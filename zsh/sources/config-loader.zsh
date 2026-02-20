# Config loader - プラグイン管理ツール非依存
# この設定により、任意のzshプラグイン管理ツールで利用可能

load_config_loader() {
  local config_loader="${ZDOTDIR:-$HOME/.config/zsh}/config/loader.zsh"
  if [[ -r "$config_loader" ]]; then
    source "$config_loader"
  fi
}

load_config_loader

# vim: set syntax=zsh:
