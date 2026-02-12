# OS-specific settings loader
# プラットフォーム固有の設定

load_os_settings() {
  local config_dir="$1"

  # OS-specific settings (deferred load if possible)
  case "$OSTYPE" in
    darwin*)
      [[ -r "$config_dir/os/macos.zsh" ]] && _defer_or_source "$config_dir/os/macos.zsh"
      ;;
    linux*)
      [[ -r "$config_dir/os/linux.zsh" ]] && _defer_or_source "$config_dir/os/linux.zsh"
      ;;
    cygwin* | msys*)
      [[ -r "$config_dir/os/windows.zsh" ]] && _defer_or_source "$config_dir/os/windows.zsh"
      ;;
  esac
}

# vim: set syntax=zsh:
