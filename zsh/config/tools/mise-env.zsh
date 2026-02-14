# ========================================
# mise Environment Bootstrap for .zshenv
# ========================================
# PURPOSE:
# - Set early mise directories (before activation in .zprofile/.zshrc)
# - Load Home Manager session vars when available
# - Determine fallback MISE_CONFIG_FILE (CI > Raspberry Pi > default)
# ========================================

_mise_source_home_manager_session_vars() {
  local primary_session_vars="$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
  local fallback_session_vars="${XDG_CONFIG_HOME:-$HOME/.config}/home-manager/home-manager.sh"

  if [[ -f "$primary_session_vars" ]]; then
    source "$primary_session_vars"
  elif [[ -f "$fallback_session_vars" ]]; then
    source "$fallback_session_vars"
  fi
}

_mise_is_raspberry_pi() {
  local arch
  arch="$(uname -m)"
  case "$arch" in
    aarch64|armv7l|armv6l)
      ;;
    *)
      return 1
      ;;
  esac

  # /sys/firmware/devicetree/base/model may contain NUL bytes; strip them before matching.
  local model=""
  if [[ -r /sys/firmware/devicetree/base/model ]]; then
    model="$(tr -d '\000' </sys/firmware/devicetree/base/model 2>/dev/null)"
  fi

  if [[ "$model" == *"Raspberry Pi"* ]]; then
    return 0
  fi

  local cpuinfo=""
  if [[ -r /proc/cpuinfo ]]; then
    cpuinfo="$(</proc/cpuinfo)"
  fi

  [[ "$cpuinfo" == *"Raspberry Pi"* || "$cpuinfo" == *"BCM27"* || "$cpuinfo" == *"BCM283"* ]]
}

_mise_detect_environment() {
  if [[ -n "$CI" || -n "$GITHUB_ACTIONS" ]]; then
    print -r -- "ci"
  elif _mise_is_raspberry_pi; then
    print -r -- "pi"
  else
    print -r -- "default"
  fi
}

_mise_bootstrap_env() {
  : "${MISE_DATA_DIR:=$HOME/.mise}"
  : "${MISE_CACHE_DIR:=$MISE_DATA_DIR/cache}"
  export MISE_DATA_DIR MISE_CACHE_DIR

  _mise_source_home_manager_session_vars

  if [[ -z "$MISE_CONFIG_FILE" ]]; then
    local environment
    environment="$(_mise_detect_environment)"
    export MISE_CONFIG_FILE="${XDG_CONFIG_HOME}/mise/config.${environment}.toml"
  fi
}
