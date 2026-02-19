---
name: refactoring
description: |
  [What] TypeScript/JavaScript/React コードのリファクタリング統合ワークフロー。
  similarity-ts（重複検出）と react-doctor（React診断）を組み合わせた段階的改善。
  code-quality-improvement（ESLint/型安全性修正）と tsr（デッドコード削除）と連携する
  オーケストレーター。
  [When] Use when: "リファクタ", "refactor", "重複コード", "コード整理", "clean up",
  "duplicate code", "react-doctor", "similarity", "コードの品質を改善", "コードを綺麗に" の言及時。
  React プロジェクト + TypeScript/JavaScript の両方に対応。
---

# Refactoring - TypeScript/JavaScript/React 統合リファクタリングワークフロー

`similarity-ts`（重複コード検出）と `react-doctor`（React診断）を組み合わせ、段階的にコード品質を改善するオーケストレータースキル。

## 🎯 Core Mission

複数の専門スキル（`similarity`、`react-doctor`、`code-quality-improvement`、`tsr`）を統合し、プロジェクトタイプに応じた最適なリファクタリング計画を立案・実行する。

## 🏗️ 前提確認: プロジェクトタイプ判定

```bash
# React プロジェクト判定（package.json に "react" が含まれるか）
cat package.json | grep '"react"'

# TypeScript プロジェクト判定
ls tsconfig.json 2>/dev/null && echo "TypeScript project"
```

| プロジェクトタイプ       | 実行ツール                         |
| ------------------------ | ---------------------------------- |
| React + TypeScript/JS    | react-doctor + similarity-ts + tsr |
| TypeScript/JS（非React） | similarity-ts + tsr                |

---

## 📋 3フェーズワークフロー

### Phase 1: 診断 (Diagnose)

#### 1-A: React プロジェクトの診断

```bash
# package.json に "react" が含まれる場合のみ実行
npx -y react-doctor@latest . --verbose
```

出力を `/tmp/react-doctor-report.txt` に保存して解析する。

#### 1-B: 重複コード検出（全 TS/JS プロジェクト）

```bash
# 90%以上の類似度でスキャン（重篤な重複から開始）
similarity-ts --threshold 0.9 . > /tmp/similarity-report.md

# 型定義の重複チェック（オプション）
similarity-ts --experimental-types --threshold 0.95 src/types/ >> /tmp/similarity-report.md
```

詳細な使用方法 → `../similarity/skills/SKILL.md` を参照。

---

### Phase 2: 分析・計画 (Analyze & Plan)

診断結果を以下の優先度マトリクスで分類する。

#### 優先度マトリクス

| Priority    | 条件                                               | アクション                 |
| ----------- | -------------------------------------------------- | -------------------------- |
| 🔴 Critical | react-doctor errors **かつ** similarity 95%+       | 即時修正（このセッション） |
| 🟡 High     | react-doctor warnings **または** similarity 90-95% | 計画修正（優先度高）       |
| 🟢 Low      | similarity 87-90%（デフォルト閾値）                | 将来候補（要確認）         |

#### 計画の出力フォーマット

```markdown
## リファクタリング計画

### 診断サマリー

- react-doctor スコア: XX/100（75+ = Great, 50-74 = Needs work, 0-49 = Critical）
- 重複コードペア数: XX件（95%+: X件、90-95%: X件）

### 優先アクション

1. 🔴 [Critical] react-doctor error: <内容> → <対処方法>
2. 🔴 [Critical] 重複 95%+: <ファイル1> ↔ <ファイル2> → 共通関数抽出
3. 🟡 [High] react-doctor warning: <内容> → <対処方法>
4. 🟡 [High] 重複 90-95%: <ファイル1> ↔ <ファイル2> → パターン確認

### 推定スコープ

- 即時修正: X件
- 計画修正: X件
- 次回候補: X件
```

---

### Phase 3: 実行 (Execute)

#### 3-1: react-doctor エラーの修正

react-doctor のエラー（最高重大度）から修正する。

```
Error 種別 → 修正アプローチ:
- Architecture: components inside components → コンポーネントをトップレベルに移動
- State & Effects: useState from props → 適切な state 管理へ変更
- Security: hardcoded secrets → 環境変数へ移行
- Bundle Size: barrel imports → 直接インポートへ変更
- Next.js: missing metadata → metadata エクスポート追加
```

react-doctor スキルの詳細 → `../react-doctor/SKILL.md` を参照（存在する場合）。

#### 3-2: 重複コード 95%+ の共通化

```typescript
// パターン1: 単純関数抽出
// Before: 2ファイルに98%類似の関数
// After: 共通 utils に抽出し両ファイルからインポート

// パターン2: ジェネリック化
// Before: getUserById / getAdminById（94%類似）
// After: findByIdOrThrow<T>(model, id, resourceName) に統合

// パターン3: 共通インターフェース抽出
// Before: 類似した型定義が複数
// After: Base 型 + extends で共通部分を一元管理
```

similarity スキルの詳細 → `../similarity/skills/SKILL.md` を参照。

#### 3-3: ESLint/型安全性の問題修正

重複解消後に残るコード品質の問題を修正する。

```bash
# 自動修正を試みる
pnpm lint:fix

# 残存エラーを確認
pnpm lint 2>&1 | tail -20
```

複雑な型安全性問題（any型排除、Result<T,E>パターン）→ `../code-quality-improvement/SKILL.md` に委譲。

#### 3-4: デッドコード削除

リファクタリング後に未使用になったコードを削除する。

```bash
# デッドコード検出
pnpm tsr:check > /tmp/tsr-report.txt

# レポート確認後、段階的に削除
pnpm tsr:fix
```

tsr スキルの詳細 → `../tsr/SKILL.md` を参照。

#### 3-5: 検証（必須）

### 各修正ステップの後に必ず実行する

```bash
pnpm type-check && pnpm lint && pnpm test
```

すべてパスするまで次のフェーズに進まない。

---

## 🔄 スキル間の委譲

| 問題領域                | 委譲先スキル                           |
| ----------------------- | -------------------------------------- |
| 重複コードの詳細分析    | `../similarity/skills/SKILL.md`        |
| ESLint エラー・型安全性 | `../code-quality-improvement/SKILL.md` |
| デッドコード削除        | `../tsr/SKILL.md`                      |
| React 固有パターン診断  | `../react-doctor/SKILL.md`（存在時）   |
| 影響範囲・参照追跡      | MCP Serena: `find_referencing_symbols` |

---

## ⚠️ 重要な注意事項

### 段階的実行の原則

1. 一度に大量変更しない: similarity 95%+ から開始し、90-95% は計画段階で止める
2. コミットを挟む: 各フェーズ完了後に `git commit` してロールバック可能に保つ
3. ビジネスロジックを確認: 高類似度 ≠ 必ず共通化すべき（意味が異なる場合がある）

### MCP Serena との連携

```bash
# 共通化前に影響範囲を確認
# mcp__serena__find_referencing_symbols で参照元を把握
# mcp__serena__find_symbol で実装の詳細を確認
```

### 検証の徹底

```bash
# 修正前: git stash or branch でバックアップ
# 修正後: type-check + lint + test を必ず実行
pnpm type-check && pnpm lint && pnpm test
```

---

## 🎯 期待される成果

- コード重複率の削減（目標: similarity 90%+ ゼロ）
- react-doctor スコアの向上（目標: 75+）
- デッドコードの除去によるコードベースのスリム化
- 型安全性向上（型エラー 0件、ESLint 違反 0件）
