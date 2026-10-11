;;; test-window.el --- Tests for window management customizations

(require 'ert)
(require 'cl-lib)

;; Target function
(defun my/jump-to-visible-buffer (orig-fn buffer-or-name &rest args)
  (let ((window (get-buffer-window buffer-or-name 0)))
    (if window
        (select-window window) ;; Jump to the existing window
      (apply orig-fn buffer-or-name args)))) ;; Otherwise, open it normally

(ert-deftest test-jump-to-visible-buffer-when-visible ()
  "Test `my/jump-to-visible-buffer' when the buffer is already visible."
  (let ((select-window-called nil)
        (orig-fn-called nil)
        (mock-window "mock-window"))
    (cl-letf (((symbol-function 'get-buffer-window)
               (lambda (&rest _) mock-window))
              ((symbol-function 'select-window)
               (lambda (win &rest _)
                 (setq select-window-called t)
                 (should (equal win mock-window)))))
      (my/jump-to-visible-buffer (lambda (&rest _) (setq orig-fn-called t)) "mock-buffer")
      (should select-window-called)
      (should-not orig-fn-called))))

(ert-deftest test-jump-to-visible-buffer-when-not-visible ()
  "Test `my/jump-to-visible-buffer' when the buffer is not visible."
  (let ((select-window-called nil)
        (orig-fn-called nil))
    (cl-letf (((symbol-function 'get-buffer-window)
               (lambda (&rest _) nil))
              ((symbol-function 'select-window)
               (lambda (&rest _)
                 (setq select-window-called t))))
      (my/jump-to-visible-buffer (lambda (&rest _) (setq orig-fn-called t)) "mock-buffer")
      (should-not select-window-called)
      (should orig-fn-called))))

(provide 'test-window)
;;; test-window.el ends here
