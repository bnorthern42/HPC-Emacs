;;; early-init.el --- Early Init for HPC Emacs -*- lexical-binding: t; -*-

;; Disable package.el in favor of Elpaca.
;; This must be done here, before Emacs initializes its package system.
(setq package-enable-at-startup nil)