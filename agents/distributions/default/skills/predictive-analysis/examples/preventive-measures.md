# 予防措置の提案

リスクを事前に防ぐための具体的な予防策と実装例。

## 開発プロセスへの統合

### 1. コード品質ゲート

### CI/CDパイプラインに組み込む

```yaml
# .github/workflows/quality-check.yml
name: Quality Gate

on: [pull_request]

jobs:
  quality-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      # 静的解析
      - name: ESLint
        run: npm run lint

      # 複雑性チェック
      - name: Complexity Check
        run: npx complexity-report --threshold 15 src/

      # セキュリティスキャン
      - name: Security Audit
        run: npm audit --audit-level=moderate

      # テストカバレッジ
      - name: Test Coverage
        run: npm test -- --coverage --coverageThreshold='{"global":{"branches":80,"functions":80,"lines":80}}'

      # 型チェック
      - name: TypeScript Check
        run: npm run type-check
```

### 2. Pre-commit Hooks

### Huskyでローカル検証

```json
// package.json
{
  "husky": {
    "hooks": {
      "pre-commit": "npm run pre-commit"
    }
  },
  "scripts": {
    "pre-commit": "npm run lint-staged && npm run type-check",
    "lint-staged": "lint-staged"
  },
  "lint-staged": {
    "*.{ts,tsx}": ["eslint --fix", "prettier --write"]
  }
}
```

### 3. コードレビューチェックリスト

### PRテンプレートに組み込む

```markdown
## Code Review Checklist

### セキュリティ

- [ ] ユーザー入力はすべて検証されているか
- [ ] 認証・認可チェックが適切に実装されているか
- [ ] シークレット情報がハードコードされていないか

### パフォーマンス

- [ ] N+1クエリは発生していないか
- [ ] アルゴリズムの時間計算量は適切か
- [ ] メモリリークの可能性はないか

### 技術的負債

- [ ] 関数の複雑度は15以下か
- [ ] コードの重複はないか
- [ ] 命名は明確で一貫しているか

### テスト

- [ ] ユニットテストが追加されているか
- [ ] エッジケースがカバーされているか
- [ ] カバレッジが低下していないか
```

## 静的解析ツールの設定

### ESLint設定

### セキュリティとパフォーマンスの検出

```javascript
// .eslintrc.js
module.exports = {
  extends: [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
    "plugin:security/recommended",
  ],
  plugins: ["security", "sonarjs"],
  rules: {
    // セキュリティ
    "security/detect-sql-injection": "error",
    "security/detect-unsafe-regex": "error",
    "security/detect-eval-with-expression": "error",

    // 複雑性
    complexity: ["error", 15],
    "max-depth": ["error", 4],
    "max-lines-per-function": ["warn", 100],

    // パフォーマンス
    "sonarjs/cognitive-complexity": ["error", 15],
    "sonarjs/no-identical-functions": "error",

    // TypeScript
    "@typescript-eslint/no-explicit-any": "error",
    "@typescript-eslint/no-unused-vars": "error",
  },
};
```

### SonarQube設定

### 包括的なコード品質管理

```yaml
# sonar-project.properties
sonar.projectKey=my-project
sonar.sources=src
sonar.tests=tests

# 品質ゲート
sonar.qualitygate.wait=true

# 複雑性閾値
sonar.complexity.threshold=15

# カバレッジ閾値
sonar.coverage.exclusions=**/*.test.ts
sonar.javascript.lcov.reportPaths=coverage/lcov.info

# セキュリティ
sonar.security.enabled=true
```

## アーキテクチャパターン

### 1. レイヤードアーキテクチャ

### 責任の分離

```typescript
// src/architecture/
// ├── presentation/    (Controllers, Routes)
// ├── application/     (Use Cases, DTOs)
// ├── domain/          (Entities, Business Logic)
// └── infrastructure/  (Database, External APIs)

// ドメイン層: ビジネスロジック
export class Order {
  constructor(private items: OrderItem[]) {}

  calculateTotal(): number {
    return this.items.reduce((sum, item) => sum + item.price, 0);
  }

  validate(): void {
    if (this.items.length === 0) {
      throw new DomainError("Order must have at least one item");
    }
  }
}

// アプリケーション層: ユースケース
export class CreateOrderUseCase {
  constructor(
    private orderRepository: OrderRepository,
    private paymentService: PaymentService,
  ) {}

  async execute(dto: CreateOrderDTO): Promise<Order> {
    const order = new Order(dto.items);
    order.validate();

    await this.paymentService.charge(order.calculateTotal());
    return await this.orderRepository.save(order);
  }
}

// プレゼンテーション層: コントローラー
export class OrderController {
  constructor(private createOrderUseCase: CreateOrderUseCase) {}

  async create(req: Request, res: Response) {
    try {
      const order = await this.createOrderUseCase.execute(req.body);
      res.status(201).json(order);
    } catch (error) {
      if (error instanceof DomainError) {
        res.status(400).json({ error: error.message });
      } else {
        res.status(500).json({ error: "Internal server error" });
      }
    }
  }
}
```

### 2. 依存性注入

### テスタビリティと疎結合

```typescript
// DIコンテナ
import { Container } from "inversify";

const container = new Container();

// インターフェース
interface PaymentProvider {
  charge(amount: number): Promise<void>;
}

// 実装
class StripePayment implements PaymentProvider {
  async charge(amount: number) {
    /* ... */
  }
}

class MockPayment implements PaymentProvider {
  async charge(amount: number) {
    /* モック */
  }
}

// バインディング
container
  .bind<PaymentProvider>("PaymentProvider")
  .to(process.env.NODE_ENV === "test" ? MockPayment : StripePayment);

// 使用
class OrderService {
  constructor(
    @inject("PaymentProvider") private paymentProvider: PaymentProvider,
  ) {}

  async process(order: Order) {
    await this.paymentProvider.charge(order.total);
  }
}
```

### 3. エラーハンドリング戦略

### 構造化されたエラー処理

```typescript
// エラークラス階層
abstract class ApplicationError extends Error {
  constructor(
    message: string,
    public code: string,
    public statusCode: number = 500,
  ) {
    super(message);
    this.name = this.constructor.name;
  }
}

class ValidationError extends ApplicationError {
  constructor(
    message: string,
    public fields?: Record<string, string>,
  ) {
    super(message, "VALIDATION_ERROR", 400);
  }
}

class NotFoundError extends ApplicationError {
  constructor(resource: string) {
    super(`${resource} not found`, "NOT_FOUND", 404);
  }
}

class UnauthorizedError extends ApplicationError {
  constructor(message: string = "Unauthorized") {
    super(message, "UNAUTHORIZED", 401);
  }
}

// グローバルエラーハンドラー
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  if (err instanceof ApplicationError) {
    logger.error(err.message, { code: err.code, stack: err.stack });
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

## モニタリングと観測可能性

### 1. ロギング戦略

### 構造化ログ

```typescript
import winston from "winston";

const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || "info",
  format: winston.format.json(),
  defaultMeta: { service: "api-service" },
  transports: [
    new winston.transports.File({ filename: "error.log", level: "error" }),
    new winston.transports.File({ filename: "combined.log" }),
  ],
});

// 使用例
logger.info("Order created", {
  orderId: order.id,
  userId: user.id,
  total: order.total,
  duration: Date.now() - startTime,
});

logger.error("Payment failed", {
  orderId: order.id,
  error: error.message,
  stack: error.stack,
});
```

### 2. メトリクス収集

### Prometheusメトリクス

```typescript
import promClient from "prom-client";

// カウンター
const orderCounter = new promClient.Counter({
  name: "orders_total",
  help: "Total number of orders",
  labelNames: ["status"],
});

// ヒストグラム (レスポンスタイム)
const httpDuration = new promClient.Histogram({
  name: "http_request_duration_seconds",
  help: "Duration of HTTP requests in seconds",
  labelNames: ["method", "route", "status"],
});

