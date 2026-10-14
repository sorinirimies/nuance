# Changelog

All notable changes to this project are documented here. It is generated from
[Conventional Commits](https://www.conventionalcommits.org) by
[git-cliff](https://git-cliff.org) — do not edit it by hand.

## [Unreleased]

### 📚 Documentation

- Move full-screen terminal theme section near the top ([`1e78288`](https://github.com/sorinirimies/nuance/commit/1e7828819b6a789b23fb94415b35e4601bb1e928))
- Re-record terminal theme gif with more visible theme changes ([`b197679`](https://github.com/sorinirimies/nuance/commit/b197679b46e0642ee9bd9d43cd9120cb01ec8ade))
- Add terminal theme tape, gif and README entry ([`6addc33`](https://github.com/sorinirimies/nuance/commit/6addc332825d31cfeae69d63be552b0df24b4ef5))
- Add audit badge ([`3e216d0`](https://github.com/sorinirimies/nuance/commit/3e216d0e463726790e5b49a3c8a348bb70b3a376))
- Add audit badge ([`78fff00`](https://github.com/sorinirimies/nuance/commit/78fff001caa70e155fa6baf2f2127e6989432078))

### 📦 Dependencies

- Nightly dependency upgrade 2026-10-14 ([`fa8425d`](https://github.com/sorinirimies/nuance/commit/fa8425d9d6c157d4c3d39e0637508496f0baf633))
- Nightly dependency upgrade 2026-10-13 ([`ed5bf46`](https://github.com/sorinirimies/nuance/commit/ed5bf4641507d95c3d7dec1928149f04ac2f10b9))
- Nightly dependency upgrade 2026-10-13 ([`a132158`](https://github.com/sorinirimies/nuance/commit/a13215835d62a039ba32129f8567139ffcb8f8f4))

### 🔄 CI and release

- **release:** Git-cliff release notes + auto-update CHANGELOG.md on tag; regenerate changelog ([`6812ed6`](https://github.com/sorinirimies/nuance/commit/6812ed660a73c046c3d925f3779011a492ae4c4d))

### 🔧 Chores

- Atomic vendoring, non-interactive nu guard, cargo-deny, changelog skips deps ([`9560304`](https://github.com/sorinirimies/nuance/commit/9560304163359e7cb2e87b28caf11f544298118e))

## [0.6.3](https://github.com/sorinirimies/nuance/compare/v0.6.2...v0.6.3) — 2026-10-12

### 📦 Dependencies

- Nightly dependency upgrade 2026-10-12 ([`6ede03b`](https://github.com/sorinirimies/nuance/commit/6ede03b050b70f353e61d186c8394846b217f35b))

### 🔄 CI and release

- **security:** Add cargo-audit workflow and just audit recipe ([`ba8849a`](https://github.com/sorinirimies/nuance/commit/ba8849a01fd0d2dac885f6fc0f7ca83bd5a0e418))

## [0.6.2](https://github.com/sorinirimies/nuance/compare/v0.6.1...v0.6.2) — 2026-10-11

### 📦 Dependencies

- Nightly dependency upgrade 2026-10-11 ([`338f2ad`](https://github.com/sorinirimies/nuance/commit/338f2ad7d989a249e588a14d621e1fde0ca7ed4b))
- Nightly dependency upgrade 2026-10-10 ([`4fafdda`](https://github.com/sorinirimies/nuance/commit/4fafdda20c333605ade6cc955b6972d575ad9f61))

## [0.6.1](https://github.com/sorinirimies/nuance/compare/v0.6.0...v0.6.1) — 2026-10-09

### ✨ Features

- 72 themes (everforest-light, ayu-light, duskfox); fix import-here demo ([`bd44576`](https://github.com/sorinirimies/nuance/commit/bd4457652217eb03863a0a8718123990633493a7))

### 📚 Documentation

- Regenerate CHANGELOG ([`6c935df`](https://github.com/sorinirimies/nuance/commit/6c935df8a5bcd8a55a5371800c13cdf3e9a8eade))

### 🧪 Tests

- Portable stderr redirects (Windows) ([`5eda34a`](https://github.com/sorinirimies/nuance/commit/5eda34a0e9a9824a5a741bccc19263b4a81704d8))

## [0.6.0](https://github.com/sorinirimies/nuance/compare/v0.4.2...v0.6.0) — 2026-10-09

### ✨ Features

- Safety net, color fallback, user styles, completions, share strings, git modes, golden snapshots, split prompt sources ([`1adbec7`](https://github.com/sorinirimies/nuance/commit/1adbec71ddacc9b8091c7068823b28a8ffaa2230))
- Generic game-flavoured names + 10 new themes/styles/looks (heist, hollow cavern, portals, bonfire, farm, fighting, boons, climb, skillcheck, sandbox); generated gallery ([`df73401`](https://github.com/sorinirimies/nuance/commit/df73401b21513ee2406f58391857f6373b9efc75))
- Single-call git status (4x faster), operation state, adaptive path shortening, ASCII fallback, HUD right-prompt opt-out ([`2b53e3d`](https://github.com/sorinirimies/nuance/commit/2b53e3dfe7565fc438ba1126c8d0260534b34dd8))

### 🐛 Bug fixes

- External commands that are not installed no longer raise (os-dark-mode on Linux, git/whoami); $nu.home-dir instead of $env.HOME ([`ee8a0a5`](https://github.com/sorinirimies/nuance/commit/ee8a0a591d5ea78cb67dc42be2e38f53026d855c))
- **docs:** Re-record doctor/picker/welcome/transient/modules GIFs; doctor shows ~ paths ([`9bb6972`](https://github.com/sorinirimies/nuance/commit/9bb69727b2a0aa8f1d430138c6df2dc3feee768b))

### 📚 Documentation

- Regenerate CHANGELOG ([`fe49536`](https://github.com/sorinirimies/nuance/commit/fe495361de2bfcc969a872632700a204b5ca5e4a))

### 🧪 Tests

- Run the gallery check with the current nu binary ([`3c1b7c0`](https://github.com/sorinirimies/nuance/commit/3c1b7c051ad42d6153c09c4f51eb55b656b47772))

## [0.4.2](https://github.com/sorinirimies/nuance/compare/v0.5.2...v0.4.2) — 2026-10-09

### ✨ Features

- Clair Obscur: Expedition 33, better Mario, game themes/styles, 13 new styles, 8 new themes ([`2412533`](https://github.com/sorinirimies/nuance/commit/2412533b7d0ea5f0f86b564719e27ba0ad5ff5bd))

## [0.5.0](https://github.com/sorinirimies/nuance/compare/v0.4.0...v0.5.0) — 2026-10-07

### 🐛 Bug fixes

- Doctor crashed when the autoload file is missing; whoami fallback ([`793627e`](https://github.com/sorinirimies/nuance/commit/793627eb25be91372899f4ff468e078f02fbccf8))
- **ci:** Nu 0.114 compatibility; add CLI integration tests, new demo tapes, docs ([`106f15b`](https://github.com/sorinirimies/nuance/commit/106f15bd79337aab19f2d4078acb10012514ffff))

### 📚 Documentation

- Re-record every demo GIF; add configure tape; faster pickers; push LFS to Gitea starscream ([`c116a3c`](https://github.com/sorinirimies/nuance/commit/c116a3ce8796b752e8e423222b4c3e27b8df107c))

## [0.4.0](https://github.com/sorinirimies/nuance/compare/v0.3.0...v0.4.0) — 2026-10-07

### ✨ Features

- 25 new themes, theme import, per-directory themes, configure wizard, doctor ([`b89007b`](https://github.com/sorinirimies/nuance/commit/b89007b79c67594f5a15e55da23476f9f75dd990))
- Transient prompt, context modules (status/jobs/ssh/root/venv/nix/lang/k8s), pastel + devbar styles ([`628eb15`](https://github.com/sorinirimies/nuance/commit/628eb156a3110022b1a225b7e3a1051f8a19e5d7))
- Segment engine, style registry, WCAG-checked palettes; add agnoster/skyline/pills styles ([`1522a98`](https://github.com/sorinirimies/nuance/commit/1522a986a72115341bc65fc6f58f18659456aa1a))

## [0.2.17](https://github.com/sorinirimies/nuance/compare/v0.2.16...v0.2.17) — 2026-10-06

### 📦 Dependencies

- Nightly dependency upgrade 2026-10-06 ([`7db14e5`](https://github.com/sorinirimies/nuance/commit/7db14e5255edbc2c30806195f9f6357e2ef0c110))

### 🔄 CI and release

- Nightly job upgrades Cargo.toml requirements; justfile: add missing recipes; ignore .codegraph ([`c499668`](https://github.com/sorinirimies/nuance/commit/c4996686808d151db524b1882650f271ecee809a))
- Release only when a direct dependency changes; fix mirror push gate; add downloads badge ([`5f4a8c2`](https://github.com/sorinirimies/nuance/commit/5f4a8c2e2cb0c3062cad3166d6b4a9bab3974401))

## [0.2.16](https://github.com/sorinirimies/nuance/compare/v0.2.15...v0.2.16) — 2026-10-04

### 📦 Dependencies

- Nightly dependency upgrade 2026-10-04 ([`01141c2`](https://github.com/sorinirimies/nuance/commit/01141c2c810e5a92a65bef1e2aad375d05f7c8ba))

## [0.2.15](https://github.com/sorinirimies/nuance/compare/v0.2.14...v0.2.15) — 2026-10-03

### 📦 Dependencies

- Nightly dependency upgrade 2026-10-03 ([`f8cc751`](https://github.com/sorinirimies/nuance/commit/f8cc75103342b06a8d006bcdee269243fdcdf2e9))

## [0.2.14](https://github.com/sorinirimies/nuance/compare/v0.2.13...v0.2.14) — 2026-10-01

### 📦 Dependencies

- Nightly dependency upgrade 2026-10-01 ([`d9168c5`](https://github.com/sorinirimies/nuance/commit/d9168c51c54c18fb5c2b6907da3d16b804d9264f))

## [0.2.13](https://github.com/sorinirimies/nuance/compare/v0.2.12...v0.2.13) — 2026-09-26

### 📦 Dependencies

- Nightly dependency upgrade 2026-09-26 ([`57e121c`](https://github.com/sorinirimies/nuance/commit/57e121c3623c9a2176ceed869346f0268a51689a))

## [0.2.12](https://github.com/sorinirimies/nuance/compare/v0.2.11...v0.2.12) — 2026-09-24

### 📦 Dependencies

- Nightly dependency upgrade 2026-09-24 ([`b499b72`](https://github.com/sorinirimies/nuance/commit/b499b72701a0cf9ff691d3e5114e97767d7df988))

## [0.2.11](https://github.com/sorinirimies/nuance/compare/v0.2.10...v0.2.11) — 2026-09-23

### 📦 Dependencies

- Nightly dependency upgrade 2026-09-23 ([`85f3c39`](https://github.com/sorinirimies/nuance/commit/85f3c393cd0039acd4907f0d49dc305316af51f8))

## [0.2.10](https://github.com/sorinirimies/nuance/compare/v0.2.9...v0.2.10) — 2026-09-22

### 📦 Dependencies

- Nightly dependency upgrade 2026-09-22 ([`b2e85b8`](https://github.com/sorinirimies/nuance/commit/b2e85b865e3fe491c85955a9e0c08df1b788ef2b))

## [0.2.9](https://github.com/sorinirimies/nuance/compare/v0.2.8...v0.2.9) — 2026-09-19

### 📦 Dependencies

- Nightly dependency upgrade 2026-09-19 ([`453b4e4`](https://github.com/sorinirimies/nuance/commit/453b4e459a5800237a66da0216a289f611696c9f))

## [0.2.8](https://github.com/sorinirimies/nuance/compare/v0.2.7...v0.2.8) — 2026-09-17

### 📦 Dependencies

- Nightly dependency upgrade 2026-09-17 ([`26efb61`](https://github.com/sorinirimies/nuance/commit/26efb61757c81db3f03336e56370a671efbac5eb))

## [0.2.7](https://github.com/sorinirimies/nuance/compare/v0.2.6...v0.2.7) — 2026-09-15

### 📦 Dependencies

- Nightly dependency upgrade 2026-09-15 ([`27d269e`](https://github.com/sorinirimies/nuance/commit/27d269e0b7a923570c87e23cf3853e9e7f6ec590))

## [0.2.6](https://github.com/sorinirimies/nuance/compare/v0.2.5...v0.2.6) — 2026-09-12

### 🐛 Bug fixes

- Correct justfile remote names (gitea-microlab/starscream -> gitea/gitea_starscream); fix nu str downcase deprecation in test.nu ([`a57d05c`](https://github.com/sorinirimies/nuance/commit/a57d05c6c1aabb09685e033ad04ce4afa944f8dd))

### 📦 Dependencies

- Nightly dependency upgrade 2026-09-12 ([`ec7b9ac`](https://github.com/sorinirimies/nuance/commit/ec7b9ac34566393725dfd38acd13a8a2a375b82f))

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


