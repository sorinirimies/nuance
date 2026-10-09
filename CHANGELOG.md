# Changelog

All notable changes to this project are documented here — generated with
[git-cliff](https://git-cliff.org) (config: [cliff.toml](cliff.toml)).

## [unreleased]

### 🐛 Bug Fixes

- Fix(docs): re-record doctor/picker/welcome/transient/modules GIFs; doctor shows ~ paths

- doctor.gif now recorded in an isolated HOME (no personal paths/state); nuance doctor prints ~ for the home dir and 'pinned'/'auto-follow' instead of a duplicated theme name
- picker.tape: wait for the 69-theme picker to load and drop a stray command that ran 'rainbow' in the shell
- welcome.tape/transient.tape no longer print the hostname / absolute working directory
- modules.tape: shorter comments so they don't wrap
- tests for tilde() and for doctor not leaking the home directory

### 💼 Other

- Feat: single-call git status (4x faster), operation state, adaptive path shortening, ASCII fallback, HUD right-prompt opt-out

- git-info: one 'git status --porcelain=v2 --branch --show-stash' (fallbacks for old git), worktree/submodule .git files, no process for repo detection
- git operation state next to the branch: REBASE n/m, MERGING, CHERRY-PICKING, REVERTING, BISECTING, AM (git-head)
- shorten-path/display-dir: fish-style path shortening to a terminal-width budget (PROMPT_DIR_MAX)
- block styles use ASCII separators when PROMPT_NERD is false
- mario/vault/grace/doomguy hide the right prompt
- tests: real temp git repos (unborn, clean, dirty, stash, detached, ahead/behind, conflict, worktree), op-state files, shorten-path cases, ASCII fallback, right-prompt opt-out
- Feat: generic game-flavoured names + 10 new themes/styles/looks (heist, hollow cavern, portals, bonfire, farm, fighting, boons, climb, skillcheck, sandbox); generated gallery

- renamed trademarked names to generic ones (mario->hud-run/coin-rush/sunny-course/cave-course, hyrule/triforce->greenfield/trifold, pip-boy/vault->phosphor/shelter, doom/doomguy->inferno/marine, tarnished/grace->gilded-ruin/sanctum, clair-obscur/expedition33/gommage->belle-epoque/ornate/petals); legacy names still resolve (saved state, theme/look/prompt-style, .nuance)
- 10 new themes + styles + looks: phantom/heist, cavern-hush/vessel, test-chamber/portals, ember/bonfire, meadow/farmstead, dojo/versus, underworld/boons, summit/climb, rain-noir/skillcheck, blocky/hotbar
- scripts/gen_gallery.nu + just gallery generate GALLERY.md from the registries; test.nu fails if it (or README counts) go stale
- README trademark/affiliation note; tests for every new style, legacy aliases
- games.gif/demo.gif/gallery images re-recorded
- Test: run the gallery check with the current nu binary
- Feat: safety net, color fallback, user styles, completions, share strings, git modes, golden snapshots, split prompt sources

- prompt safety net: renderers run inside safe-run; errors are logged (doctor) and fall back to a plain prompt
- NO_COLOR / 256 / 16-color downgrade of the final prompt string (NUANCE_COLORS to force)
- user-defined segment styles (nuance style new, <config>/nuance/styles/*.nuon); modules docker, cloud, pkg, battery
- big repos: PROMPT_GIT=full|light|off, .nuance git key, adaptive slow-repo marks (-uno)
- display-width (CJK/emoji) aware path shortening, grapheme-safe abbreviations; term-size query skipped for short paths (powerline render 22ms -> 1ms)
- Vi-mode glyphs mirror the style, transient prompt reflects exit status, 'dir' transient mode
- nuance list/current/preview/random/appearance/export/integration/style/uninstall/completions (+ import accepts share strings); doctor --clear-errors and new rows
- tab completion for theme/look/prompt-style/modules/here/transient/…; clap_complete for bash/zsh/fish/elvish/powershell
- prompt sources split into nu/*.nu, built into nushell-prompt.nu by scripts/build_prompt.nu (test.nu fails if stale)
- golden snapshots (tests/golden/prompts.txt, scripts/golden.nu) of ~1300 rendered prompts; many new tests; state/cache dirs overridable (NUANCE_CONFIG_DIR/CACHE_DIR) so tests never touch real config
- CI: nushell nightly job (allowed to fail) on Gitea + GitHub, experimental Windows job on GitHub
- THIRD_PARTY.md credits, README docs, new tapes/GIFs (toolbox; doctor/modules re-recorded)

### ◀️ Revert

- Revert: keep the original game names (mario, hyrule, triforce, pip-boy, vault, doom, tarnished, grace, clair-obscur, expedition33, gommage)

- undo the generic renames and the legacy-name aliasing; original names, HUD strings (MARIO, [VAULT-111], YOU DIED) and descriptions restored
- the 10 new themes/styles/looks (phantom/heist, cavern-hush/vessel, test-chamber/portals, ember/bonfire, meadow/farmstead, dojo/versus, underworld/boons, summit/climb, rain-noir/skillcheck, blocky/hotbar) stay
- README: unofficial-fan-project trademark note instead of 'no game names'; generated GALLERY.md, tapes and images re-recorded with the original names
## [0.4.2] - 2026-10-09

### 💼 Other

- Feat: Clair Obscur: Expedition 33, better Mario, game themes/styles, 13 new styles, 8 new themes

- themes (51 -> 59): clair-obscur, clair-obscur-canvas (light), mario-overworld (light), mario-underground, pip-boy (Fallout), tarnished (Elden Ring), hyrule (Zelda), doom
- styles (27 -> 40): expedition33, gommage (Clair Obscur), vault (Fallout), grace (Elden Ring, YOU DIED), triforce (Zelda), doomguy (DOOM), spaceship, p10k-lean, fish, steeef, fino, powerline2l, pills2l; mario rebuilt as an NES HUD + brick ground
- looks (46 -> 62)
- tests: per-style output assertions driven by injected git state, 2-line checks, bar/flag helpers; render matrix reuses one git lookup
- gallery tapes/images and games.gif re-recorded; README/GALLERY updated
- Chore: bump version to 0.4.2
## [0.5.2] - 2026-10-07

### 💼 Other

- Chore: bump version to 0.5.2
## [0.5.1] - 2026-10-07

### 💼 Other

- Chore: bump version to 0.5.1
## [0.5.0] - 2026-10-07

### 🐛 Bug Fixes

- Fix(ci): nu 0.114 compatibility; add CLI integration tests, new demo tapes, docs

- fix 'mut prev = null' (typed as nothing in 0.114) and avoid deprecated 'str downcase' via a version-independent lower helper
- tests/cli.rs: transient, modules, import, here, doctor
- new tapes + GIFs: transient, modules, import-here, doctor; gallery tapes resized for 51 themes / 27 styles
- README: embed new demos, document adding themes/styles, state files, toggles; refresh test counts
- stale comments in nushell-prompt.nu
- Fix: doctor crashed when the autoload file is missing; whoami fallback

- '(installs it)' inside a $"…" string was evaluated as a command in the missing-autoload branch; moved into doctor-autoload() and tested
- 'whoami' fallback in prompt-user used a non-external call (broke with USER unset)
- nuance configure summary printed '' instead of 'none'

### 💼 Other

- Chore: bump version to 0.5.0

### 📚 Documentation

- Docs: re-record every demo GIF; add configure tape; faster pickers; push LFS to Gitea starscream

- all older GIFs regenerated (themes-more/light/styles/demo now show the new themes, styles and looks); cli.tape fixed (nu syntax PATH, picker wait, release path)
- tapes/configure.tape + docs/configure.gif: nuance configure driven through a real terminal (isolated HOME); verified it writes theme/style/transient/modules
- pickers resolve git once ($env.NUANCE_GIT) instead of per preview: theme picker 1.7s -> ~1s; covered by tests
- justfile: Gitea starscream LFS works (git-lfs-authenticate over SSH), so stop skipping LFS on push for it
## [0.4.0] - 2026-10-07

### 💼 Other

- Feat: segment engine, style registry, WCAG-checked palettes; add agnoster/skyline/pills styles

- style-defs registry is the single source for styles, indicator glyphs and block layouts; powerline/slant/capsule/rainbow now share render-blocks
- git-segment built on git-info (new --light mode); no duplicated parsing
- palettes gain bg/fg/surface/light + per-segment AA ink; text roles auto-fitted to contrast floors (light themes, nord, onedark, oxocarbon, ... now readable)
- test.nu: hex validity, contrast floors, AA ink, light flag, registry + render checks
- new styles agnoster, skyline, pills and looks dracula-agnoster, tokyo-skyline, nord-pills
- Feat: transient prompt, context modules (status/jobs/ssh/root/venv/nix/lang/k8s), pastel + devbar styles

- nuance transient [on|off|toggle] via TRANSIENT_PROMPT_* (persisted)
- nuance modules [list|enable|disable|clear]: situational segments; block styles fold them in, single-line styles get a colored tail; lang versions cached 1h
- Rust CLI: transient + modules subcommands
- tests + README/GALLERY updated
- Feat: 25 new themes, theme import, per-directory themes, configure wizard, doctor

- 25 new themes (tokyo-night storm/moon/day, gruvbox light/material, nightfox/dawnfox, kanagawa dragon/lotus, flexoki, melange, nightfly, palenight, tomorrow-night, snazzy, iceberg, one-light, papercolor-light, synthwave-84, cobalt2, modus, horizon, sonokai) -> 51 total; 12 new looks
- nuance import: ghostty/kitty/alacritty/base16 (file or ghostty theme name) -> user themes; unknown Ghostty themes auto-imported on sync; smarter ghostty name mapping
- .nuance per-directory theme/style overrides (nuance here), validated names only
- nuance configure (guided setup) and nuance doctor
- Rust CLI: configure/doctor/import/here subcommands
- tests for imports, overrides, doctor, theme shapes; gallery images regenerated
- Chore: bump version to 0.4.0
## [0.3.0] - 2026-10-06

### 💼 Other

- Chore: bump version to 0.3.0
## [0.2.17] - 2026-10-06

### 🐛 Bug Fixes

- Fix: correct justfile remote names (gitea-microlab/starscream -> gitea/gitea_starscream); fix nu str downcase deprecation in test.nu

### 💼 Other

- Chore(deps): nightly dependency upgrade 2026-09-12
- Chore: bump version to 0.2.6
- Chore(deps): nightly dependency upgrade 2026-09-15
- Chore: bump version to 0.2.7
- Chore(deps): nightly dependency upgrade 2026-09-17
- Chore: bump version to 0.2.8
- Chore(deps): nightly dependency upgrade 2026-09-19
- Chore: bump version to 0.2.9
- Chore(deps): nightly dependency upgrade 2026-09-22
- Chore: bump version to 0.2.10
- Chore(deps): nightly dependency upgrade 2026-09-23
- Chore: bump version to 0.2.11
- Chore(deps): nightly dependency upgrade 2026-09-24
- Chore: bump version to 0.2.12
- Chore(deps): nightly dependency upgrade 2026-09-26
- Chore: bump version to 0.2.13
- Chore(deps): nightly dependency upgrade 2026-10-01
- Chore: bump version to 0.2.14
- Chore(deps): nightly dependency upgrade 2026-10-03
- Chore: bump version to 0.2.15
- Chore(deps): nightly dependency upgrade 2026-10-04
- Chore: bump version to 0.2.16
- Chore(deps): nightly dependency upgrade 2026-10-06
- Chore: bump version to 0.2.17

### ⚙️ Miscellaneous Tasks

- Ci(deps): release only when a direct dependency changes; fix mirror push gate; add downloads badge
- Ci(deps): nightly job upgrades Cargo.toml requirements; justfile: add missing recipes; ignore .codegraph

- nightly-deps: cargo upgrade (majors w/ compatible fallback) + cargo update; release when Cargo.toml or direct lock versions change
- justfile: push-all-force, pull-all, push-release-all, publish*, update-deps, changelog-*, validate-tag, etc.
- bump clap to 4.6.7

### ◀️ Revert

- Revert: restore gitea-microlab/gitea-starscream naming convention in justfile
## [0.2.5] - 2026-09-10

### 💼 Other

- Chore(deps): nightly dependency upgrade 2026-09-10
- Chore: bump version to 0.2.5
## [0.2.4] - 2026-09-08

### 💼 Other

- Chore(deps): nightly dependency upgrade 2026-09-08
- Chore: bump version to 0.2.4
## [0.2.3] - 2026-09-08

### 🚀 Features

- Add nightly dependency-update automation (Gitea): cargo update, quality gate, bump patch version, tag, push to Gitea + GitHub

Same pattern as the other 10 nexus-lab repos, adapted to nuance's own
tooling: no scripts/bump_version.nu here, so it reuses the already-tested
'just bump <version>' recipe (edits Cargo.toml, refreshes Cargo.lock,
commits, tags -- see justfile) instead of duplicating that logic. 'just
check-all' runs the same fmt/clippy/cargo-test/nu-test.nu gate used
everywhere else in this repo. Pushes the tag+branch to this Gitea instance
and to the GitHub mirror via a GITHUB_REMOTE_URL secret, matching the
sibling repos' convention.

### 💼 Other

- Chore: bump version to 0.2.0
- Gitea release.yml: stop trusting the server's broken upload_url field

Root cause of the 'Upload release binary' failure: Gitea's own API
responses for this instance embed the wrong host in url/html_url/
tarball_url/upload_url (http://192.168.1.211/... instead of the real
http://192.168.1.145:30008) -- confirmed directly against the live API
(GET /api/v1/repos/sorin/nuance/releases/tags/v0.1.1 returns upload_url
pointing at .211, same misconfigured host we already hit with the LFS
batch endpoint). actions/upload-release-asset@v1 blindly POSTs to
whatever upload_url the create-release step reported, so it was always
going to fail against this instance regardless of the earlier id: fix.

Replaced both legacy actions with direct curl calls against Gitea's REST
API, building the URL from ${{ github.server_url }} (what Gitea Actions
actually sets to point at itself) instead of anything the API response
says. Also handles the already-created-but-never-uploaded case (e.g. this
exact re-run scenario) by falling back to GET .../releases/tags/$TAG for
the release id if creation fails (tag already has a release).
- Gitea release.yml: fix resp capture bug in the create-or-lookup fallback

'resp="$(cmd1)" || cmd2' does NOT put cmd2's output into $resp when cmd1
fails -- it just runs cmd2 (output goes straight to the log), leaving
$resp as whatever the failed cmd1's substitution produced (empty, since
curl -f suppresses the error body). Exactly the re-run-after-partial-
failure scenario this was meant to handle (v0.1.1's release already
existed from the previous attempt), so $resp was empty, release_id
extraction found nothing, and the step failed with our own
'could not determine release id' error -- ironically while trying to fix
the exact same failure.

Replaced with an explicit if/else so $resp is always set from whichever
curl actually ran. Verified both branches locally with a small standalone
script (create-succeeds and create-fails-so-fallback-runs) before pushing
this time.
- Gitea release.yml: make failures actually debuggable (stop hiding response bodies)

curl -f swallows the response body on any non-2xx status, so every prior
failure of this step gave nothing to go on beyond 'exitcode 1' -- I've
been unable to fetch this Gitea instance's own Actions logs (its API
requires a token I don't have), so blind iteration wasn't working.

Replaced -f everywhere with -w '\n%{http_code}' + explicit status checks,
and print every response body regardless of outcome. Now: create-release
status is logged (409/422 = already exists is expected and handled via
lookup, not silently masked), the release id extraction is logged, and
the asset upload's real HTTP status + body are printed before failing.

Verified the exact status-code-branching logic (create-conflicts ->
lookup succeeds -> id extracted -> upload succeeds) against mocked curl
output in a standalone script first.
- Chore: bump version to 0.2.1
- Chore: bump version to 0.2.2
- Chore: bump version to 0.2.3
## [0.1.1] - 2026-08-20

### 🚀 Features

- Add .codegraph ignore rules for local artifacts

### 💼 Other

- Justfile: add gitea-microlab and gitea-starscream (parity with the other 10 repos)
- Unify the theme/prompt-style/look UI everywhere: always ratatui when available, sync-with-terminal always first

Previously two completely separate pickers existed and behaved
differently depending on where you called them from:
  - inside a running nu shell: theme/prompt-style/look and their
    "nuance theme"/etc wrappers used Nushell's own `input list` (no live
    preview, and only the "nuance theme" wrapper had a sync-with-terminal
    entry -- bare `theme` didn't).
  - from bash/zsh/fish via the compiled `nuance` binary: the ratatui
    picker with instant live preview, but with *no* sync-with-terminal
    entry at all.

Now there's exactly one UI, used everywhere:

- theme-picker-items always leads with a synthetic "sync with terminal"
  entry (key "__sync__"), so it's the same list whether Nushell's own
  `input list` renders it or the Rust ratatui picker does (both consume
  this same data).
- theme/prompt-style/look (the bare defs, and "nuance theme"/"nuance
  prompt-style"/"nuance look" now just delegate to them) check
  nuance-cli-available (`which nuance`) first: if the compiled binary is
  on PATH, delegate to it (`^nuance theme`/etc, ratatui with live
  preview) and reload the persisted result into *this* live session via
  reload-theme/reload-style so the prompt updates immediately, no new
  shell needed. Falls back to Nushell's own `input list` only when the
  binary isn't installed.
- src/main.rs: picking the "__sync__" entry runs `nuance sync theme`
  instead of trying to apply a theme literally named "__sync__".
- src/tui.rs: the list view renders the sync entry's real (ANSI-colored)
  label instead of its raw "__sync__" key, which would otherwise look
  like an internal implementation detail leaking into the UI.

Verified: nu test.nu (updated for the new sync entry in
theme-picker-items) and cargo test (39) both pass; confirmed via vhs that
the ratatui picker now shows "27 matches" (26 themes + sync) with sync
selected and rendered correctly as the first row, both in the item list
and the live-preview pane.
- Chore: bump version to 0.1.1

### ⚙️ Miscellaneous Tasks

- Ci: retest Gitea Actions trigger
## [0.1.0] - 2026-08-19

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
- Add .gitea/workflows/ (ci.yml, release.yml) — ubuntu-latest only

Gitea's own Actions runner here only has an ubuntu-latest label, no
macos-latest. Since .github/workflows/ci.yml's cli/nushell jobs run a
macos-latest matrix entry (real macOS runners on GitHub-hosted Actions),
that job would hang/fail forever on this Gitea instance waiting for a
runner label that doesn't exist -- almost certainly the cause of the
earlier 'Install Nushell / exitcode 1' failure report.

Gitea Actions reads .gitea/workflows/ in preference to .github/workflows/
when both exist (same convention already used in the sibling
droidkraft/gitkraft/tui-spinner/etc. repos) -- so:

- .gitea/workflows/ci.yml: ubuntu-latest only. fmt/clippy/cargo test jobs
  plus a nushell-suite job; Nushell installed via the same curl+tar
  approach as .github/workflows/ci.yml (no marketplace action).
- .gitea/workflows/release.yml: ubuntu-latest only. builds+tests, packages
  a linux-x86_64 tarball, creates a Gitea Release, and conditionally
  publishes to crates.io if CRATES_IO_TOKEN is set as a Gitea repo secret.

.github/workflows/ remains untouched for GitHub-hosted Actions (still has
real macOS runners for the macos-latest matrix entries).

Verified both new workflow files parse as valid YAML.
- Add justfile (task runner) — build/test/fmt/clippy/changelog/release/tapes/remotes

Mirrors the convention used in the other repos (droidkraft, gitkraft, etc.)
but tailored to nuance's actual layout (root Cargo.toml + nushell-prompt.nu
+ scripts/install.nu, no bump_version.nu/check_publish.nu scripts since
those don't exist here):

- build/build-release/install (cargo)
- fmt/fmt-check/clippy/check-all
- test (cargo test) / test-nu (nu test.nu) / test-all
- install-nu/install-nu-copy/uninstall-nu (wrap scripts/install.nu,
  scripts/uninstall.nu)
- changelog/changelog-preview (git-cliff, cliff.toml; regenerates with the
  same custom header used so far)
- version/bump/release/release-gitea/release-all (sed-based Cargo.toml
  version bump + Cargo.lock refresh + commit + tag vX.Y.Z, then push to
  origin and/or gitea-ssh)
- remotes/push*/pull*/sync-gitea (origin + gitea + gitea-ssh, matching
  this repo's actual remote names, not the gitea-nexus-lab name used in
  the other 10 repos)
- tape <name>/tapes-all (vhs wrappers for tapes/*.tape)

Verified: build/fmt-check/clippy/test/test-nu/changelog/info all run
clean; bump tested end-to-end in a throwaway clone (version bump + commit
+ tag, not pushed).
- Add curl/wget install alternative (pure Nushell, no bash)

scripts/install.nu's resolve-root() relied on $env.FILE_PWD, which only
Nushell populates for real script *files* — not for -c inline code. That's
fine for 'nu scripts/install.nu' (from a clone), but broke the '$env.FILE_PWD?
default ""' one-liner pattern silently in edge cases. Made it defensive:
falls through to the git-clone fallback whenever FILE_PWD is unset/empty
instead of erroring.

README: restored a real curl/wget install option (removed a few turns ago
along with bootstrap.sh) — but implemented correctly this time: download
scripts/install.nu to a real temp file first, then run it as a script
(nu /tmp/nuance-install.nu), so $env.FILE_PWD resolves and the git-clone
fallback in resolve-root() works. (Piping straight into 'nu' doesn't work at
all — nu refuses non-TTY stdin without an explicit script/-c argument;
verified this fails before landing on the download-then-run pattern.)

No bash: curl/wget are just the download step, nu executes the real .nu
file end to end. Verified locally: nu -c "$(cat scripts/install.nu); main"
and 'nu <downloaded-file>' both install correctly (theme set, symlink into
autoload, git-clone fallback all working) in a throwaway HOME.

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
- Regenerate CHANGELOG
- Regenerate CHANGELOG
- Justfile: rename gitea/gitea-ssh -> gitea-nexus-lab(-http)

Both remotes actually pointed at the same nexus-lab Gitea instance
(192.168.1.145) all along -- 'gitea' (http, :30008) and 'gitea-ssh'
(ssh, :30009) -- unlike the other 10 repos where 'gitea' means a
different, real 'microlab' instance (192.168.1.204). Naming it just
'gitea' was misleading. Renamed:

- remote gitea-ssh -> gitea-nexus-lab (the one that actually works)
- remote gitea      -> gitea-nexus-lab-http (kept for reference)
- push-gitea/push-gitea-ssh -> push-gitea-nexus-lab-http/push-gitea-nexus-lab
- pull-gitea-ssh -> pull-gitea-nexus-lab
- sync-gitea -> sync-gitea-nexus-lab
- release-gitea -> release-gitea-nexus-lab

No more bare 'gitea'/'gitea-ssh' anywhere in the justfile or git remotes.
Verified: just --list parses clean, just remotes/fmt-check/clippy all run.
- Justfile: bump handles same-version (first release / re-tag) gracefully

'just bump X' previously always tried to 'git commit' the version-file
change unconditionally -- fine when the version actually changes, but
failed outright ('nothing to commit') when bumping to the CURRENT version,
which is exactly the first-release case (Cargo.toml is already at 0.1.0,
nothing has ever been tagged/published). Now:
  - errors clearly if the tag already exists (no silent re-tag)
  - skips the commit (but still tags) if Cargo.toml is already at the
    requested version

Verified in a throwaway clone: 'just bump 0.1.0' now tags cleanly when
Cargo.toml is already 0.1.0, and errors clearly on a second attempt
(tag already exists) instead of silently failing on 'nothing to commit'.
- Justfile: release-all/release-gitea-nexus-lab skip LFS push (dead endpoint)
- Tests/cli.rs: pin XDG_CONFIG_HOME/CACHE_HOME/DATA_HOME per-test (fix CI flakiness)

Root cause of the intermittent 'prompt_style_sets: left cyberpunk, right
powerline' CI failures (and others): each test only overrode HOME for its
subprocess, not XDG_CONFIG_HOME/XDG_CACHE_HOME/XDG_DATA_HOME. On Linux (the
CI runner), Nushell/XDG-aware resolution prefers those vars over deriving
a path from HOME when they're set in the outer environment — so if the CI
image sets XDG_CONFIG_HOME globally, every test's subprocess was actually
writing to the *same real* shared nushell config dir despite each test
using its own tempdir HOME, racing under cargo test's default parallelism.

Not reproducible on macOS locally (no XDG_CONFIG_HOME set here) — confirmed
the failure mode by exporting a fake global XDG_CONFIG_HOME/XDG_CACHE_HOME
before 'cargo test' (reproduced the exact same failure), then confirmed the
fix holds by re-running 5x with those same fake vars set. Pinned all three
XDG_* vars to subdirs of each test's own tempdir in both run() and
config_dir() (and the inline nu call in
first_run_vendors_prompt_script_into_autoload_dir) so HOME is the only
thing that varies between tests, and it's fully isolated regardless of the
outer CI environment.
- Release.yml: fix GitHub Release creation (both GitHub + Gitea workflows)

GitHub side (.github/workflows/release.yml):
taiki-e/upload-rust-binary-action attaches assets to an *existing* GitHub
Release matching the pushed tag -- it does not create one. Without a
release-creation step, it just polls 'release not found' every few
seconds until it times out and fails (confirmed against the actual v0.1.0
release run: 3 of 4 binary jobs failed this way). Added a create-release
job (gh release create, no-op if already exists) that all binary jobs now
.

Gitea side (.gitea/workflows/release.yml), two separate bugs:
- The 'Create Gitea Release' step had no , so the next step's
   reference was always empty --
  the asset upload had nowhere to go. Added .
-  can't work as written -- step
  blocks aren't visible to  conditions on other steps, and secrets
  aren't allowed directly in step-level  either (same class of bug
  fixed as 'secrets context not allowed in step-level if:' in the sibling
  gitkraft repo's auto-release.yml). Replaced with a dedicated check step
  that writes to $GITHUB_OUTPUT, branched on via steps.check_token.outputs.

crates.io publish itself already succeeded for v0.1.0 (nuance-cli is live);
this fixes the binary-attachment side for future tags.

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
- CI: replace hustcer/setup-nu action with a manual curl+tar install

The marketplace action likely fails on Gitea Actions runners (self-hosted
act_runner) because it trusts the runs-on: label (macos-latest) rather than
the container's actual OS -- if Gitea maps every label to a Linux
container (no real macOS runners available self-hosted), the action would
try to run a macOS nu binary in a Linux container and fail immediately
(exitcode 1, matching the reported failure).

Replaced with a small inline script (both the nushell and cli jobs) that:
- detects the real OS/arch via uname -s / uname -m at runtime, not the
  job's runs-on: label
- downloads nu-<version>-<target>.tar.gz directly from nushell/nushell's
  GitHub releases
- installs it to ~/.local/bin and adds that to $GITHUB_PATH (also honored
  by Gitea Actions)

Verified the exact release URLs resolve (200) for 0.111.0 and 0.114.1 on
x86_64-unknown-linux-gnu, aarch64-apple-darwin, x86_64-apple-darwin, and
that extraction + `nu --version` works end-to-end locally. No third-party
action dependency left for Nushell installation.
