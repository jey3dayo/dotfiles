# 1Password CLI configuration (cross-platform: macOS and WSL2)

# Detect platform and set appropriate CLI path
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS: Use Homebrew-installed op CLI
  if command -v op &> /dev/null; then
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
  windows_user="${USER}"
  if [[ -d "/mnt/c/Users" ]]; then
    # If the WSL user doesn't exist in Windows, try to find the first user directory
    if [[ ! -d "/mnt/c/Users/${windows_user}" ]]; then
      windows_user=$(ls -1 /mnt/c/Users | grep -v -E '^(Public|Default|All Users|Default User)$' | head -1)
    fi
  fi
  # Only set OP_CLI_PATH if we found a valid Windows username
  if [[ -n "$windows_user" ]]; then
    OP_CLI_PATH="/mnt/c/Users/${windows_user}/AppData/Local/Microsoft/WinGet/Packages/AgileBits.1Password.CLI_Microsoft.Winget.Source_8wekyb3d8bbwe/op.exe"
  fi
fi

# Function wrapper for op command (more reliable than alias)
if [[ -n "$OP_CLI_PATH" ]] && [[ -x "$OP_CLI_PATH" ]]; then
  op() {
    "$OP_CLI_PATH" "$@"
  }
else
  # If op is in PATH, use it directly
  if command -v op &> /dev/null; then
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
export OP_DOTENV_KEYS_ITEM_ID='mzy4lhfwqbtbtr3rm466qhrouq'
export OP_DOTENV_KEYS_VAULT="${OP_DOTENV_KEYS_VAULT:-Dotfiles Automation}"
export DOTENV_KEYS_PATH="${XDG_CONFIG_HOME:-$HOME/.config}/.env.keys"
export OP_SERVICE_ACCOUNT_TOKEN_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/op/service-account-token"

if [[ -z "${OP_SERVICE_ACCOUNT_TOKEN:-}" ]] && [[ -f "$OP_SERVICE_ACCOUNT_TOKEN_FILE" ]]; then
  export OP_SERVICE_ACCOUNT_TOKEN="$(<"$OP_SERVICE_ACCOUNT_TOKEN_FILE")"
fi

# Helper function to restore .env.keys from 1Password
# Usage: restore-env-keys [item_id] [output_path]
restore-env-keys() {
  local item_id="${1:-$OP_DOTENV_KEYS_ITEM_ID}"
  local output_path="${2:-$DOTENV_KEYS_PATH}"
  local temp_path="${output_path}.tmp"
  local account_args=()

  # Check if 1Password CLI is available
  if [[ -z "$OP_CLI_PATH" ]] || [[ ! -x "$OP_CLI_PATH" ]]; then
    echo "Error: 1Password CLI not found or not executable" >&2
    return 1
  fi

  if [[ -z "${OP_SERVICE_ACCOUNT_TOKEN:-}" && -n "${OP_ACCOUNT:-}" ]]; then
    account_args+=(--account="$OP_ACCOUNT")
  fi

  echo "Restoring .env.keys from 1Password..."
  # Use temp file to avoid truncating existing keys on failure
  if "$OP_CLI_PATH" document get "$item_id" "${account_args[@]}" --vault="$OP_DOTENV_KEYS_VAULT" > "$temp_path"; then
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
  local account_args=()

  # Check if 1Password CLI is available
  if [[ -z "$OP_CLI_PATH" ]] || [[ ! -x "$OP_CLI_PATH" ]]; then
    echo "Error: 1Password CLI not found or not executable" >&2
    return 1
  fi

  if [[ ! -f "$source_path" ]]; then
    echo "Error: $source_path not found" >&2
    return 1
  fi

  if [[ -z "${OP_SERVICE_ACCOUNT_TOKEN:-}" && -n "${OP_ACCOUNT:-}" ]]; then
    account_args+=(--account="$OP_ACCOUNT")
  fi

  echo "Updating .env.keys in 1Password..."
  if "$OP_CLI_PATH" document edit "$item_id" "$source_path" "${account_args[@]}" --vault="$OP_DOTENV_KEYS_VAULT"; then
    echo "✓ Updated .env.keys | dotfiles in 1Password"
  else
    echo "Error: Failed to update .env.keys in 1Password" >&2
    return 1
  fi
}

save-op-service-account-token() {
  local token_dir="${OP_SERVICE_ACCOUNT_TOKEN_FILE%/*}"

  if [[ -z "${OP_SERVICE_ACCOUNT_TOKEN:-}" ]]; then
    echo "Error: OP_SERVICE_ACCOUNT_TOKEN is not set in the current shell" >&2
    return 1
  fi

  mkdir -p "$token_dir"
  printf '%s' "$OP_SERVICE_ACCOUNT_TOKEN" > "$OP_SERVICE_ACCOUNT_TOKEN_FILE"
  chmod 600 "$OP_SERVICE_ACCOUNT_TOKEN_FILE" 2>/dev/null || true
  echo "✓ Saved OP_SERVICE_ACCOUNT_TOKEN to $OP_SERVICE_ACCOUNT_TOKEN_FILE"
}

clear-op-service-account-token() {
  rm -f "$OP_SERVICE_ACCOUNT_TOKEN_FILE"
  unset OP_SERVICE_ACCOUNT_TOKEN
  echo "✓ Cleared OP_SERVICE_ACCOUNT_TOKEN cache"
}

# vim: set syntax=zsh:
