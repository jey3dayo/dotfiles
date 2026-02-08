# Type Safety Patterns - 実証済みパターン集

> CAAD Loca Nextプロジェクトで実証されたany型排除・型安全性向上のパターン集
>
> **実績**: any型93件 → 0件（100%排除達成）、型アサーション67%削減

## 📋 目次

1. [緊急対応パターン](#緊急対応パターン)
2. [4つの型安全性原則](#4つの型安全性原則)
3. [型アサーション完全排除](#型アサーション完全排除)
4. [Zodスキーマ統合](#zodスキーマ統合)
5. [Result<T,E>型安全統合](#resultte型安全統合)
6. [層別実装パターン](#層別実装パターン)
7. [高度な型システム活用](#高度な型システム活用)
8. [E2Eテスト型安全性](#e2eテスト型安全性)
9. [実装チェックリスト](#実装チェックリスト)

## 緊急対応パターン

### 5分で型エラーを解決

#### 最優先対応（即時修正必須）

##### 1. any型の即時修正

```typescript
// 絶対NG
const data: any = response.data;
const handler = (e: any) => console.log(e);

// 即時修正
const data: unknown = response.data;
const handler = (e: Event) => console.log(e);
```

**any→unknown移行の利点**:

- 型安全性: unknownは使用前に型チェックを強制
- 後方互換性: any→unknownは安全な変換
- 段階的改善: 既存コードを壊さずに移行可能

##### 2. 型アサーションの除去

```typescript
// 危険
const user = rawData as User;
const value = formData.get("field") as string;

// 安全な修正
// パターン1: Zodスキーマ
const userResult = UserSchema.safeParse(rawData);
if (userResult.success) {
  const user = userResult.data;
}

// パターン2: 型ガード
function isString(value: unknown): value is string {
  return typeof value === "string";
}
```

## 4つの型安全性原則

1. **any型完全排除**
   - unknown型またはジェネリクス使用
   - 実行時検証の徹底

2. **型アサーション最小化**
   - 型ガード関数の活用
   - Zodスキーマによる検証

3. **Zodランタイム検証**
   - 外部データの厳格な検証
   - スキーマから型を自動生成（`z.infer`）

4. **Result<T,E>パターン**
   - 統一エラーハンドリング
   - 型安全な成功/失敗の表現

## 型アサーション完全排除

### パターン1: 基本的な型アサーション排除

```typescript
// 禁止パターン
const user = data as User;
const config = response as CMXConfig;
const value = formData.get("field") as string;

// 推奨パターン1: 型ガード関数
function isUser(data: unknown): data is User {
  return (
    typeof data === "object" &&
    data !== null &&
    "id" in data &&
    "name" in data &&
    typeof (data as any).id === "string" &&
    typeof (data as any).name === "string"
  );
}

if (isUser(data)) {
  // dataは型安全にUserとして扱える
  console.log(data.name);
}

// 推奨パターン2: Zodスキーマ検証
const userResult = UserSchema.safeParse(data);
if (userResult.success) {
  const user = userResult.data; // 型安全保証済み
  console.log(user.name);
}

// 推奨パターン3: FormData専用ヘルパー
const extractedData = extractFormFields(formData, ["field"]);
const validated = FormDataSchema.safeParse(extractedData);
```

### パターン2: 高度な型ガード実装

```typescript
// 複合型の型ガード
function isCMXLocationResponse(data: unknown): data is CMXLocationResponse {
  return (
    isObject(data) &&
    "macAddress" in data &&
    typeof data.macAddress === "string" &&
    (!("location" in data) || isLocationData(data.location))
  );
}

// 配列要素の型ガード
function isUserArray(data: unknown): data is User[] {
  return Array.isArray(data) && data.every(isUser);
}

// ジェネリック型ガード
function isRecord<T>(
  data: unknown,
  valueGuard: (value: unknown) => value is T,
): data is Record<string, T> {
  return (
    typeof data === "object" &&
    data !== null &&
    Object.values(data).every(valueGuard)
  );
}
```

### パターン3: 構造的型付けによる型アサーション除去

```typescript
// 危険な型アサーション
const result = {
  [key]: value as any,
};

// 構造的型付けによる解決
const result: Record<string, unknown> = {};
result[key] = value; // TypeScriptの構造的型付けが安全性を保証

// より型安全な実装
function createRecord<T>(key: string, value: T): Record<string, T> {
  const result = {} as Record<string, T>;
  result[key] = value;
  return result;
}
```

### パターン4: 残存する正当な型アサーションケース

```typescript
// 正当なケース1: ジェネリック制約での初期化
function createEmptyResult<T>(): T {
  return {} as T; // 呼び出し元が型責任を持つ
}

// 正当なケース2: 型ガード関数内での推論補助
function isValidShapeType(val: string): val is ShapeType {
  return SHAPE_TYPES.includes(val as ShapeType);
}

// 正当なケース3: const型アサーション
const routes = ["/home", "/about", "/contact"] as const;
type Route = (typeof routes)[number];
```

## Zodスキーマ統合

### パターン1: Schema-First型設計

```typescript
// 基本スキーマ定義
const UserCreateSchema = z.object({
  name: z.string().min(1).max(100),
  email: z.string().email(),
  department: z.enum(["Engineering", "Design", "Product"]),
  isActive: z.boolean().default(true),
});

// 型の自動生成
type UserCreateInput = z.infer<typeof UserCreateSchema>; // 入力型
type UserCreateOutput = z.output<typeof UserCreateSchema>; // 出力型（デフォルト値適用後）

// 部分スキーマの派生
const UserUpdateSchema = UserCreateSchema.partial();
const UserFormSchema = UserCreateSchema.omit({ id: true });
```

### パターン2: 階層的スキーマ設計

```typescript
// 基底スキーマ
const BaseEntitySchema = z.object({
  id: z.string().uuid(),
  createdAt: z.date(),
  updatedAt: z.date(),
});

// 拡張スキーマ
const UserSchema = BaseEntitySchema.extend({
  name: z.string(),
  email: z.string().email(),
  permissions: z.array(z.string()),
});

// リレーション付きスキーマ
const UserWithRoleSchema = UserSchema.extend({
  role: RoleSchema,
  department: DepartmentSchema.nullable(),
});

// レスポンス用スキーマ
const UserResponseSchema = z.object({
  data: UserSchema,
  meta: z.object({
    timestamp: z.string().datetime(),
    version: z.string(),
  }),
});
```

### パターン3: 日付処理の統一パターン

```typescript
// 統一された日付型
export const DateOrString = z.union([
  z.string().datetime(),
  z.instanceof(Date),
]);

// Prisma互換スキーマ
const PrismaUserSchema = z.object({
  id: z.string(),
  createdAt: DateOrString,
  updatedAt: DateOrString,
});

// 日付変換ヘルパー
const toISOString = (date: Date | string): string => {
  return typeof date === "string" ? date : date.toISOString();
};
```

### パターン4: スキーマ配置原則

```typescript
// 本番コード: schemas/ディレクトリに集約必須
import { UserSchema } from "@/lib/schemas/user-schemas";

// テストコード: テストファイル内での定義許可
// NOTE: Test-only schema for unit testing purposes
const testSchema = z.object({
  name: z.string(),
  age: z.number(),
});

// デバッグツール: スクリプト内での一時的定義許可
// NOTE: This is a temporary schema for debugging purposes only
const DebugSchema = z.object({
  debug: z.boolean(),
});
```

## Result<T,E>型安全統合

### パターン1: 基本的なResult処理

```typescript
// 型安全なエラーハンドリング
async function getUser(id: string): Promise<Result<User, ServiceError>> {
  // 入力検証
  if (!isValidUUID(id)) {
    return err(ServiceErrors.validation("Invalid user ID format"));
  }

  // API呼び出し
  const response = await api.getUser(id);

  // レスポンス検証
  const validationResult = UserSchema.safeParse(response.data);
  if (!validationResult.success) {
    return err(ServiceErrors.validation(validationResult.error));
  }

  return ok(validationResult.data);
}
```

### パターン2: Result連鎖パターン

```typescript
// 複雑なワークフローの型安全実装
const createUserWorkflow = (input: UserCreateInput) =>
  validateUserInput(input)
    .andThen((validatedData) =>
      checkEmailUniqueness(validatedData.email).map(() => validatedData),
    )
    .andThen((validatedData) => createUser(validatedData))
    .andThen((user) => assignDefaultRole(user))
    .andThen((userWithRole) => sendWelcomeEmail(userWithRole))
    .map((result) => ({
      success: true,
      userId: result.id,
      message: "User created successfully",
    }))
    .mapErr((error) => ({
      success: false,
      error: localizeError(error),
      code: error.code,
    }));
```

### パターン3: neverthrow err()関数による型安全再構築

```typescript
// 型アサーション依存
if (isDomainError(error)) {
  return toServerActionResult(result as Result<T, DomainError>);
}

// err()関数による型安全再構築
if (isDomainError(error)) {
  return toServerActionResult(err(error));
}

// 複数エラー型の処理
function handleMultipleErrorTypes<T>(
  result: Result<T, ServiceError | ValidationError | DomainError>,
): ServerActionResult<T> {
  if (result.isOk()) {
    return { success: true, data: result.value };
  }

  const error = result.error;
  if (isServiceError(error)) {
    return { success: false, error: "Service error occurred" };
  }
  if (isValidationError(error)) {
    return { success: false, error: error.message };
  }
  if (isDomainError(error)) {
    return { success: false, error: localizeDomainError(error) };
  }

  return { success: false, error: "Unknown error" };
}
```

### パターン4: neverthrow/must-use-result エラーの効率的修正

```typescript
// 問題のあるパターン
const result = await serviceCall();
if (result.isErr()) {
  return handleError(result.error);
}

// 適切な修正パターン
// 1. match()パターンで即座に処理
return result.match(
  (data) => createSuccess(transformData(data)),
  (error) => createFailure(error),
);

// 2. 複雑な処理が必要な場合のヘルパー関数分離
async function processSignedUrlGeneration(s3Key: string, floorPath: string) {
  const signedUrlResult = await generateSignedUrl(s3Key);
  return signedUrlResult.match(
    (url) => createSuccess({ url, floorPath }),
    (error) => createFailure(error),
  );
}
```

## 層別実装パターン

### Service層

```typescript
export class UserService {
  // API呼び出しの型安全化
  async getUser(id: string): Promise<Result<User, ServiceError>> {
    return handleApiResponse(
      this.api.get(`/users/${id}`),
      UserResponseSchema,
    ).map((response) => response.data);
  }

  // 複数データソースの統合
  async getUserWithDetails(
    id: string,
  ): Promise<Result<UserWithDetails, ServiceError>> {
    const userResult = await this.getUser(id);
    if (userResult.isErr()) return userResult;

    const detailsResult = await this.getUserDetails(id);
    if (detailsResult.isErr()) return detailsResult;

    return ok({
      ...userResult.value,
      details: detailsResult.value,
    });
  }
}
```

### Action層

```typescript
// FormData処理の型安全化
export async function createUserAction(
  _prevState: unknown,
  formData: FormData,
): Promise<ServerActionResult<User>> {
  // FormDataから値を抽出
  const extractedData = extractFormFields(formData, [
    "name",
    "email",
    "department",
  ]);

  // Zodスキーマで検証
  const validation = UserCreateSchema.safeParse(extractedData);
  if (!validation.success) {
    return {
      success: false,
      error: formatZodError(validation.error),
    };
  }

  // Service層の呼び出し
  const result = await userService.createUser(validation.data);

  // Result<T,E>からServerActionResultへの変換
  return toServerActionResult(result);
}
```

### Transform層

```typescript
// 型安全なデータ変換
export const createSafeTransformer = <TInput, TOutput>(
  inputSchema: z.ZodSchema<TInput>,
  outputSchema: z.ZodSchema<TOutput>,
  transform: (input: TInput) => TOutput,
) => {
  return (data: unknown): Result<TOutput, TransformError> => {
    // 入力検証
    const inputResult = inputSchema.safeParse(data);
    if (!inputResult.success) {
      return err(new TransformError("Invalid input", inputResult.error));
    }

    try {
      // 変換実行
      const transformed = transform(inputResult.data);

      // 出力検証
      const outputResult = outputSchema.safeParse(transformed);
      if (!outputResult.success) {
        return err(new TransformError("Invalid output", outputResult.error));
      }

      return ok(outputResult.data);
    } catch (error) {
      return err(new TransformError("Transform failed", error));
    }
  };
};

// 使用例
const prismaToUser = createSafeTransformer(
  PrismaUserSchema,
  UserSchema,
  (prismaUser) => ({
    id: prismaUser.id,
    name: prismaUser.name,
    email: prismaUser.email,
    createdAt: toISOString(prismaUser.createdAt),
  }),
);
```

### Repository層

```typescript
// Prisma型の活用
export class UserRepository {
  // Prismaの自動生成型を活用
  async findById(id: string): Promise<Result<PrismaUser, RepositoryError>> {
    try {
      const user = await prisma.user.findUnique({
        where: { id },
        include: {
          permissions: true,
          roles: true,
        },
      });

      if (!user) {
        return err(new RepositoryError("User not found", "NOT_FOUND"));
      }

      return ok(user);
    } catch (error) {
      return err(new RepositoryError("Database error", error));
    }
  }

  // 型安全なクエリビルダー
  private buildWhereClause(filters: UserFilters): Prisma.UserWhereInput {
    const where: Prisma.UserWhereInput = {};

    if (filters.name) {
      where.name = { contains: filters.name, mode: "insensitive" };
    }

    if (filters.email) {
      where.email = filters.email;
    }

    if (filters.isActive !== undefined) {
      where.isActive = filters.isActive;
    }

    return where;
  }
}
```

## 高度な型システム活用

### パターン1: 条件型・マップ型

```typescript
// 条件型での型安全性
type ApiResponse<T> = T extends string
  ? { message: T }
  : T extends object
    ? { data: T }
    : never;

// マップ型での型変換
type Optional<T> = {
  [K in keyof T]?: T[K];
};

type ReadOnly<T> = {
  readonly [K in keyof T]: T[K];
};

type Nullable<T> = {
  [K in keyof T]: T[K] | null;
};

// 実用例
type UserUpdate = Optional<Pick<User, "name" | "email" | "department">>;
type UserView = ReadOnly<User>;
type UserDraft = Nullable<UserCreate>;
```

### パターン2: テンプレートリテラル型

```typescript
// イベント型の型安全定義
type EntityType = "user" | "permission" | "role";
type ActionType = "create" | "update" | "delete";
type EventName = `${EntityType}.${ActionType}`;

// 型安全なイベントハンドラー
const eventHandlers: Record<EventName, (data: unknown) => void> = {
  "user.create": (data) => handleUserCreate(data),
  "user.update": (data) => handleUserUpdate(data),
  "user.delete": (data) => handleUserDelete(data),
  // TypeScriptが全パターンを要求
};

// ルーティングパターン
type Route = `/api/${EntityType}/${string}`;
const validRoute: Route = "/api/user/123"; // OK
```

### パターン3: ユーティリティ型の活用

```typescript
// 型の部分的な操作
type UserCreateDTO = Omit<User, "id" | "createdAt" | "updatedAt">;
type UserUpdateDTO = Partial<UserCreateDTO>;
type UserRequiredFields = Required<Pick<User, "id" | "email">>;

// 関数型の操作
type AsyncReturnType<T extends (...args: any) => Promise<any>> = T extends (
  ...args: any
) => Promise<infer R>
  ? R
  : never;

type GetUserReturn = AsyncReturnType<UserServiceMethods["getUser"]>; // User
```

### パターン4: 型推論の高度な活用

```typescript
// const assertionによる厳密な型
const ROLES = ["admin", "user", "guest"] as const;
type Role = (typeof ROLES)[number]; // 'admin' | 'user' | 'guest'

// 関数からの型推論
const createUser = (name: string, email: string) => ({
  id: crypto.randomUUID(),
  name,
  email,
  createdAt: new Date(),
});

type InferredUser = ReturnType<typeof createUser>;

// ジェネリック関数の型推論
function identity<T>(value: T): T {
  return value;
}

const str = identity("hello"); // string
const num = identity(42); // number
const user = identity({ id: "1" }); // { id: string }
```

## E2Eテスト型安全性

### Playwright型安全性パターン

#### API誤用パターンと修正

```typescript
// 問題パターン1: toHaveCount()でRegExp使用
await expect(spotRows).toHaveCount(/\d+/);
// TypeError: Argument of type 'RegExp' is not assignable to parameter of type 'number'

// 修正パターン1: count()メソッド + 数値比較
const spotRows = page.locator('[data-testid="spot-row"]');
const count = await spotRows.count();
expect(count).toBeGreaterThanOrEqual(1);

// 問題パターン2: Promiseに対するfirst()チェーン
await page.click('[data-testid="button"]').first();
// TypeError: Property 'first' does not exist on type 'Promise<void>'

// 修正パターン2: Locator-firstアプローチ
await page.locator('[data-testid="button"]').first().click();
```

#### 型安全E2Eテストパターン集

```typescript
// 要素カウント検証パターン
// パターン1: 最小数チェック
const items = page.locator('[data-testid="item"]');
const count = await items.count();
expect(count).toBeGreaterThan(0);

// パターン2: 具体数チェック
await expect(page.locator('[data-testid="item"]')).toHaveCount(5);

// パターン3: 範囲チェック
expect(count).toBeGreaterThan(0);
expect(count).toBeLessThan(100);

// 要素選択・操作パターン
// パターン1: Locator-first推奨アプローチ
await page.locator('[data-testid="button"]').first().click();
await page.locator('[data-testid="button"]').nth(1).click();
await page.locator('[data-testid="button"]').last().click();

// パターン2: 要素の事前キャッシュ
const targetElement = page.locator('[data-testid="complex-element"]');
await expect(targetElement).toBeVisible();
await targetElement.click();
const text = await targetElement.textContent();
```

#### 型安全セレクター戦略

```typescript
// セマンティック優先の型安全セレクター選択
// Priority 1: ロールベース（最推奨）
await page.getByRole("button", { name: "送信" }).click();
await page.getByRole("textbox", { name: "ユーザー名" }).fill("test");

// Priority 2: アクセシブルネーム
await page.getByLabel("メールアドレス").fill("test@example.com");

// Priority 3: テキストコンテンツ
await page.getByText("ログイン").click();

// data-testid は最後の手段（セマンティックアクセス困難時のみ）
await page.locator('[data-testid="complex-chart-element"]').click();

// 避けるべき: CSSクラス・ID（脆弱）
await page.locator(".btn-primary").click();
await page.locator("#submit-btn").click();
```

## 実装チェックリスト

### 基本チェック

- [ ] any型が使用されていない（any→unknown移行）
- [ ] 型アサーション（as）が最小限に抑えられている
- [ ] unknown型が適切に処理されている（型ガード/Zod検証）
- [ ] 型推論可能な箇所で明示的型指定していない

### Zodスキーマ

- [ ] 外部データ入力にZodスキーマが適用されている
- [ ] スキーマがschemas/ディレクトリに配置されている
- [ ] z.infer<>で型が生成されている
- [ ] 日付型にDateOrStringパターンを適用している

### Result<T,E>パターン

- [ ] エラーハンドリングにResult型が使用されている
- [ ] try-catchではなくResult型で処理されている
- [ ] エラー型が適切に定義されている
- [ ] err()関数で型安全な再構築を実施している

### 層別実装

- [ ] Service層: API呼び出しの型安全化
- [ ] Action層: FormData処理の型安全化
- [ ] Transform層: createSafeTransformer使用
- [ ] Repository層: Prisma型の活用

### E2Eテスト

- [ ] Locator-firstアプローチを使用
- [ ] セマンティックセレクターを優先
- [ ] count()メソッドで要素数検証
- [ ] data-testidは最後の手段として使用

## 避けるべきアンチパターン

```typescript
const antiPatterns = {
  typeAssertion: {
    bad: "config={config as any}",
    why: "型安全性完全破綻",
    alternative: "明示的型パラメータ指定",
  },

  suppressError: {
    bad: "// @ts-ignore",
    why: "エラー原因の隠蔽",
    alternative: "根本的型修正",
  },

  unknownCasting: {
    bad: "data as unknown as TargetType",
    why: "型検証の回避",
    alternative: "段階的型変換・検証",
  },
};
```

## 関連リソース

- [TypeScript Handbook - Type Guards](https://www.typescriptlang.org/docs/handbook/2/narrowing.html)
- [Zod Documentation](https://zod.dev/)
- [neverthrow Documentation](https://github.com/supermacro/neverthrow)
- [Playwright Best Practices](https://playwright.dev/docs/best-practices)
