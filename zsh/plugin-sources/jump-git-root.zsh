function u() {
  cd ./"$(git rev-parse --show-cdup)"
  if [ $# = 1 ]; then
    cd "$1"
  fi
}
_u() {
  _values $(fd --type d --base-directory $(git rev-parse --show-cdup))
}
compdef _u u
