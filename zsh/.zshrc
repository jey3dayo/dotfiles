# jey3dayo .zshrc
bindkey -e
source "${ZDOTDIR:-$HOME}/.zinit.zsh"

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

if command -v powerline-daemon>/dev/null; then
  PYTHON_VERSION=$(cat ~/.pyenv/version)
  PYTHON_REPOS_ROOT=~/.pyenv/versions/${PYTHON_VERSION}/lib/python3.8/site-packages
  if [[ -s "${PYTHON_REPOS_ROOT}" ]]; then
    powerline-daemon -q
    . $PYTHON_REPOS_ROOT/powerline/bindings/zsh/powerline.zsh
  else
    echo 'powerline.zsh not found'
  fi
fi

# load sources
for f ("${ZDOTDIR:-$HOME}"/plugin-sources/*) source "${f}"

ZSH_THEME="gruvbox"
SOLARIZED_THEME="dark"

# vim: set syntax=zsh:
