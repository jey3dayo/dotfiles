#!/usr/bin/env sh

set -eu

config_root="${XDG_CONFIG_HOME:-$HOME/.config}"

# RESTIC_PASSWORD は on-demand 層 (.env.secrets)、RESTIC_REPOSITORY は常時注入層 (.env)
exec dotenvx run -f "${config_root}/.env.secrets" -f "${config_root}/.env" -- "${config_root}/restic/backup.sh" "$@"
