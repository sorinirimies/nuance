# ── helpers for the game / framework styles ──────────────────
# Number of changed paths (conflicts count triple — they hurt the most).
def dirty-count [g: record] {
    if not $g.present { return 0 }
    $g.staged + $g.modified + $g.untracked + ($g.conflict * 3)
}
# Compact flag string, spaceship-style: =conflict $stash +staged !modified ?untracked ⇡ahead ⇣behind.
def git-flags [g: record] {
    if not $g.present { return "" }
    mut t = ""
    if $g.conflict > 0 { $t = $t + "=" }
    if $g.stash > 0 { $t = $t + "$" }
    if $g.staged > 0 { $t = $t + "+" }
    if $g.modified > 0 { $t = $t + "!" }
    if $g.untracked > 0 { $t = $t + "?" }
    if $g.ahead > 0 { $t = $t + "⇡" }
    if $g.behind > 0 { $t = $t + "⇣" }
    $t
}
# A 5-cell resource bar:  ▰▰▰▱▱
def bar5 [filled: int, color: string] {
    let f = ([([$filled 0] | math max) 5] | math min)
    let on = (if $f > 0 { 1..$f | each { "▰" } | str join "" } else { "" })
    let off = (if $f < 5 { 1..(5 - $f) | each { "▱" } | str join "" } else { "" })
    $"(ansi {fg: $color})($on)(ansi {fg: $env.THEME_PALETTE.sep})($off)(ansi reset)"
}
def repeat-str [s: string, n: int] {
    if $n < 1 { "" } else { 1..$n | each { $s } | str join "" }
}

# A resource bar of any width:  ▰▰▰▱▱▱
def barn [filled: int, total: int, color: string] {
    let f = ([([$filled 0] | math max) $total] | math min)
    let on = (repeat-str "▰" $f)
    let off = (repeat-str "▱" ($total - $f))
    $"(ansi {fg: $color})($on)(ansi {fg: $env.THEME_PALETTE.sep})($off)(ansi reset)"
}

