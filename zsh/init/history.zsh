# History configuration.
#
# Must be set after /etc/zshrc so macOS defaults do not win. .zshenv also sets
# these values for non-interactive shells that skip .zshrc.
HISTSIZE=100000
SAVEHIST=100000
export HISTSIZE SAVEHIST

mkdir -p "${HISTFILE:h}"

# SSH completion: disable user completion and show hostnames only.
zstyle ':completion:*:(ssh|scp|sshfs):*' users

# vim: set syntax=zsh:
