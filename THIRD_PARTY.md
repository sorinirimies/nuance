# Third-party credits

nuance's themes are colour palettes. Many of them reproduce, or are adapted
from, well-known open-source colour schemes — thank you to their authors. The
palettes below are used here as plain colour values to restyle a terminal
prompt; no code from these projects is included.

> The licence column lists the licence of the upstream project **as far as we
> know it**. Please check the upstream repository before relying on it, and
> open an issue if anything here is wrong or missing.

| nuance theme(s) | Upstream | Author / project | Licence |
|---|---|---|---|
| `catppuccin-mocha`, `-macchiato`, `-frappe`, `-latte` | [catppuccin/catppuccin](https://github.com/catppuccin/catppuccin) | Catppuccin | MIT |
| `gruvbox`, `gruvbox-light` | [morhetz/gruvbox](https://github.com/morhetz/gruvbox) | Pavel Pertsev | MIT |
| `gruvbox-material` | [sainnhe/gruvbox-material](https://github.com/sainnhe/gruvbox-material) | sainnhe | MIT |
| `tokyo-night`, `-storm`, `-moon`, `-day` | [folke/tokyonight.nvim](https://github.com/folke/tokyonight.nvim) | folke | Apache-2.0 |
| `nord` | [nordtheme/nord](https://github.com/nordtheme/nord) | Arctic Ice Studio / Sven Greb | MIT |
| `dracula` | [dracula/dracula-theme](https://github.com/dracula/dracula-theme) | Zeno Rocha et al. | MIT |
| `rose-pine`, `-moon`, `-dawn` | [rose-pine/rose-pine-theme](https://github.com/rose-pine/rose-pine-theme) | Rosé Pine | MIT |
| `everforest` | [sainnhe/everforest](https://github.com/sainnhe/everforest) | sainnhe | MIT |
| `sonokai` | [sainnhe/sonokai](https://github.com/sainnhe/sonokai) | sainnhe | MIT |
| `kanagawa`, `-dragon`, `-lotus` | [rebelot/kanagawa.nvim](https://github.com/rebelot/kanagawa.nvim) | rebelot | MIT |
| `onedark`, `one-light` | [joshdick/onedark.vim](https://github.com/joshdick/onedark.vim) / Atom One | Joshua Dick / GitHub | MIT |
| `monokai` | Monokai | Wimer Hazenberg | inspired by (no explicit licence) |
| `ayu-dark`, `ayu-mirage` | [ayu-theme/ayu-colors](https://github.com/ayu-theme/ayu-colors) | Ike Ku | MIT |
| `night-owl` | [sdras/night-owl-vscode-theme](https://github.com/sdras/night-owl-vscode-theme) | Sarah Drasner | MIT |
| `github-dark`, `github-light` | [primer/github-vscode-theme](https://github.com/primer/github-vscode-theme) | GitHub | MIT |
| `oxocarbon` | IBM Carbon design system / [nyoom-engineering/oxocarbon](https://github.com/nyoom-engineering/oxocarbon) | IBM / nyoom-engineering | inspired by |
| `zenburn` | Zenburn | Jani Nurminen | inspired by |
| `solarized`, `solarized-light` | [altercation/solarized](https://github.com/altercation/solarized) | Ethan Schoonover | MIT |
| `nightfox`, `dawnfox` | [EdenEast/nightfox.nvim](https://github.com/EdenEast/nightfox.nvim) | EdenEast | MIT |
| `flexoki`, `flexoki-light` | [kepano/flexoki](https://github.com/kepano/flexoki) | Steph Ango | MIT |
| `melange` | [savq/melange-nvim](https://github.com/savq/melange-nvim) | savq | MIT |
| `nightfly` | [bluz71/vim-nightfly-colors](https://github.com/bluz71/vim-nightfly-colors) | bluz71 | MIT |
| `material-palenight` | Material Theme / palenight | Mattia Astorino, Jonathan Speek | MIT |
| `tomorrow-night` | [chriskempson/tomorrow-theme](https://github.com/chriskempson/tomorrow-theme) | Chris Kempson | MIT |
| `snazzy` | [sindresorhus/hyper-snazzy](https://github.com/sindresorhus/hyper-snazzy) | Sindre Sorhus | MIT |
| `iceberg` | [cocopon/iceberg.vim](https://github.com/cocopon/iceberg.vim) | cocopon | MIT |
| `papercolor-light` | [NLKNguyen/papercolor-theme](https://github.com/NLKNguyen/papercolor-theme) | Nguyen Nguyen | MIT |
| `synthwave-84` | [robb0wen/synthwave-vscode](https://github.com/robb0wen/synthwave-vscode) | Robb Owen | MIT |
| `cobalt2` | [wesbos/cobalt2](https://github.com/wesbos/cobalt2) | Wes Bos | MIT |
| `modus-vivendi`, `modus-operandi` | Modus themes | Protesilaos Stavrou | GPL-3.0-or-later (palette inspiration) |
| `horizon` | [jolaleye/horizon-theme-vscode](https://github.com/jolaleye/horizon-theme-vscode) | jolaleye | MIT |

**Original palettes.** `cyberpunk` and the game-inspired themes and styles
(`super-mario`, `clair-obscur`, `pip-boy`, `tarnished`, `hyrule`, `doom`,
`phantom`, `cavern-hush`, `test-chamber`, `ember`, `meadow`, `dojo`,
`underworld`, `summit`, `rain-noir`, `blocky`, …) are original colour choices
and layouts made for nuance. They are unofficial homages: nuance is not
affiliated with or endorsed by any game publisher or studio, and game names are
trademarks of their respective owners. No game art, logos, fonts or text assets
are used.

**Prompt styles** that echo other prompt frameworks (`robbyrussell`, `ys`,
`avit`, `bira`, `af-magic`, `cloud`, `steeef`, `fino` from oh-my-zsh;
`spaceship`; `p10k-lean`; `fish`; `agnoster`) are independent re-creations of
their general *layout idea* — no code is copied.

**Importing.** `nuance import` reads Ghostty, kitty, Alacritty and base16
colour-scheme files that you provide; those remain under their own licences.

## Software dependencies

nuance-cli is MIT-licensed. Its Rust dependencies (`clap`, `clap_complete`,
`ratatui`, `crossterm`, `serde`, `serde_json`, and their transitive
dependencies) are listed with exact versions in `Cargo.lock`; each is available
under its own permissive licence (MIT and/or Apache-2.0).
