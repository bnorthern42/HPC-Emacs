;;; ide-build.el --- Project-aware asynchronous build runner -*- lexical-binding: t; -*-

(require 'project)
(require 'compile)

(defun ide-build--detect-command (dir)
  "Detect the appropriate build command for the project in DIR."
  (let ((default-directory dir))
    (cond
     ((file-exists-p "mix.exs") "mix compile")
     ((file-exists-p "Cargo.toml") "cargo build")
     ((file-exists-p "go.mod") "go build")
     ((file-exists-p "pom.xml")
      (if (file-exists-p "mvnw") "./mvnw compile" "mvn compile"))
     ((or (file-exists-p "build.gradle") (file-exists-p "build.gradle.kts"))
      (if (file-exists-p "gradlew") "./gradlew build" "gradle build"))
     ((directory-files dir nil "\\.\\(sln\\|csproj\\|fsproj\\)\\'")
      "dotnet build")
     ((file-exists-p "CMakeLists.txt") "cmake --build build")
     ((file-exists-p "build.ninja") "ninja")
     ((or (file-exists-p "Makefile") (file-exists-p "GNUmakefile")) "make")
     (t nil))))

;;;###autoload
(defun ide-build-project ()
  "Compile the current project asynchronously using the detected build system.
If no project is found, defaults to `default-directory`."
  (interactive)
  (let* ((proj (project-current nil))
         (root-dir (if proj (project-root proj) default-directory))
         (cmd (ide-build--detect-command root-dir)))
    (if cmd
        (let ((default-directory root-dir))
          (compile cmd))
      (error "No supported build system detected in %s" root-dir))))

;; Modify only this file to add our own keybindings so we don't touch core.org/ide.org.
(with-eval-after-load 'general
  (when (fboundp 'my/leader-keys)
    (my/leader-keys
      "c"  '(:ignore t :which-key "compile")
      "cc" '(ide-build-project :which-key "build project"))))

(provide 'ide-build)
;;; ide-build.el ends here
