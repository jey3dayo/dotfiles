# リスクレポート例

実際のプロジェクトでの予測的コード分析レポートの例と対応事例。

## 例1: Webアプリケーションの包括的分析

### プロジェクト概要

- 種別: Express.js + React SPA
- 規模: 約50,000行のコード
- チーム: 5人の開発者
- 期間: 開発6ヶ月目

### 分析レポート

````
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔮 Predictive Code Analysis Report
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Project: e-commerce-platform
Analyzed: 247 files, 52,341 lines
Date: 2026-02-12

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚨 CRITICAL ISSUES (3)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[1] SQLインジェクション脆弱性
📍 Location: src/api/products/search.ts:45-52
⚠️ Issue: ユーザー入力を直接SQL文字列に埋め込み
💥 Impact: データベース全体が攻撃者に露出
📅 Timeline: 即座に悪用可能
🔧 Effort: 2時間 (現在) vs 2日 (データ漏洩後の対応)

Code:
```typescript
45: async function searchProducts(query: string) {
46:   const sql = `SELECT * FROM products WHERE name LIKE '%${query}%'`;
47:   return db.execute(sql);
48: }
````

🛠️ Mitigation:

- プリペアドステートメントの使用
- ORMへの移行検討 (Prisma推奨)
- 入力サニタイゼーション

Suggested Fix:

```typescript
async function searchProducts(query: string) {
  return db.execute("SELECT * FROM products WHERE name LIKE ?", [`%${query}%`]);
}
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[2] 認証バイパス
📍 Location: src/api/admin/users.ts:23-30
⚠️ Issue: 管理者エンドポイントに認証チェックなし
💥 Impact: 全ユーザーデータが誰でもアクセス可能
📅 Timeline: 即座に悪用可能
🔧 Effort: 1時間 (現在) vs 1週間 (情報漏洩後の対応)

Code:

```typescript
23: router.get('/admin/users', async (req, res) => {
24:   const users = await User.findAll();
25:   res.json(users); // パスワードハッシュも含む
26: });
```

🛠️ Mitigation:

- 認証ミドルウェアの追加
- ロールベースアクセス制御 (RBAC)
- レスポンスデータの最小化

Suggested Fix:

```typescript
router.get(
  "/admin/users",
  authenticate,
  requireRole("admin"),
  async (req, res) => {
    const users = await User.findAll({
      attributes: { exclude: ["passwordHash"] },
    });
    res.json(users);
  },
);
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[3] ハードコードされたAPIキー
📍 Location: src/services/payment.ts:12
⚠️ Issue: Stripe APIキーがソースコードに直接記載
💥 Impact: GitHubに公開されると即座に不正利用
📅 Timeline: 既に危険な状態
🔧 Effort: 30分 (現在) vs 損失額不明 (漏洩後)

Code:

```typescript
12: const stripe = new Stripe('sk_live_1234567890abcdef');
```

🛠️ Mitigation:

- 環境変数への移行
- シークレット管理サービスの使用
- Git履歴からの削除 (BFG Repo-Cleaner)

Suggested Fix:

```typescript
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!);
if (!process.env.STRIPE_SECRET_KEY) {
  throw new Error("STRIPE_SECRET_KEY is not configured");
}
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔴 HIGH PRIORITY ISSUES (5)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[4] N+1クエリ問題
📍 Location: src/api/orders/list.ts:34-40
⚠️ Issue: 注文一覧取得時に各注文ごとにユーザー情報を取得
💥 Impact: 100件の注文で101回のクエリ実行、レスポンス遅延
📅 Timeline: 現在でも2秒、来月には5秒超の予測
🔧 Effort: 1時間 (現在) vs 3日 (パフォーマンス劣化後の緊急対応)

Code:

```typescript
34: const orders = await Order.findAll();
35: for (const order of orders) {
36:   order.user = await User.findByPk(order.userId);
37:   order.products = await Product.findAll({
38:     where: { orderId: order.id }
39:   });
40: }
```

🛠️ Mitigation:

- Eager loadingの使用
- JOINクエリへの変更
- DataLoaderの導入 (GraphQL)

Suggested Fix:

```typescript
const orders = await Order.findAll({
  include: [{ model: User }, { model: Product }],
});
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[5] O(n²) アルゴリズム
📍 Location: src/utils/product-matcher.ts:56-64
⚠️ Issue: ネストループによる商品マッチング
💥 Impact: 商品数1000件で処理時間10秒、10000件で1000秒
📅 Timeline: 来月の在庫拡大で破綻予測
🔧 Effort: 2時間 (現在) vs 1週間 (本番環境での緊急対応)

Code:

```typescript
56: function matchProducts(products, filters) {
57:   const matched = [];
58:   for (const product of products) {
59:     for (const filter of filters) {
60:       if (matchesFilter(product, filter)) {
61:         matched.push(product);
62:       }
63:     }
64:   }
65:   return matched;
66: }
```

🛠️ Mitigation:

- Mapを使った O(n) アルゴリズムに変更
- フィルタの前処理
- データベース側でのフィルタリング

Suggested Fix:

```typescript
function matchProducts(products, filters) {
  const filterSet = new Set(filters.map((f) => f.id));
  return products.filter((product) =>
    product.filterIds.some((id) => filterSet.has(id)),
  );
}
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️ MEDIUM PRIORITY ISSUES (12)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[6] 高複雑度関数
📍 Location: src/services/order-processor.ts:120-245
⚠️ Issue: 循環的複雑度 28 (閾値: 15)
💥 Impact: バグ混入リスク高、保守困難
📅 Timeline: 既に影響 (過去2ヶ月で3件のバグ)
🔧 Effort: 1日 (現在) vs 3日 (バグ修正の繰り返し)

Metrics:

- Cyclomatic Complexity: 28
- Lines of Code: 125
- Maintainability Index: 32 (閾値: 65)
- Change Frequency: 15回/月 (最多)

🛠️ Mitigation:

- 関数の分割 (Extract Method)
- 早期リターンの活用
- ポリモーフィズムでの条件分岐削減

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[7-12] その他Medium優先度の問題

- コード重複: 5箇所 (平均20行)
- 未使用インポート: 23件
- メモリリーク懸念: 2箇所
- エラーハンドリング不備: 8箇所
- 密結合: 4箇所
- 命名規則の不統一: 15箇所

詳細は添付レポート参照

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Total Issues: 20
Critical: 3 (要即座対応)
High: 5 (1週間以内)
Medium: 12 (1ヶ月以内)

Estimated Effort:
Immediate fixes: 6 hours
Planned refactoring: 3 days

Risk Score: 82/100 (High Risk)

Recommendations:

1. セキュリティ問題の即座対応 (Critical #1-3)
2. N+1クエリ問題の解決 (High #4)
3. アルゴリズム最適化の計画 (High #5)
4. 高複雑度関数のリファクタリング (Medium #6)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

```

### 対応結果

**Week 1**:
- Critical #1-3 を即座に修正 (6時間)
- セキュリティ監査パス

**Week 2**:
- High #4-5 を解決 (2日)
- レスポンスタイム 2秒 → 200ms

**Week 3-4**:
- Medium #6 のリファクタリング (3日)
- バグ発生率 50% 削減

## 例2: CLIツールのメモリリーク分析

### プロジェクト概要

- **種別**: Node.js CLIツール
- **用途**: ログ解析・可視化
- **規模**: 約5,000行

### 問題レポート

```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔮 Predictive Analysis: Memory Leak
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Critical] メモリリーク
📍 Location: src/parser/log-processor.ts:67-89
⚠️ Issue: ストリーム処理でイベントリスナーが蓄積
💥 Impact: 大量ログ処理時にメモリ不足でクラッシュ
📅 Timeline: 10GBのログで確実に発生
🔧 Effort: 1時間

Problem:

```typescript
67: function processLogs(filePath: string) {
68:   const stream = fs.createReadStream(filePath);
69:   const parser = new LogParser();
70:
71:   stream.on('data', chunk => {
72:     parser.parse(chunk);
73:   });
74:
75:   stream.on('end', () => {
76:     console.log('Done');
77:   });
78:   // リスナーが削除されない
79: }
```

Memory Usage Projection:

- 1GB file: 150 MB (OK)
- 10GB file: 1.5 GB (リスナー蓄積で 3GB超)
- 100GB file: クラッシュ確実

🛠️ Solution:

```typescript
function processLogs(filePath: string) {
  return new Promise((resolve, reject) => {
    const stream = fs.createReadStream(filePath);
    const parser = new LogParser();

    const onData = (chunk) => parser.parse(chunk);
    const onEnd = () => {
      cleanup();
      resolve();
    };
    const onError = (err) => {
      cleanup();
      reject(err);
    };

    const cleanup = () => {
      stream.removeListener("data", onData);
      stream.removeListener("end", onEnd);
      stream.removeListener("error", onError);
    };

    stream.on("data", onData);
    stream.on("end", onEnd);
    stream.on("error", onError);
  });
}
```

Verification:

- 100GB file: 150 MB 安定
- メモリ使用量 95% 削減

```

## 例3: React アプリケーションのパフォーマンス分析

### レポート

```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔮 Performance Bottleneck Analysis
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[High] 不要な再レンダリング
📍 Location: src/components/Dashboard.tsx:45-120
⚠️ Issue: useEffectの依存配列が不適切
💥 Impact: 毎秒10回の再レンダリング、CPU 80%
📅 Timeline: 既に発生中
🔧 Effort: 30分

Problem:

```tsx
45: function Dashboard({ data }) {
46:   const [processed, setProcessed] = useState([]);
47:
48:   useEffect(() => {
49:     setProcessed(expensiveCalculation(data));
50:   }); // 依存配列なし → 毎回実行
51: }
```

Performance Impact:

- Initial render: 200ms
- Re-render: 200ms × 10/sec = 2秒/秒 (CPU無駄)
- Battery drain: 2x faster

🛠️ Solution:

```tsx
function Dashboard({ data }) {
  const processed = useMemo(() => expensiveCalculation(data), [data]);
}
```

Results:

- Re-render: 10/sec → 0.1/sec
- CPU usage: 80% → 5%
- Battery life: 2x improvement

````

## リスク追跡の例

### Todo作成例

分析後に自動生成されるTodo:

```json
[
  {
    "content": "[Critical] SQLインジェクション修正 (src/api/products/search.ts)",
    "priority": "critical",
    "status": "pending",
    "metadata": {
      "category": "security",
      "effort": "2h",
      "risk_score": 95
    }
  },
  {
    "content": "[High] N+1クエリ解決 (src/api/orders/list.ts)",
    "priority": "high",
    "status": "pending",
    "metadata": {
      "category": "performance",
      "effort": "1h",
      "risk_score": 75
    }
  }
]
````

### GitHub Issue作成例

```markdown
### [Critical] SQLインジェクション脆弱性

**Location**: `src/api/products/search.ts:45-52`

**Description**:
ユーザー入力を直接SQL文字列に埋め込んでいるため、SQLインジェクション攻撃に対して脆弱です。

**Impact**:

- データベース全体が攻撃者に露出
- 顧客データの漏洩リスク
- 即座に悪用可能

**Risk Score**: 95/100

**Mitigation**:

- [ ] プリペアドステートメントの使用
- [ ] 入力サニタイゼーション
- [ ] セキュリティテストの追加

**Estimated Effort**: 2 hours
```
