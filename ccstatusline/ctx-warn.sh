#!/usr/bin/env bash
# コンテキスト量が多いときだけ、区切りの | 付きで警告を出す（黄: HIGH、赤: FULL。閾値は k 単位）
high=240
full=300
t=$(jq -r '(.context_window.current_usage // empty)
  | if type == "number" then .
    else ((.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0)) end' 2>/dev/null)
[[ "$t" =~ ^[0-9]+$ ]] || exit 0
sep='\033[38;2;85;87;83m | \033[0m'
if ((t >= full * 1000)); then
  printf "$sep"'\033[1;97;41m Ctx FULL >%sk \033[0m' "$full"
elif ((t >= high * 1000)); then
  printf "$sep"'\033[1;30;43m Ctx HIGH >%sk \033[0m' "$high"
fi
