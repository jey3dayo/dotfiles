# cli
zinit update --all
asdf plugin update --all

# python
pip3 list --format json --outdated | jq .[].name | xargs pip install -U
pipx upgrade-all

# node
npm -g i npm-check-updates

# mac
brew update
brew upgrade
brew cleanup
softwareupdate --all --install --force
