;;; test-project.el --- Tests for project navigation

(require 'ert)
(require 'cl-lib)

;; Target function
(defun my/project-find-root (dir)
  (let ((root (or (locate-dominating-file dir "mix.exs")
                  (locate-dominating-file dir ".project"))))
    (when root
      (cons 'transient root))))

(ert-deftest test-project-find-root-mix-exs ()
  "Test finding project root with mix.exs."
  (let ((temp-dir (make-temp-file "project-test" t)))
    (unwind-protect
        (progn
          (with-temp-file (expand-file-name "mix.exs" temp-dir) (insert ""))
          (let ((subdir (expand-file-name "lib/module" temp-dir)))
            (make-directory subdir t)
            (let ((result (my/project-find-root subdir)))
              (should (consp result))
              (should (eq (car result) 'transient))
              ;; locate-dominating-file returns trailing slash
              (should (equal (cdr result) (file-name-as-directory temp-dir))))))
      (delete-directory temp-dir t))))

(ert-deftest test-project-find-root-dot-project ()
  "Test finding project root with .project."
  (let ((temp-dir (make-temp-file "project-test2" t)))
    (unwind-protect
        (progn
          (with-temp-file (expand-file-name ".project" temp-dir) (insert ""))
          (let ((subdir (expand-file-name "src/module" temp-dir)))
            (make-directory subdir t)
            (let ((result (my/project-find-root subdir)))
              (should (consp result))
              (should (eq (car result) 'transient))
              (should (equal (cdr result) (file-name-as-directory temp-dir))))))
      (delete-directory temp-dir t))))

(ert-deftest test-project-find-root-none ()
  "Test when no project root is found."
  (let ((temp-dir (make-temp-file "project-test3" t)))
    (unwind-protect
        (should-not (my/project-find-root temp-dir))
      (delete-directory temp-dir t))))

(provide 'test-project)
;;; test-project.el ends here
