---
name: implementation-engine
description: Smart feature implementation with session persistence and project architecture adaptation. Use when implementing features from URLs/files/descriptions, resuming work, or verifying implementations.
argument-hint: [source|resume|finish|verify]
disable-model-invocation: true
user-invocable: true
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, WebFetch
---

# Implementation Engine

スマートな機能実装エンジン。プロジェクトアーキテクチャに完全適応し、セッション永続化で中断・再開を自由に管理します。

## 概要

Implementation Engineは、あらゆるソース（URL、ローカルファイル、説明文）から機能を実装し、プロジェクトのコード規約・アーキテクチャパターンに自動適応します。セッション管理により、作業を中断しても正確に継続できます。

## Session Intelligence

### セッション管理の仕組み

セッションファイルは**現在のプロジェクトディレクトリ**の `implement/` フォルダに格納されます（HOMEディレクトリや親ディレクトリではありません）。

```
<project-root>/
└── implement/
    ├── plan.md          # 実装計画と進捗
    └── state.json       # セッション状態とチェックポイント
```

### 自動レジューム

- `/implement` 実行時、`implement/` ディレクトリが存在すれば自動的に前回の続きから再開
- 新規実装の場合は自動的にディレクトリとファイルを作成

### セッション操作コマンド

```bash
/implement                  # 自動検出してレジュームまたは新規開始
/implement resume           # 明示的にレジューム
/implement status           # 進捗確認
/implement new [source]     # 新規セッション開始（既存を無視）
```

## 6-Phase Execution Framework

Implementation Engineは以下の6フェーズを順守して実装を進めます:

### Phase 1: Initial Setup & Analysis

### 必須の初期ステップ

1. `implement/` ディレクトリの存在確認（current working directory内）
2. セッションファイル検出（`state.json`, `plan.md`）
3. セッションが存在する場合はレジューム、ない場合は新規作成
4. 実装開始前に完全な分析を実施

### ソース検出

- Web URLs（GitHub、GitLab、CodePen、JSFiddle、ドキュメントサイト）
- ローカルパス（ファイル、フォルダ、既存コード）
- 実装プラン（チェックリスト付き.mdファイル）
- 機能説明文（リサーチ用）

### プロジェクト理解

- アーキテクチャパターン（Glob/Readで分析）
- 既存の依存関係とバージョン
- コード規約と確立されたパターン
- テスト手法と品質基準

### Phase 2: Strategic Planning

### 計画作成

- ソース機能をプロジェクトアーキテクチャにマッピング
- 依存関係の互換性を識別
- 統合アプローチの設計
- テスト可能な単位に分割

### `implement/plan.md` フォーマット

```markdown
# Implementation Plan - [timestamp]

## Source Analysis

- **Source Type**: [URL/Local/Description]
- **Core Features**: [実装する機能]
- **Dependencies**: [必要なライブラリ/フレームワーク]
- **Complexity**: [推定工数]

## Target Integration

- **Integration Points**: [接続箇所]
- **Affected Files**: [変更/作成するファイル]
- **Pattern Matching**: [プロジェクトスタイルへの適応方法]

## Implementation Tasks

[優先順位付きチェックリスト]

## Validation Checklist

- [ ] All features implemented
- [ ] Tests written and passing
- [ ] No broken functionality
- [ ] Documentation updated
- [ ] Integration points verified
- [ ] Performance acceptable

## Risk Mitigation

- **Potential Issues**: [識別されたリスク]
- **Rollback Strategy**: [git checkpoints]
```

### Phase 3: Intelligent Adaptation

### 依存関係解決

- ソースライブラリを既存のものにマッピング
- 重複を避けて既存ユーティリティを再利用
- パターンをコードベースに合わせて変換
- 非推奨のアプローチを最新の標準に更新

### コード変換

- 命名規則を統一
- エラーハンドリングパターンを踏襲
- 状態管理アプローチを維持
- テストスタイルを保持

### 大規模リポジトリ対応

スマートサンプリングを使用:

- コア機能を優先（主要機能、クリティカルパス）
- 必要に応じてサポートコードを取得
- 生成ファイル、テストデータ、ドキュメントをスキップ
- 実装コードに集中

### Phase 4: Implementation Execution

### 実行プロセス

1. コア機能の実装
2. サポートユーティリティの追加
3. 既存コードとの統合
4. 新機能をカバーするテストの更新
5. すべてが正しく動作することを検証

### 進捗トラッキング

- `implement/plan.md` を各項目完了時に更新
- `implement/state.json` にチェックポイントを記録
- 論理的なポイントで意味のあるgitコミットを作成

### Phase 5: Quality Assurance

### 検証ステップ

- 既存のlintコマンドを実行
- テストスイートを実行
- 型エラーをチェック
- 統合ポイントを検証
- リグレッションがないことを確認

### Phase 6: Implementation Validation

### 統合分析

1. **Coverage Check** - 計画されたすべての機能が実装されているか検証
2. **Integration Points** - すべての接続が機能するか検証
3. **Test Coverage** - 新しいコードがテストされているか確認
4. **TODO Scan** - 残っているTODOを発見
5. **Documentation** - ドキュメントが変更を反映しているか確認

### 検証レポート形式

```
IMPLEMENTATION VALIDATION
├── Features Implemented: 12/12 (100%)
├── Integration Points: 8/10 (2 pending)
├── Test Coverage: 87%
├── Build Status: Passing
└── Documentation: Needs update

PENDING ITEMS:
- [未完了項目のリスト]

ENHANCEMENT OPPORTUNITIES:
1. [改善機会のリスト]
```

## Deep Validation Process

### すべての検証コマンド（`finish`, `verify`, `complete`, `enhance`）は同じ包括的プロセスを実行します

いずれかのコマンドを実行すると、以下が自動的に実行されます:

1. **Deep Original Source Analysis** - 元のコード/要件のあらゆる側面を徹底分析
2. **Requirements Verification** - 現在の実装と元の要件を比較
3. **Comprehensive Testing** - すべての新規コードに対するテスト作成
4. **Deep Code Analysis** - 不完全なTODO、ハードコード値、エラーハンドリングをチェック
5. **Automatic Refinement** - 失敗したテストの修正、部分的実装の完成
6. **Integration Analysis** - 統合ポイントの徹底分析
7. **Completeness Report** - 機能カバレッジ、テストカバレッジ、パフォーマンスベンチマークを報告

### 結果

## Execution Guarantee

### ワークフローは常にこの順序に従います

1. **Setup session** - 状態ファイルを最初に作成/ロード
2. **Analyze source & target** - 完全な理解
3. **Write plan** - `implement/plan.md` に完全な実装計画を記述
4. **Show plan** - 実装前に計画概要を提示
5. **Execute systematically** - 計画に従って更新しながら実行
6. **Validate integration** - 要求時に検証を実行

### 以下は決して行いません

- 書面計画なしで実装を開始
- ソースまたはプロジェクト分析をスキップ
- セッションファイル作成をバイパス
- 計画を示す前にコーディングを開始
- コミット、PR、git関連コンテンツで絵文字を使用

## 使用例

### 単一ソース

```bash
/implement https://github.com/user/feature
/implement ./legacy-code/auth-system/
/implement "Stripeのような決済処理"
```

### 複数ソース

```bash
/implement https://github.com/projectA ./local-examples/
```

### セッション再開

```bash
/implement              # 自動検出してレジューム
/implement resume       # 明示的にレジューム
/implement status       # 進捗確認
```

### Deep Validationコマンド

```bash
/implement finish       # 徹底的なテストと検証で完成
/implement verify       # 要件に対する深い検証
/implement complete     # 100%の機能完全性を保証
/implement enhance      # 実装を洗練・最適化
```

## 詳細リファレンス

より詳細な情報が必要な場合は、以下のリファレンスファイルを参照してください:

- **Phase-by-Phase Guide** (`references/phase-by-phase-guide.md`) - 6フェーズの詳細手順
- **Session Management** (`references/session-management.md`) - plan.md/state.json管理詳細
- **Deep Validation Process** (`references/deep-validation-process.md`) - Deep Validation 7ステップ
- **Adaptation Patterns** (`references/adaptation-patterns.md`) - 依存関係解決・コード変換パターン
- **Source Detection** (`references/source-detection.md`) - Web/Local/説明文判定ロジック
- **Implementation Workflows** (`examples/implementation-workflows.md`) - 実装ワークフロー実例
- **Risk Mitigation** (`examples/risk-mitigation.md`) - Rollback戦略・git checkpoint

## 依存関係

- **project-detector** - プロジェクト構造の自動検出（参照のみ、軽依存）

## トリガーキーワード

- implementation, implement, 実装
- feature development, 機能開発
- code migration, コード移行
- adapt code, コード適応
- resume implementation, 実装再開
- validate implementation, 実装検証
