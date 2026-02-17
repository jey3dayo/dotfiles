# ドキュメントワークフロー

作成/更新/修正の実践的ワークフロー。

## 新規プロジェクトのドキュメント作成

### ワークフロー

```bash
# 1. プロジェクト分析
/documentation analyze

# 2. 基本ドキュメント作成
/documentation create

# 3. 生成されたドキュメントをレビュー
# - README.md
# - CHANGELOG.md
# - docs/getting-started.md

# 4. 必要に応じて調整
/documentation update README.md
```

### 生成される基本ドキュメント

- README.md: プロジェクト概要
- CHANGELOG.md: 変更履歴
- docs/getting-started.md: 初学者向けガイド
- docs/api.md: API仕様（該当する場合）
- docs/configuration.md: 設定オプション

## 既存ドキュメントの更新

### セッション後の更新

```bash
# 長時間コーディングセッション後
/documentation session
```

実行内容:

1. 会話履歴から変更内容を抽出
2. feature/fix/enhancement でグループ化
3. 影響を受けるドキュメントを特定
4. 体系的に更新

### 機能追加後の更新

```bash
# 新機能実装後
/documentation update
```

実行内容:

1. コードベースをスキャン
2. 新しいエクスポート/APIを検出
3. README, API docs, CHANGELOG を更新

## ドキュメント修正

### リンク検証と修正

```bash
# リンク検証
/documentation validate-links

# 自動修正
/documentation fix-links
```

実行内容:

1. すべての内部リンクを検証
2. 壊れたリンクを検出
3. 類似ファイルを検索して自動修正

### 品質改善

```bash
# ドキュメント品質チェック
/documentation quality-check

# 改善提案
/documentation improve
```

## コマンド統合ワークフロー

### テスト → ドキュメント更新

```bash
# テスト実行とドキュメント更新
/test && /documentation update docs/testing.md
```

### リファクタリング → アーキテクチャ更新

```bash
# リファクタリング後
/documentation update docs/architecture.md
```

### レビュー → ドキュメント修正

```bash
# コードレビュー後
/review && /documentation
```

## 継続的メンテナンス

### 週次レビュー

```bash
# 週に1回実行
/documentation overview
/documentation gaps
```

### リリース前チェック

```bash
# リリース前に実行
/documentation validate-links
/documentation update CHANGELOG.md
/documentation quality-check
```

詳細な技術仕様は [references/](../references/) ディレクトリを参照。
