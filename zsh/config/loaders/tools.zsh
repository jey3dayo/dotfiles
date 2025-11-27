# Tool settings loader
# 開発ツール関連の設定

load_tool_settings() {
  local config_dir="$1"

  # Critical tools - immediate load (minimal set)
  for critical_tool in fzf git mise starship; do
    [[ -f "$config_dir/tools/$critical_tool.zsh" ]] &&
      source "$config_dir/tools/$critical_tool.zsh"
  done

  # Non-critical tools - ultra-deferred load with optimized timing
  for tool_file in "$config_dir/tools"/*.zsh; do
    local tool_name=$(basename "$tool_file" .zsh)
    # Skip already loaded critical tools
    [[ "$tool_name" == "fzf" || "$tool_name" == "git" || "$tool_name" == "mise" ]] && continue

    if (($ + functions[zsh - defer])); then
      # Optimized staggered loading for minimal startup impact
      case "$tool_name" in
      brew) zsh-defer -t 3 source "$tool_file" ;;   # Load after mise for proper priority
      debug) zsh-defer -t 15 source "$tool_file" ;; # Debug tools rarely needed at startup
      gh) zsh-defer -t 8 source "$tool_file" ;;     # GitHub tools - moderate priority
      *) zsh-defer -t 12 source "$tool_file" ;;     # Everything else - low priority
      esac
    else
      source "$tool_file"
    fi
  done
}

# vim: set syntax=zsh:
