#!/bin/sh
USER=$(id -u)
DOTFILES=$HOME/src/github.com/j138/dotfiles

ln -s "${DOTFILES}"/.vim ~/.vim
ln -s "${DOTFILES}"/.zsh ~/.zsh
ln -s "${DOTFILES}"/.tmux ~/.tmux
mkdir -p "${HOME}"/{tmp,.cache}
chown -R "${USER}" "${HOME}"/{tmp,.cache}

echo "source $DOTFILES/.vimrc" > ~/.vimrc
echo "source $DOTFILES/.vimperatorrc" >> ~/.vimperatorrc
echo "source $DOTFILES/.zsh/.zshrc" > ~/.zshrc
echo "source $DOTFILES/.zsh/.zshrc.mine" >> ~/.zshrc.mine
echo "source $DOTFILES/.zsh/.zshenv" >> ~/.zshenv
echo "source-file $DOTFILES/.tmux/main.conf" >> ~/.tmux.conf

git config --global include.path "${DOTFILES}"/.gitconfig
git config --global user.name "Junya Nakazato"
git config --global user.email nakazato_junya@ca-adv.co.jp
