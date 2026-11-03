#!/usr/bin/env nu
# ──────────────────────────────────────────────────────────────────────────────
# nuance — Install tmux and screen for the terminal-theming tests
# ──────────────────────────────────────────────────────────────────────────────
# Linux: apt-get (tmux, screen). macOS: brew (tmux). Anything else: nothing.
# A failed install is not fatal: those tests skip without a multiplexer.
#
# Usage: nu scripts/ci/multiplexers.nu
# ──────────────────────────────────────────────────────────────────────────────

use apt.nu [commands]

# The install commands for an OS (as named by $nu.os-info.name).
export def install_commands [os: string, root: bool]: nothing -> list<list<string>> {
    match $os {
        "linux" => (commands [tmux screen] $root)
        "macos" => [[brew install tmux]]
        _ => []
    }
}

def main [] {
    let root = $nu.os-info.name == "linux" and ((^id -u | str trim) == "0")
    for c in (install_commands $nu.os-info.name $root) {
        let r = do { run-external $c.0 ...($c | skip 1) } | complete
        if $r.exit_code != 0 { print -e $"warning: ($c | str join ' ') failed; the multiplexer tests will skip" }
    }
    let tmux = which tmux | is-not-empty
    print $"tmux=($tmux)"
}
