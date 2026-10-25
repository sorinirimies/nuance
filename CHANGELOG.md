# Changelog

All notable changes to this project are documented here. It is generated from
[Conventional Commits](https://www.conventionalcommits.org) by
[git-cliff](https://git-cliff.org) — do not edit it by hand.

## [0.9.0](https://github.com/sorinirimies/nuance/compare/v0.8.1...v0.9.0) — 2026-10-25

### ✨ Features

- Async git prompt — instant draw, background status repaint (closes #1) ([`9087070`](https://github.com/sorinirimies/nuance/commit/908707085112ab793a8521e1e22ca7678d1cbeed))

### 🔄 CI and release

- Bump minimum Nushell to 0.115 for async prompt updates ([`1b365ef`](https://github.com/sorinirimies/nuance/commit/1b365ef941dc558a35d9743729b4e2b0a1c07ff9))
- **release:** Build x86_64-apple-darwin on macos-latest (macos-13 runners are retired; job never started) ([`7430a7c`](https://github.com/sorinirimies/nuance/commit/7430a7c717fd73b72705c1ee9dc0a0bd2fe3a231))

## [0.8.1](https://github.com/sorinirimies/nuance/compare/v0.8.0...v0.8.1) — 2026-10-23

### ✨ Features

- **terminal:** Per-pane by default, opt-in --all-windows (zellij/Ghostty), --session for this shell only ([`5c12250`](https://github.com/sorinirimies/nuance/commit/5c12250b9100af4620ff2b4d2f6eb60b3235c0db))

### 🧪 Tests

- Fix skip message interpolation ([`02b5bc6`](https://github.com/sorinirimies/nuance/commit/02b5bc675edc0bee34c683c5f89acbf9031f54e2))
- Tmux OSC e2e is local-only (flaky on headless CI); detection tests stay in CI ([`337aaf3`](https://github.com/sorinirimies/nuance/commit/337aaf3410f630c3f23f56f596916a4d1ea0a0ba))
- **terminal:** Table-driven multiplexer routing, real tmux/screen detection, tmux OSC e2e; CI installs tmux+screen ([`10e41ef`](https://github.com/sorinirimies/nuance/commit/10e41efd1fb878bcbfd6c3a1d4c68f51fdded010))
- Make test.nu hermetic (state/Ghostty dirs set before sourcing, no reload), assert real config untouched, cover overlay apply/off ([`b8b09f0`](https://github.com/sorinirimies/nuance/commit/b8b09f0d33e255930b61dc401210ec2a5456fdba))

### 🔄 CI and release

- Align fuzz/security with tokenburn+gitkraft (auto-discover fuzz targets, push trigger, gitea fuzz, dependabot + auto-merge) ([`124bb13`](https://github.com/sorinirimies/nuance/commit/124bb1331864ce2de8bcc25357853c305b86fdb3))

## [0.8.0](https://github.com/sorinirimies/nuance/compare/v0.7.1...v0.8.0) — 2026-10-22

### ✨ Features

- **terminal:** Theme the screen through tmux/screen (DCS passthrough) and zellij (Ghostty config overlay); doctor row; hermetic test ([`9d37cb2`](https://github.com/sorinirimies/nuance/commit/9d37cb2d149defe41ed8272bf566f33d2d1185e8))

### 🧪 Tests

- **tui:** Render tests via TestBackend; docs: test count ([`121106e`](https://github.com/sorinirimies/nuance/commit/121106eab9b9a379287ebb77fc3a6e868eb8c982))

## [0.7.1](https://github.com/sorinirimies/nuance/compare/v0.6.1...v0.7.1) — 2026-10-21

### 🐛 Bug fixes

- **ansi:** Clamp colour channels, keep strip/parse_line consistent on unterminated escapes; tui: cast-free move_selection; more tests; fuzz asserts parser agreement ([`f08138a`](https://github.com/sorinirimies/nuance/commit/f08138a7aff4646430b3fce10b4d6db9bc9d7a4b))
- **windows:** '/'-join compact dir, build_prompt without glob ([`a45d019`](https://github.com/sorinirimies/nuance/commit/a45d019d79206c86fef7ddc640dde8702ade8036))
- **windows:** Force LF checkout, normalize backslashes in tilde(), handle POSIX-rooted shorten-path ([`d5e7501`](https://github.com/sorinirimies/nuance/commit/d5e750169851ac0d63ddbc57bb382dc62eba5ae5))

### ♻️ Refactor

- Clippy::pedantic clean; portable PATH lookup (no sh) with tests ([`72aa882`](https://github.com/sorinirimies/nuance/commit/72aa88277eb6fa31d11e37272c902fb382258138))

### 📚 Documentation

- Document fuzzing, add just fuzz ([`e855ac7`](https://github.com/sorinirimies/nuance/commit/e855ac7f96254d01914ca8cb2ec904866fb5aeac))
- Move full-screen terminal theme section near the top ([`1e78288`](https://github.com/sorinirimies/nuance/commit/1e7828819b6a789b23fb94415b35e4601bb1e928))
- Re-record terminal theme gif with more visible theme changes ([`b197679`](https://github.com/sorinirimies/nuance/commit/b197679b46e0642ee9bd9d43cd9120cb01ec8ade))
- Add terminal theme tape, gif and README entry ([`6addc33`](https://github.com/sorinirimies/nuance/commit/6addc332825d31cfeae69d63be552b0df24b4ef5))
- Add audit badge ([`3e216d0`](https://github.com/sorinirimies/nuance/commit/3e216d0e463726790e5b49a3c8a348bb70b3a376))
- Add audit badge ([`78fff00`](https://github.com/sorinirimies/nuance/commit/78fff001caa70e155fa6baf2f2127e6989432078))

### 🧪 Tests

- **fuzz:** Add cargo-fuzz targets (ansi_parse, nu_quote) and CI workflow ([`b788041`](https://github.com/sorinirimies/nuance/commit/b78804187fa0eea8b517d67008540172ca72cccc))

### 📦 Dependencies

- Nightly dependency upgrade 2026-10-20 ([`ee9a80a`](https://github.com/sorinirimies/nuance/commit/ee9a80afc75edc326463c3caa4ae57d292b3de07))
- Nightly dependency upgrade 2026-10-18 ([`bb2669d`](https://github.com/sorinirimies/nuance/commit/bb2669d1a7295dabcda76eba5583363bcc83156b))
- Nightly dependency upgrade 2026-10-17 ([`c1204e4`](https://github.com/sorinirimies/nuance/commit/c1204e47010863d36bad20b40fae66a387ff6e55))
- Nightly dependency upgrade 2026-10-14 ([`fa8425d`](https://github.com/sorinirimies/nuance/commit/fa8425d9d6c157d4c3d39e0637508496f0baf633))
- Nightly dependency upgrade 2026-10-13 ([`ed5bf46`](https://github.com/sorinirimies/nuance/commit/ed5bf4641507d95c3d7dec1928149f04ac2f10b9))
- Nightly dependency upgrade 2026-10-13 ([`a132158`](https://github.com/sorinirimies/nuance/commit/a13215835d62a039ba32129f8567139ffcb8f8f4))
- Nightly dependency upgrade 2026-10-12 ([`6ede03b`](https://github.com/sorinirimies/nuance/commit/6ede03b050b70f353e61d186c8394846b217f35b))
- Nightly dependency upgrade 2026-10-11 ([`338f2ad`](https://github.com/sorinirimies/nuance/commit/338f2ad7d989a249e588a14d621e1fde0ca7ed4b))
- Nightly dependency upgrade 2026-10-10 ([`4fafdda`](https://github.com/sorinirimies/nuance/commit/4fafdda20c333605ade6cc955b6972d575ad9f61))

### 🔄 CI and release

- Release only when a Cargo.toml requirement changes; direct-dep lock moves merge without a bump ([`8de080b`](https://github.com/sorinirimies/nuance/commit/8de080b3afde456c6cae242f7c56bbaa954ad4bb))
- Stop calling api.github.com (runner can't resolve it); pin/derive Nushell via github.com ([`b468306`](https://github.com/sorinirimies/nuance/commit/b46830651ec58bf29b24ae91df51bbff6d4e201e))
- Cargo-deny + cargo-audit security workflow ([`27314fc`](https://github.com/sorinirimies/nuance/commit/27314fc6482fac6cee529f7b7f5a83531d4ae4c0))
- **changelog:** Adopt tokenburn-style cliff.toml (conventional commits, commit/compare links, grouped) ([`c901953`](https://github.com/sorinirimies/nuance/commit/c901953e0dfb272112aaa1093447d4fc4432db77))
- **release:** Git-cliff release notes + auto-update CHANGELOG.md on tag; regenerate changelog ([`6812ed6`](https://github.com/sorinirimies/nuance/commit/6812ed660a73c046c3d925f3779011a492ae4c4d))
- **security:** Add cargo-audit workflow and just audit recipe ([`ba8849a`](https://github.com/sorinirimies/nuance/commit/ba8849a01fd0d2dac885f6fc0f7ca83bd5a0e418))

### 🔧 Chores

- **justfile:** Push/pull current branch instead of hardcoded main ([`e0fda87`](https://github.com/sorinirimies/nuance/commit/e0fda87f94e3cec0a5691782aebcf3088e71aa17))
- **justfile:** Skip unconfigured remotes in *-all recipes ([`ed677a5`](https://github.com/sorinirimies/nuance/commit/ed677a5682f19e4158d1784a2195367d957cf711))
- Atomic vendoring, non-interactive nu guard, cargo-deny, changelog skips deps ([`9560304`](https://github.com/sorinirimies/nuance/commit/9560304163359e7cb2e87b28caf11f544298118e))

## [0.6.1](https://github.com/sorinirimies/nuance/compare/v0.6.0...v0.6.1) — 2026-10-09

### ✨ Features

- 72 themes (everforest-light, ayu-light, duskfox); fix import-here demo ([`bd44576`](https://github.com/sorinirimies/nuance/commit/bd4457652217eb03863a0a8718123990633493a7))

### 📚 Documentation

- Regenerate CHANGELOG ([`6c935df`](https://github.com/sorinirimies/nuance/commit/6c935df8a5bcd8a55a5371800c13cdf3e9a8eade))

### 🧪 Tests

- Portable stderr redirects (Windows) ([`5eda34a`](https://github.com/sorinirimies/nuance/commit/5eda34a0e9a9824a5a741bccc19263b4a81704d8))

## [0.6.0](https://github.com/sorinirimies/nuance/compare/v0.2.17...v0.6.0) — 2026-10-09

### ✨ Features

- Safety net, color fallback, user styles, completions, share strings, git modes, golden snapshots, split prompt sources ([`1adbec7`](https://github.com/sorinirimies/nuance/commit/1adbec71ddacc9b8091c7068823b28a8ffaa2230))
- Generic game-flavoured names + 10 new themes/styles/looks (heist, hollow cavern, portals, bonfire, farm, fighting, boons, climb, skillcheck, sandbox); generated gallery ([`df73401`](https://github.com/sorinirimies/nuance/commit/df73401b21513ee2406f58391857f6373b9efc75))
- Single-call git status (4x faster), operation state, adaptive path shortening, ASCII fallback, HUD right-prompt opt-out ([`2b53e3d`](https://github.com/sorinirimies/nuance/commit/2b53e3dfe7565fc438ba1126c8d0260534b34dd8))
- Clair Obscur: Expedition 33, better Mario, game themes/styles, 13 new styles, 8 new themes ([`2412533`](https://github.com/sorinirimies/nuance/commit/2412533b7d0ea5f0f86b564719e27ba0ad5ff5bd))
- 25 new themes, theme import, per-directory themes, configure wizard, doctor ([`b89007b`](https://github.com/sorinirimies/nuance/commit/b89007b79c67594f5a15e55da23476f9f75dd990))
- Transient prompt, context modules (status/jobs/ssh/root/venv/nix/lang/k8s), pastel + devbar styles ([`628eb15`](https://github.com/sorinirimies/nuance/commit/628eb156a3110022b1a225b7e3a1051f8a19e5d7))
- Segment engine, style registry, WCAG-checked palettes; add agnoster/skyline/pills styles ([`1522a98`](https://github.com/sorinirimies/nuance/commit/1522a986a72115341bc65fc6f58f18659456aa1a))

### 🐛 Bug fixes

- External commands that are not installed no longer raise (os-dark-mode on Linux, git/whoami); $nu.home-dir instead of $env.HOME ([`ee8a0a5`](https://github.com/sorinirimies/nuance/commit/ee8a0a591d5ea78cb67dc42be2e38f53026d855c))
- **docs:** Re-record doctor/picker/welcome/transient/modules GIFs; doctor shows ~ paths ([`9bb6972`](https://github.com/sorinirimies/nuance/commit/9bb69727b2a0aa8f1d430138c6df2dc3feee768b))
- Doctor crashed when the autoload file is missing; whoami fallback ([`793627e`](https://github.com/sorinirimies/nuance/commit/793627eb25be91372899f4ff468e078f02fbccf8))
- **ci:** Nu 0.114 compatibility; add CLI integration tests, new demo tapes, docs ([`106f15b`](https://github.com/sorinirimies/nuance/commit/106f15bd79337aab19f2d4078acb10012514ffff))

### 📚 Documentation

- Regenerate CHANGELOG ([`fe49536`](https://github.com/sorinirimies/nuance/commit/fe495361de2bfcc969a872632700a204b5ca5e4a))
- Re-record every demo GIF; add configure tape; faster pickers; push LFS to Gitea starscream ([`c116a3c`](https://github.com/sorinirimies/nuance/commit/c116a3ce8796b752e8e423222b4c3e27b8df107c))

### 🧪 Tests

- Run the gallery check with the current nu binary ([`3c1b7c0`](https://github.com/sorinirimies/nuance/commit/3c1b7c051ad42d6153c09c4f51eb55b656b47772))

## [0.2.17](https://github.com/sorinirimies/nuance/compare/v0.2.5...v0.2.17) — 2026-10-06

### 🐛 Bug fixes

- Correct justfile remote names (gitea-microlab/starscream -> gitea/gitea_starscream); fix nu str downcase deprecation in test.nu ([`a57d05c`](https://github.com/sorinirimies/nuance/commit/a57d05c6c1aabb09685e033ad04ce4afa944f8dd))

### 📦 Dependencies

- Nightly dependency upgrade 2026-10-06 ([`7db14e5`](https://github.com/sorinirimies/nuance/commit/7db14e5255edbc2c30806195f9f6357e2ef0c110))
- Nightly dependency upgrade 2026-10-04 ([`01141c2`](https://github.com/sorinirimies/nuance/commit/01141c2c810e5a92a65bef1e2aad375d05f7c8ba))
- Nightly dependency upgrade 2026-10-03 ([`f8cc751`](https://github.com/sorinirimies/nuance/commit/f8cc75103342b06a8d006bcdee269243fdcdf2e9))
- Nightly dependency upgrade 2026-10-01 ([`d9168c5`](https://github.com/sorinirimies/nuance/commit/d9168c51c54c18fb5c2b6907da3d16b804d9264f))
- Nightly dependency upgrade 2026-09-26 ([`57e121c`](https://github.com/sorinirimies/nuance/commit/57e121c3623c9a2176ceed869346f0268a51689a))
- Nightly dependency upgrade 2026-09-24 ([`b499b72`](https://github.com/sorinirimies/nuance/commit/b499b72701a0cf9ff691d3e5114e97767d7df988))
- Nightly dependency upgrade 2026-09-23 ([`85f3c39`](https://github.com/sorinirimies/nuance/commit/85f3c393cd0039acd4907f0d49dc305316af51f8))
- Nightly dependency upgrade 2026-09-22 ([`b2e85b8`](https://github.com/sorinirimies/nuance/commit/b2e85b865e3fe491c85955a9e0c08df1b788ef2b))
- Nightly dependency upgrade 2026-09-19 ([`453b4e4`](https://github.com/sorinirimies/nuance/commit/453b4e459a5800237a66da0216a289f611696c9f))
- Nightly dependency upgrade 2026-09-17 ([`26efb61`](https://github.com/sorinirimies/nuance/commit/26efb61757c81db3f03336e56370a671efbac5eb))
- Nightly dependency upgrade 2026-09-15 ([`27d269e`](https://github.com/sorinirimies/nuance/commit/27d269e0b7a923570c87e23cf3853e9e7f6ec590))
- Nightly dependency upgrade 2026-09-12 ([`ec7b9ac`](https://github.com/sorinirimies/nuance/commit/ec7b9ac34566393725dfd38acd13a8a2a375b82f))

### 🔄 CI and release

- Nightly job upgrades Cargo.toml requirements; justfile: add missing recipes; ignore .codegraph ([`c499668`](https://github.com/sorinirimies/nuance/commit/c4996686808d151db524b1882650f271ecee809a))
- Release only when a direct dependency changes; fix mirror push gate; add downloads badge ([`5f4a8c2`](https://github.com/sorinirimies/nuance/commit/5f4a8c2e2cb0c3062cad3166d6b4a9bab3974401))

## [0.2.5](https://github.com/sorinirimies/nuance/compare/v0.2.4...v0.2.5) — 2026-09-10

### 📦 Dependencies

- Nightly dependency upgrade 2026-09-10 ([`f1558a7`](https://github.com/sorinirimies/nuance/commit/f1558a704e54bf18b8036dec88ec84e6e2d47903))

## [0.2.4](https://github.com/sorinirimies/nuance/compare/v0.2.3...v0.2.4) — 2026-09-08

### 📦 Dependencies

- Nightly dependency upgrade 2026-09-08 ([`52348c7`](https://github.com/sorinirimies/nuance/commit/52348c7747ce26b9272e0b29ea053a607eecdd9e))

## [0.1.1](https://github.com/sorinirimies/nuance/compare/v0.1.0...v0.1.1) — 2026-08-20

### 🔄 CI and release

- Retest Gitea Actions trigger ([`80e2663`](https://github.com/sorinirimies/nuance/commit/80e26632e823ae9bdba95ea9a3d84f6e94b1c249))

## [0.1.0](https://github.com/sorinirimies/nuance/releases/tag/v0.1.0) — 2026-08-19

### 📚 Documentation

- Add badges to README ([`e68cde2`](https://github.com/sorinirimies/nuance/commit/e68cde26e10c4f91a92d018e37506c901f40210a))

### 🧪 Tests

- Pin XDG_CONFIG_HOME/CACHE_HOME/DATA_HOME per-test (fix CI flakiness) ([`00cd63e`](https://github.com/sorinirimies/nuance/commit/00cd63e7f409ea8c9aebc1153b07c4109c437675))

### 🔄 CI and release

- Fix GitHub Release creation (both GitHub + Gitea workflows) ([`4c6f56c`](https://github.com/sorinirimies/nuance/commit/4c6f56cd78dec6161704cd38e95066b1bdf560cf))


