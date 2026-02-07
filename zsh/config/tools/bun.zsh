# Bun JavaScript runtime and toolkit
# https://bun.sh

# Set Bun installation directory
export BUN_INSTALL="${BUN_INSTALL:-$HOME/.bun}"

# Add Bun to PATH (if installed)
if [[ -d "$BUN_INSTALL/bin" ]]; then
  path=("$BUN_INSTALL/bin" $path)
fi
