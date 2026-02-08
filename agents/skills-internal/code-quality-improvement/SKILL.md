---
name: code-quality-improvement
description: |
  [What] Specialized skill for systematic code quality improvement. Provides Phase 1→2→3 workflow for ESLint error fixing, type safety improvements, and code quality enhancements
  [When] Use when: users mention "ESLintエラー", "大量修正", "段階的修正", "code quality", or need systematic code quality improvement
  [Keywords] ESLintエラー, 大量修正, 段階的修正, code quality
---

# Code Quality Improvement Skill

## いつ使うか

このスキルは以下の場合に自動的にトリガーされます:

- ESLintエラーを大量に修正する必要がある時
- コード品質を段階的に改善したい時
- 体系的なリファクタリングを実施する時
- 型安全性を向上させたい時
- クリーンアーキテクチャの境界違反を修正する時

## トリガーキーワード

- "ESLintエラー", "ESLint error", "lint error"
- "大量修正", "一括修正", "bulk fix"
- "段階的修正", "phased approach", "段階的"
- "コード品質改善", "code quality", "品質改善"
- "リファクタリング", "refactoring"
- "型安全性", "type safety"
- "未使用変数", "unused variables"

## 段階的ワークフロー

### Phase 1: 準備・分析 (15-30分)

#### 1.1 エラー状況の把握

```bash
# 全体のエラー数を確認
pnpm lint 2>&1 | tee lint-errors.log

# カテゴリ別にエラー数を集計
echo "未使用変数: $(pnpm lint 2>&1 | grep -c 'no-unused-vars')"
echo "型アサーション: $(pnpm lint 2>&1 | grep -c 'no-type-assertions-without-validation')"
echo "Result<T,E>パターン: $(pnpm lint 2>&1 | grep -c 'neverthrow/must-use-result')"
echo "Layer境界違反: $(pnpm lint 2>&1 | grep -c 'enforce-layer-boundaries')"
```

#### 1.2 優先度の決定

エラーを以下の優先度で分類:

| 優先度      | カテゴリ                       | 対応時期   | 例                                              |
| ----------- | ------------------------------ | ---------- | ----------------------------------------------- |
| 🔴 Critical | ビルド失敗・セキュリティリスク | 即座       | any型、型アサーション、バリデーション欠如       |
| 🟠 High     | 実行時エラーの可能性           | 24時間以内 | 未使用変数の誤った削除、Result<T,E>パターン違反 |
| 🟡 Medium   | アーキテクチャ一貫性           | 1週間以内  | Layer境界違反、責任分離違反                     |
| 🟢 Low      | スタイルガイド違反             | 1ヶ月以内  | コードフォーマット、命名規約                    |

#### 1.3 修正計画の策定

```markdown
## 修正計画

### 現状

- Total errors: XXX件
- Critical: XX件
- High: XX件
- Medium: XX件
- Low: XX件

### 目標

- Phase 2完了時: Critical 0件、High 50%削減
- Phase 3完了時: 全エラー 80%削減

### アプローチ

1. 自動修正可能なエラー → pnpm lint:fix
2. パターン適用可能なエラー → 一括置換スクリプト
3. 手動修正必要なエラー → 個別対応
```

### Phase 2: 実行 (1-3時間)

#### 2.1 自動修正の実施

```bash
# ステップ1: フォーマット修正
pnpm format:prettier

# ステップ2: ESLint自動修正
pnpm lint:fix

# ステップ3: 効果測定
echo "残存エラー: $(pnpm lint 2>&1 | grep -c 'error')"
```

#### 2.2 パターンベース一括修正

```bash
# 未使用変数のアンダースコア削除（テストファイル）
find src/tests -name "*.test.ts" -exec sed -i '' 's/const _\([a-zA-Z][a-zA-Z0-9_]*\) = /const \1 = /g' {} \;

# 型アサーション → 型ガード置換（手動確認推奨）
# 詳細はreferences/patterns.mdを参照
```

#### 2.3 手動修正の実施

優先度の高いエラーから順に手動修正:

1. **any型排除** → Zodスキーマ + unknown型
2. **型アサーション削除** → 型ガード作成
3. **Result<T,E>パターン適用** → Service層統合
4. **Layer境界違反修正** → 依存関係整理

詳細な修正パターンは [references/patterns.md](references/patterns.md) を参照

#### 2.4 段階的コミット

