# .tsrignore Configuration Guide

`.tsrignore`ファイルの設定ガイド。TSRが誤検出するパターンを適切に除外し、正確なデッドコード検出を実現します。

## 📋 基本構造

### ファイルフォーマット

```
# コメント行は # で始まる

# Glob パターンでファイルを指定
*.config.ts
src/app/**/page.tsx

# 特定のファイル
middleware.ts
next-env.d.ts
```

## 🎯 必須パターン (Next.js)

### Next.js 13+ App Router

```
# === Next.js App Router ===
# ページコンポーネント
src/app/**/page.tsx
src/app/**/layout.tsx
src/app/**/loading.tsx
src/app/**/error.tsx
src/app/**/not-found.tsx
src/app/**/template.tsx
src/app/**/default.tsx

# API Routes
src/app/api/**/*.ts
src/app/api/**/*.tsx

# Route Handlers
src/app/**/route.ts

# Middleware
middleware.ts
src/middleware.ts
```

### Next.js 12 Pages Router

```
# === Next.js Pages Router ===
# ページ
pages/**/*.tsx
pages/**/*.ts
pages/api/**/*.ts

# カスタムドキュメント・アプリ
pages/_app.tsx
pages/_document.tsx
pages/_error.tsx
pages/404.tsx
pages/500.tsx
```

## 🔧 設定ファイル

```
# === 設定ファイル ===
*.config.ts
*.config.js
*.config.mjs
*.config.cjs

# 特定の設定ファイル
next.config.js
next.config.mjs
tailwind.config.ts
vitest.config.ts
playwright.config.ts
postcss.config.js
tsconfig.json
eslint.config.js

# 環境設定
next-env.d.ts
.env
.env.local
.env.*.local
```

## 🧪 テスト関連

```
# === テスト関連 ===
# テストファイル
*.test.ts
*.test.tsx
*.spec.ts
*.spec.tsx

# テストディレクトリ
src/tests/**
src/e2e/**
src/__tests__/**
tests/**
e2e/**
__tests__/**

# テスト設定
vitest.setup.ts
playwright.setup.ts
jest.setup.ts

# モック・フィクスチャ
src/mocks/**
src/fixtures/**
src/__mocks__/**
mocks/**
fixtures/**
__mocks__/**

# Storybook
*.stories.ts
*.stories.tsx
.storybook/**
```

## 📦 Prisma関連

```
# === Prisma関連 ===
# Prisma設定
prisma/schema.prisma

# Seed & Migration
prisma/seed.ts
prisma/seeds/**
prisma/migrations/**

# カスタムスクリプト
prisma/*.ts
```

## 📝 型定義

```
# === 型定義 ===
# グローバル型定義
*.d.ts
global.d.ts

# 型定義ディレクトリ
types/**
@types/**

# 型ファイル（プロジェクト固有）
**/types.ts
*.types.ts
```

## 🎨 Storybook

```
# === Storybook ===
# ストーリーファイル
*.stories.ts
*.stories.tsx
*.story.ts
*.story.tsx

# Storybook設定
.storybook/**
storybook-static/**

# Storybookテスト
*.stories.test.ts
*.stories.spec.ts
```

## 🛠️ ビルド成果物

```
# === ビルド成果物 ===
.next/**
dist/**
out/**
build/**
.vercel/**
.turbo/**
node_modules/**
```

## 🔍 スクリプト・ツール

```
# === スクリプト・ツール ===
scripts/**
tools/**
.github/**
.vscode/**

# 開発用ツール
src/dev/**
src/debug/**
src/tools/**
```

## 📊 プロジェクト固有のパターン

### caad-loca-nextプロジェクトの例

```
# === プロジェクト固有 (caad-loca-next) ===
# テスト用ユーティリティ
src/lib/services/test-*.ts
src/lib/utils/test-*.ts

# コンポーネントテスト
src/components/test/**

# 開発/デバッグツール
src/app/debug/**
src/components/debug/**

# MSW (Mock Service Worker)
src/mocks/msw/**
src/mocks/handlers/**

# ファクトリー（テストデータ生成）
src/mocks/factories/**
```

## 🎯 カスタムパターンの追加

### パターン追加の判断基準

以下の場合に.tsrignoreに追加を検討:

1. **TSRが誤検出する**: 実際には使用されているのに検出される
2. **フレームワーク特有**: Next.js等のフレームワークが特別に扱うファイル
3. **動的インポート**: 文字列ベースでインポートされるファイル
4. **型定義のみ**: 型のみをエクスポートするファイル
5. **開発用**: 本番では使わないが、開発環境で必要

### パターン追加の手順

```bash
# 1. TSR実行
pnpm tsr:check > /tmp/tsr-report.txt

# 2. 誤検出を確認
grep "src/app/dashboard/page.tsx" /tmp/tsr-report.txt

# 3. パターンを追加
echo "src/app/dashboard/page.tsx" >> .tsrignore

# または特定ディレクトリ全体
echo "src/app/dashboard/**" >> .tsrignore

# 4. 再実行して確認
pnpm tsr:check > /tmp/tsr-report-after.txt
diff /tmp/tsr-report.txt /tmp/tsr-report-after.txt
```

## 🚨 注意事項

### 過度な除外を避ける

```bash
# ❌ Bad: 広すぎる除外
src/**/*.ts

# ✅ Good: 具体的な除外
src/app/**/page.tsx
src/lib/test-utils.ts
```

### 定期的な見直し

```bash
# .tsrignoreの効果を確認
pnpm tsr:check > /tmp/tsr-with-ignore.txt

# .tsrignore を一時的に無効化して比較
mv .tsrignore .tsrignore.bak
pnpm tsr:check > /tmp/tsr-without-ignore.txt
mv .tsrignore.bak .tsrignore

# 差分確認
diff /tmp/tsr-with-ignore.txt /tmp/tsr-without-ignore.txt
```

## 📝 完全な.tsrignoreテンプレート

### 標準的なNext.js 13+ プロジェクト

```
# TSR (TypeScript React) Ignore Patterns
# これらのパターンにマッチするファイル/エクスポートは誤検出として除外されます

# === 設定ファイル ===
*.config.ts
*.config.js
*.config.mjs
middleware.ts
next-env.d.ts

# === Prisma関連 ===
prisma/seed.ts
prisma/seeds/**

# === スクリプト ===
scripts/**

# === テスト関連 ===
*.test.ts
*.test.tsx
*.spec.ts
*.spec.tsx
src/tests/**
src/e2e/**
src/mocks/**
*.mock.ts
*.mock.tsx

# === Storybook ===
*.stories.ts
*.stories.tsx
.storybook/**

# === ビルド成果物 ===
.next/**
dist/**
out/**

# === Next.js特有のファイル ===
# ページコンポーネント
src/app/**/page.tsx
src/app/**/layout.tsx
src/app/**/loading.tsx
src/app/**/error.tsx
src/app/**/not-found.tsx
src/app/**/template.tsx

# API Routes
src/app/api/**/*.ts
src/pages/api/**/*.ts

# === 型定義 ===
# 型定義は他のファイルで暗黙的に使用される可能性が高い
**/types.ts
**/types.tsx
*.types.ts
*.d.ts

# === 特定のエクスポートパターン ===
# Prisma生成型
@prisma/client

# === プロジェクト固有の除外 ===
# テスト用ユーティリティ
src/lib/services/test-*.ts
src/lib/utils/test-*.ts

# コンポーネントのテスト関連
src/components/test/**

# 開発/デバッグツール
src/app/debug/**
src/components/debug/**

# MSW (Mock Service Worker)
src/mocks/msw/**
src/mocks/handlers/**

# ファクトリー（テストデータ生成）
src/mocks/factories/**

# === 注意事項 ===
# このファイルは慎重に管理してください。
# 誤って本当のデッドコードを除外しないよう、定期的に見直しが必要です。
```

## 🔗 関連リソース

- **メインスキル**: `../skill.md`
- **ワークフロー**: `workflow.md`
- **実践例**: `examples.md`

---

**目標**: 正確なデッドコード検出のための最適な.tsrignore設定を維持する
