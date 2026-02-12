# プロジェクト別分析パターン

フレームワーク、言語、プロジェクト種別ごとの分析パターンと注意点。

## Webアプリケーション

### Express.js / Node.js

### 重点分析項目

1. セキュリティリスク (認証・認可)
2. N+1クエリ問題
3. 非同期処理の非効率
4. メモリリーク

### よくある問題パターン

```typescript
// パターン1: ミドルウェアの順序ミス
app.use(bodyParser.json());
app.use("/api", apiRouter);
app.use(authenticate); // 遅すぎる → /api が認証なし

// 推奨
app.use(bodyParser.json());
app.use(authenticate);
app.use("/api", apiRouter);

// パターン2: エラーハンドリングの欠如
app.get("/users/:id", async (req, res) => {
  const user = await User.findByPk(req.params.id); // エラー処理なし
  res.json(user);
});

// 推奨
app.get("/users/:id", async (req, res, next) => {
  try {
    const user = await User.findByPk(req.params.id);
    if (!user) return res.status(404).json({ error: "User not found" });
    res.json(user);
  } catch (error) {
    next(error);
  }
});

// パターン3: 同期的なブロッキング処理
app.post("/process", (req, res) => {
  const result = heavyComputation(req.body); // ブロッキング
  res.json(result);
});

// 推奨
app.post("/process", async (req, res) => {
  const jobId = await queueJob(req.body);
  res.json({ jobId, status: "processing" });
});
```

### 分析コマンド例

```bash
# セキュリティリスク
grep -r "execute.*\`.*\${" --include="*.ts" --include="*.js"
grep -r "app\.(get|post|put|delete)" | grep -v "authenticate"

# N+1クエリ
grep -r "await.*findAll\|await.*findByPk" --include="*.ts" -A 5 | grep "for.*of\|forEach"

# メモリリーク
grep -r "addEventListener\|on\(" --include="*.ts" | grep -v "removeEventListener\|off\("
```

### React / Frontend SPA

### 重点分析項目

1. 不要な再レンダリング
2. メモリリーク (イベントリスナー、タイマー)
3. バンドルサイズ
4. XSS脆弱性

### よくある問題パターン

```tsx
// パターン1: 依存配列の不備
function Component({ data }) {
  const [result, setResult] = useState([]);

  useEffect(() => {
    setResult(expensiveCalculation(data));
  }); // 依存配列なし → 毎回実行

  // 推奨
  useEffect(() => {
    setResult(expensiveCalculation(data));
  }, [data]);

  // さらに良い: useMemo
  const result = useMemo(() => expensiveCalculation(data), [data]);
}

// パターン2: クリーンアップの欠如
useEffect(() => {
  const timer = setInterval(() => fetchData(), 1000);
  // クリーンアップなし → メモリリーク
}, []);

// 推奨
useEffect(() => {
  const timer = setInterval(() => fetchData(), 1000);
  return () => clearInterval(timer);
}, []);

// パターン3: 大きなバンドル
import * as lodash from "lodash"; // 全体インポート → 70KB
const result = lodash.map(data, fn);

// 推奨
import map from "lodash/map"; // 必要な関数のみ → 2KB
const result = map(data, fn);
```

### 分析コマンド例

```bash
# useEffect依存配列チェック
grep -r "useEffect\(" --include="*.tsx" --include="*.ts" -A 10 | grep -E "^\s*\}\);" -B 10

# イベントリスナーのクリーンアップ
grep -r "addEventListener" --include="*.tsx" -A 15 | grep "return.*removeEventListener" -c

# バンドルサイズ
npx webpack-bundle-analyzer dist/stats.json
```

### Next.js / SSR

### 重点分析項目

1. データフェッチ戦略 (getServerSideProps vs getStaticProps)
2. 画像最適化
3. API Routes のセキュリティ
4. ハイドレーションの問題

### よくある問題パターン

```tsx
// パターン1: 不適切なデータフェッチ
export async function getServerSideProps() {
  const data = await fetchAllData(); // 毎回サーバーで実行
  return { props: { data } };
}

// 推奨: 静的生成可能なページ
export async function getStaticProps() {
  const data = await fetchAllData();
  return {
    props: { data },
    revalidate: 3600, // 1時間ごとに再生成
  };
}

// パターン2: 画像の非最適化
<img src="/large-image.jpg" />; // 最適化なし

// 推奨
import Image from "next/image";
<Image src="/large-image.jpg" width={800} height={600} />;

// パターン3: API Routes の認証不備
// pages/api/admin/users.ts
export default async function handler(req, res) {
  const users = await getAllUsers(); // 認証なし
  res.json(users);
}

// 推奨
export default async function handler(req, res) {
  const session = await getSession({ req });
  if (!session || session.user.role !== "admin") {
    return res.status(403).json({ error: "Forbidden" });
  }
  const users = await getAllUsers();
  res.json(users);
}
```

## データベース中心のアプリケーション

### PostgreSQL / MySQL

### 重点分析項目

1. インデックスの欠如
2. N+1クエリ
3. トランザクションの不備
4. スロークエリ

### よくある問題パターン

```sql
-- パターン1: インデックスなしの検索
SELECT * FROM orders WHERE user_id = ? AND status = ?;
-- users: 100万件、実行時間: 5秒

-- 推奨: 複合インデックス
CREATE INDEX idx_orders_user_status ON orders(user_id, status);
-- 実行時間: 10ms

-- パターン2: SELECT *
SELECT * FROM users WHERE id = ?; -- 全カラム取得

-- 推奨: 必要なカラムのみ
SELECT id, name, email FROM users WHERE id = ?;

-- パターン3: トランザクション不備
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;
-- エラー時に不整合

-- 推奨: トランザクション
BEGIN;
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;
COMMIT;
```

### 分析コマンド例

```bash
# スロークエリ検出 (PostgreSQL)
psql -c "SELECT query, calls, total_time, mean_time FROM pg_stat_statements ORDER BY mean_time DESC LIMIT 10;"

# インデックス欠如
psql -c "SELECT schemaname, tablename, indexname FROM pg_indexes WHERE tablename = 'orders';"
```

### ORM (Prisma, TypeORM, Sequelize)

### 重点分析項目

1. N+1クエリ
2. Eager/Lazy loadingの使い分け
3. トランザクション管理
4. 生成されるクエリの効率

### よくある問題パターン

```typescript
// パターン1: N+1クエリ (TypeORM)
const users = await userRepository.find();
for (const user of users) {
  user.orders = await orderRepository.find({ where: { userId: user.id } });
}

// 推奨
const users = await userRepository.find({
  relations: ["orders"],
});

// パターン2: 過剰なEager loading
const user = await userRepository.findOne(1, {
  relations: ["orders", "orders.products", "orders.products.categories"],
}); // 全て取得 → 重い

// 推奨: 必要なものだけ
const user = await userRepository.findOne(1, {
  relations: ["orders"],
});

// パターン3: トランザクション外での複数操作
await userRepository.save(user);
await orderRepository.save(order); // 途中でエラーの可能性

// 推奨: トランザクション
await getConnection().transaction(async (manager) => {
  await manager.save(user);
  await manager.save(order);
});
```

## マイクロサービス / API

### 重点分析項目

1. API設計 (RESTful, GraphQL)
2. レート制限
3. エラーハンドリング
4. サーキットブレーカー

### よくある問題パターン

```typescript
// パターン1: レート制限なし
app.get("/api/search", async (req, res) => {
  const results = await expensiveSearch(req.query.q);
  res.json(results);
}); // DDoS脆弱

// 推奨
import rateLimit from "express-rate-limit";

const limiter = rateLimit({
  windowMs: 60 * 1000, // 1分
  max: 10, // 最大10リクエスト
});

app.get("/api/search", limiter, async (req, res) => {
  const results = await expensiveSearch(req.query.q);
  res.json(results);
});

// パターン2: サーキットブレーカーなし
async function callExternalAPI() {
  return await fetch("https://api.example.com/data"); // 障害時に無限リトライ
}

// 推奨
import CircuitBreaker from "opossum";

const breaker = new CircuitBreaker(callExternalAPI, {
  timeout: 3000,
  errorThresholdPercentage: 50,
  resetTimeout: 30000,
});

breaker.fallback(() => ({ error: "Service temporarily unavailable" }));
```

## CLIツール

### 重点分析項目

1. メモリリーク
2. ストリーム処理
3. エラーハンドリング
4. 進捗表示

### よくある問題パターン

```typescript
// パターン1: 大量ファイルの一括読み込み
const files = fs.readdirSync("./logs");
const contents = files.map((f) => fs.readFileSync(f, "utf-8")); // メモリ不足

// 推奨: ストリーム処理
import { pipeline } from "stream/promises";

await pipeline(
  fs.createReadStream("./logs/large.log"),
  transform,
  fs.createWriteStream("./output.txt"),
);

// パターン2: エラー時のクリーンアップ不足
async function processFiles() {
  const tempDir = await fs.mkdtemp("/tmp/process-");
  await doWork(tempDir); // エラー時にtempDirが残る
}

// 推奨
async function processFiles() {
  const tempDir = await fs.mkdtemp("/tmp/process-");
  try {
    await doWork(tempDir);
  } finally {
    await fs.rm(tempDir, { recursive: true });
  }
}
```

## モバイルアプリ (React Native)

### 重点分析項目

1. パフォーマンス (FlatList最適化)
2. メモリ管理
3. バッテリー消費
4. ネットワーク効率

### よくある問題パターン

```tsx
// パターン1: FlatListの非最適化
<FlatList
  data={items}
  renderItem={({ item }) => <Item data={item} />}
/>

// 推奨
<FlatList
  data={items}
  renderItem={({ item }) => <Item data={item} />}
  keyExtractor={item => item.id}
  removeClippedSubviews={true}
  maxToRenderPerBatch={10}
  windowSize={5}
  getItemLayout={(data, index) => ({
    length: ITEM_HEIGHT,
    offset: ITEM_HEIGHT * index,
    index
  })}
/>

// パターン2: 位置情報の連続取得
useEffect(() => {
  const timer = setInterval(() => {
    Geolocation.getCurrentPosition(updateLocation);
  }, 1000); // バッテリー消費大
}, []);

// 推奨
useEffect(() => {
  const watchId = Geolocation.watchPosition(updateLocation, null, {
    distanceFilter: 10, // 10m移動時のみ更新
    maximumAge: 10000
  });
  return () => Geolocation.clearWatch(watchId);
}, []);
```

## プロジェクト規模別の戦略

### 小規模 (<5,000行)

### フォーカス

- セキュリティの基本 (認証、入力検証)
- 明らかなパフォーマンス問題のみ
- 技術的負債は無視 (拡大時に対応)

### 中規模 (5,000-50,000行)

### フォーカス

- セキュリティ全般
- N+1クエリ、O(n²) アルゴリズム
- 高複雑度関数のリファクタリング
- スケーラビリティの計画

### 大規模 (50,000行以上)

### フォーカス

- すべてのカテゴリ
- アーキテクチャレベルの問題
- マイクロサービス分割の検討
- 継続的な品質監視
