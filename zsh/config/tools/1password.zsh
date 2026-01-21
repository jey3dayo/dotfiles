# 1Password CLI configuration (cross-platform: macOS and WSL2)

# Detect platform and set appropriate CLI path
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS: Use Homebrew-installed op CLI
  if command -v op &>/dev/null; then
    OP_CLI_PATH="$(command -v op)"
  else
    # Fallback to common macOS paths
    if [[ -x "/usr/local/bin/op" ]]; then
      OP_CLI_PATH="/usr/local/bin/op"
    elif [[ -x "/opt/homebrew/bin/op" ]]; then
      OP_CLI_PATH="/opt/homebrew/bin/op"
    fi
  fi
elif [[ "$(uname -r)" =~ "microsoft" ]] || [[ "$(uname -r)" =~ "WSL" ]]; then
  # WSL2: Use Windows version of 1Password CLI
  # Try to detect Windows username dynamically
  local windows_user="${USER}"
  if [[ -d "/mnt/c/Users" ]]; then
    # If the WSL user doesn't exist in Windows, try to find the first user directory
    if [[ ! -d "/mnt/c/Users/${windows_user}" ]]; then
      windows_user=$(ls -1 /mnt/c/Users | grep -v -E '^(Public|Default|All Users|Default User)$' | head -1)
    fi
  fi
  OP_CLI_PATH="/mnt/c/Users/${windows_user}/AppData/Local/Microsoft/WinGet/Packages/AgileBits.1Password.CLI_Microsoft.Winget.Source_8wekyb3d8bbwe/op.exe"
fi

# Function wrapper for op command (more reliable than alias)
if [[ -n "$OP_CLI_PATH" ]] && [[ -x "$OP_CLI_PATH" ]]; then
  op() {
    "$OP_CLI_PATH" "$@"
  }
else
  # If op is in PATH, use it directly
  if command -v op &>/dev/null; then
    # op is already in PATH, no wrapper needed
    :
  else
    echo "Warning: 1Password CLI not found. Please install it:" >&2
    echo "  macOS: brew install --cask 1password-cli" >&2
    echo "  WSL2:  winget install AgileBits.1Password.CLI" >&2
  fi
fi

# Default 1Password configuration
export OP_ACCOUNT='CNRNCJQSBBBYZESUWAMXLHQFBI'
export OP_DOTENV_KEYS_ITEM_ID='qz4xx3fngju6njadaughgn4e3e'
export DOTENV_KEYS_PATH="${XDG_CONFIG_HOME:-$HOME/.config}/.env.keys"

# Helper function to restore .env.keys from 1Password
# Usage: restore-env-keys [item_id] [output_path]
restore-env-keys() {
  local item_id="${1:-$OP_DOTENV_KEYS_ITEM_ID}"
  local output_path="${2:-$DOTENV_KEYS_PATH}"
  local temp_path="${output_path}.tmp"

  # Check if 1Password CLI is available
  if [[ -z "$OP_CLI_PATH" ]] || [[ ! -x "$OP_CLI_PATH" ]]; then
    echo "Error: 1Password CLI not found or not executable" >&2
    return 1
  fi

  echo "Restoring .env.keys from 1Password..."
  # Use temp file to avoid truncating existing keys on failure
  if "$OP_CLI_PATH" document get "$item_id" --account="$OP_ACCOUNT" > "$temp_path"; then
    mv "$temp_path" "$output_path"
    chmod 600 "$output_path"
    echo "✓ Restored to $output_path with permissions 600"
  else
    echo "Error: Failed to restore .env.keys from 1Password" >&2
    rm -f "$temp_path"
    return 1
  fi
}

# Helper function to update .env.keys in 1Password
# Usage: update-env-keys [item_id] [source_path]
update-env-keys() {
  local item_id="${1:-$OP_DOTENV_KEYS_ITEM_ID}"
  local source_path="${2:-$DOTENV_KEYS_PATH}"

  # Check if 1Password CLI is available
  if [[ -z "$OP_CLI_PATH" ]] || [[ ! -x "$OP_CLI_PATH" ]]; then
    echo "Error: 1Password CLI not found or not executable" >&2
    return 1
  fi

  if [[ ! -f "$source_path" ]]; then
    echo "Error: $source_path not found" >&2
    return 1
  fi

  echo "Updating .env.keys in 1Password..."
  if "$OP_CLI_PATH" document edit "$item_id" "$source_path" --account="$OP_ACCOUNT"; then
    echo "✓ Updated dotfiles-env-keys in 1Password"
  else
    echo "Error: Failed to update .env.keys in 1Password" >&2
    return 1
  fi
}

# vim: set syntax=zsh:
