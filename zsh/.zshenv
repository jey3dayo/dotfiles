if [[ -n "${ZSH_PROFILE_STARTUP:-}" ]]; then
  zmodload zsh/zprof 2>/dev/null || true
fi

# Debian/Ubuntu global zshrc may run compinit before this repo's zshrc.
# Keep completion initialization in zsh/lib/completion.zsh so CI/no-TTY
# startup can use the repo-managed compinit flags.
skip_global_compinit=1

if [[ -r "${XDG_CONFIG_HOME:-$HOME/.config}/shell/env.sh" ]]; then
  source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/env.sh"
  _shell_bootstrap_env
else
  : "${XDG_CONFIG_HOME:=$HOME/.config}"
  : "${XDG_CACHE_HOME:=$HOME/.cache}"
  : "${XDG_DATA_HOME:=$HOME/.local/share}"
  : "${XDG_STATE_HOME:=$HOME/.local/state}"
  : "${ZDOTDIR:=${XDG_CONFIG_HOME}/zsh}"
  : "${GIT_CONFIG_GLOBAL:=$XDG_CONFIG_HOME/git/config}"
  : "${MISE_DATA_DIR:=$HOME/.mise}"
  : "${MISE_CACHE_DIR:=$MISE_DATA_DIR/cache}"
  : "${MISE_CONFIG_FILE:=${XDG_CONFIG_HOME}/mise/config.default.toml}"
  export XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME XDG_STATE_HOME
  export ZDOTDIR GIT_CONFIG_GLOBAL MISE_DATA_DIR MISE_CACHE_DIR MISE_CONFIG_FILE
fi

if (( $+functions[_shell_path_prepend_existing] )); then
  _shell_path_prepend_existing "${MISE_DATA_DIR:-$HOME/.mise}/shims" "$HOME/.local/bin" /opt/homebrew/bin
else
  case ":$PATH:" in
    *":${MISE_DATA_DIR:-$HOME/.mise}/shims:"*) ;;
    *) export PATH="${MISE_DATA_DIR:-$HOME/.mise}/shims${PATH:+:$PATH}" ;;
  esac
fi

: "${HISTFILE:=${XDG_STATE_HOME}/zsh/history}"
HISTSIZE=100000
SAVEHIST=100000
export HISTFILE HISTSIZE SAVEHIST

: "${TMPDIR:=/tmp/${LOGNAME:-$USER}}"
if [[ ! -d "$TMPDIR" ]]; then
  mkdir -p "$TMPDIR"
  chmod 700 "$TMPDIR"
fi
TMPPREFIX="${TMPDIR%/}/zsh"

if [[ -f "${XDG_CONFIG_HOME}/.env.local" ]]; then
  source "${XDG_CONFIG_HOME}/.env.local"
fi

unfunction _shell_bootstrap_env _shell_bootstrap_xdg_env _shell_bootstrap_mise_env \
  _shell_bootstrap_tool_env _shell_detect_mise_environment \
  _shell_is_raspberry_pi _shell_path_prepend_existing 2>/dev/null

# vim: set syntax=zsh:
