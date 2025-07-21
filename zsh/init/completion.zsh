# zsh completion system initialization
# 補完システムの初期化処理

# キャッシュディレクトリ設定
export ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"

# キャッシュディレクトリ作成
[[ -d "${ZSH_COMPDUMP:h}" ]] || mkdir -p "${ZSH_COMPDUMP:h}"

# 古いzcompdumpファイルのクリーンアップ関数
cleanup_old_zcompdump() {
  local cache_dir="${ZSH_COMPDUMP:h}"
  # 7日以上古いファイルを削除
  find "$cache_dir" -name "zcompdump*" -type f -mtime +7 -delete 2>/dev/null
}

# post-compinit hooks実行
_execute_post_compinit_hooks() {
  if (( ${+_post_compinit_hooks} )); then
    for hook in $_post_compinit_hooks; do
      eval "$hook"
    done
    unset _post_compinit_hooks
  fi
}

# 補完システム初期化（完全初期化）
_init_completion() {
  # fpath設定 - 補完関数の検索パスを追加
  if [[ -d /opt/homebrew/share/zsh/site-functions ]]; then
    fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
  fi
  
  # プロジェクト固有の補完ディレクトリ
  local completion_dir="${${(%):-%x}:A:h:h}/completions"
  if [[ -d "$completion_dir" ]]; then
    fpath=("$completion_dir" $fpath)
  fi

  autoload -Uz compinit
  if [[ -n "${ZSH_COMPDUMP}"(#qNmh+24) ]]; then
    # 24時間以上古い場合は再構築
    compinit -d "${ZSH_COMPDUMP}"
    cleanup_old_zcompdump
  else
    # キャッシュが新しい場合はセキュリティチェックをスキップ
    compinit -C -d "${ZSH_COMPDUMP}"
  fi

  # 初期化完了後にフックを実行
  _execute_post_compinit_hooks
}

# zsh-deferが利用可能な場合は遅延読み込み、そうでなければ即座に実行
if (( $+functions[zsh-defer] )); then
  zsh-defer _init_completion
else
  _init_completion
fi

# vim: set syntax=zsh:


