#!/usr/bin/env bash
set -euo pipefail

APT_FILE="$HOME/apt-packages.common.txt"
NPM_GLOBAL_FILE="$HOME/npm-global-packages.common.txt"
TOOLS_FILE="$HOME/tools.common.txt"

have() {
  command -v "$1" >/dev/null 2>&1
}

list_file_lines() {
  local file="$1"
  [ -f "$file" ] || return 0
  grep -Ev '^[[:space:]]*($|#)' "$file"
}

ensure_dirs() {
  mkdir -p "$HOME/.local/bin"
  mkdir -p "$HOME/.config/starship"
}

ensure_bootstrap_deps() {
  if ! have curl; then
    sudo apt-get update
    sudo apt-get install -y curl ca-certificates
  fi
}

ensure_npm_available() {
  if have npm; then
    return 0
  fi

  export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
  if [ -s "$NVM_DIR/nvm.sh" ]; then
    # Load nvm so npm is available in this non-interactive bootstrap shell.
    . "$NVM_DIR/nvm.sh"
  fi

  have npm
}

install_apt_packages() {
  [ -f "$APT_FILE" ] || return 0

  sudo apt-get update
  list_file_lines "$APT_FILE" | xargs -r sudo apt-get install -y
}

install_npm_global_packages() {
  [ -f "$NPM_GLOBAL_FILE" ] || return 0

  if ! ensure_npm_available; then
    echo "Skipping npm global packages: npm is not installed or not on PATH." >&2
    return 0
  fi

  mapfile -t packages < <(list_file_lines "$NPM_GLOBAL_FILE")
  [ "${#packages[@]}" -gt 0 ] || return 0

  npm install -g "${packages[@]}"
}

run_tools_common() {
  [ -f "$TOOLS_FILE" ] || return 0

  while IFS= read -r cmd; do
    [ -n "$cmd" ] || continue
    echo "==> $cmd"
    bash -lc "$cmd"
  done < <(list_file_lines "$TOOLS_FILE")
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
  ensure_bootstrap_deps
  install_apt_packages
  install_npm_global_packages
  run_tools_common
  ensure_zsh_default

  echo
  echo "Done."
  echo "Open a new shell or run: exec zsh"
}

main "$@"
