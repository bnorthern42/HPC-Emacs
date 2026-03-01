# HPC Emacs – Gemini Vibe Coded Configuration

A literate, performance-focused Emacs configuration designed for modern C++ and HPC development.

This setup targets:

- Large C++/MPI/OpenMP codebases
- Clangd + LSP workflows
- Makefile and Meson-based projects
- GDB / MPI debugging
- Terminal-driven development
- Minimal UI friction with IDE ergonomics

It combines:

- Literate Org configuration
- Elpaca package manager
- Evil modal editing
- Eglot (built-in LSP)
- DAPE (Debug Adapter Protocol)
- Projectile + Treemacs
- Vertico/Consult completion stack

---

# Architecture Overview

The configuration is structured into three core files:

- `early-init.el` – Disables package.el and prepares for Elpaca
- `init.el` – Bootstraps Elpaca and loads the literate config
- `config.org` – Main literate configuration (tangles into `config.el`)

Startup flow:

1. `early-init.el` disables package.el
2. `init.el` bootstraps Elpaca
3. `config.org` is automatically tangled (if newer)
4. `config.el` is loaded

The system only re-tangles when necessary for fast startup.

---

# Performance Philosophy (HPC-Oriented)

This config is built around:

- Low GC interruption during LSP indexing
- High `read-process-output-max` for clangd
- No lockfiles (avoids Makefile conflicts)
- Fast vertical completion
- Minimal UI flicker

Performance settings include:

- 100MB GC threshold
- 1MB LSP pipe buffer
- Elpaca async package management

---

# Core Feature Set

## Visual & UI

- doom-one theme
- doom-modeline
- JetBrains Mono default font
- Relative line numbers
- Smooth scrolling (good-scroll)
- VSCode/Eclipse-style tabs (centaur-tabs)
- Right-click IDE context menus
- Treemacs project explorer
- Imenu outline panel (right side)

---

## Modal Editing

- evil-mode (Vim core)
- evil-collection integration
- general.el leader key system

Leader key: `SPC`

Examples:

- `SPC ff` – Find file
- `SPC bb` – Switch buffer
- `SPC pp` – Projectile commands
- `SPC e`  – Project explorer
- `SPC hr` – Reload configuration

---

## Project Management

Projectile:

- Detects Makefile or meson.build roots
- Prioritized build commands:
  - Makefile → `make -j $(nproc)`
  - Meson → `meson compile -C builddir`

Search paths:

- ~/projects
- ~/work

Treemacs:

- Auto-follows project
- File watch enabled
- Git integration
- Width 30 columns

---

## Modern C++ Development

LSP via Eglot (Emacs 29+ built-in)

Requires:

- clangd installed

Configured with:

```
clangd --header-insertion=never --background-index
```

Leader LSP commands:

- `SPC cla` – Code actions
- `SPC clr` – Rename
- `SPC clf` – Format buffer
- `SPC clR` – Reconnect

---

## HPC Debugging

Uses DAPE (Debug Adapter Protocol)

Designed for:

- GDB attach workflows
- MPI rank debugging
- OpenMP C++ programs

Custom attach config:

- `SPC dd` – Start debugger
- `SPC db` – Toggle breakpoint
- `SPC dn` – Next
- `SPC ds` – Step in

For MPI:

Typically attach to rank 0 PID manually.

---

## Terminal Integration

vterm + vterm-toggle

- Bottom 30% split terminal
- Persistent scrollback (10,000 lines)
- Leader toggle: `SPC t`

Shell helpers:

- Run current file
- Send line or region to terminal

Great for:

- MPI launch scripts
- Meson builds
- SLURM submission scripts
- Rapid compile/test loops

---

## Completion Stack

Modern “Vertical” completion stack:

- Vertico
- Orderless
- Marginalia
- Consult

Fast, minimal, Unix-style matching.

---

## Markdown & Documentation

- markdown-mode
- grip-mode (GitHub preview)
- `SPC mp` – Markdown preview
- `SPC mg` – Grip preview

---

# Literate Configuration Workflow

All configuration lives in `config.org`.

Reload workflow:

- `SPC hr` – Tangle + reload config
- No restart required

Manual reload function:

```
my/reload-config
```

Startup automatically re-tangles if `config.org` is newer than `config.el`.

---

# Installation

1. Place files in:

```
~/.emacs.d/
```

Files required:

- early-init.el
- init.el
- config.org

2. Start Emacs.

Elpaca will bootstrap automatically.

3. Ensure system dependencies exist:

- git
- clangd
- gdb
- vterm dependencies (libvterm)
- meson (optional)
- make

---

# Design Goals

This configuration aims to provide:

- IDE ergonomics without IDE weight
- Vim modal power with Emacs extensibility
- HPC-scale performance
- Clean project navigation
- First-class C++ development
- Modern debugging workflows
- Terminal-native development

It is designed for developers who:

- Build large C++ systems
- Use MPI/OpenMP
- Work with Make or Meson
- Want reproducible and transparent tooling
- Prefer literate configuration

---

# Why This Setup?

Compared to traditional IDEs:

- Faster startup
- Transparent configuration
- Fully scriptable
- Works locally and over SSH
- Ideal for cluster development
- No GUI lock-in

Compared to stock Emacs:

- Modern completion
- Real LSP
- Debug Adapter Protocol
- IDE-style navigation
- Tab UX
- Project tree sidebar

---

# Recommended Extensions (Optional)

For deeper HPC workflows, consider adding:

- Flycheck with clang-tidy
- Compile command caching
- SLURM helpers
- Dired async operations
- TRAMP cluster integration

---

# Summary

This is a modern HPC-grade Emacs distribution:

- Literate
- Fast
- Modal
- LSP-powered
- Debug-ready
- Terminal-native

Built for serious C++ engineering.

If you live in MPI deadlocks and template metaprogramming hell, this config is designed to stay out of your way.