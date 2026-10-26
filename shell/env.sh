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

_shell_is_raspberry_pi() (
  # shellcheck disable=SC3028
  # Use shell built-ins to avoid uname fork.
  if [ -n "${ZSH_VERSION:-}" ]; then
    arch="${CPUTYPE:-}"
  elif [ -n "${BASH_VERSION:-}" ]; then
    arch="${MACHTYPE%%-*}"
  else
    arch="$(uname -m 2>/dev/null || printf '')"
  fi

  # arm: 32-bit Pi bash MACHTYPE starts with 'arm-'.
  case "$arch" in
    aarch64 | arm64 | arm | armv7l | armv6l) ;;
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
    __mise_environment="ci"
  elif _shell_is_raspberry_pi; then
    __mise_environment="pi"
  else
    __mise_environment="default"
  fi
}

_shell_mise_env_append() {
  token="$1"
  case ",${MISE_ENV:-}," in
    *,"$token",*) ;;
    *) MISE_ENV="${MISE_ENV:+$MISE_ENV,}$token" ;;
  esac
  export MISE_ENV
  unset token
}

# Drop tokens this repo manages so MISE_ENV is rebuilt in canonical order (entry last);
# user-defined tokens are kept in front.
_shell_mise_env_reset() {
  __kept=""
  __old_ifs=$IFS
  IFS=,
  for __t in ${MISE_ENV:-}; do
    case "$__t" in
      "" | macos | bun | shared | workstation | workstation-unix | workstation-windows | server-pi | ci) ;;
      *) __kept="${__kept:+$__kept,}$__t" ;;
    esac
  done
  IFS=$__old_ifs
  MISE_ENV=$__kept
  unset __kept __old_ifs __t
}

_shell_bootstrap_mise_env() {
  : "${MISE_DATA_DIR:=$HOME/.mise}"
  : "${MISE_CACHE_DIR:=$MISE_DATA_DIR/cache}"
  export MISE_DATA_DIR MISE_CACHE_DIR
  # Legacy single-file selectors replace standard global discovery; drop inherited values.
  unset MISE_CONFIG_FILE MISE_GLOBAL_CONFIG_FILE
  _shell_mise_env_reset

  _shell_detect_mise_environment
  environment="$__mise_environment"
  unset __mise_environment

  # Build MISE_ENV: entry goes last so entry-specific settings win.
  # Uses standard global config discovery (~/.config/mise/config.<env>.toml)
  # CI: bun,ci
  # Pi: shared,server-pi
  # macOS: macos,bun,shared,workstation,workstation-unix
  # Linux/WSL: bun,shared,workstation,workstation-unix
  # Windows: bun,shared,workstation,workstation-windows
  case "$environment" in
    ci)
      _shell_mise_env_append bun
      _shell_mise_env_append ci
      ;;
    pi)
      _shell_mise_env_append shared
      _shell_mise_env_append server-pi
      ;;
    default)
      # shellcheck disable=SC3028
      case "${OSTYPE:-}" in
        darwin*)
          _shell_mise_env_append macos
          _shell_mise_env_append bun
          ;;
        "")
          if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
            _shell_mise_env_append macos
          fi
          _shell_mise_env_append bun
          ;;
        *)
          _shell_mise_env_append bun
          ;;
      esac
      _shell_mise_env_append shared
      _shell_mise_env_append workstation
      _shell_mise_env_append workstation-unix
      ;;
    windows)
      _shell_mise_env_append bun
      _shell_mise_env_append shared
      _shell_mise_env_append workstation
      _shell_mise_env_append workstation-windows
      ;;
  esac

  unset environment
}

_shell_bootstrap_tool_env() {
  : "${GHQ_ROOT:=$HOME/src}"
  : "${RIPGREP_CONFIG_PATH:=$XDG_CONFIG_HOME/.ripgreprc}"
  : "${BUN_INSTALL:=$HOME/.bun}"
  : "${PNPM_HOME:=$HOME/.local/share/pnpm}"
  : "${NI_CONFIG_FILE:=$HOME/.config/nirc}"
  # npm は XDG 非ネイティブのため userconfig を明示（~/.npmrc shim 廃止）
  : "${NPM_CONFIG_USERCONFIG:=$XDG_CONFIG_HOME/npm/npmrc}"
  # agmsg は既定でメッセージ DB を skill ディレクトリ内（<skill>/db）に置くため、
  # APM 再配布や plugin 更新が deploy 先を書き換えると履歴が消える。
  # teams/ には同等の override が無い（upstream fujibee/agmsg#285 が未実装）。
  : "${AGMSG_STORAGE_PATH:=${XDG_STATE_HOME:-$HOME/.local/state}/agmsg/db}"
  export GHQ_ROOT RIPGREP_CONFIG_PATH BUN_INSTALL PNPM_HOME NI_CONFIG_FILE NPM_CONFIG_USERCONFIG
  export AGMSG_STORAGE_PATH
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
