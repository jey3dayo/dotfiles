#!/bin/bash

# FIXME: shellから実行できない
# zinit self-update
# zinit update --all

asdf plugin update --all

# python
pip3 list --format json --outdated | jq .[].name | xargs pip install -U
pipx upgrade-all

# node
npm -g update
npm -g i npm-check-updates neovim

# mac
brew update
brew upgrade
brew cleanup
softwareupdate --all --install --force
