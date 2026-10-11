;;; lua.el --- Lua language module -*- lexical-binding: t; -*-

(other-lang-def lua
  :tools '("lua" "lua-language-server" "luarocks" "lua-format")
  :packages '(lua-mode reformatter)
  :modes '(lua-mode)
  :init '(progn
           (setq lua-indent-level 2))
  :config '(progn
             ;; Eglot integration for Lua Language Server
             (with-eval-after-load 'eglot
               (add-to-list 'eglot-server-programs '(lua-mode . ("lua-language-server")))
               (add-hook 'lua-mode-hook #'eglot-ensure))

             ;; Formatting using lua-format via reformatter
             (with-eval-after-load 'reformatter
               (reformatter-define lua-format
                 :program "lua-format"
                 :args '("-i"))
               (add-hook 'lua-mode-hook
                         (lambda ()
                           (add-hook 'before-save-hook #'lua-format-buffer nil t))))

             ;; Project-aware execution
             (defun my/lua-run-project-or-file ()
               "Run the Lua project (main.lua in project root) or the current file if no project."
               (interactive)
               (let* ((proj (project-current))
                      (proj-root (when proj (project-root proj)))
                      (main-file (when proj-root (expand-file-name "main.lua" proj-root)))
                      (file-to-run (if (and main-file (file-exists-p main-file))
                                       main-file
                                     (buffer-file-name))))
                 (if file-to-run
                     (let ((default-directory (if proj-root proj-root default-directory)))
                       (compile (format "lua %s" (shell-quote-argument file-to-run))))
                   (message "No Lua file found to run."))))

             ;; LuaRocks integration
             (defun my/luarocks-install (package)
               "Install a Lua package using LuaRocks."
               (interactive "sLua package to install: ")
               (compile (format "luarocks install %s" (shell-quote-argument package))))

             ;; Debugging setup for dape
             (with-eval-after-load 'dape
               (add-to-list 'dape-configs
                            `(lua
                              modes (lua-mode)
                              command "local-lua-debugger-vscode"
                              :request "launch"
                              :type "lua"
                              :program dape-buffer-default)))

             ;; Keybindings
             (with-eval-after-load 'general
               (general-define-key
                :states '(normal visual)
                :keymaps 'lua-mode-map
                :prefix "SPC"
                "c r" 'my/lua-run-project-or-file
                "c p" 'my/luarocks-install))))
