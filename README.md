# nuance

![platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-blue)
![nushell](https://img.shields.io/badge/nushell-%E2%89%A50.101-4E9A06)
![themes](https://img.shields.io/badge/themes-69-cba6f7)
![styles](https://img.shields.io/badge/prompt%20styles-50-89b4fa)
![license](https://img.shields.io/badge/license-MIT-green)
![ci](https://github.com/sorinirimies/nuance/actions/workflows/ci.yml/badge.svg)
![crates.io](https://img.shields.io/crates/v/nuance-cli.svg)
[![Downloads](https://img.shields.io/crates/d/nuance-cli?label=downloads)](https://crates.io/crates/nuance-cli)

**nuance** *(nu + nuance — the subtle differences between colors)* is a
themeable, git-aware prompt for [Nushell](https://www.nushell.sh), shipped as a
single drop-in file. Switch between **69 color themes** and **50 prompt
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
nuance sync            # follow the terminal's theme (auto-follow)
nuance update          # git pull the checkout, then: exec nu
```

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
- **Game-flavoured looks** turn git state into a game mechanic, with original
  genre-inspired palettes and generic names:
  `hud-run` (NES-style HUD + brick ground), `shelter` (retro terminal HP/☢),
  `sanctum` (HP/FP/stamina bars, FALLEN on failure), `heist` (ALERT/ALL CLEAR),
  `vessel` (mask health), `portals`, `bonfire`, `farmstead`, `versus`
  (fighting-game health bar), `boons`, `climb`, `skillcheck`, `hotbar`,
  `marine` (FPS status bar), `trifold`, `ornate`/`petals` (Belle Époque), and
  `cyberpunk`. Try `look phantom`, `look ember`, `look cave-run`, …

  ![game looks](docs/games.gif)

  > **Trademarks.** nuance is not affiliated with or endorsed by any game
  > publisher or studio. The game-flavoured themes and styles are original,
  > genre-inspired designs (colors, Unicode glyphs, git-state mappings); they
  > use no game names, logos, art or text. Earlier names (`mario`, `hyrule`,
  > `doom`, …) were renamed — old names still resolve to the new ones.
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
  `nix`, `lang` (rust/node/python/go/ruby/zig + version, cached) and `k8s`.
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
(themes/styles/looks/helpers, across Nushell **0.111** and **0.114**) and
`cargo test` (the `nuance` CLI/TUI, 48 unit + integration tests):

```sh
nu test.nu       # ✓ all checks passed — 69 themes, 50 styles, 72 looks
cargo test       # ✓ 48 passed (cli.rs, ansi.rs, nu.rs, tui.rs, tests/cli.rs)
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

Project layout: `nushell-prompt.nu` (the prompt itself) + `src/` (the
`nuance-cli` crate: `clap` + `ratatui`, self-contained — vendors the prompt
script via `include_str!`) + `scripts/` (pure Nushell: `install.nu`/
`uninstall.nu`, for installs without Rust/Cargo) + `tapes/`, `docs/`
(VHS-recorded GIFs/screenshots), `test.nu`, `tests/` (Rust integration
tests).

## Changelog

See [CHANGELOG.md](CHANGELOG.md) (generated with
[git-cliff](https://git-cliff.org) — config: [cliff.toml](cliff.toml)).

## License

MIT
