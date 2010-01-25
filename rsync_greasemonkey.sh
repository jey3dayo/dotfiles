rsync --progress --delete -avp ~/Library/Application\ Support/Firefox/Profiles/*/gm_scripts ~/Documents/dotfiles/firefox_profiles/
rsync --progress --delete -avp ~/.vim ~/Documents/dotfiles/.vim/
rsync --progress --delete -avp ~/.vimperator ~/Documents/dotfiles/.vimperator/
rsync --progress --delete -avp ~/.irssi ~/Documents/dotfiles/.irssi/

rsync --progress -avp ~/.vimrc          ~/Documents/dotfiles/.vimrc
rsync --progress -avp ~/.vimperatorrc   ~/Documents/dotfiles/.vimperatorrc
rsync --progress -avp ~/.zshrc          ~/Documents/dotfiles/.zshrc
rsync --progress -avp ~/.gvimrc         ~/Documents/dotfiles/.gvimrc
rsync --progress -avp ~/.screenrc       ~/Documents/dotfiles/.screenrc
