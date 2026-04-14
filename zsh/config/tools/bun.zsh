# Bun JavaScript runtime and toolkit
# https://bun.sh

# Keep the standalone Bun install location for compatibility, but do not let it
# override a Bun already selected by mise or another tool manager.
export BUN_INSTALL="${BUN_INSTALL:-$HOME/.bun}"

# Remove inherited standalone Bun first so mise-selected Bun can win.
typeset -gaU path
path=(${path:#$BUN_INSTALL/bin})

# Add standalone Bun to PATH only as a fallback.
if ! command -v bun >/dev/null 2>&1 && [[ -d "$BUN_INSTALL/bin" ]]; then
  path=("$BUN_INSTALL/bin" $path)
fi
