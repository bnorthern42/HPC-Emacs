;;; core-compat.el --- Compatibility and performance overrides -*- lexical-binding: t; -*-

;; 1. Fix Performance: Excessive read-process-output-max
;; 8MB causes allocation latency and memory spikes. 3MB is the sweet spot.
(setq read-process-output-max (* 3 1024 1024))

;; 2. Fix Performance: Excessive gcmh-high-cons-threshold
;; 512MB causes severe GC freezes. 32MB is a more balanced threshold.
(setq gcmh-high-cons-threshold (* 32 1024 1024))
(with-eval-after-load 'gcmh
  (setq gcmh-high-cons-threshold (* 32 1024 1024)))

;; 3. Fix Deprecated API: bidi-display-reordering
;; Disabling this in modern Emacs causes rendering corruption.
(setq bidi-display-reordering t)

;; 5. Fix Bugs: context-menu-open arity error
;; Modern Emacs requires the event argument to be passed to context-menu-open.
(defun my/editor-context-menu (event)
  "Open the normal Emacs context menu in editor buffers."
  (interactive "e")
  (mouse-set-point event)
  (if (fboundp 'context-menu-open)
      (context-menu-open event)
    (mouse-menu-major-mode-map event)))

;; 6. Fix Conflicting Hooks: Forced font-lock-mode in elixir-mode
;; Global font-lock is already enabled; forcing it locally disrupts tree-sitter and themes.
(require 'seq)
(defun my/cleanup-elixir-font-lock-hook ()
  "Remove the forced font-lock-mode lambda from elixir-mode-hook."
  (when (boundp 'elixir-mode-hook)
    (setq elixir-mode-hook
          (seq-remove (lambda (fn)
                        (string-match-p "font-lock-mode" (prin1-to-string fn)))
                      elixir-mode-hook))))
;; Clean it up if it's already loaded, and also add it to the hook to run when elixir-mode loads
(my/cleanup-elixir-font-lock-hook)
(with-eval-after-load 'elixir-mode
  (my/cleanup-elixir-font-lock-hook))

(provide 'core-compat)
;;; core-compat.el ends here
