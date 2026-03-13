# 📖 Documentation Navigation

最終更新: 2026-03-13
対象: 開発者
タグ: `category/guide`, `layer/support`, `environment/macos`, `audience/developer`

dotfiles プロジェクトのドキュメント体系へのナビゲーションガイドです。

## 🎯 ドキュメント階層

### 📂 Steering Documents (AI Context - Always Included)

Location: [`.kiro/steering/`](../.kiro/steering/)

プロジェクトの高レベルコンテキストを提供。AI セッションで常時ロードされます。

- [Product Overview](../.kiro/steering/product.md) - プロダクト概要、機能、ユースケース、価値提案
- [Technology Stack](../.kiro/steering/tech.md) - アーキテクチャ、技術スタック、開発環境、コマンド
- [Project Structure](../.kiro/steering/structure.md) - ディレクトリ構造、設計パターン、命名規則

### 📚 Detailed Documentation (Human Reference)

Location: `docs/`

実装の詳細、手順、メトリクスなど人間向けの詳細ドキュメント。

#### 🚀 Getting Started

- [Setup Guide](setup.md) - インストール、初期設定、検証手順

#### 🔧 Operational Guides

- [Performance](performance.md) - 詳細メトリクス、ベンチマーク、最適化履歴
- [Workflows and Maintenance](tools/workflows.md) - 定期メンテナンス、トラブルシューティング、更新履歴

#### 📋 Documentation Governance

- [Documentation Rules](../.claude/rules/documentation-rules.md) - タグ体系、メタデータ形式、品質基準

#### 🛠️ Tool-Specific Documentation

詳細な実装ガイド（SST）。対応するClaudeルールは [`.claude/rules/tools/`](../.claude/rules/tools/) を参照。

- [Git Configuration](tools/git.md) - Git 設定の構成、include 順序、署名オプション ([Claude Rules](../.claude/rules/tools/git.md))
- [Zsh Configuration](tools/zsh.md) - Shell layer: 最適化、プラグイン管理、パフォーマンス ([Claude Rules](../.claude/rules/tools/zsh.md))
- [Neovim Configuration](tools/nvim.md) - Editor layer: LSP、AI支援、プラグイン最適化 ([Claude Rules](../.claude/rules/tools/nvim.md))
- [WezTerm Configuration](tools/wezterm.md) - Terminal layer: 設定、キーバインド、統合 ([Claude Rules](../.claude/rules/tools/wezterm.md))
- [SSH Configuration](tools/ssh.md) - 階層的設定、セキュリティ管理 ([Claude Rules](../.claude/rules/tools/ssh.md))
- [FZF Integration](tools/fzf-integration.md) - クロスツール統合、ワークフロー（FZF/Git キーバインドのSST） ([Claude Rules](../.claude/rules/tools/fzf-integration.md))
- [Home Manager](tools/home-manager.md) - Nix Home Manager 設定・配布・トラブルシューティング ([Claude Rules](../.claude/rules/home-manager.md))
- [Nix Maintenance](tools/nix.md) - Nix store GC・generations 管理 ([Claude Rules](../.claude/rules/nix-maintenance.md))
- [Mise](tools/mise.md) - ツールバージョン管理・設定・pnpm バックエンド ([Claude Rules](../.claude/rules/tools/mise.md))
- [OpenClaw](tools/openclaw.md) - Gateway 運用・systemd 設定・トラブルシューティング ([Claude Rules](../.claude/rules/openclaw.md))
- [Workflows & Maintenance](tools/workflows.md) - 定期メンテナンス・Brewfile・コードクオリティ ([Claude Rules](../.claude/rules/workflows-and-maintenance.md))

## 🧭 Single Source of Truth (SST)

- Setup: `docs/setup.md` に全て集約（README ではリンクのみ）
- Performance: `docs/performance.md` にメトリクス・履歴を一本化
- Maintenance: `docs/tools/workflows.md` に定期/臨時タスクを集約（コンパクト版: `.claude/rules/workflows-and-maintenance.md`）
- Documentation rules: `.claude/rules/documentation-rules.md` にタグ/メタデータ/チェックリストを集約
- Tool details: `docs/tools/*.md` にツール固有の設定・最適化を集約

## 🗺️ Quick Navigation

### 新規ユーザー向け

1. [Setup Guide](setup.md) でインストール
2. [Steering/Product](../.kiro/steering/product.md) で機能を理解
3. [Tool-specific docs](tools/) で詳細を確認

### 開発者向け

1. [Steering Documents](../.kiro/steering/) で全体像を把握
2. [Performance](performance.md) で最適化を確認
3. [Workflows and Maintenance](tools/workflows.md) で運用を理解

### トラブルシューティング

1. [Workflows and Maintenance](tools/workflows.md) でよくある問題を確認
2. Tool-specific docs で詳細を調査

## 📊 Performance

メトリクスと改善履歴の単一情報源は [Performance Statistics](performance.md)。README には数値を重複掲載しない。

## 🔗 External References

- [Main README](../README.md) - ユーザー向け概要
- [Steering Documents](../.kiro/steering/) - AI向け高レベルガイド
- [TOOLS.md](../TOOLS.md) - 管理対象ツール一覧

---

_Documentation is a map to your codebase - keep it accurate and navigable._
