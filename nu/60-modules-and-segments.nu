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
        { name: "docker", role: "ahead",    desc: "non-default docker context" }
        { name: "cloud",  role: "host",     desc: "active AWS profile or GCP project" }
        { name: "pkg",    role: "modified", desc: "version of the nearest Cargo.toml / package.json / pyproject.toml" }
        { name: "battery", role: "ok",      desc: "battery percentage (laptops)" }
    ]
}
def module-names [] { module-defs | get name }
def modules-state-path [] { (nuance-config-dir) | path join "modules.txt" }

# Modules the user enabled globally (persisted in modules.txt).
def enabled-modules [] {
    ($env.NUANCE_MODULES? | default []) | where {|m| $m in (module-names) }
}

# First x.y[.z] version number in a tool's `--version` output.
def first-version [text: string] {
    $text | parse -r '(?<v>\d+\.\d+(?:\.\d+)?)' | get v.0? | default ""
}

# Where nuance keeps its state files ($env.NUANCE_CONFIG_DIR overrides — used by tests).
def nuance-config-dir [] { $env.NUANCE_CONFIG_DIR? | default $nu.default-config-dir }
# Where nuance keeps small caches (toolchain versions, slow-repo marks, last error).
def nuance-cache-dir [] { $env.NUANCE_CACHE_DIR? | default ($nu.cache-dir | path join "nuance") }
# Terminal width ($env.NUANCE_COLUMNS overrides — used by tests).
def term-cols [] {
    let o = ($env.NUANCE_COLUMNS? | default null)
    if $o != null { $o | into int } else { try { (term size).columns } catch { 80 } }
}
# Today's date for HUD styles ($env.NUANCE_DATE overrides — used by tests).
def prompt-date [] { $env.NUANCE_DATE? | default (date now | format date "%a %-d") }

# Toolchain version, cached on disk for an hour — spawning rustc/node on
# every prompt would make the shell feel sluggish.
def tool-version [tool: string, args: list<string>] {
    let dir = (nuance-cache-dir)
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

# Version of the nearest package manifest (walks up like lang-detect).
def pkg-version [start?: string] {
    mut dir = ($start | default $env.PWD)
    for _ in 0..5 {
        let cargo = ($dir | path join "Cargo.toml")
        if ($cargo | path exists) {
            let v = (open --raw $cargo | lines | where {|l| $l =~ '^version\s*=' } | first 1 | parse -r '"(?<v>[^"]+)"' | get v.0? | default "")
            if ($v | is-not-empty) { return $v }
        }
        let pj = ($dir | path join "package.json")
        if ($pj | path exists) {
            let v = (try { open $pj | get -o version | default "" } catch { "" })
            if ($v | is-not-empty) { return $v }
        }
        let py = ($dir | path join "pyproject.toml")
        if ($py | path exists) {
            let v = (open --raw $py | lines | where {|l| $l =~ '^version\s*=' } | first 1 | parse -r '"(?<v>[^"]+)"' | get v.0? | default "")
            if ($v | is-not-empty) { return $v }
        }
        let up = ($dir | path dirname)
        if $up == $dir { break }
        $dir = $up
    }
    ""
}

# Battery percentage or null (no battery). Cached for a minute — `pmset` is slow.
def battery-percent [] {
    let f = ((nuance-cache-dir) | path join "battery.txt")
    let now = (date now | format date "%s" | into int)
    if ($f | path exists) {
        let c = (open --raw $f | str trim | split row " ")
        if ($c | length) == 2 and (($now - ($c.0 | into int)) < 60) {
            return (if $c.1 == "none" { null } else { $c.1 | into int })
        }
    }
    let pct = if ("/sys/class/power_supply" | path exists) {
        let bats = (glob "/sys/class/power_supply/BAT*/capacity")
        if ($bats | is-empty) { null } else { try { open --raw ($bats | first) | str trim | into int } catch { null } }
    } else if (which pmset | is-not-empty) {
        (do -i { ^pmset -g batt } | complete | get stdout | parse -r '(?<p>\d+)%' | get p.0? | default null | if $in == null { null } else { $in | into int })
    } else { null }
    try { mkdir (nuance-cache-dir); $"($now) ($pct | default 'none')" | save -f $f }
    $pct
}

# Text of one module, or null when it has nothing to show.
def module-text [name: string] {
    # tests/screenshots: $env.NUANCE_FAKE_MODULES = { lang: "rust 1.0.0", status: "-" }  ("-" = hidden)
    let fake = ($env.NUANCE_FAKE_MODULES? | default {} | get -o $name)
    if $fake != null { return (if $fake == "-" { null } else { $fake }) }
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
        "docker" => {
            let env_ctx = ($env.DOCKER_CONTEXT? | default "")
            let ctx = if ($env_ctx | is-not-empty) { $env_ctx } else {
                let cfg = ($nu.home-dir | path join ".docker" "config.json")
                if ($cfg | path exists) { (try { open $cfg | get -o currentContext } catch { null }) | default "" } else { "" }
            }
            if ($ctx | is-empty) or $ctx == "default" { null } else { $"docker:($ctx)" }
        }
        "cloud" => {
            let aws = ($env.AWS_PROFILE? | default ($env.AWS_VAULT? | default ""))
            let gcp = ($env.CLOUDSDK_CORE_PROJECT? | default ($env.GOOGLE_CLOUD_PROJECT? | default ""))
            if ($aws | is-not-empty) { $"aws:($aws)" } else if ($gcp | is-not-empty) { $"gcp:($gcp)" } else { null }
        }
        "pkg" => {
            let v = (pkg-version)
            if ($v | is-empty) { null } else { $"v($v)" }
        }
        "battery" => {
            let b = (battery-percent)
            if $b == null { null } else { $"(if $b <= 20 { '⚠' } else { '⚡' }) ($b)%" }
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
        "path" => { text: (display-dir), bg: $p.path, ink: (do $ink "path") }
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
    let nerd = ($env.PROMPT_NERD? | default true)
    if $shape == "pill" {
        let lc = (if $nerd { char --unicode e0b6 } else { "(" })
        let rc = (if $nerd { char --unicode e0b4 } else { ")" })
        return ($segs | each {|s|
            $"(ansi {fg: $s.bg})($lc)(ansi {bg: $s.bg fg: $s.ink attr: b}) ($s.text) (ansi reset)(ansi {fg: $s.bg})($rc)(ansi reset)"
        } | str join "  ")
    }
    let sep = (if not $nerd { if $shape == "slant" { "/" } else { ">" } } else if $shape == "slant" { char --unicode e0b8 } else { char --unicode e0b0 })
    mut out = ""
    mut prev = ""
    for s in $segs {
        if $prev != "" { $out = $out + $"(ansi {fg: $prev bg: $s.bg})($sep)" }
        $out = $out + $"(ansi {bg: $s.bg fg: $s.ink attr: b}) ($s.text) "
        $prev = $s.bg
    }
    $"($out)(ansi reset)(ansi {fg: $prev})($sep)(ansi reset) "
}

# Left prompt: the style's layout, plus the user's enabled context modules
# as a tail for single-line styles (blocks styles fold them in as segments).
# ── Directory display ────────────────────────────────────────
# Long paths are shortened to fit: parent components collapse to their first
# letter (fish-style) from the left, keeping the last two intact; if that is
# still too long it falls back to …/parent/dir. The budget is a third of the
# terminal width (min 24); override with $env.PROMPT_DIR_MAX (0 = never shorten).
# Terminal columns a string occupies: wide (CJK, emoji, fullwidth) characters
# count as 2, combining marks as 0.
def display-width [s: string] {
    let chars = ($s | split chars)
    let wide = ($chars | where {|c| $c =~ '^[\x{1100}-\x{115F}\x{2E80}-\x{A4CF}\x{AC00}-\x{D7A3}\x{F900}-\x{FAFF}\x{FE30}-\x{FE6F}\x{FF00}-\x{FF60}\x{FFE0}-\x{FFE6}\x{1F300}-\x{1FAFF}\x{20000}-\x{3FFFD}]$' } | length)
    let comb = ($chars | where {|c| $c =~ '^[\x{0300}-\x{036F}\x{200B}-\x{200D}\x{FE0F}]$' } | length)
    ($chars | length) + $wide - $comb
}
def shorten-path [path: string, budget: int] {
    if $budget <= 0 or (display-width $path) <= $budget { return $path }
    let parts = ($path | path split)
    let n = ($parts | length)
    if $n <= 2 { return $path }
    let rooted = (($parts | first) == "/")
    let join = {|ps| if $rooted { "/" + ($ps | skip 1 | str join "/") } else { $ps | str join "/" } }
    mut cur = $parts
    if $n > 3 {
        for i in 1..($n - 3) {
            let c = ($cur | get $i)
            let short = (if ($c | str starts-with ".") { $c | str substring --grapheme-clusters 0..1 } else { $c | str substring --grapheme-clusters 0..0 })
            $cur = ($cur | update $i $short)
            let out = (do $join $cur)
            if (display-width $out) <= $budget { return $out }
        }
    }
    $"…/($parts | last 2 | str join '/')"
}
def dir-budget [] {
    let o = ($env.PROMPT_DIR_MAX? | default null)
    if $o != null { return ($o | into int) }
    ([((term-cols) // 3) 24] | math max)
}
# $env.NUANCE_DIR overrides the shown directory (used by tests and screenshots).
# Asking the terminal for its width costs ~10 ms, so short paths (which can
# never be shortened below the 24-column minimum budget) skip it entirely.
def display-dir [] {
    let o = ($env.NUANCE_DIR? | default null)
    let path = (if $o != null { $o } else { $env.PWD | str replace $nu.home-dir "~" })
    if ($env.PROMPT_DIR_MAX? | default null) == null and (display-width $path) <= 24 { return $path }
    shorten-path $path (dir-budget)
}

