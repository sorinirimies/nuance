# ── Terminal screen theming ──────────────────────────────────
# Optional: besides the prompt, recolor the whole terminal screen — background,
# foreground, cursor and (in `full` mode) the 16 ANSI colors — from the active
# theme via OSC escape sequences. Off by default. Toggle: `nuance terminal`.
#   off   leave the terminal's own colors alone (resets anything nuance set)
#   on    background + foreground + cursor
#   full  on + ANSI palette 0-15 (recolors ls, git, vim … too)
# Works in Ghostty, iTerm2, kitty, WezTerm, Alacritty, foot. Terminal.app
# ignores most of it. Reset sequences restore the terminal's own colors.
def terminal-state-path [] { ($env.NUANCE_CONFIG_DIR? | default $nu.default-config-dir) | path join "terminal.txt" }

# OSC 4 palette for `full` mode, derived from the theme's roles.
def terminal-ansi [p: record] {
    let n = [$p.surface $p.err $p.ok $p.modified $p.path $p.git $p.host $p.fg]
    let b = [$p.sep $p.err $p.ok $p.modified $p.path $p.git $p.host $p.fg]
    $n | append $b
}

# Escape sequences (a string) that apply `mode` for `palette`. Pure; no I/O.
def terminal-sequences [mode: string, p: record] {
    let esc = (char --unicode "1b")
    let bel = (char --unicode "07")
    if $mode == "off" {
        return $"($esc)]110($bel)($esc)]111($bel)($esc)]112($bel)($esc)]104($bel)"
    }
    mut s = $"($esc)]10;($p.fg)($bel)($esc)]11;($p.bg)($bel)($esc)]12;($p.fg)($bel)"
    if $mode == "full" {
        for e in (terminal-ansi $p | enumerate) {
            $s = $s + $"($esc)]4;($e.index);($e.item)($bel)"
        }
    }
    $s
}

# Emit to the terminal (only when stdout is a TTY; never into pipes/scripts).
# Zellij swallows OSC color sequences, so inside zellij on Ghostty we theme
# via Ghostty's own config instead: write an include file, make sure the main
# config includes it, and reload Ghostty (SIGUSR2). This recolors the whole
# Ghostty app (all windows), not just this pane. `off` removes the file.
# Which multiplexer (if any) sits between nu and the terminal.
def terminal-mux [] {
    if ($env.ZELLIJ? | default "" | is-not-empty) { "zellij" } else if ($env.TMUX? | default "" | is-not-empty) { "tmux" } else if ($env.STY? | default "" | is-not-empty) { "screen" } else { "" }
}

# The outer terminal is Ghostty (TERM_PROGRAM is "tmux" inside tmux, so also
# check the variables Ghostty exports to its shells).
def ghostty-host? [] {
    (($env.TERM_PROGRAM? | default "") == "ghostty") or ($env.GHOSTTY_RESOURCES_DIR? | default "" | is-not-empty) or ($env.GHOSTTY_BIN_DIR? | default "" | is-not-empty)
}

# tmux >= 3.3 forwards DCS passthrough only with allow-passthrough on; try to
# enable it for this pane. True when tmux accepted it.
def tmux-passthrough? [] {
    (^tmux set-option -p allow-passthrough on | complete).exit_code == 0
}

def ghostty-dir [] { ($env.XDG_CONFIG_HOME? | default ($nu.home-dir | path join ".config")) | path join "ghostty" }

def ghostty-reload [] {
    if ($env.NUANCE_NO_RELOAD? | default "" | is-empty) { ^pkill -USR2 -x ghostty | complete | ignore }
}

def terminal-ghostty-conf [mode: string, p: record] {
    mut lines = [$"background = ($p.bg)" $"foreground = ($p.fg)" $"cursor-color = ($p.fg)"]
    if $mode == "full" {
        for e in (terminal-ansi $p | enumerate) { $lines = ($lines | append $"palette = ($e.index)=($e.item)") }
    }
    ($lines | str join "\n") + "\n"
}

def terminal-ghostty-apply [mode: string, p: record] {
    let dir = (ghostty-dir)
    let overlay = ($dir | path join "nuance-terminal.conf")
    let main = ($dir | path join "config")
    if $mode == "off" {
        if ($overlay | path exists) { rm -f $overlay; ghostty-reload }
        return
    }
    let want = (terminal-ghostty-conf $mode $p)
    let have = (if ($overlay | path exists) { open --raw $overlay } else { "" })
    if $have == $want { return }
    mkdir $dir
    $want | save -f $overlay
    let inc = "config-file = ?nuance-terminal.conf"
    let cur = (if ($main | path exists) { open --raw $main } else { "" })
    if not ($cur | str contains $inc) { $"($cur | str trim --right)\n($inc)\n" | save -f $main }
    ghostty-reload
}

# Pure routing decision. mux: tmux|screen|zellij|"" · wide: app-wide Ghostty
# route allowed and available · tmux_pass: tmux accepted allow-passthrough.
# Returns { kind, bytes }: kind ∈ osc | dcs-tmux | dcs-screen | ghostty | none.
#   tmux    DCS passthrough to this pane (falls back to ghostty only if `wide`)
#   screen  DCS passthrough
#   zellij  no per-pane colors → ghostty only if `wide` (or `off`, to clean up)
def terminal-route [mode: string, p: record, mux: string, wide: bool, tmux_pass: bool] {
    let seq = (terminal-sequences $mode $p)
    let esc = (char --unicode "1b")
    match $mux {
        "tmux" => {
            if $tmux_pass {
                { kind: "dcs-tmux", bytes: $"($esc)Ptmux;($seq | str replace --all $esc ($esc + $esc))($esc)\\" }
            } else if $wide { { kind: "ghostty", bytes: "" } } else { { kind: "none", bytes: "" } }
        }
        "screen" => { { kind: "dcs-screen", bytes: $"($esc)P($seq)($esc)\\" } }
        "zellij" => { if $wide or $mode == "off" { { kind: "ghostty", bytes: "" } } else { { kind: "none", bytes: "" } } }
        _ => { { kind: "osc", bytes: $seq } }
    }
}

def terminal-emit [mode: string, p: record] {
    if not (is-terminal --stdout) { return }
    let mux = (terminal-mux)
    let wide = (($env.NUANCE_TERMINAL_SCOPE? | default "pane") == "all" and (ghostty-host?))
    let pass = (if $mux == "tmux" { tmux-passthrough? } else { false })
    let r = (terminal-route $mode $p $mux $wide $pass)
    if $r.kind == "ghostty" { terminal-ghostty-apply $mode $p } else if $r.bytes != "" { print -n $r.bytes }
}

# Why the screen may not recolor. Returns a hint string, or "" when none.
def terminal-mux-note [] {
    match (terminal-mux) {
        "zellij" => {
            if (($env.NUANCE_TERMINAL_SCOPE? | default "pane") == "all") and (ghostty-host?) {
                "zellij: themed via Ghostty's config (nuance-terminal.conf) + reload — this affects ALL Ghostty windows."
            } else {
                "zellij has no per-pane colors, so only the prompt is themed. To theme Ghostty anyway (all windows): nuance terminal full --all-windows"
            }
        }
        "tmux" => { "tmux: colors go via DCS passthrough to this pane (needs tmux >= 3.3; nuance enables allow-passthrough per pane)." }
        "screen" => { "GNU screen: colors forwarded via DCS passthrough; some builds ignore it." }
        _ => { "" }
    }
}

# Called on every theme change: re-skin the screen when the mode is on/full.
def terminal-follow [p: record] {
    let m = ($env.NUANCE_TERMINAL? | default "off")
    if $m != "off" { terminal-emit $m $p }
}

def terminal-scope-path [] { ($env.NUANCE_CONFIG_DIR? | default $nu.default-config-dir) | path join "terminal-scope.txt" }

# "pane" (default): only the pane nu runs in may change. "all": also allow the
# app-wide Ghostty-config route (the only option under zellij).
$env.NUANCE_TERMINAL_SCOPE = (try { open (terminal-scope-path) | str trim } catch { "pane" })
$env.NUANCE_TERMINAL = (try { open (terminal-state-path) | str trim } catch { "off" })
