# Common helper functions for loaders

# 遅延読み込み用ヘルパー関数
_defer_or_source() {
  local file="$1"
  # zsh-deferが利用可能な場合は遅延読み込み、そうでなければ即座に読み込み
  if (($ + functions[zsh - defer])); then
    zsh-defer source "$file"
  else
    source "$file"
  fi
}

# ディレクトリ内のzshファイルを読み込む関数
_load_zsh_files() {
  local dir="$1"
  local defer="$2" # "defer" または "immediate"

  [[ ! -d "$dir" ]] && return

  for file in "$dir"/*.zsh; do
    if [[ -r "$file" ]]; then
      if [[ "$defer" == "defer" ]]; then
        _defer_or_source "$file"
      else
        source "$file"
      fi
    fi
  done
}

# vim: set syntax=zsh:
