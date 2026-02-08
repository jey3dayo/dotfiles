---
name: sync-origin
description: |
  現在のブランチをリモートのデフォルトブランチ（main/master/develop等）と同期し、
  コンフリクトを自動解決する。"mainと同期して"、"最新にして"、"originと同期"、
  "sync with origin"、"pull main"、"rebase on main"、"update from main" などで起動。
metadata:
  short-description: Sync current branch with remote default branch
---

# Sync Origin

## Overview

現在のブランチをリモートのデフォルトブランチと同期し、コンフリクトがあれば自動解決を試みるスキル。デフォルトブランチの自動検出、merge/rebase選択、段階的なコンフリクト解決をサポートします。

## Trigger Conditions

以下のようなリクエストで起動します：

### 日本語:

- "mainと同期して"
- "最新にして"
- "originと同期"
- "デフォルトブランチから更新"
- "main/master/developからpull"

### 英語:

- "sync with origin"
- "pull main"
- "rebase on main"
- "update from main"
- "sync current branch with default"

## Workflow

### 1. 事前確認

作業を開始する前に、以下を確認します：

```bash
# 現在のブランチを確認
git branch --show-current

# 作業ツリーの状態を確認
git status --short

# 未コミットの変更がある場合は警告
```

### 未コミットの変更がある場合:

- ユーザーに確認を求める
- オプション提示: stash、commit、または作業を中断

### 2. デフォルトブランチの検出

リモートのデフォルトブランチを自動検出します：

```bash
# バンドルされたスクリプトを使用
bash ~/.agents/skills/sync-origin/scripts/detect-default-branch.sh [remote-name]
```

### 検出方法（優先順）:

1. `git symbolic-ref refs/remotes/origin/HEAD`
2. `git remote show origin | grep "HEAD branch"`
3. 一般的なブランチ名のチェック（main, master, develop）

### 明示的な指定:

ユーザーが `--base <branch>` を指定した場合は、その値を優先します。

### 3. リモートからFetch

最新の情報を取得します：

```bash
git fetch origin
```

### 4. 同期処理

#### 4.1 Merge（デフォルト）

```bash
git merge origin/<default-branch>
```

#### 4.2 Rebase（`--rebase` オプション使用時）

```bash
git rebase origin/<default-branch>
```

### 5. コンフリクト解決

コンフリクトが発生した場合、以下の段階的な解決を試みます：

#### 5.1 自動解決可能なケース

以下のケースは自動で解決します：

- **ours/theirs戦略が明確な場合:**
  - ドキュメントファイル（README.md等）: ours優先
  - 設定ファイル（package-lock.json等）: 再生成
  - 自動生成ファイル: theirs優先

```bash
# 例: package-lock.json のコンフリクト
git checkout --theirs package-lock.json
npm install  # 再生成
git add package-lock.json
```

#### 5.2 手動対応が必要なケース

コード本体のコンフリクトなど、自動解決できない場合：

1. コンフリクトファイルのリストを提示
2. 各ファイルの内容を確認
3. ユーザーに解決方法を相談

```bash
# コンフリクトファイルのリスト
git diff --name-only --diff-filter=U

# 各ファイルの詳細
git diff <file>
```

### 提示する選択肢:

- ファイルごとに内容を確認して手動マージ
- `git checkout --ours <file>` で現在の変更を維持
- `git checkout --theirs <file>` でリモートの変更を採用
- マージを中断 (`git merge --abort` または `git rebase --abort`)

### 6. 完了確認

同期が完了したら、状態を確認します：

```bash
# 最終状態の確認
git status

# ログの確認（直近の変更）
git log --oneline -10

# リモートとの差分確認
git log HEAD..origin/<default-branch> --oneline
```

## Options

### `--base <branch>`

同期対象のブランチを明示的に指定します。

```bash
# 使用例
"developブランチと同期して" + --base develop
```

### `--rebase`

merge の代わりに rebase を使用します。

```bash
# 使用例
"mainをrebaseして" + --rebase
```

### `--dry-run`

実際の操作を行わず、何が起こるかを確認します。

```bash
# 実行内容の確認
git fetch origin
git merge-base HEAD origin/<default-branch>
git log --oneline HEAD..origin/<default-branch>
```

### `--auto-stash`

未コミットの変更を自動的にstashします（rebase時のみ有効）。

```bash
git rebase --autostash origin/<default-branch>
```

## Error Handling

### 1. リモートが存在しない

```bash
# エラー: fatal: 'origin' does not appear to be a git repository
```

**対処:** リモートを追加するか、正しいリモート名を指定

### 2. デフォルトブランチが検出できない

```bash
# エラー: Could not detect default branch
```

**対処:** `--base` オプションで明示的に指定

### 3. ネットワークエラー

```bash
# エラー: fatal: unable to access '...': Could not resolve host
```

**対処:** ネットワーク接続を確認し、再試行

### 4. コンフリクトが解決できない

### 対処手順:

1. 現在の状態を保存: `git stash`
2. クリーンな状態から再試行
3. それでも解決できない場合は、手動マージを提案

## Best Practices

1. **定期的な同期**: 長期間ブランチを更新していない場合は、コンフリクトが複雑になる前に同期
2. **コミット前に同期**: 作業内容をコミットする前に、最新の状態と同期
3. **rebase vs merge**:
   - 履歴をきれいに保ちたい場合: `--rebase`
   - マージコミットを残したい場合: デフォルト（merge）
4. **dry-run活用**: 大きな変更が予想される場合は、まず `--dry-run` で確認

## Examples

### 例1: 基本的な同期

```
ユーザー: "mainと同期して"

1. 現在のブランチを確認: feature/new-feature
2. デフォルトブランチを検出: main
3. git fetch origin
4. git merge origin/main
5. コンフリクトなし → 完了
```

### 例2: rebaseでの同期

```
ユーザー: "mainをrebaseして"

1. 現在のブランチを確認: feature/fix-bug
2. デフォルトブランチを検出: main
3. git fetch origin
4. git rebase origin/main
5. コンフリクトあり → 自動解決を試みる
6. package-lock.json: 自動解決（再生成）
7. src/app.ts: 手動対応が必要 → ユーザーに相談
```

### 例3: 明示的なブランチ指定

```
ユーザー: "developと同期して" + --base develop

1. 指定されたブランチを使用: develop
2. git fetch origin
3. git merge origin/develop
4. 完了
```

## Resources

### scripts/detect-default-branch.sh

リモートのデフォルトブランチを検出するBashスクリプト。

### 使用方法:

```bash
bash ~/.agents/skills/sync-origin/scripts/detect-default-branch.sh [remote-name]
```

### 出力:

- 成功: デフォルトブランチ名（例: main）
- 失敗: エラーメッセージ（stderr）、exit code 1

### 検出ロジック:

1. `git symbolic-ref` による検出
2. `git remote show` による検出
3. 一般的なブランチ名（main, master, develop）のチェック
