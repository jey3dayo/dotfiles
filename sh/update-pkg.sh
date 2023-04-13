# zinit update --all &

# npm
npm -g i npm-check-updates &

# python
pip3 list --format json --outdated | jq .[].name | xargs pip install -U &

# node
yarn global upgrade &

brew update
brew upgrade
brew cleanup

softwareupdate --all --install --force
