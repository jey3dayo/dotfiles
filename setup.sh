#!/bin/sh
set -eu

resolve_repo_root() {
  target=$0

  case $target in
    /*) ;;
    *) target=$(command -v -- "$target") ;;
  esac

  while [ -L "$target" ]; do
    link=$(readlink "$target")
    case $link in
      /*) target=$link ;;
      *) target=$(dirname "$target")/$link ;;
    esac
  done

  cd "$(dirname "$target")" && pwd -P
}

DOTFILES=${DOTFILES:-"$(resolve_repo_root)"}

if [ ! -d "$DOTFILES" ]; then
  echo "Dotfiles directory not found: $DOTFILES" >&2
  exit 1
fi

XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME/.config"}
XDG_CACHE_HOME=${XDG_CACHE_HOME:-"$HOME/.cache"}
XDG_DATA_HOME=${XDG_DATA_HOME:-"$HOME/.local/share"}
XDG_STATE_HOME=${XDG_STATE_HOME:-"$HOME/.local/state"}

link() {
  src=$1
  dest=$2

  if [ ! -e "$src" ]; then
    printf "Missing source: %s\n" "$src" >&2
    exit 1
  fi

  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    backup="${dest}.bak.$(date +%s)"
    mv "$dest" "$backup"
    printf "Backed up %s to %s\n" "$dest" "$backup"
  fi

  mkdir -p "$(dirname "$dest")"
  ln -sfn "$src" "$dest"
}

# Base directories (idempotent)
mkdir -p \
  "$HOME/tmp" \
  "$XDG_CONFIG_HOME" \
  "$XDG_CACHE_HOME" \
  "$XDG_DATA_HOME" \
  "$XDG_STATE_HOME" \
  "$HOME/.local/share/zsh-autocomplete" \
  "$HOME/.mise" \
  "$HOME/.ssh/ssh_config.d" \
  "$HOME/.ssh/sockets" \
  "$HOME/.awsume"

# XDG config directories managed by the repo
CONFIG_DIRS="
alacritty
btop
claude
codex
cursor
efm-langserver
flipper
gh
git
helm
htop
karabiner
mise
nvim
projects-config
ssh
tmux
wezterm
yamllint
zed
zsh
zsh-abbr
"

for dir in $CONFIG_DIRS; do
  link "$DOTFILES/$dir" "$XDG_CONFIG_HOME/$dir"
done

# File-level configs
link "$DOTFILES/.gitignore" "$XDG_CONFIG_HOME/.gitignore"
link "$DOTFILES/.ripgreprc" "$XDG_CONFIG_HOME/.ripgreprc"
link "$DOTFILES/Brewfile" "$XDG_CONFIG_HOME/Brewfile"
link "$DOTFILES/Brewfile.lock.json" "$XDG_CONFIG_HOME/Brewfile.lock.json"
link "$DOTFILES/nirc" "$XDG_CONFIG_HOME/nirc"
link "$DOTFILES/pycodestyle" "$XDG_CONFIG_HOME/pycodestyle"
link "$DOTFILES/starship.toml" "$XDG_CONFIG_HOME/starship.toml"
link "$DOTFILES/typos.toml" "$XDG_CONFIG_HOME/typos.toml"
link "$DOTFILES/taplo.toml" "$XDG_CONFIG_HOME/taplo.toml"
link "$DOTFILES/stylua.toml" "$XDG_CONFIG_HOME/stylua.toml"
link "$DOTFILES/biome.json" "$XDG_CONFIG_HOME/biome.json"
link "$DOTFILES/hadolint.yaml" "$XDG_CONFIG_HOME/hadolint/config.yaml"
link "$DOTFILES/global-package.json" "$XDG_CONFIG_HOME/global-package.json"
link "$DOTFILES/shellcheckrc" "$HOME/.shellcheckrc"
link "$DOTFILES/.mise.toml" "$XDG_CONFIG_HOME/.mise.toml"

# Tool-specific entrypoints
link "$DOTFILES/awsume/config.yaml" "$HOME/.awsume/config.yaml"
link "$DOTFILES/.tmux/main.conf" "$HOME/.tmux.conf"
link "$DOTFILES/zsh/.zshenv" "$HOME/.zshenv"
link "$XDG_CONFIG_HOME/git/config" "$HOME/.gitconfig"
link "$XDG_CONFIG_HOME/ssh/config" "$HOME/.ssh/config"

chmod 700 "$HOME/.ssh"

if [ -f "$DOTFILES/.gitmodules" ]; then
  git -C "$DOTFILES" submodule update --init --recursive
fi

printf "Dotfiles setup complete. XDG config: %s\n" "$XDG_CONFIG_HOME"
