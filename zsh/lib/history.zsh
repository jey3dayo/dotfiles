HISTSIZE=100000
SAVEHIST=100000
export HISTSIZE SAVEHIST

mkdir -p "${HISTFILE:h}"

autoload -Uz history-search-end

zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey '^p' history-beginning-search-backward-end
bindkey '^n' history-beginning-search-forward-end

# vim: set syntax=zsh:
