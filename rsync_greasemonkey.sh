rsync --progress --delete -av ~/Library/Application\ Support/Firefox/Profiles/*/gm_scripts ~/Documents/dotfiles/firefox_profiles/
rsync --progress --delete -av ~/.vim ~/Documents/dotfiles/.vim/
rsync --progress --delete -av ~/.vimperator ~/Documents/dotfiles/.vimperator/
rsync --progress --delete -av ~/.irssi ~/Documents/dotfiles/.irssi/

rsync --progress -av ~/.vimrc          ~/Documents/dotfiles/.vimrc
rsync --progress -av ~/.vimperatorrc   ~/Documents/dotfiles/.vimperatorrc
rsync --progress -av ~/.zshrc          ~/Documents/dotfiles/.zshrc
rsync --progress -av ~/.gvimrc         ~/Documents/dotfiles/.gvimrc
rsync --progress -av ~/.screenrc       ~/Documents/dotfiles/.screenrc
