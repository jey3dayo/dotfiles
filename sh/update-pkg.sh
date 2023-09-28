#!/bin/bash

asdf plugin update --all

sheldon lock --update

# python
pip3 install --upgrade pip
pip3 list --format json --outdated | jq .[].name | xargs pip3 install -U
pipx upgrade-all

# node
npm -g update
npm -g i npm-check-updates neovim

# mac
brew update
brew upgrade
brew cleanup
softwareupdate --all --install --force
