# j138 .zshrc
setopt append_history
setopt auto_cd
setopt auto_menu
setopt auto_name_dirs
setopt auto_param_keys
setopt auto_param_slash
setopt auto_pushd
setopt auto_remove_slash
setopt complete_aliases
setopt complete_in_word
setopt correct
setopt extended_glob
setopt extended_history
setopt globdots
setopt hist_ignore_dups
setopt hist_ignore_space
setopt list_packed
setopt hist_verify
setopt list_types
setopt magic_equal_subst
setopt mark_dirs
setopt no_beep
setopt nolistbeep
setopt noautoremoveslash
setopt nonomatch
setopt notify
setopt print_eight_bit
setopt prompt_subst
setopt pushd_ignore_dups
setopt rm_star_silent
setopt rm_star_wait
setopt share_history

autoload zed

# historical backward/forward search with linehead string binded to ^P/^N
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^p" history-beginning-search-backward-end
bindkey "^n" history-beginning-search-forward-end


if [[ -s "${ZDOTDIR:-$HOME}/.zplug/init.zsh" ]]; then
  export ZPLUG_HOME="${ZDOTDIR}/.zplug"
  source "${ZPLUG_HOME}/init.zsh"

  zplug "modules/history", from:prezto
  zplug "modules/environment", from:prezto
  zplug "modules/terminal", from:prezto
  zplug "modules/editor", from:prezto
  zplug "modules/directory", from:prezto
  zplug "modules/spectrum", from:prezto
  zplug "modules/utility", from:prezto
  zplug "modules/completion", from:prezto
  zplug "modules/tmux", from:prezto
  zplug "modules/osx", from:prezto
  zplug "modules/history-substring-search", from:prezto
  zplug "modules/prompt", from:prezto
  zplug "modules/tmux:iterm", from:prezto
  zplug load
fi

if command -v powerline-daemon>/dev/null; then
  powerline-daemon -q
  . /usr/local/lib/python2.7/site-packages/powerline/bindings/zsh/powerline.zsh
fi

# load sources
for f ("${ZDOTDIR:-$HOME}"/plugin-sources/*) source "${f}"

# vim: set syntax=zsh:
