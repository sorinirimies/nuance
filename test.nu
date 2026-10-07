#!/usr/bin/env nu
# test.nu — validates nuance: every theme, style and look is well-formed,
# the prompt renders, and helpers behave. Exits non-zero on any failure.
# Run:  nu test.nu
source nushell-prompt.nu
$env.NUANCE_THEMES_DIR = (mktemp -d)

mut errors = []

# ── themes: color_config is substantial + palette has required keys ──
let required = [user host path git sep ok err time added modified deleted untracked ahead behind stash conflict duration ink bg fg surface light inks]
for t in (theme-list) {
    let g = (theme-get $t)
    let cols = ($g.color_config | columns | length)
    if $cols < 40 { $errors = ($errors | append $"theme '($t)': color_config only ($cols) entries") }
    let pal = ($g.palette | columns)
    for k in $required {
        if ($k not-in $pal) { $errors = ($errors | append $"theme '($t)': palette missing '($k)'") }
    }
}

# ── styles: every style renders a non-empty prompt ──
$env.THEME_PALETTE = (theme-get "gruvbox").palette
for s in (prompt-styles) {
    $env.PROMPT_STYLE = $s
    let out = (try { create_left_prompt } catch {|e| "" })
    if ($out | is-empty) { $errors = ($errors | append $"style '($s)': empty/failed prompt") }
}

# ── looks: reference valid themes + styles, unique names ──
for l in (presets) {
    if ($l.theme not-in (theme-list)) { $errors = ($errors | append $"look '($l.name)': unknown theme '($l.theme)'") }
    if ($l.style not-in (prompt-styles)) { $errors = ($errors | append $"look '($l.name)': unknown style '($l.style)'") }
}
let look_names = (presets | get name)
if (($look_names | length) != ($look_names | uniq | length)) {
    $errors = ($errors | append "duplicate look names")
}

# ── uniqueness of theme + style names ──
if ((theme-list | length) != (theme-list | uniq | length)) { $errors = ($errors | append "duplicate theme names") }
if ((prompt-styles | length) != (prompt-styles | uniq | length)) { $errors = ($errors | append "duplicate style names") }


# ── theme quality: valid hex, readable text, AA ink on every segment ──
# (color math lives in nushell-prompt.nu: contrast / ink-on / finish-palette)
let light_themes = [catppuccin-latte rose-pine-dawn github-light solarized-light tokyo-night-day gruvbox-light dawnfox kanagawa-lotus flexoki-light one-light papercolor-light modus-operandi]
for t in (theme-list) {
    let p = (theme-get $t).palette
    for k in ($p | columns | where {|c| $c not-in [light inks] }) {
        let v = ($p | get $k)
        if ($v !~ '^#[0-9a-fA-F]{6}$') { $errors = ($errors | append $"theme '($t)': palette.($k) is not a #rrggbb hex: ($v)") }
    }
    if ($p.light != ($t in $light_themes)) {
        $errors = ($errors | append $"theme '($t)': light flag is ($p.light) but theme is ((if ($t in $light_themes) { 'light' } else { 'dark' }))")
    }
    for k in (palette-text-roles) {
        let c = (contrast ($p | get $k) $p.bg)
        if $c < 3.0 { $errors = ($errors | append $"theme '($t)': text role '($k)' contrast ($c | math round --precision 2) < 3.0 on bg") }
    }
    for k in (palette-muted-roles) {
        let c = (contrast ($p | get $k) $p.bg)
        if $c < 2.4 { $errors = ($errors | append $"theme '($t)': muted role '($k)' contrast ($c | math round --precision 2) < 2.4 on bg") }
    }
    for k in (palette-seg-roles) {
        let c = (contrast ($p.inks | get $k) ($p | get $k))
        if $c < 4.5 { $errors = ($errors | append $"theme '($t)': ink on '($k)' segment contrast ($c | math round --precision 2) < 4.5 (WCAG AA)") }
    }
    # the three main block-segment colors must be distinct from each other
    if (($p.user == $p.path) or ($p.path == $p.git) or ($p.user == $p.git)) {
        $errors = ($errors | append $"theme '($t)': user/path/git colors are not all distinct")
    }
}

# ── color math sanity ──
if ((contrast "#000000" "#ffffff") | math round --precision 1) != 21.0 { $errors = ($errors | append "contrast(black, white) should be 21") }
if ((hex-mix "#000000" "#ffffff" 0.5) != "#808080") { $errors = ($errors | append $"hex-mix midpoint wrong: (hex-mix '#000000' '#ffffff' 0.5)") }
if ((hex-rgb "#0b0221") != [11.0 2.0 33.0]) { $errors = ($errors | append "hex-rgb mis-parses '0b' bytes") }

# ── style registry: every style has a renderer, glyph, and valid tone ──
let sdefs = (style-defs)
for d in $sdefs {
    if ($d.kind not-in [inline blocks]) { $errors = ($errors | append $"style '($d.name)': bad kind '($d.kind)'") }
    if ($d.tone not-in [ok git modified]) { $errors = ($errors | append $"style '($d.name)': bad tone '($d.tone)'") }
    if ($d.desc | is-empty) { $errors = ($errors | append $"style '($d.name)': empty desc") }
    if $d.kind == "blocks" {
        if ($d.shape not-in [arrow slant pill]) { $errors = ($errors | append $"style '($d.name)': bad shape '($d.shape)'") }
        if ("path" not-in $d.segs) { $errors = ($errors | append $"style '($d.name)': blocks styles must include 'path'") }
        for sg in $d.segs {
            if ($sg not-in ([user host path git] ++ (module-names))) { $errors = ($errors | append $"style '($d.name)': unknown segment '($sg)'") }
        }
    }
}
# every style renders non-empty output on every theme (catches renderer typos)
$env.PROMPT_USER = "sorin"; $env.PROMPT_HOST = "nuance"
let saved_style = $env.PROMPT_STYLE
for t in (theme-list) {
    theme-apply $t
    for d in $sdefs {
        $env.PROMPT_STYLE = $d.name
        let out = (create_left_prompt | ansi strip)
        if ($out | str trim | is-empty) { $errors = ($errors | append $"style '($d.name)' on '($t)' rendered nothing") }
        if ($d.kind == "blocks") and not ($out | str contains ($env.PWD | path basename)) {
            $errors = ($errors | append $"style '($d.name)' on '($t)' missing the directory")
        }
    }
}
$env.PROMPT_STYLE = $saved_style
hide-env PROMPT_USER PROMPT_HOST

# ── context modules ──
let mdefs = (module-defs)
if (($mdefs | get name | uniq | length) != ($mdefs | length)) { $errors = ($errors | append "duplicate module names") }
for m in $mdefs {
    if ($m.role not-in (palette-seg-roles)) { $errors = ($errors | append $"module '($m.name)': role '($m.role)' is not a segment role (no ink computed)") }
}
let r_ok = (with-env { LAST_EXIT_CODE: 0 } { module-text "status" })
if ($r_ok != null) { $errors = ($errors | append "status module shows with exit code 0") }
let r_status = (with-env { LAST_EXIT_CODE: 2 } { module-text "status" })
if ($r_status != "✘ 2") { $errors = ($errors | append $"status module wrong for exit code 2: ($r_status)") }
let r_ssh = (with-env { SSH_CONNECTION: "1 2 3 4" } { module-text "ssh" })
if ($r_ssh != "ssh") { $errors = ($errors | append "ssh module missing inside SSH_CONNECTION") }
let r_venv = (with-env { VIRTUAL_ENV: "/tmp/proj/.venv-demo" } { module-text "venv" })
if ($r_venv != "py:.venv-demo") { $errors = ($errors | append $"venv module wrong: ($r_venv)") }
let r_nix = (with-env { IN_NIX_SHELL: "pure" } { module-text "nix" })
if ($r_nix != "nix") { $errors = ($errors | append "nix module missing in IN_NIX_SHELL") }
if ((first-version "rustc 1.99.0 (b940084d7 2026-09-28)") != "1.99.0") { $errors = ($errors | append "first-version parse wrong") }
if ((first-version "go version go1.22 darwin/arm64") != "1.22") { $errors = ($errors | append "first-version parse wrong for go") }
let ld = (mktemp -d)
let l_empty = (lang-detect $ld)
if ($l_empty != "") { $errors = ($errors | append "lang-detect found a project in an empty dir") }
"" | save ($ld | path join "Cargo.toml")
mkdir ($ld | path join "src")
let l_root = (lang-detect $ld)
let l_sub = (lang-detect ($ld | path join "src"))
if ($l_root != "rust") { $errors = ($errors | append "lang-detect missed Cargo.toml") }
if ($l_sub != "rust") { $errors = ($errors | append "lang-detect doesn't walk up to parent project") }
rm -rf $ld

# ctx tail shows up on single-line styles only when a module is enabled
theme-apply "gruvbox"
$env.PROMPT_USER = "sorin"; $env.PROMPT_HOST = "nuance"
$env.PROMPT_STYLE = "full"
let tail_off = (with-env { LAST_EXIT_CODE: 1, NUANCE_MODULES: [] } { create_left_prompt | ansi strip })
if ($tail_off | str contains "✘ 1") { $errors = ($errors | append "module tail shown while no module is enabled") }
let tail_full = (with-env { LAST_EXIT_CODE: 1, NUANCE_MODULES: ["status"] } { create_left_prompt | ansi strip })
if not ($tail_full | str contains "✘ 1") { $errors = ($errors | append "enabled status module missing on `full`") }
$env.PROMPT_STYLE = "powerline"
let tail_pl = (with-env { LAST_EXIT_CODE: 1, NUANCE_MODULES: ["status"] } { create_left_prompt | ansi strip })
if not ($tail_pl | str contains "✘ 1") { $errors = ($errors | append "enabled status module missing on `powerline`") }
hide-env PROMPT_USER PROMPT_HOST
$env.PROMPT_STYLE = $saved_style

# ── transient prompt ──
transient-apply "on"
if ($env.NUANCE_TRANSIENT != "on") or ("TRANSIENT_PROMPT_COMMAND" not-in ($env | columns)) { $errors = ($errors | append "transient-apply on didn't set TRANSIENT_PROMPT_COMMAND") }
if ((transient-left | ansi strip | str trim | is-empty)) { $errors = ($errors | append "transient-left rendered nothing") }
transient-apply "off"
if ($env.NUANCE_TRANSIENT != "off") or ("TRANSIENT_PROMPT_COMMAND" in ($env | columns)) { $errors = ($errors | append "transient-apply off didn't clear TRANSIENT_PROMPT_COMMAND") }

# ── extra themes: shape + builtin separation ──
let pal_keys = [fg gray red orange yellow green cyan blue magenta purple bg]
for n in ($EXTRA_THEMES | columns) {
    let c = ($EXTRA_THEMES | get $n)
    for k in $pal_keys {
        if ($k not-in ($c | columns)) { $errors = ($errors | append $"extra theme '($n)': missing '($k)'") }
    }
    if ($n in (theme-list-builtin)) { $errors = ($errors | append $"extra theme '($n)' shadows a built-in") }
}

# ── ghostty names -> themes (exact slug, variants, families) ──
let gmap2 = { "Tokyo Night Storm": "tokyo-night-storm", "TokyoNight Moon": "tokyo-night-moon", "Gruvbox Light": "gruvbox-light", "Kanagawa Dragon": "kanagawa-dragon", "One Light": "one-light", "Flexoki Light": "flexoki-light", "Modus Operandi": "modus-operandi", "Nightfox": "nightfox", "Material Palenight": "material-palenight" }
for row in ($gmap2 | transpose k v) {
    let got = (ghostty-map-name $row.k)
    if ($got != $row.v) { $errors = ($errors | append $"ghostty map '($row.k)' -> '($got)' (want '($row.v)')") }
}

# ── theme import: every format, positions of missing colors, built-in guard ──
let idir = (mktemp -d)
"palette = 1=#ff5555\npalette = 2=#50fa7b\npalette = 3=#f1fa8c\npalette = 4=#bd93f9\npalette = 5=#ff79c6\npalette = 6=#8be9fd\npalette = 8=#6272a4\nbackground = #282a36\nforeground = #f8f8f2\n" | save ($idir | path join "gh-sample")
"foreground #c0c0c0\nbackground #101010\ncolor1 #ff0000\ncolor2 #00ff00\ncolor3 #ffff00\ncolor4 #0000ff\ncolor5 #ff00ff\ncolor6 #00ffff\ncolor8 #555555\n" | save ($idir | path join "kitty-sample.conf")
"[colors.primary]\nbackground = \"#1d1f21\"\nforeground = \"#c5c8c6\"\n[colors.normal]\nred = \"#cc6666\"\ngreen = \"#b5bd68\"\nyellow = \"#f0c674\"\nblue = \"#81a2be\"\nmagenta = \"#b294bb\"\ncyan = \"#8abeb7\"\n" | save ($idir | path join "alac-sample.toml")
"base00: \"282828\"\nbase03: \"928374\"\nbase05: \"d5c4a1\"\nbase08: \"fb4934\"\nbase09: \"fe8019\"\nbase0A: \"fabd2f\"\nbase0B: \"b8bb26\"\nbase0C: \"8ec07c\"\nbase0D: \"83a598\"\nbase0E: \"d3869b\"\n" | save ($idir | path join "b16-sample.yaml")
let imports = [["gh-sample" "ghostty" "#f1fa8c"] ["kitty-sample.conf" "kitty" "#ffff00"] ["alac-sample.toml" "alacritty" "#f0c674"] ["b16-sample.yaml" "base16" "#fabd2f"]]
for i in $imports {
    let r = (try { theme-import ($idir | path join $i.0) } catch {|e| { name: "", format: $e.msg } })
    if ($r.format != $i.1) { $errors = ($errors | append $"import '($i.0)': expected ($i.1), got ($r.format)") } else {
        let c = (user-theme-load $r.name)
        if ($c.yellow != $i.2) { $errors = ($errors | append $"import '($i.0)': yellow is ($c.yellow), want ($i.2) (color positions shifted?)") }
        if ($r.name not-in (theme-list)) { $errors = ($errors | append $"imported '($r.name)' missing from theme-list") }
        let pal = (theme-get $r.name).palette
        for k in (palette-text-roles) {
            if (contrast ($pal | get $k) $pal.bg) < 3.0 { $errors = ($errors | append $"imported '($r.name)': text role '($k)' below contrast floor") }
        }
    }
}
let guard = (try { theme-import ($idir | path join "gh-sample") "dracula"; "allowed" } catch { "refused" })
if ($guard != "refused") { $errors = ($errors | append "import allowed overwriting a built-in theme name") }
let bad = (try { theme-import ($idir | path join "nope-nope"); "ok" } catch { "refused" })
if ($bad != "refused") { $errors = ($errors | append "import of a missing source didn't fail") }
if ((norm-hex "0xABCDEF") != "#abcdef") or ((norm-hex "\"ABCDEF\"") != "#abcdef") or ((norm-hex "xyz") != null) { $errors = ($errors | append "norm-hex wrong") }
rm -rf $idir
rm -rf $env.NUANCE_THEMES_DIR
mkdir $env.NUANCE_THEMES_DIR

# ── per-directory overrides (.nuance) ──
let orig_pwd = $env.PWD
let ddir = (mktemp -d)
mkdir ($ddir | path join "sub")
"theme = \"dracula\"\nstyle = \"powerline\"\n" | save ($ddir | path join ".nuance")
cd ($ddir | path join "sub")
$env.PROMPT_USER = "sorin"; $env.PROMPT_HOST = "nuance"
theme-apply "gruvbox"
$env.PROMPT_STYLE = "full"
let ov = (dir-override)
let local_out = (create_left_prompt | ansi strip)
let core_out = (left-prompt-core | ansi strip)
"theme = \"not-a-theme\"\nstyle = 5\n" | save -f ($ddir | path join ".nuance")
let ov_bad = (dir-override)
cd $orig_pwd
rm -rf $ddir
if ($ov == null) or ($ov.THEME_NAME != "dracula") or ($ov.PROMPT_STYLE != "powerline") { $errors = ($errors | append $"dir-override didn't pick up .nuance from a parent: ($ov | to nuon)") }
if ($local_out == $core_out) { $errors = ($errors | append ".nuance override didn't change the rendered prompt") }
if ($ov_bad != null) { $errors = ($errors | append "invalid .nuance values should be ignored") }
if ($env.THEME_NAME? | default "") == "dracula" { $errors = ($errors | append ".nuance override leaked into the session env") }
hide-env PROMPT_USER PROMPT_HOST
$env.PROMPT_STYLE = $saved_style

# ── doctor ──
let doc = (nuance doctor)
if (($doc | length) < 10) { $errors = ($errors | append "nuance doctor returned too few checks") }
for r in $doc {
    if ($r.status not-in [ok warn info]) { $errors = ($errors | append $"doctor check '($r.check)': bad status '($r.status)'") }
}

# ── helpers ──
if ((prompt-user) | is-empty) { $errors = ($errors | append "prompt-user returned empty") }
if ((prompt-host) | is-empty) { $errors = ($errors | append "prompt-host returned empty") }
$env.PROMPT_USER = "sorin"; $env.PROMPT_HOST = "nuance"
if ((prompt-user) != "sorin") { $errors = ($errors | append "PROMPT_USER override ignored") }
if ((prompt-host) != "nuance") { $errors = ($errors | append "PROMPT_HOST override ignored") }
hide-env PROMPT_USER PROMPT_HOST

