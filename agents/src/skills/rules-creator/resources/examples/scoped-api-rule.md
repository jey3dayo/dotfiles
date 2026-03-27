---
paths:
  - "src/api/**/*.{ts,tsx}"
  - "src/routes/**/*.{ts,tsx}"
---

# API エンドポイント開発ルール

## 制約

すべての API エンドポイントは以下を満たすこと:

- リクエストボディは Zod スキーマで入力検証必須
- エラーレスポンスは標準形式 `{ error: string; code: string }` を使用
- レスポンス型を明示的に定義

## 根拠

- 不正な入力による実行時エラーを防止
- クライアント側で一貫したエラーハンドリングを実現
- API ドキュメントの自動生成を可能にする

## 例

### 正しい

```typescript
import { z } from "zod";

const createUserSchema = z.object({
  name: z.string().min(1),
  email: z.string().email(),
});

type CreateUserRequest = z.infer<typeof createUserSchema>;

export async function POST(req: Request): Promise<Response> {
  const parsed = createUserSchema.safeParse(await req.json());
  if (!parsed.success) {
    return Response.json(
      { error: "Validation failed", code: "VALIDATION_ERROR" },
      { status: 400 },
    );
  }
  const user = await createUser(parsed.data);
  return Response.json(user, { status: 201 });
}
```

### 不正

```typescript
// バリデーションなし（禁止）
export async function POST(req: Request) {
  const body = await req.json();
  const user = await createUser(body); // 未検証の入力
  return Response.json(user);
}
```

## 例外

- ヘルスチェックエンドポイント (`/api/health`) はバリデーション不要
- 内部専用エンドポイント（`// @internal` マーク付き）は簡易チェックで可

## 強制

- [x] コードレビューで確認
- [ ] カスタム ESLint ルール（検討中）

## 関連ルール

- `error-handling.md`: 標準エラーレスポンス形式
