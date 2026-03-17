# ~/.zshrc

[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"

export PATH="$HOME/.local/bin:/usr/local/bin:$PATH"

# --- zoxide ---
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

# --- Starship ---
export STARSHIP_CONFIG="$HOME/.config/starship/beige.toml"
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# --- Aliases ---
alias pn='pnpm'
alias lgit='lazygit'
alias cls='clear'
alias bat='batcat'
alias ag='antigravity'
alias gh='"/mnt/c/Program Files/GitHub CLI/gh.exe"'

# --- yazi (cd into selected dir on exit) ---
function y() {
    command -v yazi >/dev/null 2>&1 || {
        echo "yazi is not installed." >&2
        return 127
    }

    local tmp
    tmp="$(mktemp -t yazi-cwd.XXXXXX 2>/dev/null || mktemp)"
    yazi "$@" --cwd-file="$tmp"

    if [ -f "$tmp" ]; then
        local cwd
        cwd="$(cat -- "$tmp")"
        if [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
            cd -- "$cwd"
        fi
    fi

    rm -f -- "$tmp"
}

# --- rg default to current dir unless path-like args are present ---
function rg() {
    if [[ "$*" != */* && "$*" != *..* ]]; then
        command rg "$@" .
    else
        command rg "$@"
    fi
}

# --- 0x0.st helpers ---
function oxo() {
    curl -4 --silent --show-error \
      --resolve 0x0.st:443:168.119.145.117 \
      -F "file=@$1" \
      https://0x0.st
}

function oxoget() {
    curl -L -4 \
      --resolve 0x0.st:443:168.119.145.117 \
      -o "${2:-$(basename "$1")}" \
      "$1"
}

# --- Bare dotfiles repo helper ---
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

# --- pnpm ---
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# --- nvm ---
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

# --- Interactive-only setup ---
if [[ $- == *i* ]]; then
    # startup art
    pink=$'\e[38;2;255;160;180m'
    reset=$'\e[0m'
    echo "${pink}⠀⠀⠀⠀⠀⠀⢀⣰⣀⠀⠀⠀⠀⠀⠀⠀⠀"
    echo "${pink}⢀⣀⠀⠀⠀⢀⣄⠘⠀⠀⣶⡿⣷⣦⣾⣿⣧"
    echo "${pink}⢺⣾⣶⣦⣰⡟⣿⡇⠀⠀⠻⣧⠀⠛⠀⡘⠏"
    echo "${pink}⠈⢿⡆⠉⠛⠁⡷⠁⠀⠀⠀⠀⠳⣦⣮⠁⠀"
    echo "${pink}⠀⠀⠛⢷⣄⣼⠃⠀⠀⠀⠀⠀⠀⠉⠀⠠⡧"
    echo "${pink}⠀⠀⠀⠀⠉⠋⠀⠀⠀⠠⡥⠄⠀⠀⠀⠀⠀${reset}"

    autoload -Uz compinit && compinit

    [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && \
        source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh

    # fzf integration: Debian/Ubuntu path first, fallback second
    if [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]; then
        source /usr/share/doc/fzf/examples/key-bindings.zsh
    elif [ -f /usr/share/fzf/key-bindings.zsh ]; then
        source /usr/share/fzf/key-bindings.zsh
    fi

    if [ -f /usr/share/doc/fzf/examples/completion.zsh ]; then
        source /usr/share/doc/fzf/examples/completion.zsh
    elif [ -f /usr/share/fzf/completion.zsh ]; then
        source /usr/share/fzf/completion.zsh
    fi

    # source syntax highlighting late
    [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && \
        source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

    # Word movement
    bindkey "^[[1;5C" forward-word        # Ctrl+Right
    bindkey "^[[1;5D" backward-word       # Ctrl+Left
    bindkey "^[[1;6C" forward-word        # Ctrl+Shift+Right
    bindkey "^[[1;6D" backward-word       # Ctrl+Shift+Left

    # Deletion
    bindkey "^H" backward-kill-word       # Ctrl+Backspace
    bindkey "^[[3;5~" kill-word           # Ctrl+Delete

    # History search by prefix
    bindkey "^[[A" history-beginning-search-backward
    bindkey "^[[B" history-beginning-search-forward
fi

