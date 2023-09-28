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
