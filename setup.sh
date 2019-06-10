#!/bin/sh
USER=$(id -u)
DOTFILES=$HOME/src/github.com/j138/dotfiles

mkdir -p "${HOME}"/{tmp,.cache,.config}
chown -R "${USER}" "${HOME}"/{tmp,.cache}

ln -s "${DOTFILES}"/.vim ~/.config/nvim
ln -s "${DOTFILES}"/.vim ~/.vim
ln -s "${DOTFILES}"/.zsh ~/.config/.zsh
ln -s "${DOTFILES}"/.tmux ~/.tmux
ln -s "${DOTFILES}"/.config/powerline ~/.config/powerline
ln -s "${DOTFILES}"/.config/.ignore ~/.ignore

echo "source $DOTFILES/.vimrc" > ~/.vimrc
echo "source $DOTFILES/.vimperatorrc" >> ~/.vimperatorrc
echo "source-file $DOTFILES/.tmux/main.conf" >> ~/.tmux.conf

export ZDOTDIR=~/src/github.com/.config/.zsh
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
echo "export ZDOTDIR=$DOTFILES/.zsh" >> ~/.zshenv
echo "source $ZDOTDIR/.zshenv" >> ~/.zshenv

git submodule foreach git pull
