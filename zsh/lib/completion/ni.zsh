ni_completion="${XDG_DATA_HOME:-$HOME/.local/share}/sheldon/repos/github.com/snowsman/ni-completion/.ni.zsh"
[[ -r "$ni_completion" ]] && () { source "$1" } "$ni_completion"
unset ni_completion

# vim: set syntax=zsh:
