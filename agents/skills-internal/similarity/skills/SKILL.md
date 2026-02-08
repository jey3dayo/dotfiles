---
name: similarity
description: |
  [What] Specialized skill for detecting code duplication and analyzing code similarity in TypeScript/JavaScript projects. Leverages similarity-ts tool to find duplicate code patterns (>87% similarity), assist refactoring decisions, and identify common patterns for extraction
  [When] Use when: users mention "duplicate code", "similar functions", "code similarity", or need refactoring analysis for TypeScript/JavaScript codebases
  [Keywords] duplicate code, similar functions, code similarity
---

# Similarity - TypeScript/JavaScriptコード類似度検索

TypeScript/JavaScriptコードの類似度を検出し、重複コードの発見とリファクタリング支援を行う専門スキル。

## 🎯 Core Mission

`similarity-ts`ツールを活用し、プロジェクト内の重複コード検出、類似パターンの発見、リファクタリング機会の特定を行う。

## 🛠️ ツール情報

- **コマンド**: `similarity-ts` (v0.1.1)
- **パス**: `~/.cargo/bin/similarity-ts`
- **対応言語**: TypeScript, JavaScript
- **解析手法**: APTED（Tree Edit Distance）アルゴリズム

## 📋 主要機能

### 1. 関数の類似度検出

- TypeScript/JavaScript関数のAST（抽象構文木）ベース比較
- デフォルト閾値: 0.87（87%以上の類似度）
- 構造的類似度（60%）+ 命名類似度（40%）の重み付け

### 2. 型定義の類似性チェック（実験的機能）

- Interface定義の類似性分析
- Type alias定義の類似性分析
- 型リテラルの比較

### 3. カスタマイズ可能なフィルタリング

- 最小行数フィルタ（デフォルト: 3行）
- 最小トークン数フィルタ
- 関数名・関数本体によるフィルタ

## 🚀 基本的な使い方

### プロジェクト全体のスキャン

```bash
# デフォルト設定で全体をスキャン
similarity-ts .

# 特定ディレクトリのみ
similarity-ts src/

# 複数パス指定
similarity-ts src/actions/ src/services/

# レポート出力（推奨）
similarity-ts . > /tmp/similarity-report.md
pnpm report:similarity  # package.jsonで定義されている場合
```

### 閾値を調整した検索

```bash
# 90%以上の類似度で検索（より厳格）
similarity-ts --threshold 0.9 src/

# 80%以上の類似度で検索（より広範囲）
similarity-ts --threshold 0.8 src/

# 95%以上の類似度で検索（ほぼ同一コード検出）
similarity-ts --threshold 0.95 .
```

### 型定義の類似性チェック

```bash
# 型定義の類似度チェック（実験的機能）
similarity-ts --experimental-types src/types/

# Interface定義のみ
similarity-ts --experimental-types --interfaces-only src/

# Type aliasのみ
similarity-ts --experimental-types --types-only src/

# InterfaceとType aliasの相互比較を許可
similarity-ts --experimental-types --allow-cross-kind src/
```

### 特定の関数に絞った検索

```bash
# 関数名で絞り込み（部分一致）
similarity-ts --filter-function "User" src/

# 関数本体の内容で絞り込み
similarity-ts --filter-function-body "prisma.user" src/

# 最小行数を指定
similarity-ts --min-lines 10 src/

# 最小トークン数を指定
similarity-ts --min-tokens 50 src/
```

### コード内容を表示

```bash
# 類似コードの内容も表示
similarity-ts --print src/
```

## 📊 結果の解釈と対応方針

### 類似度レベル別の対応

| 類似度      | 評価                     | 推奨アクション                         |
| ----------- | ------------------------ | -------------------------------------- |
| **95-100%** | ほぼ同一（コピー）       | 即座に共通化・関数抽出                 |
| **90-95%**  | 非常に高い類似性         | リファクタリング必須（優先度：高）     |
| **87-90%**  | 高い類似性（デフォルト） | リファクタリング推奨（優先度：中）     |
| **80-87%**  | 中程度の類似性           | パターン確認・共通化検討（優先度：低） |
| **70-80%**  | 一部類似                 | 参考情報として活用                     |

### アクションプラン

#### 類似度95%以上の場合

```typescript
// Before: 重複コード（類似度98%）
// File: src/services/user-service.ts
export async function getUserById(id: string) {
  const user = await prisma.user.findUnique({ where: { id } });
  if (!user) throw new Error("User not found");
  return user;
}

// File: src/services/admin-service.ts
export async function getAdminById(id: string) {
  const admin = await prisma.admin.findUnique({ where: { id } });
  if (!admin) throw new Error("Admin not found");
  return admin;
}

// After: 共通化
// File: src/lib/repository-utils.ts
export async function findByIdOrThrow<T>(
  model: any,
  id: string,
  resourceName: string,
): Promise<T> {
  const record = await model.findUnique({ where: { id } });
  if (!record) throw new Error(`${resourceName} not found`);
  return record;
}

// File: src/services/user-service.ts
export async function getUserById(id: string) {
  return findByIdOrThrow(prisma.user, id, "User");
}

// File: src/services/admin-service.ts
export async function getAdminById(id: string) {
  return findByIdOrThrow(prisma.admin, id, "Admin");
}
```

#### 類似度87-95%の場合

- パターンの確認と共通化の検討
- ビジネスロジックの差異を精査
- 共通インターフェース・型定義の抽出

## 🎯 実用的な使用シーン

### 1. 重複コード検出（日常的な使用）

```bash
# プロジェクト全体で重複を検出してレポート出力
similarity-ts --threshold 0.9 . > /tmp/similarity-report.md

# 特定の層で重複を検出
similarity-ts --threshold 0.9 src/services/ > /tmp/similarity-services.md
similarity-ts --threshold 0.9 src/actions/ > /tmp/similarity-actions.md

# 結果をスキルで解析
# スキル起動後に /tmp/similarity-report.md を参照して分析
```

### 2. リファクタリング前の調査

```bash
# Userに関連する関数の類似度をチェック
similarity-ts --filter-function "User" --threshold 0.85 src/

# データベース操作の類似パターンを検出
similarity-ts --filter-function-body "prisma" --threshold 0.87 src/
```

### 3. コードレビュー時の活用

```bash
# 新規追加したファイルと既存コードの類似性チェック
similarity-ts --threshold 0.85 src/services/new-service.ts src/services/

# 特定ディレクトリ内の類似度チェック
similarity-ts --print --threshold 0.9 src/actions/
```

### 4. 型定義の統合機会発見

```bash
# 類似した型定義を発見
similarity-ts --experimental-types --threshold 0.9 src/types/

# Interface定義の重複チェック
similarity-ts --experimental-types --interfaces-only --threshold 0.95 src/
```

## 🔧 高度なオプション

### 重み付けのカスタマイズ

```bash
# 構造的類似度を重視（命名の違いを許容）
similarity-ts --structural-weight 0.8 --naming-weight 0.2 src/

# 命名類似度を重視（構造の違いを許容）
similarity-ts --structural-weight 0.4 --naming-weight 0.6 src/
```

### パフォーマンス調整

```bash
# 高速モード無効化（精度重視）
similarity-ts --no-fast src/

# サイズペナルティ無効化
similarity-ts --no-size-penalty src/

# Rename costの調整（デフォルト: 0.3）
similarity-ts --rename-cost 0.5 src/
```

### ファイル拡張子の指定

```bash
# TypeScriptファイルのみ
similarity-ts --extensions ts,tsx src/

# JavaScriptファイルのみ
similarity-ts --extensions js,jsx src/
```

## 🔍 出力の読み方

### 典型的な出力例

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Function: getUserById
  File: src/services/user-service.ts:42
  Lines: 5 | Tokens: 23

Function: getAdminById
  File: src/services/admin-service.ts:38
  Lines: 5 | Tokens: 24

Similarity: 0.94 (94%)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**解釈**:

- 2つの関数が94%の類似度を持つ
- ほぼ同一のロジックを実装している可能性が高い
- 共通化の候補として優先度高

## 🤝 他のツール・コマンドとの連携

### `/refactoring`コマンドとの使い分け

#### `similarity`スキル（このスキル）を使う場合

- ✅ 明らかなコード重複の検出（>87%類似度）
- ✅ 同一パターンの関数統合
- ✅ コピー＆ペーストコードの発見
- ✅ 単純な共通関数の抽出

#### `/refactoring`コマンドを使う場合

- ✅ Result<T,E>パターンへの移行
- ✅ any型の排除・型安全性改善
- ✅ 複雑なビジネスロジックのリファクタリング
- ✅ 層別制約違反の修正
- ✅ コードスメル・アンチパターンの解消

### MCP Serenaとの組み合わせ

```bash
# 1. similarity-tsで重複を検出
similarity-ts --threshold 0.9 src/services/

# 2. MCP Serenaで該当シンボルの参照を確認
# mcp__serena__find_referencing_symbols を使用

# 3. 影響範囲を把握した上でリファクタリング実行
```

### 典型的なワークフロー

```bash
# Step 1: 重複検出とレポート出力
similarity-ts --threshold 0.9 src/ > /tmp/similarity-report.md

# Step 2: スキルでレポート解析・リファクタリング計画立案
# スキル起動後: レポート内容を参照して類似度分析

# Step 3: 該当箇所をMCP Serenaで詳細分析
# mcp__serena__find_symbol を使用して影響範囲を把握

# Step 4: /refactoringコマンドで自動適用または手動修正
# /refactoring --pattern similarity-based src/services/

# Step 5: 品質チェック
# pnpm type-check && pnpm lint && pnpm test
```

## 📋 ベストプラクティス

### 定期的なスキャン

```bash
# 週次または機能追加後に実行
similarity-ts --threshold 0.9 . > /tmp/similarity-$(date +%Y%m%d).md

# プロジェクト固有のreportsディレクトリがある場合
pnpm report:similarity  # reports/similarity-report.md に出力
```

### プロジェクト固有の閾値設定

```bash
# プロジェクトの複雑度に応じて閾値を調整
# 小規模プロジェクト: 0.95（厳格）
# 中規模プロジェクト: 0.90（標準）
# 大規模プロジェクト: 0.87（広範囲）
```

### 段階的なリファクタリング

1. **検出**: similarity-tsで類似度95%以上を検出
2. **分析**: 該当箇所の詳細分析（MCP Serena活用）
3. **計画**: 共通化の影響範囲を評価
4. **実行**: テストを書いてから共通化
5. **検証**: type-check, lint, test実行

## ⚠️ 制約・注意事項

### 技術的制約

- TypeScript/JavaScriptのみ対応
- ASTベースの解析のため、コメントや空白は無視される
- 型定義チェックは実験的機能（--experimental-types）

### 注意点

- **高い類似度 ≠ 必ず共通化すべき**: ビジネスロジックの意図を確認
- **命名の違い**: 類似していても意味的に異なる場合がある
- **テストの重要性**: 共通化前に必ずテストを書く
- **段階的な適用**: 一度に大量の共通化は避ける

### 誤検出の可能性

```typescript
// 例: 構造は似ているが、意味が異なる
// これらは共通化すべきではない

// ユーザー作成
async function createUser(data: UserInput) {
  const validated = validateUserInput(data);
  return await prisma.user.create({ data: validated });
}

// 管理者作成（追加の権限チェックが必要）
async function createAdmin(data: AdminInput) {
  const validated = validateAdminInput(data);
  return await prisma.admin.create({ data: validated });
}
```

## 🎓 実践例

### 例1: Service層の重複検出

```bash
# Service層全体をスキャンしてレポート出力
similarity-ts --threshold 0.9 --min-lines 5 src/services/ > /tmp/similarity-services.md

# スキルでレポート解析
# スキル起動後: /tmp/similarity-services.md を読み込んで分析

# 結果に基づいてリファクタリング
# （共通のRepository層またはUtility関数を作成）
```

### 例2: Action層のパターン統一

```bash
# FormData処理パターンの類似度チェック
similarity-ts --filter-function-body "FormData" --threshold 0.85 src/actions/ > /tmp/similarity-actions.md

# スキルでパターン解析
# スキル起動後: /tmp/similarity-actions.md を読み込んで分析

# 結果: 類似度90%以上のFormData処理パターンを発見
# → 共通のconvertFormDataToAction関数を作成
```

### 例3: 型定義の整理

```bash
# 型定義の重複検出
similarity-ts --experimental-types --threshold 0.95 src/types/ > /tmp/similarity-types.md

# スキルで型定義解析
# スキル起動後: /tmp/similarity-types.md を読み込んで分析

# 結果: 類似したUser型とAdmin型を発見
# → 共通のBase型を抽出し、継承を活用
```

## 📚 関連リソース

### 詳細ドキュメント

詳細な使用方法は`references/`ディレクトリを参照:

- **references/report-analysis.md**: レポート解析とリファクタリング計画の立て方

### 外部リソース

- **similarity-tsリポジトリ**: Rust製のTypeScript/JavaScript類似度検出ツール
- **APTED論文**: Tree Edit Distance アルゴリズムの詳細
- **プロジェクト固有ガイド**: `CLAUDE.md`, `.claude/essential/integration-guide.md`

## 🎯 期待される成果

- コード重複率の削減（目標: 5%以下）
- 保守性の向上（共通ロジックの一元管理）
- バグリスクの低減（重複コードの不整合防止）
- リファクタリング効率の向上（自動検出による時間短縮）

---

**使用タイミング**: 機能追加後、定期的なコード品質チェック時、リファクタリング計画時
**所要時間**: プロジェクト全体スキャン 10-30秒、分析・対応計画 5-15分
