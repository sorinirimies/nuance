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
def terminal-emit [mode: string, p: record] {
    if (is-terminal --stdout) { print -n (terminal-sequences $mode $p) }
}

# Called on every theme change: re-skin the screen when the mode is on/full.
def terminal-follow [p: record] {
    let m = ($env.NUANCE_TERMINAL? | default "off")
    if $m != "off" { terminal-emit $m $p }
}

$env.NUANCE_TERMINAL = (try { open (terminal-state-path) | str trim } catch { "off" })
