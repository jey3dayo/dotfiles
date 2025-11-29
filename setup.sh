#!/bin/sh
set -eu

DOTFILES=${DOTFILES:-"$(cd "$(dirname "$0")" && pwd)"}
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME/.config"}

if [ ! -d "$DOTFILES" ]; then
    echo "Dotfiles directory not found: $DOTFILES" >&2
    exit 1
fi

mkdir -p "$HOME/tmp" "$HOME/.cache" "$HOME/.local/share/zsh-autocomplete" "$HOME/.mise"

# Keep existing config safe unless it's already a symlink we can replace
if [ -d "$XDG_CONFIG_HOME" ] && [ ! -L "$XDG_CONFIG_HOME" ]; then
    if find "$XDG_CONFIG_HOME" -mindepth 1 -maxdepth 1 | read -r _; then
        echo "$XDG_CONFIG_HOME exists and is not empty. Back it up or remove it before re-running setup." >&2
        exit 1
    fi
    rmdir "$XDG_CONFIG_HOME"
fi

ln -sfn "$DOTFILES" "$XDG_CONFIG_HOME"

# Git configuration
mkdir -p "${XDG_CONFIG_HOME}/git"
ln -sfn "${DOTFILES}/git/config" "${XDG_CONFIG_HOME}/git/config"

link_home() {
    src=$1
    dest=$2

    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        echo "Skipping $dest because it already exists and is not a symlink." >&2
        return
    fi

    ln -sfn "$src" "$dest"
}

link_home "${XDG_CONFIG_HOME}/.tmux/main.conf" "$HOME/.tmux.conf"
link_home "${XDG_CONFIG_HOME}/zsh/.zshenv" "$HOME/.zshenv"

if [ -f "${DOTFILES}/nvim/init.vim" ]; then
    link_home "${XDG_CONFIG_HOME}/nvim/init.vim" "$HOME/.vimrc"
fi

(cd "$DOTFILES" && git submodule update --init --recursive)
