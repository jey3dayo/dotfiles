---
description: Code quality assurance with automatic fix iteration
argument-hint: [options]
---

# Polish Code - 品質保証＆自動修正

コードをlint/format/testで磨き上げ、エラーが出なくなるまで自動修正を繰り返します。

## 🎯 機能概要

プロジェクトのlint/format/test設定を自動検出し、品質チェックと修正を繰り返し実行します。

オプションでコメント整理機能も提供します：

- 冗長なコメントの自動削除
- 価値あるドキュメント（WHY説明、TODO等）は保持
- コードの可読性を向上

## 🔄 動作フロー

1. **プロジェクト設定検出**

   - `mise.toml` のタスク検出
   - `package.json` のスクリプト検出
   - Lint/Format設定ファイル確認

2. **Format実行**

   - `mise run format` または `npm run format`
   - コードを自動整形

3. **Lint実行＆修正**

   - `mise run lint` でエラーチェック
   - エラーがあれば `mise run lint-fix` で自動修正
   - まだエラーがあれば手動修正を試みる

4. **Test実行＆修正**

   - テストコマンド実行
   - エラーがあれば修正を試みる

5. **繰り返し**
   - すべて成功するまで最大3回繰り返す
   - 各ステップの結果を表示

## 📋 検出される設定

### mise.toml

```toml
[tasks]
format = ["prettier --write ..."]
lint = ["markdownlint ...", "prettier --check ..."]
lint-fix = ["markdownlint --fix ...", "prettier --write ..."]
```

### package.json

```json
{
  "scripts": {
    "format": "prettier --write .",
    "lint": "eslint .",
    "lint:fix": "eslint --fix .",
    "test": "jest"
  }
}
```

## 🚀 使用方法

### 基本実行

```bash
# すべて実行（format → lint → test）
/polish
```

### オプション指定

```bash
# コメント整理を含む完全な品質改善
/polish --with-comments

# 特定のステップのみ（将来実装予定）
/polish --only format
/polish --only lint
/polish --only test

# 最大試行回数を指定（将来実装予定）
/polish --max-attempts 5
```

## 📊 実行例

```
🔧 Code Polish を開始します

📋 プロジェクト設定検出
  ✅ mise.toml 検出: format, lint, lint-fix
  ✅ package.json 検出: なし

🎨 Step 1/3: Format実行
  $ mise run format
  ✅ フォーマット完了（3ファイル更新）

🔍 Step 2/3: Lint実行
  $ mise run lint
  ❌ 5件のエラー検出

  $ mise run lint-fix
  ✅ 5件中4件を自動修正

  🔧 残り1件を手動修正中...
  ✅ すべてのlintエラーを修正

✅ Step 3/3: Test実行（スキップ - testコマンドなし）

🎉 Code Polish 完了！
  - Format: ✅ 成功
  - Lint: ✅ 成功（5件修正）
  - Test: ⊘ スキップ

  試行回数: 2回
  総実行時間: 12.3秒
```

## 🎯 ユースケース

### 開発中の品質保証

```bash
# コードを書いた後、PRを作る前に実行
/polish
```

### レビュー指摘後の修正

```bash
# レビュー指摘を修正した後に実行
/polish
```

### マージ前の最終チェック

```bash
# マージ前の最終確認
/polish
# すべて成功したら
/commit
/create-pr
```

## ⚙️ 対応プロジェクト

- **JavaScript/TypeScript**: ESLint, Prettier, Jest
- **Python**: Black, Flake8, pytest
- **Go**: gofmt, golangci-lint
- **Rust**: rustfmt, clippy, cargo test
- **Markdown**: markdownlint, prettier

## 💡 ヒント

### mise.tomlを活用

プロジェクトに `mise.toml` を追加すると、統一的な品質チェックが可能：

```toml
[tasks]
format = ["prettier --write ."]
lint = ["eslint .", "prettier --check ."]
lint-fix = ["eslint --fix .", "prettier --write ."]
test = ["npm test"]
```

### コメント整理ルール

`--with-comments` オプション使用時の動作：

**削除対象のコメント：**

- コードの内容をそのまま繰り返すだけのコメント
- 自明な内容（例: コンストラクタの上の "constructor" コメント）
- コード自体から明らかな内容

**保持されるコメント：**

- WHY（なぜ）を説明するコメント
- 複雑なビジネスロジックの説明
- TODO, FIXME, HACK などのマーカー
- 非自明な動作の警告
- 重要なコンテキスト情報

### 段階的な実行

特定のステップだけ実行したい場合は、個別コマンドを使用：

- テストのみ: `/test`

## 🔗 関連コマンド

- `/test` - テスト実行のみ
- `/fix-imports` - import文の修正
- `/clean:full` - プロジェクト全体のクリーンアップ
- `/review` - コードレビュー実行

---

name: polish
description: lint/format/testを実行し、エラーが出なくなるまで自動修正

---

## 実装開始

プロジェクトのlint/format/test設定を検出し、品質チェックと修正を繰り返し実行します。

最大3回まで試行し、すべてのエラーを修正します。

`--with-comments` オプションが指定された場合は、コメント整理も実行します：

1. **コメント分析**

   - Grep/Read ツールでコメントパターンを検出
   - 冗長なコメントと価値あるコメントを分類

2. **冗長コメント削除**

   - コードの内容を繰り返すだけのコメントを削除
   - WHY説明、TODO、複雑なロジック説明は保持
   - 削除予定のコメントをユーザーに確認（確認後に適用）

3. **クリーンアップ**
   - Edit ツールで該当コメントを削除
   - コードの可読性を向上

各ステップの結果を表示しながら、段階的に品質を向上させていきます。
