#!/usr/bin/env bash
set -euo pipefail

APT_PACKAGES=(
  ca-certificates
  curl
  git
  unzip
  wget
  build-essential
  zsh
  fzf
  ripgrep
  bat
  zoxide
  zsh-autosuggestions
  zsh-syntax-highlighting
)

have() {
  command -v "$1" >/dev/null 2>&1
}

ensure_dirs() {
  mkdir -p "$HOME/.local/bin"
  mkdir -p "$HOME/.config/starship"
}

apt_install() {
  sudo apt-get update
  sudo apt-get install -y "${APT_PACKAGES[@]}"
}

github_latest_asset() {
  local repo="$1"
  local pattern="$2"

  curl -fsSL "https://api.github.com/repos/$repo/releases/latest" |
    grep '"browser_download_url":' |
    sed -E 's/.*"([^"]+)".*/\1/' |
    grep -E "$pattern" |
    head -n 1
}

install_starship() {
  if have starship; then
    return
  fi

  curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin"
}

install_nvm() {
  if [ -s "$HOME/.nvm/nvm.sh" ]; then
    return
  fi

  local nvm_version="${NVM_VERSION:-v0.40.3}"
  curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${nvm_version}/install.sh" | bash
}

load_nvm() {
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
}

install_node_and_pnpm() {
  install_nvm
  load_nvm

  if ! have nvm; then
    echo "nvm failed to load." >&2
    return 1
  fi

  nvm install --lts
  nvm alias default 'lts/*'

  if ! have pnpm; then
    npm install -g pnpm
  fi
}

install_yazi() {
  if have yazi && have ya; then
    return
  fi

  local arch url tmpdir
  arch="$(uname -m)"

  case "$arch" in
  x86_64) arch='x86_64-unknown-linux-gnu' ;;
  aarch64) arch='aarch64-unknown-linux-gnu' ;;
  *)
    echo "Unsupported architecture for Yazi: $arch" >&2
    return 1
    ;;
  esac

  url="$(github_latest_asset 'sxyazi/yazi' "yazi-.*-${arch}\\.zip$")"
  [ -n "$url" ] || {
    echo "Could not find Yazi release asset." >&2
    return 1
  }

  tmpdir="$(mktemp -d)"
  trap 'rm -rf "$tmpdir"' RETURN

  curl -fsSL "$url" -o "$tmpdir/yazi.zip"
  unzip -q "$tmpdir/yazi.zip" -d "$tmpdir/extract"

  install -m 755 "$(find "$tmpdir/extract" -type f -name yazi | head -n 1)" "$HOME/.local/bin/yazi"
  install -m 755 "$(find "$tmpdir/extract" -type f -name ya | head -n 1)" "$HOME/.local/bin/ya"
}

install_aichat() {
  if have aichat; then
    return
  fi

  local arch url tmpdir
  arch="$(uname -m)"

  case "$arch" in
  x86_64) arch='x86_64-unknown-linux-musl' ;;
  aarch64) arch='aarch64-unknown-linux-musl' ;;
  *)
    echo "Unsupported architecture for aichat: $arch" >&2
    return 1
    ;;
  esac

  url="$(github_latest_asset 'sigoden/aichat' "aichat-.*-${arch}\\.tar\\.gz$")"
  [ -n "$url" ] || {
    echo "Could not find aichat release asset." >&2
    return 1
  }

  tmpdir="$(mktemp -d)"
  trap 'rm -rf "$tmpdir"' RETURN

  curl -fsSL "$url" -o "$tmpdir/aichat.tar.gz"
  tar -xzf "$tmpdir/aichat.tar.gz" -C "$tmpdir"

  install -m 755 "$(find "$tmpdir" -type f -name aichat | head -n 1)" "$HOME/.local/bin/aichat"
}

install_lazygit() {
  if have lazygit; then
    return
  fi

  local arch url tmpdir
  arch="$(uname -m)"

  case "$arch" in
  x86_64) arch='Linux_x86_64' ;;
  aarch64) arch='Linux_arm64' ;;
  *)
    echo "Unsupported architecture for lazygit: $arch" >&2
    return 1
    ;;
  esac

  url="$(github_latest_asset 'jesseduffield/lazygit' "lazygit_.*_${arch}\\.tar\\.gz$")"
  [ -n "$url" ] || {
    echo "Could not find lazygit release asset." >&2
    return 1
  }

  tmpdir="$(mktemp -d)"
  trap 'rm -rf "$tmpdir"' RETURN

  curl -fsSL "$url" -o "$tmpdir/lazygit.tar.gz"
  tar -xzf "$tmpdir/lazygit.tar.gz" -C "$tmpdir"

  install -m 755 "$tmpdir/lazygit" "$HOME/.local/bin/lazygit"
}

ensure_zsh_default() {
  if have zsh; then
    local zsh_path
    zsh_path="$(command -v zsh)"
    if [ "${SHELL:-}" != "$zsh_path" ]; then
      chsh -s "$zsh_path" || true
    fi
  fi
}

main() {
  ensure_dirs
  apt_install
  install_starship
  install_node_and_pnpm
  install_yazi
  install_aichat
  install_lazygit
  ensure_zsh_default

  echo
  echo "Done."
  echo "Open a new shell or run: exec zsh"
}

main "$@"
