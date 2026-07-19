# nuance

![platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-blue)
![nushell](https://img.shields.io/badge/nushell-%E2%89%A50.101-4E9A06)
![themes](https://img.shields.io/badge/themes-26-cba6f7)
![styles](https://img.shields.io/badge/prompt%20styles-22-89b4fa)
![license](https://img.shields.io/badge/license-MIT-green)
![ci](https://github.com/sorinirimies/nuance/actions/workflows/ci.yml/badge.svg)

**nuance** *(nu + nuance — the subtle differences between colors)* is a
themeable, git-aware prompt for [Nushell](https://www.nushell.sh), shipped as a
single drop-in file. Switch between **26 color themes** and **22 prompt
styles**, combine them into named **looks**, and optionally let the shell
**follow your terminal's theme** automatically. macOS · Linux · WSL.

![nuance demo](docs/welcome.gif)

> **See every theme, style and look in the [gallery →](GALLERY.md)**

## Installation

**No Nushell yet?** One command installs Nushell *and* nuance:

```sh
curl -fsSL https://raw.githubusercontent.com/sorinirimies/nuance/main/bootstrap.sh | bash
```

…or with `wget`:

```sh
wget -qO- https://raw.githubusercontent.com/sorinirimies/nuance/main/bootstrap.sh | bash
```

The bootstrap installs Nushell via your package manager (Homebrew / apt /
pacman / dnf / zypper / cargo) or a prebuilt binary, then wires up the prompt.

**Already have Nushell?**

```sh
git clone https://github.com/sorinirimies/nuance
cd nuance
nu install.nu          # symlink (repo stays the source of truth) — or --copy
```

Then open a new shell (or `exec nu`). A [Nerd Font](https://www.nerdfonts.com/)
is recommended for the glyph styles (or set `$env.PROMPT_NERD = false`).

## Theming & styling

```nu
nuance                 # help — list every command
nuance theme           # show ALL themes (swatches); add a name to set + pin one
nuance theme dracula   # …e.g. set + pin dracula
nuance prompt-style    # show ALL styles; add a name to set one
nuance look            # list looks; add a name to apply one (theme + style)
nuance update          # git pull the checkout, then: exec nu
```

Short forms (same effect): `theme [name]` · `prompt-style [name]` ·
`look [name]` · `theme-sync` · `theme-preview` · `style-preview`. These also
work from a normal shell via the `nuance` CLI — selections apply to your next
Nushell (`exec nu`).

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
`theme-sync` re-enables auto-follow.

![theme-sync](docs/sync.gif)

## Updating

Run **`nuance update`** — it works both inside Nushell (built-in command) and
in any normal shell (a `nuance` CLI is installed to `~/.local/bin`):

```sh
nuance update      # pulls the checkout; then run: exec nu
```

Or `cd` into the repo and `git pull` (symlink installs apply on the next
shell). Copy/bootstrap installs: re-run the bootstrap one-liner.

## Cross-platform & tested

One pure-Nushell file, no OS-specific dependencies. Paths resolve via Nushell
built-ins; the Ghostty config is found at `~/.config/ghostty/config` or the
macOS `Library/…` path; light/dark detection uses macOS `defaults` or GNOME
`gsettings`. Two test suites run in CI on **Ubuntu + macOS** across Nushell
**0.111** and **0.114** — `nu test.nu` (themes/styles/looks/helpers) and
`bats test.bats` (the POSIX `nuance` CLI):

```sh
nu test.nu       # ✓ all checks passed — 26 themes, 22 styles, 31 looks
bats test.bats   # ✓ 8 CLI tests
```

## How it works

`install.nu` places `nushell-prompt.nu` in your Nushell autoload dir
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
tapes in [`tapes/`](tapes) — e.g. `vhs tapes/demo.tape`. Run `nu test.nu` and
`bats test.bats` before opening a PR.

## License

MIT
