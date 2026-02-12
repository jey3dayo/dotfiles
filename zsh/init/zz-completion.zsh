# zsh completion system initialization
# 補完システムの初期化処理

# キャッシュディレクトリ設定
export ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"

# キャッシュディレクトリ作成
[[ -d "${ZSH_COMPDUMP:h}" ]] || mkdir -p "${ZSH_COMPDUMP:h}"

# 古いzcompdumpファイルのクリーンアップ関数
cleanup_old_zcompdump() {
  local cache_dir="${ZSH_COMPDUMP:h}"
  local max_days="${ZSH_COMPDUMP_MAX_AGE_DAYS:-7}"
  # 設定日数以上古いファイルを削除
  find "$cache_dir" -name "zcompdump*" -type f -mtime +"${max_days}" -delete 2>/dev/null
}

# post-compinit hooks実行
_execute_post_compinit_hooks() {
  if (( ${+_post_compinit_hooks} )); then
    local hook
    for hook in "${_post_compinit_hooks[@]}"; do
      eval "$hook"
    done
    unset _post_compinit_hooks
  fi
}

# 補完システム初期化（完全初期化）
_init_completion() {
  # fpath設定 - 補完関数の検索パスを追加
  if [[ -d /opt/homebrew/share/zsh/site-functions ]]; then
    fpath=(/opt/homebrew/share/zsh/site-functions "${fpath[@]}")
  fi

  # プロジェクト固有の補完ディレクトリ
  local completion_dir="${${(%):-%x}:A:h:h}/completions"
  if [[ -d "$completion_dir" ]]; then
    fpath=("$completion_dir" "${fpath[@]}")
  fi
  # ユーザーの補完ディレクトリ
  local user_completion_dir="${ZDOTDIR:-$HOME/.config/zsh}/completions"
  if [[ -d "$user_completion_dir" ]]; then
    fpath=("$user_completion_dir" "${fpath[@]}")
  fi

  # Load complist for menu selection widgets
  zmodload -i zsh/complist
  autoload -Uz compinit
  local need_rebuild=0
  local rebuild_hours="${ZSH_COMPDUMP_REBUILD_AGE_HOURS:-24}"
  # 設定時間以上古い場合は再構築
  [[ -n "${ZSH_COMPDUMP}"(#qNmh+${rebuild_hours}) ]] && need_rebuild=1
  # 補完ファイルがzcompdumpより新しければ再構築
  local comp_dir comp_file
  for comp_dir in "$completion_dir" "$user_completion_dir"; do
    for comp_file in "$comp_dir"/*(N); do
      [[ "$comp_file" -nt "${ZSH_COMPDUMP}" ]] && need_rebuild=1
    done
  done

  if (( need_rebuild )); then
    compinit -d "${ZSH_COMPDUMP}"
    cleanup_old_zcompdump
  else
    # キャッシュが新しい場合はセキュリティチェックをスキップ
    compinit -C -d "${ZSH_COMPDUMP}"
  fi
  unset need_rebuild user_completion_dir completion_dir

  # 初期化完了後にフックを実行
  _execute_post_compinit_hooks
}

# Execute immediately (required before sheldon plugins load)
_init_completion

# vim: set syntax=zsh:
