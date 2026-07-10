#!/usr/bin/env bash
# install.sh — bootstrap for nushell-prompt (macOS / Linux).
# Usage:  ./install.sh [--copy]
set -euo pipefail

if ! command -v nu >/dev/null 2>&1; then
  echo "error: Nushell (nu) is not installed."
  echo "Install it first:  https://www.nushell.sh/book/installation.html"
  echo "  macOS:  brew install nushell"
  echo "  Linux:  cargo install nu   (or your distro's package manager)"
  exit 1
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec nu "$DIR/install.nu" "$@"