def left-prompt-core [] {
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
    let full_dir = (display-dir)

    # Data-driven styles: render straight from the registry row.
    let def = (style-def $style)
    if $def.kind == "blocks" {
        let out = (render-blocks $def.shape $def.segs)
        return (if ($def.nl? | default false) { $"($out)\n" } else { $out })
    }

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
                $" (ansi {fg: $p.sep})(git-head $g)($dirty)(ansi reset)"
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
                $" (ansi {fg: $p.sep})on(ansi reset) (ansi {fg: $p.git attr: b})⎇ (git-head $g)(ansi reset)($dirty)"
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
            let cols = (term-cols)
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
            # NES HUD on top, brick ground with the hero running on it below:
            #   MARIO ◉×03  WORLD 3-4  ~/dir  ⚑ branch ▲2 ▼1 ✖1 ⬢1
            #   ▀▄▀▄▀▄◆▶
            # ◉ coins = changed files · ⚑ flag = branch · ▲▼ = pipes (ahead/behind)
            # ✖ = Goomba (conflict) · ⬢ = mushroom (stash) · ★ = starman (clean)
            let g = (git-info)
            let rs = (ansi reset)
            let coins = (if $g.present { $g.staged + $g.modified + $g.untracked } else { 0 })
            let coin_txt = ($coins | into string | fill --alignment right --character "0" --width 2)
            let depth = (($full_dir | path split | length) | into string)
            let world = $"($depth)-($coins + 1)"
            let hud_name = $"(ansi {fg: $p.err attr: b})MARIO($rs)"
            let hud_coin = $"(ansi {fg: $p.modified attr: b})◉×($coin_txt)($rs)"
            let hud_world = $"(ansi {fg: $p.sep})WORLD(ansi {fg: $p.path attr: b}) ($world)($rs)"
            let dir = $"(ansi {fg: $p.path attr: b})($full_dir)($rs)"
            let git_txt = if $g.present {
                mut segs = [$"(ansi {fg: $p.ok attr: b})⚑ (git-head $g)($rs)"]
                if $coins == 0 and $g.conflict == 0 { $segs = ($segs | append $"(ansi {fg: $p.modified attr: b})★($rs)") }
                if $g.ahead    > 0 { $segs = ($segs | append $"(ansi {fg: $p.ok})▲($g.ahead)($rs)") }
                if $g.behind   > 0 { $segs = ($segs | append $"(ansi {fg: $p.behind})▼($g.behind)($rs)") }
                if $g.conflict > 0 { $segs = ($segs | append $"(ansi {fg: $p.err attr: b})✖($g.conflict)($rs)") }
                if $g.stash    > 0 { $segs = ($segs | append $"(ansi {fg: $p.stash})⬢($g.stash)($rs)") }
                $"  ($segs | str join ' ')"
            } else { "" }
            let ground = $"(ansi {fg: $p.host})▀▄▀▄▀▄(ansi {fg: $p.err attr: b})◆($rs)"
            $"($hud_name) ($hud_coin)  ($hud_world)  ($dir)($git_txt)\n($ground)"
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
        "expedition33" => {
            # Clair Obscur: Expedition 33 — gold Belle Époque ornaments.
            #   ❖ staged · ✶ modified (Gommage) · ✧ untracked · ✖ conflict · ❦ stash · ✦ clean
            let g = (git-info)
            let rs = (ansi reset)
            let gold = (ansi {fg: $p.user})
            let git_txt = if $g.present {
                mut parts = []
                if $g.ahead    > 0 { $parts = ($parts | append $"(ansi {fg: $p.ahead})⇡($g.ahead)($rs)") }
                if $g.behind   > 0 { $parts = ($parts | append $"(ansi {fg: $p.behind})⇣($g.behind)($rs)") }
                if $g.staged   > 0 { $parts = ($parts | append $"(ansi {fg: $p.ok})❖($g.staged)($rs)") }
                if $g.modified > 0 { $parts = ($parts | append $"(ansi {fg: $p.err attr: b})✶($g.modified)($rs)") }
                if $g.untracked > 0 { $parts = ($parts | append $"(ansi {fg: $p.ahead})✧($g.untracked)($rs)") }
                if $g.conflict > 0 { $parts = ($parts | append $"(ansi {fg: $p.err attr: b})✖($g.conflict)($rs)") }
                if $g.stash    > 0 { $parts = ($parts | append $"(ansi {fg: $p.stash})❦($g.stash)($rs)") }
                let st = (if ($parts | is-empty) { $"(ansi {fg: $p.ahead})✦($rs)" } else { $parts | str join " " })
                $" ($gold)⚜ (ansi {fg: $p.git attr: b})(git-head $g)($rs) ($st)"
            } else { "" }
            let l1 = $"($gold)╭─❖ (ansi {fg: $p.user attr: b})(prompt-user)($gold) ✦ (ansi {fg: $p.fg attr: b})($full_dir)($rs)($git_txt)"
            $"($l1)\n($gold)╰─($rs)"
        }
        "gommage" => {
            # Every changed file is a petal on the wind.
            let g = (git-info)
            let rs = (ansi reset)
            let n = (if $g.present { $g.staged + $g.modified + $g.untracked + $g.conflict } else { 0 })
            let git_txt = if $g.present {
                let tail = (if $n > 0 { $"(ansi {fg: $p.err})(repeat-str '✿' ([$n 6] | math min))($rs)" } else { $"(ansi {fg: $p.sep})✧($rs)" })
                $" (ansi {fg: $p.err})❀($rs) (ansi {fg: $p.git attr: b})(git-head $g)($rs) ($tail)"
            } else { "" }
            $"(ansi {fg: $p.fg attr: b})($full_dir)($rs)($git_txt)"
        }
        "vault" => {
            # Fallout Pip-Boy: HP drops with every change, ☢ for conflicts.
            let g = (git-info)
            let rs = (ansi reset)
            let hp = (100 - ([((dirty-count $g) * 5) 95] | math min))
            let hpc = (if $hp >= 70 { $p.ok } else if $hp >= 40 { $p.modified } else { $p.err })
            let rad = (if $g.present and $g.conflict > 0 { $" (ansi {fg: $p.err attr: b})☢($g.conflict)($rs)" } else { "" })
            let br = (if $g.present { $" (ansi {fg: $p.git})[(git-head $g)]($rs)" } else { "" })
            $"(ansi {fg: $p.ok attr: b})[VAULT-111]($rs) (ansi {fg: $p.user})(prompt-user)($rs) (ansi {fg: $p.path attr: b})($full_dir)($rs) (ansi {fg: $hpc attr: b})HP ($hp)/100($rs)($rad)($br)"
        }
        "grace" => {
            # Elden Ring: ♥ HP · ✦ FP · ⚡ stamina. A failed command is YOU DIED.
            let g = (git-info)
            let rs = (ansi reset)
            let n = (dirty-count $g)
            let died = (($env.LAST_EXIT_CODE? | default 0) != 0)
            let gold = (ansi {fg: $p.user})
            let git_txt = (if $g.present { $" ($gold)❖ (ansi {fg: $p.git attr: b})(git-head $g)($rs)" } else { "" })
            let bars = $"(ansi {fg: $p.err})♥($rs)(bar5 (5 - ([$n 4] | math min)) $p.err) (ansi {fg: $p.path})✦($rs)(bar5 5 $p.path) (ansi {fg: $p.ok})⚡($rs)(bar5 (if $died { 1 } else { 5 }) $p.ok)"
            let dead = (if $died { $"(ansi {fg: $p.err attr: b})YOU DIED($rs) " } else { "" })
            $"($dead)($gold)✧ (ansi {fg: $p.fg attr: b})($full_dir)($rs)($git_txt)  ($bars)"
        }
        "triforce" => {
            let g = (git-info)
            let rs = (ansi reset)
            let empty = ([(((dirty-count $g) + 1) // 2) 3] | math min)
            let hearts = $"(ansi {fg: $p.err})(repeat-str '♥' (3 - $empty))(ansi {fg: $p.sep})(repeat-str '♡' $empty)($rs)"
            let rupees = (if $g.present and $g.untracked > 0 { $"  (ansi {fg: $p.ok})◆($g.untracked)($rs)" } else { "" })
            let git_txt = (if $g.present { $"  (ansi {fg: $p.git attr: b})✦ (git-head $g)($rs)" } else { "" })
            $"(ansi {fg: $p.user attr: b})▲($rs) (ansi {fg: $p.path attr: b})($full_dir)($rs)($git_txt)  ($hearts)($rupees)"
        }
        "doomguy" => {
            let g = (git-info)
            let rs = (ansi reset)
            let n = (dirty-count $g)
            let hp = (100 - ([($n * 5) 100] | math min))
            let face = (if $hp >= 70 { "☺" } else if $hp >= 30 { "☹" } else { "☠" })
            let armor = (if $g.present { $g.staged } else { 0 })
            let ammo = (if $g.present { $g.ahead } else { 0 })
            let br = (if $g.present { $" (ansi {fg: $p.git})(git-head $g)($rs)" } else { "" })
            $"(ansi {fg: $p.err attr: b})HEALTH ($hp)%($rs)  (ansi {fg: $p.ok attr: b})ARMOR ($armor)($rs)  (ansi {fg: $p.modified attr: b})AMMO ($ammo)($rs)  (ansi {fg: $p.user})($face)($rs) (ansi {fg: $p.path attr: b})($full_dir)($rs)($br)"
        }
        "spaceship" => {
            let g = (git-info)
            let rs = (ansi reset)
            let icon = (if ($env.PROMPT_NERD? | default true) { " " } else { "" })
            let flags = (git-flags $g)
            let git_txt = if $g.present {
                let f = (if ($flags | is-empty) { "" } else { $" (ansi {fg: $p.err})[($flags)]($rs)" })
                $" (ansi {fg: $p.sep})on($rs) (ansi {fg: $p.git attr: b})($icon)(git-head $g)($rs)($f)"
            } else { "" }
            let lang = (module-text "lang")
            let via = (if $lang == null { "" } else { $" (ansi {fg: $p.sep})via($rs) (ansi {fg: $p.modified attr: b})($lang)($rs)" })
            $"(ansi {fg: $p.path attr: b})($full_dir)($rs)($git_txt)($via)\n"
        }
        "p10k-lean" => {
            let g = (git-info)
            let rs = (ansi reset)
            let git_txt = if $g.present {
                let hc = (if $g.conflict > 0 { $p.err } else if $g.clean { $p.ok } else { $p.modified })
                mut parts = []
                if $g.ahead    > 0 { $parts = ($parts | append $"(ansi {fg: $p.ahead})⇡($g.ahead)($rs)") }
                if $g.behind   > 0 { $parts = ($parts | append $"(ansi {fg: $p.behind})⇣($g.behind)($rs)") }
                if $g.conflict > 0 { $parts = ($parts | append $"(ansi {fg: $p.err})~($g.conflict)($rs)") }
                if $g.staged   > 0 { $parts = ($parts | append $"(ansi {fg: $p.ok})+($g.staged)($rs)") }
                if $g.modified > 0 { $parts = ($parts | append $"(ansi {fg: $p.modified})!($g.modified)($rs)") }
                if $g.untracked > 0 { $parts = ($parts | append $"(ansi {fg: $p.untracked})?($g.untracked)($rs)") }
                let tail = (if ($parts | is-empty) { "" } else { $" ($parts | str join ' ')" })
                $"  (ansi {fg: $hc})(git-head $g)($rs)($tail)"
            } else { "" }
            $"(ansi {fg: $p.path attr: b})($full_dir)($rs)($git_txt)\n"
        }
        "fish" => {
            let g = (git-info)
            let rs = (ansi reset)
            let git_txt = if $g.present {
                mut parts = []
                if $g.staged   > 0 { $parts = ($parts | append $"(ansi {fg: $p.ok})●($g.staged)($rs)") }
                if $g.modified > 0 { $parts = ($parts | append $"(ansi {fg: $p.modified})✚($g.modified)($rs)") }
                if $g.untracked > 0 { $parts = ($parts | append $"(ansi {fg: $p.untracked})…($g.untracked)($rs)") }
                if $g.conflict > 0 { $parts = ($parts | append $"(ansi {fg: $p.err})✖($g.conflict)($rs)") }
                let st = (if ($parts | is-empty) { $"(ansi {fg: $p.ok})✔($rs)" } else { $parts | str join "" })
                $" (ansi {fg: $p.sep})\((ansi {fg: $p.git})(git-head $g)(ansi {fg: $p.sep})|($st)(ansi {fg: $p.sep})\)($rs)"
            } else { "" }
            $"(ansi {fg: $p.user})(prompt-user)(ansi {fg: $p.sep})@(ansi {fg: $p.host})(prompt-host)($rs) (ansi {fg: $p.path attr: b})($full_dir)($rs)($git_txt)"
        }
        "steeef" => {
            let g = (git-info)
            let rs = (ansi reset)
            let git_txt = if $g.present {
                mut marks = ""
                if $g.staged   > 0 { $marks = $marks + $"(ansi {fg: $p.ok})●($rs)" }
                if $g.modified > 0 { $marks = $marks + $"(ansi {fg: $p.err})●($rs)" }
                if $g.untracked > 0 { $marks = $marks + $"(ansi {fg: $p.modified})●($rs)" }
                $" (ansi {fg: $p.git attr: b})[(git-head $g)($marks)(ansi {fg: $p.git attr: b})]($rs)"
            } else { "" }
            $"(ansi {fg: $p.git attr: b})(prompt-user)($rs) (ansi {fg: $p.sep})at($rs) (ansi {fg: $p.host attr: b})(prompt-host)($rs) (ansi {fg: $p.sep})in($rs) (ansi {fg: $p.path attr: b})($full_dir)($rs)($git_txt)\n"
        }
        "fino" => {
            let g = (git-info)
            let rs = (ansi reset)
            let git_txt = if $g.present {
                let dirty = (if $g.clean { "" } else { $" (ansi {fg: $p.err attr: b})✗($rs)" })
                $" (ansi {fg: $p.sep})on($rs) (ansi {fg: $p.git})git:(ansi {fg: $p.behind attr: b})(git-head $g)($rs)($dirty)"
            } else { "" }
            let l1 = $"(ansi {fg: $p.sep})╭─($rs) (ansi {fg: $p.git attr: b})(prompt-user)($rs) (ansi {fg: $p.sep})at($rs) (ansi {fg: $p.host attr: b})(prompt-host)($rs) (ansi {fg: $p.sep})in($rs) (ansi {fg: $p.path attr: b})($full_dir)($rs)($git_txt)"
            $"($l1)\n(ansi {fg: $p.sep})╰─($rs)"
        }
        "heist" => {
            let g = (git-info)
            let rs = (ansi reset)
            let n = (dirty-count $g)
            let red = (ansi {fg: $p.err attr: b})
            let status = (if $n > 0 { $"($red)ALERT ×($n)($rs)" } else { $"(ansi {fg: $p.user attr: b})ALL CLEAR($rs)" })
            let br = (if $g.present { $" ($red)◣(ansi {fg: $p.git attr: b}) (git-head $g) ($red)◥($rs)" } else { $" ($red)◤($rs)" })
            $"($red)◢($rs)(ansi {fg: $p.fg attr: b}) ($full_dir)($rs)($br)  ($status)"
        }
        "vessel" => {
            let g = (git-info)
            let rs = (ansi reset)
            let lost = ([(dirty-count $g) 4] | math min)
            let masks = $"(ansi {fg: $p.fg})(repeat-str '●' (5 - $lost))(ansi {fg: $p.sep})(repeat-str '○' $lost)($rs)"
            let br = (if $g.present { $" (ansi {fg: $p.git})(git-head $g)($rs)" } else { "" })
            let soul = (if $g.present and $g.ahead > 0 { $"  (ansi {fg: $p.ahead})◐($g.ahead)($rs)" } else { "" })
            let shards = (if $g.present and $g.untracked > 0 { $"  (ansi {fg: $p.modified})◈($g.untracked)($rs)" } else { "" })
            $"($masks) (ansi {fg: $p.path attr: b})($full_dir)($rs)($br)($soul)($shards)"
        }
        "portals" => {
            let g = (git-info)
            let rs = (ansi reset)
            let died = (($env.LAST_EXIT_CODE? | default 0) != 0)
            let orange = (ansi {fg: $p.host attr: b})
            let blue = (ansi {fg: $p.path attr: b})
            let br = (if $g.present { $" (ansi {fg: $p.sep})⇄($rs) ($blue)◖(ansi {fg: $p.fg})(git-head $g)($blue)◗($rs)" } else { "" })
            let delta = (if $g.present and $g.modified + $g.staged > 0 { $" (ansi {fg: $p.modified})Δ($g.modified + $g.staged)($rs)" } else { "" })
            let fail = (if $died { $"(ansi {fg: $p.err attr: b})TEST FAILED($rs) " } else { "" })
            $"($fail)($orange)◖(ansi {fg: $p.fg})($full_dir)($orange)◗($rs)($br)($delta)"
        }
        "bonfire" => {
            let g = (git-info)
            let rs = (ansi reset)
            let n = (dirty-count $g)
            let died = (($env.LAST_EXIT_CODE? | default 0) != 0)
            let state = (if $died { $"(ansi {fg: $p.err attr: b})FALLEN($rs)" } else if $n == 0 { $"(ansi {fg: $p.host})lit($rs)" } else { $"(ansi {fg: $p.sep})embers ×($n)($rs)" })
            let br = (if $g.present { $" (ansi {fg: $p.sep})⟨(ansi {fg: $p.git})(git-head $g)(ansi {fg: $p.sep})⟩($rs)" } else { "" })
            $"(ansi {fg: $p.host attr: b})♨($rs) (ansi {fg: $p.fg attr: b})($full_dir)($rs)($br) ($state)"
        }
        "farmstead" => {
            let g = (git-info)
            let rs = (ansi reset)
            let day = (prompt-date)
            let crops = (if $g.present and $g.ahead > 0 { $" (ansi {fg: $p.ok})(repeat-str '❀' ([$g.ahead 5] | math min))($rs)" } else { "" })
            let br = (if $g.present { $"  (ansi {fg: $p.ok})⚘ (git-head $g)($rs)" } else { "" })
            $"(ansi {fg: $p.user attr: b})☀ ($day)($rs)  (ansi {fg: $p.path attr: b})⌂ ($full_dir)($rs)($br)($crops)"
        }
        "versus" => {
            let g = (git-info)
            let rs = (ansi reset)
            let n = (dirty-count $g)
            let died = (($env.LAST_EXIT_CODE? | default 0) != 0)
            let hp = (8 - ([$n 8] | math min))
            let col = (if $hp >= 5 { $p.ok } else if $hp >= 3 { $p.modified } else { $p.err })
            let tag = (if $died { $"  (ansi {fg: $p.err attr: b})K.O.($rs)" } else if $n == 0 { $"  (ansi {fg: $p.modified attr: b})FIGHT!($rs)" } else { "" })
            let br = (if $g.present { $" (ansi {fg: $p.git})(git-head $g)($rs)" } else { "" })
            $"(ansi {fg: $p.err attr: b})1P($rs) (barn $hp 8 $col) (ansi {fg: $p.path attr: b})($full_dir)($rs)($br)($tag)"
        }
        "boons" => {
            let g = (git-info)
            let rs = (ansi reset)
            let br = (if $g.present { $"  (ansi {fg: $p.git attr: b})♆ (git-head $g)($rs)" } else { "" })
            mut b = []
            if $g.present and $g.staged > 0 { $b = ($b | append $"(ansi {fg: $p.ok})✦×($g.staged)($rs)") }
            if $g.present and $g.modified > 0 { $b = ($b | append $"(ansi {fg: $p.modified})⚔×($g.modified)($rs)") }
            if $g.present and $g.untracked > 0 { $b = ($b | append $"(ansi {fg: $p.untracked})◇×($g.untracked)($rs)") }
            let boons = (if ($b | is-empty) { "" } else { $"  ($b | str join ' ')" })
            $"(ansi {fg: $p.user attr: b})❦($rs) (ansi {fg: $p.fg attr: b})($full_dir)($rs)($br)($boons)"
        }
        "climb" => {
            let g = (git-info)
            let rs = (ansi reset)
            let dashes = (if $g.present and $g.conflict > 0 { 0 } else if $g.present and not $g.clean { 1 } else { 2 })
            let br = (if $g.present { $"  (ansi {fg: $p.git})(git-head $g)($rs)" } else { "" })
            let berries = (if $g.present and $g.untracked > 0 { $"  (ansi {fg: $p.err})✿×($g.untracked)($rs)" } else { "" })
            $"(ansi {fg: $p.path attr: b})⛰ ($full_dir)($rs)($br)  (ansi {fg: $p.ahead})(repeat-str '»' $dashes)(ansi {fg: $p.sep})(repeat-str '·' (2 - $dashes))($rs)($berries)"
        }
        "skillcheck" => {
            let g = (git-info)
            let rs = (ansi reset)
            let n = (dirty-count $g)
            let died = (($env.LAST_EXIT_CODE? | default 0) != 0)
            let check = if $died { { t: "Volition: Failure", c: $p.err }
            } else if ($g.present and $g.conflict > 0) { { t: "Composure: Failure", c: $p.err }
            } else if $n == 0 { { t: "Perception: Success", c: $p.ok }
            } else { { t: $"Logic: Medium ($n)", c: $p.modified } }
            let br = (if $g.present { $" (ansi {fg: $p.git})(git-head $g)($rs)" } else { "" })
            $"(ansi {fg: $check.c attr: b})[($check.t)]($rs) (ansi {fg: $p.fg})($full_dir)($rs)($br)"
        }
        "hotbar" => {
            let g = (git-info)
            let rs = (ansi reset)
            let n = (dirty-count $g)
            let lost = ([($n // 2) 4] | math min)
            let hearts = $"(ansi {fg: $p.err})(repeat-str '♥' (5 - $lost))(ansi {fg: $p.sep})(repeat-str '♡' $lost)($rs)"
            let slots = ([$n 5] | math min)
            let bar = $"(ansi {fg: $p.ok})▕(repeat-str '▮' $slots)(ansi {fg: $p.sep})(repeat-str '▯' (5 - $slots))(ansi {fg: $p.ok})▏($rs)"
            let br = (if $g.present { $" (ansi {fg: $p.git})⚒ (git-head $g)($rs)" } else { "" })
            $"($hearts) ($bar) (ansi {fg: $p.path attr: b})($full_dir)($rs)($br)"
        }
        _ => {
            let user_host = $"(ansi {fg: $p.user})(prompt-user)(ansi {fg: $p.sep})@(ansi {fg: $p.host})(prompt-host)(ansi reset)"
            $"($user_host) (ansi {fg: $p.sep})in (ansi {fg: $p.path attr: b})($full_dir)(ansi reset)(git-segment --counts)"
        }
    }
}

def right-prompt-core [] {
    # HUD-style prompts are already full; they opt out of the right prompt.
    if ((style-def ($env.PROMPT_STYLE? | default "full")).right? | default "time") == "none" { return "" }
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
def indicator-core [] {
    let p = $env.THEME_PALETTE
    let ok = (($env.LAST_EXIT_CODE? | default 0) == 0)
    let def = (style-def ($env.PROMPT_STYLE? | default "full"))
    let glyph = $def.glyph
    let color = if $ok { $p | get $def.tone } else { $p.err }
    $"(ansi {fg: $color attr: b})($glyph) (ansi reset)"
}


