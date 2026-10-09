# ── Theme import (ghostty · kitty · alacritty · base16) ──────
# Converts a terminal color scheme into a nuance theme and stores it in the
# user themes dir. Ghostty themes can also be imported by *name*, and any
# unknown theme Ghostty is using is imported automatically on sync.
def norm-hex [v: any] {
    if $v == null { return null }
    let raw = ($v | into string | str trim | str trim --char '"' | str trim --char "'")
    let t = ((lower $raw) | str replace --regex '^(#|0x)' '')
    if ($t =~ '^[0-9a-f]{6}$') { $"#($t)" } else { null }
}

# Build a theme record from bg/fg + the 16 ANSI colors (nulls allowed).
def theme-from-ansi [bg: string, fg: string, ansi: list, --orange: string, --purple: string] {
    # (missing colors are "" — `each` would drop nulls and shift the indices)
    let a = {|i| let v = ($ansi | get -o $i | default ""); if ($v | is-empty) { $fg } else { $v } }
    let red = (do $a 1)
    let yellow = (do $a 3)
    let magenta = (do $a 5)
    {
        fg: $fg
        gray: (do $a 8)
        red: $red
        orange: ($orange | default (hex-mix $red $yellow 0.5))
        yellow: $yellow
        green: (do $a 2)
        cyan: (do $a 6)
        blue: (do $a 4)
        magenta: $magenta
        purple: ($purple | default (let v = ($ansi | get -o 13 | default ""); if ($v | is-empty) { $magenta } else { $v }))
        bg: $bg
    }
}

def import-detect [text: string] {
    if ($text =~ '(?m)^\s*palette\s*=') { "ghostty"
    } else if ($text =~ '(?m)^\s*base0[0-9a-fA-F]\s*:') { "base16"
    } else if ($text =~ '(?m)^\s*\[colors') { "alacritty"
    } else if ($text =~ '(?m)^\s*(color\d+|foreground|background)\s+#?[0-9a-fA-F]{6}') { "kitty"
    } else { null }
}

def import-ghostty [text: string] {
    let lines = ($text | lines | each { str trim } | where {|l| ($l | is-not-empty) and not ($l | str starts-with "#") })
    let pal = ($lines | parse -r '^palette\s*=\s*(?<i>\d+)\s*=\s*(?<c>\S+)')
    let ansi = (0..15 | each {|i| norm-hex ($pal | where {|r| ($r.i | into int) == $i } | get 0?.c?) | default "" })
    let bg = (norm-hex ($lines | parse -r '^background\s*=\s*(?<c>\S+)' | get 0?.c?))
    let fg = (norm-hex ($lines | parse -r '^foreground\s*=\s*(?<c>\S+)' | get 0?.c?))
    if $bg == null or $fg == null { error make { msg: "ghostty theme has no background/foreground" } }
    theme-from-ansi $bg $fg $ansi
}

def import-kitty [text: string] {
    let lines = ($text | lines | each { str trim } | where {|l| ($l | is-not-empty) and not ($l | str starts-with "#") })
    let cols = ($lines | parse -r '^color(?<i>\d+)\s+(?<c>\S+)')
    let ansi = (0..15 | each {|i| norm-hex ($cols | where {|r| ($r.i | into int) == $i } | get 0?.c?) | default "" })
    let bg = (norm-hex ($lines | parse -r '^background\s+(?<c>\S+)' | get 0?.c?))
    let fg = (norm-hex ($lines | parse -r '^foreground\s+(?<c>\S+)' | get 0?.c?))
    if $bg == null or $fg == null { error make { msg: "kitty theme has no background/foreground" } }
    theme-from-ansi $bg $fg $ansi
}

def import-alacritty [text: string] {
    let c = ($text | from toml | get colors)
    let names = [black red green yellow blue magenta cyan white]
    let norm = {|grp| $names | each {|n| norm-hex ($c | get -o $grp | default {} | get -o $n) | default "" } }
    let ansi = ((do $norm "normal") ++ (do $norm "bright"))
    let bg = (norm-hex ($c.primary?.background?))
    let fg = (norm-hex ($c.primary?.foreground?))
    if $bg == null or $fg == null { error make { msg: "alacritty theme has no primary background/foreground" } }
    theme-from-ansi $bg $fg $ansi
}

def import-base16 [text: string] {
    let rows = ($text | lines | each { str trim } | parse -r '^(?<k>base0[0-9a-fA-F])\s*:\s*(?<v>\S+)')
    let b = {|k| norm-hex ($rows | where {|r| (lower $r.k) == $k } | get 0?.v?) }
    let bg = (do $b "base00")
    let fg = (do $b "base05")
    if $bg == null or $fg == null { error make { msg: "base16 scheme is missing base00/base05" } }
    let ansi = ["base00" "base08" "base0b" "base0a" "base0d" "base0e" "base0c" "base05" "base03" "base08" "base0b" "base0a" "base0d" "base0e" "base0c" "base07"] | each {|k| do $b $k | default "" }
    theme-from-ansi $bg $fg $ansi --orange (do $b "base09") --purple (do $b "base0e")
}

def ghostty-theme-dirs [] {
    let home = $nu.home-dir
    [
        ($env.GHOSTTY_RESOURCES_DIR? | default "" | path join "themes")
        ($home | path join ".config" "ghostty" "themes")
        ($home | path join "Library" "Application Support" "com.mitchellh.ghostty" "themes")
        "/Applications/Ghostty.app/Contents/Resources/ghostty/themes"
        "/usr/share/ghostty/themes"
        "/usr/local/share/ghostty/themes"
        "/opt/homebrew/share/ghostty/themes"
    ] | where {|d| ($d | path type) == "dir" }
}

# Path of a Ghostty theme file by (case-insensitive) name, or null.
def ghostty-theme-file [name: string] {
    let want = (lower $name)
    for d in (ghostty-theme-dirs) {
        let hit = (ls $d | where {|f| (lower ($f.name | path basename)) == $want } | get 0?.name?)
        if $hit != null { return $hit }
    }
    null
}

# Import `source` (a file path, or a Ghostty theme name) as theme `name`.
def theme-import [source: string, name?: string] {
    let file = if ($source | path exists) { $source } else { ghostty-theme-file $source }
    if $file == null { error make { msg: $"not a file and not a Ghostty theme name: ($source)" } }
    let text = (open --raw $file)
    let fmt = (import-detect $text)
    if $fmt == null { error make { msg: $"unrecognized color scheme format: ($file)" } }
    let theme = match $fmt {
        "ghostty" => (import-ghostty $text)
        "kitty" => (import-kitty $text)
        "alacritty" => (import-alacritty $text)
        _ => (import-base16 $text)
    }
    let slug = (theme-slug ($name | default ($file | path parse | get stem)))
    if ($slug | is-empty) { error make { msg: "could not derive a theme name — pass --name" } }
    if $slug in ((theme-list-builtin) ++ ($EXTRA_THEMES | columns)) {
        error make { msg: $"'($slug)' is a built-in theme — pass --name to import it under another name" }
    }
    let dir = (user-themes-dir)
    mkdir $dir
    $theme | to nuon | save -f ($dir | path join $"($slug).nuon")
    { name: $slug, format: $fmt, file: $file }
}

# Import a Ghostty theme by name for auto-follow; returns its slug or null.
def ghostty-adopt [name: string] {
    let slug = (theme-slug $name)
    if ($slug | is-empty) { return null }
    if $slug in (theme-list) { return $slug }
    if (ghostty-theme-file $name) == null { return null }
    try { theme-import $name $slug | get name } catch { null }
}

# `nuance import <file|ghostty-theme-name> [--name x]`
def --env "nuance import" [source: string, --name: string] {
    if ($source | str starts-with "nuance:") { apply-share $source; return }
    let r = (try { theme-import $source $name } catch {|e| print $"(ansi red)import failed:(ansi reset) ($e.msg)"; return })
    print $"(ansi green_bold)✓(ansi reset) imported (ansi attr_bold)($r.name)(ansi reset) from ($r.format) theme — apply with: (ansi attr_bold)nuance theme ($r.name)(ansi reset)"
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
let start_theme = (pick-theme-name $saved_theme)
theme-apply $start_theme

# ─────────────────────────────────────────────────────────────
# Prompt — git-aware, oh-my-zsh style, themed via $env.THEME_PALETTE
#   • rich repo info: branch, ahead/behind, staged/modified/etc.
#   • command duration + exit status
#   • switch layout with:  prompt-style   (see `style-defs` for every style)
# ─────────────────────────────────────────────────────────────

def prompt-style-path [] { (nuance-config-dir) | path join "prompt-style.txt" }
