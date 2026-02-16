---
name: rules-creator
description: |
  [What] Claude Code ルールの作成ガイド。CLAUDE.md と .claude/rules/ の使い分けと作成手順を提供します。
  [When] Use when: プロジェクト標準を強制したい、AIの動作をガイドしたい、ルールを新規作成・改修する時。
  [Keywords] rules, guidelines, project standards, policy, enforcement, claude.md
---

# Rules Creator

Claude Code のルールシステムを活用して、プロジェクト標準を定義・強制するためのガイドです。

## ルールの2層構造

Claude Code のルールは 2 つの仕組みで構成される:

```
┌─────────────────────────────────────────┐
│ CLAUDE.md (ガイドライン)                │  ← 提案・推奨
│ - 開発哲学、ベストプラクティス          │
│ - AIが理解し従うが強制はない            │
└─────────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────┐
│ .claude/rules/ (ルール)                 │  ← 強制・制約
│ - paths で適用範囲を限定可能            │
│ - AIが自動参照し遵守する                │
└─────────────────────────────────────────┘
```

| タイプ     | 強制レベル | 場所           | 目的                         |
| ---------- | ---------- | -------------- | ---------------------------- |
| Guidelines | 提案       | CLAUDE.md      | 開発哲学、ベストプラクティス |
| Rules      | 強制       | .claude/rules/ | 制約、標準、ポリシー         |

## ロード順序と優先度

Rules は 2 レベルで読み込まれる:

| レベル        | パス                   | スコープ           | 優先度             |
| ------------- | ---------------------- | ------------------ | ------------------ |
| User-level    | `~/.claude/rules/*.md` | 全プロジェクト共通 | 低（先に読み込み） |
| Project-level | `.claude/rules/*.md`   | プロジェクト固有   | 高（後に上書き）   |

- サブディレクトリも再帰的に探索
- シンボリックリンク対応

## いつ Guidelines を使うべきか

- 一般的な原則を共有したい
- 哲学や価値観を伝えたい
- ベストプラクティスを推奨したい
- 強制は不要

例: 「型安全性を優先すべき」「テストは重要」

配置: `CLAUDE.md`（プロジェクトルートまたは `~/.claude/`）

## いつ Rules を使うべきか

- 強制可能な標準が必要
- 明確な制約を定義したい
- 違反が検出可能
- 特定のファイルパターンにスコープしたい

例: 「any 型の使用禁止」「API エンドポイントは入力検証必須」

配置: `.claude/rules/`

### `paths` frontmatter で適用範囲を限定

```yaml
---
paths:
  - "src/api/**/*.{ts,tsx}"
  - "{src,lib}/**/*.ts"
---
# API 開発ルール

- 全 API エンドポイントは入力検証必須
- 標準エラーレスポンス形式を使用
```

`paths` 省略時はルールが全ファイルに適用される。

## 詳細リファレンス

- `references/rules-system.md` - ロード順序、glob パターン、構造、アンチパターン

## リソース

- `resources/templates/rule-template.md` - ルールテンプレート
- `resources/examples/type-safety-rule.md` - 型安全性ルール例
- `resources/examples/scoped-api-rule.md` - paths スコープ例
- `resources/checklist.md` - 品質チェックリスト

## Related Skills

- cc-sdd: `.kiro/steering/` によるプロジェクトメモリ・パターン管理
- hookify プラグイン: イベント駆動の自動アクション（pre-commit フック等）
