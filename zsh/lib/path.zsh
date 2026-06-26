dotfiles_zsh_setup_path() {
  emulate -L zsh
  typeset -gaU path

  local -a front_paths existing_front_paths back_paths existing_back_paths other_paths
  local dir

  path=(${path:#${BUN_INSTALL:-$HOME/.bun}/bin})

  front_paths=(
    "${MISE_DATA_DIR:-$HOME/.mise}/shims"
    "$HOME/bin"
    "$HOME/sbin"
    "$HOME/.local/bin"
    "$HOME/.local/sbin"
    "${XDG_CONFIG_HOME:-$HOME/.config}/scripts"
    "${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}/bin"
    "$HOME/.claude/bin"
    "$HOME/.claude/local"
    "$HOME/.deno/bin"
    "$HOME/.cargo/bin"
    "$HOME/go/bin"
    "${ANDROID_SDK_ROOT:-}/emulator"
    "${ANDROID_SDK_ROOT:-}/tools"
    "${ANDROID_SDK_ROOT:-}/tools/bin"
    "${ANDROID_SDK_ROOT:-}/platform-tools"
    /opt/homebrew/bin
    /usr/local/bin
  )

  back_paths=(/opt/homebrew/sbin /usr/local/sbin)

  for dir in "${front_paths[@]}"; do
    [[ -n "$dir" && -d "$dir" ]] || continue
    path=(${path:#$dir})
    existing_front_paths+=("$dir")
  done

  for dir in "${back_paths[@]}"; do
    [[ -n "$dir" && -d "$dir" ]] || continue
    path=(${path:#$dir})
    existing_back_paths+=("$dir")
  done

  other_paths=("${path[@]}")
  path=("${existing_front_paths[@]}" "${other_paths[@]}" "${existing_back_paths[@]}")
}

# vim: set syntax=zsh:
