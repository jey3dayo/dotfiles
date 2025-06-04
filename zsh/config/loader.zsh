# Configuration loader for new structure

# Get the directory where this script is located
local config_dir="${0:A:h}"

# Core settings (immediate load)
for file in "$config_dir"/core/*.zsh; do
  [[ -r "$file" ]] && source "$file"
done

# Tool settings (deferred load)
for file in "$config_dir"/tools/*.zsh; do
  [[ -r "$file" ]] && zsh-defer source "$file"
done

# Functions (deferred load)
local functions_dir="${config_dir:h}/functions"
for file in "$functions_dir"/*.zsh; do
  [[ -r "$file" ]] && zsh-defer source "$file"
done

# OS-specific settings (deferred load)
case "$OSTYPE" in
  darwin*) zsh-defer source "$config_dir/os/macos.zsh" 2>/dev/null ;;
  linux*)  zsh-defer source "$config_dir/os/linux.zsh" 2>/dev/null ;;
  cygwin*|msys*) zsh-defer source "$config_dir/os/windows.zsh" 2>/dev/null ;;
esac

# Load abbreviations
local abbr_file="${config_dir:h}/abbreviations"
[[ -r "$abbr_file" ]] && zsh-defer source "$abbr_file"