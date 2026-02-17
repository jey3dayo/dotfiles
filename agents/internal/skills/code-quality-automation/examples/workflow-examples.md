# Workflow Examples

実際の使用例とワークフロー。

## 🎯 Use Case 1: Development Quality Assurance

### Scenario

開発中に定期的にコード品質をチェックしたい。

### Workflow

```bash
# 1. 機能実装
# コードを書く...

# 2. 品質チェック
/polish

# 3. エラーがあれば修正
# 自動修正されたコードを確認

# 4. コミット
/commit
```

### Execution Example

```
$ /polish

🔧 Code Polish を開始します

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 プロジェクト設定検出

✅ mise.toml 検出
   - format: prettier --write .
   - lint: eslint .
   - lint-fix: eslint --fix .
   - test: npm test

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔄 試行 1/3

🎨 Step 1/3: Format実行
  $ mise run format

  prettier --write .
  src/index.ts           50ms
  src/utils.ts           32ms
  src/api/client.ts      45ms

  ✅ フォーマット完了（3ファイル更新）

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔍 Step 2/3: Lint実行
  $ mise run lint

  ✅ Lintエラーなし

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Step 3/3: Test実行
  $ mise run test

  PASS src/utils.test.ts
  PASS src/index.test.ts
  PASS src/api/client.test.ts

  Test Suites: 3 passed, 3 total
  Tests:       18 passed, 18 total
  Snapshots:   0 total
  Time:        2.145 s

  ✅ すべてのテストが成功

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎉 Code Polish 完了！

📊 実行結果サマリー

✅ Format: 成功（3ファイル更新）
✅ Lint: 成功
✅ Test: 成功（18テスト）

⏱️  総実行時間: 5.2秒
🔄 試行回数: 1回
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Benefits

- 早期にエラーを検出
- コードレビューの負担を軽減
- 一貫したコード品質を維持

## 🎯 Use Case 2: Post-Review Fix

### Scenario

コードレビューで指摘された問題を修正した後、品質を確認したい。

### Workflow

```bash
# 1. レビュー指摘を確認
# GitHub PR のコメントを読む

# 2. 修正実施
# 指摘された箇所を修正

# 3. 品質チェック
/polish

# 4. すべて成功したらコミット
/commit -m "fix: Address review comments"
```

### Execution Example (With Errors)

```
$ /polish

🔧 Code Polish を開始します

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 プロジェクト設定検出

✅ mise.toml 検出
   - format: prettier --write .
   - lint: eslint .
   - lint-fix: eslint --fix .
   - test: npm test

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔄 試行 1/3

🎨 Step 1/3: Format実行
  $ mise run format

  ✅ フォーマット完了（2ファイル更新）

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔍 Step 2/3: Lint実行
  $ mise run lint

  ❌ 5件のエラー検出

  /src/api/client.ts
    42:7   error  'response' is assigned a value but never used  @typescript-eslint/no-unused-vars
    58:15  error  Unsafe assignment of an 'any' value            @typescript-eslint/no-unsafe-assignment

  /src/utils.ts
    15:3   error  Missing return type on function                @typescript-eslint/explicit-function-return-type
    28:5   error  Expected 'error' to be handled                 @typescript-eslint/no-floating-promises
    35:10  error  Prefer nullish coalescing operator             @typescript-eslint/prefer-nullish-coalescing

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  💡 自動修正を試行します...

  $ mise run lint-fix

  ✅ 5件中3件を自動修正

  自動修正されたエラー:
  - Missing return type (1件)
  - Prefer nullish coalescing (1件)
  - (部分的) no-unused-vars (1件)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  $ mise run lint

  ❌ 2件のエラーが残っています

  /src/api/client.ts
    58:15  error  Unsafe assignment of an 'any' value  @typescript-eslint/no-unsafe-assignment

  /src/utils.ts
    28:5   error  Expected 'error' to be handled       @typescript-eslint/no-floating-promises

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  🔧 残りのエラーを手動修正中...

  エラー 1/2: Unsafe assignment
  ファイル: src/api/client.ts:58

  コード:
  const data = response.data; // 型が any

  修正:
  const data: ApiResponse = response.data;

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  エラー 2/2: Unhandled promise
  ファイル: src/utils.ts:28

  コード:
  fetchData(url);  // Promise が放置されている

  修正:
  void fetchData(url);  // 明示的に無視

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  $ mise run lint

  ✅ すべてのlintエラーを修正

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Step 3/3: Test実行
  $ mise run test

  ✅ すべてのテストが成功

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎉 Code Polish 完了！

📊 実行結果サマリー

✅ Format: 成功（2ファイル更新）
✅ Lint: 成功（5件修正）
✅ Test: 成功（18テスト）

⏱️  総実行時間: 8.7秒
🔄 試行回数: 1回
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Benefits

- レビュー指摘の修正漏れを防ぐ
- 型安全性を確保
- 新しいエラーを導入しない

## 🎯 Use Case 3: Pre-Merge Final Check

### Scenario

マージ前に最終的な品質チェックを実行したい。

### Workflow

```bash
# 1. 最終品質チェック（コメント整理含む）
/polish --with-comments

# 2. すべて成功したら
/commit -m "chore: Final polish before merge"

# 3. PRを作成（または更新）
/create-pr
```

### Execution Example (With Comment Cleanup)

```
$ /polish --with-comments

🔧 Code Polish を開始します

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 プロジェクト設定検出

✅ mise.toml 検出

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔄 試行 1/3

🎨 Step 1/3: Format実行
  ✅ フォーマット完了

🔍 Step 2/3: Lint実行
  ✅ Lintエラーなし

✅ Step 3/3: Test実行
  ✅ すべてのテストが成功

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🗑️  コメント整理を実行します

🔍 冗長コメントを検出中...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
削除候補: 8件

1. src/index.ts:15
   // Create user
   function createUser() { }

2. src/index.ts:42
   // Return result
   return result;

3. src/utils.ts:8
   // Constructor
   constructor() { }

4. src/utils.ts:25
   // Increment counter
   counter++;

5. src/api/client.ts:12
   // Import axios
   import axios from 'axios';

6. src/api/client.ts:50
   // Set value
   this.value = value;

7. src/api/client.ts:65
   // Loop through items
   for (const item of items) { }

8. src/api/client.ts:88
   // Check if null
   if (value === null) { }

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

保持されるコメント例:

1. src/utils.ts:45
   // HACK: Use setTimeout to avoid race condition
   setTimeout(() => setValue(value), 0);

2. src/api/client.ts:120
   // NOTE: This must run before useEffect
   const ref = useRef(null);

3. src/api/client.ts:155
   // TODO: Add retry logic

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

これらのコメントを削除しますか？ [y/N/show/interactive]
> y

🗑️  8件のコメントを削除しました

✅ コメント整理完了

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎉 Code Polish 完了！

📊 実行結果サマリー

✅ Format: 成功
✅ Lint: 成功
✅ Test: 成功
✅ Comment Cleanup: 8件削除

⏱️  総実行時間: 6.5秒
🔄 試行回数: 1回
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Benefits

- マージ前の最終確認
- 冗長なコメントを削除してコードをクリーンに
- レビュアーの負担を軽減

## 🎯 Use Case 4: Legacy Code Refactoring

### Scenario

レガシーコードをリファクタリングする際に品質を確保したい。

### Workflow

```bash
# 1. リファクタリング実施
# コードを整理、構造変更...

# 2. テストが通ることを確認
/polish

# 3. さらにコメントを整理
/polish --with-comments

# 4. コミット
/commit -m "refactor: Modernize codebase"
```

### Execution Example (Multiple Iterations)

```
$ /polish

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔄 試行 1/3

🎨 Step 1/3: Format実行
  ✅ フォーマット完了（12ファイル更新）

🔍 Step 2/3: Lint実行
  ❌ 23件のエラー検出

  $ mise run lint-fix
  ✅ 23件中18件を自動修正

  ❌ 5件のエラーが残っています

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔄 試行 2/3

🔍 Step 2/3: Lint実行（再試行）
  🔧 残りのエラーを手動修正中...

  エラー 1/5: Unused variable
  修正: 変数 'foo' を削除

  エラー 2/5: Type error
  修正: 型アノテーションを追加

  エラー 3/5: Missing return type
  修正: 戻り値の型を指定

  エラー 4/5: Unsafe any
  修正: 適切な型を指定

  エラー 5/5: Unhandled promise
  修正: .catch() を追加

  $ mise run lint
  ✅ すべてのlintエラーを修正

✅ Step 3/3: Test実行
  $ mise run test

  FAIL src/legacy/old-module.test.ts
    ● should handle edge case

  🔧 失敗したテストを修正中...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔄 試行 3/3

✅ Step 3/3: Test実行（再試行）
  $ mise run test
  ✅ すべてのテストが成功

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎉 Code Polish 完了！

📊 実行結果サマリー

✅ Format: 成功（12ファイル更新）
✅ Lint: 成功（23件修正）
✅ Test: 成功（42テスト）

⏱️  総実行時間: 25.8秒
🔄 試行回数: 3回
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Benefits

- 大規模リファクタリングでも品質を保証
- 自動修正で手作業を最小化
- テスト失敗にも対応

## 💡 Tips for Each Use Case

### Development Quality Assurance

- コミット前に毎回実行する習慣をつける
- CI でも同じチェックを実行
- mise.toml を活用して統一的に管理

### Post-Review Fix

- レビュー指摘の修正後は必ず実行
- 新しいエラーを導入していないか確認
- 型安全性を重視

### Pre-Merge Final Check

- `--with-comments` で最終クリーンアップ
- すべて成功してからマージ
- レビュアーの負担を軽減

### Legacy Code Refactoring

- 段階的にリファクタリング
- 各ステップでテストが通ることを確認
- エラーが多い場合は分割して実行

## 🔗 Related

- `SKILL.md` - 基本的な使い方
- `execution-flow.md` - 実行フロー詳細
- `comment-cleanup.md` - コメント整理詳細
