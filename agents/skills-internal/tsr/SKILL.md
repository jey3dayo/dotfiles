---
name: tsr
description: |
  [What] Specialized skill for detecting and removing unused TypeScript/React code (dead code). Leverages TSR (TypeScript Remove Unused) tool with flexible configuration system supporting project-specific, home directory, and default settings
  [When] Use when: users mention "unused code", "dead code", "tsr", or need codebase cleanup for TypeScript/React projects
  [Keywords] unused code, dead code, tsr
---

# TSR - TypeScript未使用コード検出・削除

TypeScript/Reactプロジェクトの未使用コード(デッドコード)を安全に検出・削除する専門スキル。柔軟な設定システムにより、プロジェクト固有の設定とグローバル設定を統合管理できます。

## 新機能: 柔軟な設定システム

### 設定ファイルの優先順位(カスケーディング)

TSRは以下の順序で設定を読み込み、マージします:

1. **プロジェクトルート** (最高優先): `.tsr-config.json`
2. **ホームディレクトリ**: `~/.config/tsr/config.json`
3. **デフォルト設定** (最低優先): `tsr-config.default.json`

### 設定ファイル形式

```json
{
  "version": "1.0.0",
  "tsconfig": "tsconfig.json",
  "ignoreFile": ".tsrignore",
  "entryPatterns": ["src/.*\\.(ts|tsx)$"],
  "maxDeletionPerRun": 10,
  "includeDts": false,
  "recursive": false,
  "ignorePatterns": [],
  "verification": {
    "typeCheck": true,
    "lint": true,
    "test": false
  },
  "reporting": {
    "outputPath": "/tmp/tsr-report-{date}.txt",
    "verbose": false
  },
  "framework": {
    "type": "nextjs",
    "nextjs": {
      "appRouter": true,
      "pagesRouter": false
    }
  }
}
```

### 設定フィールド詳細

| フィールド                     | 型       | デフォルト                   | 説明                                                           |
| ------------------------------ | -------- | ---------------------------- | -------------------------------------------------------------- |
| `version`                      | string   | "1.0.0"                      | 設定ファイルのバージョン                                       |
| `tsconfig`                     | string   | "tsconfig.json"              | TypeScript設定ファイルのパス(プロジェクトルートからの相対パス) |
| `ignoreFile`                   | string   | ".tsrignore"                 | 除外パターンファイルのパス                                     |
| `entryPatterns`                | string[] | ["src/.*\\.(ts\|tsx)$"]      | エントリーポイントパターン                                     |
| `maxDeletionPerRun`            | number   | 10                           | 1回の実行で削除する最大数                                      |
| `includeDts`                   | boolean  | false                        | .d.tsファイルを解析対象に含める                                |
| `recursive`                    | boolean  | false                        | 再帰的削除モード                                               |
| `ignorePatterns`               | string[] | []                           | 追加の除外パターン(.tsrignoreとマージ)                         |
| `verification.typeCheck`       | boolean  | true                         | 削除後に型チェックを実行                                       |
| `verification.lint`            | boolean  | true                         | 削除後にlintを実行                                             |
| `verification.test`            | boolean  | false                        | 削除後にテストを実行                                           |
| `reporting.outputPath`         | string   | "/tmp/tsr-report-{date}.txt" | レポート出力パス({date}は自動置換)                             |
| `reporting.verbose`            | boolean  | false                        | 詳細出力モード                                                 |
| `framework.type`               | string   | "nextjs"                     | フレームワークタイプ(nextjs\|react\|node\|custom)              |
| `framework.nextjs.appRouter`   | boolean  | true                         | Next.js App Router使用                                         |
| `framework.nextjs.pagesRouter` | boolean  | false                        | Next.js Pages Router使用                                       |

### 設定管理コマンド

```bash
# 設定を表示
node config-loader.ts

# プロジェクト設定を作成
cat > .tsr-config.json <<EOF
{
  "version": "1.0.0",
  "maxDeletionPerRun": 20,
  "framework": {
    "type": "nextjs",
    "nextjs": {
      "appRouter": true,
      "pagesRouter": false
    }
  }
}
EOF

# ホームディレクトリ設定を作成(全プロジェクト共通)
mkdir -p ~/.config/tsr
cat > ~/.config/tsr/config.json <<EOF
{
  "verification": {
    "typeCheck": true,
    "lint": true,
    "test": true
  },
  "reporting": {
    "outputPath": "~/tsr-reports/tsr-{date}.txt",
    "verbose": true
  }
}
EOF
```

## 🎯 Core Mission

`tsr`ツールを活用し、プロジェクト内の未使用エクスポート・未使用ファイルを検出し、柔軟な設定システムと`.tsrignore`との連携で誤検出を除外しながら、段階的かつ安全にデッドコードを削除する。

## 🛠️ ツール情報

- **コマンド**: `tsr` (v1.3.4)
- **パッケージ**: devDependenciesに含まれる
- **対応言語**: TypeScript, JavaScript (React対応)
- **検出方式**: TypeScriptコンパイラAPI + 静的解析
- **設定システム**: カスケーディング設定ローダー

## 📋 主要機能

### 1. 未使用コード検出

- **未使用エクスポート**: 他のファイルから参照されていないexport
- **未使用ファイル**: プロジェクト内で一切使用されていないファイル
- **エントリーポイント追跡**: 正規表現パターンでエントリーポイントを指定

### 2. 安全な削除ワークフロー

- **検出モード** (`tsr`): 未使用コードをレポート(変更なし)
- **削除モード** (`tsr --write`): 実際に削除を実行
- **再帰モード** (`tsr --recursive`): クリーンになるまで繰り返し実行
- **自動検証**: 設定に基づいて type-check/lint/test を自動実行

### 3. 誤検出の除外

- **.tsrignore**: 誤検出パターンを定義
- **フレームワーク自動除外**: Next.js/React特有のファイルを自動判定
- **カスタムパターン**: プロジェクト固有の除外パターンを設定

## 🚀 基本的な使い方

### クイックスタート

```bash
# 1. 設定ファイル生成
node config-loader.ts > config-summary.txt

# 2. プロジェクト固有設定を作成(オプション)
cat > .tsr-config.json <<EOF
{
  "version": "1.0.0",
  "maxDeletionPerRun": 15,
  "framework": {
    "type": "nextjs",
    "nextjs": {
      "appRouter": true
    }
  }
}
EOF

# 3. デッドコード検出
pnpm tsr:check

# 4. レポート確認後、削除実行
pnpm tsr:fix
```

### package.jsonスクリプト

```json
{
  "scripts": {
    "tsr:check": "tsr 'src/.*\\.(ts|tsx)$'",
    "tsr:fix": "tsr -w 'src/.*\\.(ts|tsx)$'",
    "tsr:config": "node config-loader.ts"
  }
}
```

## 📊 典型的な使用フロー

### Step 1: 設定確認

```bash
# 現在の設定を確認
pnpm tsr:config

# 出力例:
# TSR Configuration
# ==================================================
# Project Root: /path/to/project
# Config Source: project
#
# Resolved Paths:
#   tsconfig: /path/to/project/tsconfig.json
#   ignoreFile: /path/to/project/.tsrignore
#   outputPath: /tmp/tsr-report-20260115.txt
#
# Settings:
#   Framework: nextjs
#   Max Deletion: 15
#   Include .d.ts: false
#   Recursive: false
# ==================================================
```

### Step 2: 検出

```bash
# デッドコード検出とレポート出力
pnpm tsr:check > /tmp/tsr-report.txt
```

### Step 3: レポート解析

レポートを確認し、以下を分類:

1. **安全に削除可能**: 明らかに未使用
2. **要確認**: 誤検出の可能性あり
3. **保持**: 必要だが使用が追跡できないもの

### Step 4: .tsrignore更新

誤検出パターンを`.tsrignore`に追加:

```
# Next.js特有のファイル
src/app/**/page.tsx
src/app/**/layout.tsx
src/app/api/**/*.ts

# テスト関連
*.test.ts
*.spec.ts
src/mocks/**
```

### Step 5: 段階的削除

```bash
# 設定に基づいて削除(maxDeletionPerRunまで)
pnpm tsr:fix

# 自動検証が実行される(verification設定による)
# - pnpm type-check (verification.typeCheck: true)
# - pnpm lint (verification.lint: true)
# - pnpm test (verification.test: true)
```

## 🎯 実用的な使用シーン

### 1. 定期的なコードベースクリーンアップ

```bash
# 週次または機能追加後に実行
pnpm tsr:check > /tmp/tsr-$(date +%Y%m%d).txt

# スキルで解析
# スキル起動後: /tmp/tsr-{date}.txt を読み込んで分析
```

### 2. リファクタリング後のクリーンアップ

```bash
# リファクタリング後のデッドコード検出
pnpm tsr:check > /tmp/tsr-after-refactor.txt

# 結果を確認して削除
pnpm tsr:fix
```

### 3. CI/CD統合

```yaml
# GitHub Actions例
- name: Check for dead code
  run: pnpm tsr:check
```

## 📋 .tsrignoreファイルの設定

### 基本構造

```
# コメント行は # で始まる

# Glob パターンでファイルを指定
*.config.ts
src/app/**/page.tsx

# 特定のファイル
middleware.ts
next-env.d.ts
```

### 自動生成

設定ファイルに基づいて`.tsrignore`を自動生成できます:

```typescript
import { loadTsrConfig, generateTsrIgnore } from "./config-loader";

const config = await loadTsrConfig("/path/to/project");
const ignoreContent = await generateTsrIgnore(config);
console.log(ignoreContent);
```

詳細は `references/tsrignore.md` を参照。

## ⚠️ 制約・注意事項

### 誤検出の可能性

以下は使用されているが、誤検出される可能性があります:

1. **Next.js特有のファイル**
   - `page.tsx`, `layout.tsx`, `loading.tsx`, `error.tsx`
   - API Routes (`src/app/api/**/*.ts`)
   - Middleware (`middleware.ts`)

2. **動的インポート**
   - `import()` による遅延ロード
   - 文字列ベースのインポート

3. **テスト関連**
   - テストファイル (_.test.ts,_.spec.ts)
   - Storybook (\*.stories.tsx)
   - モックデータ (src/mocks/\*\*)

4. **型定義**
   - 型定義ファイル (\*.d.ts)
   - 型のみのエクスポート

### 安全な削除のために

1. **段階的な削除**: `maxDeletionPerRun`設定で制御(デフォルト10件)
2. **自動検証**: `verification`設定で削除後の検証を自動化
3. **Git commit**: 削除前にコミットしてロールバック可能に
4. **.tsrignore管理**: 誤検出パターンを適切に管理

## 🔧 高度な使用方法

### カスタム設定例

```json
{
  "version": "1.0.0",
  "maxDeletionPerRun": 20,
  "includeDts": false,
  "recursive": false,
  "verification": {
    "typeCheck": true,
    "lint": true,
    "test": true
  },
  "reporting": {
    "outputPath": "~/tsr-reports/tsr-{date}.txt",
    "verbose": true
  },
  "framework": {
    "type": "nextjs",
    "nextjs": {
      "appRouter": true,
      "pagesRouter": false
    }
  },
  "ignorePatterns": ["src/experimental/**", "src/deprecated/**"]
}
```

### プロジェクトタイプ別設定

#### Next.js (App Router)

```json
{
  "framework": {
    "type": "nextjs",
    "nextjs": {
      "appRouter": true,
      "pagesRouter": false
    }
  }
}
```

#### Next.js (Pages Router)

```json
{
  "framework": {
    "type": "nextjs",
    "nextjs": {
      "appRouter": false,
      "pagesRouter": true
    }
  }
}
```

#### React (非Next.js)

```json
{
  "framework": {
    "type": "react"
  }
}
```

#### Node.js

```json
{
  "framework": {
    "type": "node"
  },
  "entryPatterns": ["src/.*\\.ts$"]
}
```

## 🤝 他のツール・コマンドとの連携

### Knipとの比較

| 特徴         | TSR                          | Knip                 |
| ------------ | ---------------------------- | -------------------- |
| 検出対象     | 未使用エクスポート・ファイル | 未使用依存関係も含む |
| 削除         | ✅ 自動削除可能              | ❌ レポートのみ      |
| 設定の複雑さ | 🟢 シンプル                  | 🟡 やや複雑          |
| Next.js対応  | 🟢 良好                      | 🟡 要設定            |

### Similarityスキルとの連携

```bash
# 1. Similarityで重複コード削除
similarity-ts --threshold 0.9 src/ > /tmp/similarity-report.md

# 2. リファクタリング実行

# 3. TSRでデッドコード削除
pnpm tsr:check > /tmp/tsr-report.txt
pnpm tsr:fix
```

### Refactoringコマンドとの組み合わせ

```bash
# 1. /refactoring でコード改善

# 2. TSRでデッドコード削除
pnpm tsr:fix

# 3. 品質チェック(自動実行)
# verification設定により自動実行
```

## 📚 関連リソース

### 詳細ドキュメント

- **config-loader.ts**: 設定ローダーの実装
- **tsr-config.schema.json**: 設定スキーマ定義
- **tsr-config.default.json**: デフォルト設定
- **references/workflow.md**: 実行ワークフローの詳細
- **references/tsrignore.md**: .tsrignore設定ガイド
- **references/examples.md**: 実践例とユースケース

### 外部リソース

- **TSRリポジトリ**: [GitHub - line/tsr](https://github.com/line/tsr)
- **プロジェクト固有ガイド**: `CLAUDE.md`, `.claude/essential/integration-guide.md`

## 🎯 期待される成果

- **コードベースのスリム化**: 未使用コードの削除により、保守性向上
- **ビルド時間の短縮**: 不要なファイルの削除により、コンパイル時間削減
- **バンドルサイズの削減**: 未使用コードの除去により、最終バンドルサイズ削減
- **コードの可読性向上**: 使用されているコードのみが残り、理解しやすくなる
- **設定の柔軟性**: プロジェクト固有とグローバル設定の統合管理

## 🎓 実践的なワークフロー

### 初回セットアップ

```bash
# 1. 設定確認
pnpm tsr:config

# 2. プロジェクト固有設定を作成(必要に応じて)
cat > .tsr-config.json <<EOF
{
  "version": "1.0.0",
  "maxDeletionPerRun": 15,
  "verification": {
    "typeCheck": true,
    "lint": true,
    "test": false
  }
}
EOF

# 3. .tsrignore自動生成
node config-loader.ts --generate-ignore > .tsrignore

# 4. 初回検出
pnpm tsr:check > /tmp/tsr-initial.txt

# 5. レポート確認後、削除実行
pnpm tsr:fix
```

### 週次クリーンアップ

```bash
# Step 1: 検出
pnpm tsr:check > /tmp/tsr-weekly.txt

# Step 2: レポート確認
# スキル起動後: /tmp/tsr-weekly.txt を読み込んで分析

# Step 3: 安全な削除
pnpm tsr:fix

# Step 4: 自動検証(verification設定により自動実行)

# Step 5: コミット
git add -A
git commit -m "chore: remove unused code"
```

---

**使用タイミング**: 週次メンテナンス、リファクタリング後、大規模機能削除後
**所要時間**: プロジェクト全体スキャン 5-15秒、分析・削除 5-10分
**設定時間**: 初回セットアップ 5-10分、その後は自動
