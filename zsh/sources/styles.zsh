# zsh completion styles configuration
# 補完スタイルとテーマ設定

# 補完スタイル設定
_set_completion_styles() {
  # LS_COLORS環境変数の初期化
  if command -v gdircolors >/dev/null 2>&1; then
    eval "$(gdircolors -b)"
  elif command -v dircolors >/dev/null 2>&1; then
    eval "$(dircolors -b)"
  else
    # fallback: 基本的な色設定
    export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'
  fi

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


