# nushell-prompt.nu — nuance: themeable, git-aware Nushell prompt
# https://github.com/sorinirimies/nuance
# Single self-contained file. Drop into your Nushell autoload dir.
#
# GENERATED from nu/*.nu by scripts/build_prompt.nu — edit those files, then
# run `just build-prompt` (test.nu fails if this file is stale).

# ── color themes ─────────────────────────────────────────────
# (part of nushell-prompt)
#
# Exposes:
#   theme-list         -> list of available theme names
#   theme-get <name>   -> { color_config: {...}, palette: {...} }
#
# `color_config` plugs into `$env.config.color_config`.
# `palette` supplies accent colors for the custom prompt (see `create_left_prompt`).

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

# More themes — name → palette (same shape as the consts above), rendered via
# the shared basic-color-config / basic-prompt-palette builders.
const EXTRA_THEMES = {
    "tokyo-night-storm": {
        fg: "#c0caf5", gray: "#565f89", red: "#f7768e", orange: "#ff9e64"
        yellow: "#e0af68", green: "#9ece6a", cyan: "#7dcfff", blue: "#7aa2f7"
        magenta: "#bb9af7", purple: "#9d7cd8", bg: "#24283b"
    }
    "tokyo-night-moon": {
        fg: "#c8d3f5", gray: "#636da6", red: "#ff757f", orange: "#ff966c"
        yellow: "#ffc777", green: "#c3e88d", cyan: "#86e1fc", blue: "#82aaff"
        magenta: "#c099ff", purple: "#fca7ea", bg: "#222436"
    }
    "tokyo-night-day": {
        fg: "#3760bf", gray: "#848cb5", red: "#f52a65", orange: "#b15c00"
        yellow: "#8c6c3e", green: "#587539", cyan: "#007197", blue: "#2e7de9"
        magenta: "#9854f1", purple: "#7847bd", bg: "#e1e2e7"
    }
    "gruvbox-light": {
        fg: "#3c3836", gray: "#7c6f64", red: "#9d0006", orange: "#af3a03"
        yellow: "#b57614", green: "#79740e", cyan: "#427b58", blue: "#076678"
        magenta: "#8f3f71", purple: "#8f3f71", bg: "#fbf1c7"
    }
    "gruvbox-material": {
        fg: "#d4be98", gray: "#928374", red: "#ea6962", orange: "#e78a4e"
        yellow: "#d8a657", green: "#a9b665", cyan: "#89b482", blue: "#7daea3"
        magenta: "#d3869b", purple: "#d3869b", bg: "#282828"
    }
    "nightfox": {
        fg: "#cdcecf", gray: "#738091", red: "#c94f6d", orange: "#f4a261"
        yellow: "#dbc074", green: "#81b29a", cyan: "#63cdcf", blue: "#719cd6"
        magenta: "#9d79d6", purple: "#9d79d6", bg: "#192330"
    }
    "dawnfox": {
        fg: "#575279", gray: "#a8a3b3", red: "#b4637a", orange: "#d7827e"
        yellow: "#ea9d34", green: "#618774", cyan: "#56949f", blue: "#286983"
        magenta: "#907aa9", purple: "#907aa9", bg: "#faf4ed"
    }
    "kanagawa-dragon": {
        fg: "#c5c9c5", gray: "#727169", red: "#c4746e", orange: "#b6927b"
        yellow: "#c4b28a", green: "#8a9a7b", cyan: "#8ea4a2", blue: "#8ba4b0"
        magenta: "#a292a3", purple: "#8992a7", bg: "#181616"
    }
    "kanagawa-lotus": {
        fg: "#545464", gray: "#8a8980", red: "#c84053", orange: "#cc6d00"
        yellow: "#77713f", green: "#6f894e", cyan: "#597b75", blue: "#4d699b"
        magenta: "#b35b79", purple: "#624c83", bg: "#f2ecbc"
    }
    "flexoki": {
        fg: "#cecdc3", gray: "#878580", red: "#d14d41", orange: "#da702c"
        yellow: "#d0a215", green: "#879a39", cyan: "#3aa99f", blue: "#4385be"
        magenta: "#ce5d97", purple: "#8b7ec8", bg: "#100f0f"
    }
    "flexoki-light": {
        fg: "#100f0f", gray: "#6f6e69", red: "#af3029", orange: "#bc5215"
        yellow: "#ad8301", green: "#66800b", cyan: "#24837b", blue: "#205ea6"
        magenta: "#a02f6f", purple: "#5e409d", bg: "#fffcf0"
    }
    "melange": {
        fg: "#ece1d7", gray: "#867462", red: "#d47766", orange: "#e49b5d"
        yellow: "#ebc06d", green: "#78997a", cyan: "#7b9695", blue: "#7f91b2"
        magenta: "#b380b0", purple: "#b380b0", bg: "#292522"
    }
    "nightfly": {
        fg: "#bdc1c6", gray: "#7c8f8f", red: "#fc514e", orange: "#f78c6c"
        yellow: "#e3d18a", green: "#a1cd5e", cyan: "#7fdbca", blue: "#82aaff"
        magenta: "#c792ea", purple: "#ae81ff", bg: "#011627"
    }
    "material-palenight": {
        fg: "#a6accd", gray: "#676e95", red: "#f07178", orange: "#f78c6c"
        yellow: "#ffcb6b", green: "#c3e88d", cyan: "#89ddff", blue: "#82aaff"
        magenta: "#c792ea", purple: "#c792ea", bg: "#292d3e"
    }
    "tomorrow-night": {
        fg: "#c5c8c6", gray: "#969896", red: "#cc6666", orange: "#de935f"
        yellow: "#f0c674", green: "#b5bd68", cyan: "#8abeb7", blue: "#81a2be"
        magenta: "#b294bb", purple: "#b294bb", bg: "#1d1f21"
    }
    "snazzy": {
        fg: "#eff0eb", gray: "#686868", red: "#ff5c57", orange: "#ff9f43"
        yellow: "#f3f99d", green: "#5af78e", cyan: "#9aedfe", blue: "#57c7ff"
        magenta: "#ff6ac1", purple: "#bd93f9", bg: "#282a36"
    }
    "iceberg": {
        fg: "#c6c8d1", gray: "#6b7089", red: "#e27878", orange: "#e2a478"
        yellow: "#e9b189", green: "#b4be82", cyan: "#89b8c2", blue: "#84a0c6"
        magenta: "#a093c7", purple: "#a093c7", bg: "#161821"
    }
    "one-light": {
        fg: "#383a42", gray: "#a0a1a7", red: "#e45649", orange: "#986801"
        yellow: "#c18401", green: "#50a14f", cyan: "#0184bc", blue: "#4078f2"
        magenta: "#a626a4", purple: "#a626a4", bg: "#fafafa"
    }
    "papercolor-light": {
        fg: "#444444", gray: "#878787", red: "#af0000", orange: "#d75f00"
        yellow: "#d78700", green: "#008700", cyan: "#0087af", blue: "#005f87"
        magenta: "#8700af", purple: "#8700af", bg: "#eeeeee"
    }
    "synthwave-84": {
        fg: "#ffffff", gray: "#848bbd", red: "#fe4450", orange: "#f97e72"
        yellow: "#fede5d", green: "#72f1b8", cyan: "#03edf9", blue: "#36f9f6"
        magenta: "#ff7edb", purple: "#b893ce", bg: "#262335"
    }
    "cobalt2": {
        fg: "#e1efff", gray: "#6f8fa3", red: "#ff628c", orange: "#ff9d00"
        yellow: "#ffc600", green: "#3ad900", cyan: "#80ffbb", blue: "#0088ff"
        magenta: "#fb94ff", purple: "#9a5feb", bg: "#193549"
    }
    "modus-vivendi": {
        fg: "#ffffff", gray: "#989898", red: "#ff5f59", orange: "#ef8b50"
        yellow: "#d0bc00", green: "#44bc44", cyan: "#00d3d0", blue: "#2fafff"
        magenta: "#feacd0", purple: "#b6a0ff", bg: "#000000"
    }
    "modus-operandi": {
        fg: "#000000", gray: "#595959", red: "#a60000", orange: "#884900"
        yellow: "#6f5500", green: "#006800", cyan: "#00538b", blue: "#0031a9"
        magenta: "#721045", purple: "#531ab6", bg: "#ffffff"
    }
    "horizon": {
        fg: "#d5d8da", gray: "#6c6f93", red: "#e95678", orange: "#fab795"
        yellow: "#fac29a", green: "#29d398", cyan: "#59e1e3", blue: "#26bbd9"
        magenta: "#ee64ac", purple: "#b877db", bg: "#1c1e26"
    }
    "sonokai": {
        fg: "#e2e2e3", gray: "#7f8490", red: "#fc5d7c", orange: "#f39660"
        yellow: "#e7c664", green: "#9ed072", cyan: "#76cce0", blue: "#7ec8e3"
        magenta: "#b39df3", purple: "#b39df3", bg: "#2c2e34"
    }
    # Clair Obscur: Expedition 33 — Belle Époque night: ink-black blue, parchment, gold, Gommage crimson, Lumina cyan.
    "clair-obscur": {
        fg: "#e9dfc7", gray: "#5d6178", red: "#d4343f", orange: "#d98a3d"
        yellow: "#e3b95a", green: "#8fae8b", cyan: "#7fd0e0", blue: "#4a78c2"
        magenta: "#c9708a", purple: "#8a6bbf", bg: "#0b0d17"
    }
    # Clair Obscur — the Paintress's canvas: parchment ground, dark ink, oil-paint reds and golds (light).
    "clair-obscur-canvas": {
        fg: "#2b2433", gray: "#8a7f72", red: "#a3212c", orange: "#b4601f"
        yellow: "#8c6a12", green: "#4d6b4a", cyan: "#2a6f80", blue: "#2a4f8f"
        magenta: "#8f3b58", purple: "#5e3f8c", bg: "#efe4cc"
    }
    # Super Mario overworld — daytime sky, pipe green, Mario red (light).
    "mario-overworld": {
        fg: "#14173d", gray: "#5b6a8a", red: "#c4161c", orange: "#b85c00"
        yellow: "#8a6a00", green: "#1c7a2a", cyan: "#00738f", blue: "#0b4fa8"
        magenta: "#a1307a", purple: "#5a3da8", bg: "#a6d8ff"
    }
    # Super Mario underground — black cave, blue bricks, coin gold.
    "mario-underground": {
        fg: "#e8f0ff", gray: "#5a6a9a", red: "#ff4d3d", orange: "#f89b3a"
        yellow: "#fcd23a", green: "#3fd16a", cyan: "#3ee0e8", blue: "#3b7bff"
        magenta: "#ff6fc8", purple: "#8f7bff", bg: "#02030f"
    }
    # Fallout Pip-Boy — phosphor green terminal (amber for alerts).
    "pip-boy": {
        fg: "#46ff90", gray: "#1f8f55", red: "#ff8a3d", orange: "#c8ff4d"
        yellow: "#e6ff7a", green: "#3dff8a", cyan: "#6dffd0", blue: "#29d97a"
        magenta: "#9dffb0", purple: "#7fe0a0", bg: "#031208"
    }
    # Elden Ring — Site-of-Grace gold on the Lands Between's gloom.
    "tarnished": {
        fg: "#e6d8b0", gray: "#6f654f", red: "#a63a2f", orange: "#c77f2e"
        yellow: "#e3b24a", green: "#7a8c52", cyan: "#7fa8a0", blue: "#5d7690"
        magenta: "#9c5f6e", purple: "#77608f", bg: "#0e0c09"
    }
    # Zelda — Hyrule field green, Triforce gold, Sheikah blue.
    "hyrule": {
        fg: "#e8e2c4", gray: "#5f7060", red: "#d6453a", orange: "#e08a2c"
        yellow: "#f2d04a", green: "#6fbf5b", cyan: "#5ed1c7", blue: "#4aa3d6"
        magenta: "#c06fa8", purple: "#8a78c8", bg: "#0f1a14"
    }
    # DOOM — hellfire red/orange, armor green, rusted steel.
    "doom": {
        fg: "#d9cfc4", gray: "#6a5f58", red: "#e5251c", orange: "#ff7a1a"
        yellow: "#ffc21a", green: "#4aa83a", cyan: "#3aa5a0", blue: "#4a6ea8"
        magenta: "#b0407a", purple: "#7a4a9a", bg: "#120c0b"
    }
    # Heist: black, signal red, stage-light white.
    "phantom": {
        fg: "#f2f2f2", gray: "#6b6b6b", red: "#e60012", orange: "#ff5a36"
        yellow: "#ffd400", green: "#4ad06a", cyan: "#3fd0ff", blue: "#2f6bff"
        magenta: "#ff2a8a", purple: "#8a3fff", bg: "#0a0a0a"
    }
    # Cavern hush: deep blue-black, pale bone, soul-light cyan.
    "cavern-hush": {
        fg: "#dfe7ef", gray: "#4a5568", red: "#c8505a", orange: "#d0905a"
        yellow: "#d8c58a", green: "#7fb7a4", cyan: "#9ee6f0", blue: "#5b7bb5"
        magenta: "#a58ac0", purple: "#7a6aa8", bg: "#080b14"
    }
    # Test chamber: clinical white-on-slate with orange and blue portals.
    "test-chamber": {
        fg: "#e9edf2", gray: "#5d6773", red: "#ff4b4b", orange: "#ff9a1f"
        yellow: "#ffd24a", green: "#5ed17a", cyan: "#3ec3ff", blue: "#1d8cff"
        magenta: "#d57bff", purple: "#8e7bff", bg: "#12151a"
    }
    # Ember: ash grey, bonfire orange, bone.
    "ember": {
        fg: "#d8cfc2", gray: "#6a6158", red: "#b5382d", orange: "#e0782a"
        yellow: "#d9a441", green: "#7c8a5b", cyan: "#6d9a9a", blue: "#5f7691"
        magenta: "#94616e", purple: "#75618a", bg: "#0d0b0a"
    }
    # Meadow: warm cream paper, soil brown, leaf green (light).
    "meadow": {
        fg: "#4a3b2a", gray: "#9a8a70", red: "#b8433a", orange: "#c4742a"
        yellow: "#a8821c", green: "#4f7a3a", cyan: "#2f7f87", blue: "#3e6fa8"
        magenta: "#a2566e", purple: "#7a5a9a", bg: "#f6efdc"
    }
    # Dojo: arcade black with fighter-select primaries.
    "dojo": {
        fg: "#f1f1f1", gray: "#66666e", red: "#e8222a", orange: "#ff8a1f"
        yellow: "#ffe033", green: "#35c759", cyan: "#3ac7ff", blue: "#2f6fe8"
        magenta: "#ff3d9a", purple: "#8a4dff", bg: "#0f0f14"
    }
    # Underworld: wine-black, laurel gold, blood red.
    "underworld": {
        fg: "#ecdcc8", gray: "#6b5a66", red: "#e0352b", orange: "#f08a3a"
        yellow: "#f5c04a", green: "#6fbf8a", cyan: "#6ad5d0", blue: "#5a7fd6"
        magenta: "#d86aa0", purple: "#9a5fd0", bg: "#120b12"
    }
    # Summit: twilight indigo with berry pink and glacier blue.
    "summit": {
        fg: "#eae6ff", gray: "#6d6a8f", red: "#ff5c7c", orange: "#ff9e5e"
        yellow: "#ffe36e", green: "#7ee8a2", cyan: "#6ad8ff", blue: "#6d8cff"
        magenta: "#ff7ad9", purple: "#a07bff", bg: "#1c1b2e"
    }
    # Rain noir: wet-asphalt greys, streetlamp amber.
    "rain-noir": {
        fg: "#d9d4c7", gray: "#5f6670", red: "#b24a3a", orange: "#cf8a3a"
        yellow: "#d4b24e", green: "#6f9a7c", cyan: "#5aa3a8", blue: "#5a7fa8"
        magenta: "#a06a86", purple: "#7e6c9a", bg: "#14171c"
    }
    # Blocky: grass green, dirt brown, stone grey, gem cyan.
    "blocky": {
        fg: "#e9e6df", gray: "#6f6a60", red: "#d9443a", orange: "#e08a2c"
        yellow: "#f3d04a", green: "#5fb23a", cyan: "#4de3dc", blue: "#3d62d6"
        magenta: "#d26ad6", purple: "#9a5fd0", bg: "#12100d"
    }
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