# ── git formatting helpers ('present' record) ──
let gdirty = { present: true, head: "main", ahead: 1, behind: 2, staged: 1, modified: 3, untracked: 2, conflict: 0, stash: 1, clean: false }
let gclean = { present: true, head: "main", ahead: 0, behind: 0, staged: 0, modified: 0, untracked: 0, conflict: 0, stash: 0, clean: true }
let plain = (git-plain $gdirty)
for frag in ["main" "⇡1" "⇣2" "+1" "!3" "?2" "*1"] {
    if not ($plain | str contains $frag) { $errors = ($errors | append $"git-plain missing '($frag)' in '($plain)'") }
}
let omz = (git-omz $gdirty | ansi strip)
if not ($omz | str contains "git:(main)") { $errors = ($errors | append $"git-omz format wrong: '($omz)'") }
if not ($omz | str contains "✗") { $errors = ($errors | append "git-omz missing dirty mark") }
if ((git-omz $gclean | ansi strip) | str contains "✗") { $errors = ($errors | append "git-omz shows dirty mark when clean") }

# ── public commands are defined ──
let cmds = (scope commands | get name)
for c in ["theme" "theme-sync" "prompt-style" "look" "looks" "theme-preview" "style-preview" "style-label" "style-picker-items" "theme-label" "theme-picker-items" "look-label" "look-picker-items" "sync-picker-item" "reload-theme" "reload-style" "nuance-cli-available" "nuance" "nuance help" "nuance update" "nuance theme" "nuance prompt-style" "nuance look" "nuance sync" "nuance sync theme" "nuance transient" "nuance modules" "nuance configure" "nuance doctor" "nuance import" "nuance here"] {
    if ($c not-in $cmds) { $errors = ($errors | append $"command not defined: ($c)") }
}

# ── style/theme picker labels: one per candidate, each carries its own name
# and a non-empty rendered preview (the "preview while picking" feature) ──
let s_items = (style-picker-items)
if (($s_items | length) != (prompt-styles | length)) {
    $errors = ($errors | append "style-picker-items: count mismatch with prompt-styles")
}
for row in $s_items {
    if (($row.label | ansi strip) !~ $row.key) {
        $errors = ($errors | append $"style-picker-items: label for '($row.key)' doesn't mention its name")
    }
    if (($row.label | str contains "→") == false) {
        $errors = ($errors | append $"style-picker-items: label for '($row.key)' missing preview arrow")
    }
}

let t_items = (theme-picker-items)
if (($t_items | length) != ((theme-list | length) + 1)) {
    $errors = ($errors | append "theme-picker-items: count mismatch with theme-list (+1 for the leading sync entry)")
}
let t_sync = ($t_items | get 0?)
if (($t_sync.key? | default "") != "__sync__") {
    $errors = ($errors | append "theme-picker-items: first entry must be the sync-with-terminal item (key '__sync__')")
}
if ((($t_sync.label? | default "") | ansi strip | str contains --ignore-case "sync with terminal") == false) {
    $errors = ($errors | append "theme-picker-items: sync entry label doesn't mention 'sync with terminal'")
}
for row in ($t_items | skip 1) {
    if (($row.label | ansi strip) !~ $row.key) {
        $errors = ($errors | append $"theme-picker-items: label for '($row.key)' doesn't mention its name")
    }
    if (($row.label | str contains "→") == false) {
        $errors = ($errors | append $"theme-picker-items: label for '($row.key)' missing preview arrow")
    }
}

let l_items = (look-picker-items)
if (($l_items | length) != (presets | length)) {
    $errors = ($errors | append "look-picker-items: count mismatch with presets")
}
for row in $l_items {
    if (($row.label | ansi strip) !~ $row.key) {
        $errors = ($errors | append $"look-picker-items: label for '($row.key)' doesn't mention its name")
    }
    if (($row.label | str contains "→") == false) {
        $errors = ($errors | append $"look-picker-items: label for '($row.key)' missing preview arrow")
    }
}

# ── ghostty keyword mapping ──
let gmap = { "Gruvbox Dark Hard": "gruvbox", "Catppuccin Mocha": "catppuccin-mocha", "Dracula": "dracula", "Tokyo Night": "tokyo-night", "Nord": "nord", "Solarized Light": "solarized-light", "Ayu Mirage": "ayu-mirage", "Super Mario": "super-mario" }
for row in ($gmap | transpose k v) {
    let got = (ghostty-map-name $row.k)
    if ($got != $row.v) { $errors = ($errors | append $"ghostty map '($row.k)' -> '($got)' (want '($row.v)')") }
}

# ── report ──
if ($errors | is-empty) {
    print $"(ansi green_bold)✓ all checks passed(ansi reset) — (theme-list | length) themes, (prompt-styles | length) styles, (presets | length) looks"
} else {
    $errors | each {|e| print $"(ansi red)✗(ansi reset) ($e)" }
    print $"(ansi red_bold)(($errors | length)) check\(s) failed(ansi reset)"
    exit 1
}
