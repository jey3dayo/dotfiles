---
paths:
  - "{src,lib}/**/*.ts"
  - "{src,lib}/**/*.tsx"
---

# 型安全性: any 型禁止

## 制約

TypeScript コードで `any` 型の使用を禁止する。

すべての変数、関数引数、戻り値には明示的な型定義が必要。

## 根拠

- 型安全性を維持し、コンパイル時に型エラーを検出
- 実行時エラーを防ぎ、コードの信頼性を向上
- IntelliSense の精度向上により開発効率が向上
- リファクタリングの安全性を確保

## 例

### 正しい

明示的な型定義を使用:

```typescript
interface User {
  id: string;
  name: string;
  email: string;
}

function processUser(user: User): Result<ProcessedUser, Error> {
  return ok(transformUser(user));
}

// ジェネリクスで型安全性を保持
function fetchData<T>(url: string): Promise<Result<T, Error>> {
  // 明示的な型パラメータ
}
```

### 不正

any 型の使用:

```typescript
// any 型の使用（禁止）
function processData(data: any): any {
  return data.something;
}

// 暗黙的な any（禁止）
function handleEvent(event) {
  // event の型が不明
}

// 型アサーションの乱用（禁止）
const data = response as any;
```

## 例外

`unknown` 型を使用し、型ガードで安全に処理する場合のみ許容:

```typescript
function parseJSON(json: string): Result<unknown, Error> {
  try {
    const data: unknown = JSON.parse(json);
    if (isValidData(data)) {
      return ok(data);
    }
    return err(new Error("Invalid data"));
  } catch (e) {
    return err(e as Error);
  }
}
```

## 強制

- [x] ESLint: `@typescript-eslint/no-explicit-any`
- [x] TypeScript Compiler: `strict: true`, `noImplicitAny: true`
- [x] CI/CD: 型チェックが失敗すればビルドブロック

## 関連ルール

- `error-handling.md`: Result<T,E> パターンの使用
- `type-assertions.md`: 型アサーションの制限
