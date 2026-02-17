# ロールバック戦略 - 問題発生時の対処法

クリーンアップで問題が発生した際の復旧手順とロールバック戦略。

## 基本的なロールバック

### Gitチェックポイントへのロールバック

最も一般的で安全なロールバック方法。

```bash
# チェックポイント情報を確認
$ cat .cleanup_checkpoint.json

{
  "hash": "h8i9j0k",
  "timestamp": "2026-02-12 15:30:45",
  "message": "Pre-cleanup checkpoint: 2026-02-12 15:30:45",
  "branch": "cleanup/maintenance"
}

# 完全ロールバック（推奨）
$ git reset --hard h8i9j0k
HEAD is now at h8i9j0k Pre-cleanup checkpoint

# 未追跡ファイルも削除
$ git clean -fd
Removing .cleanup_archive_20260212_153045.tar.gz
Removing .cleanup_snapshot_20260212_153045/

✓ Rollback completed
✓ Project restored to pre-cleanup state
```

### ソフトロールバック（変更履歴保持）

変更内容を確認しながらロールバック。

```bash
# ソフトリセット（変更は保持）
$ git reset --soft h8i9j0k

# 変更内容を確認
$ git diff --cached

# 必要なら個別に復元
$ git restore --staged <file>
$ git restore <file>

# または全て破棄
$ git reset --hard h8i9j0k
```

## 部分的なロールバック

### 特定ファイルのみ復元

```bash
# 1つのファイルを復元
$ git checkout h8i9j0k -- src/utils/metrics.ts
Updated 1 path from h8i9j0k

# 複数ファイルを復元
$ git checkout h8i9j0k -- src/utils/*.ts
Updated 5 paths from h8i9j0k

# ディレクトリ全体を復元
$ git checkout h8i9j0k -- src/components/
Updated 23 paths from h8i9j0k
```

### 特定の変更のみRevert

```bash
# 特定のコミットをrevert
$ git revert <commit-hash>

# revert後の状態確認
$ git log --oneline -5
$ git diff HEAD~1

# revertをやめる場合
$ git revert --abort
```

## アーカイブからの復元

### アーカイブ全体を復元

```bash
# アーカイブ一覧を確認
$ ls -lh .cleanup_archive_*.tar.gz
-rw-r--r--  1 user  staff   89M Feb 12 15:30 .cleanup_archive_20260212_153045.tar.gz

# アーカイブ内容を確認
$ tar -tzf .cleanup_archive_20260212_153045.tar.gz | head -10
logs/app.log
logs/error.log
logs/debug.log
...

# 全ファイルを復元
$ tar -xzf .cleanup_archive_20260212_153045.tar.gz

✓ Restored 45 files from archive
```

### 特定ファイルのみ復元

```bash
# 1つのファイルを復元
$ tar -xzf .cleanup_archive_20260212_153045.tar.gz \
    src/utils/oldMetrics.ts

# 複数ファイルを復元
$ tar -xzf .cleanup_archive_20260212_153045.tar.gz \
    src/utils/oldMetrics.ts \
    src/utils/oldFormatters.ts

# パターンマッチで復元
$ tar -xzf .cleanup_archive_20260212_153045.tar.gz \
    --wildcards "src/utils/old*.ts"
```

### 復元前の確認

```bash
# アーカイブの詳細情報
$ cat .cleanup_archive_20260212_153045.json

{
  "archive": ".cleanup_archive_20260212_153045.tar.gz",
  "timestamp": "2026-02-12T15:30:45",
  "file_count": 45,
  "files": [
    "logs/app.log",
    "logs/error.log",
    ...
  ],
  "size": 93421568
}

# 特定ファイルが含まれるか確認
$ tar -tzf .cleanup_archive_20260212_153045.tar.gz | \
    grep "metrics.ts"
src/utils/oldMetrics.ts
```

## スナップショットからの復元

### 整合性検証

```bash
# スナップショット情報を確認
$ cat .cleanup_snapshot_20260212_153045/snapshot.json

{
  "timestamp": "2026-02-12T15:30:45",
  "git_hash": "h8i9j0k",
  "files": {
    "src/utils/metrics.ts": {
      "hash": "a1b2c3d4...",
      "size": 1234,
      "mtime": 1707742245
    },
    ...
  }
}

# 現在のファイルとハッシュを比較
$ python3 << 'EOF'
import json
import hashlib
import os

with open('.cleanup_snapshot_20260212_153045/snapshot.json') as f:
    snapshot = json.load(f)

corrupted = []
for file_path, info in snapshot['files'].items():
    if os.path.exists(file_path):
        with open(file_path, 'rb') as f:
            current_hash = hashlib.sha256(f.read()).hexdigest()
        if current_hash != info['hash']:
            corrupted.append(file_path)

if corrupted:
    print("Corrupted files:")
    for f in corrupted:
        print(f"  - {f}")
else:
    print("All files match snapshot")
EOF
```

### 破損ファイルの復元

```bash
# Gitから復元（推奨）
$ git checkout h8i9j0k -- <corrupted-file>

# アーカイブから復元
$ tar -xzf .cleanup_archive_20260212_153045.tar.gz <corrupted-file>
```

## 段階的ロールバック

### Phase-by-Phase復元

クリーンアップを段階的に実行した場合の復元。

```bash
# Phase 4で問題発生した場合
# → Phase 3まで戻す

# 最新のコミットを確認
$ git log --oneline -5
j0k1l2m Phase 4: Documentation consolidation
i9j0k1l Phase 3: File cleanup
h8i9j0k Phase 2: Code cleanup
g7h8i9j Phase 1: Debug code removal
f6g7h8i Pre-cleanup checkpoint

# Phase 3まで戻す
$ git reset --hard i9j0k1l

# 動作確認
$ npm test
$ npm run build

# 問題が解決したことを確認
✓ Tests passing
✓ Build successful
```

## 緊急ロールバックシナリオ

### シナリオ1: 本番環境でエラー発生

```bash
# 状況: 本番環境でデプロイ後にエラー発生
# 原因: 重要な関数が削除されていた

# Step 1: 即座に前のバージョンにロールバック
$ git revert HEAD --no-edit
$ git push origin main

# Step 2: デプロイ
$ npm run deploy

# Step 3: ローカルで修正
$ git reset --hard HEAD~2  # revertとcleanupを取り消し
$ git checkout -b fix/restore-missing-function

# Step 4: 必要な関数をアーカイブから復元
$ tar -xzf .cleanup_archive_20260212_153045.tar.gz \
    src/utils/criticalFunction.ts

# Step 5: @preserve追加して再クリーンアップ
# @preserve: Required by production API
export function criticalFunction() { ... }

# Step 6: 検証とデプロイ
$ npm test
$ git add .
$ git commit -m "fix: restore critical function"
$ git push origin fix/restore-missing-function
```

### シナリオ2: テストが大量に失敗

```bash
# 状況: クリーンアップ後、42個のテストが失敗
# 原因: テスト用のユーティリティ関数が削除された

# Step 1: 影響範囲を確認
$ npm test 2>&1 | grep "FAIL"
  ● tests/utils/helpers.test.ts
  ● tests/components/Dashboard.test.tsx
  ...

# Step 2: 失敗したテストのパターンを分析
$ npm test 2>&1 | grep "Cannot find" | sort | uniq
  Cannot find module 'utils/testHelpers'
  Cannot find module 'utils/mockData'

# Step 3: 必要なファイルをアーカイブから復元
$ tar -tzf .cleanup_archive_20260212_153045.tar.gz | \
    grep -E "(testHelpers|mockData)"
src/utils/testHelpers.ts
src/utils/mockData.ts

$ tar -xzf .cleanup_archive_20260212_153045.tar.gz \
    src/utils/testHelpers.ts \
    src/utils/mockData.ts

# Step 4: 検証
$ npm test

✓ All tests passing
✓ 42 previously failing tests now pass
```

### シナリオ3: ビルドが完全に失敗

```bash
# 状況: ビルドが開始さえしない
# 原因: 重要な型定義ファイルが削除された

# Step 1: エラーメッセージを確認
$ npm run build 2>&1 | tee build-error.log
  Error: Cannot find module 'types/global.d.ts'
  Error: Type 'AppConfig' is not found

# Step 2: 完全ロールバック（最速）
$ git reset --hard h8i9j0k

# Step 3: ビルド確認
$ npm run build
✓ Build successful

# Step 4: より慎重に再クリーンアップ
# .cleanupignoreに追加
$ echo "types/" >> .cleanupignore
$ echo "**/*.d.ts" >> .cleanupignore

# Step 5: 再実行
$ /project-maintenance full
```

## 自動ロールバックスクリプト

### 検証失敗時の自動ロールバック

```bash
#!/bin/bash
# auto-rollback.sh

CHECKPOINT=$(cat .cleanup_checkpoint.json | jq -r '.hash')

echo "Running post-cleanup validation..."

# テスト実行
if ! npm test; then
    echo "❌ Tests failed! Rolling back..."
    git reset --hard "$CHECKPOINT"
    git clean -fd
    echo "✓ Rolled back to checkpoint: $CHECKPOINT"
    exit 1
fi

# ビルド実行
if ! npm run build; then
    echo "❌ Build failed! Rolling back..."
    git reset --hard "$CHECKPOINT"
    git clean -fd
    echo "✓ Rolled back to checkpoint: $CHECKPOINT"
    exit 1
fi

# 型チェック
if ! npx tsc --noEmit; then
    echo "❌ Type check failed! Rolling back..."
    git reset --hard "$CHECKPOINT"
    git clean -fd
    echo "✓ Rolled back to checkpoint: $CHECKPOINT"
    exit 1
fi

echo "✓ All validations passed!"
```

### 使用方法

```bash
# クリーンアップ実行
$ /project-maintenance full

# 自動検証とロールバック
$ bash auto-rollback.sh

# または統合
$ /project-maintenance full && bash auto-rollback.sh
```

## 予防的ロールバック準備

### マルチチェックポイント戦略

```bash
# Phase 1実行
$ /project-maintenance full --code-only
$ git commit -m "cleanup: phase 1 - code only"
$ git tag cleanup-phase1

# Phase 2実行
$ /project-maintenance full --files-only
$ git commit -m "cleanup: phase 2 - files only"
$ git tag cleanup-phase2

# Phase 3実行
$ /project-maintenance full --docs-only
$ git commit -m "cleanup: phase 3 - docs only"
$ git tag cleanup-phase3

# 問題が発生した場合
$ git reset --hard cleanup-phase2  # Phase 2まで戻る
```

### ブランチ戦略

```bash
# クリーンアップ専用ブランチ作成
$ git checkout -b cleanup/safe-maintenance

# 段階的にコミット
$ /project-maintenance files
$ git add .
$ git commit -m "cleanup: remove temporary files"
$ npm test  # 検証

$ /project-maintenance full --code-only
$ git add .
$ git commit -m "cleanup: remove unused code"
$ npm test  # 検証

# 問題が発生した場合
$ git checkout main  # mainブランチに戻る
$ git branch -D cleanup/safe-maintenance  # クリーンアップブランチを削除
```

## ロールバック後の対応

### 問題分析

```bash
# 何が削除されたかを確認
$ git diff h8i9j0k HEAD

# 削除されたファイル一覧
$ git diff --name-status h8i9j0k HEAD | grep "^D"

# 削除された行数
$ git diff --stat h8i9j0k HEAD
```

### .cleanupignore更新

```bash
# 削除すべきでなかったファイルを除外
$ cat >> .cleanupignore << 'EOF'
# Critical files (do not remove)
src/utils/criticalFunction.ts
types/
**/*.d.ts

# Test utilities
tests/utils/
tests/mocks/
EOF
```

### 再実行

```bash
# より安全な設定で再実行
$ /project-maintenance full --dry-run

# 確認後に実行
$ /project-maintenance full

# 段階的に検証
$ npm test
$ npm run build
$ npm run lint
```

## ベストプラクティス

### ロールバック準備

1. 複数のチェックポイント: 段階的にコミット
2. タグ付け: 重要なポイントにタグ
3. ブランチ分離: 専用ブランチで実行
4. ドキュメント: 変更内容を記録

### 問題発見時

1. 即座に停止: 問題を発見したら即停止
2. 状態記録: エラーログを保存
3. 影響範囲確認: どこまで影響があるか確認
4. 段階的復旧: 完全ロールバックから開始

### 再実行時

1. 原因分析: なぜ問題が発生したか分析
2. 除外設定: .cleanupignoreを更新
3. より慎重に: --dry-runで確認
4. 段階的実行: 小規模から再開

### チーム共有

1. インシデント記録: 何が起きたか記録
2. 学習共有: チームに共有
3. プロセス改善: 再発防止策を検討
4. ドキュメント更新: 手順書を更新
