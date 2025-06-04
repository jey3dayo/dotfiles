# Configuration loader
# Any zsh plugin manager can source this file

# Get the directory where this script is located
local config_dir="${0:A:h}"

# Load helper functions
source "$config_dir/loaders/helper.zsh"

# Load specific loaders
source "$config_dir/loaders/core.zsh"
source "$config_dir/loaders/tools.zsh"
source "$config_dir/loaders/functions.zsh"
source "$config_dir/loaders/os.zsh"

# Execute loading sequence
load_core_settings "$config_dir"
load_tool_settings "$config_dir"
load_functions "$config_dir"
load_os_settings "$config_dir"

# Clean up helper functions
unfunction _defer_or_source 2>/dev/null
unfunction _load_zsh_files 2>/dev/null
unfunction load_core_settings 2>/dev/null
unfunction load_tool_settings 2>/dev/null
unfunction load_functions 2>/dev/null
unfunction load_os_settings 2>/dev/null

# vim: set syntax=zsh:
