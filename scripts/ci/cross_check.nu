#!/usr/bin/env nu
# ──────────────────────────────────────────────────────────────────────────────
# nuance — Clippy for every OS from one host
# ──────────────────────────────────────────────────────────────────────────────
# Runs clippy for the Windows, macOS and Linux targets, so `#[cfg(windows)]` and
# `#[cfg(unix)]` code is type-checked even where only Linux runners exist (Gitea).
# Checking needs no linker or SDK: nuance has no C build dependencies.
#
# Usage: nu scripts/ci/cross_check.nu
# ──────────────────────────────────────────────────────────────────────────────

export const TARGETS = [x86_64-pc-windows-gnu aarch64-apple-darwin x86_64-unknown-linux-gnu]

# The commands for `targets`: add each std, then clippy each with warnings as errors.
export def commands [targets: list<string>]: nothing -> list<list<string>> {
    if ($targets | is-empty) { return [] }
    [
        [rustup target add ...$targets]
        ...($targets | each {|t| [cargo clippy --locked --all-targets --target $t -- -D warnings] })
    ]
}

def main [] {
    for c in (commands $TARGETS) {
        print $"▶ ($c | str join ' ')"
        run-external $c.0 ...($c | skip 1)
    }
    print "cross-check=ok"
}
