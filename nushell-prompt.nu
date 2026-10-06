# nushell-prompt.nu — nuance: themeable, git-aware Nushell prompt
# https://github.com/sorinirimies/nuance
# Single self-contained file. Drop into your Nushell autoload dir.

# ── color themes ─────────────────────────────────────────────
# (part of nushell-prompt)
#
# Exposes:
#   theme-list         -> list of available theme names
#   theme-get <name>   -> { color_config: {...}, palette: {...} }
#
# `color_config` plugs into `$env.config.color_config`.
# `palette` supplies accent colors for the custom prompt (see config.nu).

# ── Catppuccin flavor palettes ────────────────────────────────
const CAT_MOCHA = {
    rosewater: "#f5e0dc", flamingo: "#f2cdcd", pink: "#f5c2e7", mauve: "#cba6f7"
    red: "#f38ba8", maroon: "#eba0ac", peach: "#fab387", yellow: "#f9e2af"
    green: "#a6e3a1", teal: "#94e2d5", sky: "#89dceb", sapphire: "#74c7ec"
    blue: "#89b4fa", lavender: "#b4befe", text: "#cdd6f4", subtext1: "#bac2de"
    subtext0: "#a6adc8", overlay2: "#9399b2", overlay1: "#7f849c", overlay0: "#6c7086"
    surface2: "#585b70", surface1: "#45475a", surface0: "#313244"
    base: "#1e1e2e", mantle: "#181825", crust: "#11111b"
}
const CAT_MACCHIATO = {
    rosewater: "#f4dbd6", flamingo: "#f0c6c6", pink: "#f5bde6", mauve: "#c6a0f6"
    red: "#ed8796", maroon: "#ee99a0", peach: "#f5a97f", yellow: "#eed49f"
    green: "#a6da95", teal: "#8bd5ca", sky: "#91d7e3", sapphire: "#7dc4e4"
    blue: "#8aadf4", lavender: "#b7bdf8", text: "#cad3f5", subtext1: "#b8c0e0"
    subtext0: "#a5adcb", overlay2: "#939ab7", overlay1: "#8087a2", overlay0: "#6e738d"
    surface2: "#5b6078", surface1: "#494d64", surface0: "#363a4f"
    base: "#24273a", mantle: "#1e2030", crust: "#181926"
}
const CAT_FRAPPE = {
    rosewater: "#f2d5cf", flamingo: "#eebebe", pink: "#f4b8e4", mauve: "#ca9ee6"
    red: "#e78284", maroon: "#ea999c", peach: "#ef9f76", yellow: "#e5c890"
    green: "#a6d189", teal: "#81c8be", sky: "#99d1db", sapphire: "#85c1dc"
    blue: "#8caaee", lavender: "#babbf1", text: "#c6d0f5", subtext1: "#b5bfe2"
    subtext0: "#a5adce", overlay2: "#949cbb", overlay1: "#838ba7", overlay0: "#737994"
    surface2: "#626880", surface1: "#51576d", surface0: "#414559"
    base: "#303446", mantle: "#292c3c", crust: "#232634"
}
const CAT_LATTE = {
    rosewater: "#dc8a78", flamingo: "#dd7878", pink: "#ea76cb", mauve: "#8839ef"
    red: "#d20f39", maroon: "#e64553", peach: "#fe640b", yellow: "#df8e1d"
    green: "#40a02b", teal: "#179299", sky: "#04a5e5", sapphire: "#209fb5"
    blue: "#1e66f5", lavender: "#7287fd", text: "#4c4f69", subtext1: "#5c5f77"
    subtext0: "#6c6f85", overlay2: "#7c7f93", overlay1: "#8c8fa1", overlay0: "#9ca0b0"
    surface2: "#acb0be", surface1: "#bcc0cc", surface0: "#ccd0da"
    base: "#eff1f5", mantle: "#e6e9ef", crust: "#dce0e8"
}

# Build the Catppuccin color_config for a given flavor palette.
# Faithful port of catppuccin/nushell.
def cat-color-config [p: record] {
    let s = {
        recognized_command: $p.blue
        unrecognized_command: $p.text
        constant: $p.peach
        punctuation: $p.overlay2
        operator: $p.sky
        string: $p.green
        virtual_text: $p.surface2
        variable: { fg: $p.flamingo attr: i }
        filepath: $p.yellow
    }
    {
        separator: { fg: $p.surface2 attr: b }
        leading_trailing_space_bg: { fg: $p.lavender attr: u }
        header: { fg: $p.text attr: b }
        row_index: $s.virtual_text
        record: $p.text
        list: $p.text
        hints: $s.virtual_text
        search_result: { fg: $p.base bg: $p.yellow }
        shape_closure: $p.teal
        closure: $p.teal
        shape_flag: { fg: $p.maroon attr: i }
        shape_matching_brackets: { attr: u }
        shape_garbage: $p.red
        shape_keyword: $p.mauve
        shape_match_pattern: $p.green
        shape_signature: $p.teal
        shape_table: $s.punctuation
        cell-path: $s.punctuation
        shape_list: $s.punctuation
        shape_record: $s.punctuation
        shape_vardecl: $s.variable
        shape_variable: $s.variable
        empty: { attr: n }
        filesize: {||
            if $in < 1kb { $p.teal } else if $in < 10kb { $p.green
            } else if $in < 100kb { $p.yellow } else if $in < 10mb { $p.peach
            } else if $in < 100mb { $p.maroon } else if $in < 1gb { $p.red } else { $p.mauve }
        }
        duration: {||
            if $in < 1day { $p.teal } else if $in < 1wk { $p.green
            } else if $in < 4wk { $p.yellow } else if $in < 12wk { $p.peach
            } else if $in < 24wk { $p.maroon } else if $in < 52wk { $p.red } else { $p.mauve }
        }
        datetime: {|| (date now) - $in |
            if $in < 1day { $p.teal } else if $in < 1wk { $p.green
            } else if $in < 4wk { $p.yellow } else if $in < 12wk { $p.peach
            } else if $in < 24wk { $p.maroon } else if $in < 52wk { $p.red } else { $p.mauve }
        }
        shape_external: $s.unrecognized_command
        shape_internalcall: $s.recognized_command
        shape_external_resolved: $s.recognized_command
        shape_block: $s.recognized_command
        block: $s.recognized_command
        shape_custom: $p.pink
        custom: $p.pink
        shape_range: $s.operator
        range: $s.operator
        shape_pipe: $s.operator
        shape_operator: $s.operator
        shape_redirection: $s.operator
        glob: $s.filepath
        shape_directory: $s.filepath
        shape_filepath: $s.filepath
        shape_glob_interpolation: $s.filepath
        shape_globpattern: $s.filepath
        shape_int: $s.constant
        int: $s.constant
        bool: $s.constant
        float: $s.constant
        nothing: $s.constant
        binary: $s.constant
        shape_nothing: $s.constant
        shape_bool: $s.constant
        shape_float: $s.constant
        shape_binary: $s.constant
        shape_datetime: $s.constant
        shape_literal: $s.constant
        string: $s.string
        shape_string: $s.string
        shape_string_interpolation: $p.flamingo
        shape_raw_string: $s.string
        shape_externalarg: $s.string
    }
}

# Accent colors for the prompt, derived from a Catppuccin flavor.
def cat-prompt-palette [p: record] {
    {
        user: $p.yellow, host: $p.peach, path: $p.blue, git: $p.mauve
        sep: $p.overlay1, ok: $p.green, err: $p.red, time: $p.overlay0
        added: $p.green, modified: $p.yellow, deleted: $p.red, untracked: $p.overlay1
        ahead: $p.sky, behind: $p.peach, stash: $p.lavender, conflict: $p.maroon
        duration: $p.peach, ink: $p.crust, bg: $p.base, fg: $p.text
    }
}

# ── Gruvbox Dark Hard ─────────────────────────────────────────
const GRUV = {
    fg: "#ebdbb2", gray: "#928374", red: "#fb4934", green: "#b8bb26"
    yellow: "#fabd2f", blue: "#83a598", purple: "#d3869b", aqua: "#8ec07c"
    orange: "#fe8019", bg: "#1d2021"
}

def gruvbox-color-config [] {
    let g = $GRUV
    {
        separator: { fg: $g.gray }
        leading_trailing_space_bg: { attr: n }
        header: { fg: $g.green attr: b }
        empty: $g.blue
        bool: $g.aqua
        int: $g.purple
        filesize: $g.aqua
        duration: $g.purple
        date: $g.yellow
        range: $g.fg
        float: $g.purple
        string: $g.fg
        nothing: $g.gray
        binary: $g.orange
        cell-path: $g.fg
        row_index: { fg: $g.yellow attr: b }
        record: $g.fg
        list: $g.fg
        block: $g.fg
        hints: $g.gray
        search_result: { fg: $g.bg bg: $g.yellow }
        shape_and: { fg: $g.purple attr: b }
        shape_binary: { fg: $g.purple attr: b }
        shape_block: { fg: $g.blue attr: b }
        shape_bool: $g.aqua
        shape_closure: { fg: $g.aqua attr: b }
        shape_custom: $g.green
        shape_datetime: { fg: $g.aqua attr: b }
        shape_directory: $g.aqua
        shape_external: $g.aqua
        shape_externalarg: { fg: $g.green attr: b }
        shape_external_resolved: { fg: $g.yellow attr: b }
        shape_filepath: $g.aqua
        shape_flag: { fg: $g.blue attr: b }
        shape_float: { fg: $g.purple attr: b }
        shape_glob_interpolation: { fg: $g.aqua attr: b }
        shape_globpattern: { fg: $g.aqua attr: b }
        shape_int: { fg: $g.purple attr: b }
        shape_internalcall: { fg: $g.aqua attr: b }
        shape_keyword: { fg: $g.red attr: b }
        shape_list: { fg: $g.aqua attr: b }
        shape_literal: $g.blue
        shape_match_pattern: $g.green
        shape_matching_brackets: { attr: u }
        shape_nothing: $g.aqua
        shape_operator: $g.orange
        shape_or: { fg: $g.purple attr: b }
        shape_pipe: { fg: $g.purple attr: b }
        shape_range: { fg: $g.orange attr: b }
        shape_record: { fg: $g.aqua attr: b }
        shape_redirection: { fg: $g.purple attr: b }
        shape_signature: { fg: $g.green attr: b }
        shape_string: $g.green
        shape_string_interpolation: { fg: $g.aqua attr: b }
        shape_table: { fg: $g.blue attr: b }
        shape_variable: $g.purple
        shape_vardecl: $g.purple
        shape_garbage: { fg: $g.bg bg: $g.red attr: b }
    }
}

# ── Cyberpunk (neon) ──────────────────────────────────────────
const NEON = {
    fg: "#eaf2ff", gray: "#6c5b8c", pink: "#ff2a6d", cyan: "#05d9e8"
    magenta: "#ff5cf4", green: "#00ff9f", yellow: "#f9f871", violet: "#a97bff"
    orange: "#ff8b39", bg: "#0b0221"
}

def neon-color-config [] {
    let n = $NEON
    {
        separator: { fg: $n.magenta }
        leading_trailing_space_bg: { attr: n }
        header: { fg: $n.cyan attr: b }
        empty: $n.violet
        bool: $n.green
        int: $n.magenta
        filesize: $n.cyan
        duration: $n.magenta
        date: $n.yellow
        range: $n.fg
        float: $n.magenta
        string: $n.green
        nothing: $n.gray
        binary: $n.orange
        cell-path: $n.cyan
        row_index: { fg: $n.cyan attr: b }
        record: $n.fg
        list: $n.fg
        block: $n.fg
        hints: $n.gray
        search_result: { fg: $n.bg bg: $n.pink }
        shape_and: { fg: $n.magenta attr: b }
        shape_binary: { fg: $n.magenta attr: b }
        shape_block: { fg: $n.cyan attr: b }
        shape_bool: $n.green
        shape_closure: { fg: $n.cyan attr: b }
        shape_custom: $n.green
        shape_datetime: { fg: $n.cyan attr: b }
        shape_directory: $n.cyan
        shape_external: $n.cyan
        shape_externalarg: { fg: $n.green attr: b }
        shape_external_resolved: { fg: $n.yellow attr: b }
        shape_filepath: $n.cyan
        shape_flag: { fg: $n.yellow attr: b }
        shape_float: { fg: $n.magenta attr: b }
        shape_glob_interpolation: { fg: $n.cyan attr: b }
        shape_globpattern: { fg: $n.cyan attr: b }
        shape_int: { fg: $n.magenta attr: b }
        shape_internalcall: { fg: $n.cyan attr: b }
        shape_keyword: { fg: $n.pink attr: b }
        shape_list: { fg: $n.cyan attr: b }
        shape_literal: $n.violet
        shape_match_pattern: $n.green
        shape_matching_brackets: { attr: u }
        shape_nothing: $n.gray
        shape_operator: $n.pink
        shape_or: { fg: $n.magenta attr: b }
        shape_pipe: { fg: $n.pink attr: b }
        shape_range: { fg: $n.orange attr: b }
        shape_record: { fg: $n.cyan attr: b }
        shape_redirection: { fg: $n.pink attr: b }
        shape_signature: { fg: $n.green attr: b }
        shape_string: $n.green
        shape_string_interpolation: { fg: $n.cyan attr: b }
        shape_table: { fg: $n.cyan attr: b }
        shape_variable: $n.violet
        shape_vardecl: $n.violet
        shape_garbage: { fg: $n.bg bg: $n.pink attr: b }
    }
}

# ── Extra themes via a shared builder ────────────────────────
const TOKYO = {
    fg: "#c0caf5", gray: "#565f89", red: "#f7768e", orange: "#ff9e64"
    yellow: "#e0af68", green: "#9ece6a", cyan: "#7dcfff", blue: "#7aa2f7"
    magenta: "#bb9af7", purple: "#9d7cd8", bg: "#1a1b26"
}
const NORD = {
    fg: "#d8dee9", gray: "#4c566a", red: "#bf616a", orange: "#d08770"
    yellow: "#ebcb8b", green: "#a3be8c", cyan: "#88c0d0", blue: "#81a1c1"
    magenta: "#b48ead", purple: "#5e81ac", bg: "#2e3440"
}
const DRACULA = {
    fg: "#f8f8f2", gray: "#6272a4", red: "#ff5555", orange: "#ffb86c"
    yellow: "#f1fa8c", green: "#50fa7b", cyan: "#8be9fd", blue: "#bd93f9"
    magenta: "#ff79c6", purple: "#bd93f9", bg: "#282a36"
}
const ROSE_PINE = {
    fg: "#e0def4", gray: "#6e6a86", red: "#eb6f92", orange: "#ebbcba"
    yellow: "#f6c177", green: "#9ccfd8", cyan: "#9ccfd8", blue: "#31748f"
    magenta: "#c4a7e7", purple: "#c4a7e7", bg: "#191724"
}
const EVERFOREST = {
    fg: "#d3c6aa", gray: "#859289", red: "#e67e80", orange: "#e69875"
    yellow: "#dbbc7f", green: "#a7c080", cyan: "#83c092", blue: "#7fbbb3"
    magenta: "#d699b6", purple: "#d699b6", bg: "#2d353b"
}
const KANAGAWA = {
    fg: "#dcd7ba", gray: "#727169", red: "#ff5d62", orange: "#ffa066"
    yellow: "#e6c384", green: "#98bb6c", cyan: "#7fb4ca", blue: "#7e9cd8"
    magenta: "#957fb8", purple: "#957fb8", bg: "#1f1f28"
}
const ONEDARK = {
    fg: "#abb2bf", gray: "#5c6370", red: "#e06c75", orange: "#d19a66"
    yellow: "#e5c07b", green: "#98c379", cyan: "#56b6c2", blue: "#61afef"
    magenta: "#c678dd", purple: "#c678dd", bg: "#282c34"
}
const SOLARIZED = {
    fg: "#839496", gray: "#586e75", red: "#dc322f", orange: "#cb4b16"
    yellow: "#b58900", green: "#859900", cyan: "#2aa198", blue: "#268bd2"
    magenta: "#d33682", purple: "#6c71c4", bg: "#002b36"
}
const SOLARIZED_LIGHT = {
    fg: "#657b83", gray: "#93a1a1", red: "#dc322f", orange: "#cb4b16"
    yellow: "#b58900", green: "#859900", cyan: "#2aa198", blue: "#268bd2"
    magenta: "#d33682", purple: "#6c71c4", bg: "#fdf6e3"
}
const ROSE_PINE_MOON = {
    fg: "#e0def4", gray: "#6e6a86", red: "#eb6f92", orange: "#ea9a97"
    yellow: "#f6c177", green: "#9ccfd8", cyan: "#9ccfd8", blue: "#3e8fb0"
    magenta: "#c4a7e7", purple: "#c4a7e7", bg: "#232136"
}
const ROSE_PINE_DAWN = {
    fg: "#575279", gray: "#9893a5", red: "#b4637a", orange: "#d7827e"
    yellow: "#ea9d34", green: "#56949f", cyan: "#56949f", blue: "#286983"
    magenta: "#907aa9", purple: "#907aa9", bg: "#faf4ed"
}
const MONOKAI = {
    fg: "#f8f8f2", gray: "#75715e", red: "#f92672", orange: "#fd971f"
    yellow: "#e6db74", green: "#a6e22e", cyan: "#66d9ef", blue: "#66d9ef"
    magenta: "#ae81ff", purple: "#ae81ff", bg: "#272822"
}
const AYU_MIRAGE = {
    fg: "#cbccc6", gray: "#707a8c", red: "#ff3333", orange: "#ffa759"
    yellow: "#ffd580", green: "#bae67e", cyan: "#95e6cb", blue: "#73d0ff"
    magenta: "#d4bfff", purple: "#d4bfff", bg: "#1f2430"
}
const AYU_DARK = {
    fg: "#bfbdb6", gray: "#565b66", red: "#f26d78", orange: "#ff8f40"
    yellow: "#e6b450", green: "#aad94c", cyan: "#95e6cb", blue: "#59c2ff"
    magenta: "#d2a6ff", purple: "#d2a6ff", bg: "#0b0e14"
}
const NIGHT_OWL = {
    fg: "#d6deeb", gray: "#637777", red: "#ef5350", orange: "#f78c6c"
    yellow: "#ffeb95", green: "#addb67", cyan: "#7fdbca", blue: "#82aaff"
    magenta: "#c792ea", purple: "#c792ea", bg: "#011627"
}
const GITHUB_DARK = {
    fg: "#c9d1d9", gray: "#8b949e", red: "#ff7b72", orange: "#ffa657"
    yellow: "#e3b341", green: "#7ee787", cyan: "#a5d6ff", blue: "#79c0ff"
    magenta: "#d2a8ff", purple: "#d2a8ff", bg: "#0d1117"
}
const GITHUB_LIGHT = {
    fg: "#24292f", gray: "#6e7781", red: "#cf222e", orange: "#bc4c00"
    yellow: "#9a6700", green: "#1a7f37", cyan: "#1b7c83", blue: "#0969da"
    magenta: "#8250df", purple: "#8250df", bg: "#ffffff"
}
const OXOCARBON = {
    fg: "#f2f4f8", gray: "#525252", red: "#ee5396", orange: "#ff6f00"
    yellow: "#fae48c", green: "#42be65", cyan: "#3ddbd9", blue: "#33b1ff"
    magenta: "#be95ff", purple: "#be95ff", bg: "#161616"
}
const ZENBURN = {
    fg: "#dcdccc", gray: "#709080", red: "#cc9393", orange: "#dfaf8f"
    yellow: "#f0dfaf", green: "#7f9f7f", cyan: "#93e0e3", blue: "#8cd0d3"
    magenta: "#dc8cc3", purple: "#dc8cc3", bg: "#3f3f3f"
}
# Super Mario — vivid red / coin-gold / luigi-green / sky-blue on night bg.
const SUPER_MARIO = {
    fg: "#fdfdf5", gray: "#8a7f9a", red: "#ff3b30", orange: "#ff9c1a"
    yellow: "#ffd21e", green: "#3fca3f", cyan: "#49c6e8", blue: "#1aa5e6"
    magenta: "#ff77d4", purple: "#8a6be0", bg: "#0f0b24"
}

# Generic color_config from a simple palette (fg/gray/red/orange/yellow/
# green/cyan/blue/magenta/bg). Reused by tokyo-night and nord.
def basic-color-config [c: record] {
    {
        separator: { fg: $c.gray }
        leading_trailing_space_bg: { attr: n }
        header: { fg: $c.blue attr: b }
        empty: $c.blue
        bool: $c.cyan
        int: $c.magenta
        filesize: $c.cyan
        duration: $c.magenta
        date: $c.yellow
        range: $c.fg
        float: $c.magenta
        string: $c.green
        nothing: $c.gray
        binary: $c.orange
        cell-path: $c.fg
        row_index: { fg: $c.yellow attr: b }
        record: $c.fg
        list: $c.fg
        block: $c.fg
        hints: $c.gray
        search_result: { fg: $c.bg bg: $c.yellow }
        shape_and: { fg: $c.magenta attr: b }
        shape_binary: { fg: $c.magenta attr: b }
        shape_block: { fg: $c.blue attr: b }
        shape_bool: $c.cyan
        shape_closure: { fg: $c.cyan attr: b }
        shape_custom: $c.green
        shape_datetime: { fg: $c.cyan attr: b }
        shape_directory: $c.blue
        shape_external: $c.cyan
        shape_externalarg: { fg: $c.green attr: b }
        shape_external_resolved: { fg: $c.yellow attr: b }
        shape_filepath: $c.blue
        shape_flag: { fg: $c.magenta attr: b }
        shape_float: { fg: $c.magenta attr: b }
        shape_glob_interpolation: { fg: $c.cyan attr: b }
        shape_globpattern: { fg: $c.cyan attr: b }
        shape_int: { fg: $c.magenta attr: b }
        shape_internalcall: { fg: $c.cyan attr: b }
        shape_keyword: { fg: $c.red attr: b }
        shape_list: { fg: $c.cyan attr: b }
        shape_literal: $c.blue
        shape_match_pattern: $c.green
        shape_matching_brackets: { attr: u }
        shape_nothing: $c.cyan
        shape_operator: $c.orange
        shape_or: { fg: $c.magenta attr: b }
        shape_pipe: { fg: $c.magenta attr: b }
        shape_range: { fg: $c.orange attr: b }
        shape_record: { fg: $c.cyan attr: b }
        shape_redirection: { fg: $c.magenta attr: b }
        shape_signature: { fg: $c.green attr: b }
        shape_string: $c.green
        shape_string_interpolation: { fg: $c.cyan attr: b }
        shape_table: { fg: $c.blue attr: b }
        shape_variable: $c.magenta
        shape_vardecl: $c.magenta
        shape_garbage: { fg: $c.bg bg: $c.red attr: b }
    }
}

def basic-prompt-palette [c: record] {
    {
        user: $c.yellow, host: $c.orange, path: $c.blue, git: $c.magenta
        sep: $c.gray, ok: $c.green, err: $c.red, time: $c.gray
        added: $c.green, modified: $c.yellow, deleted: $c.red, untracked: $c.gray
        ahead: $c.cyan, behind: $c.orange, stash: $c.magenta, conflict: $c.red
        duration: $c.orange, ink: $c.bg, bg: $c.bg, fg: $c.fg
    }
}

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

# ── Public API ────────────────────────────────────────────────
def theme-list [] {
    ["gruvbox" "catppuccin-mocha" "catppuccin-macchiato" "catppuccin-frappe" "catppuccin-latte" "tokyo-night" "nord" "dracula" "rose-pine" "rose-pine-moon" "rose-pine-dawn" "everforest" "kanagawa" "onedark" "monokai" "ayu-dark" "ayu-mirage" "night-owl" "github-dark" "github-light" "oxocarbon" "zenburn" "solarized" "solarized-light" "super-mario" "cyberpunk"]
}

def theme-get-raw [name: string] {
    match $name {
        "catppuccin-mocha"     => { color_config: (cat-color-config $CAT_MOCHA)     palette: (cat-prompt-palette $CAT_MOCHA) }
        "catppuccin-macchiato" => { color_config: (cat-color-config $CAT_MACCHIATO) palette: (cat-prompt-palette $CAT_MACCHIATO) }
        "catppuccin-frappe"    => { color_config: (cat-color-config $CAT_FRAPPE)    palette: (cat-prompt-palette $CAT_FRAPPE) }
        "catppuccin-latte"     => { color_config: (cat-color-config $CAT_LATTE)     palette: (cat-prompt-palette $CAT_LATTE) }
        "cyberpunk" => {
            color_config: (neon-color-config)
            palette: {
                user: $NEON.yellow, host: $NEON.pink, path: $NEON.cyan, git: $NEON.magenta
                sep: $NEON.gray, ok: $NEON.green, err: $NEON.pink, time: $NEON.violet
                added: $NEON.green, modified: $NEON.yellow, deleted: $NEON.pink, untracked: $NEON.gray
                ahead: $NEON.cyan, behind: $NEON.orange, stash: $NEON.magenta, conflict: $NEON.pink
                duration: $NEON.orange, ink: $NEON.bg, bg: $NEON.bg, fg: $NEON.fg
            }
        }
        "tokyo-night" => { color_config: (basic-color-config $TOKYO) palette: (basic-prompt-palette $TOKYO) }
        "nord"        => { color_config: (basic-color-config $NORD)  palette: (basic-prompt-palette $NORD) }
        "dracula"     => { color_config: (basic-color-config $DRACULA)     palette: (basic-prompt-palette $DRACULA) }
        "rose-pine"   => { color_config: (basic-color-config $ROSE_PINE)   palette: (basic-prompt-palette $ROSE_PINE) }
        "rose-pine-moon" => { color_config: (basic-color-config $ROSE_PINE_MOON) palette: (basic-prompt-palette $ROSE_PINE_MOON) }
        "rose-pine-dawn" => { color_config: (basic-color-config $ROSE_PINE_DAWN) palette: (basic-prompt-palette $ROSE_PINE_DAWN) }
        "everforest"  => { color_config: (basic-color-config $EVERFOREST)  palette: (basic-prompt-palette $EVERFOREST) }
        "kanagawa"    => { color_config: (basic-color-config $KANAGAWA)    palette: (basic-prompt-palette $KANAGAWA) }
        "onedark"     => { color_config: (basic-color-config $ONEDARK)     palette: (basic-prompt-palette $ONEDARK) }
        "monokai"     => { color_config: (basic-color-config $MONOKAI)     palette: (basic-prompt-palette $MONOKAI) }
        "ayu-dark"    => { color_config: (basic-color-config $AYU_DARK)    palette: (basic-prompt-palette $AYU_DARK) }
        "ayu-mirage"  => { color_config: (basic-color-config $AYU_MIRAGE)  palette: (basic-prompt-palette $AYU_MIRAGE) }
        "night-owl"   => { color_config: (basic-color-config $NIGHT_OWL)   palette: (basic-prompt-palette $NIGHT_OWL) }
        "github-dark"  => { color_config: (basic-color-config $GITHUB_DARK)  palette: (basic-prompt-palette $GITHUB_DARK) }
        "github-light" => { color_config: (basic-color-config $GITHUB_LIGHT) palette: (basic-prompt-palette $GITHUB_LIGHT) }
        "oxocarbon"   => { color_config: (basic-color-config $OXOCARBON)   palette: (basic-prompt-palette $OXOCARBON) }
        "zenburn"     => { color_config: (basic-color-config $ZENBURN)     palette: (basic-prompt-palette $ZENBURN) }
        "super-mario" => { color_config: (basic-color-config $SUPER_MARIO) palette: (basic-prompt-palette $SUPER_MARIO) }
        "solarized"       => { color_config: (basic-color-config $SOLARIZED)       palette: (basic-prompt-palette $SOLARIZED) }
        "solarized-light" => { color_config: (basic-color-config $SOLARIZED_LIGHT) palette: (basic-prompt-palette $SOLARIZED_LIGHT) }
        _ => {
            color_config: (gruvbox-color-config)
            palette: {
                user: $GRUV.yellow, host: $GRUV.orange, path: $GRUV.aqua, git: $GRUV.purple
                sep: $GRUV.gray, ok: $GRUV.green, err: $GRUV.red, time: $GRUV.gray
                added: $GRUV.green, modified: $GRUV.yellow, deleted: $GRUV.red, untracked: $GRUV.gray
                ahead: $GRUV.aqua, behind: $GRUV.orange, stash: $GRUV.purple, conflict: $GRUV.red
                duration: $GRUV.orange, ink: $GRUV.bg, bg: $GRUV.bg, fg: $GRUV.fg
            }
        }
    }
}

# ─────────────────────────────────────────────────────────────
# Theme system  (definitions live in theme.nu)
#   • Ghostty is the source of truth: on startup nushell adopts
#     whatever theme Ghostty is using (gruvbox → gruvbox, etc.)
#   • re-sync in a running shell:  theme-sync
#   • override manually:           theme  (or: theme catppuccin-mocha)
#   • list themes:                 theme-list
# ─────────────────────────────────────────────────────────────

$env.config.table.mode = "rounded"
$env.config.table.index_mode = "auto"
$env.config.footer_mode = 25
$env.config.render_right_prompt_on_last_line = true
$env.config.show_banner = false

# File that stores the currently-selected theme name.
def theme-state-path [] { $nu.default-config-dir | path join "current-theme.txt" }

# Apply a theme to the *current* session (colors + prompt palette).
def --env theme-apply [name: string] {
    let t = (theme-get $name)
    $env.config.color_config = $t.color_config
    $env.THEME_PALETTE = $t.palette
    $env.THEME_NAME = $name
}

# Render one theme name into a labelled preview line: "name  →  <live prompt>".
# Renders using the CURRENT prompt style so only theme colors change.
def --env theme-label [name: string] {
    let saved = $env.THEME_PALETTE?
    $env.THEME_PALETTE = (theme-get $name).palette
    let rendered = (create_left_prompt)
    $env.THEME_PALETTE = $saved
    let w = (theme-list | each { str length } | math max)
    $"($name | fill --alignment left --width $w)  →  ($rendered)"
}

def --env theme-picker-items [] {
    [(sync-picker-item)] ++ (theme-list | each {|n| { label: (theme-label $n), key: $n } })
}

# Whether the compiled `nuance` (clap + ratatui) binary is on PATH. When it
# is, every interactive picker delegates to it instead of Nushell's own
# `input list`, so the UI is identical everywhere: inside `nu`, from
# bash/zsh/fish via the `nuance` CLI, doesn't matter.
def nuance-cli-available [] { (which nuance | is-not-empty) }

# Re-read persisted theme/style state and apply it to *this* live session.
# `^nuance ...` only ever persists to disk from its own subprocess — this
# is what makes the change visible immediately in the shell you're
# actually sitting in, instead of only the next new one.
def --env reload-theme [] {
    let saved = (try { open (theme-state-path) | str trim } catch { "auto" })
    let name = (
        if ($saved in (theme-list)) { $saved }
        else {
            let g = (ghostty-theme-name)
            if ($g | is-not-empty) { $g } else { "gruvbox" }
        }
    )
    theme-apply $name
}

def --env reload-style [] {
    let saved = (try { open (prompt-style-path) | str trim } catch { "full" })
    $env.PROMPT_STYLE = (if ($saved in (prompt-styles)) { $saved } else { "full" })
}

# The synthetic "sync with terminal" entry every theme/look picker leads
# with — same icon + key ("__sync__") used by both the Nushell `input
# list` fallback and the Rust ratatui picker (fed this same item over JSON).
def --env sync-picker-item [] {
    let sicon = (if ($env.PROMPT_NERD? | default true) { (char --unicode f021) } else { (char --unicode 27f3) })
    { label: $"(ansi {fg: $env.THEME_PALETTE.ahead attr: b})($sicon)  sync with terminal(ansi reset)", key: "__sync__" }
}

# Switch theme. With no argument and the `nuance` binary available,
# delegates to its ratatui picker (instant live preview, always the same
# UI as any other shell) and reloads the result into this session. Without
# it, falls back to Nushell's own fuzzy `input list` picker. Either way,
# "↻ sync with terminal" is always the first entry.
def --env theme [name?: string] {
    if ($name | is-empty) and (nuance-cli-available) {
        ^nuance theme
        reload-theme
        return
    }
    let choice = if ($name | is-empty) {
        let items = (theme-picker-items)
        let pick = ($items | get label | input list --fuzzy $"theme  \(current: ($env.THEME_NAME? | default 'gruvbox')\)")
        if ($pick | is-empty) { "" } else {
            ($items | where label == $pick | get 0?).key? | default ""
        }
    } else { $name }
    if ($choice | is-empty) { return }
    if ($choice == "__sync__") { theme-sync; return }
    if ($choice not-in (theme-list)) {
        print $"(ansi red)unknown theme:(ansi reset) ($choice)"
        print $"available: (theme-list | str join ', ')"
        return
    }
    theme-apply $choice
    $choice | save -f (theme-state-path)
    print $"(ansi green_bold)✓(ansi reset) theme set to (ansi attr_bold)($choice)(ansi reset) (ansi grey)\(pinned\)(ansi reset)"
    # When picked interactively via the Nushell fallback (no `nuance`
    # binary), also choose a matching prompt style. The ratatui path above
    # skips this deliberately, to keep the UI identical everywhere — use
    # `look` for a theme+style combo.
    if ($name | is-empty) {
        let s_items = (style-picker-items)
        let s_pick = ($s_items | get label | input list --fuzzy $"prompt style for ($choice)  \(esc to keep ($env.PROMPT_STYLE? | default 'full')\)")
        let s = if ($s_pick | is-empty) { "" } else { ($s_items | where label == $s_pick | get 0?).key? | default "" }
        if ($s | is-not-empty) {
            $env.PROMPT_STYLE = $s
            $s | save -f (prompt-style-path)
            print $"(ansi green_bold)✓(ansi reset) prompt style set to (ansi attr_bold)($s)(ansi reset)"
        }
    }
}

# Curated theme + prompt-style combinations.
def presets [] {
    [
        { name: "cyberpunk",        theme: "cyberpunk",             style: "cyberpunk" }
        { name: "synthwave",        theme: "cyberpunk",             style: "capsule" }
        { name: "gruvbox",          theme: "gruvbox",               style: "full" }
        { name: "gruvbox-minimal",  theme: "gruvbox",               style: "minimal" }
        { name: "mocha-pure",       theme: "catppuccin-mocha",      style: "pure" }
        { name: "macchiato-lambda", theme: "catppuccin-macchiato",  style: "lambda" }
        { name: "latte-compact",    theme: "catppuccin-latte",      style: "compact" }
        { name: "tokyo-powerline",  theme: "tokyo-night",           style: "powerline" }
        { name: "tokyo-capsule",    theme: "tokyo-night",           style: "capsule" }
        { name: "nord-lambda",      theme: "nord",                  style: "lambda" }
        { name: "dracula-slant",    theme: "dracula",               style: "slant" }
        { name: "rose-pine-pure",   theme: "rose-pine",             style: "pure" }
        { name: "everforest-boxed", theme: "everforest",            style: "boxed" }
        { name: "kanagawa-capsule", theme: "kanagawa",              style: "capsule" }
        { name: "onedark-bracket",  theme: "onedark",               style: "bracket" }
        { name: "solarized-full",   theme: "solarized",             style: "full" }
        { name: "monokai-rainbow",  theme: "monokai",               style: "rainbow" }
        { name: "ayu-arrow",        theme: "ayu-dark",              style: "arrow" }
        { name: "night-owl-pure",   theme: "night-owl",             style: "pure" }
        { name: "github-arrow",     theme: "github-dark",           style: "arrow" }
        { name: "oxocarbon-rainbow",theme: "oxocarbon",             style: "rainbow" }
        { name: "rose-moon-boxed",  theme: "rose-pine-moon",        style: "boxed" }
        { name: "robbyrussell",     theme: "onedark",               style: "robbyrussell" }
        { name: "ys",               theme: "night-owl",             style: "ys" }
        { name: "avit",             theme: "tokyo-night",           style: "avit" }
        { name: "bira",             theme: "nord",                  style: "bira" }
        { name: "af-magic",         theme: "dracula",               style: "af-magic" }
        { name: "cloud",            theme: "catppuccin-frappe",      style: "cloud" }
        { name: "super-mario",      theme: "super-mario",           style: "mario" }
        { name: "arcade",           theme: "super-mario",           style: "arcade" }
        { name: "8bit",             theme: "gruvbox",               style: "8bit" }
        { name: "dracula-agnoster", theme: "dracula",               style: "agnoster" }
        { name: "tokyo-skyline",    theme: "tokyo-night",           style: "skyline" }
        { name: "nord-pills",       theme: "nord",                  style: "pills" }
    ]
}

# Apply + pin a theme and a prompt style together (overrides Ghostty).
def --env apply-look [theme_name: string, style_name: string] {
    theme-apply $theme_name
    $env.PROMPT_STYLE = $style_name
    $theme_name | save -f (theme-state-path)
    $style_name | save -f (prompt-style-path)
}

# Render one look's preview: applies its theme+style to the *current*
# session only for the duration of the render, then restores. Used by both
# the Nushell fuzzy picker and the Rust/ratatui TUI (via `... | to json`).
def --env look-label [theme_name: string, style_name: string] {
    let saved_p = $env.THEME_PALETTE?
    let saved_s = $env.PROMPT_STYLE?
    $env.THEME_PALETTE = (theme-get $theme_name).palette
    $env.PROMPT_STYLE = $style_name
    let rendered = (create_left_prompt)
    $env.THEME_PALETTE = $saved_p
    $env.PROMPT_STYLE = $saved_s
    $rendered
}

def --env look-picker-items [] {
    let ps = (presets)
    let w = ($ps | get name | each { str length } | math max)
    $ps | each {|r| { label: $"($r.name | fill --alignment left --width $w)  →  (look-label $r.theme $r.style)", key: $r.name } }
}

# Pick a full look (theme + prompt style). No arg = interactive picker
# (delegates to the `nuance` ratatui picker when available).
def --env look [name?: string] {
    if ($name | is-empty) and (nuance-cli-available) {
        ^nuance look
        reload-theme
        reload-style
        return
    }
    let ps = (presets)
    let choice = if ($name | is-empty) {
        let items = (look-picker-items)
        let pick = ($items | get label | input list --fuzzy "look  (theme + prompt style)")
        if ($pick | is-empty) { "" } else { ($items | where label == $pick | get 0?).key? | default "" }
    } else { $name }
    if ($choice | is-empty) { return }
    let row = ($ps | where name == $choice | get 0?)
    if ($row | is-empty) {
        print $"(ansi red)unknown look:(ansi reset) ($choice)"
        print $"available: ($ps | get name | str join ', ')"
        return
    }
    apply-look $row.theme $row.style
    print $"(ansi green_bold)✓(ansi reset) look (ansi attr_bold)($choice)(ansi reset) — theme (ansi attr_bold)($row.theme)(ansi reset), style (ansi attr_bold)($row.style)(ansi reset)"
}

# List available looks.
def looks [] { presets | select name theme style }

# Swatch of every theme's palette (one row each) — see all colors at a glance.
def theme-preview [] {
    let names = (theme-list)
    let w = ($names | each { str length } | math max)
    let keys = [err host modified ok ahead path git user]
    for t in $names {
        let p = (theme-get $t).palette
        let sw = ($keys | each {|k| $"(ansi {fg: ($p | get $k)})███(ansi reset)" } | str join "")
        print $"($t | fill --alignment left --width $w)  ($sw)"
    }
}

# Render every prompt style once (using the current theme), stacked + labelled.
def style-preview [] {
    let saved = ($env.PROMPT_STYLE? | default "full")
    let sep = (($env.THEME_PALETTE? | default {}).sep? | default "#808080")
    for s in (prompt-styles) {
        $env.PROMPT_STYLE = $s
        print $"(ansi {fg: $sep})($s)(ansi reset)"
        print (create_left_prompt)
        print ""
    }
    $env.PROMPT_STYLE = $saved
}

# Update nuance in place. If installed as a symlink to a git checkout, this
# pulls the latest and reloads; otherwise it points you at the reinstall.
# nuance CLI (also available as a POSIX `nuance` in ~/.local/bin for other shells)
def "nuance update" [] {
    let link = ($nu.user-autoload-dirs | get 0 | path join "nushell-prompt.nu")
    if not ($link | path exists) { print $"(ansi red)nuance is not installed(ansi reset) at ($link)"; return }
    let real = ($link | path expand)          # resolves the symlink
    let repo = ($real | path dirname)
    if (($repo | path join ".git") | path exists) {
        print $"(ansi green)updating(ansi reset) ($repo) …"
        ^git -C $repo pull --ff-only
        print $"(ansi green_bold)✓(ansi reset) updated — run (ansi attr_bold)exec nu(ansi reset) to reload."
    } else {
        print $"(ansi yellow)copy install detected(ansi reset) \(($repo)) — re-run the installer to update:"
        print "  nu scripts/install.nu   # from a fresh git clone, or: cargo install --force nuance-cli"
    }
}

def nuance [] { nuance help }

def "nuance help" [] {
    print $"(ansi green_bold)nuance(ansi reset) — themeable, git-aware Nushell prompt"
    print ""
    print "  nuance theme [name]          selector (incl. ↻ sync with terminal), or set one"
    print "  nuance prompt-style [name]   selector, or set one"
    print "  nuance look [name]           list looks, or apply one (theme + style)"
    print "  nuance sync                  follow the terminal's theme (auto-follow)"
    print "  nuance transient [on|off]    collapse finished prompts to one glyph"
    print "  nuance modules [enable|disable|list|clear] [name…]   situational segments (git is always on)"
    print "  nuance update                pull the latest, then: exec nu"
    print "  nuance help                  this help"
    print ""
    print "Shortcuts:  theme · prompt-style · look · theme-preview · style-preview"
}

# `nuance theme` — no name opens a swatch selector; a name sets + pins it.
# `nuance theme` — same as bare `theme`: no name opens the picker
# (ratatui via the external `nuance` binary when available, else Nushell's
# own fuzzy `input list`); a name sets + pins it. Kept as a separate name
# for discoverability/back-compat — identical behavior either way.
def --env "nuance theme" [name?: string] { theme $name }

# `nuance prompt-style` — same as bare `prompt-style`.
def --env "nuance prompt-style" [name?: string] { prompt-style $name }

# `nuance look` — same as bare `look`.
def --env "nuance look" [name?: string] { look $name }

# `nuance transient [on|off|toggle]` — collapse finished prompts to one glyph.
def --env "nuance transient" [mode?: string] {
    let cur = ($env.NUANCE_TRANSIENT? | default "off")
    let next = match ($mode | default "") {
        "" => { print $"transient prompt: (ansi attr_bold)($cur)(ansi reset)  \(nuance transient on|off|toggle\)"; return }
        "toggle" => (if $cur == "on" { "off" } else { "on" })
        "on" | "off" => $mode
        _ => { print $"(ansi red)unknown mode:(ansi reset) ($mode)  — use on, off or toggle"; return }
    }
    transient-apply $next
    $next | save -f (transient-state-path)
    print $"(ansi green_bold)✓(ansi reset) transient prompt (ansi attr_bold)($next)(ansi reset)"
}

# `nuance modules [list|enable|disable|clear] [name…]` — situational prompt segments.
def --env "nuance modules" [action?: string, ...names: string] {
    let act = ($action | default "list")
    match $act {
        "list" => {
            let on = (enabled-modules)
            module-defs | each {|m| { module: $m.name, enabled: ($m.name in $on), description: $m.desc } }
        }
        "enable" | "disable" => {
            let bad = ($names | where {|n| $n not-in (module-names) })
            if ($names | is-empty) or ($bad | is-not-empty) {
                print $"(ansi red)usage:(ansi reset) nuance modules ($act) <name…>   modules: (module-names | str join ', ')"
                return
            }
            let cur = (enabled-modules)
            let next = if $act == "enable" { $cur | append $names | uniq } else { $cur | where {|m| $m not-in $names } }
            $env.NUANCE_MODULES = $next
            $next | str join "\n" | save -f (modules-state-path)
            print $"(ansi green_bold)✓(ansi reset) modules: (if ($next | is-empty) { 'none' } else { $next | str join ', ' })"
        }
        "clear" => {
            $env.NUANCE_MODULES = []
            "" | save -f (modules-state-path)
            print $"(ansi green_bold)✓(ansi reset) all modules disabled"
        }
        _ => { print $"(ansi red)unknown action:(ansi reset) ($act)  — use list, enable, disable or clear" }
    }
}

# Read Ghostty's active theme and map it to a nushell theme name.
# Returns null when it can't be determined.
# Detect OS dark mode (macOS `defaults`, GNOME `gsettings`); default dark.
def os-dark-mode [] {
    let mac = (do -i { ^defaults read -g AppleInterfaceStyle } | complete)
    if $mac.exit_code == 0 { return ($mac.stdout | str contains --ignore-case "dark") }
    let gnome = (do -i { ^gsettings get org.gnome.desktop.interface color-scheme } | complete)
    if $gnome.exit_code == 0 { return ($gnome.stdout | str contains --ignore-case "dark") }
    true
}

# Map a raw theme name (from Ghostty or anywhere) to a nuance theme, or null.
def ghostty-map-name [low: string] {
    if ($low | str contains --ignore-case "gruvbox") { "gruvbox"
    } else if ($low | str contains --ignore-case "mocha") { "catppuccin-mocha"
    } else if ($low | str contains --ignore-case "macchiato") { "catppuccin-macchiato"
    } else if ($low | str contains --ignore-case "frappe") { "catppuccin-frappe"
    } else if ($low | str contains --ignore-case "latte") { "catppuccin-latte"
    } else if ($low | str contains --ignore-case "tokyo") { "tokyo-night"
    } else if ($low | str contains --ignore-case "nord") { "nord"
    } else if ($low | str contains --ignore-case "dracula") { "dracula"
    } else if (($low | str contains --ignore-case "rose") or ($low | str contains --ignore-case "ros\u{e9}")) {
        if ($low | str contains --ignore-case "dawn") { "rose-pine-dawn"
        } else if ($low | str contains --ignore-case "moon") { "rose-pine-moon"
        } else { "rose-pine" }
    } else if ($low | str contains --ignore-case "everforest") { "everforest"
    } else if ($low | str contains --ignore-case "kanagawa") { "kanagawa"
    } else if (($low | str contains --ignore-case "one") and ($low | str contains --ignore-case "dark")) { "onedark"
    } else if ($low | str contains --ignore-case "monokai") { "monokai"
    } else if ($low | str contains --ignore-case "mirage") { "ayu-mirage"
    } else if ($low | str contains --ignore-case "ayu") { "ayu-dark"
    } else if (($low | str contains --ignore-case "night") and ($low | str contains --ignore-case "owl")) { "night-owl"
    } else if (($low | str contains --ignore-case "github") and ($low | str contains --ignore-case "light")) { "github-light"
    } else if ($low | str contains --ignore-case "github") { "github-dark"
    } else if ($low | str contains --ignore-case "oxocarbon") { "oxocarbon"
    } else if ($low | str contains --ignore-case "zenburn") { "zenburn"
    } else if ($low | str contains --ignore-case "mario") { "super-mario"
    } else if (($low | str contains --ignore-case "solarized") and ($low | str contains --ignore-case "light")) { "solarized-light"
    } else if ($low | str contains --ignore-case "solarized") { "solarized"
    } else { null }
}

