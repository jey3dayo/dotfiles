# jey3dayo .zshrc
bindkey -e

if (( $+commands[sw_vers] )) && (( $+commands[arch] )); then
  [[ -x /usr/local/bin/brew ]] && alias brew="arch -arch x86_64 /usr/local/bin/brew"
  alias x64='exec arch -x86_64 /bin/zsh'
  alias a64='exec arch -arm64e /bin/zsh'
  switch-arch() {
    if  [[ "$(uname -m)" == arm64 ]]; then
      arch=x86_64
    elif [[ "$(uname -m)" == x86_64 ]]; then
      arch=arm64e
    fi
    exec arch -arch $arch /bin/zsh
  }
fi

if [ "$(uname -m)" = "arm64" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
  path=(/opt/homebrew/bin(N-/) $path)
else
  eval "$(/usr/local/bin/brew shellenv)"
fi

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
setopt magic_equal_subst

autoload zed

# load sources
for f ("${ZDOTDIR:-$HOME}"/plugin-sources/*) source "${f}"

# vim: set syntax=zsh:
