# コマンド統合 移行ガイド

2025年10月の統合により、複数のコマンドが統合され、より使いやすくなりました。

## 📋 変更サマリー

### 統合されたコマンド

| 旧コマンド     | 新コマンド         | 変更内容                 |
| -------------- | ------------------ | ------------------------ |
| `/refactoring` | `/refactor`        | セッション管理機能を追加 |
| `/fix-review`  | `/review --fix-pr` | `/review`に統合          |

### 新規追加された機能

- **共通ライブラリ**: `commands/shared/`に再利用可能なユーティリティ
- **新規スキル**: `refactoring-engine`, `pr-review-automation`
- **セッション管理**: `/refactor`でリファクタリング進捗を保存・再開可能

## 🔄 移行手順

### 1. `/refactoring` → `/refactor`

#### 基本的な使用方法

```bash
# 旧コマンド
/refactoring src/services/user-service.ts

# 新コマンド（同じ結果）
/refactor src/services/user-service.ts
```

#### 新機能の活用

```bash
# セッション管理（新機能）
/refactor src/services/           # 初回実行
/refactor resume                  # 後で再開
/refactor status                  # 進捗確認
/refactor validate                # 完全検証

# オプションはほぼ同じ
/refactor --analyze               # 分析のみ
/refactor --layer service         # 特定層にフォーカス
/refactor --pattern result-pattern # 特定パターン適用
```

#### 変更点

**セッションファイル**:

```
refactor/
  ├── plan.md          # リファクタリング計画
  ├── state.json       # 現在の状態
  └── original-analysis.md  # 元コードの分析
```

**新しいワークフロー**:

1. 初回実行でセッション作成
2. 中断しても`/refactor resume`で再開可能
3. 進捗は自動保存

### 2. `/fix-review` → `/review --fix-pr`

#### 基本的な使用方法

```bash
# 旧コマンド
/fix-review 123

# 新コマンド
/review --fix-pr 123
```

#### 新機能の活用

```bash
# 現在のブランチのPRを自動検出
/review --fix-pr

# 優先度フィルター
/review --fix-pr --priority critical

# 特定ボットのコメントのみ
/review --fix-pr --bot coderabbitai

# カテゴリフィルター
/review --fix-pr --category security,bug

# ドライラン
/review --fix-pr --dry-run
```

詳細は旧コマンド移行ガイドを参照してください。

---

**最終更新**: 2025-10-21
**バージョン**: 2.0.0
