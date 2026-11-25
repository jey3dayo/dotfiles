#!/usr/bin/env sh
# 公式 installer は最後の `agy install` で shell profile へ PATH を追記し `alias agy` を消す。
# dotfiles 管理の profile を守るため、一時 HOME で実行して binary だけ移す。
set -eu

tmp_home="$(mktemp -d)"
trap 'rm -rf "${tmp_home}"' EXIT

HOME="${tmp_home}" bash -c 'curl -fsSL https://antigravity.google/cli/install.sh | bash'

mkdir -p "${HOME}/.local/bin"
mv "${tmp_home}/.local/bin/agy" "${HOME}/.local/bin/agy"
