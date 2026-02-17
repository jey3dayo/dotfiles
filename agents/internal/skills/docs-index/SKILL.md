---
name: docs-index
description: |
  [What] Documentation navigation hub for Claude Code. Provides quick access to all skills, commands, agents, and guides with bilingual support (Japanese/English).
  [When] Use when: searching for documentation, finding specific skills/commands/agents, understanding system capabilities, navigating Claude Code ecosystem, or looking for implementation guides.
  [Keywords] documentation, docs, navigation, index, skills, commands, agents, guides, reference, search, ドキュメント, ナビゲーション, 検索
disable-model-invocation: false
user-invocable: true
---

# Documentation Index - Claude Code ナビゲーションハブ

Claude Codeのドキュメント、スキル、コマンド、エージェントへのクイックアクセスを提供します。

## 概要

`docs-index`スキルは、Claude Code環境全体のドキュメントナビゲーションハブです。Progressive Disclosure設計により、必要な情報に素早くアクセスできます。

### いつ使うか

このスキルは以下の場合に起動されます:

- ドキュメントやガイドを探している
- 特定のスキル、コマンド、エージェントを見つけたい
- Claude Codeの機能やケイパビリティを理解したい
- 実装パターンやベストプラクティスを参照したい
- システム全体の構造を把握したい

### トリガーキーワード

### 日本語

### 英語

## クイックリファレンス

### 主要カテゴリ

| カテゴリ     | 説明                                 | 詳細ドキュメント            |
| ------------ | ------------------------------------ | --------------------------- |
| **Skills**   | 再利用可能な知識とワークフロー       | `indexes/skills-index.md`   |
| **Commands** | ⚠️ **廃止予定**: Skills移行中        | `indexes/commands-index.md` |
| **Agents**   | タスク自動化とワークフロー実行       | `indexes/agents-index.md`   |
| **Guides**   | クイックスタートとナビゲーションTips | `guides/`                   |

### よく使うドキュメント

1. **クイックスタートガイド** (`guides/quick-start.md`)
   - Claude Code基本操作
   - よく使うコマンド Top 10
   - スキルシステムの使い方

2. **統合フレームワーク** (skill: `integration-framework`)
   - TaskContext標準化
   - Communication Busパターン
   - エージェント/コマンド統合

3. **コードレビューシステム** (skill: `code-review`)
   - ⭐️5段階評価システム
   - プロジェクト自動検出
   - 技術スキル統合

4. **Spec-Driven Development** (skill: `cc-sdd`)
   - Kiro形式のスペック駆動開発
   - `/kiro:` コマンドファミリー
   - ステアリング＋仕様管理

## ドキュメント検索のコツ

### カテゴリ別検索

### スキルを探す時

- 技術スタック特化: `typescript`, `react`, `golang`, `zsh`, `nvim`
- ドキュメント系: `docs-write`, `markdown-docs`, `slide-docs`
- 開発ツール: `mise`, `dotenvx`, `similarity`, `tsr`
- セキュリティ: `security`, `dotfiles-integration`

### コマンドを探す時

- コード品質: `/polish`, `/review`, `/fix-todos`
- タスク管理: `/task`, `/todos`, `/create-todos`
- Git操作: `/commit`, `/create-pr`
- Spec-Driven: `/kiro:spec-init`, `/kiro:spec-design`, `/kiro:spec-impl`

### エージェントを探す時

- コードレビュー: `code-reviewer`, `github-pr-reviewer`
- エラー修正: `error-fixer`
- ドキュメント: `docs-manager`
- オーケストレーション: `orchestrator`

### キーワードマッピング（日本語↔英語）

| 日本語             | 英語                  | カテゴリ      |
| ------------------ | --------------------- | ------------- |
| コードレビュー     | code review           | Skill/Command |
| タスク管理         | task management       | Command       |
| 統合フレームワーク | integration framework | Skill         |
| 品質保証           | quality assurance     | Command/Skill |
| ドキュメント       | documentation         | Skill/Command |
| エージェント選択   | agent selection       | Skill         |
| スペック駆動       | spec-driven           | Skill/Command |

## よくある質問（FAQ）

### Q1: スキル、コマンド、エージェントの違いは？

- **Skill**: 再利用可能な知識とワークフロー。Progressive Disclosure設計で必要時にロード。
- **Command**: ユーザーが手動実行するインタラクティブ操作（例: `/review`, `/polish`）。
- **Agent**: 複雑なタスクの自動実行。他のエージェントやスキルと連携。

### Q2: 新しいスキル/コマンドを作成したい

1. スキル作成: `knowledge-creator` スキルを使用
2. コマンド作成: `command-creator` スキルを使用
3. エージェント作成: `agent-creator` スキルを使用

### Q3: マーケットプレイスのスキルを追加したい

```bash
/plugin marketplace add ~/src/github.com/jey3dayo/claude-code-marketplace
```

詳細は `claude-marketplace-sync` スキルを参照。

### Q4: ドキュメントが見つからない

1. `indexes/skills-index.md` でスキル一覧を確認
2. `indexes/commands-index.md` でコマンド一覧を確認
3. トラブルシューティング: `~/.config/.claude/rules/troubleshooting.md`

### Q5: スキルが読み込まれない

### Nix Home Manager環境

- `home-manager generations` で現在のgenerationを確認
- `home-manager switch --flake ~/.agents --impure` で再適用

## Progressive Disclosure

このスキルは段階的に情報を開示します:

1. **初回ロード** (このファイル): 概要とクイックリファレンス (~6KB)
2. 詳細検索時: `indexes/` の各種インデックス (~20KB)
3. ガイド参照時: `guides/` の詳細ガイド (~15KB)

## 参照

- **Global Instructions**: `~/.claude/CLAUDE.md`
- **Project Instructions**: `~/CLAUDE.md`
- **Troubleshooting**: `.claude/rules/troubleshooting.md`
- **Migration Guide**: `commands/migration-guide.md`

## 更新履歴

- 2025-02-12: 初回作成。40+ スキル、45+ コマンドをインデックス化。
