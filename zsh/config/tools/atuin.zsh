# atuin shell history initialization
# Loaded via zsh-defer by config/loaders/tools.zsh as a non-critical tool.
# Ordering note: fzf (critical) binds ^R first; atuin re-binds ^R here so
# atuin wins. Up arrow is intentionally NOT bound (--disable-up-arrow).

command -v atuin > /dev/null 2>&1 && eval "$(atuin init zsh --disable-up-arrow)"
