# Emacs Configuration Audit Findings

## Bugs
1. **`switch-to-buffer` return value broken:** In `config.org` under `03 Buffer and Window Behavior`, the `my/jump-to-visible-buffer` function (which advises `switch-to-buffer`) returns a window object (from `select-window`) instead of a buffer object when the buffer is already visible. This violates the API contract of `switch-to-buffer`, which will break any Elisp code that expects a buffer to be returned.
2. **`context-menu-open` arity error:** In `config.org` under `09 Language Server Mouse Navigation`, `my/editor-context-menu` calls `(context-menu-open)` without arguments. In modern Emacs, `context-menu-open` requires an EVENT argument. Clicking `mouse-3` will result in a `wrong-number-of-arguments` error.

## Redundant Packages
1. **`vterm-toggle`:** The configuration installs and loads `vterm-toggle`, but it also installs and fully configures `project-terminal` for bottom-panel terminal toggling (bound to `SPC tt`). This makes `vterm-toggle` redundant and unnecessary overhead.

## Conflicting Hooks
1. **Forced `font-lock-mode` in `elixir-mode`:** Adding `(lambda () (font-lock-mode 1))` to `elixir-mode-hook` can cause initialization conflicts. Global font-lock is already enabled by default, and forcing it locally can disrupt themes, tree-sitter integrations, or cause double-parsing during buffer load.

## Unsafe Advice
1. **Advising `switch-to-buffer`:** Using `:around` advice on `switch-to-buffer` is notoriously unsafe. Core Emacs functions and countless third-party packages call `switch-to-buffer` internally and expect exact built-in behavior. Window management logic should be handled through `display-buffer-alist` instead of advising core C primitives.

## Deprecated APIs
1. **`bidi-display-reordering` set to `nil`:** The configuration contains `(setq bidi-display-reordering nil)`. In Emacs 27.1 and newer, disabling bidi reordering is strongly discouraged. The display engine relies on it, and disabling it does not improve performance anymore; instead, it can cause text rendering corruption and unexpected display bugs.

## Performance Problems
1. **Excessive `gcmh-high-cons-threshold`:** Setting the idle GC threshold to 512MB (`(* 512 1024 1024)`) is too large. While it prevents garbage collection while typing, it means that when GC finally triggers, Emacs has to traverse half a gigabyte of memory. This will result in severe, noticeable freezes (GC spikes). A value closer to 16MB or 32MB is typically recommended.
2. **Oversized `read-process-output-max`:** Setting this to 8MB (`(* 8 1024 1024)`) is excessively large. While increasing it from the default helps LSP servers like `clangd`, a buffer size of 8MB can cause allocation latency and memory spikes. 1MB to 3MB (`1048576` to `3145728` bytes) is the sweet spot for LSP performance.
