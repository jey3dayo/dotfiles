#!/usr/bin/env bash
# launchd 直下（ppid==1）に取り残された dev サーバーを検出する（read-only、kill しない）。
# 終了コード: 0=検出なし（または darwin 以外でスキップ）、1=検出あり、2=実行エラー。
#
# 使い方: orphan-dev-servers.sh [--notify] [--help]
# テスト用: ORPHAN_PS_INPUT=<file> で ps の代わりに読む、ORPHAN_UNAME=<値> で OS 判定を差し替える。
set -euo pipefail

readonly TOKENS=("mise run" vite workerd pnpm)

usage() {
  sed -n '2,6p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

notify=0
for arg in "$@"; do
  case "$arg" in
    --notify) notify=1 ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "unknown option: $arg" >&2
      usage >&2
      exit 2
      ;;
  esac
done

# `uname -s` は外部コマンドの起動になるため、bash 組み込みの OSTYPE で判定する。
case "${ORPHAN_UNAME:-$OSTYPE}" in
  [Dd]arwin*) ;;
  *)
    echo "skip: darwin 以外では実行しません"
    exit 0
    ;;
esac

if [[ -n "${ORPHAN_PS_INPUT:-}" ]]; then
  if ! ps_output=$(<"$ORPHAN_PS_INPUT"); then
    echo "ORPHAN_PS_INPUT を読めません: $ORPHAN_PS_INPUT" >&2
    exit 2
  fi
elif ! ps_output=$(ps -axo pid=,ppid=,uid=,etime=,command=); then
  echo "ps の実行に失敗しました" >&2
  exit 2
fi

token_pattern=""
for token in "${TOKENS[@]}"; do
  token_pattern+="${token_pattern:+|}${token}"
done
match_regex="(^|[^[:alnum:]_])(${token_pattern})([^[:alnum:]_]|$)"

count=0
while read -r pid ppid uid etime command; do
  [[ -n "$command" && "$pid" != "$$" ]] || continue
  [[ "$ppid" == 1 && "$uid" == "$UID" ]] || continue
  [[ "$command" =~ $match_regex ]] || continue
  printf '%s\t%s\t%s\n' "$pid" "$etime" "$command"
  count=$((count + 1))
done <<<"$ps_output"

if ((count == 0)); then
  echo "孤児なし"
  exit 0
fi

if ((notify)); then
  if ! osascript -e "display notification \"孤児 dev サーバー: ${count} 件\" with title \"audit:orphans\""; then
    echo "通知に失敗しました（検出結果は変わりません）" >&2
  fi
fi
exit 1
