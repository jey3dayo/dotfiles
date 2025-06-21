# Dotfiles Architecture Patterns - 設計原則と統一パターン

このドキュメントでは、dotfiles全体を通じて適用される設計パターン、原則、ベストプラクティスを定義します。

## 🏗️ アーキテクチャ原則

### 主要技術スタック
**Primary Stack**: Zsh + WezTerm + Neovim
- **Zsh (Shell)**: 開発環境の基盤、コマンドライン効率化の中核
- **WezTerm (Terminal)**: GPU加速ターミナル、Lua設定による高度なカスタマイズ
- **Neovim (Editor)**: LSP統合エディタ、AI支援開発環境

この3つが設定量・機能・使用頻度において中核を成しており、他のツールはこれらを補完する役割。

### 1. モジュラー設計
- **責任分離**: 各ツール・機能は独立したモジュールとして管理
- **依存関係最小化**: ツール間の不要な依存関係を避ける
- **設定の階層化**: global → local → project の優先順位
- **主要技術優先**: Zsh/WezTerm/Neovim設定に開発リソースを集中

#### 設計原則詳細
- **分離の原則**: 各ツール独立、疎結合設計
- **統合の原則**: 一貫したテーマ・キーバインド・ワークフロー
- **拡張性**: 新ツール追加の容易さ
- **保守性確保**: 文書化、バージョン管理、テスト性

### 2. パフォーマンス最優先
- **遅延読み込み**: 必要時のみリソースを読み込み
- **起動時間最適化**: 主要3ツールで起動時間の継続測定・改善
- **メモリ効率**: 不要なプロセス・機能の排除
- **主要技術最適化**: Zsh 1.2s, Neovim 95ms, WezTerm 800msを継続改善

### 3. 一貫性の維持
- **テーマ統一**: 全ツールで一貫したカラースキーム・フォント
- **キーバインド統一**: 主要3ツール間での一貫したキーマッピング
- **命名規則**: ファイル名、関数名、変数名の統一

## 📁 ディレクトリ構造パターン

```
dotfiles/
├── .claude/                    # AI支援・知見管理
│   ├── layers/                 # 層別知識管理
│   │   ├── core/              # 核となる設定層
│   │   ├── tools/             # ツール固有層
│   │   └── support/           # 支援・横断層
│   ├── architecture/          # アーキテクチャ知識
│   ├── knowledge/             # 汎用知識
│   └── commands/              # カスタムコマンド
├── zsh/                       # Shell環境
│   ├── config/                # モジュラー設定
│   ├── functions/             # カスタム関数
│   └── completions/           # 補完設定
├── nvim/                      # エディタ環境
│   ├── lua/config/            # Lua設定（モジュラー）
│   └── lua/plugins/           # プラグイン設定
├── terminal/                  # ターミナル設定
│   ├── wezterm/               # WezTerm設定
│   ├── alacritty/             # Alacritty設定
│   └── tmux/                  # Tmux設定
└── integration/               # ツール間統合
    ├── themes/                # 統一テーマ
    ├── keymaps/               # 統一キーマップ
    └── workflows/             # ワークフロー自動化
```

## 🔧 設定管理パターン

### 環境別設定パターン

```zsh
# 設定ファイルの階層読み込み
load_config() {
    local config_name="$1"
    
    # 1. デフォルト設定
    local default_config="$DOTFILES_DIR/config/${config_name}.default"
    [[ -f "$default_config" ]] && source "$default_config"
    
    # 2. OS固有設定
    local os_config="$DOTFILES_DIR/config/${config_name}.${DOTFILES_OS}"
    [[ -f "$os_config" ]] && source "$os_config"
    
    # 3. 環境固有設定
    local env_config="$DOTFILES_DIR/config/${config_name}.${DOTFILES_ENV}"
    [[ -f "$env_config" ]] && source "$env_config"
    
    # 4. ローカル設定（git管理外）
    local local_config="$HOME/.config/${config_name}.local"
    [[ -f "$local_config" ]] && source "$local_config"
}
```

### 遅延読み込みパターン

```zsh
# 汎用遅延読み込みテンプレート
create_lazy_loader() {
    local tool_name="$1"
    local init_command="$2"
    local check_command="${3:-command -v $tool_name}"
    
    if eval "$check_command" >/dev/null 2>&1; then
        eval "${tool_name}() {
            unfunction ${tool_name} 2>/dev/null
            eval \"\$(${init_command})\"
            ${tool_name} \"\$@\"
        }"
    fi
}

# 使用例
create_lazy_loader "mise" "mise activate zsh"
create_lazy_loader "kubectl" "kubectl completion zsh"
create_lazy_loader "docker" "docker completion zsh"
```

## 🎨 テーマ統一パターン

### カラースキーム管理

```zsh
# 統一テーマシステム
export DOTFILES_THEME_PRIMARY="gruvbox"
export DOTFILES_THEME_VARIANT="dark"

# テーマ適用関数
apply_unified_theme() {
    local theme="$DOTFILES_THEME_PRIMARY"
    local variant="$DOTFILES_THEME_VARIANT"
    
    case "$theme" in
        gruvbox)
            # 共通カラー定義
            export THEME_BG="#282828"
            export THEME_FG="#ebdbb2"
            export THEME_ACCENT="#fe8019"
            
            # FZF
            export FZF_DEFAULT_OPTS="--color=bg+:#3c3836,bg:#32302f,spinner:#fb4934,hl:#928374"
            
            # LS_COLORS
            export LS_COLORS="di=1;34:ln=1;36:so=1;35:pi=1;33:ex=1;32"
            ;;
    esac
    
    # 各ツールにテーマを通知
    notify_theme_change "$theme" "$variant"
}

notify_theme_change() {
    local theme="$1" variant="$2"
    
    # Neovim
    echo "colorscheme $theme" > ~/.config/nvim/theme.vim
    
    # その他のツールも同様に更新
}
```

## ⚡ パフォーマンスパターン

### 起動時間最適化

```zsh
# パフォーマンス測定付き設定読み込み
timed_source() {
    local file="$1"
    local start_time=$(gdate +%s.%N)
    
    source "$file"
    
    local end_time=$(gdate +%s.%N)
    local elapsed=$(echo "$end_time - $start_time" | bc -l)
    
    # 遅い設定ファイルを特定
    if (( $(echo "$elapsed > 0.1" | bc -l) )); then
        echo "⚠️  Slow config: $file (${elapsed}s)" >&2
    fi
}

# 使用例
timed_source "$HOME/.config/zsh/aliases.zsh"
```

### メモリ効率パターン

```zsh
# 条件付きプラグイン読み込み
load_plugin_if_needed() {
    local plugin="$1"
    local condition="$2"
    
    if eval "$condition"; then
        sheldon plugin load "$plugin"
    else
        # プレースホルダー関数で必要時に遅延読み込み
        eval "${plugin}() {
            sheldon plugin load '$plugin'
            unfunction '$plugin'
            $plugin \"\$@\"
        }"
    fi
}
```

## 🔑 キーバインド統一パターン

### 共通キーマップ定義

```zsh
# 統一キーマップ設定
export DOTFILES_LEADER_KEY="^X"  # Ctrl+X

# 共通アクション
export KEY_FILE_SEARCH="^]"      # Ctrl+]
export KEY_GIT_STATUS="^G^G"     # Ctrl+G Ctrl+G
export KEY_PROJECT_JUMP="^P"     # Ctrl+P

# ツール固有だが統一されたキー
export KEY_TERMINAL_SPLIT_H="|"
export KEY_TERMINAL_SPLIT_V="-"
export KEY_PANE_LEFT="h"
export KEY_PANE_DOWN="j"
export KEY_PANE_UP="k"
export KEY_PANE_RIGHT="l"
```

