# クリーンアップワークフロー - 実行例とベストプラクティス

プロジェクトメンテナンスの実用的なワークフローと実行例。

## フルクリーンアップワークフロー

### 基本ワークフロー

```bash
# 1. 現在の状態を確認
git status
git log --oneline -5

# 2. プレビューモードで確認
/project-maintenance full --dry-run

# 3. 実行（段階的）
/project-maintenance full --code-only     # コードのみ
# 動作確認
npm test

/project-maintenance full --files-only    # ファイルのみ
# 動作確認
npm test

/project-maintenance full --docs-only     # ドキュメントのみ
# 動作確認
npm run build

# 4. 最終確認
git status
git diff
```

### 実行例: TypeScriptプロジェクト

````markdown
## プロジェクト情報

- 言語: TypeScript
- フレームワーク: React
- ビルドツール: Vite
- テスト: Jest + React Testing Library

## 実行ログ

### Phase 1: 安全性確保とプロジェクト解析

```bash
$ /project-maintenance full

🔒 Phase 1: Safety & Analysis
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ Git status: Clean working tree
✓ Checkpoint created: a1b2c3d
✓ Snapshot saved: .cleanup_snapshot_20260212_143022

📊 Project Structure
- Total files: 1,234
- Code files: 456
- Documentation: 23
- Test files: 89
```
````

### Phase 2: セマンティック・コード解析

```bash
🔍 Phase 2: Semantic Analysis
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Analyzing symbols...
✓ Found 342 symbols
✓ Checking references...

📋 Analysis Results
┌─────────────────────┬───────┬──────────┐
│ Type                │ Total │ Unused   │
├─────────────────────┼───────┼──────────┤
│ Functions           │ 156   │ 8        │
│ Classes             │ 45    │ 2        │
│ Variables           │ 89    │ 5        │
│ Imports             │ 52    │ 23       │
├─────────────────────┼───────┼──────────┤
│ Total               │ 342   │ 38       │
└─────────────────────┴───────┴──────────┘

🐛 Debug Code Detection
- console.log: 15 occurrences
- debugger: 3 occurrences
- TODO comments: 7 items
```

### Phase 3: コード整理実行

```bash
🧹 Phase 3: Code Cleanup
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ Removed unused function: calculateOldMetric (src/utils/metrics.ts)
✓ Removed unused function: formatLegacyDate (src/utils/formatters.ts)
✓ Removed unused class: DeprecatedComponent (src/components/old.tsx)
✓ Cleaned 23 unused imports
✓ Removed 15 debug statements
✓ Cleaned 5 TODO markers

📊 Code Cleanup Summary
- Functions removed: 8
- Classes removed: 2
- Variables removed: 5
- Imports cleaned: 23
- Debug statements: 15
- Lines removed: 487
```

### Phase 4: ファイル整理

```bash
📁 Phase 4: File Cleanup
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Scanning for temporary files...
✓ Found 45 files to clean

✓ Removed: logs/debug.log (12.3 MB)
✓ Removed: .cache/vite-plugin-*.tmp (23 files, 45.6 MB)
✓ Removed: node_modules/.cache (128 MB)
✓ Removed: .DS_Store (15 files)

📊 File Cleanup Summary
- Files removed: 45
- Space freed: 185.9 MB
- Protected files: 12
```

### Phase 5: ドキュメント統合

```bash
📖 Phase 5: Documentation
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Analyzing documentation...
✓ Found 23 markdown files

🔍 Duplicate Detection
- docs/api.md vs docs/api-reference.md (85% similar)
  → Consolidated into docs/api-reference.md
- docs/setup.md vs README.md (60% similar)
  → Updated cross-references

📊 Documentation Summary
- Files consolidated: 3 → 1
- Links fixed: 12
- Consistency improved: 5 files
```

### Phase 6: 事後検証

```bash
✅ Phase 6: Post-Validation
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Running tests...
✓ Jest: 89 tests passed
✓ TypeScript: No errors
✓ ESLint: No violations

Running build...
✓ Vite build: Success
✓ Output size: 456 KB (reduced from 523 KB)

📊 Validation Summary
✓ All tests passing
✓ No type errors
✓ No lint violations
✓ Build successful
✓ Bundle size reduced: -12.8%
```

### 最終レポート

