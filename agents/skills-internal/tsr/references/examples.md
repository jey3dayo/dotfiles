# TSR実践例とユースケース

実際のプロジェクトでTSRを効果的に活用するための実践例を紹介します。

## 🎯 ユースケース別実践例

### 例1: 大規模リファクタリング後のクリーンアップ

**シナリオ**: Service層のリファクタリングで多数の関数が不要になった

```bash
# Before リファクタリング
# src/services/ に 50個のサービス関数

# リファクタリング実行
# → Repository層を新設し、共通化

# After リファクタリング
# 多数の未使用関数が残存
```

**実行手順**:

```bash
# 1. リファクタリング完了をコミット
git add -A
git commit -m "refactor: consolidate service layer with repository pattern"

# 2. デッドコード検出
pnpm tsr:check > /tmp/tsr-after-refactor.txt

# 3. レポート確認
cat /tmp/tsr-after-refactor.txt | grep "src/services"

# 出力例:
# Unused export 'getUserById' in src/services/user-service.ts
# Unused export 'getAdminById' in src/services/admin-service.ts
# Unused export 'getPostById' in src/services/post-service.ts
# ... (合計 23個の未使用エクスポート)

# 4. スキルで解析
# TSRスキル起動後: /tmp/tsr-after-refactor.txt を読み込んで分析
# → 23個全てが安全に削除可能と判断

# 5. 削除実行
pnpm tsr:fix

# 6. 検証
pnpm type-check && pnpm lint && pnpm test

# 7. コミット
git add -A
git commit -m "chore: remove unused service functions after refactoring"
```

**結果**:

```
Before:
- src/services/*: 50 functions
- Total lines: 1,200

After:
- src/services/*: 27 functions
- Total lines: 650
- Reduction: 46%
```

### 例2: モノレポからの機能抽出後

**シナリオ**: 特定機能を別パッケージに切り出した後のクリーンアップ

```bash
# 機能抽出前
packages/
  web/
    src/
      features/
        auth/     # 認証機能
        payment/  # 決済機能
        shipping/ # 配送機能

# 機能抽出後
packages/
  web/
    src/features/auth/    # 他は削除済み
  payment-service/        # 新パッケージ
  shipping-service/       # 新パッケージ
```

**実行手順**:

```bash
cd packages/web

# 1. 抽出後の状態をコミット
git add -A
git commit -m "refactor: extract payment and shipping to separate packages"

# 2. デッドコード検出
pnpm tsr:check > /tmp/tsr-after-extraction.txt

# 3. レポート解析
# 出力例:
# Unused export 'PaymentService' in src/lib/payment-client.ts
# Unused export 'ShippingCalculator' in src/lib/shipping-utils.ts
# Unused file src/types/payment-types.ts
# Unused file src/types/shipping-types.ts
# ... (合計 15ファイル、45エクスポート)

# 4. カテゴリー分類
# - 安全に削除: payment/shipping関連の全て
# - 保持: auth関連

# 5. 削除実行
pnpm tsr:fix

# 6. 検証
pnpm type-check && pnpm test

# 7. 不要なディレクトリを削除
rm -rf src/lib/payment-client.ts
rm -rf src/lib/shipping-utils.ts
rm -rf src/types/payment-types.ts
rm -rf src/types/shipping-types.ts

# 8. コミット
git add -A
git commit -m "chore: cleanup after extracting payment and shipping features"
```

**結果**:

```
Removed:
- 15 files
- 45 exports
- ~500 lines of code
- Bundle size: -35KB
```

### 例3: 週次メンテナンスルーチン

**シナリオ**: 定期的なコードベースクリーンアップ

**毎週月曜 9:00 に実行**:

```bash
#!/bin/bash
# weekly-tsr-maintenance.sh

set -e

echo "=== Weekly TSR Maintenance ==="
date

# 1. 最新の main を取得
git checkout main
git pull origin main

# 2. メンテナンスブランチ作成
BRANCH_NAME="chore/tsr-weekly-$(date +%Y%m%d)"
git checkout -b "$BRANCH_NAME"

# 3. デッドコード検出
echo "Detecting dead code..."
pnpm tsr:check > /tmp/tsr-weekly-$(date +%Y%m%d).txt

# 4. レポート統計
UNUSED_COUNT=$(wc -l < /tmp/tsr-weekly-$(date +%Y%m%d).txt)
echo "Found $UNUSED_COUNT lines of potential dead code"

if [ "$UNUSED_COUNT" -eq 0 ]; then
  echo "✅ No dead code found!"
  git checkout main
  git branch -D "$BRANCH_NAME"
  exit 0
fi

# 5. レポート送信（Slack通知）
echo "📊 Weekly TSR Report: $UNUSED_COUNT potential dead code items" | \
  curl -X POST -H 'Content-type: application/json' \
  --data "{\"text\":\"$(cat /tmp/tsr-weekly-$(date +%Y%m%d).txt | head -20)\"}" \
  "$SLACK_WEBHOOK_URL"

# 6. 手動確認待ち
echo "Review /tmp/tsr-weekly-$(date +%Y%m%d).txt"
echo "Update .tsrignore if needed, then run: pnpm tsr:fix"
echo "Press Enter to continue..."
read

# 7. 削除実行
pnpm tsr:fix

# 8. 検証
echo "Running quality checks..."
pnpm type-check
pnpm lint
pnpm test:unit

# 9. コミット&プッシュ
git add -A
git commit -m "chore: weekly tsr cleanup - removed $UNUSED_COUNT items"
git push origin "$BRANCH_NAME"

# 10. PR作成
gh pr create \
  --title "chore: Weekly TSR cleanup" \
  --body "Removed $UNUSED_COUNT unused code items detected by TSR" \
  --label "maintenance"

echo "=== Maintenance Complete ==="
```

**実行結果の例**:

```
Week 1: 12 items removed
Week 2: 5 items removed
Week 3: 0 items (clean!)
Week 4: 8 items removed

Average: 6.25 items/week
Total removed in month: 25 items
```

### 例4: CI/CD統合による継続的チェック

**シナリオ**: Pull Requestごとにデッドコードをチェック

**.github/workflows/tsr-check.yml**:

```yaml
name: TSR Dead Code Check

on:
  pull_request:
    branches: [main, develop]
    paths:
      - "src/**/*.ts"
      - "src/**/*.tsx"

jobs:
  tsr-check:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0 # 全履歴取得

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: "20"
          cache: "pnpm"

      - name: Install dependencies
        run: pnpm install --frozen-lockfile

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

            const body = `## 🧹 TSR Dead Code Report

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

**実行例**:

```
PR #123: feature/add-user-profile
✅ TSR Check: 0 dead code items

PR #124: refactor/service-layer
ℹ️ TSR Check: 15 dead code items
📝 Comment posted with details

PR #125: feature/payment-integration
⚠️ TSR Check: 105 dead code items
❌ Build failed - too much dead code
```

### 例5: テスト削除後のクリーンアップ

**シナリオ**: E2Eテストを別リポジトリに移行

```bash
# Before
src/
  tests/
    e2e/
      auth.e2e.ts
      payment.e2e.ts
      ...
  lib/
    test-utils.ts      # E2Eテスト用ユーティリティ
  mocks/
    e2e-fixtures.ts    # E2Eテスト用フィクスチャ

# E2Eテスト削除
rm -rf src/tests/e2e

# After
# test-utils.ts, e2e-fixtures.ts が未使用に
```

**実行手順**:

```bash
# 1. E2Eテスト削除をコミット
git add -A
git commit -m "test: migrate e2e tests to separate repository"

# 2. デッドコード検出
pnpm tsr:check > /tmp/tsr-after-e2e-removal.txt

# 3. レポート確認
cat /tmp/tsr-after-e2e-removal.txt | grep -E "(test-utils|fixtures)"

# 出力:
# Unused export 'setupE2EEnvironment' in src/lib/test-utils.ts
# Unused export 'createE2EUser' in src/lib/test-utils.ts
# Unused file src/mocks/e2e-fixtures.ts

# 4. 削除実行
pnpm tsr:fix

# 5. 残存する test-utils.ts を確認
cat src/lib/test-utils.ts
# → E2E用の関数が削除され、Unit/Integration用の関数のみ残る

# 6. コミット
git add -A
git commit -m "chore: cleanup e2e test utilities after migration"
```

## 📊 効果測定例

### プロジェクトA: 中規模Next.jsアプリケーション

**Before TSR**:

```
Files: 450
Lines of Code: 35,000
Build Time: 45s
Bundle Size: 320KB
```

**After 1 month of TSR**:

```
Files: 420 (-30)
Lines of Code: 32,500 (-2,500)
Build Time: 42s (-3s)
Bundle Size: 295KB (-25KB)

Weekly TSR runs: 4
Total items removed: 78
Average per run: 19.5
```

### プロジェクトB: 大規模モノレポ

**Before TSR**:

```
Packages: 12
Total Files: 2,100
Lines of Code: 180,000
Dead Code Rate: ~8%
```

**After 3 months of TSR**:

```
Packages: 12
Total Files: 1,950 (-150)
Lines of Code: 166,000 (-14,000)
Dead Code Rate: ~2%

Monthly TSR runs: 12
Total items removed: 342
Average per run: 28.5
```

## 🔗 関連リソース

- **メインスキル**: `../skill.md`
- **ワークフロー**: `workflow.md`
- **.tsrignore設定**: `tsrignore.md`

---

**目標**: 実践的な例を通じて、TSRを効果的に活用する方法を理解する
