;;; init.el --- Robust Bootstrap Loader for HPC Emacs -*- lexical-binding: t; -*-

;; Maximize GC threshold during startup to speed up loading
(setq gc-cons-threshold most-positive-fixnum)

;; Prevent UI flickering during startup
(setq-default frame-inhibit-implied-resize t)
(setq inhibit-startup-screen t)
(menu-bar-mode 1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; --- Elpaca Package Manager Setup ---
(defvar elpaca-installer-version 0.11)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1 :inherit ignore
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
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
  ;; Reset GC threshold to a reasonable value (20MB) after startup
  (setq gc-cons-threshold (* 20 1024 1024)))
(add-hook 'emacs-startup-hook #'my/display-startup-time)

(let ((conf-org (expand-file-name "config.org" user-emacs-directory))
      (conf-el  (expand-file-name "config.el"  user-emacs-directory)))
  (if (file-exists-p conf-org)
      (progn
        ;; Only tangle if config.org is newer than config.el
        (when (or (not (file-exists-p conf-el))
                  (file-newer-than-file-p conf-org conf-el))
          (require 'org)
          (org-babel-tangle-file conf-org conf-el "elisp"))
        (load conf-el))
    (message "No config.org found in %s" user-emacs-directory)))
