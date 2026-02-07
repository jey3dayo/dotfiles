# ~/.zshrc - Entry point for interactive Zsh shells
# Main configuration is in ~/.config/zsh/.zshrc

# Source main Zsh configuration
if [[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/.zshrc" ]]; then
  source "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/.zshrc"
fi
