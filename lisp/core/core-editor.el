;;; lisp/core/core-editor.el -*- lexical-binding: t; -*-

;; Improve indentation and whitespace handling
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq require-final-newline t)
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; Automatic pairing
(electric-pair-mode 1)

;; Commenting
(global-set-key (kbd "M-;") 'comment-line)

;; Undo history
(setq undo-limit 800000)
(setq undo-strong-limit 12000000)
(setq undo-outer-limit 120000000)

;; File backups
(setq backup-directory-alist '(("." . "~/.emacs.d/backups")))
(setq delete-old-versions -1)
(setq version-control t)
(setq vc-make-backup-files t)
(setq auto-save-file-name-transforms '((".*" "~/.emacs.d/auto-save-list/" t)))

;; Text manipulation
(delete-selection-mode 1)
(global-subword-mode 1)

(provide 'core-editor)
