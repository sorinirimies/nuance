# ── Color fallback ───────────────────────────────────────────
# Themes are truecolor (#rrggbb). On terminals that can't show that, the final
# prompt string is rewritten: 24-bit SGR codes become the nearest 256- or
# 16-color ones, and NO_COLOR strips color entirely.
# Force a mode with $env.NUANCE_COLORS = truecolor | 256 | 16 | none.
def color-mode [] {
    if (($env.NO_COLOR? | default "") | is-not-empty) { return "none" }
    let o = ($env.NUANCE_COLORS? | default "auto")
    if $o in ["truecolor" "256" "16" "none"] { return $o }
    if (($env.COLORTERM? | default "") in ["truecolor" "24bit"]) { return "truecolor" }
    if (($env.TERM? | default "") | str contains "256") { "256" } else { "16" }
}
def rgb-256 [r: int, g: int, b: int] {
    if (($r - $g | math abs) < 10) and (($g - $b | math abs) < 10) {
        let a = (($r + $g + $b) / 3)
        if $a < 8 { return 16 }
        if $a > 248 { return 231 }
        return (232 + ([((($a - 8) * 24 / 247) | math round | into int) 23] | math min))
    }
    let lv = {|v| ($v * 5.0 / 255.0) | math round | into int }
    16 + 36 * (do $lv $r) + 6 * (do $lv $g) + (do $lv $b)
}
# Index (0-15) of the nearest basic ANSI color.
def rgb-16 [r: int, g: int, b: int] {
    let pal = [[0 0 0] [205 0 0] [0 205 0] [205 205 0] [0 0 238] [205 0 205] [0 205 205] [229 229 229] [127 127 127] [255 0 0] [0 255 0] [255 255 0] [92 92 255] [255 0 255] [0 255 255] [255 255 255]]
    $pal | enumerate | each {|e|
        let c = $e.item
        { i: $e.index, d: ((($c.0 - $r) ** 2) + (($c.1 - $g) ** 2) + (($c.2 - $b) ** 2)) }
    } | sort-by d | first | get i
}
# Rewrite the parameters of one SGR sequence (the part between ESC[ and m).
def convert-sgr [params: string, mode: string] {
    let t = ($params | split row ";")
    let n = ($t | length)
    mut out = []
    mut i = 0
    while $i < $n {
        let tok = ($t | get $i)
        if ($tok in ["38" "48"]) and (($t | get -o ($i + 1)) == "2") and (($i + 4) < $n) {
            let r = ($t | get ($i + 2) | into int)
            let g = ($t | get ($i + 3) | into int)
            let b = ($t | get ($i + 4) | into int)
            if $mode == "256" {
                $out = ($out | append [$tok "5" (rgb-256 $r $g $b | into string)])
            } else {
                let c = (rgb-16 $r $g $b)
                let fg = ($tok == "38")
                let code = (if $c < 8 { (if $fg { 30 } else { 40 }) + $c } else { (if $fg { 90 } else { 100 }) + $c - 8 })
                $out = ($out | append ($code | into string))
            }
            $i = $i + 5
        } else {
            $out = ($out | append $tok)
            $i = $i + 1
        }
    }
    $out | str join ";"
}
def downgrade-ansi [s: string, mode: string] {
    if $mode == "truecolor" { return $s }
    if $mode == "none" { return ($s | ansi strip) }
    let esc = (char --unicode "1b")
    let parts = ($s | split row $"($esc)[")
    let rest = ($parts | skip 1 | each {|chunk|
        let i = ($chunk | str index-of "m")
        if $i < 0 { $"($esc)[($chunk)" } else {
            let params = (if $i == 0 { "" } else { $chunk | str substring 0..<$i })
            let text = ($chunk | str substring ($i + 1)..)
            if ($params | str contains "38;2;") or ($params | str contains "48;2;") {
                $"($esc)[(convert-sgr $params $mode)m($text)"
            } else { $"($esc)[($chunk)" }
        }
    })
    ($parts | first) + ($rest | str join "")
}
def finalize [s: string] {
    let m = (color-mode)
    if $m == "truecolor" { $s } else { downgrade-ansi $s $m }
}

# ── Safety net ───────────────────────────────────────────────
# A prompt must never break your shell. Every renderer runs inside safe-run:
# on any error it logs the message (shown by `nuance doctor`) and falls back to
# a plain prompt.
def log-prompt-error [what: string, msg: string] {
    try {
        let dir = (nuance-cache-dir)
        mkdir $dir
        $"($what): ($msg)" | save -f ($dir | path join "last-error.txt")
    }
}
def safe-run [what: string, body: closure, fallback: closure] {
    try { do $body } catch {|e|
        log-prompt-error $what ($e.msg? | default "unknown error")
        do $fallback
    }
}

# ── Per-directory overrides (.nuance) ────────────────────────
# A `.nuance` TOML file in a directory (or any parent) re-themes the prompt
# while you are inside it — e.g. a red theme for prod checkouts:
#     theme = "gruvbox"
#     style = "powerline"
# Only theme/style *names* are read (validated against the known lists), so a
# `.nuance` file in a cloned repo can change colors but never run anything.
# Create/clear one with `nuance here <theme> [style]` / `nuance here clear`.
def dir-config-find [start?: string] {
    mut dir = ($start | default $env.PWD)
    for _ in 0..8 {
        let f = ($dir | path join ".nuance")
        if (($f | path exists) and (($f | path type) == "file")) { return $f }
        let up = ($dir | path dirname)
        if $up == $dir { break }
        $dir = $up
    }
    null
}

# Env overrides ({ THEME_PALETTE, THEME_NAME, PROMPT_STYLE }) or null.
def dir-override [] {
    let f = (dir-config-find)
    if $f == null { return null }
    let cfg = (try { open --raw $f | from toml } catch { null })
    if $cfg == null { return null }
    mut e = {}
    let t = ($cfg.theme? | default "")
    if ($t | describe) == "string" and $t in (theme-list) {
        $e = ($e | insert THEME_PALETTE (theme-get $t).palette | insert THEME_NAME $t)
    }
    let st = ($cfg.style? | default "")
    if ($st | describe) == "string" and $st in (prompt-styles) { $e = ($e | insert PROMPT_STYLE $st) }
    let gm = ($cfg.git? | default "")
    if ($gm | describe) == "string" and $gm in ["off" "light" "full"] { $e = ($e | insert PROMPT_GIT $gm) }
    if ($e | is-empty) { null } else { $e }
}

def with-local [body: closure] {
    let o = (dir-override)
    if $o == null { do $body } else { with-env $o { do $body } }
}

def create_left_prompt [] {
    finalize (safe-run "left prompt" { with-local { left-prompt-core } } { $"(($env.PWD | str replace $nu.home-dir '~')) " })
}
def create_right_prompt [] {
    finalize (safe-run "right prompt" { with-local { right-prompt-core } } { "" })
}
def prompt-indicator [] {
    finalize (safe-run "indicator" { with-local { indicator-core } } { "❯ " })
}

# ── Terminal integration ─────────────────────────────────────
# Nushell can emit terminal-integration sequences (window title, working
# directory, clickable paths, semantic prompt marks for jump-to-prompt / copy
# last output). They are on by default; `nuance integration off` disables all.
def integration-state-path [] { (nuance-config-dir) | path join "integration.txt" }
def --env integration-apply [mode: string] {
    let on = ($mode != "off")
    $env.config.shell_integration.osc2 = $on
    $env.config.shell_integration.osc7 = $on
    $env.config.shell_integration.osc8 = $on
    $env.config.shell_integration.osc133 = $on
    $env.config.shell_integration.osc633 = $on
    $env.NUANCE_INTEGRATION = (if $on { "on" } else { "off" })
}
integration-apply (try { open (integration-state-path) | str trim } catch { "on" })

# ── Transient prompt ─────────────────────────────────────────
# Once you press Enter, the finished prompt collapses to a single colored
# glyph so scrollback stays clean (powerlevel10k / starship "transient").
# Uses Nushell's TRANSIENT_PROMPT_* variables. Toggle: `nuance transient`.
def transient-state-path [] { (nuance-config-dir) | path join "transient.txt" }
# Mirror a style's indicator glyph for Vi normal mode (❯ → ❮).
def vi-glyph [g: string] {
    let m = { "❯": "❮", "▶": "◀", "»": "«", ">": "<", "▸": "◂", "❧": "☙", "▮▮": "▮▮", "▶▶▶": "◀◀◀" }
    $m | get -o $g | default "❮"
}
def vi-normal [] {
    let p = $env.THEME_PALETTE
    let g = (style-def ($env.PROMPT_STYLE? | default "full")).glyph
    $"(ansi {fg: $p.err attr: b})(vi-glyph (if ($g | is-empty) { '❯' } else { $g })) (ansi reset)"
}
# Collapsed prompt: the style's glyph, colored by the last exit status. In
# `dir` mode the directory name stays in front of it.
def transient-left [] {
    let p = $env.THEME_PALETTE
    let g = (style-def ($env.PROMPT_STYLE? | default "full")).glyph
    let glyph = if ($g | is-empty) { "❯" } else { $g }
    let c = (if (($env.LAST_EXIT_CODE? | default 0) == 0) { $p.ok } else { $p.err })
    let dir = (if ($env.NUANCE_TRANSIENT? | default "on") == "dir" { $"(ansi {fg: $p.path})($env.PWD | path basename)(ansi reset) " } else { "" })
    $"($dir)(ansi {fg: $c attr: b})($glyph) (ansi reset)"
}
def --env transient-apply [mode: string] {
    if $mode in ["on" "dir"] {
        $env.TRANSIENT_PROMPT_COMMAND = { || finalize (safe-run "transient prompt" { with-local { transient-left } } { "❯ " }) }
        $env.TRANSIENT_PROMPT_INDICATOR = { || "" }
        $env.TRANSIENT_PROMPT_INDICATOR_VI_INSERT = { || "" }
        $env.TRANSIENT_PROMPT_COMMAND_RIGHT = { || "" }
        $env.NUANCE_TRANSIENT = $mode
    } else {
        hide-env --ignore-errors TRANSIENT_PROMPT_COMMAND TRANSIENT_PROMPT_INDICATOR TRANSIENT_PROMPT_INDICATOR_VI_INSERT TRANSIENT_PROMPT_COMMAND_RIGHT
        $env.NUANCE_TRANSIENT = "off"
    }
}

$env.NUANCE_MODULES = (try { open (modules-state-path) | lines | each { str trim } | where {|l| $l in (module-names) } } catch { [] })
transient-apply (try { open (transient-state-path) | str trim } catch { "off" })

$env.PROMPT_COMMAND = { || create_left_prompt }
$env.PROMPT_COMMAND_RIGHT = { || create_right_prompt }
$env.PROMPT_INDICATOR = { || prompt-indicator }
$env.PROMPT_INDICATOR_VI_INSERT = { || prompt-indicator }
$env.PROMPT_INDICATOR_VI_NORMAL = { || finalize (safe-run "vi indicator" { with-local { vi-normal } } { "❮ " }) }
$env.PROMPT_MULTILINE_INDICATOR = { || finalize $"(ansi {fg: $env.THEME_PALETTE.sep}):::(ansi reset) " }
