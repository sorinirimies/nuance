# ── Color math (WCAG contrast) ────────────────────────────────
# Used to guarantee every theme's prompt is readable: text roles are nudged
# toward the theme's own foreground until they clear a contrast floor, and
# each segment background gets a per-color `ink` that passes WCAG AA (4.5).
# (Hex bytes get an explicit `0x` prefix: a bare "0b…" byte such as the "0b" in
# "#0b0221" would otherwise be read as a binary literal prefix.)
def hex-byte [s: string] { $"0x($s)" | into int | into float }
def hex-rgb [h: string] { [1 3 5] | each {|i| hex-byte ($h | str substring $i..($i + 1)) } }
def hex-from-rgb [rgb: list<float>] {
    let d = "0123456789abcdef"
    let bytes = ($rgb | each {|v|
        let n = ([([$v 0.0] | math max) 255.0] | math min | math round | into int)
        let hi = ($n // 16)
        let lo = ($n mod 16)
        $"($d | str substring $hi..$hi)($d | str substring $lo..$lo)"
    })
    $"#($bytes | str join '')"
}
# Blend `a` toward `b` by t (0.0 = a, 1.0 = b).
def hex-mix [a: string, b: string, t: float] {
    let x = (hex-rgb $a)
    let y = (hex-rgb $b)
    hex-from-rgb (0..2 | each {|i| ($x | get $i) * (1.0 - $t) + ($y | get $i) * $t })
}
def lum [h: string] {
    let c = (hex-rgb $h | each {|v|
        let x = ($v / 255.0)
        if $x <= 0.03928 { $x / 12.92 } else { (($x + 0.055) / 1.055) ** 2.4 }
    })
    0.2126 * $c.0 + 0.7152 * $c.1 + 0.0722 * $c.2
}
# WCAG contrast ratio (1.0 – 21.0).
def contrast [a: string, b: string] {
    let la = (lum $a)
    let lb = (lum $b)
    if $la > $lb { ($la + 0.05) / ($lb + 0.05) } else { ($lb + 0.05) / ($la + 0.05) }
}
# Nudge `c` toward `pole` (in 10% steps) until it reaches `min` contrast on `bg`.
def fit-contrast [c: string, bg: string, min: float, pole: string] {
    if (contrast $c $bg) >= $min { return $c }
    for i in 1..10 {
        let cand = (hex-mix $c $pole (($i | into float) / 10.0))
        if (contrast $cand $bg) >= $min { return $cand }
    }
    $pole
}
# Best text color to print on a segment background: the theme's `ink` when it
# is already AA-readable, else the nearest readable shade of ink (or of the
# theme fg when ink sits on the wrong side of the background).
def ink-on [ink: string, fg: string, bg: string] {
    if (contrast $ink $bg) >= 4.5 { return $ink }
    let pole = (if (contrast "#000000" $bg) >= (contrast "#ffffff" $bg) { "#000000" } else { "#ffffff" })
    let wrong_side = (if $pole == "#000000" { (lum $ink) > (lum $bg) } else { (lum $ink) < (lum $bg) })
    fit-contrast (if $wrong_side { $fg } else { $ink }) $bg 4.5 $pole
}

# Colors used as text on the terminal background vs as segment backgrounds.
def palette-text-roles [] { [user host path git ok err modified added deleted ahead behind stash conflict duration] }
def palette-muted-roles [] { [sep time untracked] }
def palette-seg-roles [] { [user host path git ok err modified ahead] }

# Add the derived keys every theme exposes and enforce readability:
#   bg fg surface light   + `inks` (a readable text color per segment role)
def finish-palette [p: record] {
    let bg = $p.bg
    let fg = $p.fg
    mut out = $p
    for r in (palette-text-roles) { $out = ($out | upsert $r (fit-contrast ($p | get $r) $bg 3.0 $fg)) }
    for r in (palette-muted-roles) { $out = ($out | upsert $r (fit-contrast ($p | get $r) $bg 2.4 $fg)) }
    let fixed = $out
    let inks = (palette-seg-roles | reduce --fold {} {|r, acc| $acc | insert $r (ink-on $p.ink $fg ($fixed | get $r)) })
    $fixed | insert surface (hex-mix $bg $fg 0.1) | insert light ((lum $bg) > 0.4) | insert inks $inks
}

# Public: { color_config, palette } for a theme name.
def theme-get [name: string] {
    let t = (theme-get-raw $name)
    { color_config: $t.color_config, palette: (finish-palette $t.palette) }
}

# ── Tab completion ───────────────────────────────────────────
def "nu-complete nuance themes" [] { theme-list }
def "nu-complete nuance styles" [] { prompt-styles }
def "nu-complete nuance looks" [] { presets | get name }
def "nu-complete nuance modules" [] { module-names }
def "nu-complete nuance module-actions" [] { ["list" "enable" "disable" "clear"] }
def "nu-complete nuance transient" [] { ["on" "dir" "off" "toggle"] }
def "nu-complete nuance kinds" [] { ["themes" "styles" "looks" "modules"] }
def "nu-complete nuance random" [] { ["look" "theme" "style"] }
def "nu-complete nuance integration" [] { ["on" "off" "status"] }

# ── Public API ────────────────────────────────────────────────
def theme-list-builtin [] {
    ["gruvbox" "catppuccin-mocha" "catppuccin-macchiato" "catppuccin-frappe" "catppuccin-latte" "tokyo-night" "nord" "dracula" "rose-pine" "rose-pine-moon" "rose-pine-dawn" "everforest" "kanagawa" "onedark" "monokai" "ayu-dark" "ayu-mirage" "night-owl" "github-dark" "github-light" "oxocarbon" "zenburn" "solarized" "solarized-light" "super-mario" "cyberpunk"]
}

