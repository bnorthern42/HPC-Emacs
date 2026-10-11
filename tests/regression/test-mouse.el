;;; test-mouse.el --- Tests for mouse actions

(require 'ert)
(require 'cl-lib)

;; Target function
(defun my/editor-context-menu (event)
  "Open the normal Emacs context menu in editor buffers."
  (interactive "e")
  (mouse-set-point event)
  (if (fboundp 'context-menu-open)
      (context-menu-open)
    (mouse-menu-major-mode-map event)))

(ert-deftest test-editor-context-menu-with-context-menu-open ()
  "Test `my/editor-context-menu' when `context-menu-open' is bound."
  (let ((mouse-set-point-called nil)
        (context-menu-open-called nil)
        (mouse-menu-called nil))
    (cl-letf (((symbol-function 'mouse-set-point)
               (lambda (_) (setq mouse-set-point-called t)))
              ((symbol-function 'fboundp)
               (lambda (sym) (eq sym 'context-menu-open)))
              ((symbol-function 'context-menu-open)
               (lambda () (setq context-menu-open-called t)))
              ((symbol-function 'mouse-menu-major-mode-map)
               (lambda (_) (setq mouse-menu-called t))))
      (my/editor-context-menu 'mock-event)
      (should mouse-set-point-called)
      (should context-menu-open-called)
      (should-not mouse-menu-called))))

(ert-deftest test-editor-context-menu-without-context-menu-open ()
  "Test `my/editor-context-menu' when `context-menu-open' is not bound."
  (let ((mouse-set-point-called nil)
        (context-menu-open-called nil)
        (mouse-menu-called nil))
    (cl-letf (((symbol-function 'mouse-set-point)
               (lambda (_) (setq mouse-set-point-called t)))
              ((symbol-function 'fboundp)
               (lambda (_) nil))
              ((symbol-function 'context-menu-open)
               (lambda () (setq context-menu-open-called t)))
              ((symbol-function 'mouse-menu-major-mode-map)
               (lambda (_) (setq mouse-menu-called t))))
      (my/editor-context-menu 'mock-event)
      (should mouse-set-point-called)
      (should-not context-menu-open-called)
      (should mouse-menu-called))))

(provide 'test-mouse)
;;; test-mouse.el ends here
