;;; core-ui.el --- UI adjustments and optimizations -*- lexical-binding: t; -*-

;; Modeline optimizations
(with-eval-after-load 'doom-modeline
  (setq doom-modeline-height 35
        doom-modeline-bar-width 5
        doom-modeline-icon t
        doom-modeline-major-mode-icon t
        doom-modeline-major-mode-color-icon t
        doom-modeline-buffer-file-name-style 'truncate-upto-project
        doom-modeline-buffer-state-icon t
        doom-modeline-buffer-modification-icon t
        doom-modeline-minor-modes nil
        doom-modeline-enable-word-count nil
        doom-modeline-buffer-encoding t
        doom-modeline-indent-info nil
        doom-modeline-checker-simple-format t
        doom-modeline-vcs-max-length 12
        doom-modeline-env-version t
        doom-modeline-modal-icon t))

;; Base16 Isotope optimizations
(with-eval-after-load 'base16-isotope-theme
  (custom-set-faces
   '(font-lock-comment-face ((t (:slant italic))))
   '(font-lock-keyword-face ((t (:weight bold))))))

;; Centaur Tabs optimizations
(with-eval-after-load 'centaur-tabs
  (setq centaur-tabs-style "bar"
        centaur-tabs-height 36
        centaur-tabs-set-icons t
        centaur-tabs-set-modified-marker t
        centaur-tabs-show-navigation-buttons t
        centaur-tabs-set-bar 'under))

;; Fonts optimizations
(set-face-attribute 'default nil :font "JetBrains Mono" :height 120 :weight 'semi-bold)
(set-face-attribute 'fixed-pitch nil :font "JetBrains Mono" :height 120 :weight 'semi-bold)
(set-face-attribute 'variable-pitch nil :font "Roboto" :height 120 :weight 'regular)

;; Scrolling optimizations
(setq scroll-margin 2
      scroll-conservatively 101
      scroll-up-aggressively 0.01
      scroll-down-aggressively 0.01
      scroll-preserve-screen-position t
      auto-window-vscroll nil)

;; Diagnostics indicators optimizations
(setq flymake-error-bitmap '(flymake-double-exclamation-mark compilation-error)
      flymake-warning-bitmap '(exclamation-mark compilation-warning)
      flymake-note-bitmap '(exclamation-mark compilation-info))

(with-eval-after-load 'flycheck
  (setq flycheck-indication-mode 'right-fringe))

;; Window layouts optimizations
(setq window-combination-resize t
      even-window-sizes 'width-only
      window-sides-vertical nil
      fit-window-to-buffer-horizontally t)

(provide 'core-ui)
;;; core-ui.el ends here
