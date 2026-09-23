#!/usr/bin/env sh
# mise 本体は公式インストーラ管理で、`mise self-update` は mise/config.toml の
# minimum_release_age を適用しない（v2026.9.12 の src/cli/self_update.rs に
# minimum_release_age / published_at の参照が無い）。最も特権的な更新だけが
# リポジトリの供給チェーン方針を迂回しないよう、ここで待機を実装する。
#
# 判定後に latest が差し替わる TOCTOU を避けるため、self-update には exact
# version を渡す。API 失敗・日時 parse 失敗・未来日時は fail-closed で止める。
set -eu

min_age_seconds=86400
api_url="https://api.github.com/repos/jdx/mise/releases/latest"

# shim ではなく実体を使う。github.credential_command と同じ解決先。
gh_bin=$(mise which gh 2>/dev/null) || gh_bin=""
if [ -z "${gh_bin}" ] || [ ! -x "${gh_bin}" ]; then
  echo "❌ gh binary not resolved (mise which gh)" >&2
  exit 1
fi

release=$("${gh_bin}" api "${api_url}" --jq '[.tag_name, .published_at] | @tsv') || {
  echo "❌ failed to fetch the latest mise release from GitHub" >&2
  exit 1
}

tag=$(printf '%s\n' "${release}" | cut -f1)
published_at=$(printf '%s\n' "${release}" | cut -f2)
if [ -z "${tag}" ] || [ -z "${published_at}" ]; then
  echo "❌ latest release is missing tag_name or published_at" >&2
  exit 1
fi

# BSD date（macOS）と GNU date（Linux/WSL）のどちらでも ISO8601 を epoch にする。
published_epoch=$(date -j -u -f "%Y-%m-%dT%H:%M:%SZ" "${published_at}" "+%s" 2>/dev/null) \
  || published_epoch=$(date -u -d "${published_at}" "+%s" 2>/dev/null) \
  || {
    echo "❌ failed to parse published_at: ${published_at}" >&2
    exit 1
  }

now_epoch=$(date -u "+%s")
age=$((now_epoch - published_epoch))
if [ "${age}" -lt 0 ]; then
  echo "❌ ${tag} has a future published_at (${published_at}); refusing to update" >&2
  exit 1
fi

if [ "${age}" -lt "${min_age_seconds}" ]; then
  echo "⏳ ${tag} は公開から $((age / 3600)) 時間。minimum_release_age (1d) を満たすまで self-update を延期する"
  exit 0
fi

version=${tag#v}
exec mise self-update --yes "${version}"
