if [[ -r "${XDG_CONFIG_HOME:-$HOME/.config}/shell/env.sh" ]]; then
  source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/env.sh"
  _dotfiles_bootstrap_xdg_env
else
  : "${XDG_CONFIG_HOME:=$HOME/.config}"
  : "${XDG_CACHE_HOME:=$HOME/.cache}"
  : "${XDG_DATA_HOME:=$HOME/.local/share}"
  : "${XDG_STATE_HOME:=$HOME/.local/state}"
  export XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME XDG_STATE_HOME

  : "${ZDOTDIR:=${XDG_CONFIG_HOME}/zsh}"
  : "${GIT_CONFIG_GLOBAL:=$XDG_CONFIG_HOME/git/config}"
  export ZDOTDIR GIT_CONFIG_GLOBAL
fi

# ========================================
# mise Environment Configuration
# ========================================
# TIMING: Must be in .zshenv for every shell type.
# RELATED: config/tools/mise.zsh performs interactive activation from .zshrc.
# FALLBACK: Home Manager sets MISE_CONFIG_FILE; local fallback lives in config/tools/mise-env.zsh
# ========================================

# Keep .zshenv small: bootstrap logic is delegated to a dedicated file.
if [[ -f "${ZDOTDIR}/config/tools/mise-env.zsh" ]]; then
  source "${ZDOTDIR}/config/tools/mise-env.zsh"
  _mise_bootstrap_env
  unfunction _mise_bootstrap_env _dotfiles_bootstrap_shell_env _dotfiles_bootstrap_tool_env _dotfiles_bootstrap_mise_env _dotfiles_detect_mise_environment _dotfiles_is_raspberry_pi _dotfiles_source_home_manager_session_vars _dotfiles_bootstrap_xdg_env 2>/dev/null
else
  : "${MISE_DATA_DIR:=$HOME/.mise}"
  : "${MISE_CACHE_DIR:=$MISE_DATA_DIR/cache}"
  export MISE_DATA_DIR MISE_CACHE_DIR
  : "${MISE_CONFIG_FILE:=${XDG_CONFIG_HOME}/mise/config.default.toml}"
  export MISE_CONFIG_FILE
fi

# NOTE: interactive mise activation happens through config/tools/mise.zsh, which
# is loaded from .zshrc after login and non-login startup files have run.

# Non-interactive shells used by agents can skip .zprofile/.zshrc; keep mise
# shims ahead of Homebrew there too so project Node versions are honored.
case ":$PATH:" in
  *":${MISE_DATA_DIR:-$HOME/.mise}/shims:"*) ;;
  *) export PATH="${MISE_DATA_DIR:-$HOME/.mise}/shims${PATH:+:$PATH}" ;;
esac

# History file should be set before shell init so history loads
# even if .zshrc is skipped. Keep it under XDG state by default.
: "${HISTFILE:=${XDG_STATE_HOME}/zsh/history}"
export HISTFILE

# History size must be set in .zshenv (not .zshrc) because tools like Claude Code
# use 'zsh -c' which skips .zshrc, resulting in Zsh's defaults (HISTSIZE=30, SAVEHIST=0).
# .zshenv is always sourced, ensuring proper history configuration in all contexts.
HISTSIZE=100000
SAVEHIST=100000
export HISTSIZE SAVEHIST

# Temporary Files
if [[ ! -d "$TMPDIR" ]]; then
  export TMPDIR="/tmp/$LOGNAME"
  mkdir -p "$TMPDIR"
  chmod 700 "$TMPDIR"
fi

TMPPREFIX="${TMPDIR%/}/zsh"

if [[ -r "${XDG_CONFIG_HOME}/shell/env.sh" ]]; then
  source "${XDG_CONFIG_HOME}/shell/env.sh"
  _dotfiles_bootstrap_tool_env
  unfunction _dotfiles_bootstrap_shell_env _dotfiles_bootstrap_tool_env _dotfiles_bootstrap_mise_env _dotfiles_detect_mise_environment _dotfiles_is_raspberry_pi _dotfiles_source_home_manager_session_vars _dotfiles_bootstrap_xdg_env 2>/dev/null
else
  export GHQ_ROOT=~/src
  export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/.ripgreprc"
  export BUN_INSTALL="$HOME/.bun"
  export PNPM_HOME="$HOME/.local/share/pnpm"
  export NI_CONFIG_FILE="$HOME/.config/nirc"
fi

# Load decrypted environment variables for every shell type so remote commands
# like `ssh host 'gog ...'` can access required credentials without .zshrc.
if [[ -f "${XDG_CONFIG_HOME}/.env.local" ]]; then
  source "${XDG_CONFIG_HOME}/.env.local"
fi

# macOS-specific environment (early load for PATH setup in .zprofile)
if [[ "$OSTYPE" == darwin* ]]; then
  [[ -f "${ZDOTDIR}/config/os/macos-env.zsh" ]] && source "${ZDOTDIR}/config/os/macos-env.zsh"
fi

# Interactive PATH configuration is prepared by config/core/interactive-path.zsh
# and finalized by config/tools/mise.zsh.

fpath=(
  ~/.awsume/zsh-autocomplete/
  ~/.local/share/zsh-autocomplete/
"${fpath[@]}")

# vim: set syntax=zsh:
