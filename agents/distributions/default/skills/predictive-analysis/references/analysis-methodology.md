# 分析手法

予測的コード分析で使用する静的解析手法とパターン検出アルゴリズムの詳細。

## 分析アプローチ

### 1. 静的コード解析

コードの実行なしに構造とパターンを解析します。

#### 構文解析

- **AST (Abstract Syntax Tree) 解析**: コードの構造を木構造で表現
- **制御フロー解析**: 実行経路の可視化
- **データフロー解析**: 変数の使用と依存関係の追跡

#### メトリクス計測

```typescript
// 循環的複雑度 (Cyclomatic Complexity)
complexity = edges - nodes + 2 * connected_components;

// 認知的複雑度 (Cognitive Complexity)
cognitive_complexity = nested_structures + break_linear_flow;

// 保守性指標 (Maintainability Index)
MI = 171 - 5.2 * ln(HV) - 0.23 * CC - 16.2 * ln(LOC);
// HV: Halstead Volume, CC: Cyclomatic Complexity, LOC: Lines of Code
```

### 2. パターンマッチング

既知の問題パターンとアンチパターンを検出します。

#### セキュリティパターン

**SQLインジェクション検出**:

```regex
Pattern: (execute|query|run)\s*\(\s*[`'"].*\$\{.*\}.*[`'"]\s*\)
Context: データベース操作関数
Risk: Critical
```

**XSS脆弱性検出**:

```regex
Pattern: innerHTML\s*=.*\$\{.*\}
Context: DOM操作
Risk: High
```

**ハードコードされたシークレット**:

```regex
Patterns:
  - (api_key|apikey|secret|password|token)\s*=\s*['"][^'"]{10,}['"]
  - (AWS|GITHUB|STRIPE)_[A-Z_]+\s*=\s*['"][^'"]+['"]
Risk: Critical
```

#### パフォーマンスパターン

**O(n²) 以上のアルゴリズム**:

```typescript
// ネストループ検出
Pattern: for/forEach内に for/forEach が存在
Context: データ処理、検索、フィルタリング
Risk: High (データ量に依存)

// N+1 クエリ問題
Pattern: ループ内でのデータベースクエリ実行
Context: ORM操作、API呼び出し
Risk: High
```

**メモリリーク**:

```typescript
// キャッシュの無制限な成長
Pattern:
  - グローバル変数への追加のみで削除なし
  - WeakMap/WeakSet 未使用
  - イベントリスナーの削除なし
Risk: Medium to High
```

### 3. 複雑性分析

#### 循環的複雑度 (McCabe Complexity)

**計算方法**:

```
CC = E - N + 2P
E: エッジ数 (制御フローの遷移)
N: ノード数 (実行可能な文)
P: 連結成分数 (通常は1)
```

**閾値**:

- 1-10: シンプル、低リスク
- 11-20: 中程度の複雑さ、テスト必要
- 21-50: 複雑、リファクタリング推奨
- 50+: 非常に複雑、分割必須

**検出例**:

```typescript
function processPayment(order, user, config) {
  // CC = 23 (High complexity)
  if (order.type === "subscription") {
    if (user.isPremium) {
      if (config.autoRenewal) {
        // 7階層のネスト、15の分岐
      }
    }
  }
}
```

#### 認知的複雑度

**ペナルティスコア**:

- ネストされた制御構造: +1 per level
- 早期リターン/continue/break: +1
- 再帰呼び出し: +1
- 論理演算子の連鎖: +1 per operator

**例**:

```typescript
function validateOrder(order) {
  // Cognitive Complexity = 12
  if (!order) return false; // +1 (early return)

  if (order.items.length > 0) {
    // +1 (if)
    for (const item of order.items) {
      // +2 (nested loop)
      if (item.quantity > 0 && item.price > 0) {
        // +3 (nested if) +1 (&&)
        // Processing...
      }
    }
  }
}
```

### 4. 依存関係分析

#### インポート解析

```bash
# 循環依存の検出
A imports B → B imports C → C imports A

# 未使用インポートの検出
Pattern: import.*from.*
Context: インポート文と実際の使用を照合

# 過剰な依存
Threshold: 1ファイルあたり >15 imports
```

#### カップリング分析

**求心的結合度 (Afferent Coupling - Ca)**:

- このモジュールに依存しているモジュールの数
- 高い = 影響範囲が広い = 変更リスク高

**遠心的結合度 (Efferent Coupling - Ce)**:

- このモジュールが依存しているモジュールの数
- 高い = 依存が多い = 脆弱性

**不安定性 (Instability)**:

```
I = Ce / (Ca + Ce)
0 = 最も安定 (変更の影響が少ない)
1 = 最も不安定 (変更の影響が大きい)
```

### 5. コード重複検出

#### トークンベース検出

```
1. コードをトークン列に変換
2. 連続するトークンのハッシュ値を計算
3. 同一ハッシュの検出で重複を特定
```

**閾値**:

- 5-10行の重複: Medium (リファクタリング推奨)
- 10-20行の重複: High (共通化必須)
- 20+行の重複: Critical (設計の見直し)

#### 構造的重複

```typescript
// 構造は同じだが変数名が異なる
function calculateUserDiscount(user) {
  const basePrice = user.order.total;
  const discount = basePrice * 0.1;
  return basePrice - discount;
}

function calculateAdminDiscount(admin) {
  const total = admin.purchase.amount;
  const reduction = total * 0.1;
  return total - reduction;
}
// 検出: 構造的重複
```

### 6. 変更頻度分析

#### ホットスポット検出

```bash
# Gitログから変更頻度を算出
git log --format=format: --name-only | sort | uniq -c | sort -nr

# 変更頻度とバグ密度の相関
High Change Frequency + High Bug Density = Critical Hotspot
```

**リスク判定**:

- 変更頻度 > 月10回 かつ バグ密度 > 0.5/100LOC: High Risk
- 変更頻度 > 月5回 かつ 高複雑度: Medium Risk

### 7. スケーラビリティ分析

#### リソース使用予測

**メモリ使用量**:

```
Estimated Memory = Data Size × Growth Rate × Safety Margin

例:
  Current: 100 MB
  Monthly Growth: 20%
  6ヶ月後: 100 × 1.2^6 = 299 MB
  1年後: 100 × 1.2^12 = 892 MB
```

**レスポンスタイム予測**:

```
Response Time = O(f(n)) × Data Scale Factor

O(n²) アルゴリズム:
  n=100: 1ms
  n=1000: 100ms (100倍)
  n=10000: 10s (10000倍) ← Critical
```

#### ボトルネック予測

```typescript
// 同期的な大量処理
Pattern:
  - ループ内でのawait
  - 並列化されていない非同期処理
  - データベースコネクションプールの制限

Risk Level: High (スケール時に確実に問題化)
```

## ツール統合

### Grep ツールの活用

**問題パターンの検索**:

```bash
# セキュリティリスク
grep -r "innerHTML.*\$\{" --include="*.ts" --include="*.js"
grep -r "eval\(" --include="*.ts" --include="*.js"

# パフォーマンスリスク
grep -r "forEach.*forEach" --include="*.ts" --include="*.js"
grep -r "await.*for" --include="*.ts" --include="*.js"
```

### Glob ツールの活用

**ファイル構造の解析**:

```bash
# 大規模ファイルの検出
find . -name "*.ts" -size +1000 -ls

# 命名規則の不統一
glob "**/{[A-Z]*,[a-z]*}.{ts,js}"
```

### Read ツールの活用

**詳細なコード解析**:

```
1. Grep/Globで候補を絞り込み
2. Readで複雑な関数の詳細を確認
3. コンテキストを理解した上でリスク評価
```

### MCP Serena の活用

**シンボルレベルの解析**:

```bash
# 関数の複雑性を評価
get_symbols_overview → 関数一覧取得
find_symbol → 特定関数の詳細取得
find_referencing_symbols → 影響範囲の特定
```

## 分析の優先順位

### 高優先度の分析対象

1. **クリティカルパス**: ユーザーの主要な操作フロー
2. **認証・認可**: セキュリティの基盤
3. **データ処理**: パフォーマンスに直結
4. **統合ポイント**: 外部システムとの接続

### 分析の深さの調整

```
Phase 1: 表層スキャン (全体の概要把握)
  - パターンマッチング
  - 基本メトリクス計測
  - 明らかな問題の検出

Phase 2: 詳細分析 (リスク領域の深掘り)
  - 依存関係の追跡
  - 複雑性の詳細評価
  - スケーラビリティ予測

Phase 3: コンテキスト評価 (ビジネス影響の考慮)
  - ビジネスクリティカリティ
  - 変更履歴との相関
  - 修正コストの見積もり
```

## 誤検出の削減

### 誤検出パターンの除外

```typescript
// 許容されるパターン
const SAFE_PATTERNS = {
  // テストコードでのeval使用
  test_eval: /describe|test|it.*eval/,

  // ビルド設定での動的require
  build_require: /webpack|rollup.*require/,

  // 型定義ファイルの複雑性
  type_complexity: /\.d\.ts$/,
};
```

### コンテキストベースの判定

```
1. ファイルパスでの判定 (test/, config/, types/)
2. コメントアノテーション (// @ts-ignore, // SAFE: reason)
3. 周辺コードのパターン (try-catch, validation)
```

## 継続的な改善

### フィードバックループ

```
1. 予測の追跡: 実際に問題が発生したか
2. 精度の測定: 誤検出率、見逃し率
3. パターンの更新: 新しいリスクパターンの追加
4. 閾値の調整: プロジェクト特性に応じた最適化
```