## 🔄 統合パターン

### ツール間連携

```zsh
# 統合コマンドパターン
create_integrated_command() {
    local command_name="$1"
    local description="$2"
    shift 2
    local tools=("$@")
    
    eval "${command_name}() {
        echo \"🔧 $description\"
        for tool in ${tools[@]}; do
            if command -v \$tool >/dev/null 2>&1; then
                echo \"  ✅ \$tool: executing...\"
                \$tool \"\$@\"
            else
                echo \"  ❌ \$tool: not available\"
            fi
        done
    }"
}

# 使用例
create_integrated_command "update-all" "Update all package managers" \
    "brew upgrade" "mise outdated" "nvim +PackerSync"
```

## 📋 設定検証パターン

### 健全性チェック

```zsh
# 設定の整合性チェック
validate_dotfiles() {
    echo "🔍 Validating dotfiles configuration..."
    
    local errors=0
    
    # 必須コマンドの確認
    local required_commands=("git" "nvim" "tmux" "fzf")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            echo "❌ Missing required command: $cmd"
            ((errors++))
        fi
    done
    
    # 設定ファイルの存在確認
    local config_files=(
        "$HOME/.zshrc"
        "$HOME/.config/nvim/init.lua"
        "$HOME/.tmux.conf"
    )
    for file in "${config_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            echo "❌ Missing config file: $file"
            ((errors++))
        fi
    done
    
    # パフォーマンスチェック
    echo "📊 Performance check..."
    zsh-benchmark 1 | grep -q "startup time: [0-1]\." || {
        echo "⚠️  Slow startup time detected"
        ((errors++))
    }
    
    if [[ $errors -eq 0 ]]; then
        echo "✅ All validations passed"
        return 0
    else
        echo "❌ $errors validation errors found"
        return 1
    fi
}
```

## 💡 設計決定記録

### 成功した設計決定
1. **Sheldon採用**: プラグイン管理の一元化と高速化実現
2. **Lua設定**: Neovimの起動時間を60%短縮
3. **遅延読み込み**: 30%の起動時間短縮効果

### 失敗から学んだ教訓
1. **過度の抽象化**: 設定の複雑化を招き保守困難に
2. **テスト不足**: 環境変更時の動作検証不十分
3. **ドキュメント不備**: 設定変更の理由・効果の記録不足

### 今後の設計方針
1. **段階的改善**: 大幅な変更は段階的に実施
2. **測定の重要性**: 全ての最適化は測定に基づく
3. **シンプル指向**: 複雑さよりもシンプルさを優先

## 🔧 よく使用するパターン

### シンボリックリンク管理
```bash
# 基本パターン
ln -sf "$DOTFILES_DIR/config_file" "$HOME/.config_file"

# ディレクトリ対応
ln -sf "$DOTFILES_DIR/config_dir" "$HOME/.config/app_name"

# 一括作成
create_symlinks() {
    local dotfiles_dir="$1"
    ln -sf "$dotfiles_dir/zsh/.zshrc" "$HOME/.zshrc"
    ln -sf "$dotfiles_dir/nvim" "$HOME/.config/nvim"
    ln -sf "$dotfiles_dir/wezterm/wezterm.lua" "$HOME/.config/wezterm/wezterm.lua"
}
```

### 条件付き設定読み込み
```bash
# コマンド存在確認
if command -v tool_name >/dev/null 2>&1; then
    source "$DOTFILES_DIR/tool_config"
fi

# ファイル存在確認
[[ -f "$HOME/.local_config" ]] && source "$HOME/.local_config"

# OS別分岐
case "$(uname -s)" in
    Darwin)  # macOS
        source "$DOTFILES_DIR/macos.zsh"
        ;;
    Linux)   # Linux
        source "$DOTFILES_DIR/linux.zsh"
        ;;
esac
```

---

*最終更新: 2025-06-20*
*設計フェーズ: 安定版 - 継続的改善*