# j138 .zshrc

HISTFILE=$HOME/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

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
setopt hist_reduce_blanks
setopt hist_verify
setopt hist_no_store
setopt list_packed
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

if [[ -s "${ZDOTDIR:-$HOME}/.zplug/init.zsh" ]]; then
  export ZPLUG_HOME="${HOME}/.cache/zplug"
  source "${ZDOTDIR}/.zplug/init.zsh"

  zplug "zsh-users/zsh-completions"
  zplug "felixr/docker-zsh-completion"
  zplug "zsh-users/zsh-syntax-highlighting", defer:2
  zplug "modules/environment", from:prezto
  zplug "modules/editor", from:prezto
  zplug "modules/spectrum", from:prezto
  zplug "modules/tmux", from:prezto
  zplug "modules/prompt", from:prezto
  zplug "b4b4r07/enhancd"
  zplug "mollifier/anyframe"

  if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
  fi

  zplug load

  bindkey '^R' anyframe-widget-execute-history
  bindkey '^T' anyframe-widget-cd-ghq-repository
fi

if command -v powerline-daemon>/dev/null; then
  powerline-daemon -q
  . /usr/local/lib/python2.7/site-packages/powerline/bindings/zsh/powerline.zsh
fi

# load sources
for f ("${ZDOTDIR:-$HOME}"/plugin-sources/*) source "${f}"

# historical backward/forward search with linehead string binded to ^P/^N
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^p" history-beginning-search-backward-end
bindkey "^n" history-beginning-search-forward-end

# vim: set syntax=zsh:
