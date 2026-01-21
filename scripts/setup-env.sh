#!/bin/sh
set -e

CONFIG_ROOT="${XDG_CONFIG_HOME:-$HOME/.config}"
ENV_FILE="$CONFIG_ROOT/.env"
ENV_KEYS="$CONFIG_ROOT/.env.keys"
ENV_LOCAL="$CONFIG_ROOT/.env.local"

# Check if .env exists
if [ ! -f "$ENV_FILE" ]; then
  echo "" >&2
  echo "❌ CRITICAL: $ENV_FILE not found" >&2
  echo "" >&2
  exit 1
fi

# Check if .env.keys exists
if [ ! -f "$ENV_KEYS" ]; then
  echo "" >&2
  echo "❌ CRITICAL: $ENV_KEYS not found" >&2
  echo "" >&2
  echo "Restore from 1Password:" >&2
  echo "  op document get \"dotfiles-env-keys\" --vault \"Private\" --output \"$ENV_KEYS\"" >&2
  echo "  chmod 600 \"$ENV_KEYS\"" >&2
  echo "" >&2
  exit 1
fi

# Check if dotenvx is available
if ! command -v dotenvx >/dev/null 2>&1; then
  echo "" >&2
  echo "❌ CRITICAL: dotenvx not found" >&2
  echo "" >&2
  echo "Install with: mise install" >&2
  echo "" >&2
  exit 1
fi

# Update check: decrypt only if .env is newer than .env.local
if [ -f "$ENV_LOCAL" ]; then
  if [ "$ENV_FILE" -nt "$ENV_LOCAL" ]; then
    echo "Updating .env.local (detected changes in .env)..."
  else
    # .env.local is up-to-date
    exit 0
  fi
else
  echo "Generating .env.local for the first time..."
fi

# Decrypt .env to .env.local (use temp file for atomicity)
TEMP_FILE="$ENV_LOCAL.tmp"
if DOTENV_PRIVATE_KEY_PATH="$ENV_KEYS" dotenvx decrypt -f "$ENV_FILE" --stdout > "$TEMP_FILE" 2>/dev/null; then
  mv "$TEMP_FILE" "$ENV_LOCAL"
  chmod 600 "$ENV_LOCAL"
  echo "✓ .env.local updated successfully"
else
  rm -f "$TEMP_FILE"
  echo "" >&2
  echo "❌ CRITICAL: Failed to decrypt .env" >&2
  echo "" >&2
  echo "Check that .env.keys contains the correct private key." >&2
  echo "" >&2
  exit 1
fi
