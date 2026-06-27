export ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
mkdir -p "${ZSH_COMPDUMP:h}"

add_fpath() {
  local dir="$1"
  [[ -n "$dir" && -d "$dir" ]] || return 0
  fpath=("$dir" "${fpath[@]}")
}

fpath=(
  "${ZDOTDIR:-$HOME/.config/zsh}/completions"
  /opt/homebrew/share/zsh/site-functions
  "${fpath[@]}"
)

add_fpath "${XDG_DATA_HOME:-$HOME/.local/share}/sheldon/repos/github.com/eza-community/eza/completions/zsh"
add_fpath "$HOME/.bun"
unfunction add_fpath 2>/dev/null

zmodload -i zsh/complist
autoload -Uz compinit

if [[ -r "$ZSH_COMPDUMP" ]]; then
  compinit -C -d "$ZSH_COMPDUMP"
else
  compinit -d "$ZSH_COMPDUMP"
fi

zstyle ':completion:*' use-cache true
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*:(ssh|scp|sshfs):*' users

# vim: set syntax=zsh:
