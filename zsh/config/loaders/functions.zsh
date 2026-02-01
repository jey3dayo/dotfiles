# Functions loader
# ユーティリティ関数の読み込み

load_functions() {
  local config_dir="$1"

  # Functions (deferred load if possible)
  local functions_dir="${config_dir:h}/functions"
  _load_zsh_files "$functions_dir" "defer"
}

# vim: set syntax=zsh:
