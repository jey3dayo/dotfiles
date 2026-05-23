# Canonical PATH setup for interactive shells.
#
# This helper is idempotent and safe to call more than once during interactive
# startup: first before Sheldon/plugin bootstrap so Homebrew-managed bootstrap
# tools are visible, and again before `mise activate` so mise hook-env can put
# managed tool paths in their final positions.
_dotfiles_setup_interactive_path() {
  emulate -L zsh
  typeset -gaU path
  local -a base_paths existing_paths fallback_paths
  local dir

  path=(${path:#${BUN_INSTALL:-$HOME/.bun}/bin})

  base_paths=(
    "${MISE_DATA_DIR:-$HOME/.mise}/shims"

    # User binaries
    "$HOME/bin"
    "$HOME/sbin"
    "$HOME/.local/bin"
    "$HOME/.local/sbin"
    "$XDG_CONFIG_HOME/scripts"
    "$HOME/.claude/bin"
    "$HOME/.claude/local"

    # Language-specific tools
    "$HOME/.deno/bin"
    "$HOME/.cargo/bin"
    "/usr/local/opt/openjdk/bin"
    "/usr/local/opt/coreutils/libexec/gnubin"
    "$HOME/go/bin"
    # pnpm global: mise で管理するため無効化
    # $PNPM_HOME(N-)
    # $HOME/.local/npm-global/bin(N-)

    # Android SDK
    "${ANDROID_SDK_ROOT:-}/emulator"
    "${ANDROID_SDK_ROOT:-}/tools"
    "${ANDROID_SDK_ROOT:-}/tools/bin"
    "${ANDROID_SDK_ROOT:-}/platform-tools"

    # Homebrew (before system for latest tools)
    "/opt/homebrew/bin"
    "/usr/local/bin"
  )

  path=(${path:#/opt/homebrew/sbin})
  path=(${path:#/usr/local/sbin})

  for dir in "${base_paths[@]}"; do
    [[ -n "$dir" && -d "$dir" ]] && existing_paths+=("$dir")
  done

  for dir in /opt/homebrew/sbin /usr/local/sbin; do
    [[ -d "$dir" ]] && fallback_paths+=("$dir")
  done

  path=("${existing_paths[@]}" $path "${fallback_paths[@]}")
}
