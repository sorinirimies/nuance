# ── User themes (nuance import …) ─────────────────────────────
# One .nuon file per theme in <config>/nuance/themes (override the directory
# with $env.NUANCE_THEMES_DIR). Same 11-color shape as the consts above.
def user-themes-dir [] {
    $env.NUANCE_THEMES_DIR? | default ((nuance-config-dir) | path join "nuance" "themes")
}
def user-theme-names [] {
    let dir = (user-themes-dir)
    if not ($dir | path exists) { return [] }
    let taken = ((theme-list-builtin) ++ ($EXTRA_THEMES | columns))
    ls $dir | where name =~ '\.nuon$' | get name | each {|f| $f | path parse | get stem } | where {|n| $n not-in $taken } | sort
}
def user-theme-load [name: string] { open (user-themes-dir | path join $"($name).nuon") }

# Every available theme: built-ins, then the extra set, then imported ones.
def theme-list [] {
    (theme-list-builtin) ++ ($EXTRA_THEMES | columns) ++ (user-theme-names)
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
        _ if ($name in ($EXTRA_THEMES | columns)) => {
            let c = ($EXTRA_THEMES | get $name)
            { color_config: (basic-color-config $c) palette: (basic-prompt-palette $c) }
        }
        _ if ($name in (user-theme-names)) => {
            let c = (user-theme-load $name)
            { color_config: (basic-color-config $c) palette: (basic-prompt-palette $c) }
        }
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
# Theme system  (definitions live above, in this same file)
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
def theme-state-path [] { (nuance-config-dir) | path join "current-theme.txt" }

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
    let rendered = (left-prompt-core)
    $env.THEME_PALETTE = $saved
    let w = (theme-list | each { str length } | math max)
    $"($name | fill --alignment left --width $w)  →  ($rendered)"
}

def --env theme-picker-items [] {
    $env.NUANCE_GIT = (git-info)
    let items = ([(sync-picker-item)] ++ (theme-list | each {|n| { label: (theme-label $n), key: $n } }))
    hide-env NUANCE_GIT
    $items
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
# ── Appearance (dark/light) theme pair ───────────────────────
# `nuance appearance <dark-theme> <light-theme>` follows the OS appearance when
# a shell starts (or on `reload-theme`).
def appearance-path [] { (nuance-config-dir) | path join "appearance.txt" }
def appearance-theme [] {
    let c = (try { open (appearance-path) | str trim | split row "," } catch { [] })
    if ($c | length) != 2 { return null }
    let name = (if (os-dark-mode) { $c.0 } else { $c.1 })
    if $name in (theme-list) { $name } else { null }
}
# Which theme to start with, given the saved state.
def pick-theme-name [saved: string] {
    if $saved == "appearance" {
        let t = (appearance-theme)
        if $t != null { return $t }
    }
    if $saved in (theme-list) { return $saved }
    let g = (ghostty-theme-name)
    if ($g | is-not-empty) { $g } else { "gruvbox" }
}
def --env reload-theme [] {
    theme-apply (pick-theme-name (try { open (theme-state-path) | str trim } catch { "auto" }))
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
def --env theme [name?: string@"nu-complete nuance themes"] {
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
        { name: "storm-devbar", theme: "tokyo-night-storm", style: "devbar" }
        { name: "moon-pills", theme: "tokyo-night-moon", style: "pills" }
        { name: "day-agnoster", theme: "tokyo-night-day", style: "agnoster" }
        { name: "gruvbox-light-pure", theme: "gruvbox-light", style: "pure" }
        { name: "palenight-powerline", theme: "material-palenight", style: "powerline" }
        { name: "nightfox-skyline", theme: "nightfox", style: "skyline" }
        { name: "dawnfox-compact", theme: "dawnfox", style: "compact" }
        { name: "synthwave84-capsule", theme: "synthwave-84", style: "capsule" }
        { name: "flexoki-lambda", theme: "flexoki", style: "lambda" }
        { name: "melange-arrow", theme: "melange", style: "arrow" }
        { name: "snazzy-rainbow", theme: "snazzy", style: "rainbow" }
        { name: "modus-pure", theme: "modus-vivendi", style: "pure" }
        { name: "expedition-33", theme: "clair-obscur", style: "expedition33" }
        { name: "gommage", theme: "clair-obscur", style: "gommage" }
        { name: "canvas-33", theme: "clair-obscur-canvas", style: "expedition33" }
        { name: "mario-world", theme: "mario-overworld", style: "mario" }
        { name: "mario-underground", theme: "mario-underground", style: "mario" }
        { name: "vault-111", theme: "pip-boy", style: "vault" }
        { name: "tarnished", theme: "tarnished", style: "grace" }
        { name: "hyrule", theme: "hyrule", style: "triforce" }
        { name: "doom", theme: "doom", style: "doomguy" }
        { name: "spaceship-nord", theme: "nord", style: "spaceship" }
        { name: "p10k-tokyo", theme: "tokyo-night", style: "p10k-lean" }
        { name: "fish-gruvbox", theme: "gruvbox", style: "fish" }
        { name: "steeef-mocha", theme: "catppuccin-mocha", style: "steeef" }
        { name: "fino-dracula", theme: "dracula", style: "fino" }
        { name: "onedark-twoline", theme: "onedark", style: "powerline2l" }
        { name: "rosepine-pills2l", theme: "rose-pine", style: "pills2l" }
        { name: "phantom", theme: "phantom", style: "heist" }
        { name: "cavern", theme: "cavern-hush", style: "vessel" }
        { name: "test-chamber", theme: "test-chamber", style: "portals" }
        { name: "ember", theme: "ember", style: "bonfire" }
        { name: "farmstead", theme: "meadow", style: "farmstead" }
        { name: "dojo", theme: "dojo", style: "versus" }
        { name: "underworld", theme: "underworld", style: "boons" }
        { name: "summit", theme: "summit", style: "climb" }
        { name: "rain-noir", theme: "rain-noir", style: "skillcheck" }
        { name: "blocky", theme: "blocky", style: "hotbar" }
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
    let rendered = (left-prompt-core)
    $env.THEME_PALETTE = $saved_p
    $env.PROMPT_STYLE = $saved_s
    $rendered
}

def --env look-picker-items [] {
    let ps = (presets)
    let w = ($ps | get name | each { str length } | math max)
    $env.NUANCE_GIT = (git-info)
    let items = ($ps | each {|r| { label: $"($r.name | fill --alignment left --width $w)  →  (look-label $r.theme $r.style)", key: $r.name } })
    hide-env NUANCE_GIT
    $items
}

# Pick a full look (theme + prompt style). No arg = interactive picker
# (delegates to the `nuance` ratatui picker when available).
def --env look [name?: string@"nu-complete nuance looks"] {
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
        print (left-prompt-core)
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
    print "  nuance configure             guided setup (look, transient, modules)"
    print "  nuance doctor                check fonts, truecolor, install, state"
    print "  nuance import <file|name>    import a ghostty/kitty/alacritty/base16 theme"
    print "  nuance here [theme [style]]  pin a theme to this directory tree (.nuance)"
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
def --env "nuance theme" [name?: string@"nu-complete nuance themes"] { theme $name }

# `nuance prompt-style` — same as bare `prompt-style`.
def --env "nuance prompt-style" [name?: string@"nu-complete nuance styles"] { prompt-style $name }

# `nuance look` — same as bare `look`.
def --env "nuance look" [name?: string@"nu-complete nuance looks"] { look $name }

# `nuance transient [on|off|toggle]` — collapse finished prompts to one glyph.
def --env "nuance transient" [mode?: string@"nu-complete nuance transient"] {
    let cur = ($env.NUANCE_TRANSIENT? | default "off")
    let next = match ($mode | default "") {
        "" => { print $"transient prompt: (ansi attr_bold)($cur)(ansi reset)  \(nuance transient on|dir|off|toggle\)"; return }
        "toggle" => (if $cur == "on" { "off" } else { "on" })
        "on" | "off" | "dir" => $mode
        _ => { print $"(ansi red)unknown mode:(ansi reset) ($mode)  — use on, dir, off or toggle"; return }
    }
    transient-apply $next
    $next | save -f (transient-state-path)
    print $"(ansi green_bold)✓(ansi reset) transient prompt (ansi attr_bold)($next)(ansi reset)"
}

# `nuance here [theme [style]] | clear` — pin a theme/style to this directory tree.
def "nuance here" [theme?: string@"nu-complete nuance themes", style?: string@"nu-complete nuance styles"] {
    let f = ($env.PWD | path join ".nuance")
    if $theme == null {
        let found = (dir-config-find)
        if $found == null {
            print "no .nuance here — create one with: nuance here <theme> [style]"
        } else {
            print $"(ansi attr_bold)($found)(ansi reset)"
            print (open --raw $found)
        }
        return
    }
    if $theme == "clear" {
        if ($f | path exists) { rm -f $f; print $"(ansi green_bold)✓(ansi reset) removed ($f)" } else { print "nothing to clear" }
        return
    }
    if $theme not-in (theme-list) { print $"(ansi red)unknown theme:(ansi reset) ($theme)"; return }
    if $style != null and $style not-in (prompt-styles) { print $"(ansi red)unknown style:(ansi reset) ($style)"; return }
    let cfg = ({ theme: $theme } | merge (if $style != null { { style: $style } } else { {} }))
    $cfg | to toml | save -f $f
    print $"(ansi green_bold)✓(ansi reset) wrote ($f) — prompt in this tree now uses (ansi attr_bold)($theme)(ansi reset)(if $style != null { $' + ($style)' } else { '' })"
}

# `nuance configure` — guided setup: look (or theme + style), transient prompt, modules.
def --env "nuance configure" [] {
    print $"(ansi green_bold)nuance setup(ansi reset) — Esc cancels a step"
    let items = (look-picker-items)
    let skip = "(skip — choose theme and style separately)"
    let pick = ($items | get label | prepend $skip | input list --fuzzy "1/4  start from a look")
    if ($pick | is-empty) { print "cancelled."; return }
    if $pick == $skip {
        theme
        prompt-style
    } else {
        let key = ($items | where label == $pick | get 0.key)
        look $key
    }
    let tr = (["off — keep every prompt" "on — collapse finished prompts to one glyph"] | input list "2/4  transient prompt")
    if ($tr | is-not-empty) {
        let mode = (if ($tr | str starts-with "on") { "on" } else { "off" })
        transient-apply $mode
        $mode | save -f (transient-state-path)
    }
    let opts = (module-defs | each {|m| $"($m.name | fill --width 7)  ($m.desc)" })
    let chosen = ($opts | input list --multi "3/4  extra segments (space toggles, enter confirms)")
    if $chosen != null {
        let names = ($chosen | each {|l| $l | split row " " | first })
        $env.NUANCE_MODULES = $names
        $names | str join "\n" | save -f (modules-state-path)
    }
    print $"(ansi green_bold)4/4  done(ansi reset) — theme (ansi attr_bold)($env.THEME_NAME? | default '?')(ansi reset), style (ansi attr_bold)($env.PROMPT_STYLE)(ansi reset), transient (ansi attr_bold)($env.NUANCE_TRANSIENT)(ansi reset), modules (ansi attr_bold)(if (enabled-modules | is-empty) { 'none' } else { enabled-modules | str join ', ' })(ansi reset)"
}

# Doctor row for the autoload file: is nuance installed where Nushell loads it?
# Show a path with the home directory as ~ (macOS reports /tmp and /private/tmp
# for the same place, so compare without a leading /private).
def tilde [path: string, home?: string] {
    let strip = {|x| $x | str replace --regex '^/private(/|$)' '$1' }
    let h = (do $strip ($home | default $nu.home-dir))
    let q = (do $strip $path)
    if ($q == $h) { "~" } else if ($q | str starts-with $"($h)/") { $"~($q | str replace $h '')" } else { $path }
}
def doctor-autoload [path: string] {
    if ($path | path exists) {
        let note = (if (($path | path type) == "symlink") { " (symlink to a git checkout)" } else { "" })
        { check: "autoload file", status: "ok", detail: $"(tilde $path)($note)" }
    } else {
        { check: "autoload file", status: "warn", detail: $"(tilde $path) is missing - run `nuance sync`, which installs it, or the installer" }
    }
}

# `nuance doctor` — check the environment nuance depends on.
def "nuance doctor" [--clear-errors] {
    if $clear_errors {
        rm -f ((nuance-cache-dir) | path join "last-error.txt") (slow-git-path)
        print $"(ansi green_bold)✓(ansi reset) cleared the last prompt error and slow-repo marks"
    }
    let nu_ver = (version | get version)
    let minor = ($nu_ver | split row "." | get 1 | into int)
    let autoload = ($nu.user-autoload-dirs | get 0? | default "" | path join "nushell-prompt.nu")
    let glyphs = ([e0b0 e0b6 e0b4 f126 e725] | each {|c| char --unicode $c } | str join " ")
    let ghostty = (try { ghostty-theme-name } catch { null })
    let saved_theme = (try { open (theme-state-path) | str trim } catch { "auto" })
    let local = (dir-config-find)
    let le = ((nuance-cache-dir) | path join "last-error.txt")
    let err_row = (if ($le | path exists) { { check: "last prompt error", status: "warn", detail: (open --raw $le | str trim) } } else { { check: "last prompt error", status: "ok", detail: "none" } })
    [
        { check: "nushell version", status: (if $minor >= 100 { "ok" } else { "warn" }), detail: $"($nu_ver)(if $minor < 100 { ' — transient prompt needs 0.100+' } else { '' })" }
        { check: "truecolor", status: (if (($env.COLORTERM? | default "") in ["truecolor" "24bit"]) { "ok" } else { "warn" }), detail: (if (($env.COLORTERM? | default "") in ["truecolor" "24bit"]) { "COLORTERM is set" } else { "COLORTERM not truecolor/24bit — theme colors may be approximated" }) }
        { check: "nerd font", status: "info", detail: $"glyph sample: ($glyphs)  — boxes? install a Nerd Font or set $env.PROMPT_NERD = false" }
        (doctor-autoload $autoload)
        { check: "git", status: (if (which git | is-empty) { "warn" } else { "ok" }), detail: (if (which git | is-empty) { "git not found — git segment disabled" } else { "found" }) }
        { check: "nuance cli", status: (if (nuance-cli-available) { "ok" } else { "info" }), detail: (if (nuance-cli-available) { "on PATH (ratatui pickers)" } else { "not on PATH — pickers fall back to `input list` (cargo install nuance-cli)" }) }
        { check: "theme", status: "info", detail: $"($env.THEME_NAME? | default 'unknown') \((if $saved_theme == 'auto' { 'auto-follow' } else { 'pinned' }))" }
        { check: "prompt style", status: "info", detail: ($env.PROMPT_STYLE? | default "full") }
        { check: "transient prompt", status: "info", detail: ($env.NUANCE_TRANSIENT? | default "off") }
        { check: "modules", status: "info", detail: (if (enabled-modules | is-empty) { "none enabled" } else { enabled-modules | str join ", " }) }
        { check: "terminal theme", status: "info", detail: (if ($ghostty | is-empty) { "no Ghostty theme detected" } else { $"Ghostty → ($ghostty)" }) }
        { check: "imported themes", status: "info", detail: $"(user-theme-names | length) in (tilde (user-themes-dir))" }
        { check: "colors", status: (if (color-mode) == "truecolor" { "ok" } else { "info" }), detail: $"(color-mode)(if (color-mode) != 'truecolor' { ' — theme colors are downgraded for this terminal' } else { '' })" }
        { check: "terminal integration", status: "info", detail: $"($env.NUANCE_INTEGRATION? | default 'on') \(window title, cwd, semantic prompt marks)" }
        { check: "git mode", status: "info", detail: $"($env.PROMPT_GIT? | default 'full')(if (slow-git-path | path exists) { ' — some repos are marked slow (-uno)' } else { '' })" }
        { check: "custom styles", status: "info", detail: $"(user-style-defs | length) in (tilde (user-styles-dir))" }
        $err_row
        { check: ".nuance override", status: "info", detail: (if $local == null { "none for this directory" } else { tilde $local }) }
    ]
}

# `nuance list [themes|styles|looks|modules]` — what is available (data, so `| to json` works).
def "nuance list" [kind?: string@"nu-complete nuance kinds"] {
    match ($kind | default "themes") {
        "themes" => (theme-list | each {|t| { name: $t, light: ((lum (theme-get-raw $t).palette.bg) > 0.4) } })
        "styles" => (style-defs | each {|d| { name: $d.name, kind: $d.kind, nerd_font: $d.nerd, description: $d.desc } })
        "looks" => (presets | select name theme style)
        "modules" => (module-defs | select name desc)
        _ => { print $"(ansi red)unknown kind:(ansi reset) ($kind) — use themes, styles, looks or modules"; [] }
    }
}

# `nuance current` — the active theme, style and options.
def "nuance current" [] {
    {
        theme: ($env.THEME_NAME? | default "unknown")
        style: ($env.PROMPT_STYLE? | default "full")
        transient: ($env.NUANCE_TRANSIENT? | default "off")
        modules: (enabled-modules)
        integration: ($env.NUANCE_INTEGRATION? | default "on")
        colors: (color-mode)
        git: ($env.PROMPT_GIT? | default "full")
    }
}

# `nuance preview [theme [style]]` — render a prompt without applying anything.
def "nuance preview" [theme?: string@"nu-complete nuance themes", style?: string@"nu-complete nuance styles"] {
    let t = ($theme | default ($env.THEME_NAME? | default "gruvbox"))
    let st = ($style | default ($env.PROMPT_STYLE? | default "full"))
    if $t not-in (theme-list) { print $"(ansi red)unknown theme:(ansi reset) ($t)"; return }
    if $st not-in (prompt-styles) { print $"(ansi red)unknown style:(ansi reset) ($st)"; return }
    with-env { THEME_PALETTE: (theme-get $t).palette, PROMPT_STYLE: $st, LAST_EXIT_CODE: 0 } {
        finalize $"(left-prompt-core)(indicator-core)"
    }
}

# `nuance random [look|theme|style]` — surprise me (and pin the pick).
def --env "nuance random" [what?: string@"nu-complete nuance random"] {
    let pick = {|xs| $xs | get (random int 0..<($xs | length)) }
    match ($what | default "look") {
        "look" => { look (do $pick (presets | get name)) }
        "theme" => { theme (do $pick (theme-list)) }
        "style" => { prompt-style (do $pick (prompt-styles)) }
        _ => { print $"(ansi red)unknown:(ansi reset) ($what) — use look, theme or style" }
    }
}

# `nuance appearance <dark-theme> <light-theme> | off` — follow the OS dark/light mode.
def --env "nuance appearance" [dark?: string@"nu-complete nuance themes", light?: string@"nu-complete nuance themes"] {
    if $dark == null {
        let c = (try { open (appearance-path) | str trim } catch { "" })
        print (if ($c | is-empty) { "appearance switching is off — nuance appearance <dark-theme> <light-theme>" } else { $"appearance pair: ($c)" })
        return
    }
    if $dark == "off" {
        rm -f (appearance-path)
        "auto" | save -f (theme-state-path)
        print $"(ansi green_bold)✓(ansi reset) appearance switching off \(back to terminal auto-follow)"
        return
    }
    if $light == null or $dark not-in (theme-list) or $light not-in (theme-list) {
        print $"(ansi red)usage:(ansi reset) nuance appearance <dark-theme> <light-theme>   \(both must be known themes)"
        return
    }
    $"($dark),($light)" | save -f (appearance-path)
    "appearance" | save -f (theme-state-path)
    theme-apply (pick-theme-name "appearance")
    print $"(ansi green_bold)✓(ansi reset) dark → (ansi attr_bold)($dark)(ansi reset), light → (ansi attr_bold)($light)(ansi reset) — applied when a shell starts"
}

# ── Share a look ─────────────────────────────────────────────
# `nuance export` prints  nuance:1:<theme>:<style>:<modules+…>:<transient>
# and `nuance import "<that string>"` applies it on another machine.
def "nuance export" [] {
    let mods = ((enabled-modules) | str join "+")
    let t = ($env.THEME_NAME? | default "gruvbox")
    if $t in (user-theme-names) { print -e $"(ansi yellow)note:(ansi reset) ($t) is an imported theme — it will only resolve on machines that have it" }
    $"nuance:1:($t):($env.PROMPT_STYLE? | default 'full'):($mods):($env.NUANCE_TRANSIENT? | default 'off')"
}
def --env apply-share [code: string] {
    let c = ($code | str trim | split row ":")
    if ($c | length) != 6 or ($c.1 != "1") {
        print $"(ansi red)not a nuance share string(ansi reset) — expected nuance:1:<theme>:<style>:<modules>:<transient>"
        return
    }
    let theme = $c.2
    let style = $c.3
    let mods = ($c.4 | split row "+" | where {|m| $m | is-not-empty })
    let tr = $c.5
    let bad = ($mods | where {|m| $m not-in (module-names) })
    if $theme not-in (theme-list) { print $"(ansi red)unknown theme:(ansi reset) ($theme)"; return }
    if $style not-in (prompt-styles) { print $"(ansi red)unknown style:(ansi reset) ($style)"; return }
    if ($bad | is-not-empty) or ($tr not-in ["on" "off" "dir"]) { print $"(ansi red)invalid modules or transient mode(ansi reset)"; return }
    apply-look $theme $style
    $env.NUANCE_MODULES = $mods
    $mods | str join "\n" | save -f (modules-state-path)
    transient-apply $tr
    $tr | save -f (transient-state-path)
    print $"(ansi green_bold)✓(ansi reset) applied: theme (ansi attr_bold)($theme)(ansi reset), style (ansi attr_bold)($style)(ansi reset), modules ((if ($mods | is-empty) { 'none' } else { $mods | str join ', ' })), transient ($tr)"
}

# `nuance integration [on|off|status]` — window title, cwd reporting, semantic prompt marks.
def --env "nuance integration" [mode?: string@"nu-complete nuance integration"] {
    let cur = ($env.NUANCE_INTEGRATION? | default "on")
    match ($mode | default "status") {
        "status" => { print $"terminal integration: (ansi attr_bold)($cur)(ansi reset)  \(nuance integration on|off)" }
        "on" | "off" => {
            integration-apply $mode
            $mode | save -f (integration-state-path)
            print $"(ansi green_bold)✓(ansi reset) terminal integration (ansi attr_bold)($mode)(ansi reset)"
        }
        _ => { print $"(ansi red)unknown mode:(ansi reset) ($mode) — use on, off or status" }
    }
}

# `nuance style [new <name> | dir]` — your own segment styles (see README).
def "nuance style" [action?: string, name?: string] {
    let dir = (user-styles-dir)
    match ($action | default "list") {
        "dir" => { print $dir }
        "list" => { user-style-defs | select name shape segs desc }
        "new" => {
            if ($name | is-empty) or not ($name =~ '^[a-z0-9][a-z0-9_-]*$') { print $"(ansi red)usage:(ansi reset) nuance style new <name>   \(lowercase letters, digits, - and _)"; return }
            if $name in (style-defs-builtin | get name) { print $"(ansi red)'($name)' is a built-in style(ansi reset)"; return }
            let f = ($dir | path join $"($name).nuon")
            if ($f | path exists) { print $"(ansi red)already exists:(ansi reset) ($f)"; return }
            mkdir $dir
            {
                shape: "arrow"
                segs: ["user" "path" "git" "lang"]
                glyph: "❯"
                tone: "ok"
                desc: "my custom style"
                nl: false
            } | to nuon --indent 4 | save $f
            print $"(ansi green_bold)✓(ansi reset) created (tilde $f)\nshape: arrow | slant | pill · segs: path is required, plus any of (style-seg-ids | str join ', ')\napply with: nuance prompt-style ($name)"
        }
        _ => { print $"(ansi red)unknown action:(ansi reset) ($action) — use list, new <name> or dir" }
    }
}

# `nuance modules [list|enable|disable|clear] [name…]` — situational prompt segments.
def --env "nuance modules" [action?: string@"nu-complete nuance module-actions", ...names: string@"nu-complete nuance modules"] {
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
# ASCII lowercase that works on every nu version: `str downcase` is deprecated
# from 0.114 and `str lowercase` doesn't exist before it.
def lower [s: string] {
    let up = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    let lo = "abcdefghijklmnopqrstuvwxyz"
    $s | split chars | each {|c|
        let i = ($up | str index-of $c)
        if $i < 0 { $c } else { $lo | str substring $i..$i }
    } | str join ""
}

def theme-slug [name: string] {
    (lower $name) | str replace --all --regex '[^a-z0-9]+' '-' | str trim --char '-'
}

def ghostty-map-name [low: string] {
    # 1. exact (slugged) match with any built-in / extra / imported theme
    let slug = (theme-slug $low)
    if $slug in (theme-list) { return $slug }
    # 2. well-known variants
    let l = (lower $low)
    let has = {|w| $l | str contains $w }
    if (do $has "tokyo") {
        return (if (do $has "storm") { "tokyo-night-storm" } else if (do $has "moon") { "tokyo-night-moon" } else if ((do $has "day") or (do $has "light")) { "tokyo-night-day" } else { "tokyo-night" })
    }
    if (do $has "gruvbox") and (do $has "light") { return "gruvbox-light" }
    if (do $has "gruvbox") and (do $has "material") { return "gruvbox-material" }
    if (do $has "kanagawa") {
        return (if (do $has "dragon") { "kanagawa-dragon" } else if ((do $has "lotus") or (do $has "light")) { "kanagawa-lotus" } else { "kanagawa" })
    }
    if (do $has "dawnfox") { return "dawnfox" }
    if (do $has "nightfox") { return "nightfox" }
    if (do $has "flexoki") { return (if (do $has "light") { "flexoki-light" } else { "flexoki" }) }
    if (do $has "melange") { return "melange" }
    if (do $has "nightfly") { return "nightfly" }
    if (do $has "palenight") { return "material-palenight" }
    if (do $has "tomorrow") and (do $has "night") { return "tomorrow-night" }
    if (do $has "snazzy") { return "snazzy" }
    if (do $has "iceberg") { return "iceberg" }
    if (do $has "one") and (do $has "light") { return "one-light" }
    if (do $has "papercolor") and (do $has "light") { return "papercolor-light" }
    if (do $has "synthwave") { return "synthwave-84" }
    if (do $has "cobalt2") { return "cobalt2" }
    if (do $has "modus") { return (if (do $has "operandi") { "modus-operandi" } else { "modus-vivendi" }) }
    if (do $has "horizon") { return "horizon" }
    if (do $has "sonokai") { return "sonokai" }
    # 3. the original keyword families
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
    } else if (($low | str contains --ignore-case "solarized") and ($low | str contains --ignore-case "light")) { "solarized-light"
    } else if ($low | str contains --ignore-case "mario") { "super-mario"
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

    let mapped = (ghostty-map-name $val)
    if ($mapped | is-not-empty) { return $mapped }
    # Unknown to nuance: if Ghostty ships/has that theme file, import it so
    # *any* Ghostty theme works with auto-follow.
    ghostty-adopt $val
}


