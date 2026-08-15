#!/usr/bin/env bash
# scripts/install.sh — no cargo? grab the prebuilt `nuance` binary straight
# from GitHub Releases. No package managers, no compiling, no bootstrapping
# Nushell for you — `nuance` handles that itself the first time you run it
# (offers `cargo install nu` if cargo is around, otherwise asks you to grab
# Nushell from https://www.nushell.sh once).
#
#   curl -fsSL https://raw.githubusercontent.com/sorinirimies/nuance/main/scripts/install.sh | bash
#   wget -qO- https://raw.githubusercontent.com/sorinirimies/nuance/main/scripts/install.sh | bash
set -euo pipefail

REPO="sorinirimies/nuance"
BINDIR="${NUANCE_INSTALL_DIR:-$HOME/.local/bin}"

info() { printf '\033[1;32m==>\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31mx  \033[0m %s\n' "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

have curl || die "need curl"

case "$(uname -s)" in
  Darwin) plat="apple-darwin" ;;
  Linux)  plat="unknown-linux-gnu" ;;
  *) die "unsupported OS: $(uname -s) — see https://github.com/${REPO}" ;;
esac
case "$(uname -m)" in
  x86_64|amd64)  arch=x86_64 ;;
  arm64|aarch64) arch=aarch64 ;;
  *) die "unsupported CPU architecture: $(uname -m)" ;;
esac
target="${arch}-${plat}"
asset="nuance-cli-${target}.tar.gz"

info "Fetching latest nuance release for ${target}…"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
curl -fsSL "https://github.com/${REPO}/releases/latest/download/${asset}" -o "$tmp/${asset}" \
  || die "no release build for ${target} yet — see https://github.com/${REPO}/releases"
tar -xzf "$tmp/${asset}" -C "$tmp"

mkdir -p "$BINDIR"
find "$tmp" -type f -name nuance -exec cp {} "$BINDIR/nuance" \;
chmod +x "$BINDIR/nuance"

info "installed -> ${BINDIR}/nuance"
case ":$PATH:" in
  *":$BINDIR:"*) ;;
  *) printf '\033[1;33m!  \033[0m add %s to your PATH:  export PATH="%s:$PATH"\n' "$BINDIR" "$BINDIR" ;;
esac
printf '\033[1;32m✓ done.\033[0m Try:  %s/nuance theme\n' "$BINDIR"
