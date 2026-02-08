# ESLintエラー修正パターン集

このドキュメントは、ESLintエラー種類別の修正パターン、自動修正可能なルール、手動修正が必要なパターン、およびよくある問題と解決策をまとめたリファレンスです。

## 目次

1. [型安全性緊急対応パターン](#型安全性緊急対応パターン)
2. [カスタムESLintルール例外設定](#カスタムeslintルール例外設定)
3. [未使用変数クリーンアップ戦略](#未使用変数クリーンアップ戦略)
4. [Layer境界違反修正パターン](#layer境界違反修正パターン)
5. [Result<T,E>パターン段階的移行](#resultte-パターン段階的移行)
6. [一括修正スクリプト](#一括修正スクリプト)
7. [効率化・最適化コマンド](#効率化最適化コマンド)
8. [v2.1.0修正パターンの発見](#v210-修正パターンの発見)

---

## 型安全性緊急対応パターン

### 1. any型即時修正（最優先🔴）

#### パターン1: unknown型への置換

```typescript
// ❌ 即時修正必須
const data: any = response.data;
const value = formData.get("field") as string;
const result = JSON.parse(json) as UserData;

// ✅ 修正後
const data: unknown = response.data;
const value = validateFormData(formData, UserSchema);
const result = UserSchema.safeParse(JSON.parse(json));
```

#### パターン2: 適切な型推論の活用

```typescript
// ❌ 型を放棄
const items: any[] = response.items;

// ✅ ジェネリクスで型安全性確保
const items = response.items as Array<Item>;
// さらに良い: Zodスキーマでバリデーション
const validated = z.array(ItemSchema).safeParse(response.items);
if (validated.success) {
  const items = validated.data; // Item[]型
}
```

### 2. 層別対応マトリックス

| 発見場所     | 必須対応        | 推奨パターン                              |
| ------------ | --------------- | ----------------------------------------- |
| Service層    | Zodスキーマ検証 | `handleApiResponse()` + ResultAsync       |
| Action層     | FormData検証    | `validateFormData()` + ServerActionResult |
| Transform層  | 型安全変換      | `createSafeTransformer()`                 |
| Component層  | Props検証       | Zodスキーマ + 型ガード                    |
| Repository層 | Prisma型活用    | 自動生成型の利用                          |

### 3. 型アサーション削除パターン

#### パターン1: 型ガード関数の作成

```typescript
// ❌ 型アサーション
const unit = data.unit as "FEET" | "METERS";

// ✅ 型ガード関数
function isDimensionUnit(value: unknown): value is "FEET" | "METERS" {
  return value === "FEET" || value === "METERS";
}

function getDimensionUnit(unit: string | undefined): "FEET" | "METERS" {
  return isDimensionUnit(unit) ? unit : "FEET"; // デフォルト値
}

const unit = getDimensionUnit(data.unit);
```

#### パターン2: Zodスキーマでの検証

```typescript
// ❌ 型アサーション
const mapInfo = cmxMapInfo as CMXMapInfo;

// ✅ Zodスキーマ
const CMXMapInfoSchema = z.object({
  imageName: z.string().optional(),
  dimension: z.object({
    width: z.number(),
    height: z.number(),
    unit: z.enum(["FEET", "METERS"]),
  }),
});

const validated = CMXMapInfoSchema.safeParse(cmxMapInfo);
if (validated.success) {
  const mapInfo = validated.data; // 型安全
}
```

#### パターン3: const assertionの活用

```typescript
// ❌ 読み取り専用配列への型アサーション
(permissionIds as readonly string[]).includes(id);

// ✅ const assertion
const PERMISSION_IDS = ["read", "write", "delete"] as const;
PERMISSION_IDS.includes(id); // 型安全

// さらに良い: 型定義を明示
const PERMISSION_IDS: readonly string[] = ["read", "write", "delete"];
```

---

## カスタムESLintルール例外設定

### 1. 層境界ルール例外パターン

**課題**: Hooks層からApp Actions層への依存がClean Architectureの原則に反するが、ReactのServer Actions呼び出しパターンとして正当

**解決策**: 段階的例外設定アプローチ

#### アプローチ1: ファイルパターンベース例外（推奨⭐⭐⭐⭐⭐）

```javascript
// eslint.config.mjs
{
  files: ['src/lib/hooks/**/*.{ts,tsx}'],
  rules: {
    'custom/enforce-layer-boundaries': 'off',
  },
}
```

#### アプローチ2: 特定用途別例外（テスト・デモ）

```javascript
// eslint.config.mjs
{
  files: [
    'src/components/test/**/*.{ts,tsx}',
    'src/components/demo/**/*.{ts,tsx}',
    'src/stories/**/*.{ts,tsx}',
  ],
  rules: {
    'custom/no-formdata-mutation': 'off',
  },
}
```

### 2. 代替手法の比較

| 手法                      | 保守性     | 拡張性     | 推奨度     |
| ------------------------- | ---------- | ---------- | ---------- |
| ESLint設定ファイル例外    | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | 最推奨     |
| ルール内部ロジック修正    | ⭐⭐       | ⭐⭐       | 非推奨     |
| インラインdisableコメント | ⭐⭐⭐     | ⭐⭐       | 少数時のみ |

### 3. 層別ルール設定戦略

```javascript
// eslint.config.mjs - 実用性を考慮した段階的設定
{
  // 最も制限的: 新規コード（ERROR）
  files: ['src/app/api/**/*.ts'],
  rules: { 'neverthrow/must-use-result': 'error' }
},
{
  // 中程度: 既存コード（WARN）
  files: ['src/lib/actions/**/*.ts'],
  rules: { 'neverthrow/must-use-result': 'warn' }
},
{
  // 最も緩和: レガシー・Value Objects（OFF）
  files: ['src/lib/value-objects/**/*.ts', 'src/tests/**/*.ts'],
  rules: { 'neverthrow/must-use-result': 'off' }
}
```

---

## 未使用変数クリーンアップ戦略

### 1. 危険なClaude Code誤修正パターン

```typescript
// ❌ Claude Code誤修正例（実際に発見したバグ）
export function verifyFormDataSupport(): void {
  const _formData = new FormData(); // _プレフィックス追加

  // 使用箇所では_なし → ReferenceError!
  formData.append("test", "value"); // 未定義変数参照
  expect(formData.get("test")).toBe("value");
}

// ✅ 修正版
export function verifyFormDataSupport(): void {
  const formData = new FormData(); // 一貫した命名

  formData.append("test", "value"); // 正しい参照
  expect(formData.get("test")).toBe("value");
}
```

**重要発見**: Claude Codeが未使用変数警告を避けるため`_`プレフィックスを追加するが、実際の使用箇所は修正されず、実行時エラーを引き起こす。

### 2. 安全な削除戦略

#### Stage 1: 確実に安全な削除（未使用インポート）

```typescript
// 削除可能
import { type UnusedType } from "./types"; // 型定義のみで未使用
import { unusedHelper } from "./helpers"; // 使用されていないヘルパー

// 注意が必要
import { usedFunction, unusedFunction } from "./utils";
// → unusedFunctionのみ削除
```

#### Stage 2: 条件付き削除（分割代入・配列）

```typescript
// オブジェクト分割代入の不要プロパティ
const { used, unused } = data;
// → unused削除可能

// 配列分割代入の中間要素（慎重に）
const [first, _middle, last] = array;
// → _middleは位置が重要なので削除不可（_プレフィックスで明示）
```

#### Stage 3: 例外パターン（ESLint設定で許可）

```javascript
// eslint.config.mjs
{
  rules: {
    '@typescript-eslint/no-unused-vars': [
      'warn',
      {
        varsIgnorePattern: '^_error$|^_err$|^_prevState$',
        argsIgnorePattern: '^_',
      },
    ],
  },
}
```

### 3. 未使用変数検出コマンド

```bash
# 未使用変数のみチェック
pnpm lint 2>&1 | grep "no-unused-vars" | head -20

# ファイル別集計
pnpm lint 2>&1 | grep "no-unused-vars" | awk -F: '{print $1}' | sort | uniq -c | sort -nr
```

---

## Layer境界違反修正パターン

### 1. Logger依存の修正

```typescript
// ❌ Service Layer logger依存
import { transformLogger } from "@/lib/services/logging/layer-loggers";

// ✅ console直接使用に変更
const transformLogger = {
  info: (msg: string, data?: unknown) =>
    console.info(`[Transform] ${msg}`, data),
  error: (msg: string, error?: unknown) =>
    console.error(`[Transform] ${msg}`, error),
  warn: (msg: string, data?: unknown) =>
    console.warn(`[Transform] ${msg}`, data),
};
```

### 2. 型依存の修正

```typescript
// ❌ Service Layer型依存
import { type CMXLocationResponseService } from "@/lib/services/cmx-service/types";

// ✅ インライン型定義に変更
interface CMXLocationResponseService {
  macAddress: string;
  location?: { x: number; y: number; unit: string } | null;
  // 必要な型のみ定義
}
```

### 3. 設定依存の修正

```typescript
// ❌ Config Layer関数依存
import { isDevelopment } from "@/lib/config/server-env";

// ✅ 直接環境変数チェック
const isDev = process.env.NODE_ENV === "development";
```

### 4. 依存種類別の修正戦略

| 依存種類       | 修正方法                       | 優先度 |
| -------------- | ------------------------------ | ------ |
| Logger         | console直接使用                | 高     |
| 型定義         | インライン定義またはSchema層   | 中     |
| 設定値         | 直接環境変数参照               | 高     |
| ユーティリティ | 同層内に複製または共通層に移動 | 低     |

---

## Result<T,E> パターン段階的移行

### Stage 1: 型安全性確保

```typescript
function createUser(data: unknown): Result<User, Error> {
  const validated = UserSchema.safeParse(data);
  if (!validated.success) {
    return err(new Error(validated.error.message));
  }
  return ok(validated.data);
}
```

### Stage 2: サービス統合

```typescript
const result = await createUser(formData);
return result.match(
  (user) => ({ success: true, data: user }),
  (error) => ({ success: false, error: error.message }),
);
```

### Stage 3: Action層統合

```typescript
export async function createUserAction(formData: FormData) {
  return toServerActionResult(await createUser(formData));
}
```

### Result<T,E>パターン適用チェックリスト

- [ ] Service層関数の戻り値型を`Result<T,E>`または`ResultAsync<T,E>`に変更
- [ ] エラーケースで`err()`を返す
- [ ] 成功ケースで`ok()`を返す
- [ ] 呼び出し側で`.match()`または`.mapErr()`でハンドリング
- [ ] Action層で`toServerActionResult()`で変換

---

## 一括修正スクリプト

### 安全な一括修正スクリプト

```bash
#!/bin/bash
# 安全な一括修正スクリプト

# 1. バックアップ作成
git stash push -m "before-eslint-fixes"

# 2. 段階的修正
echo "Phase 1: Unused imports"
find src -name "*.ts" -not -path "*/node_modules/*" | xargs grep -l "^import.*from.*$" | head -20

echo "Phase 2: Variable naming consistency"
find src/tests -name "*.test.ts" -exec sed -i '' 's/const _\([a-zA-Z][a-zA-Z0-9_]*\) = /const \1 = /g' {} \;

# 3. 効果測定
echo "Improvement: $(git diff --stat)"

# 4. 安全確認
pnpm test:quick && echo "✅ Tests pass" || echo "❌ Tests failed - review changes"
```

### 特定パターンの一括置換

#### 未使用変数のアンダースコア削除（テストファイル）

```bash
find src/tests -name "*.test.ts" -exec sed -i '' 's/const _\([a-zA-Z][a-zA-Z0-9_]*\) = /const \1 = /g' {} \;
```

#### 型アサーション検出

```bash
# 型アサーション箇所を検出
grep -r " as " src/ --include="*.ts" --include="*.tsx" | grep -v "as const" | head -20
```

---

## 効率化・最適化コマンド

### 1. 特定エラー集中修正

```bash
# 未使用変数のみチェック
pnpm lint 2>&1 | grep "no-unused-vars" | head -20

# Layer境界違反のみ
pnpm lint 2>&1 | rg "enforce-layer-boundaries" -A 2 -B 2

# Result<T,E>パターン違反のみ
pnpm lint --quiet 2>&1 | grep "neverthrow/must-use-result" | head -20

# 型アサーション違反のみ
pnpm lint 2>&1 | grep "no-type-assertions-without-validation"
```

### 2. 並列修正・効果測定

```bash
# 修正前のベースライン
before=$(pnpm lint 2>&1 | grep -c 'no-unused-vars')
echo "Before: $before"

# 一括修正実行
find src/tests -name "*.test.ts" -exec sed -i '' 's/const _\([a-zA-Z][a-zA-Z0-9_]*\) = /const \1 = /g' {} \;

# 修正後の効果測定
after=$(pnpm lint 2>&1 | grep -c 'no-unused-vars')
echo "After: $after"
echo "Reduction: $((before - after)) variables"
```

### 3. エラー集計スクリプト

```bash
#!/bin/bash
# エラー種別集計

echo "=== ESLint Error Summary ==="
echo "Total errors: $(pnpm lint 2>&1 | grep -c 'error')"
echo "Total warnings: $(pnpm lint 2>&1 | grep -c 'warning')"
echo ""
echo "=== By Category ==="
echo "Unused vars: $(pnpm lint 2>&1 | grep -c 'no-unused-vars')"
echo "Type assertions: $(pnpm lint 2>&1 | grep -c 'no-type-assertions-without-validation')"
echo "Result pattern: $(pnpm lint 2>&1 | grep -c 'neverthrow/must-use-result')"
echo "Layer boundaries: $(pnpm lint 2>&1 | grep -c 'enforce-layer-boundaries')"
```

---

## v2.1.0 修正パターンの発見

### 1. ESLintルール定数定義のバグ修正

```javascript
// 🔴 問題: Result<T,E>パターン警告が大量発生（37件）
// 原因: 配列で定義した定数をオブジェクトとしてアクセス

// ❌ eslint-rules/rule-constants.js
export const RESULT_TYPE_NAMES = ["Result", "ResultAsync"];
// ルール内で RESULT_TYPE_NAMES.Result でアクセス → undefined

// ✅ 正しい実装
export const RESULT_TYPE_NAMES = {
  Result: "Result",
  ResultAsync: "ResultAsync",
  TransformResult: "TransformResult",
};
```

**教訓**: ESLintルール内での定数アクセス方法と定義の一貫性確認が重要

### 2. 型ガードユーティリティの作成パターン

```typescript
// ❌ 型アサーションの散在（31件）
const unit = data.unit as "FEET" | "METERS";
const mapInfo = cmxMapInfo as any;

// ✅ 型ガードユーティリティ作成 (src/lib/utils/type-guards.ts)
export function getDimensionUnit(unit: string | undefined): "FEET" | "METERS" {
  return isDimensionUnit(unit) ? unit : "FEET";
}

export function isCMXMapInfoLike(
  data: unknown,
): data is { imageName?: string } {
  return typeof data === "object" && data !== null && "imageName" in data;
}
```

**効果**: 型アサーションを型ガードに置換し、型安全性を向上

### 3. プロパティ名不一致の解決パターン

```typescript
// 🔴 問題: macaddress vs macAddress の不整合
// - フォームスキーマ: macAddress (camelCase)
// - サービス/ドメインスキーマ: macaddress (lowercase)

// ✅ 解決策: 明示的なマッピング
const macAddressData = {
  name: formData.name,
  macaddress: formData.macAddress, // フォーム→サービス変換
};
```

**教訓**: 層間での命名規約違いは明示的なマッピングで解決

### 4. Object.entries型推論修正

```typescript
// ❌ 型アサーション
const entries = Object.entries(fieldExtractors) as Array<
  [string, (formData: FormData) => unknown]
>;

// ✅ ジェネリクス型定義
type FieldExtractor = (formData: FormData) => unknown;
type FieldExtractors = Record<string, FieldExtractor>;

const fieldExtractors: FieldExtractors = {
  /* ... */
};
const entries = Object.entries(fieldExtractors); // 型推論が働く
```

---

## 修正成果メトリクス

### v2.1.0 実績 (2025-07-07)

| カテゴリ         | 修正前 | 修正後 | 削減率 | 方法       |
| ---------------- | ------ | ------ | ------ | ---------- |
| TypeScriptエラー | 6件    | 0件    | 100%   | AI支援修正 |
| ESLint警告       | 9件    | 0件    | 100%   | 自動+手動  |

### 大規模修正実績 (2025-06-30)

| カテゴリ         | 修正前 | 修正後  | 削減率 | 方法                  |
| ---------------- | ------ | ------- | ------ | --------------------- |
| TypeScriptエラー | 44件   | 約20件  | 55%    | AI支援修正            |
| ESLint警告       | 246件  | 約150件 | 40%    | 自動+手動             |
| 未使用変数       | 54件   | 0件     | 100%   | \_プレフィックス/削除 |
| 型アサーション   | 31件   | 26件    | 16%    | 型ガード作成          |

### 長期的改善実績

| 指標         | 初期値  | 現在値  | 改善率 |
| ------------ | ------- | ------- | ------ |
| 未使用変数   | 2,523個 | 2,137個 | 15%    |
| 型エラー     | 複数    | 0件     | 100%   |
| ESLintエラー | 500+    | 32件    | 94%    |
| any型        | 93件    | 0件     | 100%   |

---

## ESLintカスタムルール活用パターン

### 1. 危険な自動修正無効化

```javascript
// 安全措置: 危険な自動修正機能無効化済み
{
  'no-manual-success-error-patterns': { fixable: null }, // 未定義変数生成防止
  'no-type-assertions-without-validation': { fixable: null }, // 複雑変換防止
  'require-result-pattern-in-services': { fixable: null }, // ロジック破壊防止
}
```

### 2. アーキテクチャ強制ルール

```javascript
// 層境界強制
'custom/enforce-layer-boundaries': 'warn',

// データアクセス制御
'custom/no-prisma-outside-repository': 'error',
'custom/no-prisma-in-client-components': 'error',

// FormData使用制限（Transform Layer除外対応）
'custom/no-formdata-outside-server-actions': 'warn',
'custom/require-zod-validation-in-forms': 'warn',
```

---

## 品質指標・進捗追跡

### 定量的改善指標

```bash
# 主要指標の継続的監視
- 未使用変数: 2,523 → 2,137 (-15%, 386個削減)
- 型エラー: 複数 → 0 (-100%)
- ESLintエラー: 500+ → 32 errors (-94%)
- any型: 93件 → 0件 (-100%)
- Clean Architecture境界: 0 violations (100%準拠)
```

### 品質レーティングシステム

| ルール品質 | 数量 | 特徴                                   |
| ---------- | ---- | -------------------------------------- |
| ⭐⭐⭐⭐⭐ | 15個 | 本番環境対応、完全自動化、高精度、安全 |
| ⭐⭐⭐⭐   | 5個  | 高品質、実用的、信頼性高               |
| ⭐⭐⭐     | 1個  | 実用可能、基本機能完備                 |

---

## v2.0.0 ESLintルール大規模リファクタリング (2025-06-28)

### リファクタリング成果サマリー

| 改善項目         | Before | After   | 改善率 |
| ---------------- | ------ | ------- | ------ |
| コード重複       | 高い   | 80%削減 | ⬇ 80%  |
| マジックナンバー | 15+    | 0個     | ⬇ 100% |
| サイレント失敗   | 多数   | 90%削減 | ⬇ 90%  |
| 関数複雑度       | 高い   | 30%削減 | ⬇ 30%  |

### アーキテクチャ改善詳細

#### 1. モジュール化・共通化

```javascript
// ✅ Before: 各ルールで重複実装（30行×23ファイル = 690行）
function getLayerInfo(filePath) {
  let normalizedPath = filePath.startsWith("@/")
    ? filePath.replace("@/", "")
    : filePath;
  // 複雑な層検出ロジック...
}

// ✅ After: 共通ユーティリティで一元管理（rule-utils.js）
import { getLayerInfo, normalizeFilePath, safeExecute } from "./rule-utils.js";
// 23ファイル → 1ファイルに集約、690行 → 138行（80%削減）
```

#### 2. 定数管理統一

```javascript
// ❌ Before: ハードコードされたマジックナンバー
const lines = text.split("\n").slice(0, 10); // Magic number 10
const contextWindow = text.slice(nodeStart - 100, nodeStart + 100); // Magic 100

// ✅ After: 意味のある定数で管理（rule-constants.js）
export const ANALYSIS_CONSTANTS = {
  USE_CLIENT_SEARCH_LINES: 10,
  CONTEXT_WINDOW_SIZE: 100,
};
```

#### 3. エラーハンドリング統一

```javascript
// ❌ Before: サイレント失敗（エラー情報なし）
try {
  const files = readdirSync(voDir)
  return files.filter(...)
} catch {
  return [] // 何が失敗したかわからない
}

// ✅ After: 統一的なsafeExecuteパターン
return safeExecute(
  () => {
    const files = readdirSync(voDir)
    if (!Array.isArray(files)) {
      throw new Error('Failed to read value-objects directory')
    }
    return files.filter(...)
  },
  [], // フォールバック値
  'prefer-value-objects-v2: getAvailableValueObjects' // コンテキスト
)
```

---

## 学習ポイント・ベストプラクティス

### 成功パターン

1. **段階的修正**: 50-100個ずつのエラーを修正
2. **効果測定**: 修正前後の定量的比較を実施
3. **安全確認**: テスト実行・品質チェックを徹底
4. **継続的改善**: 月1回の品質レビュー

### 避けるべきアンチパターン

1. **一括大量修正**: リスクが高く、問題の追跡が困難
2. **テストなしでの修正**: 実行時エラーの見落とし
3. **自動修正への過度な依存**: 複雑な型変換の誤修正
4. **エラーメッセージの無視**: 根本原因の見落とし

### 重要な設計判断

1. **共通化 vs 個別最適化**: 80%の共通パターンを特定し共通化、20%の特殊ケースは個別対応
2. **後方互換性**: 既存ルールの動作を変更せずに内部実装のみ改善
3. **パフォーマンス vs 可読性**: 可読性を保ちつつパフォーマンス改善を実現
4. **エラーハンドリング戦略**: サイレント失敗を避け、適切なログ出力と復旧処理

---

## 関連リソース

### プロジェクト固有ドキュメント

- **型安全性緊急ガイド**: `docs/development/type-safety-comprehensive-guide.md`
- **開発効率ガイド**: `docs/development/development-efficiency-guide.md`
- **ESLintアーキテクチャルール**: `docs/development/eslint-custom-rules-guide.md`
- **Layer境界管理Tips**: `docs/development/layer-boundary-management-tips.md`

### レイヤー別ガイド

- **Action Layer**: `docs/layers/core/action-layer.md`
- **Transform Layer**: `docs/layers/core/transform-layer.md`
- **Value Object Layer**: `docs/layers/support/value-object-layer.md`

---

**最終更新**: 2025-07-07
**適用実績**: 未使用変数386個削減、型エラー100%解決、Clean Architecture境界0違反達成
