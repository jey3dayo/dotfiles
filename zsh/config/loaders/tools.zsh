# Tool settings loader
# 開発ツール関連の設定

load_tool_settings() {
  local config_dir="$1"
  
  # Tool settings (deferred load if possible)
  _load_zsh_files "$config_dir/tools" "defer"
}

# vim: set syntax=zsh: 