# Changelog

All notable changes to this project are documented here — generated with
[git-cliff](https://git-cliff.org) (config: [cliff.toml](cliff.toml)).

## [unreleased]

### 🚀 Features

- Add neon cyberpunk theme + pin/auto theme logic; pure-nu installer (drop install.sh)
- Add looks (theme+style presets), tokyo-night & nord themes, capsule style; theme picker now also selects style
- Add 7 themes (dracula, rose-pine, everforest, kanagawa, onedark, solarized, solarized-light) + 3 styles (bracket, slant, boxed); more looks; Ghostty mapping for new themes
- Add VHS demo GIFs (welcome/demo/styles/themes) via git-LFS + tapes; robust prompt-user/host; hide banner; link GIFs in README
- Add 10 themes (rose-pine moon/dawn, monokai, ayu dark/mirage, night-owl, github dark/light, oxocarbon, zenburn) + 2 styles (arrow, rainbow); 25 themes, 13 styles, 22 looks
- Add interactive picker + light-theme spotlight demo GIFs; link in README
- Add Super Mario theme + game-inspired styles (mario, arcade, 8bit) with games demo GIF; 26 themes, 16 styles, 25 looks
- Add theme-sync (Ghostty auto-follow) demo GIF + tape; link in README
- Add tests + CI (Ubuntu/macOS), theme-preview/style-preview + galleries, PROMPT_USER/PROMPT_HOST overrides, cross-platform dark-mode detection; sanitize demo identity to sorin@nuance
- Add POSIX bootstrap.sh (installs Nushell + nuance via curl/wget); add prominent Installation section after the intro
- Add 5 oh-my-zsh-inspired prompt styles (robbyrussell, ys, avit, bira, af-magic); 21 styles, 30 looks
- Add 5 oh-my-zsh dev prompt styles (robbyrussell, ys, avit, bira, af-magic) + git:(branch) helper; 21 styles, 30 looks
- Add 5 oh-my-zsh-inspired styles (robbyrussell, ys, avit, bira, af-magic); 21 styles total
- Add oh-my-zsh 'cloud' style + nuance-update command (one-line in-place update); 22 styles, 31 looks
- Add targeted tests (git-plain/git-omz/commands/ghostty mapping via extracted ghostty-map-name); new themes-more preview GIF; README
- Add GALLERY.md showcasing all 26 themes / 22 styles / 31 looks; slim main README to essentials; regenerate galleries
- Add 'nuance update' subcommand (works in Nushell AND normal shells via ~/.local/bin CLI); install/uninstall deploy it
- Add 'nuance help' + 'nuance theme'/'nuance prompt-style'/'nuance look' subcommands (no arg = show all); wire through the CLI for both shells
- Add interactive up/down theme & style selectors; add bats tests for CLI
- Add up/down interactive theme/style selector (nuance theme/prompt-style, no arg); add bats CLI test suite (test.bats) + wire into CI
- Add 'sync with terminal' entry to the theme selector; rename theme-sync -> 'nuance sync theme' (+ 'nuance sync' shortcut, theme-sync alias, bash CLI sync)

### 🐛 Bug Fixes

- Fix: escape literal parens in theme/theme-sync status messages
- Fix curl one-liner: single-quote so the outer shell doesn't expand $d; download to a fixed temp path
- Fix Nushell 0.114 deprecations (str downcase/upcase → --ignore-case flags / drop); test CI on nu 0.111 + 0.114

### 💼 Other

- Nushell-prompt: themeable git-aware prompt (5 themes, 7 styles incl. cyberpunk)
- Refresh demo GIFs: showcase new themes (monokai, night-owl, oxocarbon, github-light) and styles (arrow, rainbow) + new looks
- Beef up Super Mario: more vivid theme palette + richer two-line mario style (?-block, hero, flag, coins, pipes, conflicts, stash, brick ground)
- Refresh demo GIF to feature the oh-my-zsh styles (robbyrussell, ys, cloud) + super-mario
- Speed up install: skip LFS media (demo GIFs) when cloning — ~1s instead of ~1.5min; README uses GIT_LFS_SKIP_SMUDGE

### 🚜 Refactor

- Point URLs at github.com/sorinirimies/my_nushell_theming
- Rebrand to 'nuance': update name, URLs, and add a 'What is it?' explainer to the README
- Move theming/styling instructions (commands + picker) into main README; make GALLERY a pure visual showcase of all themes/styles/looks
- Make 'nuance theme' / 'nuance prompt-style' (no arg) open ↑↓ arrow selector — theme swatches + style previews in list

### 📚 Documentation

- README: remove broken image, add inline text preview of prompt styles
- Docs: add badges to README
- GALLERY: add table of contents; snapshot the styles sheet to a lighter static PNG (drop 821KB GIF)
- README: give the wget install its own code block (equal to curl)

### ⚙️ Miscellaneous Tasks

- CI: fix install-verify step (source needs a const path); check symlink instead
- CI: dedupe bats steps (single brew/apt install + one bats run)
