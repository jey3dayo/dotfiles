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

install_home_file() {
  src=$1
  dest=$2

  if [ ! -f "$src" ]; then
    printf "Missing source: %s\n" "$src" >&2
    return 1
  fi

  if [ -f "$dest" ]; then
    if cmp -s "$src" "$dest"; then
      printf "Unchanged: %s\n" "$dest"
      return 0
    fi
    backup="${dest}.bak.$(date +%s)"
    mv "$dest" "$backup"
    printf "Backed up %s -> %s\n" "$dest" "$backup"
  fi

  cp "$src" "$dest"
  printf "Installed: %s\n" "$dest"
}

# Base directories (idempotent)
mkdir -p \
  "$HOME/tmp" \
  "$HOME/.local/share/zsh-autocomplete" \
  "$HOME/.mise" \
  "$HOME/.ssh/ssh_config.d" \
  "$HOME/.ssh/sockets" \
  "$HOME/.awsume"

# Main symlink: ~/.config -> dotfiles
if [ -e "$HOME/.config" ] && [ ! -L "$HOME/.config" ]; then
  backup="$HOME/.config.bak.$(date +%s)"
  mv "$HOME/.config" "$backup"
  printf "Backed up existing .config to %s\n" "$backup"
fi

ln -sfn "$DOTFILES" "$HOME/.config"

# Install HOME entrypoints from home/ directory
for file in "$DOTFILES/home"/.[!.]*; do
  [ -f "$file" ] || continue
  filename=$(basename "$file")
  install_home_file "$file" "$HOME/$filename"
done

# SSH - Not XDG-compliant (symlink)
link "$DOTFILES/ssh/config" "$HOME/.ssh/config"

# AWSume - Not XDG-compliant (symlink)
link "$DOTFILES/awsume/config.yaml" "$HOME/.awsume/config.yaml"

# SSH permissions
chmod 700 "$HOME/.ssh"

# Git submodules
if [ -f "$DOTFILES/.gitmodules" ]; then
  git -C "$DOTFILES" submodule update --init --recursive
fi

printf "Dotfiles setup complete. XDG config: %s\n" "$HOME/.config"
