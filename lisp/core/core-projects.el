;;; core-projects.el --- Project detection unification -*- lexical-binding: t; -*-

(require 'project)

(defvar core-project-root-markers
  '("mix.exs"          ; Mix
    "CMakeLists.txt"   ; CMake
    ".project"         ; Custom generic marker
    ".git")            ; Git
  "Unified list of project root markers.")

;; Unify project.el behavior
(setq project-vc-extra-root-markers core-project-root-markers)

(defun my/project-find-root (dir)
  "Custom logic to find project root using unified markers.
Checks markers in priority order to ensure we stop at the correct inner project."
  (let ((root nil)
        (markers core-project-root-markers))
    (catch 'found
      (while markers
        (let* ((marker (car markers))
               (found (locate-dominating-file dir marker)))
          (when found
            (setq root found)
            (throw 'found t)))
        (setq markers (cdr markers))))
    (when root
      (cons 'transient root))))

;; Use custom finder
(setq project-find-functions (list #'my/project-find-root #'project-try-vc))

;; Unify Projectile behavior
(with-eval-after-load 'projectile
  ;; Add our unified markers to projectile's top-down root files
  ;; to ensure they take precedence over default detection
  (dolist (marker core-project-root-markers)
    (add-to-list 'projectile-project-root-files marker)))

(provide 'core-projects)
;;; core-projects.el ends here
