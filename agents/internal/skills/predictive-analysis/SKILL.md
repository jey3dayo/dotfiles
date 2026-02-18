---
name: predictive-analysis
description: Predictive code analysis for identifying potential risks, anti-patterns, and future maintenance issues. Use when assessing code health or planning refactoring.
disable-model-invocation: false
user-invocable: true
allowed-tools: Read, Grep, Glob, Bash
argument-hint: [target-path]
---

# Predictive Code Analysis

コードベースを解析し、将来的に問題となる可能性のあるリスクを事前に予測・特定します。

## 概要

予測的コード分析システムは、以下のリスクカテゴリを評価します:

- 技術的負債: 複雑性の増大、保守困難なコード
- セキュリティリスク: 入力検証の不備、脆弱性パターン
- パフォーマンスボトルネック: 非効率なアルゴリズム、スケーラビリティ問題

## 基本使用例

```bash
# プロジェクト全体を分析
/predictive-analysis

# 特定ディレクトリを分析
/predictive-analysis src/

# コンポーネント単位で分析
/predictive-analysis src/components/
```

## リスク評価フレームワーク

### リスクレベル

| レベル   | 説明                                   | 対応期限               |
| -------- | -------------------------------------- | ---------------------- |
| Critical | 即座に修正が必要、プロダクションに影響 | 即座                   |
| High     | 早急な対応が必要、将来的な障害の可能性 | 1週間以内              |
| Medium   | 計画的な対応が必要、保守性に影響       | 1ヶ月以内              |
| Low      | 改善推奨、長期的な品質向上             | 次回リファクタリング時 |

### 評価基準

各リスクは以下の観点で評価されます:

1. 発生可能性 (Likelihood): この問題が実際に発生する確率
2. 影響度 (Impact): 発生した場合の被害の大きさ
3. タイムライン (Timeline): 問題が顕在化する時期の予測
4. 修正コスト (Effort): 現在修正する場合と将来修正する場合の工数比較

## 分析プロセス

### 1. パターン認識

- 問題を引き起こす一般的なコードパターンの検出
- 複雑性が増大しているホットスポットの特定
- スケール時に破綻するアンチパターンの発見
- 潜在的な時限爆弾（ハードコード値、前提条件）の識別

### 2. リスク分類

分析では以下のカテゴリに分類されます:

#### 技術的負債

- 高複雑度関数
- コード重複
- 密結合
- 変更頻度の高いファイル

#### セキュリティリスク

- 入力検証の不備
- 脆弱な認証・認可
- シークレット情報の露出
- 安全でないデータ処理

#### パフォーマンスボトルネック

- O(n²) 以上のアルゴリズム
- メモリリーク
- 非効率なクエリ
- スケーラビリティの制約

### 3. レポート生成

各予測には以下が含まれます:

- 具体的なコード位置: ファイル名、行番号、関数名
- 問題の説明: なぜ将来的に問題になるか
- 影響の見積もり: タイムラインと影響範囲
- 修正提案: 優先度付きの予防措置

## クイックスタート

### 基本的な使用フロー

1. 分析実行: 対象を指定して分析を開始
2. リスク評価: 検出された問題とリスクレベルを確認
3. 対応方針決定: 優先度に基づいて対応を計画
4. 追跡管理: Todo/Issue として管理 (オプション)

### 分析後の追跡オプション

分析完了後、以下の追跡方法を選択できます:

```
"これらの予測をどのように追跡しますか?"

1. Todo作成: 解決進捗を追跡
2. GitHub Issue作成: 詳細情報付きで Issue を生成
3. サマリーのみ: タスク作成なしで実行可能なレポートを提供
```

## 出力例

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔮 Predictive Code Analysis Report
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Critical] セキュリティリスク
📍 Location: src/auth/login.ts:45-67
⚠️ Issue: 入力検証なしでユーザー入力をSQL文字列に結合
📅 Timeline: 即座に悪用される可能性
💥 Impact: SQLインジェクション攻撃のリスク
🛠️ Mitigation: プリペアドステートメントまたはORMを使用

[High] パフォーマンスボトルネック
📍 Location: src/api/search.ts:120-145
⚠️ Issue: O(n²) のネストループでデータフィルタリング
📅 Timeline: データが1000件を超えると遅延発生
💥 Impact: レスポンスタイム 10秒超、UX低下
🛠️ Mitigation: Map/Set による O(n) アルゴリズムに変更
```

## 詳細リファレンス

より詳細な情報は以下を参照してください:

- [リスク評価フレームワーク](references/risk-assessment-framework.md): 評価基準と重要度判定の詳細
- [分析手法](references/analysis-methodology.md): 静的解析とパターン検出の実装
- [問題分類体系](references/issue-categorization.md): 技術的負債/セキュリティ/パフォーマンスの分類詳細
- [リスク軽減戦略](references/mitigation-strategies.md): カテゴリ別の対策パターン

## 実用例

実際のプロジェクトでの使用例:

- [リスクレポート例](examples/risk-report-examples.md): 実際の分析レポートと対応例
- [プロジェクト別分析](examples/project-specific-analysis.md): フレームワーク/言語別の分析パターン
- [予防措置の提案](examples/preventive-measures.md): 具体的な予防策と実装例

## 依存関係

- project-detector: プロジェクト種別の自動判定
- MCP Serena: コード構造解析と依存関係追跡

## 重要な注意事項

本スキルは以下を行いません:

- AI による生成である旨の署名やウォーターマークの追加
- リポジトリの設定や権限の変更
- 許可なく自動的にコードを修正

すべての提案は人間によるレビューと承認を前提としています。
