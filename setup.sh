#!/bin/sh
USER=$(id -u)
DOTFILES=$HOME/src/github.com/jey3dayo/dotfiles

mkdir -p "${HOME}/{tmp,.cache,.config}"
mkdir -p "${HOME}/.local/share/zsh-autocomplete/"
chown -R "${USER}" "${HOME}/{tmp,.cache}"
mkdir -p "${HOME}/.mise"

ln -sf "${DOTFILES}" ~/.config

echo "source $HOME/.config/nvim/init.vim" >>~/.vimrc
echo "source-file $HOME/.tmux/main.conf" >>~/.tmux.conf

export ZDOTDIR=~/src/github.com/.config/.zsh
echo "source $ZDOTDIR/.zshenv" >>~/.zshenv

git submodule foreach git pull
