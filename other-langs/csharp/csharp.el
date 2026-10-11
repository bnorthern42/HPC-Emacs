;;; csharp.el --- C# module for other-langs -*- lexical-binding: t; -*-

(other-lang-def csharp
  :tools ("dotnet")
  :packages (csharp-mode dotnet sharper)
  :modes (csharp-mode csharp-ts-mode)
  :config
  (progn
     (add-hook 'csharp-mode-hook #'eglot-ensure)
     (add-hook 'csharp-ts-mode-hook #'eglot-ensure)

     ;; Formatting (use eglot)
     (defun my/csharp-format-buffer ()
       (interactive)
       (eglot-format-buffer))

     ;; Dotnet build/test/run
     (defun my/dotnet-build ()
       (interactive)
       (compile "dotnet build"))

     (defun my/dotnet-test ()
       (interactive)
       (compile "dotnet test"))

     (defun my/dotnet-run ()
       (interactive)
       (compile "dotnet run"))

     ;; Entity Framework Core
     (defun my/dotnet-ef-migrations-add (name)
       (interactive "sMigration Name: ")
       (compile (format "dotnet ef migrations add %s" (shell-quote-argument name))))

     (defun my/dotnet-ef-database-update ()
       (interactive)
       (compile "dotnet ef database update"))

     ;; Dape debugging configuration
     (with-eval-after-load 'dape
       (add-to-list 'dape-configs
                    `(netcoredbg
                      modes (csharp-mode csharp-ts-mode)
                      command "netcoredbg"
                      command-args ("--interpreter=vscode")
                      :request "launch"
                      :cwd dape-cwd
                      :program (lambda ()
                                 (let* ((dlls (directory-files-recursively (project-root (project-current t)) "\\.dll$"))
                                        (options (seq-filter (lambda (f) (string-match-p "/bin/Debug/" f)) dlls)))
                                   (if options
                                       (completing-read "Select DLL to debug: " options nil t)
                                     (read-file-name "Path to dll: " (project-root (project-current t)) nil t nil "\\.dll$")))))))

     ;; Keybindings for C#
     (with-eval-after-load 'csharp-mode
       (define-key csharp-mode-map (kbd "C-c C-c") #'my/dotnet-build)
       (define-key csharp-mode-map (kbd "C-c C-t") #'my/dotnet-test)
       (define-key csharp-mode-map (kbd "C-c C-r") #'my/dotnet-run)
       (define-key csharp-mode-map (kbd "C-c C-f") #'my/csharp-format-buffer)
       (define-key csharp-mode-map (kbd "C-c e a") #'my/dotnet-ef-migrations-add)
       (define-key csharp-mode-map (kbd "C-c e u") #'my/dotnet-ef-database-update)
       (define-key csharp-mode-map (kbd "C-c s") #'sharper-main-menu))

     (with-eval-after-load 'csharp-ts-mode
       (define-key csharp-ts-mode-map (kbd "C-c C-c") #'my/dotnet-build)
       (define-key csharp-ts-mode-map (kbd "C-c C-t") #'my/dotnet-test)
       (define-key csharp-ts-mode-map (kbd "C-c C-r") #'my/dotnet-run)
       (define-key csharp-ts-mode-map (kbd "C-c C-f") #'my/csharp-format-buffer)
       (define-key csharp-ts-mode-map (kbd "C-c e a") #'my/dotnet-ef-migrations-add)
       (define-key csharp-ts-mode-map (kbd "C-c e u") #'my/dotnet-ef-database-update)
       (define-key csharp-ts-mode-map (kbd "C-c s") #'sharper-main-menu))))
