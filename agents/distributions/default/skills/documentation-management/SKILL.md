---
name: documentation-management
description: Intelligent project documentation manager with AI-driven content generation and link validation. Use when creating/updating documentation or fixing documentation issues.
disable-model-invocation: true
user-invocable: true
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
argument-hint: [create|update|fix] [target]
---

# Documentation Management

AI駆動のインテリジェント・ドキュメント管理システム。プロジェクト構造を分析し、適切なドキュメントを自動生成・更新します。

## 概要

このスキルは、プロジェクトの実態を理解し、すべての関連ドキュメントを包括的に管理します。

**主要機能**:

- **AI駆動プロジェクト分析**: コードベース全体を解析し、ドキュメント化すべき内容を特定
- **Progressive Disclosure戦略**: 読者に必要な情報を段階的に提供
- **構造化ドキュメント生成**: 一貫性のある構造でドキュメントを作成
- **スマート更新**: 変更内容を理解し、影響を受けるすべてのドキュメントを更新
- **リンク検証**: ドキュメント内リンクの整合性チェック（今後統合予定）

## 基本使用法

### Mode 1: ドキュメント概要分析

```bash
/documentation
```

プロジェクト内のすべてのドキュメントを分析し、カバレッジを報告します。

**出力例**:

```
DOCUMENTATION OVERVIEW
├── README.md - [status: current]
├── CHANGELOG.md - [last updated: 2024-01-15]
├── docs/
│   ├── API.md - [outdated: 3 new endpoints]
│   └── architecture.md - [incomplete: 65%]
└── Total coverage: 78%

KEY FINDINGS
- Missing: Setup instructions
- Outdated: API endpoints (3 new ones)
- Incomplete: Testing guide
```

### Mode 2: スマート更新

```bash
/documentation update
```

コードベースの実態とドキュメントを比較し、必要な更新を実施します。

**実行内容**:

1. プロジェクト構造を分析（project-detector使用）
2. コードベースの実態を理解（MCP Serena使用）
3. ドキュメントと実態のギャップを特定
4. 体系的に更新:
   - README.md: 新機能・変更点
   - CHANGELOG.md: バージョンエントリ
   - API docs: 新エンドポイント
   - Configuration docs: 新オプション
   - Migration guides: 破壊的変更がある場合

### Mode 3: セッション・ドキュメンテーション

```bash
/documentation session
```

長時間のコーディングセッション後、会話履歴を分析してドキュメントを更新します。

**実行内容**:

- 会話履歴から変更内容を抽出
- feature/fix/enhancement でグループ化
- プロジェクトスタイルに従って適切なドキュメントを更新

### Mode 4: コンテキスト自動判定

セッション内容に応じて自動的に適切なドキュメントを更新:

| セッション内容     | 更新ドキュメント                   |
| ------------------ | ---------------------------------- |
| 新機能追加         | README features, CHANGELOG         |
| バグ修正           | CHANGELOG, troubleshooting         |
| リファクタリング   | architecture docs, migration guide |
| セキュリティ修正   | security policy, CHANGELOG         |
| パフォーマンス改善 | benchmarks, CHANGELOG              |

## ドキュメント戦略

### Progressive Disclosure アプローチ

読者の理解レベルに応じて情報を段階的に提供:

**レイヤー1: 概要（SKILL.md）**

- 10-15%のコンテンツ
- 基本概念と使用例
- クイックスタート

**レイヤー2: 詳細仕様（references/）**

- 40-50%のコンテンツ
- 技術詳細と実装ガイド
- API仕様とアーキテクチャ

**レイヤー3: 実用例（examples/）**

- 30-40%のコンテンツ
- プロジェクト固有の例
- ワークフローパターン

詳細: [references/documentation-strategy.md](references/documentation-strategy.md)

### 構造化アプローチ

```
project/
├── README.md              # プロジェクト概要（Progressive Disclosureのエントリポイント）
├── CHANGELOG.md          # 変更履歴
├── CONTRIBUTING.md       # コントリビューションガイド
└── docs/
    ├── getting-started.md  # 初学者向け
    ├── api/               # API詳細
    ├── guides/            # チュートリアル
    └── reference/         # リファレンス
```

