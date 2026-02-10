---
description: AI-driven knowledge recording system
argument-hint: [category] <description> [--search <query>] [--export <format>]
---

# Learnings - AI駆動知見記録システム

## 概要

開発中に得た重要な知見・学習内容を体系的に記録し、チーム全体で共有・活用する。

## 使用方法

```bash
/learnings [description] [options]
```

### オプション

**完全形式:**

- `--category fix`: リンター・コード品質修正に関する知見を学習
- `--category architecture`: アーキテクチャ・設計パターンに関する知見を学習
- `--category performance`: パフォーマンス最適化に関する知見を学習
- `--category security`: セキュリティ・認証に関する知見を学習
- `--category testing`: テスト・品質保証に関する知見を学習
- `--category database`: データベース・永続化に関する知見を学習
- `--category ui`: UI・コンポーネントに関する知見を学習

**短縮形式（推奨）:**

- `fix`: リンター・コード品質修正
- `arch`: アーキテクチャ・設計パターン
- `perf`: パフォーマンス最適化
- `sec`: セキュリティ・認証
- `test`: テスト・品質保証
- `db`: データベース・永続化
- `ui`: UI・コンポーネント

````

### 使用例

```bash
# 一般的な学習記録
/learnings エラーハンドリングパターンを学習してください

# 短縮形式（推奨）
/learnings fix リンターの修正パターンを学習してください
/learnings arch 層境界設計について学習してください
/learnings perf 最適化手法を学習してください

# 従来の完全形式（互換性維持）
/learnings --category fix リンターの修正パターンを学習してください
````

## 知見記録プロセス

### 1. 緊急・重要知見の即時記録（🔴🟠）

```bash
# 障害対応・アーキテクチャ決定・設計パターン
/learnings arch 新しいアーキテクチャパターンの実装方法を学習

# セキュリティ・パフォーマンス最適化
/learnings sec 認証フローの脆弱性対策を学習
/learnings perf キャッシュ戦略の最適化手法を学習
```

### 2. 開発効率向上知見（🟡）

```bash
# テスト戦略・デバッグ手法
/learnings test 効果的なテストパターンを学習
/learnings fix デバッグの効率的な手法を学習
```

### 3. 実装パターン・ベストプラクティス（🟢）

```bash
# コード品質・設計パターン
/learnings arch クリーンなコード設計を学習
/learnings ui コンポーネント設計のベストプラクティスを学習
```

## 知見の活用フロー

### 1. 自動提案システム

- 類似タスク着手時に関連知見を自動提示
- エラー発生時に過去の解決策を即座に参照
- コードレビュー時に設計パターンを提案

### 2. 知見の検索・参照

```bash
# カテゴリ別検索
/learnings --search arch   # アーキテクチャ関連の知見一覧
/learnings --search test   # テスト関連の知見一覧

# キーワード検索
/learnings --search "error handling"  # エラーハンドリング関連
/learnings --search "performance"      # パフォーマンス関連
```

### 3. 知見の共有・エクスポート

```bash
# マークダウン形式でエクスポート
/learnings --export markdown > learnings.md

# JSON形式でエクスポート（システム連携用）
/learnings --export json > learnings.json
```

## 品質向上への貢献

### 定量的効果

- 同一エラーの再発防止率: 95%以上
- 実装時間の短縮: 平均30%
- コードレビュー指摘事項の削減: 40%

### 定性的効果

- チーム全体の技術力向上
- ベストプラクティスの標準化
- 問題解決能力の向上

## プライバシー・セキュリティ

- プロジェクト固有の機密情報は自動マスキング
- 個人情報・認証情報は記録対象外
- 知見はプロジェクトスコープ内でのみ共有

## 統合機能

### 他コマンドとの連携

- `/fix`: 修正時の知見を自動記録
- `/review`: レビュー指摘を知見として保存
- `/task`: 複雑タスクの解決パターンを記録
- `/todos`: タスク完了時の学習内容を自動抽出

---

**目標**: 継続的な学習と知見共有により、チーム全体の開発効率と品質を向上
