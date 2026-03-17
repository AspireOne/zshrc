#!/usr/bin/env bash
set -euo pipefail

APT_FILE="$HOME/apt-packages.common.txt"
TOOLS_FILE="$HOME/tools.common.txt"

have() {
  command -v "$1" >/dev/null 2>&1
}

list_file_lines() {
  local file="$1"
  [ -f "$file" ] || return 0
  grep -Ev '^[[:space:]]*($|#)' "$file"
}

ensure_bootstrap_deps() {
  if ! have curl; then
    sudo apt-get update
    sudo apt-get install -y curl ca-certificates
  fi
}

install_apt_packages() {
  [ -f "$APT_FILE" ] || return 0

  sudo apt-get update
  list_file_lines "$APT_FILE" | xargs -r sudo apt-get install -y
}

run_tools_common() {
  [ -f "$TOOLS_FILE" ] || return 0

  while IFS= read -r cmd; do
    [ -n "$cmd" ] || continue
    echo "==> $cmd"
    bash -lc "$cmd"
  done < <(list_file_lines "$TOOLS_FILE")
}
#!/usr/bin/env bash
set -euo pipefail

APT_FILE="$HOME/apt-packages.common.txt"
TOOLS_FILE="$HOME/tools.common.txt"

have() {
  command -v "$1" >/dev/null 2>&1
}

list_file_lines() {
  local file="$1"
  [ -f "$file" ] || return 0
  grep -Ev '^[[:space:]]*($|#)' "$file"
}

ensure_bootstrap_deps() {
  if ! have curl; then
    sudo apt-get update
    sudo apt-get install -y curl ca-certificates
  fi
}

install_apt_packages() {
  [ -f "$APT_FILE" ] || return 0

  sudo apt-get update
  list_file_lines "$APT_FILE" | xargs -r sudo apt-get install -y
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
  ensure_bootstrap_deps
  install_apt_packages
  run_tools_common
  ensure_zsh_default

  echo
  echo "Done."
  echo "Open a new shell or run: exec zsh"
}

main "$@"

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
  ensure_bootstrap_deps
  install_apt_packages
  run_tools_common
  ensure_zsh_default

  echo
  echo "Done."
  echo "Open a new shell or run: exec zsh"
}

main "$@"
