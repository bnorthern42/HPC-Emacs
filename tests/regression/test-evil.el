;;; test-evil.el --- Tests for Evil customizations

(require 'ert)
(require 'cl-lib)

;; Mock dependencies
(defun evil-window-split () nil)
(defun evil-window-vsplit () nil)

;; Target functions
(defun my/evil-split-unique ()
  "Split horizontally and show the previous buffer."
  (interactive)
  (evil-window-split)
  (switch-to-buffer (other-buffer (current-buffer) t)))

(defun my/evil-vsplit-unique ()
  "Split vertically and show the previous buffer."
  (interactive)
  (evil-window-vsplit)
  (switch-to-buffer (other-buffer (current-buffer) t)))

(ert-deftest test-evil-split-unique ()
  "Test `my/evil-split-unique' splits and switches buffer."
  (let ((split-called nil)
        (switch-called nil)
        (other-buf "mock-other-buffer"))
    (cl-letf (((symbol-function 'evil-window-split)
               (lambda () (setq split-called t)))
              ((symbol-function 'other-buffer)
               (lambda (&rest _) other-buf))
              ((symbol-function 'switch-to-buffer)
               (lambda (buf &rest _)
                 (setq switch-called t)
                 (should (equal buf other-buf)))))
      (my/evil-split-unique)
      (should split-called)
      (should switch-called))))

(ert-deftest test-evil-vsplit-unique ()
  "Test `my/evil-vsplit-unique' splits and switches buffer."
  (let ((vsplit-called nil)
        (switch-called nil)
        (other-buf "mock-other-buffer"))
    (cl-letf (((symbol-function 'evil-window-vsplit)
               (lambda () (setq vsplit-called t)))
              ((symbol-function 'other-buffer)
               (lambda (&rest _) other-buf))
              ((symbol-function 'switch-to-buffer)
               (lambda (buf &rest _)
                 (setq switch-called t)
                 (should (equal buf other-buf)))))
      (my/evil-vsplit-unique)
      (should vsplit-called)
      (should switch-called))))

(provide 'test-evil)
;;; test-evil.el ends here
