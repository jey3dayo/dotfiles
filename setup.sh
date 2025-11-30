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

# XDG non-compliant tools - Entrypoints only
# Zsh - Load via ZDOTDIR
link "$DOTFILES/zsh/.zshenv" "$HOME/.zshenv"

# Git - Load via include directive
if [ ! -f "$HOME/.gitconfig" ]; then
  cat > "$HOME/.gitconfig" << 'EOF'
[include]
  path = ~/.config/git/config
  path = ~/.gitconfig_local
EOF
  printf "Created %s\n" "$HOME/.gitconfig"
fi

# SSH - Not XDG-compliant
link "$DOTFILES/ssh/config" "$HOME/.ssh/config"

# Tmux - Load via source-file directive
if [ ! -f "$HOME/.tmux.conf" ]; then
  cat > "$HOME/.tmux.conf" << 'EOF'
source-file ~/.config/.tmux/main.conf
EOF
  printf "Created %s\n" "$HOME/.tmux.conf"
fi

# AWSume - Not XDG-compliant
link "$DOTFILES/awsume/config.yaml" "$HOME/.awsume/config.yaml"

# SSH permissions
chmod 700 "$HOME/.ssh"

# Git submodules
if [ -f "$DOTFILES/.gitmodules" ]; then
  git -C "$DOTFILES" submodule update --init --recursive
fi

printf "Dotfiles setup complete. XDG config: %s\n" "$HOME/.config"
