# Core aliases and environment setup
# Loaded immediately via config loader. Formerly duplicated in
# lazy-sources/alias.zsh but consolidated here.

case ${OSTYPE} in
  darwin*)
  # gnu
  alias sed="gsed"
  alias grep="ggrep"

  # fix ggrep
  unset GREP_OPTIONS
  ;;
esac

if command -v colordiff>/dev/null; then
  alias diff="colordiff"
fi
