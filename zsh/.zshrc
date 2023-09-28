# jey3dayo .zshrc

# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.pre.zsh"

bindkey -e

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

# source command override technique
function source {
  ensure_zcompiled $1
  builtin source $1
}

function ensure_zcompiled {
  if [[ "$1" == *.zsh ]] || [[ "$1" == *.zshrc ]]; then
    local compiled="$1.zwc"
    if [[ ! -r "$compiled" || "$1" -nt "$compiled" ]]; then
      echo "\033[1;36mCompiling\033[m $1"
      zcompile $1
    fi
  fi
}
ensure_zcompiled $ZDOTDIR/.zshrc

# load sources
for f ("${ZDOTDIR:-$HOME}"/sources/*.zsh) source "${f}"
for f ("${ZDOTDIR:-$HOME}"/lazy-sources/*.zsh) zsh-defer source "${f}"

# removed custom source
zsh-defer unfunction source

# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.post.zsh"

# vim: set syntax=zsh:
