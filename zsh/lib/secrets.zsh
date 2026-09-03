# on-demand secrets 注入ヘルパー
# 高リスクな secret は常時注入せず ~/.config/.env.secrets に隔離している。
# 必要なコマンドだけ `ws <cmd>` で実行時に注入する（例: ws oco, ws op vault list）
ws() {
  local config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
  DOTENV_PRIVATE_KEY_PATH="$config_home/.env.keys" \
    dotenvx run --quiet -f "$config_home/.env.secrets" -- "$@"
}
