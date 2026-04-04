#!/usr/bin/env sh

set -eu

config_root="${XDG_CONFIG_HOME:-$HOME/.config}"

exec dotenvx run -f "${config_root}/.env" -- "${config_root}/restic/backup.sh" "$@"
