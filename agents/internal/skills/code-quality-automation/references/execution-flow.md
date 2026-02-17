# Execution Flow Details

コード品質チェックと自動修正の実行フロー詳細。

## 🎯 Overall Strategy

### Iteration Philosophy

エラーが出なくなるまで繰り返し実行：

- 最大試行回数: 3回
- 各ステップ: Format → Lint → Test
- 自動修正優先: `lint-fix` で修正可能なものは自動修正
- 手動修正: 自動修正できないエラーは手動で修正

### Success Criteria

すべてのステップが成功した時点で完了：

- Format: ✅ 成功
- Lint: ✅ 成功（エラー0件）
- Test: ✅ 成功（すべてのテストが通る）

## 📋 Step 1: Format Execution

### Purpose

コードを自動整形し、スタイルを統一します。

### Execution

```bash
# mise.toml が検出された場合
mise run format

# package.json が検出された場合
npm run format

# フォールバック（TypeScript/JavaScript）
npx prettier --write .
```

### Success Detection

```python
def is_format_success(result):
    """Format実行が成功したか判定"""
    return result.returncode == 0
```

### Output Example

```
🎨 Step 1/3: Format実行
  $ mise run format
  prettier --write .
  ✅ 3ファイル更新
     - src/index.ts
     - src/utils.ts
     - README.md
  ✅ フォーマット完了
```

### Error Handling

Format実行が失敗した場合：

```
🎨 Step 1/3: Format実行
  $ mise run format
  ❌ フォーマット失敗

  エラー内容:
  SyntaxError: Unexpected token (12:5)

  🔧 構文エラーを修正します...
```

構文エラーがある場合は、まずそれを修正してから再試行。

## 📋 Step 2: Lint Execution & Auto-Fix

### Purpose

Lintエラーを検出し、自動修正可能なものは修正します。

### Execution Flow

```python
def execute_lint_step():
    """Lint実行と自動修正"""

    # 1. Lint実行
    result = run_lint()

    if result.returncode == 0:
        print("✅ Lintエラーなし")
        return True

    # 2. エラー件数を取得
    error_count = parse_lint_errors(result.stdout)
    print(f"❌ {error_count}件のエラー検出")

    # 3. 自動修正を試行
    if lint_fix_available():
        fix_result = run_lint_fix()
        fixed_count = parse_fix_count(fix_result.stdout)
        print(f"✅ {fixed_count}件自動修正")

        # 4. 再度Lint実行
        result = run_lint()

        if result.returncode == 0:
            print("✅ すべてのlintエラーを修正")
            return True

        remaining = parse_lint_errors(result.stdout)
        print(f"⚠️  {remaining}件のエラーが残っています")

    # 5. 手動修正を試みる
    if remaining > 0:
        print("🔧 残りのエラーを手動修正中...")
        manual_fix_errors(result.stdout)

        # 6. 最終確認
        result = run_lint()
        return result.returncode == 0

    return False
```

### Lint Command

```bash
# mise.toml が検出された場合
mise run lint

# package.json が検出された場合
npm run lint

# フォールバック（TypeScript/JavaScript）
npx eslint .
```

### Lint Fix Command

```bash
# mise.toml が検出された場合
mise run lint-fix

# package.json が検出された場合
npm run lint:fix

# フォールバック（TypeScript/JavaScript）
npx eslint --fix .
```

### Output Example (Success Path)

```
🔍 Step 2/3: Lint実行
  $ mise run lint
  ❌ 5件のエラー検出

  $ mise run lint-fix
  ✅ 5件中5件を自動修正

  $ mise run lint
  ✅ Lintエラーなし
```

### Output Example (Partial Fix Path)

```
🔍 Step 2/3: Lint実行
  $ mise run lint
  ❌ 8件のエラー検出

  $ mise run lint-fix
  ✅ 8件中6件を自動修正

  $ mise run lint
  ❌ 2件のエラーが残っています

  🔧 残りのエラーを手動修正中...

  エラー 1/2:
  src/utils.ts:15:7
  'foo' is assigned a value but never used (@typescript-eslint/no-unused-vars)

  修正: 変数 'foo' を削除

  エラー 2/2:
  src/index.ts:42:3
  Expected 'error' to be handled (@typescript-eslint/no-floating-promises)

  修正: .catch() ハンドラーを追加

  $ mise run lint
  ✅ すべてのlintエラーを修正
```

### Error Classification

#### Auto-fixable Errors

- Formatting issues (spacing, quotes, semicolons)
- Import ordering
- Simple style violations

#### Manual Fix Required

- Unused variables (要判断)
- Type errors (要コード理解)
- Logic errors (要設計判断)

## 📋 Step 3: Test Execution & Fix

### Purpose

テストを実行し、失敗したテストを修正します。

### Execution

```bash
# mise.toml が検出された場合
mise run test

# package.json が検出された場合
npm test

# フォールバック（TypeScript/JavaScript）
npm test
```

### Success Detection

```python
def is_test_success(result):
    """Test実行が成功したか判定"""
    return result.returncode == 0
```

### Output Example (Success)

```
✅ Step 3/3: Test実行
  $ mise run test
  PASS src/utils.test.ts
  PASS src/index.test.ts

  Test Suites: 2 passed, 2 total
  Tests:       15 passed, 15 total

  ✅ すべてのテストが成功
```

### Output Example (Failure)

```
✅ Step 3/3: Test実行
  $ mise run test
  FAIL src/utils.test.ts
    ● should calculate sum correctly

      expect(received).toBe(expected)

      Expected: 5
      Received: 3

  Tests:       1 failed, 14 passed, 15 total

  🔧 失敗したテストを修正中...

  修正内容:
  src/utils.ts:10
  - return a + b - 2;  // バグ
  + return a + b;      // 修正

  $ mise run test
  ✅ すべてのテストが成功
```

### Test Skip Logic

テストコマンドが検出されない場合はスキップ：

```
✅ Step 3/3: Test実行（スキップ）
  ⊘ testコマンドが検出されませんでした
  ℹ️  package.json に "test" スクリプトを追加してください
```

## 🔄 Iteration Logic

### Maximum Attempts

最大3回まで試行：

```python
MAX_ATTEMPTS = 3

def execute_polish():
    """Code polish実行"""
    for attempt in range(1, MAX_ATTEMPTS + 1):
        print(f"🔄 試行 {attempt}/{MAX_ATTEMPTS}")

        # Step 1: Format
        if not execute_format():
            continue

        # Step 2: Lint
        if not execute_lint():
            continue

        # Step 3: Test
        if not execute_test():
            continue

        # すべて成功
        print(f"🎉 Code Polish 完了！（{attempt}回目）")
        return True

    # 最大試行回数に達した
    print(f"⚠️  最大試行回数（{MAX_ATTEMPTS}回）に達しました")
    return False
```

### Early Success

1回目で成功した場合：

```
🔄 試行 1/3

🎨 Step 1/3: Format実行
  ✅ フォーマット完了

🔍 Step 2/3: Lint実行
  ✅ Lintエラーなし

✅ Step 3/3: Test実行
  ✅ すべてのテストが成功

🎉 Code Polish 完了！（1回目）
```

### Multiple Iterations

2回目で成功した場合：

```
🔄 試行 1/3

🎨 Step 1/3: Format実行
  ✅ フォーマット完了

🔍 Step 2/3: Lint実行
  ❌ 3件のエラー検出
  ✅ 3件中2件を自動修正
  ❌ 1件のエラーが残っています

🔄 試行 2/3

🔍 Step 2/3: Lint実行（再試行）
  🔧 残りのエラーを手動修正中...
  ✅ すべてのlintエラーを修正

✅ Step 3/3: Test実行
  ✅ すべてのテストが成功

🎉 Code Polish 完了！（2回目）
```

## 📊 Final Report

### Success Report

```
🎉 Code Polish 完了！

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 実行結果サマリー

✅ Format: 成功（3ファイル更新）
✅ Lint: 成功（5件修正）
✅ Test: 成功（15テスト）

⏱️  総実行時間: 12.3秒
🔄 試行回数: 2回
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Partial Success Report

```
⚠️  Code Polish 一部完了

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 実行結果サマリー

✅ Format: 成功
✅ Lint: 成功
❌ Test: 失敗（2テスト失敗）

⏱️  総実行時間: 18.7秒
🔄 試行回数: 3回（最大）

💡 次のステップ:
1. 失敗したテストを確認
2. テストコードまたは実装を修正
3. 再度 /polish を実行
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## 🔗 Related

- `configuration-detection.md` - 設定検出方法
- `comment-cleanup.md` - コメント整理ロジック
- `supported-projects.md` - 言語別の対応状況
