# Tool settings loader
# 開発ツール関連の設定

load_tool_settings() {
  local config_dir="$1"

  # Critical tools - immediate load (minimal set)
  for critical_tool in fzf git; do
    [[ -f "$config_dir/tools/$critical_tool.zsh" ]] &&
      source "$config_dir/tools/$critical_tool.zsh"
  done

  # Non-critical tools - ultra-deferred load with timeout
  for tool_file in "$config_dir/tools"/*.zsh; do
    local tool_name=$(basename "$tool_file" .zsh)
    # Skip already loaded critical tools
    [[ "$tool_name" == "fzf" || "$tool_name" == "git" ]] && continue

    if (( $+functions[zsh-defer] )); then
      # Stagger tool loading to reduce startup spike
      case "$tool_name" in
      mise | starship) zsh-defer -t 5 source "$tool_file" ;;
      brew) zsh-defer -t 8 source "$tool_file" ;;
      *) zsh-defer -t 10 source "$tool_file" ;;
      esac
    else
      source "$tool_file"
    fi
  done
}

# vim: set syntax=zsh:
