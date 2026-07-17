#!/usr/bin/env bash
# bootstrap.sh — install Nushell (if missing) + set up nuance, in one go.
#
#   curl -fsSL https://raw.githubusercontent.com/sorinirimies/nuance/main/bootstrap.sh | bash
#   wget -qO- https://raw.githubusercontent.com/sorinirimies/nuance/main/bootstrap.sh | bash
#
# Works on macOS and Linux (incl. WSL). Safe to re-run.
set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/sorinirimies/nuance/main"

info() { printf '\033[1;32m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!  \033[0m %s\n' "$*"; }
die()  { printf '\033[1;31mx  \033[0m %s\n' "$*" >&2; exit 1; }

have() { command -v "$1" >/dev/null 2>&1; }

os() { case "$(uname -s)" in Darwin) echo macos;; Linux) echo linux;; *) echo other;; esac; }
arch() { case "$(uname -m)" in x86_64|amd64) echo x86_64;; arm64|aarch64) echo aarch64;; *) echo unknown;; esac; }

# ── Install Nushell via prebuilt GitHub release binary (last-resort, no pkg mgr) ──
install_nu_prebuilt() {
  local a p target url tmp
  a="$(arch)"; [ "$a" = unknown ] && die "unsupported CPU architecture: $(uname -m)"
  case "$(os)" in
    macos) p="apple-darwin" ;;
    linux) p="unknown-linux-gnu" ;;
    *) die "unsupported OS" ;;
  esac
  target="${a}-${p}"
  info "Downloading Nushell prebuilt binary ($target)…"
  url="$(curl -fsSL https://api.github.com/repos/nushell/nushell/releases/latest \
    | grep -o "https://[^\"]*nu-[^\"]*${target}\.tar\.gz" | head -1)"
  [ -n "$url" ] || die "could not find a Nushell release for $target"
  tmp="$(mktemp -d)"
  curl -fsSL "$url" -o "$tmp/nu.tar.gz"
  tar -xzf "$tmp/nu.tar.gz" -C "$tmp"
  mkdir -p "$HOME/.local/bin"
  # the archive contains a folder with the `nu` binary
  find "$tmp" -type f -name nu -exec cp {} "$HOME/.local/bin/nu" \;
  chmod +x "$HOME/.local/bin/nu"
  rm -rf "$tmp"
  export PATH="$HOME/.local/bin:$PATH"
  have nu || die "Nushell install failed"
  warn "Installed to ~/.local/bin — add it to PATH:  export PATH=\"\$HOME/.local/bin:\$PATH\""
}

ensure_nu() {
  if have nu; then info "Nushell already installed ($(nu --version))"; return; fi
  warn "Nushell not found — installing…"
  case "$(os)" in
    macos)
      if have brew; then info "via Homebrew…"; brew install nushell
      else install_nu_prebuilt; fi ;;
    linux)
      if   have apt-get && apt-cache show nushell >/dev/null 2>&1; then
             info "via apt…"; sudo apt-get update -qq && sudo apt-get install -y nushell
      elif have pacman; then info "via pacman…"; sudo pacman -S --noconfirm nushell
      elif have dnf;    then info "via dnf…";    sudo dnf install -y nushell
      elif have zypper; then info "via zypper…"; sudo zypper install -y nushell
      elif have brew;   then info "via Homebrew…"; brew install nushell
      elif have cargo;  then info "via cargo (compiles, slow)…"; cargo install nu --locked
      else install_nu_prebuilt; fi ;;
    *) die "unsupported OS — install Nushell manually: https://www.nushell.sh" ;;
  esac
  have nu || die "Nushell install did not complete"
}

main() {
  have curl || have wget || die "need curl or wget"
  ensure_nu
  info "Setting up nuance…"
  nu -c "http get ${REPO_RAW}/install.nu | save -f /tmp/nuance-install.nu; nu /tmp/nuance-install.nu"
  printf '\033[1;32m✓ done.\033[0m Open a new shell (or run: exec nu)\n'
}

main "$@"
