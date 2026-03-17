# Created by or 5.9

# ~/.zshrc
#
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"

export PATH="$HOME/.local/bin:/usr/local/bin:$PATH"

# --- zoxide ---
eval "$(zoxide init zsh)"

# --- Starship: reuse your existing beige.toml ---
export STARSHIP_CONFIG="$HOME/.config/starship/beige.toml"
eval "$(starship init zsh)"

# --- Aliases (your pnpm etc.) ---
alias pn='pnpm'
alias lgit='lazygit'
alias cls='clear'
alias bat="batcat"
alias ag='antigravity'
alias gh='"/mnt/c/Program Files/GitHub CLI/gh.exe"'

# --- yazi (same cd-on-exit trick as your y function) ---
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    local cwd="$(cat -- "$tmp")"
    if [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# --- rg default to current dir (mirrors your PS function) ---
function rg() {
    if [[ "$*" != */* && "$*" != *..* ]]; then
        command rg "$@" .
    else
        command rg "$@"
    fi
}

function oxo() { curl -4 --silent --show-error --resolve 0x0.st:443:168.119.145.117 -F "file=@$1" https://0x0.st }
function oxoget() { curl -L -4 --resolve 0x0.st:443:168.119.145.117 -o "${2:-$(basename $1)}" "$1" }
config() {
  local gitdir="$HOME/.cfg"

  if [ ! -d "$gitdir" ]; then
    echo "config: $gitdir does not exist." >&2
    echo "config: run: git clone --bare <your-dotfiles-repo-url> $gitdir" >&2
    return 1
  fi

  git --git-dir="$gitdir" --work-tree="$HOME" "$@"
}


if [ ! -d "$HOME/.cfg" ]; then
  echo "warning: dotfiles repo ~/.cfg is missing on this machine" >&2
fi

# --- Your startup art ---
pink=$'\e[38;2;255;160;180m'
reset=$'\e[0m'
echo "${pink}⠀⠀⠀⠀⠀⠀⢀⣰⣀⠀⠀⠀⠀⠀⠀⠀⠀"
echo "${pink}⢀⣀⠀⠀⠀⢀⣄⠘⠀⠀⣶⡿⣷⣦⣾⣿⣧"
echo "${pink}⢺⣾⣶⣦⣰⡟⣿⡇⠀⠀⠻⣧⠀⠛⠀⡘⠏"
echo "${pink}⠈⢿⡆⠉⠛⠁⡷⠁⠀⠀⠀⠀⠳⣦⣮⠁⠀"
echo "${pink}⠀⠀⠛⢷⣄⣼⠃⠀⠀⠀⠀⠀⠀⠉⠀⠠⡧"
echo "${pink}⠀⠀⠀⠀⠉⠋⠀⠀⠀⠠⡥⠄⠀⠀⠀⠀⠀${reset}"

# pnpm
export PNPM_HOME="/home/matej/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
#[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
autoload -Uz compinit && compinit
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

source /usr/share/doc/fzf/examples/key-bindings.zsh
source /usr/share/doc/fzf/examples/completion.zsh

# Word movement
bindkey "^[[1;5C" forward-word        # Ctrl+Right
bindkey "^[[1;5D" backward-word       # Ctrl+Left
bindkey "^[[1;6C" forward-word        # Ctrl+Shift+Right
bindkey "^[[1;6D" backward-word       # Ctrl+Shift+Left

# Deletion
bindkey "^H" backward-kill-word       # Ctrl+Backspace
bindkey "^[[3;5~" kill-word           # Ctrl+Delete

# History search by prefix (type partial command, then Up/Down)
bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward
