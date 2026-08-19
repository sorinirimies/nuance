# nuance — task runner
#
# Install just:     cargo install just
# Install nushell:  https://www.nushell.sh (or: cargo install nu)
# Usage:            just <task>   |   just --list

# Default task — show available commands
default:
    @just --list

# ── Prerequisites ─────────────────────────────────────────────────────────────

# Check nu (nushell) is available
check-nu:
    @command -v nu >/dev/null 2>&1 || { echo "❌ nu (nushell) not found. Install: https://www.nushell.sh"; exit 1; }

# Check git-cliff is available
check-git-cliff:
    @command -v git-cliff >/dev/null 2>&1 || { echo "❌ git-cliff not found. Run: cargo install git-cliff"; exit 1; }

# Check vhs is available (for regenerating demo GIFs)
check-vhs:
    @command -v vhs >/dev/null 2>&1 || { echo "❌ vhs not found. Install: brew install vhs"; exit 1; }

# ── Build ─────────────────────────────────────────────────────────────────────

# Build the nuance-cli binary (debug)
build:
    cargo build

# Build the nuance-cli binary (release)
build-release:
    cargo build --release --locked

# Install `nuance` from this checkout (cargo install --path .)
install:
    cargo install --path . --locked

# ── Code quality ──────────────────────────────────────────────────────────────

# Format code
fmt:
    cargo fmt

# Check formatting (CI-safe, no writes)
fmt-check:
    cargo fmt -- --check

# Run clippy
clippy:
    cargo clippy --all-targets -- -D warnings

# Run all quality checks (fmt, clippy, both test suites)
check-all: fmt-check clippy test test-nu
    @echo "✅ All checks passed!"

# ── Tests ─────────────────────────────────────────────────────────────────────

# Run the Rust test suite (nuance-cli: cli.rs, ansi.rs, nu.rs, tui.rs, tests/cli.rs)
test:
    cargo test --locked

# Run the Nushell test suite (nushell-prompt.nu: themes/styles/looks/helpers)
test-nu: check-nu
    nu test.nu

# Run both suites
test-all: test test-nu
    @echo "✅ All Rust and Nushell tests passed!"

# ── The prompt itself (pure Nushell, no cargo needed) ─────────────────────────

# Symlink nushell-prompt.nu into Nushell's autoload dir (repo stays source of truth)
install-nu: check-nu
    nu scripts/install.nu

# Same, but copy instead of symlinking
install-nu-copy: check-nu
    nu scripts/install.nu --copy

# Remove the prompt from Nushell's autoload dir
uninstall-nu: check-nu
    nu scripts/uninstall.nu

# ── Changelog (git-cliff, config: cliff.toml) ─────────────────────────────────

# Regenerate CHANGELOG.md (custom header + git-cliff body; see cliff.toml)
changelog: check-git-cliff
    #!/usr/bin/env sh
    set -e
    { \
        echo "# Changelog"; echo; \
        echo "All notable changes to this project are documented here — generated with"; \
        echo "[git-cliff](https://git-cliff.org) (config: [cliff.toml](cliff.toml))."; echo; \
        git-cliff --config cliff.toml; \
    } > CHANGELOG.md
    echo "✅ CHANGELOG.md regenerated!"

# Preview unreleased changes (no file write)
changelog-preview: check-git-cliff
    @git-cliff --config cliff.toml --unreleased

# ── Versioning ─────────────────────────────────────────────────────────────

# Show the current crate version (from Cargo.toml)
version:
    @grep '^version' Cargo.toml | head -1 | cut -d '"' -f2

# Bump the version in Cargo.toml, update Cargo.lock, commit, and tag v<version>.
bump version: check-all
    #!/usr/bin/env sh
    set -e
    sed -i.bak 's/^version *= *".*"/version     = "{{version}}"/' Cargo.toml && rm -f Cargo.toml.bak
    cargo check --locked >/dev/null 2>&1 || cargo check
    git add Cargo.toml Cargo.lock
    git commit -m "chore: bump version to {{version}}"
    git tag "v{{version}}"
    echo "✅ Bumped to {{version}} and tagged v{{version}} (not pushed yet — see: just release {{version}})"

# ── Release workflows ─────────────────────────────────────────────────────────

# Full automated release to GitHub — bumps version, commits, tags, and pushes.
release version: (bump version)
    @echo "Pushing branch and tag to GitHub…"
    git push origin main
    git push origin v{{version}}
    @echo "✅ Release v{{version}} pushed — GitHub Actions (release.yml) will build + publish to crates.io."

# Full automated release to Gitea (nexus-lab instance, SSH) only.
release-gitea-nexus-lab version: (bump version)
    @echo "Pushing branch and tag to Gitea (nexus-lab)…"
    git push gitea-nexus-lab main
    git push gitea-nexus-lab v{{version}}
    @echo "✅ Release v{{version}} pushed to Gitea (nexus-lab)."

# Full automated release to GitHub and Gitea.
release-all version: (bump version)
    @echo "Pushing branch and tag to GitHub and Gitea…"
    git push origin main
    git push gitea-nexus-lab main
    git push origin v{{version}}
    git push gitea-nexus-lab v{{version}}
    @echo "✅ Release v{{version}} pushed to all remotes."

# ── Git remotes & pushing ──────────────────────────────────────────────────────

# Show configured git remotes
remotes:
    @git remote -v

# Push the current branch to GitHub (origin)
push:
    git push origin main

# Push the current branch to Gitea (nexus-lab instance, http remote)
push-gitea-nexus-lab-http:
    git push gitea-nexus-lab-http main

# Push to Gitea (nexus-lab, SSH); skips LFS (its endpoint redirects to a dead host)
push-gitea-nexus-lab:
    GIT_LFS_SKIP_PUSH=1 git push gitea-nexus-lab main

# Push the current branch to all remotes (continues on failure)
push-all:
    #!/usr/bin/env sh
    failed=""
    git push origin main                              || failed="$failed origin"
    GIT_LFS_SKIP_PUSH=1 git push gitea-nexus-lab main  || failed="$failed gitea-nexus-lab"
    if [ -n "$failed" ]; then
        echo "⚠️  Failed to push to:$failed"
    else
        echo "✅ Pushed to GitHub and Gitea!"
    fi

# Pull the current branch from GitHub (origin)
pull:
    git pull origin main

# Pull the current branch from Gitea (nexus-lab instance, SSH)
pull-gitea-nexus-lab:
    GIT_LFS_SKIP_SMUDGE=1 git pull gitea-nexus-lab main

# Push all tags to GitHub
push-tags:
    git push origin --tags

# Push all tags to all remotes (continues on failure)
push-tags-all:
    #!/usr/bin/env sh
    failed=""
    git push origin --tags                             || failed="$failed origin"
    GIT_LFS_SKIP_PUSH=1 git push gitea-nexus-lab --tags || failed="$failed gitea-nexus-lab"
    if [ -n "$failed" ]; then
        echo "⚠️  Failed to push tags to:$failed"
    else
        echo "✅ Tags pushed to all remotes!"
    fi

# Force-sync Gitea (nexus-lab instance, SSH) with GitHub
sync-gitea-nexus-lab:
    GIT_LFS_SKIP_PUSH=1 git push gitea-nexus-lab main --force
    GIT_LFS_SKIP_PUSH=1 git push gitea-nexus-lab --tags --force
    @echo "✅ Gitea (nexus-lab) synced!"

# ── Demos (VHS tapes → docs/*.gif) ────────────────────────────────────────────

# Regenerate one demo GIF (usage: just tape welcome)
tape name: check-vhs
    vhs tapes/{{name}}.tape

# Regenerate every demo GIF
tapes-all: check-vhs
    #!/usr/bin/env sh
    set -e
    for f in tapes/*.tape; do
        echo "▶ vhs $f"
        vhs "$f"
    done
    echo "✅ All tapes regenerated!"

# ── Misc ───────────────────────────────────────────────────────────────────────

# Remove build artifacts
clean:
    cargo clean

# Show project info
info:
    @echo "Project:  nuance"
    @echo "Crate:    nuance-cli (bin: nuance)"
    @echo "Version:  $(just version)"
    @echo "License:  MIT"
    @echo "Repo:     https://github.com/sorinirimies/nuance"
