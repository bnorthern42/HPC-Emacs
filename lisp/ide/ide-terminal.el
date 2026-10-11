;;; ide-terminal.el --- Vterm and Project Terminal Integration -*- lexical-binding: t; -*-

(use-package vterm
  :ensure t
  :config
  (setq vterm-max-scrollback 10000)

  ;; 1. Reliable Evil keybindings for vterm
  (with-eval-after-load 'evil
    ;; Ensure we can enter insert mode and append
    (evil-define-key 'normal vterm-mode-map
      (kbd "i") 'evil-insert
      (kbd "A") 'evil-append-line
      (kbd "p") 'vterm-yank)

    ;; Pass standard Emacs/Terminal keys through when in insert mode
    (evil-define-key 'insert vterm-mode-map
      (kbd "C-c") 'vterm--self-insert
      (kbd "C-d") 'vterm--self-insert
      (kbd "C-z") 'vterm--self-insert
      (kbd "C-w") 'vterm--self-insert
      (kbd "C-u") 'vterm--self-insert
      (kbd "C-v") 'vterm--self-insert)))

;; 2. Project Terminal Integration (Custom Implementation)
(defvar my/project-terminals (make-hash-table :test 'equal)
  "Hash table mapping project roots to lists of vterm buffers.")

(defvar my/project-terminal-height 0.25
  "Height of the project terminal window.")

(defun my/project-root ()
  "Get the current project root or default-directory."
  (if-let ((proj (project-current)))
      (project-root proj)
    default-directory))

(defun my/project-terminal-get-buffers (root)
  "Get active terminal buffers for ROOT, filtering out dead ones."
  (let ((bufs (gethash root my/project-terminals)))
    (setq bufs (seq-filter #'buffer-live-p bufs))
    (puthash root bufs my/project-terminals)
    bufs))

(defun my/project-terminal-add ()
  "Create a new terminal for the current project."
  (interactive)
  (let* ((root (my/project-root))
         (bufs (my/project-terminal-get-buffers root))
         (index (1+ (length bufs)))
         (proj-name (file-name-nondirectory (directory-file-name root)))
         (buf-name (format "*vterm-project %s:%d*" proj-name index))
         (default-directory root))
    (let ((buf (vterm buf-name)))
      (puthash root (append bufs (list buf)) my/project-terminals)
      (my/project-terminal-display buf)
      buf)))

(defun my/project-terminal-display (buf)
  "Display the terminal buffer BUF in a bottom side window."
  (display-buffer buf
                  `((display-buffer-in-side-window)
                    (side . bottom)
                    (window-height . ,my/project-terminal-height)
                    (slot . 0))))

(defun my/project-terminal-toggle ()
  "Toggle the project terminal. Creates one if none exists."
  (interactive)
  (let* ((root (my/project-root))
         (bufs (my/project-terminal-get-buffers root))
         (visible-win (seq-some #'get-buffer-window bufs)))
    (if visible-win
        ;; If a terminal for this project is visible, hide it.
        (delete-window visible-win)
      ;; Otherwise, show the first available terminal or create one.
      (if bufs
          (my/project-terminal-display (car bufs))
        (my/project-terminal-add)))))

(with-eval-after-load 'general
  (my/leader-keys
    "tt" '(my/project-terminal-toggle :which-key "toggle project terminal")
    "tT" '(my/project-terminal-add :which-key "add project terminal")
    "tf" '(vterm :which-key "vterm standalone")))

(provide 'ide-terminal)
;;; ide-terminal.el ends here
