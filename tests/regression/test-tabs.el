;;; test-tabs.el --- Tests for tab customizations

(require 'ert)
(require 'cl-lib)

;; Mock dependencies
(defun centaur-tabs-display-update () nil)

;; Target function
(defun my/centaur-tabs-kill-on-side (direction)
  (let* ((group (centaur-tabs-current-group))
         (buffers (centaur-tabs-view group))
         (current-buf (current-buffer))
         (found nil))
    (dolist (buf buffers)
      (if (eq buf current-buf)
          (setq found t)
        (when (if (eq direction 'right) found (not found))
          (kill-buffer buf))))
    (centaur-tabs-display-update)))

(ert-deftest test-centaur-tabs-kill-on-right ()
  "Test killing tabs on the right."
  (let* ((killed-buffers nil)
         (buf1 (generate-new-buffer "buf1"))
         (buf2 (generate-new-buffer "buf2"))
         (buf3 (generate-new-buffer "buf3")))
    (cl-letf (((symbol-function 'centaur-tabs-current-group)
               (lambda () "mock-group"))
              ((symbol-function 'centaur-tabs-view)
               (lambda (_) (list buf1 buf2 buf3)))
              ((symbol-function 'kill-buffer)
               (lambda (buf) (push buf killed-buffers))))
      (with-current-buffer buf2
        (my/centaur-tabs-kill-on-side 'right)))
    (should (equal killed-buffers (list buf3)))
    (kill-buffer buf1)
    (kill-buffer buf2)
    (kill-buffer buf3)))

(ert-deftest test-centaur-tabs-kill-on-left ()
  "Test killing tabs on the left."
  (let* ((killed-buffers nil)
         (buf1 (generate-new-buffer "buf1"))
         (buf2 (generate-new-buffer "buf2"))
         (buf3 (generate-new-buffer "buf3")))
    (cl-letf (((symbol-function 'centaur-tabs-current-group)
               (lambda () "mock-group"))
              ((symbol-function 'centaur-tabs-view)
               (lambda (_) (list buf1 buf2 buf3)))
              ((symbol-function 'kill-buffer)
               (lambda (buf) (push buf killed-buffers))))
      (with-current-buffer buf2
        (my/centaur-tabs-kill-on-side 'left)))
    (should (equal killed-buffers (list buf1)))
    (kill-buffer buf1)
    (kill-buffer buf2)
    (kill-buffer buf3)))

(provide 'test-tabs)
;;; test-tabs.el ends here
