rsync --progress --delete -avp ~/Library/Application\ Support/Firefox/Profiles/*/gm_scripts ~/Documents/dotfiles/firefox_profiles/
rsync --progress --delete -avp ~/.vim          ~/Documents/dotfiles/
rsync --progress --delete -avp ~/.vimperator   ~/Documents/dotfiles/
rsync --progress --delete -avp ~/.irssi        ~/Documents/dotfiles/
rsync --progress --delete -avp ~/.ssh          ~/Documents/dotfiles/
rsync --progress --delete -avp ~/log          ~/Documents/dotfiles/

rsync --progress -avp ~/.vimrc                 ~/Documents/dotfiles/
rsync --progress -avp ~/.vimperatorrc          ~/Documents/dotfiles/
rsync --progress -avp ~/.zshrc                 ~/Documents/dotfiles/
rsync --progress -avp ~/.gvimrc                ~/Documents/dotfiles/
rsync --progress -avp ~/.screenrc              ~/Documents/dotfiles/
rsync --progress -avp ~/.tmux.conf             ~/Documents/dotfiles/
rsync --progress -avp ~/.colordiffrc           ~/Documents/dotfiles/
rsync --progress -avp ~/.gitconfig             ~/Documents/dotfiles/
rsync --progress -avp ~/.gitignore             ~/Documents/dotfiles/

rsync --progress -avp /opt/local/apache2/conf/httpd.conf ~/Documents/dotfiles/
rsync --progress -avp /opt/local/etc/php5/php.ini        ~/Documents/dotfiles/
rsync --progress -avp /opt/local/etc/mysql5/my.cnf       ~/Documents/dotfiles/
