# Tool settings loader
# 開発ツール関連の設定

load_tool_settings() {
  local config_dir="$1"
  local -a critical_tools=(fzf git mise starship)
  local -A is_critical
  local has_zsh_defer=$(( $+functions[zsh-defer] ))

  # Critical tools - immediate load (minimal set)
  for critical_tool in $critical_tools; do
    is_critical[$critical_tool]=1
    [[ -f "$config_dir/tools/$critical_tool.zsh" ]] && source "$config_dir/tools/$critical_tool.zsh"
  done

  # Non-critical tools - ultra-deferred load with optimized timing
  for tool_file in "$config_dir/tools"/*.zsh(N); do
    local tool_name="${tool_file:t:r}"
    # Skip already loaded critical tools
    (( is_critical[$tool_name] )) && continue

    if (( has_zsh_defer )); then
      # Optimized staggered loading for minimal startup impact
      case "$tool_name" in
      brew) zsh-defer -t $DEFER_BREW_SECONDS source "$tool_file" ;;   # Load after mise for proper priority
      debug) zsh-defer -t $DEFER_DEBUG_SECONDS source "$tool_file" ;; # Debug tools rarely needed at startup
      gh) zsh-defer -t $DEFER_GH_SECONDS source "$tool_file" ;;       # GitHub tools - moderate priority
      *) zsh-defer -t $DEFER_DEFAULT_SECONDS source "$tool_file" ;;   # Everything else - low priority
      esac
    else
      source "$tool_file"
    fi
  done
}

# vim: set syntax=zsh:
