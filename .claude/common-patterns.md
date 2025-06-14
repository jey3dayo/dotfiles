# Dotfiles よく使用するパターン

## 設定ファイル管理パターン

### シンボリックリンク作成
```bash
# 基本パターン
ln -sf "$DOTFILES_DIR/config_file" "$HOME/.config_file"

# ディレクトリ対応
ln -sf "$DOTFILES_DIR/config_dir" "$HOME/.config/app_name"
```

### 条件付き設定読み込み
```bash
# コマンド存在確認
if command -v tool_name >/dev/null 2>&1; then
    source "$DOTFILES_DIR/tool_config"
fi

# ファイル存在確認
[[ -f "$HOME/.local_config" ]] && source "$HOME/.local_config"
```

## Zsh 設定パターン

### 環境変数設定
```bash
# PATH追加
export PATH="$HOME/.local/bin:$PATH"

# 条件付きPATH追加
[[ -d "$HOME/.cargo/bin" ]] && export PATH="$HOME/.cargo/bin:$PATH"
```

### エイリアス定義
```bash
# 基本エイリアス
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'

# Git エイリアス
alias g='git'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
```

### 関数定義
```bash
# ディレクトリ作成と移動
function mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Git ブランチ切り替え
function gco() {
    git checkout $(git branch -a | fzf | sed 's/remotes\/origin\///')
}
```

## Neovim 設定パターン

### プラグイン設定
```lua
-- 基本プラグイン定義
return {
    'plugin/name',
    dependencies = { 'dep1', 'dep2' },
    config = function()
        require('plugin').setup({
            -- 設定オプション
        })
    end,
    lazy = true,
}
```

### キーマップ定義
```lua
-- 基本キーマップ
vim.keymap.set('n', '<leader>f', ':Telescope find_files<CR>')

-- 条件付きキーマップ
if vim.fn.executable('rg') == 1 then
    vim.keymap.set('n', '<leader>g', ':Telescope live_grep<CR>')
end
```

### オプション設定
```lua
-- 基本オプション
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
```

## Git 設定パターン

### カスタムエイリアス
```bash
# .gitconfig 内
[alias]
    st = status
    co = checkout
    br = branch
    ci = commit
    df = diff
    lg = log --oneline --decorate --graph --all
```

### 条件付き設定
```bash
# 作業ディレクトリによる設定切り替え
[includeIf "gitdir:~/work/"]
    path = ~/.gitconfig-work

[includeIf "gitdir:~/personal/"]
    path = ~/.gitconfig-personal
```

## Tmux 設定パターン

### セッション管理
```bash
# セッション作成
tmux new-session -d -s session_name

# ウィンドウ分割
tmux split-window -h
tmux split-window -v
```

### キーバインド設定
```bash
# プレフィックスキー変更
set -g prefix C-a
unbind C-b
bind C-a send-prefix

# ペイン移動
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R
```

## スクリプト実行パターン

### セットアップスクリプト
```bash
#!/bin/bash
set -e

# 必要なディレクトリ作成
mkdir -p "$HOME/.config"

# 設定ファイルのリンク
for config in $(find "$DOTFILES_DIR" -name "*.conf"); do
    ln -sf "$config" "$HOME/.config/$(basename "$config")"
done
```

### バックアップスクリプト
```bash
#!/bin/bash
BACKUP_DIR="$HOME/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# 既存設定のバックアップ
for file in .zshrc .vimrc .gitconfig; do
    [[ -f "$HOME/$file" ]] && cp "$HOME/$file" "$BACKUP_DIR/"
done
```

## デバッグパターン

### 設定読み込み確認
```bash
# Zsh 設定の診断
zsh -x -c 'exit'

# 環境変数の確認
printenv | grep VARIABLE_NAME

# コマンドパスの確認
which command_name
type command_name
```

### パフォーマンス測定
```bash
# Zsh 起動時間
time zsh -i -c exit

# プロファイリング
zmodload zsh/zprof
# 設定読み込み
zprof
```

## ツール連携パターン

### FZF統合
```bash
# ファイル選択
file=$(find . -type f | fzf)

# Git ブランチ選択
branch=$(git branch | fzf | sed 's/^..//')

# 履歴検索
history | fzf
```

### 1Password CLI統合
```bash
# SSH鍵取得
op item get "SSH Key" --fields private_key > ~/.ssh/id_rsa

# 環境変数設定
export API_KEY=$(op item get "API Key" --fields password)
```

## 条件分岐パターン

### OS別設定
```bash
case "$(uname -s)" in
    Darwin)
        # macOS specific
        export BROWSER='open'
        ;;
    Linux)
        # Linux specific
        export BROWSER='xdg-open'
        ;;
esac
```

### 環境別設定
```bash
# 開発環境判定
if [[ -n "$DEVELOPMENT" ]]; then
    export DEBUG=1
    alias ll='ls -la --color=always'
fi

# 本番環境判定
if [[ -n "$PRODUCTION" ]]; then
    unset DEBUG
    alias rm='rm -i'
fi
```