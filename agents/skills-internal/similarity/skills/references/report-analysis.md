# Similarity Report Analysis - レポート解析とリファクタリング計画

このドキュメントでは、`similarity-ts`が生成したレポートの読み方と、効果的なリファクタリング計画の立て方を説明します。

## 📊 レポートの構造

### 典型的なレポート出力

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Function: getUserById
  File: src/services/user-service.ts:42
  Lines: 5 | Tokens: 23

Function: getAdminById
  File: src/services/admin-service.ts:38
  Lines: 5 | Tokens: 24

Similarity: 0.94 (94%)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### レポート要素の読み方

1. **Function**: 関数名
2. **File**: ファイルパスと行番号
3. **Lines**: 行数
4. **Tokens**: トークン数（AST要素数）
5. **Similarity**: 類似度スコア（0.0-1.0）

## 🎯 レポート解析の手順

### Step 1: レポートの読み込み

```bash
# レポートファイルの場所
/tmp/similarity-report.md
```

スキル内でレポートを参照し、以下の情報を抽出:

- 検出された重複ペアの数
- 類似度の分布
- 最も高い類似度を持つペア
- 影響範囲（ファイル数、関数数）

### Step 2: 優先度の決定

類似度レベル別に優先度を付ける:

| 類似度      | 優先度 | アクション                   |
| ----------- | ------ | ---------------------------- |
| **95-100%** | 🔴 高  | 即座に共通化                 |
| **90-95%**  | 🟡 中  | 詳細分析後にリファクタリング |
| **87-90%**  | 🟢 低  | 将来のリファクタリング候補   |

### Step 3: 影響範囲の分析

重複コードの影響範囲を評価:

```typescript
// 影響範囲評価の観点
interface ImpactAnalysis {
  // 該当ファイルの層（Service, Action, Component等）
  layer: string;

  // 参照される回数
  referenceCount: number;

  // 依存するモジュール数
  dependencyCount: number;

  // テストカバレッジ
  testCoverage: number;
}
```

### Step 4: リファクタリング計画の立案

#### 4.1 共通化パターンの選択

##### パターン1: 単純な関数抽出

```typescript
// Before: 重複コード
// File: src/services/user-service.ts
export async function getUserById(id: string) {
  const user = await prisma.user.findUnique({ where: { id } });
  if (!user) throw new Error("User not found");
  return user;
}

// File: src/services/admin-service.ts
export async function getAdminById(id: string) {
  const admin = await prisma.admin.findUnique({ where: { id } });
  if (!admin) throw new Error("Admin not found");
  return admin;
}

// After: 共通関数抽出
// File: src/lib/repository-utils.ts
export async function findByIdOrThrow<T>(
  model: any,
  id: string,
  resourceName: string,
): Promise<T> {
  const record = await model.findUnique({ where: { id } });
  if (!record) throw new Error(`${resourceName} not found`);
  return record;
}
```

##### パターン2: 高階関数による抽象化

```typescript
// Before: 類似した処理パターン
async function processUserData(data: UserData) {
  const validated = validateUserData(data);
  const result = await saveUser(validated);
  await auditLog("USER_CREATED", result);
  return result;
}

async function processOrderData(data: OrderData) {
  const validated = validateOrderData(data);
  const result = await saveOrder(validated);
  await auditLog("ORDER_CREATED", result);
  return result;
}

// After: 高階関数で抽象化
async function processWithAudit<T, V>(
  data: T,
  validator: (data: T) => V,
  saver: (validated: V) => Promise<any>,
  auditAction: string,
) {
  const validated = validator(data);
  const result = await saver(validated);
  await auditLog(auditAction, result);
  return result;
}
```

##### パターン3: クラス/インターフェースによる統合

```typescript
// Before: 類似した型定義
interface UserCreateInput {
  name: string;
  email: string;
  role: string;
}

interface AdminCreateInput {
  name: string;
  email: string;
  permissions: string[];
}

// After: 共通基底型 + 拡張
interface BaseCreateInput {
  name: string;
  email: string;
}

interface UserCreateInput extends BaseCreateInput {
  role: string;
}

interface AdminCreateInput extends BaseCreateInput {
  permissions: string[];
}
```

#### 4.2 実装順序の決定

1. **テストの準備**: 既存の動作を保証するテストを作成
2. **共通関数の実装**: 新しい共通関数を作成
3. **段階的移行**: 一つずつ置き換え
4. **検証**: 各ステップでテスト実行
5. **クリーンアップ**: 未使用コードの削除

## 🔧 実践的な解析例

### 例1: Service層の重複検出レポート

```bash
# レポート生成
similarity-ts --threshold 0.9 src/services/ > /tmp/similarity-services.md
```

**レポート内容例**:

```
Found 15 similar function pairs
Average similarity: 0.92

High Priority (>95%):
- getUserById vs getAdminById (98%)
- deleteUser vs deleteAdmin (97%)

Medium Priority (90-95%):
- createUser vs createAdmin (93%)
- updateUser vs updateAdmin (91%)
```

**解析結果と計画**:

```markdown
## 解析サマリー

- 検出: 15ペア
- 高優先度: 2ペア（即時対応）
- 中優先度: 2ペア（計画的対応）

## リファクタリング計画

### Phase 1: 高優先度（即時実行）

1. **共通Repository層の作成**
   - `src/lib/repository/base-repository.ts`
   - `findByIdOrThrow<T>` 関数を実装
   - `delete<T>` 関数を実装

2. **影響範囲**:
   - user-service.ts: 2関数
   - admin-service.ts: 2関数
   - テスト: 4ファイル

3. **実装順序**:
   - [ ] テスト作成（既存動作の保証）
   - [ ] base-repository.ts作成
   - [ ] getUserById → findByIdOrThrow移行
   - [ ] getAdminById → findByIdOrThrow移行
   - [ ] deleteUser → delete移行
   - [ ] deleteAdmin → delete移行
   - [ ] テスト実行・検証

### Phase 2: 中優先度（計画的実行）

1. **Create/Update処理の共通化検討**
   - ビジネスロジックの差異を確認
   - 共通化可能な部分を抽出
```

### 例2: Action層のパターン統一

```bash
# FormData処理パターンの類似度チェック
similarity-ts --filter-function-body "FormData" --threshold 0.85 src/actions/ > /tmp/similarity-actions.md
```

**レポート内容例**:

```
Found 8 similar FormData processing patterns
Average similarity: 0.91

Pattern: FormData → Validation → Service Call
- createUserAction vs createPostAction (93%)
- updateUserAction vs updatePostAction (91%)
- deleteUserAction vs deletePostAction (89%)
```

**解析結果と計画**:

````markdown
## パターン分析

### 共通パターン

1. FormDataからオブジェクト抽出
2. Zodスキーマでバリデーション
3. Service層呼び出し
4. Result<T,E>パターンで返却

### リファクタリング提案

#### 共通ヘルパー関数の作成

```typescript
// src/lib/action-utils.ts
export async function processFormDataAction<T, E>(
  formData: FormData,
  schema: ZodSchema<T>,
  serviceCall: (data: T) => Promise<Result<E, Error>>,
): Promise<ServerActionResult<E>> {
  // FormData → Object
  const rawData = Object.fromEntries(formData);

  // Validation
  const validated = schema.safeParse(rawData);
  if (!validated.success) {
    return err(new ValidationError(validated.error));
  }

  // Service Call
  return convertFormDataToAction(() => serviceCall(validated.data));
}
```
````

#### 適用例

```typescript
// Before
export async function createUserAction(formData: FormData) {
  const rawData = Object.fromEntries(formData);
  const validated = CreateUserSchema.safeParse(rawData);
  if (!validated.success) {
    return err(new ValidationError(validated.error));
  }
  return convertFormDataToAction(() => createUserService(validated.data));
}

// After
export async function createUserAction(formData: FormData) {
  return processFormDataAction(formData, CreateUserSchema, createUserService);
}
```

````

## 🚀 ベストプラクティス

### レポート解析時の注意点

1. **類似度だけで判断しない**: ビジネスロジックの意図を確認
2. **テストカバレッジを確認**: リファクタリング前に適切なテストがあるか
3. **依存関係を把握**: MCP Serenaで参照を確認
4. **段階的に実行**: 一度に大量の変更は避ける

### 効果測定

リファクタリング後に以下を測定:

```bash
# コード重複率の測定
similarity-ts --threshold 0.9 src/ > /tmp/similarity-after.md

# 比較
# Before: 15 similar pairs
# After: 3 similar pairs
# 削減率: 80%
````

### ドキュメント化

リファクタリング結果を記録:

```bash
# /learnings コマンドで記録
/learnings refactoring "Service層の重複コード削減: 15→3ペア (80%削減)"
```

## 🔗 関連リソース

- **メインスキル**: `skill.md`
- **MCP Serena統合**: 影響範囲分析に活用
- **Refactoringコマンド**: `/refactoring` で自動適用

---

**目標**: レポート解析を通じて、効果的で安全なリファクタリング計画を立案する
