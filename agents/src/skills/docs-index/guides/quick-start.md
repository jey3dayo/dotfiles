# Quick Start Guide - Claude Code

Claude Codeを使い始めるためのクイックスタートガイド。

## 基本操作

### コマンド実行

Claude Codeでは、スラッシュコマンド（`/`で始まる）を使用してタスクを実行します。

```bash
/review              # コードレビュー実行
/polish              # コード品質改善（自動修正付き）
/commit              # スマートコミット
/task "説明"         # 自然言語でタスク実行
```

### スキル呼び出し

スキルは自動的にトリガーされるか、明示的に呼び出すことができます。

```
"code-reviewスキルを使ってレビューして"
"cc-sddで新機能の仕様を作成したい"
```

## よく使うコマンド Top 10

### 1. `/review` - コードレビュー

包括的なコードレビューを実行します。

```bash
/review                    # 基本レビュー
/review --simple           # シンプルモード（並列実行）
/review --fix-pr           # PRレビューコメント自動修正
/review --fix-ci           # CI失敗診断と修正
```

### 2. `/polish` - コード品質改善

自動修正を繰り返し、エラーが出なくなるまで実行します。

```bash
/polish                    # lint/format/test + 自動修正
/polish --with-comments    # コメント整理も実行
```

### 3. `/task` - インテリジェントタスクルーター

自然言語でタスクを指示すると、最適なエージェント/コマンドを自動選択します。

```bash
/task "コードをレビューして"
/task "パフォーマンスを改善して"
/task "ドキュメントを更新して"
```

### 4. `/commit` - スマートコミット

変更を解析して、適切なコミットメッセージを生成します。

```bash
/commit                    # 全変更をコミット
/commit --message "説明"   # メッセージ指定
```

### 5. `/todos` - タスク管理

インタラクティブなタスク管理システム。

```bash
/todos                     # タスク一覧表示
/create-todos              # TODOコメント作成
/find-todos                # TODOコメント検索
/fix-todos                 # TODO解決
```

### 6. `/implement` - スマート実装エンジン

プロジェクトアーキテクチャに適応した実装を提供します。

```bash
/implement "機能説明"      # 機能実装
```

### 7. `/docs` - ドキュメント管理

プロジェクトのドキュメントを自動管理します。

```bash
/docs                      # ドキュメント更新
/fix-docs                  # リンク修正・構造改善
```

### 8. `/learnings` - 知識記録

構造化された知見管理システム。

```bash
/learnings add "内容"      # 学習記録追加
/learnings list            # 記録一覧
```

### 9. `/create-pr` - PR作成

フォーマット・コミット・PR作成を一括実行します。

```bash
/create-pr                 # 自動PR作成
```

### 10. Kiroコマンド - Spec-Driven Development

仕様駆動開発のワークフロー。

```bash
/kiro:spec-init "説明"     # 仕様初期化
/kiro:spec-requirements    # 要件定義
/kiro:spec-design          # 技術設計
/kiro:spec-tasks           # タスク生成
/kiro:spec-impl            # TDD実装
/kiro:spec-status          # 進捗確認
```

## スキルシステムの使い方

### スキルの検索

`docs-index`スキルを使って、利用可能なスキルを検索します。

```
"スキル一覧を見せて"
"TypeScriptのスキルはある？"
```

### Progressive Disclosure

スキルは段階的に情報を開示します:

1. 初回: 概要とクイックリファレンス
2. 詳細要求時: 詳細ドキュメントをロード

### スキルの自動トリガー

キーワードで自動的にスキルがトリガーされます:

```
"コードレビューして" → code-review スキル
"mise設定を確認" → mise スキル
"セキュリティチェック" → security スキル
```

## 環境設定

### グローバル設定

個人設定は `~/.claude/CLAUDE.md` に記載します。

### プロジェクト設定

プロジェクト固有の設定は以下に配置:

- `CLAUDE.md` - プロジェクトルート
- `.claude/rules/` - プロジェクトルール
- `.kiro/steering/` - Kiroステアリング

### スキルのインストール

### Marketplaceスキル

```bash
/plugin marketplace add ~/src/github.com/jey3dayo/claude-code-marketplace
```

### Localスキル

`~/.claude/skills/` にスキルディレクトリを配置。

## トラブルシューティング

### スキルが見つからない

1. `~/.claude/skills/` のディレクトリ構造を確認
2. `SKILL.md` が存在するか確認
3. Nix Home Managerの場合、`home-manager switch` を再実行

### コマンドが実行されない

1. コマンド名のスペルミスを確認
2. `indexes/commands-index.md` で正しいコマンド名を確認

### ドキュメントが見つからない

`docs-index` スキルで検索するか、以下を参照:

- `indexes/skills-index.md` - スキル一覧
- `indexes/commands-index.md` - コマンド一覧
- `indexes/agents-index.md` - エージェント一覧

## 次のステップ

- 詳細ガイド: `guides/navigation-tips.md`
- 統合フレームワーク: `integration-framework` スキル
- コードレビュー: `code-review` スキル
- Spec-Driven Development: `cc-sdd` スキル

---

### 更新日
