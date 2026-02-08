---
name: cc-sdd
description: |
  [What] Claude Code Spec-Driven Development (cc-sdd) plugin. Kiro形式のスペック駆動開発を実現する。設定可能なディレクトリ構造とカスタマイズ可能なワークフローを提供。
  [When] Use when: users mention "kiro", "spec-driven", "specification", "steering", kiro commands (/kiro:spec-init, /kiro:spec-design), "cc-sdd", or "スペック駆動開発". 新機能開発で仕様駆動アプローチが適切な場合に最適。プロジェクトガイダンス(Steering)、仕様作成(Specification)、進捗管理のワークフローを提供する。
  [Keywords] kiro, spec-driven, specification, steering, cc-sdd, スペック駆動開発
---

# Claude Code Spec-Driven Development (cc-sdd)

## 概要

cc-sdd (Claude Code Spec-Driven Development) は、Kiro形式のスペック駆動開発を実現するプラグインです。開発を始める前に仕様を定義し、段階的に承認を経ながら実装を進めることで、品質の高い開発プロセスを実現します。

### 主な特徴

- **設定可能なディレクトリ構造**: `.kiro-config.json` でパスをカスタマイズ
- **標準化されたワークフロー**: デフォルト設定で即座に利用可能
- **Progressive Disclosure**: 詳細情報は必要時にロード
- **マルチプロジェクト対応**: プロジェクトごとに異なる設定を使用可能

## いつ使うか

以下のような場合にこのプラグインを使用する:

- ユーザーが cc-sdd やスペック駆動開発のコマンドを要求した時
- `/kiro:` で始まるコマンドの実行時
- 新機能開発で仕様駆動アプローチが適切な場合
- プロジェクトのガイドラインや技術基準を整備したい時
- 要件定義から設計、実装までの一貫したワークフローが必要な時

## 設定システム

### 設定ファイルの解決順序

1. **プロジェクト固有**: プロジェクトルートの `.kiro-config.json`
2. **ユーザーレベル**: `~/.config/kiro/config.json` (オプション)
3. **デフォルト**: ビルトインのデフォルト設定

### デフォルト構成

```json
{
  "version": "1.0.0",
  "paths": {
    "root": ".kiro",
    "steering": "steering",
    "specs": "specs",
    "settings": "settings",
    "templates": "templates",
    "rules": "rules"
  },
  "workflow": {
    "defaultLanguage": "ja",
    "autoApproval": false
  }
}
```

### カスタマイズ例

```json
{
  "version": "1.0.0",
  "paths": {
    "root": "docs/specs",
    "steering": "guidelines",
    "specs": "features"
  }
}
```

詳細は `@config-loader.md` を参照。

## プロジェクト構成

### ディレクトリ構造（デフォルト）

```
.kiro/
├── steering/           # プロジェクト全体のガイドとコンテキスト
│   ├── product.md
│   ├── tech.md
│   └── structure.md
├── specs/              # 個別機能の開発プロセス
│   └── [feature-name]/
│       ├── spec.json
│       ├── requirements.md
│       ├── design.md
│       └── tasks.md
└── settings/           # 設定とテンプレート
    ├── templates/
    └── rules/
```

### Steering vs Specification

| 項目         | Steering                 | Specification          |
| ------------ | ------------------------ | ---------------------- |
| **目的**     | プロジェクト全体のガイド | 個別機能の開発プロセス |
| **スコープ** | 全体的・横断的           | 機能単位               |
| **更新頻度** | プロジェクト変更時       | 機能開発ごと           |

## 基本ワークフロー

cc-sdd は 3つのフェーズで構成される:

### Phase 0: Steering (オプショナル)

プロジェクト全体のガイダンスを作成・更新

- コアステアリングファイルの管理
- カスタムステアリングの作成

新機能や小規模な追加の場合はスキップ可能。spec-init から直接開始できる。

### Phase 1: Specification Creation

仕様を段階的に作成し、各段階で承認を得る

1. **初期化**: 仕様の基本構造を作成
2. **要件定義**: EARS形式で要件を生成
3. **技術設計**: 要件に基づいて設計を作成
4. **タスク生成**: 実装タスクを生成

### Phase 2: Progress Tracking

進捗状況の確認

- 現在の進捗とフェーズを確認
- 品質メトリクスの評価
- ステアリング整合性のチェック

## 開発ルール

1. **設定の活用**: プロジェクトに適した設定を定義
2. **3段階承認ワークフロー**: Requirements → Design → Tasks → Implementation
3. **承認必須**: 各フェーズで人間のレビューが必要
4. **フェーズスキップ禁止**: 前フェーズの承認が必須
5. **タスクステータス更新**: 作業時にタスクを完了としてマーク
6. **Steeringの最新化**: 重要な変更後に更新

## 詳細情報

Progressive Disclosureモデルを採用。詳細は以下のリファレンスドキュメントを必要時にロード:

- **@workflow.md** - 完全なワークフロー詳細とフェーズ説明
- **@steering-system.md** - Steeringシステムの詳細
- **@specification-system.md** - Specificationシステムの詳細
- **@commands-reference.md** - 全コマンドのリファレンス
- **@development-rules.md** - 開発ルールの詳細説明
- **@ears-format.md** - EARS形式の要件定義ガイド
- **@config-loader.md** - 設定システムの詳細

## インテリジェント・ルーター

このプラグインが呼び出された時の動作:

### Step 1: 設定の読み込み

1. **プロジェクト設定の確認**: `.kiro-config.json` の読み込み
2. **デフォルトとマージ**: 未設定項目はデフォルト値を使用
3. **パス解決**: 相対パスを絶対パスに変換

### Step 2: ユーザー意図の分析

ユーザーの発言から意図を判定し、適切なコマンドにルーティング:

```
"新機能" / "仕様を作る"        → /kiro:spec-init
"要件" / "requirements"        → /kiro:spec-requirements
"設計" / "design"              → /kiro:spec-design
"タスク" / "実装計画"          → /kiro:spec-tasks
"進捗" / "状態確認"            → /kiro:spec-status
```

### Step 3: プロジェクト状態の確認

設定されたディレクトリの内容を調査:

1. **Steering存在確認**: ステアリングファイルの有無
2. **既存Spec確認**: 仕様ディレクトリの一覧と状態
3. **次のアクション判定**: 現在のフェーズと実行可能なコマンド

### Step 4: コマンド実行とガイダンス

1. **実行前の説明**: 実行するコマンドとその理由を説明
2. **コマンド実行**: 適切な引数を渡してコマンドを呼び出し
3. **実行後のガイダンス**: 次のステップを提案

## コマンド一覧

### Steering管理

- `/kiro:steering` - コアステアリングファイルの管理
- `/kiro:steering-custom` - カスタムステアリングの作成

### Specification管理

- `/kiro:spec-init [description]` - 新規仕様の初期化
- `/kiro:spec-requirements [feature]` - 要件定義の生成
- `/kiro:spec-design [feature] [-y]` - 技術設計の作成
- `/kiro:spec-tasks [feature] [-y]` - 実装タスクの生成
- `/kiro:spec-status [feature]` - 進捗状況の確認

### 検証ツール

- `/kiro:validate-gap [feature]` - 実装ギャップの分析
- `/kiro:validate-design [feature]` - 設計の検証
- `/kiro:validate-impl [feature]` - 実装の検証

### 高速化ツール

- `/kiro:spec-quick [description]` - インタラクティブまたは自動モード

## 初期セットアップ

### 新規プロジェクトの場合

1. **設定ファイルのコピー**: `.kiro-config.default.json` を `.kiro-config.json` としてコピー
2. **ディレクトリ構造の作成**: `.kiro-default/` の内容をプロジェクトにコピー
3. **カスタマイズ**: 必要に応じて設定を調整

### 既存プロジェクトの場合

1. **現在の構造を維持**: `.kiro-config.json` で現在のパスを定義
2. **段階的移行**: 必要に応じて新しい構造に移行

## ガイドライン

開発時は以下を考慮する:

- **英語で思考、日本語で回答**: 思考プロセスは英語で、生成する回答は日本語で行う
- **段階的アプローチ**: 各フェーズを完了してから次に進む
- **人間のレビュー**: 自動化できても、重要な決定には人間の承認を求める
- **ドキュメントファースト**: コードを書く前に仕様を明確にする
- **設定の尊重**: プロジェクト固有の設定に従う

## マイグレーション

既存のcc-sddプロジェクトからの移行:

1. **現在の構造を確認**: 既存の `.kiro/` ディレクトリの構造を調査
2. **設定ファイルを生成**: 現在の構造に合わせた `.kiro-config.json` を作成
3. **動作確認**: コマンドが正しく動作することを確認
4. **必要に応じて再構成**: より良い構造に段階的に移行

詳細は `MIGRATION.md` を参照。
