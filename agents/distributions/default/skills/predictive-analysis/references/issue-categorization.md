# 問題分類体系

予測的コード分析で検出される問題を体系的に分類し、各カテゴリの特徴と対応方針を定義します。

## 主要カテゴリ

### 1. セキュリティリスク

アプリケーションのセキュリティを脅かす脆弱性や不適切な実装。

#### 1.1 インジェクション攻撃

### SQLインジェクション

```typescript
// 危険: パラメータ化されていないクエリ
const query = `SELECT * FROM users WHERE id = ${userId}`;

// 推奨: プリペアドステートメント
const query = "SELECT * FROM users WHERE id = ?";
db.query(query, [userId]);
```

### コマンドインジェクション

```typescript
// 危険: ユーザー入力を直接シェルコマンドに渡す
exec(`rm ${userInput}`);

// 推奨: 入力検証と安全なAPI使用
if (!/^[a-zA-Z0-9_-]+$/.test(userInput)) throw new Error("Invalid input");
fs.unlink(path.join(SAFE_DIR, userInput));
```

### XSS (Cross-Site Scripting)

```typescript
// 危険: エスケープなしのHTML挿入
element.innerHTML = userInput;

// 推奨: サニタイズまたはテキストノード使用
element.textContent = userInput;
// または
element.innerHTML = DOMPurify.sanitize(userInput);
```

#### 1.2 認証・認可の不備

### 認証バイパス

```typescript
// 危険: 認証チェックの欠如
app.get("/admin/users", (req, res) => {
  res.json(getAllUsers());
});

// 推奨: 認証ミドルウェア
app.get("/admin/users", authenticateAdmin, (req, res) => {
  res.json(getAllUsers());
});
```

### 不適切なセッション管理

```typescript
// 危険: セッションの有効期限なし
session.set("user", userData);

// 推奨: タイムアウト設定
session.set("user", userData, { maxAge: 3600000 }); // 1時間
```

#### 1.3 データ露出

### ハードコードされたシークレット

```typescript
// 危険: ソースコードに秘密情報
const API_KEY = "sk_live_1234567890abcdef";

// 推奨: 環境変数
const API_KEY = process.env.API_KEY;
```

### 過剰なデータ露出

```typescript
// 危険: パスワードハッシュを含む全データ返却
res.json(user);

// 推奨: 必要なフィールドのみ返却
res.json({
  id: user.id,
  name: user.name,
  email: user.email,
});
```

#### 1.4 暗号化の問題

### 弱い暗号化アルゴリズム

```typescript
// 危険: MD5, SHA1
const hash = crypto.createHash("md5").update(password).digest("hex");

// 推奨: bcrypt, Argon2
const hash = await bcrypt.hash(password, 12);
```

### 2. パフォーマンスボトルネック

スケーラビリティとレスポンスタイムに影響する実装。

#### 2.1 アルゴリズム効率

### O(n²) 以上の複雑度

```typescript
// 危険: ネストループによる O(n²)
users.forEach((user) => {
  user.orders = orders.filter((o) => o.userId === user.id);
});

// 推奨: Map による O(n)
const ordersByUser = orders.reduce((acc, order) => {
  (acc[order.userId] = acc[order.userId] || []).push(order);
  return acc;
}, {});
users.forEach((user) => {
  user.orders = ordersByUser[user.id] || [];
});
```

### 不要な再計算

```typescript
// 危険: ループ内で毎回計算
for (let i = 0; i < items.length; i++) {
  if (expensiveCalculation() > threshold) {
    /* ... */
  }
}

// 推奨: ループ外で1回計算
const result = expensiveCalculation();
for (let i = 0; i < items.length; i++) {
  if (result > threshold) {
    /* ... */
  }
}
```

#### 2.2 データベースの問題

### N+1 クエリ

```typescript
// 危険: ループ内でクエリ実行
const users = await User.findAll();
for (const user of users) {
  user.orders = await Order.findAll({ where: { userId: user.id } });
}

// 推奨: JOIN またはバッチ取得
const users = await User.findAll({
  include: [{ model: Order }],
});
```

### インデックスの欠如

```sql
-- 危険: インデックスなしの検索
SELECT * FROM orders WHERE user_id = ? AND status = ?;

-- 推奨: 複合インデックス
CREATE INDEX idx_orders_user_status ON orders(user_id, status);
```

#### 2.3 メモリ管理

### メモリリーク

```typescript
// 危険: イベントリスナーの削除忘れ
element.addEventListener("click", handler);
// removeEventListener が呼ばれない

// 推奨: クリーンアップ
const cleanup = () => {
  element.removeEventListener("click", handler);
};
```

### 無制限なキャッシュ

```typescript
// 危険: サイズ制限なし
const cache = {};
function addToCache(key, value) {
  cache[key] = value; // 無限に増加
}

// 推奨: LRU キャッシュ
const cache = new LRUCache({ max: 1000, ttl: 3600000 });
```

#### 2.4 非同期処理の非効率

### 逐次的な非同期処理

```typescript
// 危険: 順番に実行
const user = await fetchUser(id);
const orders = await fetchOrders(id);
const products = await fetchProducts(id);

// 推奨: 並列実行
const [user, orders, products] = await Promise.all([
  fetchUser(id),
  fetchOrders(id),
  fetchProducts(id),
]);
```

### 3. 技術的負債

長期的な保守性とコード品質に関する問題。

#### 3.1 高複雑度

### 循環的複雑度が高い

```typescript
// 危険: CC = 25
function processOrder(order, user, config) {
  if (order.type === "standard") {
    if (user.isPremium) {
      if (config.discount > 0) {
        // 10階層のネスト、20の分岐
      }
    }
  }
}

// 推奨: 分割と早期リターン
function processOrder(order, user, config) {
  if (order.type !== "standard") return processSpecialOrder(order);
  if (!user.isPremium) return processRegularOrder(order);
  return processPremiumOrder(order, config);
}
```

#### 3.2 コード重複

### ロジックの重複

```typescript
// 危険: 同じロジックが複数箇所
function validateUserEmail(email) {
  const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return regex.test(email);
}

function validateAdminEmail(email) {
  const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return regex.test(email);
}

// 推奨: 共通化
function validateEmail(email) {
  const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return regex.test(email);
}
```

#### 3.3 密結合

### ハードコードされた依存

```typescript
// 危険: 具体的な実装への依存
class OrderService {
  processOrder(order) {
    const payment = new StripePayment(); // 密結合
    payment.charge(order.amount);
  }
}

// 推奨: 依存性注入
class OrderService {
  constructor(private paymentProvider: PaymentProvider) {}

  processOrder(order) {
    this.paymentProvider.charge(order.amount);
  }
}
```

#### 3.4 不適切な命名

### 意味不明な名前

```typescript
// 危険: 省略形や意味不明な名前
function proc(d) {
  const r = d.map((x) => x * 2);
  return r;
}

// 推奨: 明確な名前
function processData(values: number[]): number[] {
  const doubled = values.map((value) => value * 2);
  return doubled;
}
```

### 4. スケーラビリティの問題

システムの成長に対応できない実装。

#### 4.1 ハードコードされた制限

```typescript
// 危険: 固定値
const MAX_USERS = 1000;

// 推奨: 設定可能
const MAX_USERS = config.maxUsers || Infinity;
```

#### 4.2 単一障害点

```typescript
// 危険: 単一インスタンス
const cache = new Map(); // メモリ内キャッシュ

// 推奨: 分散キャッシュ
const cache = new Redis({ cluster: true });
```

#### 4.3 同期的なブロッキング処理

```typescript
// 危険: 大量のデータを同期処理
const results = files.map((file) => fs.readFileSync(file));

// 推奨: ストリーミング処理
async function* processFiles(files) {
  for (const file of files) {
    yield await processFile(file);
  }
}
```

### 5. エラーハンドリングの不備

#### 5.1 エラーの無視

```typescript
// 危険: エラーを無視
try {
  riskyOperation();
} catch (e) {
  // 何もしない
}

// 推奨: 適切なハンドリング
try {
  riskyOperation();
} catch (error) {
  logger.error("Operation failed", { error });
  throw new ApplicationError("Failed to complete operation", { cause: error });
}
```

#### 5.2 不適切なエラー伝播

```typescript
// 危険: 詳細なエラー情報を外部に露出
app.use((err, req, res, next) => {
  res.status(500).json({ error: err.stack }); // スタックトレース露出
});

// 推奨: 一般的なメッセージ
app.use((err, req, res, next) => {
  logger.error(err);
  res.status(500).json({ error: "Internal server error" });
});
```

## 分類マトリクス

### カテゴリとリスクレベルの関係

| カテゴリ                   | Critical | High   | Medium | Low    |
| -------------------------- | -------- | ------ | ------ | ------ |
| セキュリティリスク         | 多い     | 中     | 少ない | 稀     |
| パフォーマンスボトルネック | 少ない   | 多い   | 中     | 中     |
| 技術的負債                 | 稀       | 少ない | 多い   | 多い   |
| スケーラビリティ問題       | 少ない   | 中     | 多い   | 中     |
| エラーハンドリング不備     | 中       | 中     | 多い   | 少ない |

### カテゴリと発生タイミング

| カテゴリ                   | 即座   | 短期   | 中期   | 長期   |
| -------------------------- | ------ | ------ | ------ | ------ |
| セキュリティリスク         | 多い   | 中     | 少ない | 稀     |
| パフォーマンスボトルネック | 少ない | 中     | 多い   | 中     |
| 技術的負債                 | 稀     | 少ない | 中     | 多い   |
| スケーラビリティ問題       | 稀     | 少ない | 多い   | 多い   |
| エラーハンドリング不備     | 中     | 多い   | 中     | 少ない |

## プロジェクト種別による優先度

### Webアプリケーション

1. セキュリティリスク (最優先)
2. パフォーマンスボトルネック
3. スケーラビリティ問題
4. 技術的負債

### CLIツール

1. エラーハンドリング不備 (最優先)
2. パフォーマンスボトルネック
3. 技術的負債
4. セキュリティリスク

### ライブラリ

1. 技術的負債 (最優先)
2. パフォーマンスボトルネック
3. エラーハンドリング不備
4. スケーラビリティ問題

## 検出優先度

### Phase 1: 即座に検出すべき問題

- セキュリティリスク (Critical/High)
- 明らかなパフォーマンスボトルネック
- エラーハンドリングの致命的な欠陥

### Phase 2: 詳細分析で検出する問題

- 技術的負債の蓄積
- スケーラビリティの制約
- 保守性の問題

### Phase 3: 長期的な観察で検出する問題

- コードの変更頻度とバグ密度の相関
- 技術的負債の成長率
- チーム生産性への影響
