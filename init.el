;;; init.el --- Robust Bootstrap Loader for HPC Emacs -*- lexical-binding: t; -*-

;; Maximize GC threshold during startup to speed up loading
(setq gc-cons-threshold most-positive-fixnum)

;; Prevent UI flickering during startup
(setq-default frame-inhibit-implied-resize t)
(setq inhibit-startup-screen t)
(menu-bar-mode 1)
(when (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))

;; --- Elpaca Package Manager Setup ---
(defvar elpaca-installer-version 0.12)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-sources-directory (expand-file-name "sources/" elpaca-directory))

;; Self-healing: Repair build symlinks if config is moved or opened under a different user
(defun my/elpaca-heal-build-symlinks ()
  "Repair broken symlinks in `elpaca-builds-directory' if moved or on a new machine."
  (when (file-directory-p elpaca-builds-directory)
    (let* ((marker-file (expand-file-name ".last-emacs-dir" elpaca-directory))
           (current-dir (file-truename user-emacs-directory))
           (canary (expand-file-name "elpaca/elpaca.el" elpaca-builds-directory))
           (last-dir (when (file-exists-p marker-file)
                       (with-temp-buffer
                         (insert-file-contents marker-file)
                         (buffer-string)))))
      (unless (and (equal last-dir current-dir)
                   (file-exists-p canary))
        (let ((repaired 0))
          (dolist (file (directory-files-recursively elpaca-builds-directory "" t (lambda (_) t)))
            (when (file-symlink-p file)
              (let ((target (file-symlink-p file)))
                (when (string-match "elpaca/sources/\\(.*\\)\\'" target)
                  (let ((expected (expand-file-name (match-string 1 target) elpaca-sources-directory)))
                    (unless (and (file-exists-p file)
                                 (equal (ignore-errors (file-truename file))
                                        (ignore-errors (file-truename expected))))
                      (delete-file file)
                      (if (file-exists-p expected)
                          (progn
                            (make-symbolic-link expected file t)
                            (setq repaired (1+ repaired)))
                        (message "Removed dangling Elpaca symlink: %s" file))))))))
          (with-temp-file marker-file
            (insert current-dir))
          (when (> repaired 0)
            (message "Healed %d Elpaca build symlink(s)." repaired)))))))

(my/elpaca-heal-build-symlinks)

(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1 :inherit ignore
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca-activate)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-sources-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (<= emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth) "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (let ((load-source-file-function nil)) (load "./elpaca-autoloads"))))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;; Install use-package support
(elpaca elpaca-use-package
  (elpaca-use-package-mode))
(elpaca-wait)

;; --- Literate Config Loading ---
(defun my/display-startup-time ()
  (message "Emacs loaded in %s with %d garbage collections."
           (format "%.2f seconds"
                   (float-time
                    (time-subtract after-init-time before-init-time)))
           gcs-done)
  ;; Reset GC threshold to a reasonable value (50MB) after startup
  (setq gc-cons-threshold (* 50 1024 1024)))
(add-hook 'emacs-startup-hook #'my/display-startup-time)

(let ((core-org (expand-file-name "core.org" user-emacs-directory))
      (core-el  (expand-file-name "core.el"  user-emacs-directory))
      (ide-org (expand-file-name "ide.org" user-emacs-directory))
      (ide-el  (expand-file-name "ide.el"  user-emacs-directory))
      (lang-org (expand-file-name "lang.org" user-emacs-directory))
      (lang-el  (expand-file-name "lang.el"  user-emacs-directory)))
  (if (and (file-exists-p core-org) (file-exists-p ide-org) (file-exists-p lang-org))
      (progn
        (require 'org)
        (when (or (not (file-exists-p core-el))
                  (file-newer-than-file-p core-org core-el))
          (org-babel-tangle-file core-org core-el "elisp"))
        (load core-el)
        (when (or (not (file-exists-p ide-el))
                  (file-newer-than-file-p ide-org ide-el))
          (org-babel-tangle-file ide-org ide-el "elisp"))
        (load ide-el)
        (when (or (not (file-exists-p lang-el))
                  (file-newer-than-file-p lang-org lang-el))
          (org-babel-tangle-file lang-org lang-el "elisp"))
        (load lang-el))
    (message "Missing org files in %s" user-emacs-directory)))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(cua-mode t)
 '(display-line-numbers-type 'relative)
 '(global-display-line-numbers-mode t)
 '(package-selected-packages
   '(consult dape evil magit marginalia orderless projectile vertico))
 '(tool-bar-mode nil)
 '(warning-suppress-types '((treesit))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(centaur-tabs-close-selected ((t :height 1.3 :weight bold :foreground "red")))
 '(centaur-tabs-close-unselected ((t :height 1.3 :weight medium italic :foreground "yellow"))))