def ghostty-theme-name [] {
    let cfgs = [
        ($env.HOME | path join ".config" "ghostty" "config")
        ($env.HOME | path join "Library" "Application Support" "com.mitchellh.ghostty" "config")
    ]
    let file = ($cfgs | where {|p| $p | path exists } | get 0? )
    if ($file | is-empty) { return null }

    let line = (
        open $file | lines
        | where {|l| ($l | str trim | str starts-with --ignore-case "theme") and ($l | str contains "=") }
        | get 0?
    )
    if ($line | is-empty) { return null }
    mut val = ($line | str replace -r '^\s*[Tt]heme\s*=\s*' '' | str trim)

    # Ghostty supports  theme = light:NAME,dark:NAME  — pick per OS appearance.
    if ($val | str contains ":") {
        let dark = (os-dark-mode)
        let want = (if $dark { "dark" } else { "light" })
        let seg = ($val | split row "," | where {|s| $s | str trim | str starts-with --ignore-case $want } | get 0?)
        if ($seg | is-not-empty) { $val = ($seg | split row ":" | last | str trim) }
    }

    ghostty-map-name $val
}

# Re-adopt Ghostty's current theme in this session.
# Follow the terminal: adopt Ghostty's current theme (auto-follow on).
def --env "nuance sync theme" [] {
    let g = (ghostty-theme-name)
    if ($g | is-empty) {
        print $"(ansi yellow)could not detect a matching terminal theme(ansi reset)"
        return
    }
    theme-apply $g
    "auto" | save -f (theme-state-path)
    print $"(ansi green_bold)✓(ansi reset) following the terminal — (ansi attr_bold)($g)(ansi reset) (ansi grey)\(auto-follow on\)(ansi reset)"
}

# Shortcuts / back-compat aliases.
def --env "nuance sync" [] { nuance sync theme }
def --env theme-sync [] { nuance sync theme }

# Startup theme selection:
#   • a pinned theme (a saved theme name) wins — keeps e.g. cyberpunk
#   • "auto" / no pin / invalid → follow Ghostty, else fall back to gruvbox
let saved_theme = (try { open (theme-state-path) | str trim } catch { "auto" })
let start_theme = (
    if ($saved_theme in (theme-list)) { $saved_theme }
    else {
        let g = (ghostty-theme-name)
        if ($g | is-not-empty) { $g } else { "gruvbox" }
    }
)
theme-apply $start_theme

# ─────────────────────────────────────────────────────────────
# Prompt — git-aware, oh-my-zsh style, themed via $env.THEME_PALETTE
#   • rich repo info: branch, ahead/behind, staged/modified/etc.
#   • command duration + exit status
#   • switch layout with:  prompt-style   (full | compact | minimal)
# ─────────────────────────────────────────────────────────────

def prompt-style-path [] { $nu.default-config-dir | path join "prompt-style.txt" }
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
def style-defs [] {
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
        { name: "boxed",        kind: "inline", glyph: "❯",   tone: "ok",       nerd: false, desc: "two-line box-drawing with a ● clean/dirty marker" }
        { name: "mario",        kind: "inline", glyph: "▶",   tone: "ok",       nerd: false, desc: "two-line 🍄 overworld — ▣ ◆ ⚑ ◉ ▄" }
        { name: "arcade",       kind: "inline", glyph: "▮▮",  tone: "modified", nerd: false, desc: "retro all-caps ▶ 1UP score line" }
        { name: "8bit",         kind: "inline", glyph: "█",   tone: "modified", nerd: false, desc: "pixel ░▒▓ gradient separators" }
        { name: "cyberpunk",    kind: "inline", glyph: "▶▶▶", tone: "git",      nerd: false, desc: "two-line neon box-drawing with ⚡ and ▶▶▶" }
    ]
}
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
    let rendered = (create_left_prompt)
    $env.PROMPT_STYLE = $saved
    let w = (prompt-styles | each { str length } | math max)
    $"($s | fill --alignment left --width $w)  →  ($rendered)"
}

# Build the labelled candidate list once, and a lookup back to plain names.
def --env style-picker-items [] {
    prompt-styles | each {|s| { label: (style-label $s), key: $s } }
}

# Switch prompt layout. No arg = interactive picker (delegates to the
# `nuance` ratatui picker when available, same as every other picker here).
def --env prompt-style [name?: string] {
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

# Gather git repo state as data (reused by every prompt style).
# `--light` only resolves the branch/HEAD (skips status + stash: much faster).
def git-info [--light] {
    let inside = (do -i { git rev-parse --is-inside-work-tree } | complete)
    if $inside.exit_code != 0 { return { present: false } }
    let branch = (do -i { git branch --show-current } | complete | get stdout | str trim)
    let head = if ($branch | is-not-empty) { $branch } else {
        let sha = (do -i { git rev-parse --short HEAD } | complete | get stdout | str trim)
        if ($sha | is-empty) { "(no commits)" } else { $"@($sha)" }
    }
    if $light {
        return { present: true, head: $head, ahead: 0, behind: 0, staged: 0, modified: 0, untracked: 0, conflict: 0, stash: 0, clean: true }
    }
    let lines = (do -i { git status --porcelain=v1 --branch } | complete | get stdout | lines)
    let bl = ($lines | where {|l| $l | str starts-with "##" } | get 0? | default "")
    let ahead  = ($bl | parse -r 'ahead (?<n>\d+)'  | get n.0? | default "0" | into int)
    let behind = ($bl | parse -r 'behind (?<n>\d+)' | get n.0? | default "0" | into int)
    mut staged = 0; mut modified = 0; mut untracked = 0; mut conflict = 0
    for line in ($lines | where {|l| not ($l | str starts-with "##") }) {
        let cs = ($line | split chars)
        let x = ($cs | get 0? | default " ")
        let y = ($cs | get 1? | default " ")
        if ($x == "?" and $y == "?") { $untracked = $untracked + 1
        } else if ($x == "U" or $y == "U" or ($x == "A" and $y == "A") or ($x == "D" and $y == "D")) { $conflict = $conflict + 1
        } else {
            if $x != " " { $staged = $staged + 1 }
            if $y != " " { $modified = $modified + 1 }
        }
    }
    let stash = (do -i { git stash list } | complete | get stdout | lines | where {|l| $l | is-not-empty } | length)
    let clean = (($ahead + $behind + $staged + $modified + $untracked + $conflict + $stash) == 0)
    { present: true, head: $head, ahead: $ahead, behind: $behind, staged: $staged, modified: $modified, untracked: $untracked, conflict: $conflict, stash: $stash, clean: $clean }
}

# Plain-text branch + status summary (no color), e.g. "main ⇡2 +1 !3".
def git-plain [g: record] {
    mut t = $g.head
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
    $"(ansi {fg: $p.git})git:\((ansi {fg: $p.behind attr: b})($g.head)(ansi {fg: $p.git})\)(ansi reset)($dirty)"
}

# Rich git segment: branch/commit + divergence + working-tree status.
def git-segment [--counts] {
    let p = $env.THEME_PALETTE
    let g = (if $counts { git-info } else { git-info --light })
    if not $g.present { return "" }

    let icon = if ($env.PROMPT_NERD? | default true) { " " } else { "" }
    let base = $"(ansi {fg: $p.sep})on (ansi {fg: $p.git attr: b})($icon)($g.head)(ansi reset)"
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
        let w = (do -i { whoami } | complete | get stdout | str trim)
        if ($w | is-not-empty) { $w } else { "user" }
    }
}
def prompt-host [] {
    if (($env.PROMPT_HOST? | default "") | is-not-empty) { return $env.PROMPT_HOST }
    try { sys host | get hostname } catch { ($env.HOSTNAME? | default "host") }
}

# ── Context modules ──────────────────────────────────────────
# Small situational segments: they only render when they have something to
# say (a failing exit code, background jobs, an SSH session, a project's
# toolchain …). Block styles can list them in their registry `segs`
# (pastel, devbar); on top of that you can opt in to any of them for every
# style with `nuance modules enable <name>` — blocks styles append them as
# extra segments, single-line styles as a colored tail.
#   role = palette color the module is drawn with (must be a segment role)
def module-defs [] {
    [
        { name: "status", role: "err",      desc: "exit code of the last command (when non-zero)" }
        { name: "jobs",   role: "modified", desc: "number of background jobs" }
        { name: "ssh",    role: "host",     desc: "shown inside an SSH session" }
        { name: "root",   role: "err",      desc: "shown when running as root" }
        { name: "venv",   role: "ok",       desc: "active Python virtualenv / conda env" }
        { name: "nix",    role: "ahead",    desc: "inside a nix shell" }
        { name: "lang",   role: "ahead",    desc: "project toolchain + version: rust, node, python, go, ruby, zig" }
        { name: "k8s",    role: "host",     desc: "current kubectl context" }
    ]
}
def module-names [] { module-defs | get name }
def modules-state-path [] { $nu.default-config-dir | path join "modules.txt" }

# Modules the user enabled globally (persisted in modules.txt).
def enabled-modules [] {
    ($env.NUANCE_MODULES? | default []) | where {|m| $m in (module-names) }
}

# First x.y[.z] version number in a tool's `--version` output.
def first-version [text: string] {
    $text | parse -r '(?<v>\d+\.\d+(?:\.\d+)?)' | get v.0? | default ""
}

# Toolchain version, cached on disk for an hour — spawning rustc/node on
# every prompt would make the shell feel sluggish.
def tool-version [tool: string, args: list<string>] {
    let dir = ($nu.cache-dir | path join "nuance")
    let f = ($dir | path join $"ver-($tool)")  # keyed by binary name
    if ($f | path exists) {
        let age = ((date now) - (ls -D $f | get 0.modified))
        if $age < 1hr { return (open --raw $f | str trim) }
    }
    if (which $tool | is-empty) { return "" }
    let out = (do -i { ^$tool ...$args } | complete)
    let v = (first-version ($out.stdout + $out.stderr))
    mkdir $dir
    $v | save -f $f
    $v
}

# Which toolchain does this project use? Walks up from $PWD (max 6 levels).
def lang-detect [start?: string] {
    let markers = [
        { file: "Cargo.toml", lang: "rust" } { file: "go.mod", lang: "go" }
        { file: "package.json", lang: "node" } { file: "pyproject.toml", lang: "python" }
        { file: "requirements.txt", lang: "python" } { file: "setup.py", lang: "python" }
        { file: "Gemfile", lang: "ruby" } { file: "build.zig", lang: "zig" }
    ]
    mut dir = ($start | default $env.PWD)
    for _ in 0..5 {
        for m in $markers {
            if ($dir | path join $m.file | path exists) { return $m.lang }
        }
        let up = ($dir | path dirname)
        if $up == $dir { break }
        $dir = $up
    }
    ""
}

# Text of one module, or null when it has nothing to show.
def module-text [name: string] {
    match $name {
        "status" => {
            let c = ($env.LAST_EXIT_CODE? | default 0)
            if $c == 0 { null } else { $"✘ ($c)" }
        }
        "jobs" => {
            let n = (try { job list | length } catch { 0 })
            if $n > 0 { $"⚙ ($n)" } else { null }
        }
        "ssh" => (if (($env.SSH_CONNECTION? | default "") | is-not-empty) { "ssh" } else { null })
        "root" => (if (($env.USER? | default "") == "root") { "root" } else { null })
        "venv" => {
            let v = ($env.VIRTUAL_ENV? | default ($env.CONDA_DEFAULT_ENV? | default ""))
            if ($v | is-empty) { null } else { $"py:($v | path basename)" }
        }
        "nix" => (if (($env.IN_NIX_SHELL? | default "") | is-not-empty) { "nix" } else { null })
        "lang" => {
            let l = (lang-detect)
            if ($l | is-empty) { null } else {
                let args = (if $l == "go" { ["version"] } else if $l == "zig" { ["version"] } else { ["--version"] })
                let tool = (match $l { "python" => "python3", "rust" => "rustc", _ => $l })
                let v = (tool-version $tool $args)
                if ($v | is-empty) { $l } else { $"($l) ($v)" }
            }
        }
        "k8s" => {
            let cfg = ($env.KUBECONFIG? | default ($nu.home-dir | path join ".kube" "config") | split row (char esep) | first)
            if not ($cfg | path exists) { null } else {
                let ctx = (open --raw $cfg | lines | where {|l| $l | str starts-with "current-context:" } | get 0? | default "" | str replace "current-context:" "" | str trim)
                if ($ctx | is-empty) { null } else { $"k8s:($ctx)" }
            }
        }
        _ => null
    }
}

# Enabled modules as a colored, space-separated tail for single-line styles.
def module-inline [] {
    let p = $env.THEME_PALETTE
    let on = (enabled-modules)
    if ($on | is-empty) { return "" }
    $on | each {|m|
        let t = (module-text $m)
        if $t == null { null } else {
            let role = (module-defs | where name == $m | get 0.role)
            $"(ansi {fg: ($p | get $role)})($t)(ansi reset)"
        }
    } | compact | str join " "
}

# ── Segment engine ───────────────────────────────────────────
# A block segment is { text, bg }. `block-seg` resolves a segment id (user,
# host, path, git) to one — or null when it has nothing to show (e.g. git
# outside a repo) — and `render-blocks` draws the list in a given shape.
def block-seg [id: string, g: record] {
    let p = $env.THEME_PALETTE
    let ink = {|role| $p.inks? | default {} | get -o $role | default $p.ink }
    match $id {
        "user" => { text: (prompt-user), bg: $p.user, ink: (do $ink "user") }
        "host" => { text: (prompt-host), bg: $p.host, ink: (do $ink "host") }
        "path" => { text: ($env.PWD | str replace $nu.home-dir "~"), bg: $p.path, ink: (do $ink "path") }
        "git"  => (if $g.present { { text: (git-plain $g), bg: $p.git, ink: (do $ink "git") } } else { null })
        _ => {
            # context module (status, jobs, ssh, lang, …) — null when it has nothing to say
            let def = (module-defs | where name == $id | get 0?)
            if $def == null { null } else {
                let text = (module-text $id)
                if $text == null { null } else { { text: $text, bg: ($p | get $def.role), ink: (do $ink $def.role) } }
            }
        }
    }
}

# shape: "arrow" (powerline ), "slant" (), "pill" (rounded caps, gapped).
def render-blocks [shape: string, ids: list<string>] {
    let g = (git-info)
    let ids = ($ids | append (enabled-modules | where {|m| $m not-in $ids }))
    let segs = ($ids | each {|id| block-seg $id $g } | compact)
    if $shape == "pill" {
        let lc = (char --unicode e0b6)
        let rc = (char --unicode e0b4)
        return ($segs | each {|s|
            $"(ansi {fg: $s.bg})($lc)(ansi {bg: $s.bg fg: $s.ink attr: b}) ($s.text) (ansi reset)(ansi {fg: $s.bg})($rc)(ansi reset)"
        } | str join "  ")
    }
    let sep = (if $shape == "slant" { char --unicode e0b8 } else { char --unicode e0b0 })
    mut out = ""
    mut prev = null
    for s in $segs {
        if $prev != null { $out = $out + $"(ansi {fg: $prev bg: $s.bg})($sep)" }
        $out = $out + $"(ansi {bg: $s.bg fg: $s.ink attr: b}) ($s.text) "
        $prev = $s.bg
    }
    $"($out)(ansi reset)(ansi {fg: $prev})($sep)(ansi reset) "
}

# Left prompt: the style's layout, plus the user's enabled context modules
# as a tail for single-line styles (blocks styles fold them in as segments).
def create_left_prompt [] {
    let left = (render-left)
    let d = (style-def ($env.PROMPT_STYLE? | default "full"))
    if ($d.ctx? | default false) {
        let tail = (module-inline)
        if ($tail | is-not-empty) { return $"($left) ($tail)" }
    }
    $left
}

def render-left [] {
    let p = $env.THEME_PALETTE
    let style = ($env.PROMPT_STYLE? | default "full")
    let full_dir = ($env.PWD | str replace $nu.home-dir "~")

    # Data-driven styles: render straight from the registry row.
    let def = (style-def $style)
    if $def.kind == "blocks" { return (render-blocks $def.shape $def.segs) }

    match $style {
        "minimal" => {
            let dir = ($full_dir | path basename)
            $"(ansi {fg: $p.path attr: b})($dir)(ansi reset)(git-segment)"
        }
        "compact" => {
            let parts = ($full_dir | path split)
            let dir = if (($parts | length) > 2) { $"…/($parts | last 2 | path join)" } else { $full_dir }
            $"(ansi {fg: $p.path attr: b})($dir)(ansi reset)(git-segment --counts)"
        }
        "lambda" => {
            $"(ansi {fg: $p.git attr: b})λ (ansi {fg: $p.path attr: b})($full_dir)(ansi reset)(git-segment --counts)"
        }
        "pure" => {
            let g = (git-info)
            let git_txt = if $g.present {
                let dirty = if $g.clean { "" } else { $"(ansi {fg: $p.modified})*(ansi reset)" }
                $" (ansi {fg: $p.sep})($g.head)($dirty)(ansi reset)"
            } else { "" }
            $"(ansi {fg: $p.path attr: b})($full_dir)(ansi reset)($git_txt)\n"
        }
        "bracket" => {
            let g = (git-info)
            let git_txt = if $g.present { $" (ansi {fg: $p.git attr: b})[(git-plain $g)](ansi reset)" } else { "" }
            let uh = $"(ansi {fg: $p.user attr: b})[(prompt-user)@(prompt-host)](ansi reset)"
            let dir = $"(ansi {fg: $p.path attr: b})[($full_dir)](ansi reset)"
            $"($uh) ($dir)($git_txt)"
        }
        "boxed" => {
            let g = (git-info)
            let git_txt = if $g.present {
                let mark = if $g.clean { $"(ansi {fg: $p.ok})●(ansi reset)" } else { $"(ansi {fg: $p.modified})●(ansi reset)" }
                $" (ansi {fg: $p.sep})│ (ansi {fg: $p.git attr: b})(git-plain $g)(ansi reset) ($mark)"
            } else { "" }
            let uh = $"(ansi {fg: $p.user attr: b})(prompt-user)(ansi {fg: $p.sep})@(ansi {fg: $p.host})(prompt-host)(ansi reset)"
            let l1 = $"(ansi {fg: $p.sep})╭─ ($uh) (ansi {fg: $p.sep})in (ansi {fg: $p.path attr: b})($full_dir)(ansi reset)($git_txt)"
            let l2 = $"(ansi {fg: $p.sep})╰─(ansi reset)"
            $"($l1)\n($l2)"
        }
        "arrow" => {
            let g = (git-info)
            let sep = $"(ansi {fg: $p.sep}) » "
            let gitp = if $g.present { $"($sep)(ansi {fg: $p.git attr: b})(git-plain $g)(ansi reset)" } else { "" }
            $"(ansi {fg: $p.user attr: b})(prompt-user)(ansi reset)($sep)(ansi {fg: $p.path attr: b})($full_dir)(ansi reset)($gitp)"
        }
        "robbyrussell" => {
            # oh-my-zsh default:  ➜  dir git:(branch) ✗
            let g = (git-info)
            let okc = (if (($env.LAST_EXIT_CODE? | default 0) == 0) { $p.ok } else { $p.err })
            let arrow = $"(ansi {fg: $okc attr: b})➜(ansi reset)"
            let dir = $"(ansi {fg: $p.path attr: b})($full_dir | path basename)(ansi reset)"
            let git_txt = if $g.present { $" (git-omz $g)" } else { "" }
            $"($arrow)  ($dir)($git_txt)"
        }
        "ys" => {
            # informative dev one-liner:  # user @ host in ~/dir on ⎇ branch●
            let g = (git-info)
            let git_txt = if $g.present {
                let dirty = if $g.clean { "" } else { $"(ansi {fg: $p.err})●(ansi reset)" }
                $" (ansi {fg: $p.sep})on(ansi reset) (ansi {fg: $p.git attr: b})⎇ ($g.head)(ansi reset)($dirty)"
            } else { "" }
            $"(ansi {fg: $p.git attr: b})#(ansi reset) (ansi {fg: $p.user attr: b})(prompt-user)(ansi reset) (ansi {fg: $p.sep})@(ansi reset) (ansi {fg: $p.host attr: b})(prompt-host)(ansi reset) (ansi {fg: $p.sep})in(ansi reset) (ansi {fg: $p.path attr: b})($full_dir)(ansi reset)($git_txt)"
        }
        "avit" => {
            # clean two-line; time shows on the right prompt
            let g = (git-info)
            let git_txt = if $g.present { $"  (git-omz $g)" } else { "" }
            $"(ansi {fg: $p.path attr: b})($full_dir)(ansi reset)($git_txt)\n"
        }
        "bira" => {
            # two-line box:  ╭─user@host ~/dir git:(branch)  /  ╰─➤
            let g = (git-info)
            let uh = $"(ansi {fg: $p.user attr: b})(prompt-user)(ansi {fg: $p.sep})@(ansi {fg: $p.host attr: b})(prompt-host)(ansi reset)"
            let git_txt = if $g.present { $" (git-omz $g)" } else { "" }
            let l1 = $"(ansi {fg: $p.sep})╭─(ansi reset)($uh) (ansi {fg: $p.path attr: b})($full_dir)(ansi reset)($git_txt)"
            $"($l1)\n(ansi {fg: $p.sep})╰─(ansi reset)"
        }
        "af-magic" => {
            # a full-width rule, then user ~/dir git:(branch)
            let cols = (try { (term size).columns } catch { 80 })
            let bar = ("" | fill --width $cols --character "─")
            let g = (git-info)
            let git_txt = if $g.present { $"  (git-omz $g)" } else { "" }
            $"(ansi {fg: $p.sep})($bar)(ansi reset)\n(ansi {fg: $p.git attr: b})(prompt-user)(ansi reset) (ansi {fg: $p.path attr: b})($full_dir)(ansi reset)($git_txt)"
        }
        "cloud" => {
            # oh-my-zsh cloud:  ☁  ~/dir git:(branch)
            let g = (git-info)
            let git_txt = if $g.present { $"  (git-omz $g)" } else { "" }
            $"(ansi {fg: $p.ahead attr: b})☁(ansi reset)  (ansi {fg: $p.path attr: b})($full_dir)(ansi reset)($git_txt)"
        }
        "mario" => {
            # Two-line overworld: ▣ ?-block · ◆ hero · ⚑ flag · ◉ coins · ▲▼ pipes
            # · ✖ conflicts · ⬢ stash · ★ when clean, on a ▄ brick ground.
            let g = (git-info)
            let block = $"(ansi {fg: $p.modified attr: b})▣(ansi reset)"
            let hero  = $"(ansi {fg: $p.err attr: b})◆(ansi reset)"
            let dir   = $"(ansi {fg: $p.path attr: b})($full_dir)(ansi reset)"
            let git_txt = if $g.present {
                mut segs = [$"(ansi {fg: $p.ok attr: b})⚑ ($g.head)(ansi reset)"]
                let n = ($g.staged + $g.modified + $g.untracked)
                if $n > 0 {
                    $segs = ($segs | append $"(ansi {fg: $p.modified attr: b})◉×($n)(ansi reset)")
                } else {
                    $segs = ($segs | append $"(ansi {fg: $p.modified attr: b})★(ansi reset)")
                }
                if $g.ahead    > 0 { $segs = ($segs | append $"(ansi {fg: $p.ok})▲($g.ahead)(ansi reset)") }
                if $g.behind   > 0 { $segs = ($segs | append $"(ansi {fg: $p.behind})▼($g.behind)(ansi reset)") }
                if $g.conflict > 0 { $segs = ($segs | append $"(ansi {fg: $p.err attr: b})✖($g.conflict)(ansi reset)") }
                if $g.stash    > 0 { $segs = ($segs | append $"(ansi {fg: $p.stash})⬢($g.stash)(ansi reset)") }
                $"  ($segs | str join '  ')"
            } else { "" }
            let ground = $"(ansi {fg: $p.host})▄▄▄(ansi reset)"
            $"($block) ($hero) ($dir)($git_txt)\n($ground)"
        }
        "arcade" => {
            # retro all-caps score/1UP vibe
            let g = (git-info)
            let git_txt = if $g.present { $" (ansi {fg: $p.sep})‹(ansi {fg: $p.git attr: b})(git-plain $g)(ansi {fg: $p.sep})›(ansi reset)" } else { "" }
            $"(ansi {fg: $p.modified attr: b})▶ 1UP(ansi reset) (ansi {fg: $p.path attr: b})($full_dir)(ansi reset)($git_txt)"
        }
        "8bit" => {
            # pixel gradient separators ░▒▓
            let g = (git-info)
            let grad = $"(ansi {fg: $p.sep})░▒▓(ansi reset)"
            let gitp = if $g.present { $"($grad)(ansi {fg: $p.git attr: b})(git-plain $g)(ansi reset)" } else { "" }
            $"(ansi {fg: $p.user attr: b})(prompt-user)($grad)(ansi {fg: $p.path attr: b})($full_dir)(ansi reset)($gitp)"
        }
        "cyberpunk" => {
            let g = (git-info)
            let git_txt = if $g.present {
                $" (ansi {fg: $p.sep})─(ansi {fg: $p.git attr: b})▓ (git-plain $g)(ansi reset)"
            } else { "" }
            let bolt = $"(ansi {fg: $p.modified attr: b})⚡(ansi reset)"
            let uh = $"(ansi {fg: $p.user attr: b})❮(prompt-user)@(prompt-host)❯"
            let dir = $"(ansi {fg: $p.path attr: b})❮($full_dir)❯"
            let l1 = $"(ansi {fg: $p.sep})╭─($bolt)(ansi {fg: $p.sep})─($uh)(ansi {fg: $p.sep})─($dir)(ansi reset)($git_txt)"
            let l2 = $"(ansi {fg: $p.sep})╰─(ansi reset)"
            $"($l1)\n($l2)"
        }
        _ => {
            let user_host = $"(ansi {fg: $p.user})(prompt-user)(ansi {fg: $p.sep})@(ansi {fg: $p.host})(prompt-host)(ansi reset)"
            $"($user_host) (ansi {fg: $p.sep})in (ansi {fg: $p.path attr: b})($full_dir)(ansi reset)(git-segment --counts)"
        }
    }
}

def create_right_prompt [] {
    let p = $env.THEME_PALETTE
    let dur_ms = ($env.CMD_DURATION_MS? | default "0" | into int)
    let dur_seg = if $dur_ms > 2000 {
        let d = ($dur_ms * 1ms)
        $"(ansi {fg: $p.duration})took ($d)(ansi reset)  "
    } else { "" }
    let time = $"(ansi {fg: $p.time})(date now | format date '%H:%M:%S')(ansi reset)"
    if ($env.PROMPT_STYLE? | default "full") == "minimal" { $time } else { $"($dur_seg)($time)" }
}

# Indicator: style-aware glyph, turns red after a failed command.
def prompt-indicator [] {
    let p = $env.THEME_PALETTE
    let ok = (($env.LAST_EXIT_CODE? | default 0) == 0)
    let def = (style-def ($env.PROMPT_STYLE? | default "full"))
    let glyph = $def.glyph
    let color = if $ok { $p | get $def.tone } else { $p.err }
    $"(ansi {fg: $color attr: b})($glyph) (ansi reset)"
}

# ── Transient prompt ─────────────────────────────────────────
# Once you press Enter, the finished prompt collapses to a single colored
# glyph so scrollback stays clean (powerlevel10k / starship "transient").
# Uses Nushell's TRANSIENT_PROMPT_* variables. Toggle: `nuance transient`.
def transient-state-path [] { $nu.default-config-dir | path join "transient.txt" }
def transient-left [] {
    let p = $env.THEME_PALETTE
    let g = (style-def ($env.PROMPT_STYLE? | default "full")).glyph
    let glyph = if ($g | is-empty) { "❯" } else { $g }
    $"(ansi {fg: $p.ok attr: b})($glyph) (ansi reset)"
}
def --env transient-apply [mode: string] {
    if $mode == "on" {
        $env.TRANSIENT_PROMPT_COMMAND = { || transient-left }
        $env.TRANSIENT_PROMPT_INDICATOR = { || "" }
        $env.TRANSIENT_PROMPT_INDICATOR_VI_INSERT = { || "" }
        $env.TRANSIENT_PROMPT_COMMAND_RIGHT = { || "" }
        $env.NUANCE_TRANSIENT = "on"
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
$env.PROMPT_INDICATOR_VI_NORMAL = { || $"(ansi {fg: $env.THEME_PALETTE.err attr: b})❮ (ansi reset)" }
$env.PROMPT_MULTILINE_INDICATOR = { || $"(ansi {fg: $env.THEME_PALETTE.sep})::: (ansi reset)" }
