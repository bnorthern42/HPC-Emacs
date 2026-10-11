(require 'ert)
(load-file "lisp/core/core-performance.el")

(ert-deftest test-performance-gc ()
  (should (>= gc-cons-threshold (* 512 1024 1024))))

(ert-deftest test-performance-lsp ()
  (should (>= read-process-output-max (* 8 1024 1024))))

(ert-deftest test-performance-scrolling ()
  (should fast-but-imprecise-scrolling))

(ert-deftest test-performance-fontification ()
  (should redisplay-skip-fontification-on-input))

(ert-deftest test-benchmark-startup ()
  (message "Startup time measured using float-time: %s seconds"
           (format "%.2f" (float-time (time-subtract after-init-time before-init-time))))
  (should t))