```bash
# 機能別・ファイル別にコミット
git add src/tests/**/*.test.ts
git commit -m "fix: remove unused variable underscore prefixes in tests"

git add src/lib/services/**/*.ts
git commit -m "refactor: apply Result<T,E> pattern to services"
```

### Phase 3: 検証・完了 (30分-1時間)

#### 3.1 品質保証

```bash
# 必須チェック（全てパスすること）
pnpm test          # 全テスト成功
pnpm type-check    # 型エラー0件
pnpm lint          # リント違反0件
pnpm build         # ビルド成功（該当する場合）
```

#### 3.2 効果測定・レポート

```markdown
## 修正完了レポート

### 修正成果

- Total errors: XXX件 → YY件 (ZZ%削減)
- Critical: XX件 → 0件 (100%解消)
- High: XX件 → Y件 (ZZ%削減)

### 品質指標

- [ ] 全テスト成功
- [ ] 型エラー0件
- [ ] リント違反0件
- [ ] ビルド成功

### 主要な修正内容

1. any型排除: XX箇所
2. 型アサーション削除: XX箇所
3. Result<T,E>パターン適用: XX箇所
4. Layer境界違反修正: XX箇所
```

## 重要な注意事項

### 危険なパターン - 絶対に避けるべき修正

#### 1. Claude Codeの誤修正パターン

```typescript
// ❌ 危険: アンダースコアだけ追加して使用箇所は未修正
export function verifyFormDataSupport(): void {
  const _formData = new FormData(); // ← _追加

  // 使用箇所は_なし → ReferenceError!
  formData.append("test", "value"); // ← 未定義変数参照
  expect(formData.get("test")).toBe("value");
}

// ✅ 正しい: 一貫した命名
export function verifyFormDataSupport(): void {
  const formData = new FormData();

  formData.append("test", "value");
  expect(formData.get("test")).toBe("value");
}
```

**重要**: 未使用変数の修正後は必ず該当ファイルのテストを実行すること

#### 2. 自動修正が危険なルール

以下のルールは自動修正を無効化済み（手動修正必須）:

- `no-manual-success-error-patterns` - 未定義変数生成リスク
- `no-type-assertions-without-validation` - 複雑な型変換
- `require-result-pattern-in-services` - ロジック破壊リスク

### 安全な修正順序

1. **自動修正可能** → `pnpm lint:fix`で自動実行
2. **パターン適用可能** → スクリプトで一括処理（テスト実行必須）
3. **手動修正必要** → 慎重に個別対応

## 層別修正戦略

### Service層

```typescript
// 🔴 修正前: any型 + 型アサーション
async function getUser(id: string): Promise<any> {
  const response = await fetch(`/api/users/${id}`);
  return response.json() as User;
}

// ✅ 修正後: Zodスキーマ + Result<T,E>
async function getUser(id: string): ResultAsync<User, Error> {
  return handleApiResponse(fetch(`/api/users/${id}`), UserSchema);
}
```

### Action層

```typescript
// 🔴 修正前: FormData型安全性なし
export async function createUser(formData: FormData) {
  const name = formData.get("name") as string;
  const email = formData.get("email") as string;
  return await userService.create({ name, email });
}

// ✅ 修正後: Zodスキーマ検証 + Result<T,E>
export async function createUser(formData: FormData) {
  const validated = validateFormData(formData, CreateUserSchema);
  if (!validated.success) {
    return { success: false, error: validated.error };
  }

  const result = await userService.create(validated.data);
  return toServerActionResult(result);
}
```

### Transform層

```typescript
// 🔴 修正前: 型アサーション
function transformData(raw: unknown): User {
  return raw as User;
}

// ✅ 修正後: 型ガード + バリデーション
function transformData(raw: unknown): Result<User, Error> {
  const validated = UserSchema.safeParse(raw);
  if (!validated.success) {
    return err(new Error(validated.error.message));
  }
  return ok(validated.data);
}
```

## チェックリスト

### Phase 1: 準備・分析

- [ ] エラー状況把握完了（カテゴリ別集計）
- [ ] 優先度決定完了（Critical/High/Medium/Low）
- [ ] 修正計画策定完了（目標・アプローチ明確化）
- [ ] バックアップ作成（git stash or branch）

### Phase 2: 実行

- [ ] 自動修正実施完了（prettier + lint:fix）
- [ ] パターンベース修正完了（スクリプト実行）
- [ ] 手動修正実施完了（優先度順）
- [ ] 段階的コミット完了（機能別・ファイル別）
- [ ] 各ステップでテスト実行確認

### Phase 3: 検証・完了

- [ ] 全テスト成功（pnpm test）
- [ ] 型エラー0件（pnpm type-check）
- [ ] リント違反0件（pnpm lint）
- [ ] ビルド成功（該当する場合）
- [ ] 効果測定レポート作成
- [ ] ドキュメント更新（必要に応じて）

## 関連リソース

### 詳細な修正パターン

- [references/patterns.md](references/patterns.md) - ESLintエラー種類別の修正パターン

### プロジェクト固有ガイド

- Result<T,E>パターン: `.claude/essential/result-pattern.md`
- レイヤー概要: `docs/layers/layer-overview.md`
- 型安全性ガイド: `docs/development/type-safety-comprehensive-guide.md`

### 関連コマンド

- `/refactor` - 統合リファクタリング
- `/review` - コードレビュー
- `/polish` - コード品質保証

## 実績データ

### v2.1.0 /fix コマンド実績 (2025-07-07)

- TypeScriptエラー: 6件 → 0件 (100%解消)
- ESLint警告: 9件 → 0件 (100%解消)
- 自動修正率: 100%のAI駆動解決

### 大規模修正実績

- 未使用変数: 2,523個 → 2,137個 (386個削減、15%改善)
- 型エラー: 複数 → 0件 (100%解消)
- ESLintエラー: 500+ → 32件 (94%削減)
- any型: 93件 → 0件 (100%排除)

## トラブルシューティング

### よくある問題

#### Q: pnpm lint:fix が一部のエラーを修正できない

A: 以下のルールは手動修正必須（自動修正無効化済み）

- 型アサーション系
- Result<T,E>パターン系
- Layer境界違反系

#### Q: テストが失敗する

A: 未使用変数修正時の誤修正の可能性。以下を確認:

1. `_`プレフィックス追加箇所の使用箇所チェック
2. 削除した変数が実際に使用されていないか確認
3. git diff で変更内容を詳細レビュー

#### Q: 型エラーが増えた

A: 型アサーション削除時の一時的増加は正常。適切な型ガードやバリデーションを追加することで解消

## 学習ポイント

### 成功パターン

1. 段階的修正（50-100個ずつ）
2. 効果測定（修正前後の定量比較）
3. 継続的テスト実行
4. 機能別コミット

### 避けるべきパターン

1. 一括大量修正（リスク高）
2. テストなしでの修正
3. 自動修正への過度な依存
4. エラーメッセージの無視

## 🤖 Agent Integration

このスキルは段階的なコード品質改善タスクを実行するエージェントに専門知識を提供します:

### Error-Fixer Agent（特に重要）

- **提供内容**: 3-Phase段階的品質改善戦略、ESLintエラー修正、型安全性向上
- **タイミング**: ESLintエラー修正・大量修正・コード品質改善タスク実行時
- **コンテキスト**:
  - Phase 1: Surface Linter修正（ESLint auto-fix）
  - Phase 2: Type Safety改善（any型排除、型ガード実装）
  - Phase 3: Deep Quality向上（Result<T,E>、アーキテクチャパターン）
  - 段階的修正戦略（50-100個ずつ）
  - 効果測定と定量評価

### Orchestrator Agent

- **提供内容**: 品質改善計画策定、複数Phase調整
- **タイミング**: 大規模品質改善プロジェクト実行時
- **コンテキスト**: Phase進行管理、セッション管理、効果測定、リスク管理

### Code-Reviewer Agent

- **提供内容**: 品質改善効果の評価、継続的品質チェック
- **タイミング**: Phase完了後の品質検証時
- **コンテキスト**: 改善前後の定量比較、残存問題の特定、次Phase推奨

### 自動ロード条件

- "ESLintエラー"、"大量修正"、"段階的修正"に言及
- "code quality"、"品質改善"、"リファクタリング"に言及
- ESLintエラー100件以上のプロジェクト検出時
- `/refactor`コマンド実行時

**統合例**:

```
ユーザー: "ESLintエラーを段階的に修正して型安全性を向上"
    ↓
TaskContext作成
    ↓
プロジェクト検出: TypeScript（ESLintエラー300件）
    ↓
スキル自動ロード: code-quality-improvement, typescript
    ↓
エージェント選択: error-fixer
    ↓ (スキルコンテキスト提供)
3-Phase戦略 + TypeScript型安全性パターン
    ↓
Phase 1実行（100件修正）→ 継続確認 → Phase 2へ
    ↓
実行完了（段階的品質向上、効果測定レポート）
```
