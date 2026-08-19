# nuance

![platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-blue)
![nushell](https://img.shields.io/badge/nushell-%E2%89%A50.101-4E9A06)
![themes](https://img.shields.io/badge/themes-26-cba6f7)
![styles](https://img.shields.io/badge/prompt%20styles-22-89b4fa)
![license](https://img.shields.io/badge/license-MIT-green)
![ci](https://github.com/sorinirimies/nuance/actions/workflows/ci.yml/badge.svg)
![crates.io](https://img.shields.io/crates/v/nuance-cli.svg)

**nuance** *(nu + nuance — the subtle differences between colors)* is a
themeable, git-aware prompt for [Nushell](https://www.nushell.sh), shipped as a
single drop-in file. Switch between **26 color themes** and **22 prompt
styles**, combine them into named **looks**, and optionally let the shell
**follow your terminal's theme** automatically. macOS · Linux · WSL.

![nuance demo](docs/welcome.gif)

> **See every theme, style and look in the [gallery →](GALLERY.md)**

## Installation

Two ways to get `nuance` — no bash scripts involved either way, just
`cargo` or plain Nushell:

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

**Already have Nushell?** Clone the repo and symlink `nushell-prompt.nu`
straight into Nushell's autoload dir with the pure-Nushell installer — the
repo stays the source of truth, and `nu scripts/install.nu` / `nuance update`
(git pull) both work against it:

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
  classics like `robbyrussell`/`ys`, game-inspired `mario`/`8bit`, neon
  `cyberpunk`, …), independent of the colors.
- A **look** pins a theme + style together and overrides Ghostty auto-follow.
- The **git segment** shows branch, `⇡`ahead `⇣`behind `=`conflict `+`staged
  `!`modified `?`untracked `*`stash, `✔` clean — plus command duration (>2s)
  and an exit-status-aware indicator.

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
`cargo test` (the `nuance` CLI/TUI, 39 unit + integration tests):

```sh
nu test.nu       # ✓ all checks passed — 26 themes, 22 styles, 31 looks
cargo test       # ✓ 39 passed (cli.rs, ansi.rs, nu.rs, tui.rs, tests/cli.rs)
```

## How it works

`scripts/install.nu` places `nushell-prompt.nu` in your Nushell autoload dir
(`~/Library/Application Support/nushell/autoload` on macOS,
`~/.config/nushell/autoload` on Linux) — it loads automatically without
touching your `config.nu`, and nothing runs but a prompt. Selections persist in
`current-theme.txt` / `prompt-style.txt` in your Nushell config dir.

**Add a theme:** add a palette + `color_config` in `nushell-prompt.nu`, then
register it in `theme-list` and `theme-get`. The prompt reads accent colors
from the theme's `palette`, so it restyles automatically.

**Toggles:** `$env.PROMPT_NERD` (Nerd Font glyphs on/off) ·
`$env.PROMPT_USER` / `$env.PROMPT_HOST` (override shown user/host).

## Contributing / demos

GIFs are recorded with [VHS](https://github.com/charmbracelet/vhs) from the
tapes in [`tapes/`](tapes) — e.g. `vhs tapes/demo.tape` (or `tapes/cli.tape`
for the `nuance-cli` picker). Run `nu test.nu` and `cargo test` before
opening a PR.

There's also a [`justfile`](justfile) (`cargo install just`) wrapping the
common tasks — `just --list` to see them all: `just check-all` (fmt +
clippy + both test suites), `just changelog`, `just tape welcome`,
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
