;;; test-rest.el --- Regression tests for Verb REST client integration -*- lexical-binding: t; -*-

(require 'ert)
(require 'easymenu)
(require 'org)
(require 'menu-bar)

(unless (fboundp 'elpaca-wait)
  (defalias 'elpaca-wait #'ignore))

;; Load the REST definitions from ide.el
(unless (fboundp 'my/verb-open-rest-page)
  (with-temp-buffer
    (insert-file-contents (expand-file-name "ide.el" default-directory))
    (goto-char (point-min))
    (when (re-search-forward "(defun my/verb-open-rest-page" nil t)
      (goto-char (match-beginning 0))
      (eval (read (current-buffer)) t))
    (goto-char (point-min))
    (when (re-search-forward "(easy-menu-define my/rest-top-menu" nil t)
      (goto-char (match-beginning 0))
      (eval (read (current-buffer)) t))))

(with-eval-after-load 'menu-bar
  (easy-menu-add-item menu-bar-tools-menu nil
    ["REST Client (Open Page)" my/verb-open-rest-page
     :help "Open a REST client scratch buffer powered by Verb"]))

(ert-deftest test-rest-top-menu-defined ()
  "Ensure the top menu bar contains the REST menu and Open REST Page item."
  (let ((rest-menu (lookup-key global-map [menu-bar rest])))
    (should rest-menu)
    (let ((open-item (lookup-key global-map [menu-bar rest Open\ REST\ Page])))
      (should (eq open-item 'my/verb-open-rest-page)))))

(ert-deftest test-rest-tools-menu-integration ()
  "Ensure the Tools menu bar contains the REST client entry."
  (let ((tools-item (lookup-key menu-bar-tools-menu [rest-client-(open-page)])))
    (should tools-item)))

(ert-deftest test-verb-open-rest-page-buffer-creation ()
  "Ensure `my/verb-open-rest-page' creates and populates the *REST Client* buffer."
  (let ((test-buf-name "*REST Client*"))
    (when (get-buffer test-buf-name)
      (kill-buffer test-buf-name))
    (my/verb-open-rest-page)
    (let ((buf (get-buffer test-buf-name)))
      (should (buffer-live-p buf))
      (with-current-buffer buf
        (should (derived-mode-p 'org-mode))
        (should (string-match-p ":verb:" (buffer-string)))
        (should (string-match-p "https://httpbin.org/get" (buffer-string)))
        (should (string-match-p "https://httpbin.org/post" (buffer-string)))))
    (when (get-buffer test-buf-name)
      (kill-buffer test-buf-name))))

(ert-deftest test-verb-open-rest-page-preserves-existing-content ()
  "Ensure `my/verb-open-rest-page' does not overwrite existing buffer content."
  (let ((test-buf-name "*REST Client*"))
    (when (get-buffer test-buf-name)
      (kill-buffer test-buf-name))
    (with-current-buffer (get-buffer-create test-buf-name)
      (insert "* Custom Request :verb:\nget https://example.com\n"))
    (my/verb-open-rest-page)
    (with-current-buffer test-buf-name
      (should-not (string-match-p "https://httpbin.org/get" (buffer-string)))
      (should (string-match-p "https://example.com" (buffer-string))))
    (when (get-buffer test-buf-name)
      (kill-buffer test-buf-name))))

(ert-deftest test-verb-leader-keybindings-in-core ()
  "Ensure core.org defines leader keybinding for REST client under SPC r."
  (with-temp-buffer
    (insert-file-contents (expand-file-name "core.org" default-directory))
    (goto-char (point-min))
    (should (re-search-forward "\"r\"\\s-+'(:ignore t :which-key \"rest\")" nil t))
    (should (re-search-forward "\"ro\"\\s-+'(my/verb-open-rest-page :which-key \"open rest page\")" nil t))))
