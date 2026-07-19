#!/usr/bin/env bats
# test.bats — tests for the `nuance` POSIX CLI (bin/nuance) and, as a gate,
# the Nushell suite (test.nu). Run:  bats test.bats

setup_file() {
    export CLI="$BATS_TEST_DIRNAME/bin/nuance"
    if command -v nu >/dev/null 2>&1; then
        # make sure the autoload symlink exists so `theme`/`prompt-style` resolve
        nu "$BATS_TEST_DIRNAME/install.nu" >/dev/null 2>&1 || true
        CFG="$(nu -n -c '$nu.default-config-dir' 2>/dev/null || true)"
        export CFG
        [ -f "$CFG/current-theme.txt" ] && cp "$CFG/current-theme.txt" "$BATS_FILE_TMPDIR/theme.bak" || true
        [ -f "$CFG/prompt-style.txt" ]  && cp "$CFG/prompt-style.txt"  "$BATS_FILE_TMPDIR/style.bak" || true
    fi
}

teardown_file() {
    [ -f "$BATS_FILE_TMPDIR/theme.bak" ] && cp "$BATS_FILE_TMPDIR/theme.bak" "$CFG/current-theme.txt" || true
    [ -f "$BATS_FILE_TMPDIR/style.bak" ] && cp "$BATS_FILE_TMPDIR/style.bak" "$CFG/prompt-style.txt"  || true
}

@test "help prints usage" {
    run "$CLI" help
    [ "$status" -eq 0 ]
    [[ "$output" == *"nuance theme"* ]]
    [[ "$output" == *"update"* ]]
}

@test "no args prints usage (exit 0)" {
    run "$CLI"
    [ "$status" -eq 0 ]
    [[ "$output" == *"nuance"* ]]
}

@test "unknown subcommand exits non-zero with usage" {
    run "$CLI" frobnicate
    [ "$status" -ne 0 ]
    [[ "$output" == *"nuance"* ]]
}

@test "theme <name> sets + pins a theme" {
    command -v nu >/dev/null || skip "nushell not installed"
    run "$CLI" theme gruvbox
    [ "$status" -eq 0 ]
    [[ "$output" == *"gruvbox"* ]]
    [ "$(cat "$CFG/current-theme.txt")" = "gruvbox" ]
}

@test "theme rejects an unknown name" {
    command -v nu >/dev/null || skip "nushell not installed"
    run "$CLI" theme not-a-real-theme
    [[ "$output" == *"unknown theme"* ]]
}

@test "prompt-style <name> sets a style" {
    command -v nu >/dev/null || skip "nushell not installed"
    run "$CLI" prompt-style powerline
    [ "$status" -eq 0 ]
    [[ "$output" == *"powerline"* ]]
    [ "$(cat "$CFG/prompt-style.txt")" = "powerline" ]
}

@test "look <name> applies a preset" {
    command -v nu >/dev/null || skip "nushell not installed"
    run "$CLI" look cyberpunk
    [ "$status" -eq 0 ]
    [[ "$output" == *"cyberpunk"* ]]
}

@test "nushell suite (test.nu) passes" {
    command -v nu >/dev/null || skip "nushell not installed"
    run nu "$BATS_TEST_DIRNAME/test.nu"
    [ "$status" -eq 0 ]
    [[ "$output" == *"all checks passed"* ]]
}
