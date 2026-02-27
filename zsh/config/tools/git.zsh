# Git configuration loader
# 読み込み順序が重要: core → widgets → menu → worktree
# core.zsh のヘルパー関数に他ファイルが依存するため、glob順ではなく明示的にsource
local git_config_dir="${0:A:h}/git"
source "$git_config_dir/core.zsh"
source "$git_config_dir/widgets.zsh"
source "$git_config_dir/menu.zsh"
source "$git_config_dir/worktree.zsh"

# vim: set syntax=zsh:
