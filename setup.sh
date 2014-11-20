#!/bin/sh
USER=`id -u`
DOTFILES=$HOME/src/dotfiles

ln -s $DOTFILES/.vim ~/.vim
ln -s $DOTFILES/.zsh ~/.zsh
ln -s $DOTFILES/.tmux ~/.tmux
mkdir $HOME/{tmp,log,.cache}


echo "source $DOTFILES/.vimrc" >> ~/.vimrc
echo "source $DOTFILES/.vimperatorrc" >> ~/.vimperatorrc
echo "source $DOTFILES/.zsh/.zshrc" >> ~/.zshrc
echo "source $DOTFILES/.zsh/.zshenv" >> ~/.zshenv
echo "source-file $DOTFILES/.tmux/main.conf" >> ~/.tmux.conf


git config --global include.path $DOTFILES/.gitconfig
git config --global user.name "Junya Nakazato"
git config --global user.email nakazato_junya@ca-adv.co.jp


curl https://raw.githubusercontent.com/Shougo/neobundle.vim/master/bin/install.sh | sh
git clone https://github.com/Shougo/vimproc.vim $DOTFILES/.vim/bundle/vimproc.vim
cd $DOTFILES/.vim/bundle/vimproc.vim/
make -f ./make_unix.mak
$DOTFILES/.vim/bundle/neobundle.vim/bin/neoinstall


chown -R $USER $HOME/{tmp,log,.cache}

