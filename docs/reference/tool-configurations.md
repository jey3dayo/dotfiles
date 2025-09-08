# Tool Configurations - Centralized Reference

🔧 各ツールの設定方針と統合パターンの一元管理

## 🎯 統合設計思想

### Core Principles

1. **Performance First**: 起動時間最適化を最優先
2. **Modular Design**: 機能別設定分離
3. **Lazy Loading**: 重いツールの遅延読み込み
4. **Unified Theme**: Gruvboxベース統一デザイン

## 📦 主要ツール設定

### 🐚 Shell Integration Tools

#### mise (Language Version Manager)

**設定場所**:

- `mise.toml` - メイン設定（ツール・タスク定義）
- `zsh/config/tools/mise.zsh` - Shell統合・遅延読み込み

**設計思想**:

```zsh
# 最適化された初期化パターン
eval "$(mise activate zsh)"      # 即座にPATH設定
eval "$(mise hook-env -s zsh)"   # 環境変数hook
zsh-defer -t 3 eval "$(mise complete -s zsh)"  # 補完のみ遅延
```

**分離理由**:

- `mise.toml`: ツール定義・タスク管理（mise固有）
- `zsh設定`: Shell統合・パフォーマンス最適化（Zsh固有）

#### Homebrew Package Manager

**設定場所**:

- `Brewfile` - パッケージ定義
- `zsh/config/tools/brew.zsh` - Shell統合・アーキテクチャ対応

**設計思想**:

```zsh
# アーキテクチャ別PATH設定
if [[ "$(arch)" == arm64 ]]; then
  BREW_PATH=/opt/homebrew/bin
else
  BREW_PATH=/usr/local/bin
fi
```

**分離理由**:

- `Brewfile`: パッケージ管理（Homebrew固有）
- `zsh設定`: 環境変数・PATH設定（Shell固有）

### 🛠️ Development Tools

#### Git Configuration

**設定場所**:

- `git/config` - メイン設定
- `git/gitconfig_local.example` - ローカル設定テンプレート
- `zsh/config/tools/git.zsh` - Shell統合（abbreviations）

**統合パターン**:

- メイン設定: 共通設定・エイリアス
- ローカル設定: 個人情報（未tracked）
- Shell統合: キーボードショートカット・FZF連携

#### FZF (Fuzzy Finder)

**設定場所**:

- `zsh/config/tools/fzf.zsh` - Shell統合
- `zsh/widgets/` - カスタムウィジェット

**最適化パターン**:

```zsh
# 遅延読み込み + カスタマイズ
[[ $- != *i* ]] && return  # 非対話モードは除外
source <(fzf --zsh)        # 公式設定読み込み
```

## 🎨 統一設計パターン

### Theme Integration (Gruvbox)

**適用ツール**:

- Neovim: `colorscheme gruvbox`
- WezTerm: Gruvbox color scheme
- Tmux: Gruvbox status line
- Alacritty: Gruvbox colors

**設定統一**:

```lua
-- 共通カラーパレット（例: WezTerm）
local colors = {
  background = '#282828',
  foreground = '#ebdbb2',
  -- ... gruvbox colors
}
```

### Font Integration

**統一フォント**: 各ツールでSF Mono系フォント使用

- Terminal: SF Mono
- Editor: SF Mono (with ligatures)
- Status: SF Mono

## 🚀 Performance Patterns

### 遅延読み込みパターン

#### Pattern 1: Function Wrapper

```zsh
# 重いツールの関数ラッパー
tool_name() {
    unfunction tool_name
    eval "$(tool_name init)"
    tool_name "$@"
}
```

#### Pattern 2: Conditional Loading

```zsh
# 存在確認後の条件付き読み込み
command -v tool_name >/dev/null || return
eval "$(tool_name init)"
```

#### Pattern 3: Deferred Loading

```zsh
# zsh-defer使用パターン
if (( $+functions[zsh-defer] )); then
  zsh-defer -t 3 eval "$(tool_name init)"
else
  eval "$(tool_name init)"
fi
```

## 📁 Directory Structure Patterns

### Configuration Organization

```
dotfiles/
├── tool_name/
│   ├── config/          # メイン設定
│   ├── themes/          # テーマ設定
│   └── README.md        # ツール固有ドキュメント
└── zsh/config/tools/    # Shell統合設定
    └── tool_name.zsh
```

### Integration Points

1. **Main Config**: ツール固有設定
2. **Shell Integration**: Zsh統合・遅延読み込み
3. **Theme Config**: 統一テーマ設定
4. **Performance Config**: 最適化設定

## 🔄 Maintenance Patterns

### 設定更新フロー

1. **Main Config更新**: 機能・設定変更
2. **Performance測定**: `zsh-benchmark`で影響確認
3. **Integration確認**: 他ツールとの連携確認
4. **Documentation更新**: 変更内容をドキュメント反映

### 監視対象

- 起動時間への影響
- 機能の正常動作
- テーマ統一性の維持
- 他ツールとの競合

---

**設計原則**: 機能分離 + 統合最適化  
**維持方針**: パフォーマンス優先 + モジュラー設計  
**更新頻度**: 四半期レビュー + 問題発生時
