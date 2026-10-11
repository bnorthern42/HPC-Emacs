;;; test-heex.el --- Tests for HEEx editing customizations

(require 'ert)
(require 'cl-lib)

;; Target function
(defun my/heex-tab-handler ()
  "Intercept TAB to dynamically expand *-if and *-for tags, fallback to Emmet."
  (interactive)
  (if (looking-back "\\b\\([[:alnum:]_.]+\\)-\\(if\\|for\\)" (line-beginning-position))
      (let ((tag (match-string 1))
            (attr (match-string 2)))
        (delete-region (match-beginning 0) (match-end 0))
        (insert (format "<%s :%s={}>" tag attr))
        (save-excursion
          (insert (format "</%s>" tag)))
        (backward-char 2))
    (call-interactively 'emmet-expand-line)))

(ert-deftest test-heex-tab-handler-div-if ()
  "Test `my/heex-tab-handler' expands div-if."
  (cl-letf (((symbol-function 'emmet-expand-line)
             (lambda () (error "Should not be called"))))
    (with-temp-buffer
      (insert "div-if")
      (my/heex-tab-handler)
      (should (equal (buffer-string) "<div :if={}></div>"))
      ;; Check point position: inside the {}
      (should (equal (char-before) ?{))
      (should (equal (char-after) ?})))))

(ert-deftest test-heex-tab-handler-span-for ()
  "Test `my/heex-tab-handler' expands span-for."
  (cl-letf (((symbol-function 'emmet-expand-line)
             (lambda () (error "Should not be called"))))
    (with-temp-buffer
      (insert "span-for")
      (my/heex-tab-handler)
      (should (equal (buffer-string) "<span :for={}></span>"))
      (should (equal (char-before) ?{))
      (should (equal (char-after) ?})))))

(ert-deftest test-heex-tab-handler-fallback ()
  "Test `my/heex-tab-handler' falls back to emmet."
  (let ((emmet-called nil))
    (cl-letf (((symbol-function 'call-interactively)
               (lambda (cmd)
                 (if (eq cmd 'emmet-expand-line)
                     (setq emmet-called t)
                   (error "Unexpected command %s" cmd)))))
      (with-temp-buffer
        (insert "div")
        (my/heex-tab-handler)
        (should emmet-called)))))

(provide 'test-heex)
;;; test-heex.el ends here
