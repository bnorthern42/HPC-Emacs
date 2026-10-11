;;; ide-git.el --- Git Integration -*- lexical-binding: t; -*-

(use-package magit
  :ensure t
  :defer t
  :init
  (with-eval-after-load 'general
    (my/leader-keys
      "g" '(:ignore t :which-key "git")
      "gg" '(magit-status :which-key "magit status")
      "gc" '(magit-clone :which-key "magit clone")
      "gf" '(magit-fetch-all :which-key "magit fetch all")
      "gl" '(magit-log-all :which-key "magit log")
      "gp" '(magit-push-current-to-pushremote :which-key "magit push")
      "gF" '(magit-pull-from-pushremote :which-key "magit pull")))
  :config
  ;; Project-aware magit status
  (defun my/magit-status-project ()
    "Open magit status for the current project root."
    (interactive)
    (let ((project (project-current)))
      (if project
          (magit-status (project-root project))
        (magit-status))))

  (with-eval-after-load 'general
    (my/leader-keys "gP" '(my/magit-status-project :which-key "project status")))

  (setq magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; Evil integration for magit
(use-package evil-magit
  :ensure t
  :after magit)

(use-package diff-hl
  :ensure t
  :defer t
  :hook ((magit-pre-refresh . diff-hl-magit-pre-refresh)
         (magit-post-refresh . diff-hl-magit-post-refresh)
         (prog-mode . diff-hl-mode)
         (dired-mode . diff-hl-dired-mode))
  :config
  (diff-hl-flydiff-mode 1)
  (diff-hl-margin-mode 1))

(provide 'ide-git)
;;; ide-git.el ends here
