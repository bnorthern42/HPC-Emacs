# Master HPC Emacs – C++ & Elixir Configuration

A literate, high-performance Emacs distribution engineered for demanding C++ HPC workloads and full-stack Elixir development. This setup delivers IDE-grade ergonomics while preserving the speed and transparency that power users require on large codebases, clusters, and Phoenix projects.

Targeted workflows include:
- Massive C++/MPI/OpenMP/CMake/Make codebases with clangd
- Elixir, Phoenix, and HEEx template development
- High-throughput LSP indexing and debugging
- Terminal-first build/test/debug cycles
- Reproducible, self-documenting configuration

---

## Architecture

The configuration is fully literate and consists of three core files:

- `early-init.el` – Disables `package.el`, suppresses UI noise, and prepares the environment for Elpaca.
- `init.el` – Bootstraps the Elpaca package manager and automatically tangles/reloads `config.org` when necessary.
- `config.org` – The single source of truth. All settings, packages, and custom logic are defined here and tangled to `config.el`.

Startup is deliberately lean:
1. Early GC tuning for fast boot.
2. Elpaca bootstraps asynchronously.
3. `config.org` is tangled only when newer than `config.el`.
4. Desktop, recentf, savehist, and saveplace restore your exact session.

---

## Performance Philosophy

Built from the ground up for HPC-scale responsiveness:

- Garbage collection managed by `gcmh` (512 MiB idle threshold, 64 MiB during typing).
- `read-process-output-max` increased to 8 MiB for large LSP responses.
- `native-comp` warnings silenced.
- No lockfiles (`create-lockfiles` nil) to prevent Makefile conflicts.
- Fast but precise scrolling, disabled bidi reordering, and optimized redisplay.

The result is an editor that stays invisible during heavy clangd indexing or ElixirLS analysis.

---

## Visuals & UI

- **Theme**: `base16-isotope` (sourced directly from tinted-theming).
- **Modeline**: `doom-modeline` with modal state and major-mode icons.
- **Typography**: JetBrains Mono at 120 height, relative line numbers.
- **Scrolling**: `good-scroll` (when running under a window system) + visible scroll bar.
- **Fill column**: Indicator at column 100 in programming modes.
- **Delimiters**: `rainbow-delimiters` in all `prog-mode` buffers.
- **Tabs**: `centaur-tabs` with rounded style, 32 px height, custom “x” close button styling, and a right-click context menu on the header line offering “Close other tabs”, “Close tabs to the right”, and “Close tab”.
- **Window management**: Dedicated bottom-side windows for Flymake, Flycheck, compilation, Eglot, and help buffers. Mouse automatically selects windows on hover. Visible draggable dividers.

---

## Modal Editing & Navigation

- Full `evil-mode` + `evil-collection` for consistent Vim behavior across packages.
- `general.el` leader-key system (`SPC` / `C-SPC`) with carefully ordered keymaps that survive package loading order.
- Custom split commands (`C-w s` / `C-w v`) that automatically display the most recently used buffer instead of cloning the current one.
- Smart buffer switching: clicking a tab or selecting a buffer that is already visible jumps to the existing window rather than duplicating it.
- `imenu-list` on the right side (toggle with `SPC o`).
- `treemacs` with filewatch, follow-mode, 35-column width, and resizable pane.
- `projectile` with search paths `~/projects` and `~/work`.

---

## Project & File Detection

`project.el` is customized to prioritize:
1. `mix.exs` (Elixir/Phoenix root)
2. `.project` marker
3. `CMakeLists.txt`
4. Standard Git root as fallback.

`projectile` provides fast project-wide search and commands.

---

## Elixir & HEEx Development

First-class support for modern Elixir workflows:

- `elixir-mode` with forced font-lock.
- `alchemist` integration (tests, compile, IEx, help, goto-definition) bound under `SPC cl`.
- `flycheck-credo` linting.
- `web-mode` for `.heex` files with automatic tag closing, pairing, and quoting.
- Custom `emmet-mode` extension that intelligently expands `div-if`, `div-for`, etc., into proper HEEx conditional/for constructs before falling back to standard Emmet expansion.
- Eglot automatically started for `elixir-mode`.

---

## Modern C++ Development

- Eglot (built-in LSP) enabled for `c++-mode`.
- Configured to use the system `elixir-ls` binary (AUR naming) and to respect the project root.
- Full mouse-driven navigation: `C-mouse-1` for definition, `C-mouse-3` for go-back, `C-S-mouse-1` for declaration.
- Right-click context menu fully functional in both normal and Evil states.

---

## Terminal Integration

- `vterm` with 10 000-line scrollback.
- `project-terminal` (GitHub: cowboyd/project-terminal.el) providing a clean bottom panel (15 % height) tied to the current project.
- Leader bindings: `SPC tt` (toggle), `SPC tT` (add new terminal), `SPC tf` (standalone vterm).

Perfect for MPI launch scripts, Meson builds, SLURM jobs, and rapid compile-test loops.

---

## Debugging

- `dape` (Debug Adapter Protocol) ready for GDB, MPI rank attachment, and OpenMP workflows.
- Leader prefix `SPC d` reserved for debugger commands.

---

## Completion & Search

Modern vertical completion stack:
- `vertico` + `vertico-posframe` (top-right, 110×20).
- `orderless` matching with partial-completion fallback for files.
- `consult` with live preview for find, ripgrep, line, and buffer.
- `marginalia` for rich annotations.

Leader shortcuts:
- `SPC ff` – find file
- `SPC fs` – ripgrep
- `SPC bb` – switch buffer
- `SPC bk` / `SPC x` – kill buffer/tab

---

## Session & Reliability

- Desktop session persistence with automatic idle saves.
- Recent files, minibuffer history, and cursor position restored across restarts.
- One-command reload: `SPC hr` (tangles `config.org` then loads the new `config.el`).
- All leader keys defined in a single block after `general` to prevent binding loss.

---

## Mouse & Context Menu

- Full right-click IDE-style context menu in editor buffers (works in all Evil states).
- Header-line right-click on tabs opens custom close menu.
- Dialog boxes and tag fallback disabled in favor of Eglot.

---

## Installation

1. Place the three files in `~/.emacs.d/`:
   - `early-init.el`
   - `init.el`
   - `config.org`

2. Launch Emacs. Elpaca will bootstrap itself on first run.

3. System dependencies (Arch Linux / AUR recommended):
   - `clangd`, `elixir-ls`, `gdb`
   - `libvterm` (for vterm)
   - `git`, `make`, `meson` (as needed)

No manual package installation is required.

---

## Design Goals

This configuration provides:
- Enterprise-grade C++ and Elixir tooling without IDE bloat.
- Vim muscle memory with Emacs extensibility.
- Literate, version-controlled, and instantly reloadable settings.
- Zero friction on cluster environments and SSH sessions.
- Transparent, auditable behavior suitable for HPC and production Phoenix deployments.

It is the result of deliberate engineering choices that favor speed, correctness, and maintainability over feature creep.

If your daily work involves template metaprogramming, MPI deadlocks, Phoenix LiveView, or HEEx templates, this setup is engineered to stay out of your way while giving you every modern editor advantage.