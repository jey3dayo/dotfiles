# sync-origin スキル

現在のブランチをリモートのデフォルトブランチ（main/master/develop等）と同期し、コンフリクトを自動解決するスキル。

## 概要

このスキルは以下の機能を提供します：

- リモートのデフォルトブランチを自動検出
- merge または rebase による同期
- 段階的なコンフリクト解決（自動 + 手動）
- dry-run モードでの事前確認

## 使い方

### 基本的な使用

```
mainと同期して
最新にして
originと同期
```

### rebase での同期

```
mainをrebaseして
```

### 明示的なブランチ指定

```
developブランチと同期して
```

## トリガーキーワード

### 日本語:

- "mainと同期して"
- "最新にして"
- "originと同期"
- "デフォルトブランチから更新"

### 英語:

- "sync with origin"
- "pull main"
- "rebase on main"
- "update from main"

## 機能

### 1. デフォルトブランチの自動検出

リモートのデフォルトブランチを以下の方法で検出します：

1. `git symbolic-ref refs/remotes/origin/HEAD`
2. `git remote show origin`
3. 一般的なブランチ名のチェック（main, master, develop）

### 2. 同期処理

- **Merge（デフォルト）**: マージコミットを作成
- **Rebase（オプション）**: 履歴を一直線に保つ

### 3. コンフリクト解決

#### 自動解決

以下のファイルは自動で解決します：

- **package-lock.json, yarn.lock**: 再生成
- **自動生成ファイル**: リモートの変更を優先

#### 手動対応

コード本体のコンフリクトは、ファイル内容を確認してユーザーに相談します。

## スクリプト

### scripts/detect-default-branch.sh

リモートのデフォルトブランチを検出するBashスクリプト。

### 使用方法:

```bash
bash ~/.agents/skills/sync-origin/scripts/detect-default-branch.sh [remote-name]
```

### 例:

```bash
# originのデフォルトブランチを検出
bash ~/.agents/skills/sync-origin/scripts/detect-default-branch.sh origin

# 出力例: main
```

## エラーハンドリング

### リモートが存在しない

```
fatal: 'origin' does not appear to be a git repository
```

**対処:** リモートを追加するか、正しいリモート名を指定

### デフォルトブランチが検出できない

```
Could not detect default branch
```

**対処:** 明示的にブランチ名を指定

### コンフリクトが解決できない

自動解決できない場合は、ユーザーに解決方法を相談します。

## ベストプラクティス

1. **定期的な同期**: コンフリクトが複雑になる前に同期
2. **コミット前に同期**: 作業内容をコミットする前に最新の状態と同期
3. **rebase vs merge**:
   - 履歴をきれいに保ちたい: `--rebase`
   - マージコミットを残したい: デフォルト（merge）
4. **dry-run活用**: 大きな変更が予想される場合は事前確認

## 例

### 例1: 基本的な同期

```
ユーザー: "mainと同期して"

→ 現在のブランチ: feature/new-feature
→ デフォルトブランチを検出: main
→ git fetch origin
→ git merge origin/main
→ 完了
```

### 例2: rebaseでの同期

```
ユーザー: "mainをrebaseして"

→ git fetch origin
→ git rebase origin/main
→ コンフリクトを自動解決
→ 完了
```

### 例3: 明示的なブランチ指定

```
ユーザー: "developと同期して"

→ git fetch origin
→ git merge origin/develop
→ 完了
```

## ライセンス

このスキルは自由に使用・修正できます。
