# Configuration Detection

コードの品質チェックツールの設定を自動検出します。

## 🔍 Detection Strategy

### Priority Order

1. **mise.toml** (highest priority)
2. **package.json** scripts
3. **Fallback**: Language-specific defaults

### Rationale

mise.tomlを最優先とする理由：

- 統一的なタスク定義（言語非依存）
- 複数タスクの組み合わせが容易
- プロジェクト横断で一貫性を保てる
- エディタ・CI/CDとの統合が簡単

## 📋 mise.toml Detection

### Basic Structure

```toml
[tasks]
format = ["prettier --write ."]
lint = ["eslint .", "prettier --check ."]
lint-fix = ["eslint --fix .", "prettier --write ."]
test = ["npm test"]
```

### Detected Tasks

| Task Name  | Purpose        | Required |
| ---------- | -------------- | -------- |
| `format`   | コード整形     | ✅ Yes   |
| `lint`     | エラーチェック | ✅ Yes   |
| `lint-fix` | 自動修正       | Optional |
| `test`     | テスト実行     | Optional |

### Detection Logic

```python
# 1. Check if mise.toml exists
if os.path.exists("mise.toml"):
    config = parse_toml("mise.toml")

    # 2. Extract [tasks] section
    if "tasks" in config:
        tasks = config["tasks"]

        # 3. Check for required tasks
        has_format = "format" in tasks
        has_lint = "lint" in tasks
        has_lint_fix = "lint-fix" in tasks
        has_test = "test" in tasks

        return {
            "source": "mise.toml",
            "tasks": tasks,
            "has_format": has_format,
            "has_lint": has_lint,
            "has_lint_fix": has_lint_fix,
            "has_test": has_test
        }
```

### Task Execution

```bash
# Format
mise run format

# Lint
mise run lint

# Lint fix
mise run lint-fix

# Test
mise run test
```

### Advanced Patterns

#### Multiple Tools

```toml
[tasks.format]
run = [
  "prettier --write .",
  "gofmt -w ."
]

[tasks.lint]
run = [
  "eslint .",
  "golangci-lint run",
  "prettier --check ."
]
```

#### Conditional Execution

```toml
[tasks.lint]
run = "if [ -f .eslintrc.js ]; then eslint .; fi"

[tasks.test]
run = "if [ -f package.json ]; then npm test; fi"
```

## 📦 package.json Detection

### Basic Structure

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

### Script Name Variants

| Standard   | Variants          | Purpose        |
| ---------- | ----------------- | -------------- |
| `format`   | `fmt`, `prettier` | コード整形     |
| `lint`     | `eslint`, `check` | エラーチェック |
| `lint:fix` | `lint-fix`, `fix` | 自動修正       |
| `test`     | `jest`, `vitest`  | テスト実行     |

### Detection Logic

```python
# 1. Check if package.json exists
if os.path.exists("package.json"):
    pkg = parse_json("package.json")

    # 2. Extract scripts section
    if "scripts" in pkg:
        scripts = pkg["scripts"]

        # 3. Find format script
        format_script = find_script(scripts, ["format", "fmt", "prettier"])

        # 4. Find lint script
        lint_script = find_script(scripts, ["lint", "eslint", "check"])

        # 5. Find lint-fix script
        lint_fix_script = find_script(scripts, [
            "lint:fix", "lint-fix", "fix", "eslint:fix"
        ])

        # 6. Find test script
        test_script = find_script(scripts, ["test", "jest", "vitest"])

        return {
            "source": "package.json",
            "scripts": {
                "format": format_script,
                "lint": lint_script,
                "lint_fix": lint_fix_script,
                "test": test_script
            }
        }
```

### Script Execution

```bash
# Format
npm run format

# Lint
npm run lint

# Lint fix
npm run lint:fix  # or npm run lint-fix

# Test
npm test  # or npm run test
```

## 🔄 Fallback Strategies

### Language-Specific Defaults

#### JavaScript/TypeScript

```bash
# Format
npx prettier --write .

# Lint
npx eslint .

# Lint fix
npx eslint --fix .

# Test
npm test
```

#### Python

```bash
# Format
black .

# Lint
flake8 .

# Lint fix
black . && isort .

# Test
pytest
```

#### Go

```bash
# Format
gofmt -w .

# Lint
golangci-lint run

# Lint fix
golangci-lint run --fix

# Test
go test ./...
```

#### Rust

```bash
# Format
cargo fmt

# Lint
cargo clippy

# Lint fix
cargo clippy --fix

# Test
cargo test
```

## 🎯 Detection Results

### Success Example

```
📋 プロジェクト設定検出
  ✅ mise.toml 検出
     - format: ✅ 定義あり
     - lint: ✅ 定義あり
     - lint-fix: ✅ 定義あり
     - test: ⊘ 未定義

  ℹ️  package.json 検出
     - scripts: あり（使用しない）
```

### Partial Detection Example

```
📋 プロジェクト設定検出
  ⚠️  mise.toml 検出
     - format: ⊘ 未定義
     - lint: ✅ 定義あり
     - lint-fix: ⊘ 未定義
     - test: ✅ 定義あり

  ✅ package.json 検出
     - format: npm run format
     - lint: （mise.toml使用）
     - lint-fix: npm run lint:fix
     - test: （mise.toml使用）
```

### Fallback Example

```
📋 プロジェクト設定検出
  ❌ mise.toml 未検出
  ❌ package.json 未検出

  ℹ️  フォールバック: 言語別デフォルト
     - 言語: TypeScript
     - format: npx prettier --write .
     - lint: npx eslint .
     - lint-fix: npx eslint --fix .
     - test: npm test
```

## 💡 Best Practices

### Recommended: mise.toml

```toml
[tasks]
# Format
format = ["prettier --write ."]

# Lint (combined check)
lint = [
  "eslint .",
  "prettier --check ."
]

# Lint fix (combined fix)
lint-fix = [
  "eslint --fix .",
  "prettier --write ."
]

# Test
test = ["npm test"]
```

### Benefits of mise.toml

1. **Language-agnostic**: 同じ構造で複数言語をサポート
2. **Tool-agnostic**: どのツールでも統一的に実行
3. **Composable**: 複数コマンドの組み合わせが容易
4. **Discoverable**: `mise tasks` で一覧表示

### Migration from package.json

```bash
# Before (package.json)
npm run format
npm run lint
npm run lint:fix
npm test

# After (mise.toml)
mise run format
mise run lint
mise run lint-fix
mise run test
```

すべて `mise run <task>` で統一。

## 🔗 Related

- `execution-flow.md` - 検出した設定の実行方法
- `supported-projects.md` - 言語別の設定例
- `examples/mise-toml-templates.md` - テンプレート集
