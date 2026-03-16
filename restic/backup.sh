#!/usr/bin/env bash
set -euo pipefail

RESTIC_DIR="$(cd "$(dirname "$0")" && pwd)"
PATHS_FILE="${RESTIC_DIR}/paths.txt"
EXCLUDES_FILE="${RESTIC_DIR}/excludes.txt"
PROFILE="${PERMAN_PROFILE:-$HOME/.config/perman-aws-vault/aws-caad-admin-role}"

export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-ap-northeast-1}"

# restic 環境変数チェック（dotenvx or mise 経由で設定済みであること）
if [[ -z "${RESTIC_REPOSITORY:-}" || -z "${RESTIC_PASSWORD:-}" ]]; then
  echo "Error: RESTIC_REPOSITORY and RESTIC_PASSWORD must be set."
  echo "Run via: dotenvx run -f \"${XDG_CONFIG_HOME:-$HOME/.config}/.env\" -- restic/backup.sh"
  exit 1
fi

# perman-aws-vault で AWS 一時クレデンシャル取得
echo "Fetching AWS credentials via perman-aws-vault..."
AWS_CREDS=$(perman-aws-vault print -p "$PROFILE")
if [[ -z "$AWS_CREDS" ]]; then
  echo "Error: Failed to fetch AWS credentials from perman-aws-vault."
  exit 1
fi
eval "$(echo "$AWS_CREDS" | jq -r '
  "export AWS_ACCESS_KEY_ID=\(.AccessKeyId)",
  "export AWS_SECRET_ACCESS_KEY=\(.SecretAccessKey)",
  "export AWS_SESSION_TOKEN=\(.SessionToken)"
')"

COMMAND="${1:-backup}"

case "$COMMAND" in
  backup)
    echo "Starting backup..."
    # paths.txt 内の ~ を $HOME に展開
    EXPANDED_PATHS=$(mktemp)
    trap 'rm -f "$EXPANDED_PATHS"' EXIT
    sed "s|^~|$HOME|" "$PATHS_FILE" >"$EXPANDED_PATHS"

    restic backup \
      --host "$(hostname)" \
      --files-from "$EXPANDED_PATHS" \
      --exclude-file "$EXCLUDES_FILE" \
      --exclude-caches

    restic forget \
      --host "$(hostname)" \
      --group-by host \
      --keep-last 10 \
      --keep-daily 30 \
      --keep-weekly 12 \
      --keep-monthly 12
    echo "Backup completed: $(date)"
    ;;
  prune)
    echo "Pruning unreferenced data..."
    restic prune
    echo "Prune completed: $(date)"
    ;;
  check)
    echo "Checking repository integrity..."
    restic check --read-data-subset=10%
    echo "Check completed: $(date)"
    ;;
  init)
    restic init
    ;;
  snapshots)
    restic snapshots --host "$(hostname)"
    ;;
  stats)
    restic stats
    ;;
  restore)
    TARGET="${2:-./restore}"
    echo "Restoring latest snapshot to: $(realpath "$TARGET" 2>/dev/null || echo "$TARGET")"
    restic restore latest --host "$(hostname)" --target "$TARGET"
    ;;
  *)
    echo "Usage: backup.sh {backup|init|snapshots|stats|restore [target]|prune|check}"
    exit 1
    ;;
esac
