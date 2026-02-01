#
# Executes commands at login post-zshrc.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Ensure custom completions are in fpath
# .zlogin runs after .zshrc/.zprofile, making it ideal for final fpath adjustments
user_completion_dir="${ZDOTDIR:-$HOME/.config/zsh}/completions"
if [[ -d "$user_completion_dir" ]]; then
  # Remove if already exists to avoid duplicates
  fpath=("${(@)fpath:#$user_completion_dir}")
  # Add to the front
  fpath=("$user_completion_dir" $fpath)

  # Force reload completion system to pick up new fpath
  unfunction _ssh_hosts 2>/dev/null
  autoload -Uz compinit
  compinit -d "${ZSH_COMPDUMP:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump}"
fi
unset user_completion_dir

# Execute code that does not affect the current session in the background.
{
  # Compile the completion dump to increase startup speed.
  # ZSH_COMPDUMP環境変数が設定されていればそれを使用、なければデフォルト
  zcompdump="${ZSH_COMPDUMP:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump}"
  if [[ -s "$zcompdump" && (! -s "${zcompdump}.zwc" || "$zcompdump" -nt "${zcompdump}.zwc") ]]; then
    zcompile "$zcompdump"
  fi
} &!

# Print a random, hopefully interesting, adage.
if (( $+commands[fortune] )); then
  if [[ -t 0 || -t 1 ]]; then
    fortune -s
    print
  fi
fi
