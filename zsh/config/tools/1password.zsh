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
    OP_CLI_PATH="$(command -v op)"
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
export OP_DOTENV_ENV_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/.env"

op-service-account() {
  dotenvx run -f "$OP_DOTENV_ENV_FILE" -- op "$@"
}

_op_filter_dotenvx_stdout() {
  local line

  while IFS= read -r line; do
    if [[ "$line" == "[dotenvx]"* ]] || [[ "$line" == "⟐"* ]]; then
      continue
    fi
    print -r -- "$line"
  done
}

# Helper function to restore .env.keys from 1Password
# Usage: restore-env-keys [item_id] [output_path]
restore-env-keys() {
  local item_id="${1:-$OP_DOTENV_KEYS_ITEM_ID}"
  local output_path="${2:-$DOTENV_KEYS_PATH}"
  local temp_path="${output_path}.tmp"
  local fallback_path="${temp_path}.dotenvx"
  local -a account_args=()

  # Check if 1Password CLI is available
  if [[ -z "$OP_CLI_PATH" ]] || [[ ! -x "$OP_CLI_PATH" ]]; then
    echo "Error: 1Password CLI not found or not executable" >&2
    return 1
  fi

  echo "Restoring .env.keys from 1Password..."
  # Use temp file to avoid truncating existing keys on failure
  if [[ -n "${OP_ACCOUNT:-}" ]] && [[ -z "${OP_SERVICE_ACCOUNT_TOKEN:-}" ]]; then
    account_args=(--account="$OP_ACCOUNT")
  fi

  if "$OP_CLI_PATH" document get "$item_id" "${account_args[@]}" --vault="$OP_DOTENV_KEYS_VAULT" > "$temp_path" \
    || {
    dotenvx run -f "$OP_DOTENV_ENV_FILE" -- "$OP_CLI_PATH" document get "$item_id" --vault="$OP_DOTENV_KEYS_VAULT" > "$fallback_path" \
      && _op_filter_dotenvx_stdout < "$fallback_path" > "$temp_path"
    }; then
    mv "$temp_path" "$output_path"
    chmod 600 "$output_path"
    rm -f "$fallback_path"
    echo "✓ Restored to $output_path with permissions 600"
  else
    echo "Error: Failed to restore .env.keys from 1Password" >&2
    rm -f "$temp_path" "$fallback_path"
    return 1
  fi
}

# Helper function to update .env.keys in 1Password
# Usage: update-env-keys [item_id] [source_path]
update-env-keys() {
  local item_id="${1:-$OP_DOTENV_KEYS_ITEM_ID}"
  local source_path="${2:-$DOTENV_KEYS_PATH}"
  local -a account_args=()

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
  if [[ -n "${OP_ACCOUNT:-}" ]] && [[ -z "${OP_SERVICE_ACCOUNT_TOKEN:-}" ]]; then
    account_args=(--account="$OP_ACCOUNT")
  fi

  if "$OP_CLI_PATH" document edit "$item_id" "$source_path" "${account_args[@]}" --vault="$OP_DOTENV_KEYS_VAULT" \
    || dotenvx run -f "$OP_DOTENV_ENV_FILE" -- "$OP_CLI_PATH" document edit "$item_id" "$source_path" --vault="$OP_DOTENV_KEYS_VAULT"; then
    echo "✓ Updated .env.keys | dotfiles in 1Password"
  else
    echo "Error: Failed to update .env.keys in 1Password" >&2
    return 1
  fi
}

save-op-service-account-token() {
  if [[ -z "${OP_SERVICE_ACCOUNT_TOKEN:-}" ]]; then
    echo "Error: OP_SERVICE_ACCOUNT_TOKEN is not set in the current shell" >&2
    return 1
  fi

  dotenvx set OP_SERVICE_ACCOUNT_TOKEN "$OP_SERVICE_ACCOUNT_TOKEN" \
    -f "$OP_DOTENV_ENV_FILE" \
    -fk "${OP_DOTENV_ENV_FILE}.keys" \
    --encrypt
  chmod 600 "$OP_DOTENV_ENV_FILE" "${OP_DOTENV_ENV_FILE}.keys" 2>/dev/null || true
  echo "✓ Saved OP_SERVICE_ACCOUNT_TOKEN to dotenvx env file"
}

clear-op-service-account-token() {
  unset OP_SERVICE_ACCOUNT_TOKEN
  echo "✓ Cleared OP_SERVICE_ACCOUNT_TOKEN from current shell"
  echo "Remove or rotate OP_SERVICE_ACCOUNT_TOKEN in $OP_DOTENV_ENV_FILE with dotenvx if needed."
}

# vim: set syntax=zsh:
