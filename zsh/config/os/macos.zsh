# macOS specific configuration

if [[ "$OSTYPE" == darwin* ]]; then
  # macOS specific aliases and settings
  alias chrome="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"
  alias flusdns="dscacheutil -flushcache;sudo killall -HUP mDNSResponder"

  # macOS specific PATH additions
  if [[ -d "/opt/homebrew" ]]; then
    export HOMEBREW_PREFIX="/opt/homebrew"
  elif [[ -d "/usr/local/Homebrew" ]]; then
    export HOMEBREW_PREFIX="/usr/local"
  fi

  # Claude Code CLI
  if [[ -d "$HOME/.claude/local" ]]; then
    path=("$HOME/.claude/local" $path)
  fi
fi
