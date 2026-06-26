export ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
mkdir -p "${ZSH_COMPDUMP:h}"

fpath=(
  "${ZDOTDIR:-$HOME/.config/zsh}/completions"
  /opt/homebrew/share/zsh/site-functions
  "${fpath[@]}"
)

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
