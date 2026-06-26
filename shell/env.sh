# shellcheck shell=sh
# Shared shell environment bootstrap for Bash and Zsh entrypoints.

_shell_bootstrap_xdg_env() {
  : "${XDG_CONFIG_HOME:=$HOME/.config}"
  : "${XDG_CACHE_HOME:=$HOME/.cache}"
  : "${XDG_DATA_HOME:=$HOME/.local/share}"
  : "${XDG_STATE_HOME:=$HOME/.local/state}"
  export XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME XDG_STATE_HOME

  : "${ZDOTDIR:=${XDG_CONFIG_HOME}/zsh}"
  : "${GIT_CONFIG_GLOBAL:=$XDG_CONFIG_HOME/git/config}"
  export ZDOTDIR GIT_CONFIG_GLOBAL
}

_shell_source_hm_session_vars() {
  if [ -n "${HM_SESSION_VARS_LOADED:-}" ]; then
    return 0
  fi

  if [ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
    . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
    export HM_SESSION_VARS_LOADED=1
  elif [ -f "${XDG_CONFIG_HOME:-$HOME/.config}/home-manager/home-manager.sh" ]; then
    . "${XDG_CONFIG_HOME:-$HOME/.config}/home-manager/home-manager.sh"
    export HM_SESSION_VARS_LOADED=1
  fi
}

_shell_is_raspberry_pi() (
  arch="$(uname -m 2>/dev/null || printf '')"
  case "$arch" in
    aarch64 | armv7l | armv6l) ;;
    *) return 1 ;;
  esac

  model=""
  if [ -r /sys/firmware/devicetree/base/model ]; then
    model="$(tr -d '\000' </sys/firmware/devicetree/base/model 2>/dev/null)"
  fi
  case "$model" in
    *"Raspberry Pi"*) return 0 ;;
  esac

  cpuinfo=""
  if [ -r /proc/cpuinfo ]; then
    cpuinfo="$(sed -n '1,200p' /proc/cpuinfo 2>/dev/null)"
  fi
  case "$cpuinfo" in
    *"Raspberry Pi"* | *"BCM27"* | *"BCM283"*) return 0 ;;
    *) return 1 ;;
  esac
)

_shell_detect_mise_environment() {
  if [ -n "${CI:-}" ] || [ -n "${GITHUB_ACTIONS:-}" ]; then
    printf '%s\n' "ci"
  elif _shell_is_raspberry_pi; then
    printf '%s\n' "pi"
  else
    printf '%s\n' "default"
  fi
}

_shell_bootstrap_mise_env() {
  : "${MISE_DATA_DIR:=$HOME/.mise}"
  : "${MISE_CACHE_DIR:=$MISE_DATA_DIR/cache}"
  export MISE_DATA_DIR MISE_CACHE_DIR

  _shell_source_hm_session_vars

  case "${MISE_CONFIG_FILE:-}" in
    /tmp/hm-verify/*)
      unset MISE_CONFIG_FILE
      ;;
    "") ;;
    *)
      [ -f "$MISE_CONFIG_FILE" ] || unset MISE_CONFIG_FILE
      ;;
  esac

  if [ -z "${MISE_CONFIG_FILE:-}" ]; then
    environment="$(_shell_detect_mise_environment)"
    export MISE_CONFIG_FILE="${XDG_CONFIG_HOME}/mise/config.${environment}.toml"
    unset environment
  fi
}

_shell_bootstrap_tool_env() {
  : "${GHQ_ROOT:=$HOME/src}"
  : "${RIPGREP_CONFIG_PATH:=$XDG_CONFIG_HOME/.ripgreprc}"
  : "${BUN_INSTALL:=$HOME/.bun}"
  : "${PNPM_HOME:=$HOME/.local/share/pnpm}"
  : "${NI_CONFIG_FILE:=$HOME/.config/nirc}"
  export GHQ_ROOT RIPGREP_CONFIG_PATH BUN_INSTALL PNPM_HOME NI_CONFIG_FILE
}

_shell_path_prepend_existing() {
  path_prefix=""
  for path_dir; do
    [ -n "$path_dir" ] && [ -d "$path_dir" ] || continue
    case ":$PATH:" in
      *":$path_dir:"*) continue ;;
    esac
    case ":$path_prefix:" in
      *":$path_dir:"*) continue ;;
    esac
    path_prefix="${path_prefix}${path_prefix:+:}$path_dir"
  done

  if [ -n "$path_prefix" ]; then
    PATH="${path_prefix}${PATH:+:$PATH}"
    export PATH
  fi

  unset path_dir path_prefix
}

_shell_bootstrap_env() {
  _shell_bootstrap_xdg_env
  _shell_bootstrap_mise_env
  _shell_bootstrap_tool_env
}
