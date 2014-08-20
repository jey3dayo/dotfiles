# Setup

```
cd /www/
git clone https://github.com/j138/dotfiles
mkdir ~/tmp # backup files vim
mkdir ~/log # zshlogs
git submodule foreach git pull
```

# vim


``` ~/.vimrc
source ~/www/dotfiles/.vimrc
```

```
ln -s ~/www/dotfiles/.vim ~/.vim
curl https://raw.githubusercontent.com/Shougo/neobundle.vim/master/bin/install.sh | sh
cd ~/.vim/bundle/vimproc/

# 適宜読みかえ
make ./make_mac.mak

# プラグイン一括インストール
~/.vim/bundle/neobundle.vim/bin/neoinstall
```

# vimperator

```
ln -s ~/www/dotfiles/.vim ~/.vimperator
```

``` ~/.vimperatorrc
source ~/www/dotfiles/.vimperatorrc
```
# zsh

``` ~/.zshrc
source ~/.zsh/.zshrc
source ~/.zsh/percol.zsh
```

``` ~/.zshenv
source ~/.zsh/.zshenv
```

```
ln -s ~/www/dotfiles/.zsh ~/.zsh

# ついでにpercolも入れよう
# zsh起動して<C-r>で幸せになれる
pip install percol
```

# tmux
``` ~/.tmux.conf
source-file ~/www/dotfiles/.tmux.conf
```

```
cd ~/www/
git clone https://github.com/erikw/tmux-powerline
```

# misc

``` ~/.gitconfig
[include]
    path = ~/www/dotfiles/.gitconfig

[user]
    name = j138
    email = j138cm at gmail.com
```

