# リスク軽減戦略

検出された問題カテゴリごとの具体的な対策パターンと実装ガイド。

## セキュリティリスクの軽減

### SQLインジェクション対策

### 戦略

```typescript
// Before: 脆弱
const query = `SELECT * FROM users WHERE email = '${userEmail}'`;
db.execute(query);

// After: 安全
const query = "SELECT * FROM users WHERE email = ?";
db.execute(query, [userEmail]);

// ORM使用
const user = await User.findOne({ where: { email: userEmail } });
```

### 追加対策

- ORM/クエリビルダーの活用 (Prisma, TypeORM, Knex)
- 入力バリデーションとサニタイゼーション
- 最小権限の原則 (データベースユーザー権限の制限)

### XSS対策

### 戦略

```typescript
// Before: 脆弱
element.innerHTML = userInput;

// After: 安全
// オプション1: テキストノード使用
element.textContent = userInput;

// オプション2: サニタイズライブラリ
import DOMPurify from "dompurify";
element.innerHTML = DOMPurify.sanitize(userInput);

// オプション3: フレームワークの自動エスケープ
// React: {userInput} (自動エスケープ)
// Vue: {{ userInput }} (自動エスケープ)
```

### 追加対策

- Content Security Policy (CSP) の設定
- HttpOnly, Secure フラグ付きクッキー
- 信頼できるタイプシステム (Trusted Types API)

### 認証・認可の強化

### 戦略

```typescript
// Before: 認証なし
app.get("/admin/users", (req, res) => {
  res.json(getAllUsers());
});

// After: 認証・認可付き
app.get(
  "/admin/users",
  authenticate, // 認証確認
  requireRole("admin"), // ロール確認
  (req, res) => {
    res.json(getAllUsers());
  },
);

// ミドルウェア実装例
function authenticate(req, res, next) {
  const token = req.headers.authorization?.split(" ")[1];
  if (!token) return res.status(401).json({ error: "Unauthorized" });

  try {
    req.user = jwt.verify(token, process.env.JWT_SECRET);
    next();
  } catch (error) {
    res.status(401).json({ error: "Invalid token" });
  }
}

function requireRole(role) {
  return (req, res, next) => {
    if (req.user.role !== role) {
      return res.status(403).json({ error: "Forbidden" });
    }
    next();
  };
}
```

### 追加対策

- セッションタイムアウトの設定
- レート制限 (ブルートフォース対策)
- 多要素認証 (MFA) の導入
- 監査ログの記録

### シークレット管理

### 戦略

```typescript
// Before: ハードコード
const API_KEY = "sk_live_1234567890abcdef";

// After: 環境変数
const API_KEY = process.env.API_KEY;
if (!API_KEY) throw new Error("API_KEY is required");

// 本番環境: シークレット管理サービス
import { SecretsManager } from "@aws-sdk/client-secrets-manager";

async function getSecret(secretName) {
  const client = new SecretsManager({ region: "us-east-1" });
  const response = await client.getSecretValue({ SecretId: secretName });
  return JSON.parse(response.SecretString);
}
```

### .env ファイル管理

```bash
# .gitignore に追加
.env
.env.local
.env.*.local

# .env.example を提供
API_KEY=your_api_key_here
DATABASE_URL=postgresql://localhost:5432/mydb
```

## パフォーマンスボトルネックの軽減

### アルゴリズム最適化

### 戦略

```typescript
// Before: O(n²)
function findDuplicates(arr) {
  const duplicates = [];
  for (let i = 0; i < arr.length; i++) {
    for (let j = i + 1; j < arr.length; j++) {
      if (arr[i] === arr[j]) duplicates.push(arr[i]);
    }
  }
  return duplicates;
}

// After: O(n)
function findDuplicates(arr) {
  const seen = new Set();
  const duplicates = new Set();

  for (const item of arr) {
    if (seen.has(item)) {
      duplicates.add(item);
    }
    seen.add(item);
  }

  return Array.from(duplicates);
}
```

### 最適化パターン

- **配列 → Set/Map**: O(n) の検索が必要な場合
- **ネストループ → 単一ループ**: データの前処理で解決
- **再帰 → ループ**: スタックオーバーフロー回避

### N+1クエリ問題の解決

### 戦略

```typescript
// Before: N+1 クエリ
const users = await User.findAll();
for (const user of users) {
  user.orders = await Order.findAll({ where: { userId: user.id } });
}

// After: JOIN
const users = await User.findAll({
  include: [{ model: Order }],
});

// After: DataLoader (GraphQL推奨)
import DataLoader from "dataloader";

const orderLoader = new DataLoader(async (userIds) => {
  const orders = await Order.findAll({
    where: { userId: { [Op.in]: userIds } },
  });

  const ordersByUser = orders.reduce((acc, order) => {
    (acc[order.userId] = acc[order.userId] || []).push(order);
    return acc;
  }, {});

  return userIds.map((id) => ordersByUser[id] || []);
});

// 使用
const orders = await orderLoader.load(userId);
```

### メモリリーク対策

### 戦略

```typescript
// Before: メモリリーク
class EventManager {
  listeners = [];

  addEventListener(listener) {
    this.listeners.push(listener);
    // removeが呼ばれないと無限に蓄積
  }
}

// After: クリーンアップ機能
class EventManager {
  listeners = new Set();

  addEventListener(listener) {
    this.listeners.add(listener);
    return () => this.removeEventListener(listener); // クリーンアップ関数を返す
  }

  removeEventListener(listener) {
    this.listeners.delete(listener);
  }
}

// 使用
const cleanup = eventManager.addEventListener(handleEvent);
// コンポーネント破棄時
cleanup();
```

### LRUキャッシュの実装

```typescript
import LRU from "lru-cache";

const cache = new LRU({
  max: 1000, // 最大エントリ数
  ttl: 1000 * 60 * 60, // 1時間
  updateAgeOnGet: true, // アクセス時に有効期限をリセット
  dispose: (value, key) => {
    // エントリが削除されるときのクリーンアップ
    value.cleanup?.();
  },
});
```

### 非同期処理の最適化

### 戦略

```typescript
// Before: 逐次処理
async function fetchUserData(userId) {
  const user = await fetchUser(userId); // 100ms
  const orders = await fetchOrders(userId); // 100ms
  const products = await fetchProducts(userId); // 100ms
  return { user, orders, products }; // 合計: 300ms
}

// After: 並列処理
async function fetchUserData(userId) {
  const [user, orders, products] = await Promise.all([
    fetchUser(userId),
    fetchOrders(userId),
    fetchProducts(userId),
  ]);
  return { user, orders, products }; // 合計: 100ms
}

// ストリーミング処理
async function* processLargeDataset(items) {
  const BATCH_SIZE = 100;

  for (let i = 0; i < items.length; i += BATCH_SIZE) {
    const batch = items.slice(i, i + BATCH_SIZE);
    yield await processBatch(batch);
  }
}

// 使用
for await (const result of processLargeDataset(largeArray)) {
  console.log(result);
}
```

## 技術的負債の軽減

### 複雑性の削減

### 戦略

```typescript
// Before: 高複雑度 (CC = 20)
function processOrder(order, user, config) {
  if (order.type === "standard") {
    if (user.isPremium) {
      if (config.discount > 0) {
        if (order.total > 100) {
          // 深いネスト...
        }
      }
    }
  }
}

// After: 低複雑度 (CC = 5)
function processOrder(order, user, config) {
  if (order.type !== "standard") return processSpecialOrder(order);
  if (!user.isPremium) return processStandardOrder(order);
  if (config.discount <= 0) return processWithoutDiscount(order, user);
  if (order.total <= 100) return processSmallOrder(order, config);

  return processLargePremiumOrder(order, user, config);
}
```

### リファクタリングパターン

- **Extract Method**: 長い関数を小さな関数に分割
- **Replace Nested Conditional with Guard Clauses**: 早期リターンで浅いネスト
- **Replace Conditional with Polymorphism**: 条件分岐をクラス階層に変換

### コード重複の解消

### 戦略

```typescript
// Before: 重複
function validateUserEmail(email) {
  const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!regex.test(email)) throw new Error("Invalid email");
}

function validateAdminEmail(email) {
  const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!regex.test(email)) throw new Error("Invalid email");
}

// After: 共通化
function validateEmail(email: string, userType?: string) {
  const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!regex.test(email)) {
    throw new Error(`Invalid ${userType || ""} email`);
  }
}

// テンプレートメソッドパターン
abstract class EntityValidator<T> {
  validate(entity: T) {
    this.validateRequired(entity);
    this.validateFormat(entity);
    this.validateBusinessRules(entity);
  }

  abstract validateRequired(entity: T): void;
  abstract validateFormat(entity: T): void;
  abstract validateBusinessRules(entity: T): void;
}

class UserValidator extends EntityValidator<User> {
  validateRequired(user: User) {
    /* ... */
  }
  validateFormat(user: User) {
    /* ... */
  }
  validateBusinessRules(user: User) {
    /* ... */
  }
}
```

### 密結合の解消

### 戦略

```typescript
// Before: 密結合
class OrderService {
  processOrder(order: Order) {
    const payment = new StripePayment(); // 具体的な実装に依存
    payment.charge(order.amount);
  }
}

// After: 疎結合
interface PaymentProvider {
  charge(amount: number): Promise<void>;
}

class StripePayment implements PaymentProvider {
  async charge(amount: number) {
    /* ... */
  }
}

class OrderService {
  constructor(private paymentProvider: PaymentProvider) {}

  async processOrder(order: Order) {
    await this.paymentProvider.charge(order.amount);
  }
}

// 使用
const orderService = new OrderService(new StripePayment());

// テストでは
const mockPayment = { charge: jest.fn() };
const orderService = new OrderService(mockPayment);
```

## スケーラビリティ問題の軽減

### ハードコード制限の解消

### 戦略

```typescript
// Before: ハードコード
const MAX_CONNECTIONS = 10;
const TIMEOUT = 5000;

// After: 設定ファイル
// config/default.json
{
  "database": {
    "maxConnections": 100,
    "timeout": 30000
  },
  "cache": {
    "ttl": 3600
  }
}

// 設定の読み込み
import config from 'config';

const dbConfig = config.get('database');
const pool = new Pool({
  max: dbConfig.maxConnections,
  connectionTimeoutMillis: dbConfig.timeout
});
```

### 単一障害点の排除

### 戦略

```typescript
// Before: メモリ内キャッシュ (単一障害点)
const cache = new Map();

// After: 分散キャッシュ
import Redis from "ioredis";

const redis = new Redis.Cluster([
  { host: "redis-1", port: 6379 },
  { host: "redis-2", port: 6379 },
  { host: "redis-3", port: 6379 },
]);

// フォールバック機能付き
async function getCachedData(key) {
  try {
    return await redis.get(key);
  } catch (error) {
    logger.warn("Redis unavailable, fallback to database");
    return await database.get(key);
  }
}
```

## エラーハンドリングの改善

### 構造化されたエラー処理

### 戦略

```typescript
// エラークラスの定義
class ApplicationError extends Error {
  constructor(
    message: string,
    public code: string,
    public statusCode: number = 500,
    public metadata?: Record<string, any>,
  ) {
    super(message);
    this.name = this.constructor.name;
    Error.captureStackTrace(this, this.constructor);
  }
}

class ValidationError extends ApplicationError {
  constructor(message: string, metadata?: Record<string, any>) {
    super(message, "VALIDATION_ERROR", 400, metadata);
  }
}

// 使用
function validateUser(user) {
  if (!user.email) {
    throw new ValidationError("Email is required", { field: "email" });
  }
}

// エラーハンドリングミドルウェア
app.use((err, req, res, next) => {
  if (err instanceof ApplicationError) {
    logger.error(err.message, { code: err.code, metadata: err.metadata });
    res.status(err.statusCode).json({
      error: {
        code: err.code,
        message: err.message,
      },
    });
  } else {
    logger.error("Unexpected error", { error: err });
    res.status(500).json({
      error: {
        code: "INTERNAL_ERROR",
        message: "An unexpected error occurred",
      },
    });
  }
});
```

## 実装優先度

### High Priority (即座に実装)

1. セキュリティリスク全般
2. Critical/High パフォーマンスボトルネック
3. メモリリーク

### Medium Priority (計画的に実装)

1. 技術的負債 (高複雑度)
2. N+1 クエリ問題
3. 密結合の解消

### Low Priority (次回リファクタリング時)

1. コード重複
2. 命名規則の統一
3. コメントの整理
