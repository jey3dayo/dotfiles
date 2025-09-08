# Dotfiles Documentation

高性能macOS開発環境設定の統合ドキュメント管理システムです。

## 📚 ドキュメント構造

### 🎯 [Overview](overview/) - プロジェクト概要

- **[README](overview/README.md)** - メインプロジェクト説明
- **[Quick Start](overview/quick-start.md)** - 高速セットアップガイド
- **[Tools List](overview/tools-list.md)** - 管理対象ツール一覧

### 🏗️ [Architecture](architecture/) - 設計・アーキテクチャ

- **[Structure](architecture/structure.md)** - プロジェクト全体構造
- **[Design Patterns](architecture/patterns.md)** - 設計パターン・ベストプラクティス
- **[Permissions](architecture/permissions.md)** - コンポーネント権限管理

### 🔧 [Configuration](configuration/) - 設定管理

#### Core Layers (基本設定)

- **[Shell](configuration/core/shell.md)** - Zsh最適化・プラグイン管理
- **[Git](configuration/core/git.md)** - Gitワークフロー・認証・統合

#### Tool Layers (専門ツール)

- **[Editor](configuration/tools/editor.md)** - Neovim・LSP・AI支援
- **[Terminal](configuration/tools/terminal.md)** - WezTerm・Tmux・Alacritty設定

#### Support Layers (横断的機能)

- **[Performance](configuration/support/performance.md)** - 計測・最適化・監視
- **[Integration](configuration/support/integration.md)** - ツール間連携・同期

### 🛠️ [Tools](tools/) - 各ツール詳細説明

- **[Zsh](tools/zsh/)** - シェル設定詳細ガイド
- **[Neovim](tools/nvim/)** - エディタ設定詳細ガイド
- **[WezTerm](tools/wezterm/)** - ターミナル設定詳細ガイド
- **[SSH](tools/ssh/)** - SSH設定詳細ガイド

### 📖 [Guides](guides/) - 実装・保守ガイド

- **[Maintenance](guides/maintenance.md)** - 定期メンテナンス・改善履歴
- **[AI Assistance](guides/ai-assistance.md)** - AI支援システム・o3 MCP相談
- **[Configuration Management](guides/configuration-management.md)** - 設定管理パターン・実装手法

### 📋 [Reference](reference/) - リファレンス情報

- **[Performance Stats](reference/performance-stats.md)** - パフォーマンス統計・ベンチマーク
- **[Tool Configurations](reference/tool-configurations.md)** - ツール設定参照
- **[Keybindings](reference/keybindings.md)** - キーバインド参照表

## 🚀 Quick Navigation

### よく使用する情報

- **新規セットアップ**: [Quick Start](overview/quick-start.md)
- **パフォーマンス確認**: [Performance Stats](reference/performance-stats.md)
- **トラブルシューティング**: [Maintenance Guide](guides/maintenance.md)
- **キーバインド確認**: [Keybindings Reference](reference/keybindings.md)

### 設定カスタマイズ

- **Shell最適化**: [Shell Configuration](configuration/core/shell.md)
- **Editor設定**: [Editor Configuration](configuration/tools/editor.md)
- **ターミナル設定**: [Terminal Configuration](configuration/tools/terminal.md)

### 開発・拡張

- **設計思想**: [Architecture Structure](architecture/structure.md)
- **設計パターン**: [Design Patterns](architecture/patterns.md)
- **AI支援活用**: [AI Assistance](guides/ai-assistance.md)

## 📊 Current Status

**Configuration Status**: Production Ready - 統合ドキュメント管理システム完了  
**Performance Targets**: All core metrics achieved  
**Last Updated**: 2025-09-08

### パフォーマンス実績

| Component           | Target | Current   | Status  |
| ------------------- | ------ | --------- | ------- |
| **Zsh startup**     | <1.5s  | **1.2s**  | ✅ 達成 |
| **Neovim startup**  | <100ms | **<95ms** | ✅ 達成 |
| **WezTerm startup** | <1.0s  | **800ms** | ✅ 達成 |

---

_このドキュメントシステムは、モダンな開発環境構築に必要な全ての情報を体系的に整理し、効率的なナビゲーションを提供します。_
