#!/usr/bin/env bash
# Environment detection script for mise configuration
# Automatically selects the appropriate mise config based on the environment

DOTFILES_ROOT="${DOTFILES_ROOT:-${HOME}/src/github.com/jey3dayo/dotfiles}"

detect_environment() {
  # WSL2 detection
  # Check both WSL_DISTRO_NAME environment variable and /proc/version
  if [ -n "$WSL_DISTRO_NAME" ] || grep -qE "(microsoft|WSL)" /proc/version 2>/dev/null; then
    echo "wsl2"
    return
  fi

  # Raspberry Pi detection
  # Check device tree model for Raspberry Pi identifier
  if [ -f /sys/firmware/devicetree/base/model ]; then
    if grep -q "Raspberry Pi" /sys/firmware/devicetree/base/model 2>/dev/null; then
      echo "pi"
      return
    fi
  fi

  # macOS detection
  if [ "$(uname -s)" = "Darwin" ]; then
    echo "macos"
    return
  fi

  # Default for other Linux distributions
  echo "default"
}

setup_mise_config() {
  local env_type
  env_type=$(detect_environment)

  case "$env_type" in
    pi)
      export MISE_CONFIG_FILE="${DOTFILES_ROOT}/mise/config.pi.toml"
      ;;
    *)
      # Default for macOS, WSL2, and other Linux distributions
      export MISE_CONFIG_FILE="${DOTFILES_ROOT}/mise/config.toml"
      ;;
  esac

  # Debug output (uncomment if needed)
  # echo "Environment: $env_type, Config: $MISE_CONFIG_FILE" >&2
}

# Execute setup
setup_mise_config
