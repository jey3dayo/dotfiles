# zsh completion styles configuration
# 補完スタイルとテーマ設定

# 補完スタイル設定
_set_completion_styles() {
  zstyle ':completion:*' use-cache true
  zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"
  zstyle ':completion:*' menu select
  zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
  zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
}

# compinit初期化済みの場合はスタイルを適用
if (( $+functions[compdef] )); then
  _set_completion_styles
fi

# vim: set syntax=zsh:

