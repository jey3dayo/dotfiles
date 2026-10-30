#!/usr/bin/env bash
# Claude Code のコンテキスト量が多いときだけ警告を出す（300k 以上で黄、400k 以上で赤）
t=$(jq -r '(.context_window.current_usage // empty)
  | if type == "number" then .
    else ((.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0)) end' 2>/dev/null)
[[ "$t" =~ ^[0-9]+$ ]] || exit 0
if ((t >= 400000)); then
  printf ' \033[1;31m🔥 /compact\033[0m'
elif ((t >= 300000)); then
  printf ' \033[33m⚠\033[0m'
fi