## スマート・ドキュメント・ルール

### 必ず実施すること

1. **既存ドキュメントを完全に読む**: 更新前に現在の内容を理解
2. **適切なセクションを特定**: 正確な更新箇所を見つける
3. **インプレース更新**: 重複を作らず既存セクションを更新
4. **カスタムコンテンツの保持**: ユーザーの手動追加内容を保護
5. **スタイルの継承**: 既存のフォーマットに従う

### カスタムコンテンツ保護

```markdown
<!-- CUSTOM:START -->

ユーザーが手動で追加したコンテンツ
この部分は自動更新から保護される

<!-- CUSTOM:END -->
```

### CHANGELOG管理

- **変更をタイプ別にグループ化**: Added, Changed, Fixed, Removed
- **バージョンバンプの提案**: major/minor/patchを判定
- **PR/Issueへのリンク**: 関連する議論への参照
- **時系列順の維持**: 最新が最上部

## クイックスタート

### 新規プロジェクトのドキュメント作成

```bash
# 1. プロジェクト分析とドキュメント生成
/documentation create

# 2. 生成されたドキュメントをレビュー
/documentation review

# 3. 必要に応じて調整
/documentation update README.md
```

### 既存プロジェクトのドキュメント改善

```bash
# 1. 現状分析
/documentation analyze

# 2. ギャップ特定
/documentation gaps

# 3. 一括更新
/documentation update --all
```

### コマンド統合

他のコマンドとシームレスに連携:

```bash
# コード理解 → ドキュメント更新
/understand && /documentation

# テスト実行 → カバレッジ更新
/test && /documentation

# リファクタリング → アーキテクチャドキュメント更新
/refactor && /documentation
```

## 依存関係

### 必須

- **project-detector**: プロジェクトタイプとスタック判定
- **MCP Serena**: コード構造解析とシンボル検索

### オプション

- **docs-index**: 大規模ドキュメントセットのインデックス化
- **markdown-docs**: ドキュメント品質評価

## ドキュメントタイプ

管理可能なドキュメント種別:

- **API Documentation**: エンドポイント、パラメータ、レスポンス
- **Database Schema**: テーブル、リレーション、マイグレーション
- **Configuration**: 環境変数、設定
- **Deployment**: セットアップ、要件、手順
- **Troubleshooting**: よくある問題と解決策
- **Performance**: ベンチマーク、最適化ガイド
- **Security**: ポリシー、ベストプラクティス

## 詳細リファレンス

### 技術仕様

- [ドキュメント戦略](references/documentation-strategy.md) - Progressive Disclosure、構造化アプローチ
- [AI駆動分析](references/ai-driven-analysis.md) - プロジェクト構造分析、コンテンツ生成
- [リンク検証](references/link-validation.md) - リンク検証ルール、自動修正（今後統合）
- [コンテンツ生成パターン](references/content-generation-patterns.md) - セクション別生成パターン

### 実用例

- [プロジェクト固有ドキュメント](examples/project-specific-docs.md) - プロジェクト種別ごとの例
- [ドキュメントワークフロー](examples/documentation-workflows.md) - 作成/更新/修正ワークフロー
- [修正パターン集](examples/fix-patterns.md) - ドキュメント修正パターン（今後統合）

## 注意事項

### 絶対にしないこと

- 既存ドキュメントの削除
- カスタムセクションの上書き
- ドキュメントスタイルの大幅変更
- AI属性マーカーの追加
- 不要なドキュメントの作成

### 実行前の確認

更新実行前に確認を求めます:

- すべての古いドキュメントを更新する
- 特定のファイルに焦点を当てる
- 不足しているドキュメントを作成する
- マイグレーションガイドを生成する
- 特定セクションをスキップする

## 品質チェック

- **Doc Coverage**: 未ドキュメント機能を報告
- **Freshness Check**: 古いドキュメントにフラグ
- **Consistency**: スタイルの統一性を確保
- **Completeness**: すべてのセクションの存在確認
- **Accuracy**: ドキュメントと実装の比較

---

**Token効率**: このProgressive Disclosure構造により、初回ロード時のトークン使用量を約90%削減。詳細情報は必要時のみロード。
