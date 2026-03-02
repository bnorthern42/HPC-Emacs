(setq read-process-output-max (* 3 1024 1024)) ; 3MB (Better for huge C++ LSP responses)
(setq create-lockfiles nil) ; Stop creating .#files (breaks some makefiles)

;; Garbage Collector Magic Hack
;; Automatically adjusts GC threshold: high when idle, low when active.
(use-package gcmh
  :ensure t
  :hook (after-init . gcmh-mode)
  :config
  (setq gcmh-high-cons-threshold (* 512 1024 1024) ; 512MB when idle
        gcmh-idle-delay 0.8))

(use-package base16-theme
:ensure t
:config
(load-theme 'base16-gigavolt t))

(use-package doom-modeline
:ensure t
:init (doom-modeline-mode 1))

(set-face-attribute 'default nil :font "JetBrains Mono" :height 120)
(global-display-line-numbers-mode 1)
(setq display-line-numbers-type 'relative)

;; Smooth Scrolling
(use-package good-scroll
  :ensure t
  :if window-system
  :config (good-scroll-mode 1))

;; Fill Column Indicator (Vertical Line at 100 chars)
(use-package display-fill-column-indicator
  :ensure nil
  :hook (prog-mode . display-fill-column-indicator-mode)
  :config
  (setq-default display-fill-column-indicator-column 100))

;; Tabs (VSCode/Eclipse style)
(use-package centaur-tabs
  :ensure t
  :demand
  :config
  (centaur-tabs-mode t)
  (setq centaur-tabs-style "rounded"
        centaur-tabs-height 32
        centaur-tabs-set-icons t
        centaur-tabs-set-modified-marker t
        centaur-tabs-show-navigation-buttons t
        centaur-tabs-set-bar 'under
        centaur-tabs-set-close-button 'left)
  (centaur-tabs-headline-match)
  (centaur-tabs-group-by-projectile-project)
  (with-eval-after-load 'evil
    (define-key evil-normal-state-map (kbd "g t") 'centaur-tabs-forward)
    (define-key evil-normal-state-map (kbd "g T") 'centaur-tabs-backward))
  (custom-set-faces
   ;; Make X bigger and yellow on tabs for closing
   '(centaur-tabs-close-selected ((t :height 1.3 :weight bold :foreground "red")))
   '(centaur-tabs-close-unselected ((t :height 1.3 :weight medium italic :foreground "yellow"))))

  ;; Custom Context Menu Logic for Tabs
  (defun my/centaur-tabs-kill-on-side (direction)
    "Kill buffers on the left or right of the current buffer in the current group."
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

  (defun my/centaur-tabs-context-menu (event)
    "Pop up a context menu for the tab bar."
    (interactive "e")
    (let ((menu (make-sparse-keymap "Context Menu")))
      (define-key menu [close-others] '(menu-item "Close Other Tabs" centaur-tabs-kill-other-buffers-in-current-group))
      (define-key menu [close-right] '(menu-item "Close Tabs to Right" (lambda () (interactive) (my/centaur-tabs-kill-on-side 'right))))
      (define-key menu [close-left] '(menu-item "Close Tabs to Left" (lambda () (interactive) (my/centaur-tabs-kill-on-side 'left))))
      (define-key menu [close] '(menu-item "Close Tab" (lambda () (interactive) (kill-buffer (current-buffer)))))
      (popup-menu menu event)))

  ;; Bind right-click on header line to the context menu
  (global-set-key [header-line mouse-3] 'my/centaur-tabs-context-menu))

;; Configure popup windows (compilation, help, etc.) to close on 'q'
(add-to-list 'display-buffer-alist
             '("\\*\\(Flymake\\|Flycheck\\|Compile-Log\\|Warnings\\|Help\\|compilation\\|Backtrace\\|Eglot\\).*"
               (display-buffer-reuse-window display-buffer-in-side-window)
               (side . bottom)
               (slot . 0)
               (window-height . 0.25)
               (window-parameters . ((dedicated . t) (no-other-window . t)))))

;; Context Menu (Right-Click)
(use-package emacs
  :init
  (context-menu-mode 1)
  :config
  (defun my/ide-context-menu (menu click)
    "Add IDE-like navigation commands to the right-click menu."
    (define-key menu [ide-separator] menu-bar-separator)
    (define-key menu [ide-go-file]
      '(menu-item "Go to File" find-file-at-point :help "Find file at point"))
    (define-key menu [ide-go-proj]
      '(menu-item "Find in Project" projectile-find-file :help "Search for file in project"))
    (when (bound-and-true-p eglot--managed-mode)
      (define-key menu [ide-go-decl]
        '(menu-item "Go to Declaration" eglot-find-declaration))
      (define-key menu [ide-go-impl]
        '(menu-item "Go to Implementation" eglot-find-implementation))
      (define-key menu [ide-go-def]
        '(menu-item "Go to Definition" xref-find-definitions)))
    menu)
  (add-hook 'context-menu-functions #'my/ide-context-menu 10)

  ;; Custom Menu Bar Items
  (define-key-after global-map [menu-bar view]
    (cons "View" (make-sparse-keymap "View"))
    'edit)
  (define-key global-map [menu-bar view treemacs]
    '(menu-item "Project Explorer" treemacs :help "Toggle File Tree"))
  (define-key global-map [menu-bar view toggle-wrap]
    '(menu-item "Toggle Word Wrap" visual-line-mode :help "Wrap long lines"))

  (define-key-after global-map [menu-bar preferences]
    (cons "Preferences" (make-sparse-keymap "Preferences"))
    'view)
  (define-key global-map [menu-bar preferences open-config]
    '(menu-item "Edit Configuration" 
                (lambda () (interactive) (find-file (expand-file-name "config.org" user-emacs-directory)))
                :help "Open config.org"))
  (define-key global-map [menu-bar preferences reload-config]
    '(menu-item "Reload Configuration" my/reload-config
                :help "Re-tangle and reload config")))

(use-package evil
:ensure t
:demand t
:init
(setq evil-want-integration t)
(setq evil-want-keybinding nil)
(setq evil-vimpulse-expand-on-all-prev-next t)
:config
(evil-mode 1))

(use-package evil-collection
:ensure t
:after evil
:config
(evil-collection-init))

;; Block until Evil is installed/loaded to ensure states are available
(elpaca-wait)

;; Leader Key setup (SPC)
(use-package general
:ensure t
:demand t
:config
(general-create-definer my/leader-keys
  :states '(normal insert visual emacs)
  :keymaps 'override
    :prefix "SPC"
    :global-prefix "C-SPC"))

;; Block until General is ready so the leader macro is defined
(elpaca-wait)

(with-eval-after-load 'general
  (my/leader-keys
    "f" '(:ignore t :which-key "files")
    "ff" '(find-file :which-key "find file")
    "bb" '(switch-to-buffer :which-key "switch buffer")
    "pp" '(projectile-command-map :which-key "projectile")
    "e" '(treemacs :which-key "explorer")))
;; Dired (File Manager) Configuration
(use-package dired
  :ensure nil
  :after evil
  :config
  (evil-define-key 'normal dired-mode-map
    (kbd "h") 'dired-up-directory
    (kbd "l") 'dired-find-file
    (kbd "RET") 'dired-find-file))

(use-package projectile
:ensure t
:init
(projectile-mode +1)
:config
(setq projectile-project-search-path '("~/projects" "~/work"))
;; Treat Makefiles and meson.build as project roots even inside git repos
(add-to-list 'projectile-project-root-files-bottom-up "meson.build")
(add-to-list 'projectile-project-root-files-bottom-up "Makefile")
;; Custom logic to prioritize builds
(setq projectile-compilation-cmd-map
'(("Makefile" . "make -j $(nproc)")
("meson.build" . "meson compile -C builddir"))))

;; File Tree (Eclipse-like Sidebar)
(use-package treemacs
  :ensure t
  :config
  (setq treemacs-width 30)
  (treemacs-follow-mode t)
  (treemacs-filewatch-mode t)
  (treemacs-fringe-indicator-mode 'always)
  (treemacs-git-mode 'simple)
  ;; Auto-open and focus on the current project/file location
  (defun my/treemacs-init ()
    (condition-case nil
        (treemacs-display-current-project-exclusively)
      (error (treemacs))))
  (add-hook 'window-setup-hook #'my/treemacs-init))

(use-package treemacs-evil
  :after (treemacs evil)
  :ensure t)

(use-package treemacs-projectile
  :after (treemacs projectile)
  :ensure t)

;; Structure/Outline Sidebar (Right Side)
(use-package imenu-list
  :ensure t
  :after general
  :config
  (setq imenu-list-focus-after-activation t)
  (setq imenu-list-auto-resize t)
  (setq imenu-list-position 'right)
  (setq imenu-list-size 30)

  ;; Custom logic to limit the depth of the outline (e.g. to 2 levels)
  (defun my/imenu-limit-depth (alist depth)
    "Recursively limit the depth of the IMENU-ALIST to DEPTH levels."
    (if (<= depth 0)
        nil
      (let (result)
        (dolist (item alist)
          (if (and (listp (cdr item)) (cdr item)) ;; It's a submenu
              (let ((children (my/imenu-limit-depth (cdr item) (1- depth))))
                (when children
                  (push (cons (car item) children) result)))
            (push item result))) ;; It's a leaf
        (nreverse result))))

  ;; Apply the limit (2 layers) to imenu-list
  (setq imenu-list-get-index-function
        (lambda () (my/imenu-limit-depth (imenu--make-index-alist) 2)))

  (my/leader-keys
    "o" '(imenu-list-smart-toggle :which-key "outline")))

;; Cheat Sheet (Bottom Right)
(defun my/toggle-cheat-sheet ()
  "Toggle a quick reference cheat sheet."
  (interactive)
  (let ((buf-name "*CheatSheet*"))
    (if (get-buffer-window buf-name)
        (delete-window (get-buffer-window buf-name))
      (with-current-buffer (get-buffer-create buf-name)
        (setq buffer-read-only nil)
        (erase-buffer)
        (insert "  HPC Emacs Cheatsheet\n")
        (insert "========================\n\n")
        (insert "Navigation\n")
        (insert "----------\n")
        (insert "gg / G      : Top / Bottom\n")
        (insert ": <num>     : Go to line\n")
        (insert "0 / $       : Start/End line\n")
        (insert "%           : Match paren\n")
        (insert "C-o / C-i   : Jump Back/Fwd\n\n")
        (insert "Editing\n")
        (insert "-------\n")
        (insert "v / V       : Visual Char/Line\n")
        (insert "C-v         : Visual Block\n")
        (insert "  + I / A   : Multi-line Edit\n")
        (insert "u / C-r     : Undo / Redo\n")
        (insert ">> / <<     : Indent\n\n")
        (insert "Windows\n")
        (insert "-------\n")
        (insert "C-w h/j/k/l : Move Focus\n")
        (insert "C-w v / s   : Split Vert/Hor\n")
        (insert "C-w c       : Close Window\n\n")
        (insert "Leader (SPC)\n")
        (insert "------------\n")
        (insert "f f         : Find File\n")
        (insert "b b         : Switch Buffer\n")
        (insert "e           : Explorer\n")
        (insert "o           : Outline\n")
        (insert "c l         : LSP Actions\n")
        (insert "d d         : Debug (Dape)\n")
        (special-mode))
      (display-buffer buf-name))))

(add-to-list 'display-buffer-alist
             '("\\*CheatSheet\\*"
               (display-buffer-in-side-window)
               (side . right)
               (slot . 1)
               (window-width . 30)
               (window-parameters . ((no-other-window . t)
                                     (no-delete-other-windows . t)))))

(my/leader-keys
  "?" '(my/toggle-cheat-sheet :which-key "cheatsheet"))

;; Markdown & Documentation
(use-package markdown-mode
  :ensure t
  :after general
  :mode ("README\\.md\\'" . gfm-mode)
  :config
  (my/leader-keys
    "m" '(:ignore t :which-key "markdown")
    "mp" '(markdown-preview :which-key "preview")))

(use-package grip-mode
  :ensure t
  :after general
  :after markdown-mode
  :config
  (my/leader-keys
    "mg" '(grip-mode :which-key "grip preview")))

(use-package eglot
:after general
:hook (c++-mode . eglot-ensure)
:config
(add-to-list 'eglot-server-programs
'((c++-mode c-mode) . ("clangd" "--header-insertion=never" "--background-index")))
;; Keybinds for LSP
(my/leader-keys
"cl" '(:ignore t :which-key "lsp")
"cla" '(eglot-code-actions :which-key "actions")
"clr" '(eglot-rename :which-key "rename")
"clf" '(eglot-format-buffer :which-key "format")
"clR" '(eglot-reconnect :which-key "reconnect")))

(use-package dape
:after general
:ensure t
:config
;; Custom configuration for MPI debugging
;; Note: For MPI, we usually attach or use a script to launch gdb on rank 0.
(add-to-list 'dape-configs
             `(gdb-attach
               modes (c-mode c++-mode)
               command "gdb"
               command-args ("--interpreter=dap")
               :request "attach"
               :pid (lambda () (string-to-number (read-string "PID to attach: ")))
               :cwd "."))

(my/leader-keys
"d" '(:ignore t :which-key "debug")
"dd" '(dape :which-key "start")
"db" '(dape-breakpoint-toggle :which-key "breakpoint")
"dn" '(dape-next :which-key "next")
"ds" '(dape-step-in :which-key "step in")))

(use-package vterm
  :ensure t
  :config
  (setq vterm-max-scrollback 10000))

(use-package vterm-toggle
  :ensure t
  :after vterm
  :config
  (setq vterm-toggle-fullscreen-p nil)
  (add-to-list 'display-buffer-alist
               '((lambda (buffer-or-name _)
                   (let ((buffer (get-buffer buffer-or-name)))
                     (with-current-buffer buffer
                       (or (equal major-mode 'vterm-mode)
                           (string-prefix-p vterm-buffer-name (buffer-name buffer))))))
                 (display-buffer-reuse-window display-buffer-in-side-window)
                 (side . bottom)
                 (slot . 1)
                 (reusable-frames . visible)
                 (window-height . 0.3)
                 (window-parameters . ((dedicated . t) (no-other-window . t)))))
  (my/leader-keys
    "t" '(vterm-toggle :which-key "terminal")))

(defun my/ensure-vterm-visible ()
  "Ensure vterm is visible."
  (unless (get-buffer-window "*vterm*")
    (vterm-toggle)))

(defun my/sh-send-line-or-region ()
  "Send the current line or region to the vterm terminal."
  (interactive)
  (my/ensure-vterm-visible)
  (let ((text (if (use-region-p)
                  (buffer-substring-no-properties (region-beginning) (region-end))
                (buffer-substring-no-properties (line-beginning-position) (line-end-position)))))
    (vterm-send-string text)
    (vterm-send-return)))

(defun my/sh-execute-file ()
  "Execute the current file in vterm."
  (interactive)
  (save-buffer)
  (let ((filename (buffer-file-name)))
    (when filename
      (my/ensure-vterm-visible)
      (vterm-send-string (concat "bash " (shell-quote-argument filename)))
      (vterm-send-return))))

(use-package sh-script
  :ensure nil
  :after (vterm general)
  :config
  (my/leader-keys
    :keymaps 'sh-mode-map
    "r" '(:ignore t :which-key "run")
    "rf" '(my/sh-execute-file :which-key "run file")
    "rl" '(my/sh-send-line-or-region :which-key "run line/region")))

(use-package vertico
:ensure t
:init (vertico-mode))

(use-package orderless
:ensure t
:init
(setq completion-styles '(orderless basic)
completion-category-defaults nil
completion-category-overrides '((file (styles partial-completion)))))

(use-package marginalia
:ensure t
:init (marginalia-mode))

(use-package consult
:ensure t)

;; In-buffer completion (Corfu)
;; This provides the "IntelliSense" popup as you type.
(use-package corfu
  :ensure t
  :init
  (global-corfu-mode)
  :config
  (setq corfu-auto t                 ;; Enable auto completion
        corfu-auto-delay 0.0         ;; Instant appearance
        corfu-auto-prefix 1          ;; Show after 1 character
        corfu-cycle t                ;; Enable cycling
        corfu-preselect 'first       ;; Always select the first candidate
        corfu-quit-no-match 'separator)
  
  ;; Popup documentation (Parameter hints & docs)
  (corfu-popupinfo-mode 1)
  (setq corfu-popupinfo-delay '(0.5 . 0.2))

  ;; Bind TAB to insert the selected candidate
  (define-key corfu-map (kbd "TAB") 'corfu-insert)
  (define-key corfu-map (kbd "<tab>") 'corfu-insert))

;; Icons for completion (VSCode-like)
(use-package kind-icon
  :ensure t
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

(defun my/reload-config ()
"Tangles the config.org file and loads the resulting config.el."
(interactive)
(let ((conf-org (expand-file-name "config.org" user-emacs-directory))
(conf-el  (expand-file-name "config.el"  user-emacs-directory)))
(require 'org)
(org-babel-tangle-file conf-org conf-el "elisp")
(load-file conf-el)
(message "Config reloaded successfully!")))

(with-eval-after-load 'general
  (my/leader-keys
   "hr" '(my/reload-config :which-key "reload config")))
