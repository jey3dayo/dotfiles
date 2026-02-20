# ========================================
# dotenvx - encrypted .env loader
# ========================================
# Load encrypted global .env at shell startup

_dotenvx_load_global_env() {
  local env_file="${XDG_CONFIG_HOME:-$HOME/.config}/.env"
  command -v dotenvx >/dev/null 2>&1 || return 0
  [[ -f "$env_file" ]] || return 0

  local vars
  vars=$(dotenvx get --format shell -f "$env_file" 2>/dev/null) || return 0
  eval "${vars}"
}

_dotenvx_load_global_env
unfunction _dotenvx_load_global_env 2>/dev/null

# vim: set syntax=zsh:
