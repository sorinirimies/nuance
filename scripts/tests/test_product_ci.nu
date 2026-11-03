#!/usr/bin/env nu
# ── nuance · test_product_ci.nu ──────────────────────────────────────
# The CI helpers for the prompt and the CLI smoke test.

use std/assert
use runner.nu *
use ../ci/multiplexers.nu [install_commands]
use ../ci/verify_install.nu [prompt_path]
use ../ci/smoke.nu [CHECKS current_look]

def "test multiplexers: apt on linux, brew on macos, nothing elsewhere" [] {
    let linux = install_commands linux false
    assert equal ($linux.1 | last 2) [tmux screen]
    assert equal (install_commands macos false) [[brew install tmux]]
    assert equal (install_commands windows false) []
}

def "test verify_install: the prompt goes into the autoload dir" [] {
    assert equal (prompt_path "/a/autoload") ("/a/autoload" | path join "nushell-prompt.nu")
}

def "test smoke: every check names a subcommand and an expected word" [] {
    for c in $CHECKS {
        assert ($c.args | is-not-empty)
        assert ($c.expect | is-not-empty)
    }
    assert equal ($CHECKS | last | get expect) cyberpunk "the last check sets the look current_look reads"
}

def "test smoke: current_look reads the persisted look" [] {
    let d = mktemp -d
    assert equal (current_look $d) null
    "cyberpunk\n" | save ($d | path join "current-theme.txt")
    assert equal (current_look $d) cyberpunk
    rm -rf $d
}

def main [] { run-tests }
