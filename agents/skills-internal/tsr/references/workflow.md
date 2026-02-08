# TSR Workflow - 実行ワークフローの詳細

TSRを使った安全で効果的なデッドコード削除のワークフローを解説します。柔軟な設定システムにより、プロジェクト固有の要件に適応できます。

## 🎯 基本ワークフロー

### Phase 0: 設定確認

```bash
# 1. 現在の設定を確認
node config-loader.ts

# 出力例:
# TSR Configuration
# ==================================================
# Project Root: /path/to/project
# Config Source: project
#
# Resolved Paths:
#   tsconfig: /path/to/project/tsconfig.json
#   ignoreFile: /path/to/project/.tsrignore
#   outputPath: /tmp/tsr-report-20260115.txt
# ==================================================

# 2. プロジェクト固有設定を作成(必要に応じて)
cp examples/nextjs-app-router.json .tsr-config.json
vim .tsr-config.json  # カスタマイズ
```

### Phase 1: 準備

```bash
# 3. 現在の状態をコミット
git add -A
git commit -m "checkpoint: before tsr cleanup"

# 4. ブランチ作成(オプション)
git checkout -b chore/tsr-cleanup
```

### Phase 2: 検出

```bash
# 5. デッドコード検出
pnpm tsr:check > /tmp/tsr-report-$(date +%Y%m%d).txt

# または設定ファイルのreporting.outputPathを使用
# 自動的に {date} が置換されて保存される

# 6. レポートの概要確認
wc -l /tmp/tsr-report-$(date +%Y%m%d).txt
```

### Phase 3: 解析

スキル内でレポートを解析し、以下を分類:

**カテゴリー分類**:

1. **安全に削除可能** (90%以上の確実性)
   - 明らかに未使用のユーティリティ関数
   - 古いテストヘルパー
   - 使われていない型定義

2. **要確認** (50-90%の確実性)
   - Next.jsページコンポーネント(誤検出の可能性)
   - API Routes
   - 動的インポートされる可能性があるコード

3. **保持** (誤検出)
   - middleware.ts
   - \*.config.ts
   - Prisma seed files

### Phase 4: 設定調整

```bash
# 誤検出を設定ファイルに追加
vim .tsr-config.json

# ignorePatterns フィールドに追加
{
  "ignorePatterns": [
    "src/app/debug/**",
    "src/lib/test-utils/**"
  ]
}

# または .tsrignore に直接追加
vim .tsrignore
```

### Phase 5: 段階的削除

```bash
# 7. 最初の削除(maxDeletionPerRunまで)
pnpm tsr:fix

# 8. 自動検証(verification設定による)
# - type-check (verification.typeCheck: true)
# - lint (verification.lint: true)
# - test (verification.test: true)
# ※設定により自動実行される
```

**問題が発生した場合**:

```bash
# ロールバック
git reset --hard HEAD

# 問題のあるパターンを設定に追加
vim .tsr-config.json

# 再試行
pnpm tsr:fix
```

### Phase 6: 検証

```bash
# 9. ビルド確認
pnpm build

# 10. E2Eテスト(重要な変更の場合)
pnpm test:e2e
```

### Phase 7: コミット

```bash
# 11. 変更をコミット
git add -A
git commit -m "chore: remove unused code via tsr"

# 12. プッシュとPR作成
git push origin chore/tsr-cleanup
gh pr create --title "chore: Remove unused code" --body "Remove dead code detected by TSR"
```

## 🔧 実践的なワークフロー例

### 例1: 週次メンテナンス

```bash
#!/bin/bash
# weekly-tsr-cleanup.sh

set -e

echo "Starting weekly TSR cleanup..."

# 設定確認
node config-loader.ts

# Checkpoint
git add -A
git commit -m "checkpoint: before weekly tsr cleanup" || echo "No changes to commit"

# Detect
echo "Detecting dead code..."
pnpm tsr:check > /tmp/tsr-weekly.txt

# Count
DEAD_CODE_COUNT=$(wc -l < /tmp/tsr-weekly.txt)
echo "Found $DEAD_CODE_COUNT lines of potential dead code"

if [ "$DEAD_CODE_COUNT" -eq 0 ]; then
  echo "No dead code found. Exiting."
  exit 0
fi

# Analyze (manual step - use TSR skill)
echo "Analyze /tmp/tsr-weekly.txt and update .tsr-config.json if needed"
echo "Press Enter to continue with deletion..."
read

# Delete (limited by maxDeletionPerRun)
echo "Deleting dead code..."
pnpm tsr:fix

# Verify (automatic based on verification config)
echo "Quality checks completed (automatic)"

# Commit
git add -A
git commit -m "chore: weekly tsr cleanup - removed unused code"

echo "Weekly TSR cleanup completed successfully!"
```

### 例2: プロジェクト初期セットアップ

```bash
#!/bin/bash
# setup-tsr.sh

set -e

echo "Setting up TSR for project..."

# 1. プロジェクトタイプを検出
if [ -f "next.config.js" ] || [ -f "next.config.mjs" ]; then
  if [ -d "src/app" ]; then
    echo "Detected: Next.js App Router"
    CONFIG_TEMPLATE="nextjs-app-router"
  else
    echo "Detected: Next.js Pages Router"
    CONFIG_TEMPLATE="nextjs-pages-router"
  fi
elif [ -f "package.json" ] && grep -q "\"react\"" package.json; then
  echo "Detected: React application"
  CONFIG_TEMPLATE="react-app"
else
  echo "Detected: Node.js application"
  CONFIG_TEMPLATE="nodejs-app"
fi

# 2. 設定ファイルをコピー
cp examples/${CONFIG_TEMPLATE}.json .tsr-config.json
echo "Created .tsr-config.json from template: ${CONFIG_TEMPLATE}"

# 3. .tsrignore を自動生成
node -e "
const { loadTsrConfig, generateTsrIgnore } = require('./config-loader');
(async () => {
  const config = await loadTsrConfig(process.cwd());
  const ignoreContent = await generateTsrIgnore(config);
  console.log(ignoreContent);
})();
" > .tsrignore

echo "Generated .tsrignore"

# 4. package.json スクリプト追加
if ! grep -q "tsr:check" package.json; then
  npm pkg set scripts.tsr:check="tsr 'src/.*\\\\.(ts|tsx)\$'"
  npm pkg set scripts.tsr:fix="tsr -w 'src/.*\\\\.(ts|tsx)\$'"
  npm pkg set scripts.tsr:config="node config-loader.ts"
  echo "Added TSR scripts to package.json"
fi

# 5. 初回実行
echo "Running initial TSR check..."
pnpm tsr:check > /tmp/tsr-initial.txt

INITIAL_COUNT=$(wc -l < /tmp/tsr-initial.txt)
echo "Found $INITIAL_COUNT items of potential dead code"
echo "Review /tmp/tsr-initial.txt and adjust .tsr-config.json before running tsr:fix"

echo "TSR setup completed!"
```

### 例3: CI/CD統合(設定ベース)

```yaml
# .github/workflows/tsr-check.yml
name: TSR Dead Code Check

on:
  pull_request:
    branches: [main, develop]
    paths:
      - "src/**/*.ts"
      - "src/**/*.tsx"
      - ".tsr-config.json"
      - ".tsrignore"

jobs:
  tsr-check:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: "20"
          cache: "pnpm"

      - name: Install dependencies
        run: pnpm install --frozen-lockfile

      - name: Display TSR configuration
        run: node config-loader.ts

      - name: Run TSR check
        id: tsr
        run: |
          pnpm tsr:check > tsr-report.txt || true
          DEAD_CODE_COUNT=$(wc -l < tsr-report.txt)
          echo "count=$DEAD_CODE_COUNT" >> $GITHUB_OUTPUT

      - name: Comment PR
        if: steps.tsr.outputs.count > 0
        uses: actions/github-script@v6
        with:
          script: |
            const count = '${{ steps.tsr.outputs.count }}';
            const fs = require('fs');
            const report = fs.readFileSync('tsr-report.txt', 'utf8');

            const body = `## TSR Dead Code Report

            Found **${count}** potential dead code items:

            \`\`\`
            ${report.split('\n').slice(0, 20).join('\n')}
            ${count > 20 ? '\n... and ' + (count - 20) + ' more' : ''}
            \`\`\`

            ${count > 50 ? '⚠️ **Warning**: High number of dead code detected. Consider running \`pnpm tsr:fix\`' : ''}
            ${count > 0 && count <= 50 ? 'ℹ️ **Info**: Run \`pnpm tsr:fix\` to clean up' : ''}
            `;

            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: body
            });

      - name: Upload TSR report
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: tsr-report
          path: tsr-report.txt

      - name: Fail if too much dead code
        if: steps.tsr.outputs.count > 100
        run: |
          echo "❌ Too much dead code detected (${{ steps.tsr.outputs.count }} items)"
          echo "Please run 'pnpm tsr:fix' locally and commit the changes"
          exit 1
```

### 例4: ホーム設定を使用したグローバルワークフロー

```bash
#!/bin/bash
# setup-global-tsr.sh

set -e

echo "Setting up global TSR configuration..."

# ホームディレクトリに設定を作成
mkdir -p ~/.config/tsr

cat > ~/.config/tsr/config.json <<EOF
{
  "version": "1.0.0",
  "verification": {
    "typeCheck": true,
    "lint": true,
    "test": true
  },
  "reporting": {
    "outputPath": "~/tsr-reports/tsr-{date}.txt",
    "verbose": true
  },
  "maxDeletionPerRun": 10
}
EOF

# レポート出力ディレクトリ作成
mkdir -p ~/tsr-reports

echo "Global TSR configuration created at ~/.config/tsr/config.json"
echo "All projects will inherit these settings unless overridden"
echo ""
echo "Usage in any project:"
echo "  pnpm tsr:check  # Uses global config"
echo "  node config-loader.ts  # View merged config"
```

## 🚨 トラブルシューティング

### 問題1: 設定が読み込まれない

**症状**:

```bash
node config-loader.ts
# Config Source: default (expected: project or home)
```

**対処法**:

```bash
# 設定ファイルの存在確認
ls -la .tsr-config.json
ls -la ~/.config/tsr/config.json

# JSON構文確認
cat .tsr-config.json | jq .

# 権限確認
chmod 644 .tsr-config.json
```

### 問題2: 削除後にビルドエラー

**症状**:

```bash
pnpm tsr:fix
pnpm build
# Error: Module not found
```

**対処法**:

```bash
# ロールバック
git reset --hard HEAD^

# 問題のあるファイルを ignorePatterns に追加
vim .tsr-config.json
# "ignorePatterns": ["path/to/false-positive.ts"]

# 再試行
pnpm tsr:fix
```

### 問題3: 検証が実行されない

**症状**:

```bash
pnpm tsr:fix
# 削除は成功するが、type-check/lintが実行されない
```

**対処法**:

```bash
# verification 設定を確認
node config-loader.ts | grep -A 5 "Verification"

# 設定を修正
vim .tsr-config.json
# "verification": {
#   "typeCheck": true,
#   "lint": true,
#   "test": false
# }
```

### 問題4: レポートが期待した場所に保存されない

**症状**:

```bash
# reporting.outputPath: "~/tsr-reports/tsr-{date}.txt"
# しかし /tmp/tsr-report-*.txt に保存される
```

**対処法**:

```bash
# 設定の優先度を確認
node config-loader.ts

# プロジェクト設定がホーム設定をオーバーライドしている可能性
# .tsr-config.json から reporting.outputPath を削除
```

## 📊 効果測定

### メトリクス収集スクリプト

```bash
#!/bin/bash
# measure-tsr-impact.sh

set -e

# Before
echo "=== Before TSR ==="
FILES_BEFORE=$(find src -type f \( -name "*.ts" -o -name "*.tsx" \) | wc -l)
SIZE_BEFORE=$(du -sh src | cut -f1)
echo "Files: $FILES_BEFORE"
echo "Size: $SIZE_BEFORE"

# Build time
echo "Measuring build time..."
time pnpm build > /tmp/build-before.txt 2>&1

# TSR実行
echo ""
echo "=== Running TSR ==="
pnpm tsr:check > /tmp/tsr-report.txt
ITEMS_TO_REMOVE=$(wc -l < /tmp/tsr-report.txt)
echo "Items to remove: $ITEMS_TO_REMOVE"

pnpm tsr:fix

# After
echo ""
echo "=== After TSR ==="
FILES_AFTER=$(find src -type f \( -name "*.ts" -o -name "*.tsx" \) | wc -l)
SIZE_AFTER=$(du -sh src | cut -f1)
echo "Files: $FILES_AFTER"
echo "Size: $SIZE_AFTER"

# Build time
echo "Measuring build time..."
time pnpm build > /tmp/build-after.txt 2>&1

# Report
echo ""
echo "=== Impact Report ==="
echo "Files removed: $((FILES_BEFORE - FILES_AFTER))"
echo "Items cleaned: $ITEMS_TO_REMOVE"
echo "Size before: $SIZE_BEFORE"
echo "Size after: $SIZE_AFTER"
```

## 🎯 ベストプラクティス

### 1. 設定ファイルの管理

```bash
# プロジェクト設定はGit管理
git add .tsr-config.json
git commit -m "chore: add TSR configuration"

# ホーム設定は個人的な設定
# プロジェクト設定で必要に応じてオーバーライド
```

### 2. 段階的な削除

```json
{
  "maxDeletionPerRun": 10 // 一度に削除する最大数
}
```

### 3. 検証の自動化

```json
{
  "verification": {
    "typeCheck": true, // 必須
    "lint": true, // 推奨
    "test": false // プロジェクトによる
  }
}
```

### 4. レポートの保存

```json
{
  "reporting": {
    "outputPath": "~/tsr-reports/tsr-{date}.txt", // 日付ごとに保存
    "verbose": true // 詳細ログ
  }
}
```

## 🔗 関連リソース

- **メインスキル**: `../SKILL.md`
- **設定スキーマ**: `../tsr-config.schema.json`
- **設定ローダー**: `../config-loader.ts`
- **設定例**: `../examples/`
- **.tsrignore設定**: `tsrignore.md`
- **実践例**: `examples.md`

---

**目標**: 設定システムを活用した、安全で効果的なデッドコード削除ワークフローを確立する
