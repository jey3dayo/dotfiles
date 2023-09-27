# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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

# compiled zsh scripts
source zsh/hook/ensure_zcompiled.zsh
ensure_zcompiled ~/.zshrc

# load sources
for f ("${ZDOTDIR:-$HOME}"/sources/*.zsh) source "${f}"
for f ("${ZDOTDIR:-$HOME}"/lazy-sources/*.zsh) zsh-defer source "${f}"

# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.post.zsh"

# vim: set syntax=zsh:
