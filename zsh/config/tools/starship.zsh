# Starship prompt initialization
# This file is loaded via zsh-defer by loaders/tools.zsh
# so we initialize immediately within this already-deferred context

command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"
