# Run an external command and capture its result — like `^cmd | complete`, but
# a command that is not installed (e.g. `defaults` on Linux, `git` on a bare
# box) yields { exit_code: 127 } instead of raising an error.
def --wrapped ext [cmd: string, ...args: string] {
    if (which $cmd | is-empty) { return { exit_code: 127, stdout: "", stderr: $"($cmd): command not found" } }
    do -i { ^$cmd ...$args } | complete
}

# ── Style registry ───────────────────────────────────────────
# One row per prompt style = the single source of truth for: the style list,
# the indicator glyph/color, picker/gallery descriptions, and (for `blocks`
# styles) the data-driven segment renderer below. Adding a block style is
# one row; adding a hand-written layout is a row + a `match` arm in
# `create_left_prompt`.
#   kind    inline  → hand-written layout in create_left_prompt
#           blocks  → generic renderer: `shape` (arrow|slant|pill) × `segs`
#   glyph   prompt indicator (second line / before the cursor)
#   tone    palette role for the indicator when the last command succeeded
#   nerd    needs a Nerd Font for its separators
def style-defs-builtin [] {
    [
        { name: "full",         kind: "inline", ctx: true, glyph: "❯",   tone: "ok",       nerd: false, desc: "user@host in ~/path on  branch +git (default)" }
        { name: "compact",      kind: "inline", ctx: true, glyph: "❯",   tone: "ok",       nerd: false, desc: "…/last2/dirs on  branch +git" }
        { name: "minimal",      kind: "inline", ctx: true, glyph: "❯",   tone: "ok",       nerd: false, desc: "dirname on  branch" }
        { name: "lambda",       kind: "inline", ctx: true, glyph: "λ",   tone: "ok",       nerd: false, desc: "λ ~/path on  branch +git" }
        { name: "pure",         kind: "inline", glyph: "❯",   tone: "git",      nerd: false, desc: "two-line, pure-like" }
        { name: "bracket",      kind: "inline", ctx: true, glyph: "❯",   tone: "ok",       nerd: false, desc: "ASCII [user@host] [path] [git]" }
        { name: "arrow",        kind: "inline", ctx: true, glyph: "❯",   tone: "ok",       nerd: false, desc: "user » path » git" }
        { name: "robbyrussell", kind: "inline", ctx: true, glyph: "",    tone: "ok",       nerd: false, desc: "oh-my-zsh default — ➜  dir git:(branch) ✗" }
        { name: "ys",           kind: "inline", ctx: true, glyph: "$",   tone: "ok",       nerd: false, desc: "oh-my-zsh ys — # user @ host in ~/dir on ⎇ branch●" }
        { name: "avit",         kind: "inline", glyph: "➜",   tone: "ok",       nerd: false, desc: "oh-my-zsh avit — clean two-line + git:(branch)" }
        { name: "bira",         kind: "inline", glyph: "➤",   tone: "ok",       nerd: false, desc: "oh-my-zsh bira — ╭─user@host ~/dir / ╰─➤" }
        { name: "af-magic",     kind: "inline", glyph: "❯",   tone: "ok",       nerd: false, desc: "oh-my-zsh af-magic — full-width rule + info line" }
        { name: "cloud",        kind: "inline", ctx: true, glyph: "",    tone: "ok",       nerd: false, desc: "oh-my-zsh cloud — ☁  ~/dir git:(branch)" }
        { name: "powerline",    kind: "blocks", glyph: "❯",   tone: "ok",       nerd: true,  desc: "Nerd-Font segments with  separators", shape: "arrow", segs: ["path" "git"] }
        { name: "slant",        kind: "blocks", glyph: "❯",   tone: "ok",       nerd: true,  desc: "Nerd-Font slanted segment separators", shape: "slant", segs: ["path" "git"] }
        { name: "capsule",      kind: "blocks", glyph: "❯",   tone: "ok",       nerd: true,  desc: "Nerd-Font rounded pill segments", shape: "pill", segs: ["path" "git"] }
        { name: "rainbow",      kind: "blocks", glyph: "❯",   tone: "ok",       nerd: true,  desc: "Nerd-Font powerline, each segment its own color", shape: "arrow", segs: ["user" "path" "git"] }
        { name: "agnoster",     kind: "blocks", glyph: "❯",   tone: "ok",       nerd: true,  desc: "Nerd-Font powerline with user, host, path and git", shape: "arrow", segs: ["user" "host" "path" "git"] }
        { name: "skyline",      kind: "blocks", glyph: "❯",   tone: "ok",       nerd: true,  desc: "Nerd-Font slanted segments for user, path and git", shape: "slant", segs: ["user" "path" "git"] }
        { name: "pills",        kind: "blocks", glyph: "❯",   tone: "ok",       nerd: true,  desc: "Nerd-Font rounded pills for user, path and git", shape: "pill", segs: ["user" "path" "git"] }
        { name: "pastel",       kind: "blocks", glyph: "❯",   tone: "ok",       nerd: true,  desc: "Nerd-Font powerline: user, path, git + toolchain (rust/node/python/go)", shape: "arrow", segs: ["user" "path" "git" "lang"] }
        { name: "devbar",       kind: "blocks", glyph: "❯",   tone: "ok",       nerd: true,  desc: "Nerd-Font pills: exit code, ssh, path, git, toolchain, jobs", shape: "pill", segs: ["status" "ssh" "path" "git" "lang" "jobs"] }
        { name: "expedition33", kind: "inline", glyph: "❧",   tone: "modified", nerd: false, desc: "Clair Obscur: Expedition 33 — Belle Époque two-liner, gold ornaments, Gommage marks" }
        { name: "gommage",      kind: "inline", ctx: true, glyph: "✿",   tone: "git",      nerd: false, desc: "Clair Obscur — a red `✿` petal falls for every changed file (Gommage)" }
        { name: "vault",        kind: "inline", right: "none", glyph: ">",   tone: "ok",       nerd: false, desc: "Fallout Pip-Boy — `[VAULT-111] … HP 75/100 ☢`" }
        { name: "grace",        kind: "inline", right: "none", ctx: true, glyph: "❖",   tone: "modified", nerd: false, desc: "Elden Ring — HP / FP / stamina bars; YOU DIED on a failed command" }
        { name: "triforce",     kind: "inline", ctx: true, glyph: "▲",   tone: "modified", nerd: false, desc: "Zelda — `▲` Triforce, `♥♥♡` hearts, `◆` rupees" }
        { name: "doomguy",      kind: "inline", right: "none", glyph: "»",   tone: "modified", nerd: false, desc: "DOOM status bar — `HEALTH 75%  ARMOR 0  AMMO 3  ☺`" }
        { name: "spaceship",    kind: "inline", glyph: "❯",   tone: "ok",       nerd: false, desc: "spaceship — path on  branch [flags] via toolchain, two-line" }
        { name: "p10k-lean",    kind: "inline", glyph: "❯",   tone: "ok",       nerd: false, desc: "powerlevel10k lean — path + colored git state, two-line" }
        { name: "fish",         kind: "inline", ctx: true, glyph: ">",   tone: "ok",       nerd: false, desc: "fish informative — user@host ~/path (branch|✚2…1)" }
        { name: "steeef",       kind: "inline", glyph: "$",   tone: "ok",       nerd: false, desc: "oh-my-zsh steeef — user at host in ~/path [branch●]" }
        { name: "fino",         kind: "inline", glyph: "○",   tone: "ok",       nerd: false, desc: "oh-my-zsh fino — ╭─ user at host in ~/path on git:branch ✗ / ╰─○" }
        { name: "powerline2l",  kind: "blocks", nl: true, glyph: "❯", tone: "ok", nerd: true, desc: "Nerd-Font powerline segments, prompt on its own line", shape: "arrow", segs: ["user" "path" "git" "lang"] }
        { name: "pills2l",      kind: "blocks", nl: true, glyph: "❯", tone: "ok", nerd: true, desc: "Nerd-Font pills with the prompt on its own line", shape: "pill", segs: ["status" "path" "git" "lang"] }
        { name: "heist",        kind: "inline", glyph: "▶",   tone: "modified", nerd: false, desc: "angular red/black heist card — `◢ path ◣ branch ◥  ALL CLEAR / ALERT ×N`" }
        { name: "vessel",       kind: "inline", glyph: "●",   tone: "ok",       nerd: false, desc: "mask-health row `●●●○○`, ◐ soul for unpushed commits, ◈ shards for untracked files" }
        { name: "portals",      kind: "inline", glyph: "⇄",   tone: "path",     nerd: false, desc: "orange portal for the path, blue portal for the branch — `◖~/dir◗ ⇄ ◖main◗`" }
        { name: "bonfire",      kind: "inline", glyph: "♨",   tone: "host",     nerd: false, desc: "♨ lit when clean, embers ×N when dirty, FALLEN after a failed command" }
        { name: "farmstead",    kind: "inline", glyph: "⌂",   tone: "ok",       nerd: false, desc: "farm HUD — `☀ Wed 8  ⌂ ~/dir  ⚘ main ❀❀` (a crop per unpushed commit)" }
        { name: "versus",       kind: "inline", glyph: "▶",   tone: "modified", nerd: false, desc: "fighting-game health bar `1P ▰▰▰▰▰▰▱▱`, FIGHT! when clean, K.O. after a failure" }
        { name: "boons",        kind: "inline", glyph: "❦",   tone: "user",     nerd: false, desc: "dungeon-crawler boons — `✦×staged ⚔×modified ◇×untracked`" }
        { name: "climb",        kind: "inline", glyph: "»",   tone: "ahead",    nerd: false, desc: "mountain climb — `⛰ ~/dir main  »»` dashes left, ✿ berries for untracked files" }
        { name: "skillcheck",   kind: "inline", glyph: "▸",   tone: "ok",       nerd: false, desc: "RPG skill checks — `[Perception: Success]`, `[Logic: Medium 3]`, `[Volition: Failure]`" }
        { name: "hotbar",       kind: "inline", glyph: "⚒",   tone: "ok",       nerd: false, desc: "sandbox HUD — `♥♥♥♥♡ ▕▮▮▯▯▯▏ ~/dir ⚒ main`" }
        { name: "boxed",        kind: "inline", glyph: "❯",   tone: "ok",       nerd: false, desc: "two-line box-drawing with a ● clean/dirty marker" }
        { name: "mario",        kind: "inline", right: "none", glyph: "▶",   tone: "ok",       nerd: false, desc: "two-line NES HUD: `MARIO ◉×03  WORLD 3-4  ~/dir  ⚑ branch ▲▼✖⬢★`, then a brick ground with the `◆` hero" }
        { name: "arcade",       kind: "inline", glyph: "▮▮",  tone: "modified", nerd: false, desc: "retro all-caps ▶ 1UP score line" }
        { name: "8bit",         kind: "inline", glyph: "█",   tone: "modified", nerd: false, desc: "pixel ░▒▓ gradient separators" }
        { name: "cyberpunk",    kind: "inline", glyph: "▶▶▶", tone: "git",      nerd: false, desc: "two-line neon box-drawing with ⚡ and ▶▶▶" }
    ]
}
# ── User styles ──────────────────────────────────────────────
# Drop a <name>.nuon in <config>/nuance/styles (override: $env.NUANCE_STYLES_DIR)
# to define your own segment style — see `nuance style new <name>`.
def user-styles-dir [] {
    $env.NUANCE_STYLES_DIR? | default ((nuance-config-dir) | path join "nuance" "styles")
}
def style-seg-ids [] { ["user" "host" "path" "git"] ++ (module-names) }
def user-style-defs [] {
    let dir = (user-styles-dir)
    if not ($dir | path exists) { return [] }
    let taken = (style-defs-builtin | get name)
    ls $dir | where name =~ '\.nuon$' | get name | each {|f|
        let name = ($f | path parse | get stem)
        let r = (try { open $f } catch { null })
        let segs = ($r.segs? | default [])
        let ok = ($r != null) and ($name not-in $taken) and (($r.shape? | default "") in ["arrow" "slant" "pill"]) and (($segs | describe) =~ '^list') and ("path" in $segs) and ($segs | all {|x| $x in (style-seg-ids) }) and (($r.tone? | default "ok") in (palette-text-roles))
        if $ok {
            { name: $name, kind: "blocks", glyph: ($r.glyph? | default "❯"), tone: ($r.tone? | default "ok"), nerd: ($r.nerd? | default true), desc: ($r.desc? | default "custom style"), shape: $r.shape, segs: $segs, nl: ($r.nl? | default false), user: true }
        } else { null }
    } | compact
}
def style-defs [] { (style-defs-builtin) ++ (user-style-defs) }
def prompt-styles [] { style-defs | get name }
# Registry row for a style name (falls back to `full` for unknown names).
def style-def [name: string] {
    let hit = (style-defs | where name == $name)
    if ($hit | is-empty) { style-defs | first } else { $hit | first }
}

# `to json` does not escape raw control bytes (e.g. the ESC in ANSI color
# codes) — it just embeds them verbatim, which produces invalid JSON. This
# swaps ESC for a reversible plain-text marker before serializing (used by
# the Rust/ratatui frontend; not needed for Nushell's own `input list`,
# which wants the real ESC byte).
def escape-esc [s: string] { $s | str replace --all (char --unicode "1b") '\u001b' }

# Use Nerd Font glyphs (branch icon). Set to false for plain ASCII.
$env.PROMPT_NERD = true

# Load saved layout (default: full).
let saved_style = (try { open (prompt-style-path) | str trim } catch { "full" })
$env.PROMPT_STYLE = (if ($saved_style in (prompt-styles)) { $saved_style } else { "full" })

# Render one style name into a labelled preview line: "name  →  <live prompt>".
# Used to make pickers show the actual rendered prompt next to each choice.
def --env style-label [s: string] {
    let saved = $env.PROMPT_STYLE
    $env.PROMPT_STYLE = $s
    let rendered = (left-prompt-core)
    $env.PROMPT_STYLE = $saved
    let w = (prompt-styles | each { str length } | math max)
    $"($s | fill --alignment left --width $w)  →  ($rendered)"
}

# Build the labelled candidate list once, and a lookup back to plain names.
def --env style-picker-items [] {
    $env.NUANCE_GIT = (git-info)
    let items = (prompt-styles | each {|s| { label: (style-label $s), key: $s } })
    hide-env NUANCE_GIT
    $items
}

# Switch prompt layout. No arg = interactive picker (delegates to the
# `nuance` ratatui picker when available, same as every other picker here).
def --env prompt-style [name?: string@"nu-complete nuance styles"] {
    if ($name | is-empty) and (nuance-cli-available) {
        ^nuance prompt-style
        reload-style
        return
    }
    let choice = if ($name | is-empty) {
        let items = (style-picker-items)
        let pick = ($items | get label | input list --fuzzy $"prompt style  \(current: ($env.PROMPT_STYLE)\)")
        if ($pick | is-empty) { "" } else {
            ($items | where label == $pick | get 0?).key? | default ""
        }
    } else { $name }
    if ($choice | is-empty) { return }
    if ($choice not-in (prompt-styles)) {
        print $"(ansi red)unknown style:(ansi reset) ($choice)"
        print $"available: (prompt-styles | str join ', ')"
        return
    }
    $env.PROMPT_STYLE = $choice
    $choice | save -f (prompt-style-path)
    print $"(ansi green_bold)✓(ansi reset) prompt style set to (ansi attr_bold)($choice)(ansi reset)"
}

# Find the git dir by walking up from $PWD (no process spawn). Handles
# worktrees/submodules where `.git` is a file ("gitdir: <path>"). Returns the
# resolved git dir, or null outside a repository.
def git-dir-find [start?: string] {
    mut dir = ($start | default $env.PWD)
    for _ in 0..40 {
        let g = ($dir | path join ".git")
        if ($g | path exists) {
            if (($g | path type) == "dir") { return $g }
            let target = (try { open --raw $g | lines | first | str replace "gitdir:" "" | str trim } catch { "" })
            if ($target | is-empty) { return null }
            return (if (($target | str starts-with "/") or ($target =~ '^[A-Za-z]:')) { $target } else { $dir | path join $target | path expand })
        }
        let up = ($dir | path dirname)
        if $up == $dir { break }
        $dir = $up
    }
    null
}

# In-progress operation ("REBASE 2/5", "MERGING", "CHERRY-PICKING",
# "REVERTING", "BISECTING", "AM 1/3") — read from the git dir, no process.
def git-op-state [gd: string] {
    let rd = {|f| try { open --raw ($gd | path join $f) | str trim } catch { "" } }
    if ($gd | path join "rebase-merge" | path exists) {
        let n = (do $rd "rebase-merge/msgnum")
        let t = (do $rd "rebase-merge/end")
        return (if ($n | is-not-empty) and ($t | is-not-empty) { $"REBASE ($n)/($t)" } else { "REBASE" })
    }
    if ($gd | path join "rebase-apply" | path exists) {
        let n = (do $rd "rebase-apply/next")
        let t = (do $rd "rebase-apply/last")
        let kind = (if ($gd | path join "rebase-apply" "rebasing" | path exists) { "REBASE" } else { "AM" })
        return (if ($n | is-not-empty) and ($t | is-not-empty) { $"($kind) ($n)/($t)" } else { $kind })
    }
    if ($gd | path join "MERGE_HEAD" | path exists) { return "MERGING" }
    if ($gd | path join "CHERRY_PICK_HEAD" | path exists) { return "CHERRY-PICKING" }
    if ($gd | path join "REVERT_HEAD" | path exists) { return "REVERTING" }
    if ($gd | path join "BISECT_LOG" | path exists) { return "BISECTING" }
    ""
}

# ── Slow repositories ────────────────────────────────────────
# If a `git status` takes longer than 400 ms (override: $env.NUANCE_GIT_SLOW_MS),
# the repo is remembered for a day and scanned with -uno from then on, so a huge
# monorepo can't make every prompt crawl. `nuance doctor --clear-errors` forgets.
def slow-git-path [] { (nuance-cache-dir) | path join "slow-git.txt" }
def git-slow-marked [gd: string] {
    let f = (slow-git-path)
    if not ($f | path exists) { return false }
    let now = (date now | format date "%s" | into int)
    open --raw $f | lines | any {|l|
        let c = ($l | split row "\t")
        (($c | get 0) == $gd) and (($now - ($c | get 1 | into int)) < 86400)
    }
}
def git-slow-mark [gd: string] {
    try {
        mkdir (nuance-cache-dir)
        let now = (date now | format date "%s")
        $"($gd)\t($now)\n" | save --append (slow-git-path)
    }
}

# Branch name plus any in-progress operation:  main|REBASE 2/5
def git-head [g: record] {
    let st = ($g.state? | default "")
    if ($st | is-empty) { $g.head } else { $"($g.head)|($st)" }
}

# Gather git repo state as data (reused by every prompt style). One
# `git status --porcelain=v2` call does the whole job (branch, ahead/behind,
# stash count, every changed path) instead of five separate git processes.
# `--light` only resolves the branch/HEAD (cheaper: skips the status scan).
def git-info [--light] {
    # Pickers render dozens of previews in one go: they resolve git once and
    # park the record in $env.NUANCE_GIT so every preview reuses it.
    if ($env.NUANCE_GIT? | default null) != null { return $env.NUANCE_GIT }
    # $env.PROMPT_GIT = full | light | off  (also settable per tree via `.nuance`: git = "off")
    let mode = ($env.PROMPT_GIT? | default "full")
    if $mode == "off" { return { present: false } }
    let gd = (git-dir-find)
    if $gd == null { return { present: false } }
    let state = (git-op-state $gd)
    let light = ($light or ($mode == "light"))

    if $light {
        let b = (ext git symbolic-ref --short -q HEAD | get stdout | str trim)
        let head = if ($b | is-not-empty) { $b } else {
            let sha = (ext git rev-parse --short HEAD | get stdout | str trim)
            if ($sha | is-empty) { "(no commits)" } else { $"@($sha)" }
        }
        return { present: true, head: $head, state: $state, ahead: 0, behind: 0, staged: 0, modified: 0, untracked: 0, conflict: 0, stash: 0, clean: true }
    }

    # A repo whose status scan was slow recently is scanned without untracked
    # files (the expensive part) — see git-slow-mark.
    let slow = (git-slow-marked $gd)
    let base = (["status" "--porcelain=v2" "--branch"] ++ (if $slow { ["-uno"] } else { [] }))
    let t0 = (date now)
    # --show-stash needs git >= 2.35; fall back to counting the stash list.
    mut r = (ext git ...($base ++ ["--show-stash"]))
    mut stash_from_list = false
    if $r.exit_code != 0 {
        $r = (ext git ...$base)
        $stash_from_list = true
    }
    if $r.exit_code != 0 { return { present: false } }
    let took = ((date now) - $t0)
    let slow_ms = ($env.NUANCE_GIT_SLOW_MS? | default 400 | into int)
    if (not $slow) and ($took > ($slow_ms * 1ms)) { git-slow-mark $gd }

    let lines = ($r.stdout | lines)
    let hdr = {|key| $lines | where {|l| $l | str starts-with $"# ($key) " } | get 0? | default "" | str replace $"# ($key) " "" }
    let oid = (do $hdr "branch.oid")
    let bhead = (do $hdr "branch.head")
    let head = if $bhead == "(detached)" { $"@($oid | str substring 0..6)" } else if ($bhead | is-empty) { "(no commits)" } else { $bhead }
    let ab = (do $hdr "branch.ab")
    let ahead = ($ab | parse -r '\+(?<n>\d+)' | get n.0? | default "0" | into int)
    let behind = ($ab | parse -r '-(?<n>\d+)' | get n.0? | default "0" | into int)
    let stash = if $stash_from_list {
        (ext git stash list | get stdout | lines | where {|l| $l | is-not-empty } | length)
    } else {
        (do $hdr "stash" | default "0" | if ($in | is-empty) { 0 } else { $in | into int })
    }

    let entries = ($lines | where {|l| not ($l | str starts-with "#") })
    let untracked = ($entries | where {|l| $l | str starts-with "? " } | length)
    let conflict = ($entries | where {|l| $l | str starts-with "u " } | length)
    let tracked = ($entries | where {|l| ($l | str starts-with "1 ") or ($l | str starts-with "2 ") })
    let staged = ($tracked | where {|l| ($l | str substring 2..2) != "." } | length)
    let modified = ($tracked | where {|l| ($l | str substring 3..3) != "." } | length)
    let clean = (($ahead + $behind + $staged + $modified + $untracked + $conflict + $stash) == 0)
    { present: true, head: $head, state: $state, ahead: $ahead, behind: $behind, staged: $staged, modified: $modified, untracked: $untracked, conflict: $conflict, stash: $stash, clean: $clean }
}

# Plain-text branch + status summary (no color), e.g. "main ⇡2 +1 !3".
def git-plain [g: record] {
    mut t = (git-head $g)
    if $g.ahead    > 0 { $t = $t + $" ⇡($g.ahead)" }
    if $g.behind   > 0 { $t = $t + $" ⇣($g.behind)" }
    if $g.conflict > 0 { $t = $t + $" =($g.conflict)" }
    if $g.staged   > 0 { $t = $t + $" +($g.staged)" }
    if $g.modified > 0 { $t = $t + $" !($g.modified)" }
    if $g.untracked > 0 { $t = $t + $" ?($g.untracked)" }
    if $g.stash    > 0 { $t = $t + $" *($g.stash)" }
    $t
}

# oh-my-zsh style git segment:  git:(branch) ✗
def git-omz [g: record] {
    let p = $env.THEME_PALETTE
    let dirty = if $g.clean { "" } else { $" (ansi {fg: $p.err attr: b})✗(ansi reset)" }
    $"(ansi {fg: $p.git})git:\((ansi {fg: $p.behind attr: b})(git-head $g)(ansi {fg: $p.git})\)(ansi reset)($dirty)"
}

# Rich git segment: branch/commit + divergence + working-tree status.
def git-segment [--counts] {
    let p = $env.THEME_PALETTE
    let g = (if $counts { git-info } else { git-info --light })
    if not $g.present { return "" }

    let icon = if ($env.PROMPT_NERD? | default true) { " " } else { "" }
    let base = $"(ansi {fg: $p.sep})on (ansi {fg: $p.git attr: b})($icon)(git-head $g)(ansi reset)"
    if not $counts { return $" ($base)" }

    mut parts = []
    if $g.ahead    > 0 { $parts = ($parts | append $"(ansi {fg: $p.ahead})⇡($g.ahead)(ansi reset)") }
    if $g.behind   > 0 { $parts = ($parts | append $"(ansi {fg: $p.behind})⇣($g.behind)(ansi reset)") }
    if $g.conflict > 0 { $parts = ($parts | append $"(ansi {fg: $p.conflict})=($g.conflict)(ansi reset)") }
    if $g.staged   > 0 { $parts = ($parts | append $"(ansi {fg: $p.added})+($g.staged)(ansi reset)") }
    if $g.modified > 0 { $parts = ($parts | append $"(ansi {fg: $p.modified})!($g.modified)(ansi reset)") }
    if $g.untracked > 0 { $parts = ($parts | append $"(ansi {fg: $p.untracked})?($g.untracked)(ansi reset)") }
    if $g.stash    > 0 { $parts = ($parts | append $"(ansi {fg: $p.stash})*($g.stash)(ansi reset)") }
    let status_seg = if ($parts | is-empty) {
        $" (ansi {fg: $p.added})✔(ansi reset)"
    } else {
        $" ($parts | str join ' ')"
    }
    $" ($base)($status_seg)"
}

# Username / hostname that don't break the prompt in minimal environments
# (e.g. ttyd/VHS where `whoami` may fail).
def prompt-user [] {
    if (($env.PROMPT_USER? | default "") | is-not-empty) { return $env.PROMPT_USER }
    let u = ($env.USER? | default ($env.USERNAME? | default ""))
    if ($u | is-not-empty) { $u } else {
        let w = (ext whoami | get stdout | str trim)
        if ($w | is-not-empty) { $w } else { "user" }
    }
}
def prompt-host [] {
    if (($env.PROMPT_HOST? | default "") | is-not-empty) { return $env.PROMPT_HOST }
    try { sys host | get hostname } catch { ($env.HOSTNAME? | default "host") }
}

