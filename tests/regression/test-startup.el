;;; test-startup.el --- Verification for startup and leader key definitions -*- lexical-binding: t; -*-

(require 'ert)

(defvar elpaca-directory)
(defvar elpaca-builds-directory)
(defvar elpaca-sources-directory)

(unless (fboundp 'my/elpaca-heal-build-symlinks)
  (with-temp-buffer
    (insert-file-contents (expand-file-name "init.el" default-directory))
    (goto-char (point-min))
    (when (re-search-forward "(defun my/elpaca-heal-build-symlinks" nil t)
      (goto-char (match-beginning 0))
      (eval (read (current-buffer)) t))))

(ert-deftest test-elpaca-no-broken-symlinks ()
  "Ensure no broken symlinks exist in the elpaca builds directory."
  (let ((builds-dir (expand-file-name "elpaca/builds" default-directory)))
    (when (file-directory-p builds-dir)
      (let ((broken nil))
        (dolist (file (directory-files-recursively builds-dir "" t))
          (when (and (file-symlink-p file)
                     (not (file-exists-p file)))
            (push file broken)))
        (should (null broken))))))

(ert-deftest test-general-leader-definer ()
  "Ensure `my/leader-keys' is defined and functional when general is loaded."
  (let ((general-dir (expand-file-name "elpaca/builds/general" default-directory)))
    (when (file-directory-p general-dir)
      (add-to-list 'load-path general-dir)
      (require 'general)
      (should (fboundp 'general-create-definer))
      (unless (fboundp 'my/leader-keys)
        (general-create-definer my/leader-keys
          :states '(normal insert visual emacs)
          :keymaps 'override
          :prefix "SPC"
          :global-prefix "C-SPC"))
      (should (fboundp 'my/leader-keys)))))

(ert-deftest test-elpaca-self-healing ()
  "Ensure `my/elpaca-heal-build-symlinks' repairs broken symlinks."
  (let* ((tmp (expand-file-name "test-heal-ert" temporary-file-directory))
         (test-emacs-dir (file-name-as-directory tmp))
         (test-elpaca-dir (expand-file-name "elpaca/" test-emacs-dir))
         (test-builds-dir (expand-file-name "builds/" test-elpaca-dir))
         (test-sources-dir (expand-file-name "sources/" test-elpaca-dir))
         (test-pkg-src (expand-file-name "foo/foo.el" test-sources-dir))
         (test-pkg-build (expand-file-name "foo" test-builds-dir))
         (test-pkg-link (expand-file-name "foo.el" test-pkg-build)))
    (unwind-protect
        (progn
          (make-directory (file-name-directory test-pkg-src) t)
          (make-directory test-pkg-build t)
          (with-temp-file test-pkg-src (insert ";; test"))
          (make-symbolic-link "/home/fake-old-user/dotfiles/elpaca/sources/foo/foo.el" test-pkg-link t)
          (should-not (file-exists-p test-pkg-link))
          (let ((user-emacs-directory test-emacs-dir)
                (elpaca-directory test-elpaca-dir)
                (elpaca-builds-directory test-builds-dir)
                (elpaca-sources-directory test-sources-dir))
            (my/elpaca-heal-build-symlinks))
          (should (file-exists-p test-pkg-link))
          (should (equal (file-truename test-pkg-link) (file-truename test-pkg-src))))
      (when (file-directory-p tmp)
        (delete-directory tmp t)))))
