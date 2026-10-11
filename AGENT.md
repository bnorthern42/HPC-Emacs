# Agent Instructions and Skills

## Repository Guidelines
- **Literate Configuration:** This repository uses a literate Emacs configuration via Org mode. The main configuration is split into `core.org`, `ide.org`, and `lang.org`.
- **Do not edit `.el` files directly:** Always edit `.org` files. The `init.el` or Emacs itself handles tangling `.org` files into `.el` files.
- **Exclusive File Ownership:** To support concurrent Jules agents, each component file (`core.org`, `ide.org`, `lang.org`) should only be modified by the agent assigned to that domain. Ensure stable interfaces between the components.

## Core Skills & Knowledge

### 1. GNU Emacs (from GNU Emacs Documentation)
- Understanding of core Emacs concepts: buffers, windows, frames, and the kill ring.
- Familiarity with major and minor modes, hook functions (`add-hook`), and local vs global variables.
- Knowledge of Emacs initialization sequence and package management.
- Ability to consult and interpret GNU Emacs manual documentation for configuration and troubleshooting.

### 2. Emacs Lisp (Elisp)
- Proficiency in writing and debugging Emacs Lisp code.
- Understanding of Elisp data structures (lists, alists, plists, vectors, symbols).
- Familiarity with common macros and functions (`defun`, `setq`, `let`, `lambda`, `interactive`).
- Experience with configuration macros like `use-package` and modern package managers like `elpaca`.
- Ability to define custom commands, advise existing functions (`advice-add`), and modify key bindings (`define-key`, `keymap-set`).

### 3. Org Mode & Org Files
- Understanding of Org mode syntax: document structure, headings, properties, and metadata.
- **Literate Programming (Org Babel):** Proficiency with source code blocks (`#+begin_src` / `#+end_src`), header arguments (e.g., `:tangle`, `:lexical`), and noweb references.
- Experience with tangling operations (`org-babel-tangle`) to extract source code from Org documents into executable files.
- Knowledge of structuring clear, self-documenting, and reproducible configurations.
