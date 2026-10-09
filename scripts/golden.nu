#!/usr/bin/env nu
# Golden-file snapshots of rendered prompts (raw ANSI, escaped), so a visual
# regression in any theme or style fails the tests instead of being spotted by eye.
#
#   nu scripts/golden.nu --update   # rewrite tests/golden/prompts.txt (review the git diff!)
#   nu scripts/golden.nu --check    # exit 1 and list the rows that changed
source ../nushell-prompt.nu

def render-all [] {
    let esc = (char --unicode "1b")
    let dirty = { present: true, head: "main", state: "", ahead: 1, behind: 0, staged: 1, modified: 2, untracked: 3, conflict: 0, stash: 1, clean: false }
    let clean = { present: true, head: "main", state: "", ahead: 0, behind: 0, staged: 0, modified: 0, untracked: 0, conflict: 0, stash: 0, clean: true }
    let empty = (mktemp -d)
    $env.NUANCE_THEMES_DIR = $empty
    $env.NUANCE_STYLES_DIR = $empty
    let base = {
        NUANCE_DIR: "~/Projects/nuance", NUANCE_DATE: "Fri 9", NUANCE_COLUMNS: "80", NUANCE_COLORS: "truecolor", NO_COLOR: ""
        PROMPT_USER: "sorin", PROMPT_HOST: "nuance", PROMPT_NERD: true, PROMPT_GIT: "full", PROMPT_DIR_MAX: "0"
        NUANCE_FAKE_MODULES: { lang: "rust 1.99.0", status: "-", jobs: "-", ssh: "-", root: "-", venv: "-", nix: "-", k8s: "-", docker: "-", cloud: "-", pkg: "-", battery: "-" }
    }
    let pals = (theme-list | each {|t| { name: $t, pal: (theme-get $t).palette } } | reduce --fold {} {|r, acc| $acc | insert $r.name $r.pal })
    let one = {|theme: string, style: string, git: record, label: string, code: int|
        let pal = ($pals | get $theme)
        let env_set = ($base | merge { THEME_PALETTE: $pal, THEME_NAME: $theme, PROMPT_STYLE: $style, NUANCE_GIT: $git, LAST_EXIT_CODE: $code, NUANCE_MODULES: [] })
        let left = (with-env $env_set { create_left_prompt })
        let ind = (with-env $env_set { prompt-indicator })
        let body = ($"($left)|($ind)" | str replace --all $esc '\e' | str replace --all (char nl) '\n')
        $"($theme) / ($style) / ($label)\n($body)\n"
    }
    mut out = []
    # every style on four representative themes (dark, light, vivid, soft)
    for t in ["gruvbox" "catppuccin-latte" "dracula" "tokyo-night"] {
        for s in (prompt-styles) { $out = ($out | append (do $one $t $s $dirty "dirty" 0)) }
    }
    # clean tree + failed command for every style on one theme
    for s in (prompt-styles) {
        $out = ($out | append (do $one "nord" $s $clean "clean" 0))
        $out = ($out | append (do $one "nord" $s $dirty "failed" 1))
    }
    # every theme on two styles
    for t in (theme-list) {
        for s in ["powerline" "full"] { $out = ($out | append (do $one $t $s $dirty "dirty" 0)) }
    }
    $out | str join "\n"
}

def main [--update, --check] {
    let target = ($env.FILE_PWD | path dirname | path join "tests" "golden" "prompts.txt")
    let out = (render-all)
    if $update {
        mkdir ($target | path dirname)
        $out | save -f $target
        print $"✓ wrote ($target) — ($out | lines | length) lines"
        return
    }
    let cur = (try { open --raw $target } catch { "" })
    if $cur == $out { return }
    let a = ($cur | split row "\n\n")
    let b = ($out | split row "\n\n")
    let changed = ($b | enumerate | where {|r| ($a | get -o $r.index) != $r.item } | each {|r| $r.item | lines | first })
    print -e $"golden prompts changed in ($changed | length) row\(s) — first few:"
    $changed | first 8 | each {|c| print -e $"  ($c)" } | ignore
    print -e "if intended: nu scripts/golden.nu --update && git diff tests/golden"
    exit 1
}
