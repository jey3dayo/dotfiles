# Learning Records - カテゴリ別記録例

## 概要

各カテゴリの具体的な記録例を示します。実際のプロジェクトで発生した問題とその解決策を元に、効果的な知見記録のパターンを提供します。

---

## Fix - リンター・コード品質修正

### 例1: ESLint no-unused-vars エラーの体系的修正

```bash
/learnings fix "ESLint no-unused-vars エラーの修正: 未使用変数は削除、必要なら_プレフィックスで明示的に無視"
```

### 背景
リンターエラーが頻発し、コードレビューで指摘が多発していた。

### 解決策

1. 未使用変数は即座に削除
2. 引数で必須だが使用しない場合は `_param` で明示
3. `eslint-disable` コメントは最小限に

### 効果

- リンターエラー: 120件 → 0件
- コードレビュー指摘: 40%削減

### コード例

```typescript
// Before
function handler(req, res, next) {
  return res.json({ data: "ok" });
}

// After
function handler(_req, res, _next) {
  return res.json({ data: "ok" });
}
```

### 例2: TypeScript型推論エラーの解決

```bash
/learnings fix "TypeScript型エラー: as const アサーションで配列を読み取り専用タプルに変換"
```

### 背景
配列の型推論が広すぎて、型エラーが発生していた。

### 解決策
`as const` アサーションで型を厳密化

### 効果

- 型エラー: 35件 → 0件
- 実行時エラー: 85%削減

### コード例

```typescript
// Before
const colors = ["red", "green", "blue"]; // string[]

// After
const colors = ["red", "green", "blue"] as const; // readonly ["red", "green", "blue"]
```

---

## Arch - アーキテクチャ・設計パターン

### 例1: BFF（Backend For Frontend）パターン実装

```bash
/learnings arch "BFFパターン: モバイル/Webで異なるデータ構造を提供するため、APIゲートウェイ層を導入"
```

### 背景
モバイルとWebで必要なデータ構造が異なり、クライアント側での加工が複雑化していた。

### 解決策

1. BFF層を導入（Next.js API Routes）
2. 各クライアント向けに最適化されたエンドポイント
3. バックエンドAPIは変更せず、BFF層で変換

### 効果

- フロントエンド実装時間: 40%短縮
- ネットワーク通信量: 30%削減
- クライアント側のコード: 50%削減

### 例2: Repository パターンでテスト可能性向上

```bash
/learnings arch "Repository パターン: データアクセスロジックをビジネスロジックから分離し、テスト可能性を向上"
```

### 背景
データベース操作とビジネスロジックが混在し、テストが困難だった。

### 解決策

1. Repository層を導入
2. インターフェースで抽象化
3. DIコンテナで依存性注入

### 効果

- テストカバレッジ: 40% → 85%
- モックの作成時間: 60%短縮

---

## Perf - パフォーマンス最適化

### 例1: N+1問題の解決

```bash
/learnings perf "N+1問題解決: JOINクエリまたはDataLoaderで一括取得し、クエリ数を1/100に削減"
```

### 背景
100件のユーザー情報を取得する際、101回のクエリが発行されていた。

### 解決策

1. JOINクエリで一括取得
2. DataLoaderでバッチ処理
3. インデックス追加

### 効果

- クエリ数: 101回 → 1回
- レスポンス時間: 5秒 → 0.5秒（10倍改善）

### 例2: React再レンダリング最適化

```bash
/learnings perf "React.memo + useCallback: 不要な再レンダリングを防止し、ページ読み込み時間を40%短縮"
```

### 背景
子コンポーネントが頻繁に再レンダリングされ、パフォーマンスが低下していた。

### 解決策

1. React.memoで子コンポーネントをメモ化
2. useCallbackでコールバック関数を最適化
3. useMemoで重い計算をキャッシュ

### 効果

- 再レンダリング回数: 80%削減
- ページ読み込み時間: 2秒 → 1.2秒

---

## Sec - セキュリティ・認証

### 例1: XSS脆弱性の修正

```bash
/learnings sec "XSS対策: ユーザー入力をDOMPurifyでサニタイズし、dangerouslySetInnerHTMLの使用を禁止"
```

### 背景
ユーザー入力がそのままHTMLに挿入され、XSS攻撃のリスクがあった。

### 解決策

1. DOMPurifyでサニタイズ
2. Content-Security-Policyヘッダー追加
3. `dangerouslySetInnerHTML` の使用を禁止

### 効果

- XSS脆弱性: 100%解消
- セキュリティスキャン: 合格

### 例2: JWT Refresh Token実装

```bash
/learnings sec "JWT Refresh Token: アクセストークン15分、リフレッシュトークン7日で安全性と利便性を両立"
```

### 背景
長期間有効なアクセストークンがセキュリティリスクになっていた。

### 解決策

1. アクセストークン: 15分（短期）
2. リフレッシュトークン: 7日（長期）
3. HTTPOnlyクッキーでリフレッシュトークン管理

### 効果

- トークン漏洩リスク: 90%削減
- ユーザー体験: 維持

---

## Test - テスト・品質保証

### 例1: AAAパターンで統合テスト構造化

```bash
/learnings test "AAA パターン: Arrange-Act-Assert で統合テストを構造化し、可読性を80%向上"
```

### 背景
統合テストが読みにくく、メンテナンスが困難だった。

### 解決策

1. Arrange: テストデータ準備
2. Act: 実行
3. Assert: 検証

### 効果

- テスト可読性: 80%向上
- テストメンテナンス時間: 50%短縮

### コード例

```typescript
test("ユーザー登録が正しく動作すること", async () => {
  // Arrange
  const userData = { email: "test@example.com", password: "password123" };

  // Act
  const response = await request(app).post("/api/users").send(userData);

  // Assert
  expect(response.status).toBe(201);
  expect(response.body.email).toBe(userData.email);
});
```

### 例2: MSWでAPI呼び出しをモック化

```bash
/learnings test "MSW（Mock Service Worker）: API呼び出しをモック化し、テストの独立性を確保"
```

### 背景
外部APIに依存するテストが不安定だった。

### 解決策

1. MSWでAPIレスポンスをモック
2. ネットワーク層でインターセプト
3. 実際のHTTP通信を再現

### 効果

- テスト成功率: 75% → 99%
- テスト実行時間: 50%短縮

---

## DB - データベース・永続化

### 例1: 複合インデックスでクエリ速度10倍改善

```bash
/learnings db "複合インデックス: WHERE句とORDER BY句の列を組み合わせてクエリ速度を10倍改善"
```

### 背景
ユーザー検索クエリが遅く、ページ読み込みに3秒かかっていた。

### 解決策

1. `(user_id, created_at)` で複合インデックス作成
2. EXPLAINでクエリプラン確認
3. 不要なインデックスを削除

### 効果

- クエリ速度: 3秒 → 0.3秒（10倍改善）
- インデックスサイズ: 20%削減

### 例2: 楽観的ロックでデータ整合性保証

```bash
/learnings db "楽観的ロック: version カラムで更新競合を検出し、データ整合性を保証"
```

### 背景
複数ユーザーが同時更新すると、データが不整合になることがあった。

### 解決策

1. `version` カラム追加
2. 更新時にバージョンチェック
3. 競合時はエラーレスポンス

### 効果

- データ不整合: 100%解消
- 競合検出率: 99%

---

## UI - UI・コンポーネント

### 例1: Compound Component パターン

```bash
/learnings ui "Compound Component パターン: 親子コンポーネントで状態を共有し、柔軟な構成を実現"
```

### 背景
ドロップダウンコンポーネントが硬直的で、カスタマイズが困難だった。

### 解決策

1. React Contextで状態共有
2. 親コンポーネントで状態管理
3. 子コンポーネントで柔軟な構成

### 効果

- コンポーネント再利用率: 80%向上
- カスタマイズ時間: 70%短縮

### 例2: ARIA属性でアクセシビリティ対応

```bash
/learnings ui "ARIA属性: role・aria-label・aria-describedby でスクリーンリーダー対応を強化"
```

### 背景
アクセシビリティスコアが低く、スクリーンリーダー対応が不十分だった。

### 解決策

1. `role` 属性で要素の役割を明示
2. `aria-label` でラベルを提供
3. `aria-describedby` で説明を追加

### 効果

- アクセシビリティスコア: 70点 → 95点
- WCAG 2.1 準拠

---

## 記録のベストプラクティス

### 1. 定量的効果を明記

- 単なる「改善した」ではなく、「50%短縮」「10倍改善」など具体的な数値を記録

### 2. コード例を含める

- 実装前後のコードを比較
- 他の開発者が再現できるレベル

### 3. 背景を説明

- なぜその問題が発生したか
- どのような影響があったか

### 4. 適用条件を明記

- どのような状況で使えるか
- 制約事項・トレードオフ

---

## 関連リファレンス

- **カテゴリ詳細**: `references/learning-categories.md`
- **記録プロセス**: `references/recording-process.md`
- **活用パターン**: `references/usage-patterns.md`
- **統合ワークフロー**: `integration-workflows.md`