```markdown
🎉 Cleanup Completed Successfully
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 📋 Overall Summary

- Total files processed: 1,234
- Code lines removed: 487
- Files deleted: 45
- Space freed: 185.9 MB
- Execution time: 3m 42s

## 🔍 Code Quality Improvements

- Unused symbols removed: 38
- Debug statements removed: 15
- TODO items tracked: 7
- Import statements optimized: 23

## 📦 Build Improvements

- Bundle size: -12.8% (523 KB → 456 KB)
- Build time: -8.3% (2.4s → 2.2s)

## 🔄 Rollback Information

- Checkpoint: a1b2c3d
- Archive: .cleanup_archive_20260212_143022.tar.gz
- Snapshot: .cleanup_snapshot_20260212_143022/

## 📝 Next Steps

- Review 7 remaining TODO items
- Consider updating CI/CD lint rules
- Share cleanup guidelines with team
```

## ターゲットクリーンアップワークフロー

### 基本ワークフロー

```bash
# 1. パターンを確認
/project-maintenance files --dry-run

# 2. 特定パターンをクリーンアップ
/project-maintenance files "**/*.log"

# 3. 複数パターン
/project-maintenance files "**/*.{log,tmp}"

# 4. 古いファイルのみ
/project-maintenance files "**/*.log" --older-than 7
```

### 実行例: ログファイルクリーンアップ

```bash
$ /project-maintenance files "**/*.log"

🧹 File Cleanup: **/*.log
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔒 Safety Checks
✓ Git checkpoint: b2c3d4e
✓ Archive: .cleanup_archive_20260212_144530.tar.gz

📊 Scanning...
Found 23 log files:
  logs/app.log (12.3 MB, 7 days old)
  logs/error.log (3.4 MB, 5 days old)
  logs/debug.log (45.2 MB, 2 days old)
  ... 20 more files

⚠️  Large files detected:
  logs/debug.log (45.2 MB)
  logs/app.log (12.3 MB)

Proceed with deletion? (y/n): y

🗑️  Deleting...
✓ Removed: logs/app.log (12.3 MB)
✓ Removed: logs/error.log (3.4 MB)
✓ Removed: logs/debug.log (45.2 MB)
... 20 more files

📊 Summary
- Files deleted: 23
- Space freed: 89.5 MB
- Protected: 0
- Skipped: 0
```

### 実行例: キャッシュクリーンアップ

```bash
$ /project-maintenance files "**/.cache/**"

🧹 File Cleanup: **/.cache/**
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔒 Safety Checks
✓ Git checkpoint: c3d4e5f
✓ Archive: .cleanup_archive_20260212_145012.tar.gz

📊 Scanning...
Found 156 cache files:
  .cache/webpack/ (78 files, 123 MB)
  node_modules/.cache/ (68 files, 89 MB)
  .cache/eslint/ (10 files, 5 MB)

⚠️  Active processes check...
✓ No active processes using these files

🗑️  Deleting...
✓ Removed: .cache/webpack/ (123 MB)
✓ Removed: node_modules/.cache/ (89 MB)
✓ Removed: .cache/eslint/ (5 MB)

📊 Summary
- Files deleted: 156
- Space freed: 217 MB
- Protected: 0
- Skipped: 0
```

## 段階的クリーンアップワークフロー

大規模プロジェクトでの推奨アプローチ。

### Week 1: ファイルクリーンアップ

```bash
# Day 1: ログファイル
/project-maintenance files "**/*.log" --dry-run
/project-maintenance files "**/*.log"
npm test

# Day 2: 一時ファイル
/project-maintenance files "**/*.{tmp,bak,swp}" --dry-run
/project-maintenance files "**/*.{tmp,bak,swp}"
npm test

# Day 3: キャッシュ
/project-maintenance files "**/.cache/**" --dry-run
/project-maintenance files "**/.cache/**"
npm test && npm run build

# Day 4: システムファイル
/project-maintenance files "**/.DS_Store"
/project-maintenance files "**/Thumbs.db"
```

### Week 2: コードクリーンアップ

```bash
# Day 1: デバッグコード確認
/project-maintenance full --code-only --dry-run
# レビュー

# Day 2: デバッグコード削除
/project-maintenance full --code-only
npm test
npm run build

# Day 3: 動作確認
# 手動テスト
# E2Eテスト

# Day 4: ドキュメント確認
/project-maintenance full --docs-only --dry-run
```

### Week 3: 統合とレビュー

```bash
# Day 1-2: チームレビュー
# PRを作成してレビュー依頼

# Day 3: フィードバック対応

# Day 4: マージとデプロイ
```

## プロジェクトタイプ別ワークフロー

### Node.js / npm プロジェクト

```bash
# 1. 依存関係確認
npm outdated
npm audit

# 2. node_modules クリーンアップ
rm -rf node_modules
npm ci

# 3. キャッシュクリーンアップ
/project-maintenance files "node_modules/.cache/**"
/project-maintenance files ".eslintcache"

# 4. コードクリーンアップ
/project-maintenance full --code-only

# 5. 検証
npm test
npm run build
```

### Python プロジェクト

```bash
# 1. 仮想環境確認
source venv/bin/activate
pip list --outdated

# 2. キャッシュクリーンアップ
/project-maintenance files "**/__pycache__/**"
/project-maintenance files "**/*.pyc"
/project-maintenance files ".pytest_cache/**"

# 3. コードクリーンアップ
/project-maintenance full --code-only

# 4. 検証
pytest
mypy .
flake8 .
```

### モノレポ

```bash
# 各パッケージごとに実行
for pkg in packages/*; do
  echo "Cleaning $pkg"
  cd $pkg
  /project-maintenance full
  cd ../..
done

# ルートレベルのクリーンアップ
/project-maintenance files "**/*.log"
/project-maintenance files "**/node_modules/.cache/**"
```

## 緊急クリーンアップワークフロー

ディスク容量不足など、緊急時の対応。

```bash
# 1. 最も大きいファイルを特定
du -sh * | sort -rh | head -10

# 2. 安全に削除できる大きいファイルを削除
/project-maintenance files "**/*.log" --dry-run
/project-maintenance files "**/*.log"

/project-maintenance files "node_modules/.cache/**"
/project-maintenance files ".cache/**"

# 3. 古いビルド成果物を削除
/project-maintenance files "dist/**" --older-than 30
/project-maintenance files "build/**" --older-than 30

# 4. Git履歴の大きいファイルを確認（慎重に）
git rev-list --objects --all | \
  git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' | \
  sed -n 's/^blob //p' | \
  sort --numeric-sort --key=2 | \
  tail -10
```

## ベストプラクティス

### 実行前

1. Git状態確認: 未コミット変更をコミット
2. dry-run実行: 必ずプレビューで確認
3. チーム通知: 大規模変更は事前通知
4. バックアップ確認: チェックポイントが作成されたか確認

### 実行中

1. 段階的実行: 小規模から開始
2. 頻繁なテスト: 各段階でテスト実行
3. ログ記録: 実行ログを保存
4. 進捗共有: チームに進捗を共有

### 実行後

1. 動作確認: 重要機能の手動テスト
2. パフォーマンス確認: ビルド時間、バンドルサイズ
3. ドキュメント更新: 変更内容をドキュメント化
4. 学習記録: 得られた知見を記録

### トラブル時

1. 即座に停止: 問題が発生したら即停止
2. ロールバック: Gitチェックポイントに戻る
3. 原因分析: 何が問題だったか分析
4. 再計画: より慎重なアプローチで再実行

## 自動化

### CI/CD統合

```yaml
# .github/workflows/cleanup.yml
name: Weekly Cleanup

on:
  schedule:
    - cron: "0 2 * * 0" # Every Sunday at 2 AM
  workflow_dispatch:

jobs:
  cleanup:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: File Cleanup
        run: |
          /project-maintenance files "**/*.log" --older-than 7
          /project-maintenance files "**/.cache/**"

      - name: Run Tests
        run: npm test

      - name: Create PR
        uses: peter-evans/create-pull-request@v5
        with:
          title: "Weekly cleanup"
          body: "Automated cleanup of temporary files"
          branch: "cleanup/weekly"
```

### Git Hooks

```bash
# .git/hooks/pre-commit
#!/bin/bash

# コミット前に一時ファイルをクリーンアップ
/project-maintenance files "**/*.{log,tmp}" --quiet

# デバッグコードのチェック
if grep -r "console.log" src/; then
  echo "⚠️  Warning: console.log found in code"
  exit 1
fi
```

### npm Scripts

```json
{
  "scripts": {
    "cleanup:full": "/project-maintenance full",
    "cleanup:files": "/project-maintenance files",
    "cleanup:dry-run": "/project-maintenance full --dry-run",
    "pre-commit": "npm run cleanup:files && npm test"
  }
}
```
