# HISTSIZE / SAVEHIST are set in .zshenv; this file only wires key bindings.
mkdir -p "${HISTFILE:h}"

autoload -Uz history-search-end

zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey '^p' history-beginning-search-backward-end
bindkey '^n' history-beginning-search-forward-end

# vim: set syntax=zsh:
