# Core settings loader
# 即座に読み込まれる必須設定

load_core_settings() {
  local config_dir="$1"

  # Core settings (immediate load - always needed)
  _load_zsh_files "$config_dir/core" "immediate"
}

# vim: set syntax=zsh:
