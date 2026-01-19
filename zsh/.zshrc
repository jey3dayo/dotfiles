# jey3dayo .zshrc
: "${XDG_STATE_HOME:=${HOME}/.local/state}"
bindkey -e

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
if [ -f "$XDG_CONFIG_HOME/.env" ]; then
  source "$XDG_CONFIG_HOME/.env"
fi
# Load shared constants before init (used by completion, etc.)
if [[ -r "${ZDOTDIR:-$HOME}/config/core/constants.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/config/core/constants.zsh"
fi
# Source initialization files first (order-dependent)
for f in "${ZDOTDIR:-$HOME}"/init/*.zsh; do source "${f}"; done

# Source additional configurations
for f in "${ZDOTDIR:-$HOME}"/sources/*.zsh; do source "${f}"; done

# History configuration
# Must be set here in .zshrc (after /etc/zshrc) to override macOS system defaults.
# /etc/zshrc sets HISTSIZE=2000 and SAVEHIST=1000, which we need to override.
# For non-interactive contexts (like 'zsh -c'), .zshenv also sets these values.
HISTSIZE=100000
SAVEHIST=100000
export HISTSIZE SAVEHIST

# Ensure history directory exists
mkdir -p "${HISTFILE:h}"

# SSH completion: disable user completion (only show hostnames, not system users)
zstyle ':completion:*:(ssh|scp|sshfs):*' users

# vim: set syntax=zsh:
