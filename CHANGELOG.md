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
- Add self-contained nuance-cli Rust crate (cargo install nuance-cli); update README/CI/tests + git-cliff CHANGELOG

- cli/: clap + ratatui CLI/TUI, vendors nushell-prompt.nu via include_str! at
  compile time — no clone, no install.nu, works from any shell. Auto-offers
  'cargo install nu' if nu is missing. theme/prompt-style/look pickers fetch
  every candidate's live-rendered preview once, then redraw instantly on
  arrow-key movement (no per-keystroke nu calls).
- CI: new 'cli' job (fmt, clippy, build, test, smoke test) on ubuntu+macos;
  new release-cli.yml publishes nuance-cli to crates.io on cli-v* tags.
- nushell-prompt.nu/test.nu: theme/prompt-style/look pickers now render a
  live preview per candidate (theme-label/style-label/look-label +
  *-picker-items), shared by both the Nushell 'input list' picker and the
  Rust ratatui picker (via 'to json').
- README: cargo-install path, cli.gif demo, changelog + cli test mentions.
- tapes/cli.tape + docs/cli.gif: new VHS demo of the nuance-cli picker.
- cliff.toml + CHANGELOG.md: git-cliff config (custom commit_parsers since
  history predates conventional commits) + generated changelog.

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
- Group install/CLI scripts under scripts/ (bootstrap.sh, install.nu, uninstall.nu, nuance POSIX CLI)

- bootstrap.sh -> scripts/bootstrap.sh, install.nu -> scripts/install.nu,
  uninstall.nu -> scripts/uninstall.nu, bin/nuance -> scripts/nuance (bin/
  dropped).
- install.nu: resolve repo root as one level above the script (was: same
  dir); cli_src now scripts/nuance instead of bin/nuance.
- Updated all references: README, CI (ci.yml), test.bats, cli/tests/cli.rs
  comment, nushell-prompt.nu's printed bootstrap URL, and the scripts'
  own self-referential comments/URLs.
- Verified: nu test.nu, bats test.bats, cargo test (cli/) all pass; manual
  install/uninstall smoke test against a throwaway HOME confirms symlinks
  resolve correctly from the new scripts/ location.
- Promote nuance-cli to repo root (src/, Cargo.toml); drop redundant bash CLI + bats

Consolidate on a single, fully self-contained Rust app instead of a nested
cli/ crate + a parallel POSIX-shell reimplementation:

- cli/{src,tests,Cargo.toml,Cargo.lock,rustfmt.toml} -> repo root {src/,
  tests/,Cargo.toml,Cargo.lock,rustfmt.toml}. include_str! path for
  nushell-prompt.nu fixed (one dir shallower). Cargo.toml now uses an
  explicit include=[] so  only ships what the binary needs
  (src/, tests/, the vendored .nu file, README, LICENSE) — not docs/tapes/
  scripts/ etc.
- Removed scripts/nuance (POSIX bash CLI) and test.bats: fully redundant
  with the Rust  binary (39 passing unit+integration tests already
  cover the same behavior, more thoroughly). cargo install nuance-cli is
  now the one and only any-shell CLI.
- scripts/install.nu no longer symlinks a bash CLI into ~/.local/bin;
  scripts/uninstall.nu keeps that cleanup path for old installs (no-op
  otherwise). scripts/bootstrap.sh: if Rust's package manager

Usage: cargo [+toolchain] [OPTIONS] [COMMAND]
       cargo [+toolchain] [OPTIONS] -Zscript <MANIFEST_RS> [ARGS]...

Options:
  -V, --version                  Print version info and exit
      --list                     List installed commands
      --explain <CODE>           Provide a detailed explanation of a rustc error message
  -v, --verbose...               Use verbose output (-vv very verbose/build.rs output)
  -q, --quiet                    Do not print cargo log messages
      --color <WHEN>             Coloring [possible values: auto, always, never]
  -C <DIRECTORY>                 Change to DIRECTORY before doing anything (nightly-only)
      --locked                   Assert that `Cargo.lock` will remain unchanged
      --offline                  Run without accessing the network
      --frozen                   Equivalent to specifying both --locked and --offline
      --config <KEY=VALUE|PATH>  Override a configuration value
  -Z <FLAG>                      Unstable (nightly-only) flags to Cargo, see 'cargo -Z help' for
                                 details
  -h, --help                     Print help

Commands:
    build, b    Compile the current package
    check, c    Analyze the current package and report errors, but don't build object files
    clean       Remove the target directory
    doc, d      Build this package's and its dependencies' documentation
    new         Create a new cargo package
    init        Create a new cargo package in an existing directory
    add         Add dependencies to a manifest file
    remove      Remove dependencies from a manifest file
    run, r      Run a binary or example of the local package
    test, t     Run the tests
    bench       Run the benchmarks
    update      Update dependencies listed in Cargo.lock
    search      Search registry for crates
    publish     Package and upload this package to the registry
    install     Install a Rust binary
    uninstall   Uninstall a Rust binary
    ...         See all commands with --list

See 'cargo help <command>' for more information on a specific command. is already on PATH, prefer
   (self-contained: vendors the prompt, installs
   itself if missing) over the package-manager dance.
- CI: dropped the bats job/steps; cli job no longer needs
  working-directory: cli (crate is now at repo root, so does Swatinem
  rust-cache's workspaces:). Renamed release-cli.yml -> release.yml,
  tag pattern cli-v* -> v*.
- README: updated all paths/wording (cross-platform & tested section,
  updating section, contributing/demos with project layout, install-free
  cargo path).
- Verified: cargo build/test/fmt/clippy clean from root; nu test.nu passes;
  manual install/uninstall smoke test against a throwaway HOME.
- Regenerate CHANGELOG
- Drop bootstrap.sh; two install paths only: cargo install nuance-cli, or scripts/install.sh (prebuilt binary)

bootstrap.sh did too much: detect OS, try 5 different package managers to
install Nushell, only then set up the prompt. Replaced with exactly what was
asked for:

- cargo install nuance-cli (self-contained: vendors the prompt, offers
  cargo install nu itself if nu is missing).
- scripts/install.sh: curl/wget one-liner, no package-manager dance at all
  -- just downloads the prebuilt nuance-cli-<target>.tar.gz release asset
  for the current OS/arch off GitHub Releases, extracts nuance into
  ~/.local/bin. If Nushell itself is missing, running any nuance subcommand
  offers cargo install nu (if cargo is present) or points at
  nushell.sh (one-time manual step) -- same as the cargo path.
- release.yml: new binaries job (matrix: linux x86_64/aarch64-gnu, macos
  x86_64/aarch64) using taiki-e/upload-rust-binary-action to attach
  nuance-cli-<target>.tar.gz to the GitHub Release alongside the existing
  crates.io publish, so install.sh has something to fetch on tag pushes.
- README/nushell-prompt.nu: updated install section + printed update-hint
  URL; scripts/install.nu (git-clone/symlink path, for hacking on the
  prompt itself) is untouched -- unrelated to bootstrap.

Verified: cargo build/test/fmt/clippy clean, nu test.nu passes, bash -n +
shellcheck on the new script.
- Regenerate CHANGELOG
- Drop scripts/install.sh (bash) -- repo is Nushell-only scripts now

Only two install paths left, neither needs bash:
- cargo install nuance-cli (self-contained Rust binary)
- clone + nu scripts/install.nu (pure Nushell, for people who already have
  Nushell and want the repo as the source of truth)

Prebuilt binaries (from release.ymls binaries job) are still built and
attached to GitHub Releases, just no longer fetched via a curl|bash
installer -- download+extract manually if you want one without cargo.

scripts/ now contains only install.nu and uninstall.nu. Updated README
(installation, updating, project-layout sections) and the
nushell-prompt.nus copy-install update hint accordingly.

Verified: cargo build/test/fmt/clippy clean, nu test.nu passes.

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
