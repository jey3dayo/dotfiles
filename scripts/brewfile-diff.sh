#!/usr/bin/env bash

set -euo pipefail

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew not installed. Skipping brewfile:diff."
  exit 0
fi

# cwd に依存すると Brewfile / trust.json が黙ってスキップされるため、スクリプト位置から repo root を決める。
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
brewfile="$repo_root/Brewfile"
trust_json="$repo_root/homebrew/trust.json"

if [[ ! -f "$brewfile" ]]; then
  echo "Brewfile not found: $brewfile"
  exit 1
fi

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

# formulae は mise/config.macos.toml の [bootstrap.packages] が正本のため dump 対象から外す。
brew bundle dump --force --no-describe --taps --casks --mas --vscode --no-formula --file="$tmpdir/dump"

# dump は tap 行に trusted: { formulae: [...] } を出すなど Brewfile と表記が異なるため、
# 行全体でなく「種別 + 名前」を比較キーにする。mas は同名別 ID（Reeder）があるため ID も含める。
# comm の前提を満たすよう LC_ALL=C で並べる。
extract_keys() {
  { grep -E '^(tap|cask|mas|vscode) ' "$1" || true; } \
    | sed -E -e 's/^(mas) "([^"]*)", id: ([0-9]+).*/\1 \2 \3/' -e 's/^([a-z]+) "([^"]*)".*/\1 \2/' \
    | LC_ALL=C sort -u
}

print_section() {
  local title="$1" file="$2"
  echo
  echo "$title"
  if [[ -s "$file" ]]; then
    sed 's/^/  /' "$file"
  else
    echo "  (なし)"
  fi
}

# Brewfile の trusted: true マーカーと trust.json の登録状態を突き合わせる。
# 「未取り込み」との重複を避けるため、Brewfile に記載のある行だけを対象にする。
check_trust() {
  local type="$1" json_key="$2"
  local declared="$tmpdir/trust-declared-$type" trusted="$tmpdir/trust-json-$type"

  { grep -E "^${type} \"" "$brewfile" || true; } \
    | awk -v OFS='\t' '{ name = $0; sub(/^[a-z]+ "/, "", name); sub(/".*/, "", name); print name, ($0 ~ /trusted: true/ ? "true" : "false") }' \
    | LC_ALL=C sort -u >"$declared"

  jq -r --arg key "$json_key" '.[$key] // [] | .[]' "$trust_json" | LC_ALL=C sort -u >"$trusted"

  while IFS=$'\t' read -r name marker; do
    if LC_ALL=C grep -qxF "$name" "$trusted"; then
      if [[ "$marker" != "true" ]]; then
        echo "$type \"$name\": trust.json は信頼済み / Brewfile に trusted: true が無い"
      fi
    elif [[ "$marker" == "true" ]]; then
      echo "$type \"$name\": Brewfile は trusted: true / trust.json に未登録"
    fi
  done <"$declared"
}

extract_keys "$tmpdir/dump" >"$tmpdir/installed"
extract_keys "$brewfile" >"$tmpdir/declared"

LC_ALL=C comm -23 "$tmpdir/installed" "$tmpdir/declared" >"$tmpdir/installed-only"
LC_ALL=C comm -13 "$tmpdir/installed" "$tmpdir/declared" >"$tmpdir/declared-only"

print_section "未取り込み: インストール済みだが Brewfile に無い" "$tmpdir/installed-only"
print_section "未インストール: Brewfile にあるが未導入（削除候補ではない）" "$tmpdir/declared-only"

: >"$tmpdir/trust-mismatch"
if [[ ! -f "$trust_json" ]]; then
  echo "(skip: $trust_json が無い)" >"$tmpdir/trust-mismatch"
elif ! command -v jq >/dev/null 2>&1; then
  echo "(skip: jq が無い)" >"$tmpdir/trust-mismatch"
else
  {
    check_trust tap trustedtaps
    check_trust brew trustedformulae
    check_trust cask trustedcasks
  } >"$tmpdir/trust-mismatch"
fi

print_section "trusted 不一致: Brewfile と homebrew/trust.json" "$tmpdir/trust-mismatch"

echo
echo "注記: formula の差分は対象外（mise/config.macos.toml の [bootstrap.packages] が正本）"
