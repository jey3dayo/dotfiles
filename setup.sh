#!/bin/sh
USER=$(id -u)
DOTFILES=$HOME/src/github.com/jey3dayo/dotfiles

# XDG base directories
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
XDG_STATE_HOME=${XDG_STATE_HOME:-$HOME/.local/state}

mkdir -p "$HOME/tmp" "$XDG_CACHE_HOME" "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME"
mkdir -p "$HOME/.local/share/zsh-autocomplete" "$HOME/.mise" "$XDG_STATE_HOME/zsh"
chown -R "${USER}" "$HOME/tmp" "$XDG_CACHE_HOME"

link_config() {
    target=$1
    name=$2
    dest="$XDG_CONFIG_HOME/$name"

    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        printf "skip %s (exists and not a symlink)\n" "$dest"
        return
    fi

    ln -sfn "$target" "$dest"
}

append_once() {
    file=$1
    line=$2
    if [ ! -f "$file" ] || ! grep -qxF "$line" "$file"; then
        printf "%s\n" "$line" >>"$file"
    fi
}

for path in "$DOTFILES"/* "$DOTFILES"/.[!.]* "$DOTFILES"/..?*; do
    [ -e "$path" ] || continue
    base=${path##*/}
    case "$base" in
    . | .. | .git | .github | docs | spec | setup.sh | README.md | CLAUDE.md | TOOLS.md) continue ;;
    esac
    link_config "$path" "$base"
done

# Ensure git config path exists for GIT_CONFIG_GLOBAL
mkdir -p "${XDG_CONFIG_HOME}/git"

append_once "$HOME/.vimrc" "source ${XDG_CONFIG_HOME}/nvim/init.vim"
append_once "$HOME/.tmux.conf" "source-file ${XDG_CONFIG_HOME}/tmux/tmux.conf"

export ZDOTDIR="${XDG_CONFIG_HOME}/zsh"
append_once "$HOME/.zshenv" "source ${ZDOTDIR}/.zshenv"

git submodule foreach git pull