// ゲージ (現在の接続数)
const activeConnections = new promClient.Gauge({
  name: "active_connections",
  help: "Number of active connections",
});

// ミドルウェア
app.use((req, res, next) => {
  const start = Date.now();

  res.on("finish", () => {
    const duration = (Date.now() - start) / 1000;
    httpDuration
      .labels(
        req.method,
        req.route?.path || req.path,
        res.statusCode.toString(),
      )
      .observe(duration);
  });

  next();
});
```

### 3. ヘルスチェック

### 包括的なヘルスエンドポイント

```typescript
app.get("/health", async (req, res) => {
  const checks = await Promise.allSettled([
    checkDatabase(),
    checkRedis(),
    checkExternalAPI(),
  ]);

  const health = {
    status: checks.every((c) => c.status === "fulfilled")
      ? "healthy"
      : "degraded",
    timestamp: new Date().toISOString(),
    checks: {
      database: checks[0].status === "fulfilled" ? "up" : "down",
      redis: checks[1].status === "fulfilled" ? "up" : "down",
      externalAPI: checks[2].status === "fulfilled" ? "up" : "down",
    },
  };

  const statusCode = health.status === "healthy" ? 200 : 503;
  res.status(statusCode).json(health);
});

async function checkDatabase() {
  await db.query("SELECT 1");
}

async function checkRedis() {
  await redis.ping();
}

async function checkExternalAPI() {
  const response = await fetch("https://api.example.com/health", {
    timeout: 5000,
  });
  if (!response.ok) throw new Error("API unhealthy");
}
```

## セキュリティベストプラクティス

### 1. 入力検証

### Zodを使った型安全な検証

```typescript
import { z } from "zod";

const createUserSchema = z.object({
  email: z.string().email(),
  password: z
    .string()
    .min(8)
    .regex(/^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)/),
  age: z.number().int().min(18).max(120),
});

app.post("/users", async (req, res) => {
  try {
    const userData = createUserSchema.parse(req.body);
    const user = await createUser(userData);
    res.status(201).json(user);
  } catch (error) {
    if (error instanceof z.ZodError) {
      res.status(400).json({ errors: error.errors });
    }
  }
});
```

### 2. レート制限

### 柔軟なレート制限

```typescript
import rateLimit from "express-rate-limit";

// 一般的なエンドポイント
const generalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15分
  max: 100,
});

// 認証エンドポイント (厳しい制限)
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5,
  skipSuccessfulRequests: true,
});

// 検索エンドポイント (中程度の制限)
const searchLimiter = rateLimit({
  windowMs: 60 * 1000, // 1分
  max: 10,
});

app.use("/api", generalLimiter);
app.use("/auth", authLimiter);
app.use("/search", searchLimiter);
```

### 3. CORS設定

### 適切なCORS設定

```typescript
import cors from "cors";

const corsOptions = {
  origin: (origin, callback) => {
    const allowedOrigins = process.env.ALLOWED_ORIGINS?.split(",") || [];
    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error("Not allowed by CORS"));
    }
  },
  credentials: true,
  optionsSuccessStatus: 200,
};

app.use(cors(corsOptions));
```

## 継続的な改善

### 技術的負債の追跡

```typescript
// TODO: [TECH-DEBT] この関数は複雑度が高い (CC: 18)
// リファクタリング予定: 2026-03-01
// Issue: #123
function complexFunction() {
  // ...
}

// FIXME: [PERFORMANCE] O(n²) アルゴリズム
// 最適化予定: 次回スプリント
// Impact: 10000件で10秒
function inefficientSort(arr) {
  // ...
}
```

### 定期的なコードレビュー

```bash
# 月次コード品質レポート
npm run complexity-report > reports/$(date +%Y-%m).txt
npm run lint -- --format json > reports/lint-$(date +%Y-%m).json
npm run test -- --coverage --json > reports/coverage-$(date +%Y-%m).json
```
