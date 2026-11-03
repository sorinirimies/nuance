#!/usr/bin/env nu
# ──────────────────────────────────────────────────────────────────────────────
# nuance — Smoke-test the built CLI in a throwaway HOME
# ──────────────────────────────────────────────────────────────────────────────
# Runs target/debug/nuance (build it first) with a fresh HOME: help, then set a
# theme, a prompt style and a look, and checks the look was persisted. Skipped
# on Windows, which nuance does not support.
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
    if $nu.os-info.name == "windows" {
        print "smoke=skipped (windows)"
        return
    }
    let bin = "target" | path join "debug" "nuance" | path expand
    let home = mktemp -d
    with-env {HOME: $home, USERPROFILE: $home} {
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
