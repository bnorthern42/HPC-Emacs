(setq native-comp-async-report-warnings-errors 'silent)
(setq read-process-output-max (* 8 1024 1024)) ; 8MB (Better for huge C++ LSP responses)
(setq create-lockfiles nil) ; Stop creating .#files (breaks some makefiles)

;; Garbage Collector Magic Hack automatically adjusts GC threshold.
(use-package gcmh
  :ensure t
  :hook (after-init . gcmh-mode)
  :config
  (setq gcmh-high-cons-threshold (* 512 1024 1024) ; 512MB when idle
        gcmh-low-cons-threshold (* 64 1024 1024)   ; 64MB when typing
        gcmh-idle-delay 1.5))

(setq fast-but-imprecise-scrolling t)
(setq redisplay-skip-fontification-on-input t)
(setq bidi-display-reordering nil)
(setq bidi-paragraph-direction 'left-to-right)

;; Pull base16-emacs directly from the tinted-theming GitHub repository
(use-package base16-theme
  :ensure (:host github :repo "tinted-theming/base16-emacs")
  :config
  ;; Load the specific isotope theme
  (load-theme 'base16-isotope t))

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1))

(set-face-attribute 'default nil :font "JetBrains Mono" :height 120)
(global-display-line-numbers-mode 1)
(setq display-line-numbers-type 'relative)

(scroll-bar-mode 1)

(use-package good-scroll
  :ensure t
  :if window-system
  :config (good-scroll-mode 1))

(use-package display-fill-column-indicator
  :ensure nil
  :hook (prog-mode . display-fill-column-indicator-mode)
  :config
  (setq-default display-fill-column-indicator-column 100))

(use-package centaur-tabs
  :ensure t
  :demand
  :config
  (centaur-tabs-mode t)
  (setq centaur-tabs-style "rounded"
        centaur-tabs-height 32
        centaur-tabs-set-icons t
        centaur-tabs-set-bar 'under)
  (with-eval-after-load 'evil
    (define-key evil-normal-state-map (kbd "g t") 'centaur-tabs-forward)
    (define-key evil-normal-state-map (kbd "g T") 'centaur-tabs-backward))
  (custom-set-faces
   '(centaur-tabs-close-selected ((t :height 1.3 :weight bold :foreground "red")))
   '(centaur-tabs-close-unselected ((t :height 1.3 :weight medium italic :foreground "yellow"))))

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

  (defun my/centaur-tabs-context-menu (event)
    (interactive "e")
    (let ((menu (make-sparse-keymap "Context Menu")))
      (define-key menu [close-others] '(menu-item "Close Other Tabs" centaur-tabs-kill-other-buffers-in-current-group))
      (define-key menu [close-right] '(menu-item "Close Tabs to Right" (lambda () (interactive) (my/centaur-tabs-kill-on-side 'right))))
      (define-key menu [close] '(menu-item "Close Tab" (lambda () (interactive) (kill-buffer (current-buffer)))))
      (popup-menu menu event)))

  (global-set-key [header-line mouse-3] 'my/centaur-tabs-context-menu))

(add-to-list 'display-buffer-alist
             '("\\*\\(Flymake\\|Flycheck\\|Compile-Log\\|Warnings\\|Help\\|compilation\\|Backtrace\\|Eglot\\).*"
               (display-buffer-reuse-window display-buffer-in-side-window)
               (side . bottom)
               (slot . 0)
               (window-height . 0.25)
               (window-parameters . ((dedicated . t) (no-other-window . t)))))

(use-package which-key
  :ensure t
  :init (which-key-mode)
  :config
  (setq which-key-idle-delay 0.3))

(use-package evil
  :ensure t
  :demand t
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  :config
  (evil-mode 1))

(use-package evil-collection
  :ensure t
  :after evil
  :config
  (evil-collection-init))

(elpaca-wait)

(use-package general
  :ensure t
  :demand t
  :config
  (general-create-definer my/leader-keys
    :states '(normal insert visual emacs)
    :keymaps 'override
    :prefix "SPC"
    :global-prefix "C-SPC"))

(elpaca-wait)

(with-eval-after-load 'general
  (my/leader-keys
    "f" '(:ignore t :which-key "files")
    "ff" '(find-file :which-key "find file")
    "bb" '(switch-to-buffer :which-key "switch buffer")
    "p" '(projectile-command-map :which-key "projectile")
    "e" '(treemacs :which-key "explorer")))

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
  (setq projectile-switch-project-action #'projectile-find-file))

(use-package treemacs
  :ensure t
  :config
  (setq treemacs-width 30)
  (treemacs-follow-mode t))

(use-package imenu-list
  :ensure t
  :after general
  :config
  (setq imenu-list-position 'right)
  (setq imenu-list-size 30)
  (my/leader-keys "o" '(imenu-list-smart-toggle :which-key "outline")))

;; 1. EXORCISE THE GHOSTS: Remove any old tree-sitter remapping
(setq major-mode-remap-alist (assq-delete-all 'elixir-mode major-mode-remap-alist))

;; 2. Install and Force Standard Elixir Mode
(use-package elixir-mode
  :ensure t
  :mode ("\\.ex\\'" . elixir-mode)
  :mode ("\\.exs\\'" . elixir-mode)
  :config
  ;; Double-check font-lock is forcefully enabled when entering the mode
  (add-hook 'elixir-mode-hook (lambda () (font-lock-mode 1))))

(elpaca-wait)

;; 3. Alchemist Integration
(use-package alchemist
  :ensure t
  :after (elixir-mode general)
  :hook (elixir-mode . alchemist-mode)
  :config
  (my/leader-keys
    :keymaps 'elixir-mode-map
    "cl"  '(:ignore t :which-key "elixir/lsp")
    "clt" '(alchemist-project-run-tests :which-key "run tests")
    "clb" '(alchemist-project-compile :which-key "compile project")
    "cli" '(alchemist-iex-run :which-key "run iex")
    "clh" '(alchemist-help-search-at-point :which-key "help at point")
    "cld" '(alchemist-goto-definition-at-point :which-key "go to definition")))

;; 4. Linter
(use-package flycheck-credo
  :ensure t
  :after (flycheck elixir-mode)
  :config
  (flycheck-credo-setup))

(use-package web-mode
  :ensure t
  :mode ("\\.eex\\'" . web-mode)
  :mode ("\\.heex\\'" . web-mode)
  :config
  ;; Tell web-mode to use the Elixir engine for these files
  (setq web-mode-engines-alist
        '(("elixir" . "\\.heex\\'\\|\\.eex\\'")))

  ;; The Magic: Enable auto-closing for brackets, quotes, and HTML tags
  (setq web-mode-enable-auto-pairing t) ; Closes (), [], {}
  (setq web-mode-enable-auto-closing t) ; Closes <div> with </div>
  (setq web-mode-enable-auto-quoting t) ; Adds quotes around HTML attributes

  ;; Indentation (2 spaces is standard for Elixir/HTML)
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-code-indent-offset 2)
  
  ;; Make sure smartparens stays out of web-mode's way to prevent double-closing
  (add-hook 'web-mode-hook (lambda () (smartparens-mode -1))))

(use-package eglot
  :after general
  :hook (c++-mode . eglot-ensure)
  :config
  (add-to-list 'eglot-server-programs
               '((c++-mode c-mode) . ("clangd" "--header-insertion=never" "--background-index")))
  (my/leader-keys
    "cl" '(:ignore t :which-key "lsp")
    "clf" '(eglot-format-buffer :which-key "format")))

(use-package dape
  :after general
  :ensure t
  :config
  (my/leader-keys
    "d" '(:ignore t :which-key "debug")
    "dd" '(dape :which-key "start")))

(use-package vterm
  :ensure t
  :config
  (setq vterm-max-scrollback 10000))

(use-package vterm-toggle
  :ensure t
  :after vterm
  :config
  (my/leader-keys "t" '(vterm-toggle :which-key "terminal")))

;; FORCE Elpaca to grab the latest compat library from ELPA/MELPA
;; overriding the older one built into Emacs 30.2.
(use-package compat
  :ensure t)

(elpaca-wait) ;; Critical: wait for compat to install before continuing

(use-package vertico
  :ensure t
  :init (vertico-mode))

(use-package consult
  :ensure t
  :after general
  :config
  (my/leader-keys
    "bb" '(consult-buffer :which-key "switch buffer")
    "fs" '(consult-ripgrep :which-key "ripgrep")))

(use-package corfu
  :ensure t
  :init (global-corfu-mode)
  :config
  (setq corfu-auto t
        corfu-auto-delay 0.2
        corfu-auto-prefix 2))

(defun my/reload-config ()
  "Tangles the config.org file and loads the resulting config.el."
  (interactive)
  (let ((conf-org (expand-file-name "config.org" user-emacs-directory))
        (conf-el  (expand-file-name "config.el"  user-emacs-directory)))
    (require 'org)
    (org-babel-tangle-file conf-org conf-el "elisp")
    (load-file conf-el)
    (message "Config reloaded!")))

(with-eval-after-load 'general
  (my/leader-keys "hr" '(my/reload-config :which-key "reload config")))

;; Restore session at the very end
(use-package desktop
  :ensure nil
  :config
  (setq desktop-save t
        desktop-load-locked-desktop t
        desktop-restore-eager 5)
  (desktop-save-mode 1))
