;;; core-windows.el --- Window Management -*- lexical-binding: t -*-

(require 'evil)
(require 'centaur-tabs)

;; Evil Window Splitting
(defun my/evil-split-unique ()
  "Split horizontally and show the previous buffer."
  (interactive)
  (evil-window-split)
  (let ((switch-to-buffer-obey-display-actions nil))
    (switch-to-buffer (other-buffer (current-buffer) t))))

(defun my/evil-vsplit-unique ()
  "Split vertically and show the previous buffer."
  (interactive)
  (evil-window-vsplit)
  (let ((switch-to-buffer-obey-display-actions nil))
    (switch-to-buffer (other-buffer (current-buffer) t))))

;; Buffer Reuse
(advice-remove 'switch-to-buffer #'my/jump-to-visible-buffer)

(setq switch-to-buffer-obey-display-actions t)

(add-to-list 'display-buffer-alist
             '(".*"
               (display-buffer-reuse-window display-buffer-same-window)
               (reusable-frames . visible)))

(defun my/jump-to-visible-buffer (orig-fn buffer-or-name &rest args)
  (let ((window (get-buffer-window buffer-or-name 0)))
    (if window
        (progn
          (select-window window)
          (window-buffer window))
      (apply orig-fn buffer-or-name args))))

;; Centaur Tabs
(defun my/centaur-tabs-kill-on-side (direction)
  (let* ((group (centaur-tabs-current-group))
         (buffers (centaur-tabs-view group))
         (current-buf (current-buffer))
         (found nil))
    (when (memq current-buf buffers)
      (dolist (buf buffers)
        (if (eq buf current-buf)
            (setq found t)
          (when (if (eq direction 'right) found (not found))
            (kill-buffer buf))))
      (centaur-tabs-display-update))))


;; Side Windows
(add-to-list 'display-buffer-alist
             '("\\*\\(Flymake\\|Flycheck\\|Compile-Log\\|Warnings\\|Help\\|compilation\\|Backtrace\\|Eglot\\).*"
               (display-buffer-reuse-mode-window display-buffer-in-side-window)
               (side . bottom)
               (slot . 0)
               (window-height . 0.25)
               (window-parameters . ((dedicated . t) (no-other-window . t)))))
(provide 'core-windows)
;;; core-windows.el ends here
