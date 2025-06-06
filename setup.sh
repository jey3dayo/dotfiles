#!/bin/sh
USER=$(id -u)
DOTFILES=$HOME/src/github.com/jey3dayo/dotfiles

# XDG base directories
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}

mkdir -p "${HOME}/{tmp,.cache}" "${XDG_CONFIG_HOME}"
mkdir -p "${HOME}/.local/share/zsh-autocomplete/" "${HOME}/.mise"
chown -R "${USER}" "${HOME}/{tmp,.cache}"

# Link dotfiles to the XDG configuration directory
ln -sfn "${DOTFILES}" "${XDG_CONFIG_HOME}"

# Git configuration
mkdir -p "${XDG_CONFIG_HOME}/git"
ln -sfn "${DOTFILES}/git/config" "${XDG_CONFIG_HOME}/git/config"

echo "source ${XDG_CONFIG_HOME}/nvim/init.vim" >>~/.vimrc
echo "source-file ${XDG_CONFIG_HOME}/.tmux/main.conf" >>~/.tmux.conf

export ZDOTDIR="${XDG_CONFIG_HOME}/zsh"
echo "source $ZDOTDIR/.zshenv" >>~/.zshenv

git submodule foreach git pull
