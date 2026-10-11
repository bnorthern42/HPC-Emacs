;;; ide-lsp.el --- Centralized Eglot configuration -*- lexical-binding: t; -*-

(use-package eglot
  :ensure nil
  :defer t
  :config
  ;; Eglot uses project.el by default to detect the project root and Flymake for diagnostics.
  (with-eval-after-load 'evil
    (evil-define-key 'normal eglot-mode-map
      (kbd "g d") 'xref-find-definitions
      (kbd "g r") 'xref-find-references
      (kbd "g R") 'eglot-rename
      (kbd "g a") 'eglot-code-actions)))

(provide 'ide-lsp)
;;; ide-lsp.el ends here
