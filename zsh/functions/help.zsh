# Help functions for zsh configuration

zsh-help() {
  case "$1" in
    keybinds|keys)
      echo "Custom Keybindings:"
      echo "  ^]       - fzf ghq repository selector"
      echo "  ^g^g     - git diff widget"
      echo "  ^g^K     - fzf kill process widget"
      echo "  ^R       - fzf history search"
      echo "  ^T       - fzf file finder"
      ;;
    aliases)
      echo "Custom Aliases:"
      abbr -S | grep -E "^abbr" | sort
      ;;
    functions)
      echo "Custom Functions:"
      typeset -f | grep -E "^[a-zA-Z_-]+\s*\(\)" | sort
      ;;
    config)
      echo "Configuration Structure:"
      echo "  config/core/     - Core settings (immediate load)"
      echo "  config/tools/    - Tool-specific settings (deferred)"
      echo "  config/os/       - OS-specific settings"
      echo "  functions/       - Custom functions"
      echo "  abbreviations    - Command abbreviations"
      ;;
    *)
      echo "Usage: zsh-help [keybinds|aliases|functions|config]"
      echo ""
      echo "Available help topics:"
      echo "  keybinds  - Show custom key bindings"
      echo "  aliases   - Show command abbreviations"
      echo "  functions - Show custom functions"
      echo "  config    - Show configuration structure"
      ;;
  esac
}