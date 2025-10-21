# 📖 Documentation Navigation

**最終更新**: 2025-10-21
**対象**: 開発者
**タグ**: `category/guide`, `layer/core`, `environment/macos`, `audience/developer`

dotfiles プロジェクトのドキュメント体系へのナビゲーションガイドです。

## 🎯 ドキュメント階層

### 📂 Steering Documents (AI Context - Always Included)

**Location**: [`.kiro/steering/`](../.kiro/steering/)

プロジェクトの高レベルコンテキストを提供。AI セッションで常時ロードされます。

- **[Product Overview](../.kiro/steering/product.md)** - プロダクト概要、機能、ユースケース、価値提案
- **[Technology Stack](../.kiro/steering/tech.md)** - アーキテクチャ、技術スタック、開発環境、コマンド
- **[Project Structure](../.kiro/steering/structure.md)** - ディレクトリ構造、設計パターン、命名規則

### 📚 Detailed Documentation (Human Reference)

**Location**: `docs/`

実装の詳細、手順、メトリクスなど人間向けの詳細ドキュメント。

#### 🚀 Getting Started

- **[Setup Guide](setup.md)** - インストール、初期設定、検証手順

#### 🔧 Operational Guides

- **[Performance](performance.md)** - 詳細メトリクス、ベンチマーク、最適化履歴
- **[Maintenance](maintenance.md)** - 定期メンテナンス、トラブルシューティング、更新履歴

#### 📋 Project Management

- **[TODO](TODO.md)** - タスク管理、課題追跡
- **[Documentation Guidelines](documentation-guidelines.md)** - タグ体系、メタデータ形式、品質基準

#### 🛠️ Tool-Specific Documentation

- **[Zsh Configuration](tools/zsh.md)** - Shell layer: 最適化、プラグイン管理、パフォーマンス
- **[Neovim Configuration](tools/nvim.md)** - Editor layer: LSP、AI支援、プラグイン最適化
- **[WezTerm Configuration](tools/wezterm.md)** - Terminal layer: 設定、キーバインド、統合
- **[SSH Configuration](tools/ssh.md)** - 階層的設定、セキュリティ管理
- **[FZF Integration](tools/fzf-integration.md)** - クロスツール統合、ワークフロー

## 🗺️ Quick Navigation

### 新規ユーザー向け

1. [Setup Guide](setup.md) でインストール
2. [Steering/Product](../.kiro/steering/product.md) で機能を理解
3. [Tool-specific docs](tools/) で詳細を確認

### 開発者向け

1. [Steering Documents](../.kiro/steering/) で全体像を把握
2. [Performance](performance.md) で最適化を確認
3. [Maintenance](maintenance.md) で運用を理解

### トラブルシューティング

1. [Maintenance Guide](maintenance.md) でよくある問題を確認
2. Tool-specific docs で詳細を調査
3. [TODO](TODO.md) で既知の課題を確認

## 📊 Performance Highlights

| Component           | Current    | Target |
| ------------------- | ---------- | ------ |
| **Zsh startup**     | **1.1s**   | <100ms |
| **Neovim startup**  | **<100ms** | <200ms |
| **WezTerm startup** | **800ms**  | <1s    |

詳細は [Performance Statistics](performance.md) を参照。

## 🔗 External References

- [Main README](../README.md) - ユーザー向け概要
- [CLAUDE.md](../CLAUDE.md) - AI向け技術詳細
- [TOOLS.md](../TOOLS.md) - 管理対象ツール一覧

---

_Documentation is a map to your codebase - keep it accurate and navigable._
