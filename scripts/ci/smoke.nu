#!/usr/bin/env nu
# ──────────────────────────────────────────────────────────────────────────────
# nuance — Smoke-test the built CLI in a throwaway HOME
# ──────────────────────────────────────────────────────────────────────────────
# Runs target/debug/nuance (build it first) with a fresh HOME: help, then set a
# theme, a prompt style and a look, and checks the look was persisted.
#
# Usage: nu scripts/ci/smoke.nu
# ──────────────────────────────────────────────────────────────────────────────

# Each check: the arguments and a word the output must contain.
export const CHECKS = [[args expect];
    [[help] "nuance theme"]
    [[theme gruvbox] gruvbox]
    [[prompt-style powerline] powerline]
    [[look cyberpunk] cyberpunk]]

# The look the config dir records as current, or null.
export def current_look [config_dir: string]: nothing -> any {
    let f = $config_dir | path join "current-theme.txt"
    if ($f | path exists) { open --raw $f | str trim } else { null }
}

def main [] {
    let bin = "target" | path join "debug" "nuance" | path expand
    # A space in the path (like "Maya Nadia Sorin VR") guards the Windows
    # `source "C:\Users\..."` regression.
    let home = mktemp -d | path join "nuance home" | tee { mkdir $in }
    let appdata = $home | path join "AppData" "Roaming" | tee { mkdir $in }
    with-env {HOME: $home, USERPROFILE: $home, APPDATA: $appdata, XDG_CONFIG_HOME: ($home | path join ".config")} {
        for c in $CHECKS {
            let out = ^$bin ...$c.args | complete
            if $out.exit_code != 0 or not ($out.stdout | str contains $c.expect) {
                print -e $"❌ nuance ($c.args | str join ' '): expected ($c.expect)\n($out.stdout)($out.stderr)"
                exit 1
            }
        }
        let cfg = ^nu -n -c '$nu.default-config-dir' | str trim
        let look = current_look $cfg
        if $look != "cyberpunk" {
            print -e $"❌ current-theme.txt in ($cfg) is ($look), expected cyberpunk"
            exit 1
        }
    }
    rm -rf $home
    print "smoke=ok"
}
