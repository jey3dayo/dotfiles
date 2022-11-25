case ${OSTYPE} in
  darwin*)
  alias flushdns='dscacheutil -flushcache;sudo killall -HUP mDNSResponder'

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
