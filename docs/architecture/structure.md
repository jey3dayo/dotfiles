# プロジェクト構造

Dotfiles設定管理プロジェクトの全体構造と設計思想を説明します。

## 🏗️ 全体アーキテクチャ

```
dotfiles/
├── docs/              # 統合ドキュメント管理
├── zsh/               # Shell configuration (modular, optimized)
├── nvim/              # Neovim configuration (Lua-based)
├── git/               # Version control configuration
├── wezterm/           # Primary terminal configuration
├── alacritty/         # Alternative terminal
├── tmux/              # Terminal multiplexer
├── ssh/               # SSH configuration (hierarchical, secure)
├── karabiner/         # Keyboard customization
├── mise.toml          # Version management
├── Brewfile           # Package management
└── setup.sh           # Automated setup script
```

## 🔥 Primary Tech Stack

**Core Technologies**: Zsh + WezTerm + Neovim

- この3技術がコード量・使用頻度・機能において中核
- 他ツールはこれらを補完する支援的役割

**Additional Tools**: Tmux, Homebrew, Mise, Raycast, Karabiner Elements

## 設計原則

### Performance First

- 主要3技術の起動時間最適化
- 詳細指標は[Performance Statistics](../reference/performance-stats.md)参照

### Primary Integration

- Zsh ⇔ WezTerm ⇔ Neovim間のシームレス連携
- 統一されたキーバインドとワークフロー

### Unified Theme

- Gruvboxベース統一テーマ・フォント設定
- JetBrains Mono + Nerd Font ligatures

### Modular Design

- 主要技術を中心とした設定の分離・統合
- 6-tier plugin loading system
- 階層化された設定ファイル構造

## 📊 パフォーマンス目標

| Component           | Target | Current   | Status  |
| ------------------- | ------ | --------- | ------- |
| **Zsh startup**     | <1.5s  | **1.2s**  | ✅ 達成 |
| **Neovim startup**  | <100ms | **<95ms** | ✅ 達成 |
| **WezTerm startup** | <1.0s  | **800ms** | ✅ 達成 |

## 🔄 設定管理方針

### 階層化アプローチ

1. **Core Layers**: 基本設定（Shell, Git）
2. **Tool Layers**: 専門ツール（Editor, Terminal）
3. **Support Layers**: 横断的機能（Performance, Integration）

### モジュラー設計

- 各ツールは独立した設定ディレクトリを持つ
- 共通設定は上位レイヤーで統一管理
- 依存関係を最小化したプラグインシステム

---

_詳細な設計パターンは[Design Patterns](patterns.md)を参照してください。_
