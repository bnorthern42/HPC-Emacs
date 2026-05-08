;; ARCH LINUX SHIM: Pacman pre-loads an older 'compat' library.
;; Corfu demands a new Emacs 31 function called `set-local`. 
;; We polyfill it here to stop the minibuffer crashes.
(unless (fboundp 'set-local)
  (defun set-local (variable value)
    (set (make-local-variable variable) value)))

;; Force Elpaca to grab the latest compat library first
(use-package compat
  :ensure t)

(elpaca-wait)

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
  :init 
  (setq doom-modeline-modal t)
  (setq doom-modeline-major-mode-icon t)
  :config
  ;; Force it to load late to ensure all dependencies (like evil) exist
  (add-hook 'after-init-hook #'doom-modeline-mode)
  
  ;; Prevent the redisplay crash
  (setq doom-modeline-check-stats nil)
  (setq doom-modeline-env-version t))

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

(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package centaur-tabs
  :ensure t
  :demand
  :config
  (centaur-tabs-mode t)
  (setq centaur-tabs-style "rounded"
        centaur-tabs-height 32
        centaur-tabs-set-icons t
        centaur-tabs-set-bar 'under
        ;; --- THE FIX FOR THE 'X' BUTTON ---
        centaur-tabs-set-close-button t
        centaur-tabs-close-button " x ") 

  (with-eval-after-load 'evil
    (define-key evil-normal-state-map (kbd "g t") 'centaur-tabs-forward)
    (define-key evil-normal-state-map (kbd "g T") 'centaur-tabs-backward))

  ;; Styling the 'x' button to be distinct
  (custom-set-faces
   '(centaur-tabs-close-selected ((t :height 0.9 :weight bold :foreground "#ff5555")))
   '(centaur-tabs-close-unselected ((t :height 0.9 :weight medium :foreground "#555555")))
   '(centaur-tabs-selected ((t :background "#282a36" :foreground "#f8f8f2")))
   '(centaur-tabs-unselected ((t :background "#121212" :foreground "#6272a4"))))

  ;; Ensure your custom context menu and logic remain intact
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

;; 1. THE SPLIT FIX: Stop C-w s and C-w v from cloning the buffer
;; When splitting, automatically switch the new window to the LAST used buffer
(with-eval-after-load 'evil
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

  ;; Override the default Evil split bindings
  (define-key evil-window-map (kbd "s") 'my/evil-split-unique)
  (define-key evil-window-map (kbd "v") 'my/evil-vsplit-unique)
  (define-key evil-normal-state-map (kbd "C-w s") 'my/evil-split-unique)
  (define-key evil-normal-state-map (kbd "C-w v") 'my/evil-vsplit-unique))


;; 2. THE NAVIGATION FIX: Stop tabs/buffers from opening twice
;; If you click a tab or search a buffer that is already visible in another window,
;; force Emacs to jump your cursor to that window instead of duplicating it here.
(defun my/jump-to-visible-buffer (orig-fn buffer-or-name &rest args)
  (let ((window (get-buffer-window buffer-or-name 0)))
    (if window
        (select-window window) ;; Jump to the existing window
      (apply orig-fn buffer-or-name args)))) ;; Otherwise, open it normally

(advice-add 'switch-to-buffer :around #'my/jump-to-visible-buffer)

;; Enable visible, draggable dividers between windows
(use-package frame
  :ensure nil
  :config
  (setq window-divider-default-bottom-width 2)
  (setq window-divider-default-right-width 4)
  (setq window-divider-default-places 't) ; dividers on both bottom and right
  (window-divider-mode 1))

;; Optional: Make the mouse follow your focus
;; This makes the window active as soon as the mouse hovers over it
(setq mouse-autoselect-window t)

;; Ensure the mouse works even in the fringe (the space where line numbers live)
(setq-default indicate-empty-lines t)
(setq fringe-indicator-alist '((truncation . nil) (continuation . nil)))

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

(use-package imenu-list
  :ensure t
  :after general
  :config
  (setq imenu-list-position 'right)
  (setq imenu-list-size 30)
  (my/leader-keys "o" '(imenu-list-smart-toggle :which-key "outline")))
  (use-package project
  :ensure nil
  :config
  ;; Priority 1: Look for Elixir or C++ project markers
  ;; Priority 2: Fall back to Git
  (setq project-vc-extra-root-markers '("mix.exs" "CMakeLists.txt" ".project"))
  
  ;; Custom logic to ensure we always stop at the mix.exs folder
  (defun my/project-find-root (dir)
    (let ((root (or (locate-dominating-file dir "mix.exs")
                    (locate-dominating-file dir ".project"))))
      (when root
        (cons 'transient root))))

  ;; Push our custom finder to the top of the list
  (setq project-find-functions (list #'my/project-find-root #'project-try-vc)))

(use-package treemacs
  :ensure t
  :defer t
  :config
  ;; 1. THE FIX: Allow the window to be resized by the mouse/commands
  (setq treemacs-lock-width nil)
  
  ;; 2. Increase default width so long names aren't immediately cut off
  (setq treemacs-width 35)
  
  ;; 3. Optional: Make Treemacs "follow" your file
  (treemacs-follow-mode t)
  
  ;; 4. Optional: Enable file-watch (updates when files change on disk)
  (treemacs-filewatch-mode t))

(use-package treemacs-evil
  :ensure t
  :after (treemacs evil))

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

;; strictly for mechanical auto-closing, completely ignoring syntax parsing
(use-package web-mode
  :ensure t
  :mode ("\\.heex\\'" . web-mode)
  :init
  ;; 1. Set the defaults BEFORE the mode ever loads
  (setq-default web-mode-enable-auto-closing t)
  (setq-default web-mode-enable-auto-pairing t)
  (setq-default web-mode-enable-auto-quoting t)
  (setq-default web-mode-markup-indent-offset 2)
  :config
  ;; 2. THE MISSING LINK: Force web-mode to treat .heex files as HTML
  ;; Without this, the tag auto-closer stays turned off.
  (add-to-list 'web-mode-content-types-alist '("html" . "\\.heex\\'")))

(use-package emmet-mode
  :ensure t
  :hook ((web-mode . emmet-mode)
         (html-mode . emmet-mode))
  :config
  ;; Force Emmet to recognize .heex files as HTML
  (add-to-list 'emmet-jsx-major-modes 'web-mode)

;; The Dynamic HEEx Interceptor (Fixed Word Boundary)
  (defun my/heex-tab-handler ()
    "Intercept TAB to dynamically expand *-if and *-for tags, fallback to Emmet."
    (interactive)
    ;; Added \\b to force it to grab the entire word (div) instead of just the last letter (v)
    (if (looking-back "\\b\\([[:alnum:]_.]+\\)-\\(if\\|for\\)" (line-beginning-position))
        (let ((tag (match-string 1))
              (attr (match-string 2)))
          ;; 1. Delete the shorthand (e.g., div-if)
          (delete-region (match-beginning 0) (match-end 0))
          ;; 2. Build the opening HEEx tag
          (insert (format "<%s :%s={}>" tag attr))
          ;; 3. Build the closing tag without moving the cursor
          (save-excursion
            (insert (format "</%s>" tag)))
          ;; 4. Back up 2 spaces so the cursor lands perfectly inside the {}
          (backward-char 2))
      
      ;; If the word DOES NOT end in -if or -for, let Emmet do its normal job
      (call-interactively 'emmet-expand-line)))


  ;; Bind TAB to our smart interceptor instead of Emmet directly
  (define-key emmet-mode-keymap (kbd "TAB") 'my/heex-tab-handler)
  (define-key emmet-mode-keymap (kbd "<tab>") 'my/heex-tab-handler))

(use-package eglot
  :ensure nil
  :config
  ;; Tell Eglot to use the AUR binary name
  (add-to-list 'eglot-server-programs
               '(elixir-mode . ("elixir-ls")))
  
  ;; Tell ElixirLS to look at the current folder for the mix.exs
  (setq-default eglot-workspace-configuration
                '((:elixirLS . (:projectDir ".")))))

(add-hook 'elixir-mode-hook #'eglot-ensure)
(add-hook 'c++-mode-hook #'eglot-ensure)

(use-package dape
  :after general
  :ensure t
  :config
)

(use-package vterm
  :ensure t
  :config
  (setq vterm-max-scrollback 10000))

(use-package vterm-toggle
  :ensure t
  :after vterm
  :config
)

(use-package project-terminal
  :ensure (:host github :repo "cowboyd/project-terminal.el")
  :after (project vterm)
  :custom
  (project-terminal-height 0.15)
  (project-terminal-side 'bottom)
  (project-terminal-shell 'vterm))

;; 1. DISABLE THE GUI & TAGS FALLBACK GLOBALLY
(setq use-dialog-box nil)             ; Stop dialog boxes from opening
(setq xref-prompt-for-identifier nil) ; Use the word under the mouse immediately
(setq-default xref-backend-functions '(eglot--xref-backend t)) ; Force LSP over Tags

;; 2. Modeline Fix
(setq doom-modeline-lsp nil)          ; Prevent the modeline from crashing

;; 3. Enable the modern right-click editor context menu
;;
;; BUG FIX:
;; You had:
;;   (context-menu-menu-mode 1)
;;
;; That is wrong. The real Emacs mode is:
;;   context-menu-mode
;;
;; This controls right-click inside editor buffers.
(when (fboundp 'context-menu-mode)
  (context-menu-mode 1))

;; 4. Right-click inside editor buffers
;;
;; Some configs/packages/Evil states eat mouse-3 or only react to down-mouse-3.
;; This forces normal editor right-click to open the Emacs context menu.
(defun my/editor-context-menu (event)
  "Open the normal Emacs context menu in editor buffers."
  (interactive "e")
  (mouse-set-point event)
  (if (fboundp 'context-menu-open)
      (context-menu-open)
    (mouse-menu-major-mode-map event)))

(define-key global-map [mouse-3] #'my/editor-context-menu)
(define-key global-map [down-mouse-3] #'my/editor-context-menu)

(with-eval-after-load 'evil
  (define-key evil-normal-state-map [mouse-3] #'my/editor-context-menu)
  (define-key evil-normal-state-map [down-mouse-3] #'my/editor-context-menu)
  (define-key evil-insert-state-map [mouse-3] #'my/editor-context-menu)
  (define-key evil-insert-state-map [down-mouse-3] #'my/editor-context-menu)
  (define-key evil-visual-state-map [mouse-3] #'my/editor-context-menu)
  (define-key evil-visual-state-map [down-mouse-3] #'my/editor-context-menu)
  (define-key evil-motion-state-map [mouse-3] #'my/editor-context-menu)
  (define-key evil-motion-state-map [down-mouse-3] #'my/editor-context-menu))

;; 5. Mouse Bindings
(define-key global-map [C-down-mouse-1] 'ignore)
(define-key global-map [C-mouse-1] 'xref-find-definitions)
(define-key global-map [C-mouse-3] 'xref-go-back)
(define-key global-map [C-S-mouse-1] 'eglot-find-declaration)

(use-package vertico
  :ensure t
  :init (vertico-mode 1)
  :config (setq vertico-cycle t))

(use-package vertico-posframe
  :ensure t
  :after vertico
  :init (vertico-posframe-mode 1)
  :config
  (setq vertico-posframe-hide-minibuffer t
        vertico-posframe-width 110
        vertico-posframe-height 20
        vertico-posframe-poshandler #'posframe-poshandler-frame-top-right-corner))

(use-package consult
  :ensure t
  :after general
  :config
  (setq consult-preview-key 'any)
  (consult-customize
   consult-find consult-ripgrep consult-line consult-buffer
   :preview-key '(:debounce 0.1 any)))

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion)))))

(use-package marginalia
  :ensure t
  :init (marginalia-mode 1))

(defun my/reload-config ()
  (interactive)
  (let* ((conf-org (expand-file-name "config.org" user-emacs-directory))
         (conf-el  (expand-file-name "config.el" user-emacs-directory)))
    (org-babel-tangle-file conf-org conf-el "elisp")
    (load-file conf-el)
    (message "Config reloaded!")))

(global-set-key (kbd "C-c r") #'my/reload-config)

(use-package desktop
  :ensure nil
  :init (desktop-save-mode 1)
  :config
  (setq desktop-path (list user-emacs-directory)
        desktop-load-locked-desktop t))

;; --- THE MASTER KEYMAP FIX ---
;; We define ALL keys in one block to stop them from vanishing.
(with-eval-after-load 'general
  ;; 1. FIRST: Clear the 't' binding so it can become a prefix
  (general-unbind :states '(normal insert visual emacs) :keymaps 'override "SPC t")

  ;; 2. THEN: Define the full map
  (my/leader-keys
    ;; Files & Search
    "f"  '(:ignore t :which-key "files")
    "ff" '(consult-find :which-key "find file")
    "fs" '(consult-ripgrep :which-key "ripgrep search")
    
    ;; Buffers & Tabs
    "b"  '(:ignore t :which-key "buffers")
    "bb" '(consult-buffer :which-key "switch buffer")
    "bk" '(kill-current-buffer :which-key "kill buffer")
    "x"  '(kill-current-buffer :which-key "close tab")

    ;; Projects & Explorer
    "p"  '(:ignore t :which-key "project")
    "pp" '(projectile-command-map :which-key "projectile")
    "e"  '(treemacs :which-key "explorer")
    "o"  '(imenu-list-smart-toggle :which-key "outline")

    ;; TERMINAL MENU (The new layout)
    "t"  '(:ignore t :which-key "terminal")
    "tt" '(project-terminal-toggle :which-key "toggle project terminal")
    "tT" '(project-terminal-add :which-key "add project terminal")
    "tf" '(vterm :which-key "vterm standalone")
    
    ;; Debug & Help
    "d"  '(:ignore t :which-key "debug")
    "dd" '(dape :which-key "start")
    "h"  '(:ignore t :which-key "help")
    "hr" '(my/reload-config :which-key "reload config")))

;; --- SESSION PERSISTENCE ---
(use-package desktop
  :ensure nil ; Built-in
  :init
  (desktop-save-mode 1)
  :config
  ;; Automatically save when Emacs is idle
  (setq desktop-auto-save-timeout 30)
  ;; Save the desktop in the user-emacs-directory
  (setq desktop-path (list user-emacs-directory))
  (setq desktop-dirname user-emacs-directory)
  (setq desktop-base-file-name "emacs.desktop")
  
  ;; Prevent Desktop from asking "Active desktop found, use it?" every time
  (setq desktop-load-locked-desktop t)
  
  ;; Don't save some temp or utility buffers
  (setq desktop-modes-not-to-save
        '(tags-table-mode dired-mode vterm-mode help-mode magit-mode)))

;; --- RECENT FILES PERSISTENCE ---
(use-package recentf
  :ensure nil ; Built-in
  :init
  (recentf-mode 1)
  :config
  (setq recentf-max-saved-items 200
        recentf-max-menu-items 15))

;; --- MINIBUFFER HISTORY PERSISTENCE ---
(use-package savehist
  :ensure nil ; Built-in
  :init
  (savehist-mode 1))

;; --- CURSOR POSITION PERSISTENCE ---
(use-package saveplace
  :ensure nil ; Built-in
  :init
  (save-place-mode 1))
