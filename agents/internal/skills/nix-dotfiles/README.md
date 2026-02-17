# nix-dotfiles

Home Manager と Nix Flake を使った dotfiles 管理とトラブルシューティング。

## 概要

このスキルは、Home Manager による dotfiles 管理の統合操作とトラブルシューティングを提供します。

### 主な機能

- 設定適用 (home-manager switch)
- 世代管理 (generations, rollback)
- 診断 (スキル配布、Flake inputs、Worktree 検出、.gitignore)
- Agent Skills 追加 (flake inputs 同期)

## トリガー

以下のキーワードでスキルが起動します:

- "スキルが配布されない"
- "~/.claude/skills/ が空"
- "dotfiles をデプロイ" / "設定を適用"
- "Nix flake をテスト"
- "home-manager" / "generations" / "rollback"
- "worktree が見つからない"

## 構造

```
nix-dotfiles/
├── SKILL.md                    # Quick Start ガイド (538 行)
├── scripts/
│   └── diagnose.sh             # 統合診断スクリプト
└── references/
    ├── troubleshooting.md      # 詳細な診断手順 (656 行)
    ├── commands.md             # 全コマンドリファレンス (762 行)
    └── architecture.md         # Flake 構造、SSoT パターン (833 行)
```

## Quick Start

### 診断スクリプト

```bash
~/.config/agents/skills-internal/nix-dotfiles/scripts/diagnose.sh
```

### チェック項目

- Generation 検証
- Symlink 検証
- Flake Inputs 一貫性
- Worktree 検出

### よく使うコマンド

```bash
# 設定適用
home-manager switch --flake ~/.config --impure

# 世代確認
home-manager generations | head -5

# ロールバック
home-manager switch --generation <N>
```

## ドキュメント

### SKILL.md

Quick Start に特化したガイド。

### 主なセクション

- Quick Start (最頻出操作)
- Core Workflows (新ツール追加、Agent Skills 追加)
- Diagnostic Commands (統合診断、手動診断)
- Common Issues & Quick Fixes
- References Navigation

### references/troubleshooting.md

詳細な診断手順（症状 → 原因 → 確認 → 対策）

### 主なトピック

- Agent Skills が配布されない
- Flake inputs エラー
- Worktree 検出失敗
- .gitignore フィルタリング問題
- 書き込みエラー

### references/commands.md

全コマンドリファレンス

### カバー範囲

- home-manager コマンド (switch, build, generations, rollback)
- nix flake コマンド (show, metadata, check, update, lock)
- nix run コマンド (validate, catalog)
- 診断コマンド (generation 確認、symlink 検証、flake inputs 確認)

### references/architecture.md

Flake 構造、Worktree SSoT、gitignore フィルタリング

### 主なセクション

- 用語集 (Worktree, Activation Script, DAG, SSoT, cleanedRepo)
- Flake 構造
- Flake Inputs と Agent Skills 管理
- Worktree 検出ロジック
- .gitignore-aware フィルタリング
- 静的 vs 動的ファイル管理
- Activation Scripts

## 設計パターン

### Progressive Disclosure

- Quick Start: 基本操作だけで完結（SKILL.md）
- 詳細 References: 深い診断やアーキテクチャ理解（references/）
- ToC 付き: 各 reference ファイルに Table of Contents

### SSoT (Single Source of Truth)

| SSoT                       | 管理内容              |
| -------------------------- | --------------------- |
| `agent-skills-sources.nix` | スキルメタデータ      |
| `detectWorktreeScript`     | worktree 検出ロジック |
| `.gitignore`               | 除外ファイルパターン  |

### 診断スクリプト

4つのチェックで最頻出トラブルを体系的にカバー:

1. Generation 検証
2. Symlink 検証
3. Flake Inputs 一貫性
4. Worktree 検出

## 検証

### 構造検証

```bash
# スキル構造の確認
ls -la ~/.config/agents/skills-internal/nix-dotfiles/

# references の確認
ls -la ~/.config/agents/skills-internal/nix-dotfiles/references/

# scripts の実行権限確認
ls -la ~/.config/agents/skills-internal/nix-dotfiles/scripts/
```

### 診断スクリプト実行

```bash
~/.config/agents/skills-internal/nix-dotfiles/scripts/diagnose.sh
```

### 期待される出力

- `[✓]` または `[✗]` による視覚的フィードバック
- 失敗時に Quick fixes の提案
- 全体の Summary

## 関連ドキュメント

- `~/.claude/rules/troubleshooting.md` - ユーザーレベルのトラブルシューティング
- `.claude/rules/home-manager.md` - Home Manager 統合ルール
- `nix/dotfiles-module.nix` - Dotfiles 管理モジュール (SSoT)
- `nix/agent-skills-sources.nix` - スキルメタデータ (SSoT)

## メンテナンス

### 新しいトラブル事例の追加

1. `references/troubleshooting.md` にセクション追加
2. 必要に応じて `scripts/diagnose.sh` にチェック追加
3. `SKILL.md` の "Common Issues & Quick Fixes" に概要追加

### コマンドの追加

1. `references/commands.md` に詳細追加
2. `SKILL.md` に概要追加（必要な場合のみ）

### アーキテクチャの変更

1. `references/architecture.md` の該当セクション更新
2. 影響範囲に応じて `troubleshooting.md` や `commands.md` も更新
