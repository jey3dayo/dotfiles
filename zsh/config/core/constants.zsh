# Shared constants for zsh configuration

if [[ -n "${ZSH_CONSTANTS_LOADED:-}" ]]; then
  return
fi
typeset -gr ZSH_CONSTANTS_LOADED=1

# FZF defaults
typeset -gr ZSH_FZF_TMUX_HEIGHT_DEFAULT="40%"
typeset -gr ZSH_FZF_PICKER_HEIGHT="40%"
typeset -gr ZSH_FZF_PREVIEW_LINE_RANGE=80
typeset -gr ZSH_FZF_DEFAULT_HEIGHT="50%"
typeset -gr ZSH_FZF_KILL_HEIGHT="40%"
typeset -gr ZSH_FZF_CTRL_R_PREVIEW_LINES=3
typeset -gr ZSH_FZF_KILL_SIGNAL=9

# Git + FZF helpers
typeset -gr ZSH_GIT_FZF_HEIGHT="40%"
typeset -gr ZSH_GIT_FZF_FALLBACK_LIMIT=1

# Completion cache policy
typeset -gr ZSH_COMPDUMP_MAX_AGE_DAYS=7
typeset -gr ZSH_COMPDUMP_REBUILD_AGE_HOURS=24

# Deferred load timing (seconds)
typeset -gr DEFER_BREW_SECONDS=3
typeset -gr DEFER_DEBUG_SECONDS=15
typeset -gr DEFER_GH_SECONDS=8
typeset -gr DEFER_DEFAULT_SECONDS=12
typeset -gr MISE_COMPLETION_DEFER_SECONDS=10
typeset -gr BREW_ENV_DEFER_SECONDS=3

# Debug tooling
typeset -gr ZSH_DEBUG_BENCHMARK_RUNS=5
typeset -gr ZSH_DEBUG_PROFILE_TOP_COUNT=20

# vim: set syntax=zsh:
