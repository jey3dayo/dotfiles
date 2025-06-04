# zsh completion system configuration
# XDG準拠のキャッシュディレクトリを使用

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

# 補完システム初期化関数
_init_completion() {
  autoload -Uz compinit
  if [[ -n "${ZSH_COMPDUMP}"(#qNmh+24) ]]; then
    # 24時間以上古い場合は再構築
    compinit -d "${ZSH_COMPDUMP}"
    cleanup_old_zcompdump
  else
    # キャッシュが新しい場合はセキュリティチェックをスキップ
    compinit -C -d "${ZSH_COMPDUMP}"
  fi

  # 補完スタイル設定
  zstyle ':completion:*' use-cache true
  zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"
  zstyle ':completion:*' menu select
  zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
  zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
}

# zsh-deferが利用可能な場合は遅延読み込み、そうでなければ即座に実行
if (( $+functions[zsh-defer] )); then
  zsh-defer _init_completion
else
  _init_completion
fi

# vim: set syntax=zsh: 