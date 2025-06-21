# Integration Layer - Cross-Tool Coordination & Workflows

このレイヤーでは、異なるツール間の統合、ワークフロー連携、設定同期に関する知見を体系化します。

## 🎯 責任範囲

**主要技術統合**: Zsh ⇔ WezTerm ⇔ Neovim の3技術連携が中核

- **Primary Integration**: 主要3技術間のシームレス連携
- **設定統一**: テーマ・フォント・キーバインドの統一管理
- **ワークフロー**: 3技術を軸とした開発フロー最適化

- **Tool Integration**: シェル、エディタ、ターミナル、Git間の連携
- **Workflow Automation**: 開発ワークフローの自動化・効率化
- **Configuration Sync**: 設定ファイル間の一貫性・同期
- **Environment Management**: 環境固有の設定とポータビリティ

## 🔄 統合パターン

### シェル ⇔ エディタ統合

```zsh
# Neovim統合関数
v() {
    if [[ $# -eq 0 ]]; then
        nvim .
    else
        nvim "$@"
    fi
}

# プロジェクト固有のNeovim起動
vp() {
    local project_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
    cd "$project_root"
    nvim .
}

# ファイル検索 → エディタ起動
vf() {
    local file=$(fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}')
    [[ -n $file ]] && nvim "$file"
}
```

### Git ⇔ エディタ統合

```zsh
# Git統合エディタコマンド
gve() {
    # 変更ファイルをエディタで開く
    local files=$(git diff --name-only | fzf --multi --preview 'git diff --color=always {}')
    [[ -n $files ]] && echo "$files" | xargs nvim
}

# コミット前の差分確認 + エディタ
gvc() {
    git diff --cached
    echo -n "Open files in editor? (y/N): "
    read -r response
    if [[ $response =~ ^[Yy]$ ]]; then
        git diff --cached --name-only | xargs nvim
    fi
}
```

### ターミナル統合

```lua
-- WezTerm内でのコマンド統合
local wezterm = require('wezterm')

-- 新しいペインでエディタを開く
config.keys = {
    {
        key = 'e',
        mods = 'LEADER',
        action = wezterm.action.SplitHorizontal {
            args = { 'nvim', '.' },
        },
    },
    {
        key = 'g',
        mods = 'LEADER',
        action = wezterm.action.SplitVertical {
            args = { 'zsh', '-c', 'git status && exec zsh' },
        },
    },
}
```

## 🎨 テーマ統合

### 一貫したカラースキーム

```zsh
# 共通テーマ設定
export DOTFILES_THEME="gruvbox"
export DOTFILES_VARIANT="dark"

# ツール固有のテーマ適用
apply_theme() {
    case "$DOTFILES_THEME" in
        gruvbox)
            # Zsh プロンプト
            export ZSH_THEME="gruvbox"

            # FZF
            export FZF_DEFAULT_OPTS="--color=bg+:#3c3836,bg:#32302f,spinner:#fb4934"

            # Neovim (起動時に適用)
            alias nvim="nvim -c 'colorscheme gruvbox'"
            ;;
    esac
}

# 起動時にテーマ適用
apply_theme
```

### フォント統合

```zsh
# 共通フォント設定
export DOTFILES_FONT="UDEV Gothic 35NFLG"
export DOTFILES_FONT_SIZE="16"

# 各ツールでのフォント同期
sync_fonts() {
    # Alacritty
    sed -i.bak "s/family: .*/family: $DOTFILES_FONT/" ~/.config/alacritty/alacritty.yml

    # WezTerm (設定ファイル更新)
    echo "Font updated to $DOTFILES_FONT"
}
```

## 🔧 ワークフロー自動化

### 開発セッション起動

```zsh
# プロジェクト開発環境を一括起動
dev() {
    local project_name="${1:-$(basename $PWD)}"

    # プロジェクトディレクトリに移動
    if [[ -n "$1" ]]; then
        local project_path=$(ghq list -p | grep "$1" | head -1)
        [[ -n "$project_path" ]] && cd "$project_path"
    fi

    # Tmuxセッション作成/接続
    tmux new-session -d -s "$project_name" 2>/dev/null || tmux attach-session -t "$project_name"

    # ペイン分割とツール起動
    tmux split-window -h
    tmux send-keys -t 0 'nvim .' C-m
    tmux send-keys -t 1 'git status' C-m
    tmux select-pane -t 0
}

# 開発終了時のクリーンアップ
dev-stop() {
    local session="${1:-$(basename $PWD)}"

    # 変更のあるファイルを確認
    if git diff --quiet && git diff --cached --quiet; then
        echo "No uncommitted changes"
    else
        echo "Uncommitted changes detected:"
        git status --porcelain
        echo -n "Continue closing? (y/N): "
        read -r response
        [[ ! $response =~ ^[Yy]$ ]] && return
    fi

    # Tmuxセッション終了
    tmux kill-session -t "$session" 2>/dev/null
    echo "Development session '$session' closed"
}
```

### Git統合ワークフロー

```zsh
# 統合Gitワークフロー
gflow() {
    local action="$1"
    case "$action" in
        start)
            # ブランチ作成とセットアップ
            local branch_name="$2"
            git checkout -b "$branch_name"
            git push -u origin "$branch_name"
            echo "Branch '$branch_name' created and tracking set up"
            ;;
        commit)
            # ステージング → コミット → プッシュ
            git add .
            git commit
            git push
            ;;
        pr)
            # プルリクエスト作成
            git push -u origin $(git branch --show-current)
            gh pr create --fill
            ;;
        merge)
            # メインブランチにマージして削除
            local current_branch=$(git branch --show-current)
            git checkout main
            git pull
            git merge "$current_branch"
            git push
            git branch -d "$current_branch"
            git push origin --delete "$current_branch"
            ;;
    esac
}
```

## 📋 設定同期システム

### dotfiles同期

```zsh
# 設定ファイル同期チェック
sync-check() {
    echo "=== Dotfiles Sync Status ==="

    # Git状態確認
    cd "$DOTFILES_DIR"
    if git diff --quiet; then
        echo "✅ All changes committed"
    else
        echo "⚠️  Uncommitted changes:"
        git status --porcelain
    fi

    # リモートとの同期状態
    local ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo "0")
    local behind=$(git rev-list --count HEAD..@{u} 2>/dev/null || echo "0")

    echo "Commits ahead: $ahead, behind: $behind"

    # 設定ファイルの更新時刻確認
    echo -e "\n=== Recent Config Changes ==="
    find ~/.config -name "*.yml" -o -name "*.toml" -o -name "*.lua" -newer ~/.dotfiles_last_sync 2>/dev/null | head -5
}

# 自動同期
auto-sync() {
    cd "$DOTFILES_DIR"

    # 変更があれば自動コミット
    if ! git diff --quiet; then
        git add .
        git commit -m "Auto-sync: $(date '+%Y-%m-%d %H:%M')"
        git push
        echo "✅ Dotfiles auto-synced"
        touch ~/.dotfiles_last_sync
    fi
}
```

### 環境別設定管理

```zsh
# 環境検出と設定分岐
detect_environment() {
    # ホスト名による環境判定
    case "$(hostname)" in
        *work*|*company*)
            export DOTFILES_ENV="work"
            ;;
        *personal*|MacBook*)
            export DOTFILES_ENV="personal"
            ;;
        *)
            export DOTFILES_ENV="generic"
            ;;
    esac

    # OS判定
    case "$(uname -s)" in
        Darwin)
            export DOTFILES_OS="macos"
            ;;
        Linux)
            export DOTFILES_OS="linux"
            ;;
    esac
}

# 環境固有設定の読み込み
load_environment_config() {
    detect_environment

    # 環境固有の設定ファイル読み込み
    local env_config="$HOME/.config/zsh/env/${DOTFILES_ENV}.zsh"
    [[ -f "$env_config" ]] && source "$env_config"

    local os_config="$HOME/.config/zsh/os/${DOTFILES_OS}.zsh"
    [[ -f "$os_config" ]] && source "$os_config"
}
```

## 🚧 統合課題と解決策

### 現在の課題

#### 設定の重複

- **問題**: 同じ設定が複数ファイルに散在
- **解決策**: 共通設定ファイルの作成と統一管理

#### ツール間の不整合

- **問題**: キーバインドやテーマの不一致
- **解決策**: 統一設定システムの導入

#### 環境依存性

- **問題**: 異なる環境での動作不安定
- **解決策**: 環境検出と条件分岐の改善

### 改善計画

```zsh
# 統合管理システムの構想
dotfiles-manage() {
    local command="$1"
    case "$command" in
        sync)
            # 全設定の同期確認と更新
            sync-check
            auto-sync
            ;;
        validate)
            # 設定の整合性チェック
            validate-configs
            ;;
        optimize)
            # パフォーマンス最適化
            perf-check
            ;;
        backup)
            # 設定のバックアップ
            backup-configs
            ;;
    esac
}
```

## 💡 統合のベストプラクティス

### 成功パターン

- **段階的統合**: 一度にすべてを変更せず段階的に統合
- **フォールバック**: 統合機能が失敗した場合のフォールバック
- **文書化**: 統合パターンの明文化とチーム共有

### 失敗パターン

- **過度の統合**: すべてを統合しようとして複雑化
- **テスト不足**: 統合後の動作検証不十分
- **依存関係の複雑化**: ツール間の依存関係が複雑になりすぎ

## 🔗 関連層との連携

- **Shell Layer**: 統合コマンドの実装基盤
- **Git Layer**: バージョン管理と同期の基盤
- **Terminal Layer**: UI統合とワークフロー表示
- **Performance Layer**: 統合による性能への影響測定

---

_最終更新: 2025-06-20_
_統合状態: 基本統合完了、自動化進行中_
_次の目標: 環境別設定管理の完全自動化_
