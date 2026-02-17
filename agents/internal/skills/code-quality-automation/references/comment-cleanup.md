# Comment Cleanup

`--with-comments` オプションによるコメント整理の詳細。

## 🎯 Philosophy

### Goal

コードの可読性を向上させるため、冗長なコメントを削除します。

### Principle

- **削除**: コードを読めば分かるコメント
- **保持**: WHY（なぜ）を説明するコメント

### Non-Goal

ドキュメンテーションコメント（JSDoc, docstring等）の削除ではありません。

## 🔄 Execution Flow

### Overview

```python
def execute_comment_cleanup():
    """コメント整理実行"""

    # 1. コメント分析
    comments = analyze_comments()

    # 2. 冗長コメント抽出
    redundant = classify_redundant_comments(comments)

    # 3. ユーザー確認
    if not confirm_deletion(redundant):
        print("❌ コメント整理をキャンセルしました")
        return False

    # 4. コメント削除
    delete_comments(redundant)

    print(f"✅ {len(redundant)}件のコメントを削除しました")
    return True
```

### Step 1: Comment Analysis

```python
def analyze_comments():
    """コメントパターンを検出"""

    # Grep でコメント行を検出
    patterns = [
        r"//\s*\w+",           # JavaScript/TypeScript 単一行
        r"/\*.*?\*/",          # JavaScript/TypeScript 複数行
        r"#\s*\w+",            # Python/Shell 単一行
        r'""".*?"""',          # Python docstring
        r"<!--.*?-->",         # HTML/XML
    ]

    comments = []
    for pattern in patterns:
        matches = grep(pattern, recursive=True)
        comments.extend(matches)

    return comments
```

### Step 2: Redundant Comment Classification

```python
def classify_redundant_comments(comments):
    """冗長コメントを分類"""

    redundant = []
    valuable = []

    for comment in comments:
        if is_redundant(comment):
            redundant.append(comment)
        else:
            valuable.append(comment)

    return redundant
```

## 📋 Deletion Criteria

### Pattern 1: Code Repetition

コードの内容をそのまま繰り返すだけのコメント。

#### Examples (Delete)

```typescript
// Create user
function createUser() { }

// Constructor
constructor() { }

// Initialize
init() { }

// Return result
return result;

// Set value
this.value = value;
```

#### Why Delete?

コードを読めば分かる内容。コメントがあることで逆に冗長になる。

### Pattern 2: Obvious Content

自明な内容のコメント。

#### Examples (Delete)

```typescript
// Increment counter
counter++;

// Check if null
if (value === null) {
}

// Loop through items
for (const item of items) {
}

// Import React
import React from "react";

// Export component
export default MyComponent;
```

#### Why Delete?

コードの構文から明らか。コメントがあることで行数が増えるだけ。

### Pattern 3: Redundant Section Headers

セクションヘッダーが冗長な場合。

#### Examples (Delete)

```typescript
// Methods
method1() { }
method2() { }

// Properties
property1: string;
property2: number;

// Imports
import A from 'a';
import B from 'b';
```

#### Why Delete?

コードの構造から明らか。ファイルが小さければ不要。

### Pattern 4: Commented-Out Code

コメントアウトされたコード（バージョン管理があるため）。

#### Examples (Delete)

```typescript
// const oldValue = 123;
// function oldFunction() { }

/* Legacy code
function legacy() {
  // ...
}
*/
```

#### Why Delete?

Git履歴で管理できる。コメントアウトされたコードは混乱を招く。

## 📋 Preservation Criteria

### Pattern 1: WHY Explanation

「なぜ」を説明するコメント。

#### Examples (Keep)

```typescript
// HACK: Use setTimeout to avoid race condition with React 18 batching
setTimeout(() => setValue(newValue), 0);

// NOTE: This must be before useEffect to ensure proper initialization order
const ref = useRef(null);

// IMPORTANT: Do not change this order - it breaks the API contract
await step1();
await step2();
```

#### Why Keep?

コードからは分からない意図や理由を説明している。

### Pattern 2: Complex Business Logic

複雑なビジネスロジックの説明。

#### Examples (Keep)

```typescript
// Calculate tax based on progressive tax rates:
// 0-9,000: 10%
// 9,001-40,000: 20%
// 40,001+: 30%
function calculateTax(income: number) {}

// Apply discount based on customer tier and purchase history
// Tier 1: 5%, Tier 2: 10%, Tier 3: 15%
// Additional 5% for 10+ purchases in last 30 days
function calculateDiscount(customer: Customer) {}
```

#### Why Keep?

ビジネスルールを明確に文書化している。

### Pattern 3: TODO/FIXME/HACK Markers

タスクマーカー。

#### Examples (Keep)

```typescript
// TODO: Add error handling
// FIXME: Memory leak when component unmounts
// HACK: Temporary workaround for Safari bug
// NOTE: Remove this after API v2 is released
```

#### Why Keep?

将来のアクションアイテムを追跡するため。

### Pattern 4: Non-Obvious Behavior

非自明な動作の警告。

#### Examples (Keep)

```typescript
// WARNING: This function modifies the input array in-place
function sortArray(arr: number[]) {}

// CAUTION: Calling this multiple times can cause memory leaks
function subscribe() {}

// NOTE: Returns null if user is not authenticated
function getCurrentUser() {}
```

#### Why Keep?

予期しない動作を警告している。

### Pattern 5: Documentation Comments

API ドキュメンテーション。

#### Examples (Keep)

```typescript
/**
 * Create a new user account
 * @param email - User's email address
 * @param password - User's password (min 8 chars)
 * @returns The created user object
 */
function createUser(email: string, password: string): User { }

"""
Calculate the Fibonacci sequence up to n terms.

Args:
    n: Number of terms to generate

Returns:
    List of Fibonacci numbers
"""
def fibonacci(n: int) -> list[int]:
    pass
```

#### Why Keep?

公開APIの文書化。IDEで表示される。

### Pattern 6: Important Context

重要なコンテキスト情報。

#### Examples (Keep)

```typescript
// This component is used in 15+ places - changes require careful testing
export const Button = () => {};

// Performance: This runs on every render - keep it fast
const expensiveCalc = useMemo(() => {}, [deps]);

// Security: Never log this value - it contains sensitive data
const apiKey = process.env.API_KEY;
```

#### Why Keep?

重要な判断材料を提供している。

## 🔍 Classification Algorithm

### Implementation

```python
def is_redundant(comment):
    """コメントが冗長かどうか判定"""

    # 1. 特殊マーカーを含む場合は保持
    markers = ["TODO", "FIXME", "HACK", "NOTE", "WARNING", "CAUTION"]
    if any(marker in comment.text for marker in markers):
        return False

    # 2. ドキュメンテーションコメントは保持
    if is_documentation_comment(comment):
        return False

    # 3. 複数行の詳細な説明は保持
    if len(comment.lines) > 2:
        return False

    # 4. コードの構文をそのまま繰り返している場合は削除
    if repeats_code_syntax(comment):
        return True

    # 5. 一般的な冗長パターンに一致する場合は削除
    redundant_patterns = [
        r"^(create|set|get|initialize|constructor|import|export)\s",
        r"^(increment|decrement|check|loop|return)\s",
    ]
    if any(re.match(p, comment.text.lower()) for p in redundant_patterns):
        return True

    # 6. デフォルトは保持（慎重）
    return False
```

### Conservative Approach

疑わしい場合は保持します：

- **Delete**: 明らかに冗長なもののみ
- **Keep**: 価値があるかもしれないもの

## 📊 User Confirmation

### Confirmation Prompt

削除前にユーザーに確認：

```
🔍 冗長コメントを検出しました

削除候補: 12件

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. src/index.ts:15
   // Create user
   function createUser() { }

2. src/utils.ts:42
   // Return result
   return result;

3. src/components/Button.tsx:8
   // Constructor
   constructor() { }
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

（残り9件を表示するには Enter を押してください）

これらのコメントを削除しますか？ [y/N]
```

### User Options

- `y` / `yes`: すべて削除
- `n` / `no`: キャンセル
- `s` / `show`: すべての候補を表示
- `i` / `interactive`: 1件ずつ確認

## 💡 Best Practices

### When to Use `--with-comments`

推奨タイミング：

- コードレビュー後の最終クリーンアップ
- レガシーコードのリファクタリング時
- マージ前の最終確認

### When NOT to Use

避けるべきタイミング：

- 初回実装時（コメントが設計メモの場合）
- 他の人のコードを勝手に修正する場合
- ドキュメンテーションが重要なプロジェクト

### Manual Review

削除前に手動確認を推奨：

1. 削除候補を確認
2. 疑わしいものは保持
3. 削除後に動作確認
4. Git diffで変更を確認

## 🔗 Related

- `execution-flow.md` - 全体的な実行フロー
- `SKILL.md` - 基本的な使い方
