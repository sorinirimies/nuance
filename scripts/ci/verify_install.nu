#!/usr/bin/env nu
# ──────────────────────────────────────────────────────────────────────────────
# nuance — Install the prompt and check it landed in Nushell's autoload dir
# ──────────────────────────────────────────────────────────────────────────────
# Usage: nu scripts/ci/verify_install.nu
# ──────────────────────────────────────────────────────────────────────────────

# Where install.nu puts the prompt for an autoload dir.
export def prompt_path [autoload_dir: string]: nothing -> string {
    $autoload_dir | path join "nushell-prompt.nu"
}

def main [] {
    ^nu scripts/install.nu
    let dest = prompt_path ($nu.user-autoload-dirs | get 0)
    if not ($dest | path exists) {
        print -e $"❌ ($dest) missing after install"
        exit 1
    }
    print $"installed=($dest)"
}
