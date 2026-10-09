# nuance

![platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-blue)
![nushell](https://img.shields.io/badge/nushell-%E2%89%A50.101-4E9A06)
![themes](https://img.shields.io/badge/themes-72-cba6f7)
![styles](https://img.shields.io/badge/prompt%20styles-50-89b4fa)
![license](https://img.shields.io/badge/license-MIT-green)
![ci](https://github.com/sorinirimies/nuance/actions/workflows/ci.yml/badge.svg)
![crates.io](https://img.shields.io/crates/v/nuance-cli.svg)
[![Downloads](https://img.shields.io/crates/d/nuance-cli?label=downloads)](https://crates.io/crates/nuance-cli)

**nuance** *(nu + nuance — the subtle differences between colors)* is a
themeable, git-aware prompt for [Nushell](https://www.nushell.sh), shipped as a
single drop-in file. Switch between **72 color themes** and **50 prompt
styles**, combine them into named **looks**, and optionally let the shell
**follow your terminal's theme** automatically. macOS · Linux · WSL.

![nuance demo](docs/welcome.gif)

> **See every theme, style and look in the [gallery →](GALLERY.md)**

## Installation

Three ways to get `nuance` — no bash scripts checked into this repo either
way, just `cargo`, plain Nushell, or a curl/wget one-liner:

**Have Rust/Cargo?**

```sh
cargo install nuance-cli
nuance theme            # first run vendors the prompt into Nushell's autoload dir
```

This gives you a `nuance` binary usable from any shell. Running any
subcommand (`theme`, `prompt-style`, `look`, …) the first time vendors the
prompt into Nushell's autoload dir — no clone, no separate installer script.
If Nushell itself isn't installed yet, `nuance` offers to `cargo install nu`
for you. It ships its own `ratatui` picker with an instant live preview per
candidate:

![nuance-cli picker](docs/cli.gif)

See the crate's docs on [crates.io](https://crates.io/crates/nuance-cli) for
details. No cargo? Prebuilt binaries are attached to every
[release](https://github.com/sorinirimies/nuance/releases) — download the
tarball for your OS/arch, extract `nuance`, put it on your `PATH`.

**Already have Nushell?** No clone needed — curl or wget the pure-Nushell
installer and run it directly (downloads to a real file first, so it runs
as a proper script rather than inline code — no bash involved, just `nu`
itself executing a `.nu` file):

```sh
curl -fsSL https://raw.githubusercontent.com/sorinirimies/nuance/main/scripts/install.nu -o /tmp/nuance-install.nu && nu /tmp/nuance-install.nu
```

…or with `wget`:

```sh
wget -qO /tmp/nuance-install.nu https://raw.githubusercontent.com/sorinirimies/nuance/main/scripts/install.nu && nu /tmp/nuance-install.nu
```

This clones the repo into a cache dir (skipping the demo GIFs over LFS) and
symlinks `nushell-prompt.nu` into Nushell's autoload dir — the same thing
`scripts/install.nu` does from a real clone. Prefer to clone yourself so the
repo stays the source of truth (and `nuance update` / `git pull` work
against it directly)?

```sh
# GIT_LFS_SKIP_SMUDGE=1 skips the demo GIFs (LFS) — a ~1s clone instead of ~1min
GIT_LFS_SKIP_SMUDGE=1 git clone https://github.com/sorinirimies/nuance
cd nuance
nu scripts/install.nu   # symlink (repo stays the source of truth) — or --copy
```

Then open a new shell (or `exec nu`). A [Nerd Font](https://www.nerdfonts.com/)
is recommended for the glyph styles (or set `$env.PROMPT_NERD = false`).

## Theming & styling

```nu
nuance                 # help — list every command
nuance theme           # ↑↓ selector (top entry: ↻ sync with terminal), or set + pin a name
nuance theme dracula   # …e.g. set + pin dracula
nuance prompt-style    # ↑↓ selector, or set a name
nuance look            # list looks; add a name to apply one (theme + style)
nuance transient on    # collapse finished prompts to a single ❯ (off / toggle)
nuance modules         # list situational segments; enable lang status jobs …
nuance configure       # guided setup: look → transient prompt → modules
nuance doctor          # check nu version, truecolor, Nerd Font, install, state
nuance import <file|ghostty-theme-name> [--name x]   # ghostty/kitty/alacritty/base16 → theme
nuance here dracula powerline   # pin a theme/style to this directory tree (.nuance)
nuance list [themes|styles|looks|modules] [--json]   # what is available
nuance current [--json]       # the active theme, style and options
nuance preview nord pastel    # render a prompt without applying anything
nuance random [look|theme|style]   # surprise me (and pin the pick)
nuance appearance dracula tokyo-night-day   # follow the OS dark/light mode (off to stop)
nuance export                 # share string for your look…
nuance import "nuance:1:nord:pastel:lang+jobs:on"   # …and apply one on another machine
nuance integration [on|off]   # window title, cwd reporting, semantic prompt marks
nuance style new mine         # create your own segment style
nuance sync            # follow the terminal's theme (auto-follow)
nuance update          # git pull the checkout, then: exec nu
nuance uninstall [--purge]    # remove nuance from Nushell's autoload dir
nuance completions zsh        # shell completions for the CLI (bash, zsh, fish, …)
```

`theme`, `look`, `prompt-style`, `modules`, … **tab-complete** inside Nushell.

Short forms (same effect): `theme [name]` · `prompt-style [name]` ·
`look [name]` · `theme-sync` · `theme-preview` · `style-preview`. These also
work from a normal shell via the `nuance` CLI (`cargo install nuance-cli`) —
selections apply to your next Nushell (`exec nu`).

Running `nuance theme` / `nuance prompt-style` (or the short `theme` /
`prompt-style`) with **no name** opens an interactive selector — arrow keys
↑↓ to browse (themes show a color chip), Enter to apply:

![interactive picker](docs/picker.gif)

- **Themes** recolor syntax highlighting, tables **and** the prompt.
- **Styles** are prompt *layouts* (minimal, powerline, two-line, oh-my-zsh
  classics like `robbyrussell`/`ys`/`steeef`/`fino`, framework clones
  `spaceship`/`p10k-lean`/`fish`, …), independent of the colors.
- **Game-inspired looks** turn git state into a game mechanic:
  Clair Obscur: Expedition 33 (`expedition33`, `gommage`), Super Mario (`mario`
  HUD), Fallout (`vault`), Elden Ring (`grace`), Zelda (`triforce`), DOOM
  (`doomguy`), plus `heist`, `vessel`, `portals`, `bonfire`, `farmstead`,
  `versus`, `boons`, `climb`, `skillcheck`, `hotbar` and `cyberpunk`. Try
  `look expedition-33`, `look mario-underground`, `look phantom`, `look ember`, …

  ![game looks](docs/games.gif)

  > **Trademarks.** nuance is an unofficial fan project and is not affiliated
  > with or endorsed by any game publisher or studio. Game names are
  > trademarks of their respective owners. The themes and styles are original
  > palettes and layouts (colors, Unicode glyphs, git-state mappings); no game
  > art, logos, fonts or text assets are used.
- A **look** pins a theme + style together and overrides Ghostty auto-follow.
- The **git segment** shows branch, `⇡`ahead `⇣`behind `=`conflict `+`staged
  `!`modified `?`untracked `*`stash, `✔` clean — plus command duration (>2s)
  and an exit-status-aware indicator. In-progress operations show next to the
  branch (`main|REBASE 2/5`, `main|MERGING`, `|CHERRY-PICKING`, `|BISECTING`).
  Git state comes from a single `git status --porcelain=v2` call (about 4×
  faster than before), and linked worktrees/submodules are detected.
- **Adaptive paths:** long directories shorten fish-style to fit a third of the
  terminal width (`~/Projects/some/long/path` → `~/P/s/long/path`, falling back to
  `…/parent/dir`). Tune with `$env.PROMPT_DIR_MAX` (`0` = never shorten).
- **No Nerd Font?** Segment styles degrade to ASCII separators (`>`, `/`, `( )`)
  when `$env.PROMPT_NERD = false`.

- **Readable by construction.** Every theme is checked against WCAG contrast
  (text ≥ 3:1, segment text ≥ 4.5:1) and out-of-range colors are nudged toward
  the theme's own foreground — so light themes and dim separators stay legible.
- **Transient prompt** (`nuance transient on`): once you press Enter, the old
  multi-segment prompt collapses to one colored glyph, keeping scrollback clean.

  ![transient prompt](docs/transient.gif)

- **Context modules** (`nuance modules enable lang jobs …`) add segments only
  when they matter: `status` (non-zero exit), `jobs`, `ssh`, `root`, `venv`,
  `nix`, `lang` (rust/node/python/go/ruby/zig + version, cached), `k8s`, `docker`
  (non-default context), `cloud` (AWS profile / GCP project), `pkg` (manifest
  version) and `battery`.
  Block styles (`powerline`, `capsule`, …) fold them in as extra segments;
  single-line styles append them as a colored tail. `pastel` and `devbar`
  include `lang`/`status`/`jobs` out of the box.

  ![context modules](docs/modules.gif)

- **Import any terminal theme** (`nuance import`): Ghostty, kitty, Alacritty
  (TOML) and base16 (YAML) color schemes become nuance themes, or pass a
  Ghostty theme *name* (e.g. `nuance import "Rose Pine Moon" --name rpm`).
  Imported themes live in `<nushell config>/nuance/themes/*.nuon`, show up in
  every picker, and get the same contrast guarantees. With auto-follow, an
  unknown Ghostty theme is imported automatically — so *all* of Ghostty's
  ~450 themes work.

  ![import and per-directory themes](docs/import-here.gif)

- **Per-directory themes** (`nuance here <theme> [style]`): a `.nuance` TOML
  file (`theme = "…"`, `style = "…"`) re-themes the prompt in that directory
  tree — handy to make prod checkouts look different. Only known theme/style
  names are read from it; it can never run code. `nuance here clear` removes it.
- **`nuance configure`** walks you through look → transient prompt → modules;
  **`nuance doctor`** diagnoses font/truecolor/install problems.

  ![nuance configure](docs/configure.gif)

  ![nuance doctor](docs/doctor.gif)

- **A prompt that can't break your shell.** Every renderer runs inside a safety
  net: on any error nuance logs it (shown by `nuance doctor`) and falls back to a
  plain prompt instead of leaving you with a broken one.
- **Any terminal.** Theme colors are truecolor; on terminals without it the
  prompt is rewritten to the nearest 256- or 16-color codes, and `NO_COLOR`
  turns color off (force a mode with `$env.NUANCE_COLORS`).
- **Terminal integration** (`nuance integration`): window title, working-directory
  reporting, clickable paths and semantic prompt marks (jump between prompts,
  copy the last command's output in Ghostty / kitty / WezTerm) — on by default,
  `nuance integration off` disables it.
- **Your own styles.** `nuance style new mine` writes
  `<config>/nuance/styles/mine.nuon` — pick a `shape` (`arrow`, `slant`, `pill`),
  the segments (`user host path git` plus any module: `status jobs ssh root venv
  nix lang k8s docker cloud pkg battery`), a glyph and a tone; it shows up in
  every picker like a built-in.
- **Big repositories.** `$env.PROMPT_GIT` = `full` | `light` | `off` (or
  `git = "off"` in a `.nuance`); a repo whose `git status` is slow is remembered
  for a day and scanned without untracked files. `nuance doctor --clear-errors`
  forgets.
- **Light/dark switching** (`nuance appearance <dark> <light>`) and **shareable
  looks** (`nuance export` / `nuance import "nuance:1:…"`).

  ![the toolbox: preview, custom styles, sharing](docs/toolbox.gif)

See every theme, style and look with previews → **[GALLERY.md](GALLERY.md)**.

## Ghostty auto-follow

By default the theme follows your [Ghostty](https://ghostty.org) config
(`theme = …`). Pick a theme/look manually to **pin** it (survives new shells);
**`nuance sync`** (or the ↻ *sync with terminal* entry in `nuance theme`)
re-enables auto-follow.

![theme-sync](docs/sync.gif)

## Updating

Run **`nuance update`** — it works both inside Nushell (built-in command) and
in any normal shell if you have the `nuance` CLI (`cargo install nuance-cli`):

```sh
nuance update      # pulls the checkout; then run: exec nu
```

Or `cd` into the repo and `git pull` (symlink installs apply on the next
shell). Prebuilt-binary installs: download the newer release tarball and
replace the binary on your `PATH`.

## Cross-platform & tested

One pure-Nushell file, no OS-specific dependencies. Paths resolve via Nushell
built-ins; the Ghostty config is found at `~/.config/ghostty/config` or the
macOS `Library/…` path; light/dark detection uses macOS `defaults` or GNOME
`gsettings`. Two suites run in CI on **Ubuntu + macOS** — `nu test.nu`
(themes/styles/looks/helpers, golden snapshots of 1,300 rendered prompts, across
Nushell **0.111**, **0.114** and nightly) and `cargo test` (the `nuance` CLI/TUI,
57 unit + integration tests):

```sh
nu test.nu       # ✓ all checks passed — 72 themes, 50 styles, 72 looks
cargo test       # ✓ 57 passed (cli.rs, ansi.rs, nu.rs, tui.rs, tests/cli.rs)
```

## How it works

`scripts/install.nu` places `nushell-prompt.nu` in your Nushell autoload dir
(`~/Library/Application Support/nushell/autoload` on macOS,
`~/.config/nushell/autoload` on Linux) — it loads automatically without
touching your `config.nu`, and nothing runs but a prompt. Selections persist in
`current-theme.txt` / `prompt-style.txt` in your Nushell config dir.

**Add a theme:** add a palette (11 hex colors: `fg gray red orange yellow green
cyan blue magenta purple bg`) to `EXTRA_THEMES` in `nushell-prompt.nu` — it is
picked up by `theme-list`, every picker and the tests automatically. Contrast
fixing and the per-segment text colors are derived for you (`finish-palette`).
Or skip the code entirely and `nuance import` a terminal color scheme.

**Add a prompt style:** add a row to `style-defs`. A `blocks` row
(`shape: arrow|slant|pill` + `segs: [user host path git status lang …]`) needs
no other code; a hand-written layout also gets a `match` arm in `render-left`.

**State** lives in your Nushell config dir: `current-theme.txt`,
`prompt-style.txt`, `transient.txt`, `modules.txt`, and `nuance/themes/*.nuon`
for imported themes.

**Toggles:** `$env.PROMPT_NERD` (Nerd Font glyphs on/off) ·
`$env.PROMPT_USER` / `$env.PROMPT_HOST` (override shown user/host) ·
`$env.PROMPT_DIR_MAX` (path-shortening budget) ·
`$env.NUANCE_THEMES_DIR` (where imported themes are stored).

## Contributing / demos

GIFs are recorded with [VHS](https://github.com/charmbracelet/vhs) from the
tapes in [`tapes/`](tapes) — e.g. `vhs tapes/demo.tape` (or `tapes/cli.tape`
for the `nuance-cli` picker). Run `nu test.nu` and `cargo test` before
opening a PR.

There's also a [`justfile`](justfile) (`cargo install just`) wrapping the
common tasks — `just --list` to see them all: `just check-all` (fmt +
clippy + both test suites), `just changelog`, `just tape welcome` / `just tapes-all` (re-record every demo GIF),
`just release 0.2.0`.

Project layout: `nu/*.nu` (the prompt itself, in numbered parts) →
`scripts/build_prompt.nu` concatenates them into the single drop-in
`nushell-prompt.nu` (**edit `nu/`, then `just build-prompt`** — `test.nu` fails if
the built file is stale) + `src/` (the `nuance-cli` crate: `clap` + `ratatui`,
self-contained — vendors the built prompt via `include_str!`) + `scripts/`
(installers, the gallery and golden-file generators) + `tapes/`, `docs/`
(VHS-recorded GIFs/screenshots), `test.nu`, `tests/` (Rust integration tests and
`tests/golden/prompts.txt`).

Changed how a prompt renders on purpose? `nu scripts/golden.nu --update` and review
the diff. Added a theme, style or look? `just gallery` regenerates `GALLERY.md`
(and `test.nu` checks the README counts).

## Changelog

See [CHANGELOG.md](CHANGELOG.md) (generated with
[git-cliff](https://git-cliff.org) — config: [cliff.toml](cliff.toml)).

## License

MIT. Theme palettes adapted from open-source colour schemes are credited in
[THIRD_PARTY.md](THIRD_PARTY.md).
