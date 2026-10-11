;;; ide-tests.el --- Unified IDE Test Interface -*- lexical-binding: t; -*-

;;; Commentary:
;; A unified IDE test interface supporting test discovery, execution, debugging,
;; rerunning failures, and displaying results through a shared test adapter API.

;;; Code:

(defvar ide-tests-current-adapter nil
  "The currently active test adapter (a symbol representing the backend).")

(defvar ide-tests-last-run nil
  "Information about the last test run.")

(defvar ide-tests-adapter-discover-fn nil
  "Function to discover tests in the current project or buffer.
Should return a list of test definitions or populate a UI.")

(defvar ide-tests-adapter-run-fn nil
  "Function to run tests.
Can accept an optional SCOPE argument (e.g., 'all, 'at-point, 'failed).")

(defvar ide-tests-adapter-debug-fn nil
  "Function to debug tests.
Can accept an optional SCOPE argument (e.g., 'at-point).")

(defvar ide-tests-adapter-show-results-fn nil
  "Function to show the results of the last test run.")

(defun ide-tests-register-adapter (name &rest kwargs)
  "Register a test adapter with NAME.
KWARGS can include :discover, :run, :debug, and :show-results."
  (setq ide-tests-current-adapter name
        ide-tests-adapter-discover-fn (plist-get kwargs :discover)
        ide-tests-adapter-run-fn (plist-get kwargs :run)
        ide-tests-adapter-debug-fn (plist-get kwargs :debug)
        ide-tests-adapter-show-results-fn (plist-get kwargs :show-results)))

(defun ide-tests-discover ()
  "Discover tests using the current adapter."
  (interactive)
  (if ide-tests-adapter-discover-fn
      (funcall ide-tests-adapter-discover-fn)
    (message "No test adapter discover function registered.")))

(defun ide-tests-run-all ()
  "Run all tests using the current adapter."
  (interactive)
  (if ide-tests-adapter-run-fn
      (funcall ide-tests-adapter-run-fn 'all)
    (message "No test adapter run function registered.")))

(defun ide-tests-run-at-point ()
  "Run the test at point using the current adapter."
  (interactive)
  (if ide-tests-adapter-run-fn
      (funcall ide-tests-adapter-run-fn 'at-point)
    (message "No test adapter run function registered.")))

(defun ide-tests-run-failed ()
  "Rerun failed tests using the current adapter."
  (interactive)
  (if ide-tests-adapter-run-fn
      (funcall ide-tests-adapter-run-fn 'failed)
    (message "No test adapter run function registered.")))

(defun ide-tests-debug-at-point ()
  "Debug the test at point using the current adapter."
  (interactive)
  (if ide-tests-adapter-debug-fn
      (funcall ide-tests-adapter-debug-fn 'at-point)
    (message "No test adapter debug function registered.")))

(defun ide-tests-show-results ()
  "Show the results of the last test run using the current adapter."
  (interactive)
  (if ide-tests-adapter-show-results-fn
      (funcall ide-tests-adapter-show-results-fn)
    (message "No test adapter show-results function registered.")))

(provide 'ide-tests)
;;; ide-tests.el ends here
