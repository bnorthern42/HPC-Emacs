;;; core-completion.el --- Completion System -*- lexical-binding: t; -*-

(use-package vertico
  :ensure t
  :init
  (vertico-mode 1)
  :config
  (setq vertico-cycle t
        vertico-resize t
        vertico-count 20))

(use-package vertico-posframe
  :ensure t
  :after vertico
  :init
  (vertico-posframe-mode 1)
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
  :init
  (marginalia-mode 1))


(use-package corfu
  :ensure t
  :custom
  (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
  (corfu-auto t)                 ;; Enable auto completion
  (corfu-separator ?\s)          ;; Orderless field separator
  (corfu-auto-delay 0.1)         ;; Delay before auto completion
  (corfu-auto-prefix 2)          ;; Minimum prefix for auto completion
  (corfu-quit-at-boundary nil)   ;; Never quit at completion boundary
  (corfu-quit-no-match nil)      ;; Never quit, even if there is no match
  (corfu-preview-current nil)    ;; Disable current candidate preview
  (corfu-preselect 'prompt)      ;; Preselect the prompt
  (corfu-on-exact-match nil)     ;; Configure handling of exact matches
  :init
  (global-corfu-mode 1))

(use-package cape
  :ensure t
  :init
  ;; Add useful defaults: `file` and `dabbrev` and `dict` and `elisp-block`
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-elisp-block)
  ;; Add `dict` or `keyword` here if desired, but we'll stick to a fast subset.
  )

;; Disable overlapping completion providers (company-mode)
;; Ensure we do not load company-mode to avoid conflicting with Corfu
(with-eval-after-load 'company
  (company-mode -1)
  (global-company-mode -1))

;; Use Corfu for completion in region (e.g., M-TAB)
(setq completion-in-region-function
      (lambda (&rest args)
        (apply (if vertico-mode
                   #'consult-completion-in-region
                 #'completion--in-region)
               args)))

(provide 'core-completion)
;;; core-completion.el ends here
