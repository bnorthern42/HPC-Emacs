💡 **What:**
Combined three separate `directory-files` calls into a single call in `lisp/ide/ide-build.el` using a unified regular expression: `"\\.\\(sln\\|csproj\\|fsproj\\)\\'"`.

🎯 **Why:**
The `ide-build--detect-command` function previously checked for `.sln`, `.csproj`, and `.fsproj` files sequentially. Since `directory-files` scans the entire directory and performs regex matching, doing this three times introduces unnecessary CPU and I/O overhead. Consolidating this into a single regex check makes the detection faster by reducing the directory scans to one.

📊 **Measured Improvement:**
Due to limitations in the current execution environment (the `emacs` executable is unavailable and blocking script execution), a direct empirical benchmark cannot be run natively. However, theoretically, this optimization eliminates 2 extraneous OS-level directory reads and string-matching loops in the worst-case scenario (when none of those files are present), leading to a measurable reduction in constant-time overhead for every invocation of the build script.
