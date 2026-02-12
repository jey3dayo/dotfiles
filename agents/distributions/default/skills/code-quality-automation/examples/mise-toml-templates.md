# mise.toml Templates

言語別のmise.toml設定テンプレート。

## 📋 Template Structure

基本的な構造：

```toml
[tasks]
format = ["<format-command>"]
lint = ["<lint-command>"]
lint-fix = ["<lint-fix-command>"]
test = ["<test-command>"]
```

## 📦 JavaScript/TypeScript

### Basic Template

```toml
[tasks]
format = ["prettier --write ."]
lint = ["eslint ."]
lint-fix = ["eslint --fix ."]
test = ["npm test"]
```

### Advanced Template (Multiple Checks)

```toml
[tasks.format]
run = [
  "prettier --write .",
]

[tasks.lint]
run = [
  "eslint .",
  "prettier --check .",
  "tsc --noEmit",  # Type check
]

[tasks.lint-fix]
run = [
  "eslint --fix .",
  "prettier --write .",
]

[tasks.test]
run = ["npm test"]

[tasks.test-watch]
run = ["npm test -- --watch"]
```

### Monorepo Template

```toml
[tasks.format]
run = [
  "prettier --write .",
]

[tasks.lint]
run = [
  "eslint packages/**/src/**/*.ts",
  "prettier --check .",
]

[tasks.lint-fix]
run = [
  "eslint --fix packages/**/src/**/*.ts",
  "prettier --write .",
]

[tasks.test]
run = [
  "npm test --workspaces",
]
```

## 🐍 Python

### Basic Template

```toml
[tasks]
format = ["black .", "isort ."]
lint = ["flake8 ."]
lint-fix = ["black .", "isort ."]
test = ["pytest"]
```

### Advanced Template (with mypy)

```toml
[tasks.format]
run = [
  "black .",
  "isort .",
]

[tasks.lint]
run = [
  "flake8 .",
  "mypy .",
  "black --check .",
  "isort --check .",
]

[tasks.lint-fix]
run = [
  "black .",
  "isort .",
  "autoflake --remove-all-unused-imports --in-place -r .",
]

[tasks.test]
run = ["pytest"]

[tasks.test-coverage]
run = ["pytest --cov=src --cov-report=html"]
```

### Poetry Project Template

```toml
[tasks.format]
run = [
  "poetry run black .",
  "poetry run isort .",
]

[tasks.lint]
run = [
  "poetry run flake8 .",
  "poetry run mypy .",
]

[tasks.lint-fix]
run = [
  "poetry run black .",
  "poetry run isort .",
]

[tasks.test]
run = ["poetry run pytest"]
```

## 🐹 Go

### Basic Template

```toml
[tasks]
format = ["gofmt -w .", "goimports -w ."]
lint = ["golangci-lint run"]
lint-fix = ["golangci-lint run --fix"]
test = ["go test ./..."]
```

### Advanced Template (with Coverage)

```toml
[tasks.format]
run = [
  "gofmt -w .",
  "goimports -w .",
]

[tasks.lint]
run = [
  "golangci-lint run",
  "go vet ./...",
]

[tasks.lint-fix]
run = [
  "golangci-lint run --fix",
]

[tasks.test]
run = ["go test ./..."]

[tasks.test-coverage]
run = [
  "go test -coverprofile=coverage.out ./...",
  "go tool cover -html=coverage.out -o coverage.html",
]

[tasks.test-race]
run = ["go test -race ./..."]
```

### Module Project Template

```toml
[tasks.format]
run = [
  "gofmt -w .",
  "goimports -w .",
]

[tasks.lint]
run = [
  "golangci-lint run --timeout 5m",
  "go mod verify",
]

[tasks.lint-fix]
run = [
  "golangci-lint run --fix",
  "go mod tidy",
]

[tasks.test]
run = ["go test -v ./..."]
```

## 🦀 Rust

### Basic Template

```toml
[tasks]
format = ["cargo fmt"]
lint = ["cargo clippy -- -D warnings"]
lint-fix = ["cargo clippy --fix --allow-dirty"]
test = ["cargo test"]
```

### Advanced Template (with Check)

```toml
[tasks.format]
run = ["cargo fmt"]

[tasks.lint]
run = [
  "cargo check",
  "cargo clippy -- -D warnings",
  "cargo fmt -- --check",
]

[tasks.lint-fix]
run = [
  "cargo clippy --fix --allow-dirty",
  "cargo fmt",
]

[tasks.test]
run = ["cargo test"]

[tasks.test-all]
run = [
  "cargo test",
  "cargo test --release",
  "cargo test --doc",
]
```

### Workspace Template

```toml
[tasks.format]
run = ["cargo fmt --all"]

[tasks.lint]
run = [
  "cargo check --workspace",
  "cargo clippy --workspace -- -D warnings",
]

[tasks.lint-fix]
run = [
  "cargo clippy --workspace --fix --allow-dirty",
  "cargo fmt --all",
]

[tasks.test]
run = ["cargo test --workspace"]
```

## 📝 Markdown

### Basic Template

```toml
[tasks]
format = ["prettier --write '**/*.md'"]
lint = ["markdownlint '**/*.md'"]
lint-fix = ["markdownlint --fix '**/*.md'"]
```

### Advanced Template (with Link Check)

```toml
[tasks.format]
run = ["prettier --write '**/*.md'"]

[tasks.lint]
run = [
  "markdownlint '**/*.md'",
  "prettier --check '**/*.md'",
]

[tasks.lint-fix]
run = [
  "markdownlint --fix '**/*.md'",
  "prettier --write '**/*.md'",
]

# Optional: Link validation
[tasks.check-links]
run = ["markdown-link-check '**/*.md'"]
```

## 💎 Ruby

### Basic Template

```toml
[tasks]
format = ["rubocop -a"]
lint = ["rubocop"]
lint-fix = ["rubocop -A"]
test = ["rspec"]
```

### Advanced Template (with RuboCop Auto-correct)

```toml
[tasks.format]
run = ["rubocop -a"]

[tasks.lint]
run = [
  "rubocop",
  "reek",  # Code smell detector
]

[tasks.lint-fix]
run = [
  "rubocop -A",  # Auto-correct all offenses
]

[tasks.test]
run = ["rspec"]

[tasks.test-coverage]
run = ["COVERAGE=true rspec"]
```

### Rails Project Template

```toml
[tasks.format]
run = ["rubocop -a"]

[tasks.lint]
run = [
  "rubocop",
  "bundle exec brakeman",  # Security scanner
]

[tasks.lint-fix]
run = ["rubocop -A"]

[tasks.test]
run = [
  "rspec",
  "rails test:system",
]
```

## 🌐 Multi-Language Projects

### TypeScript + Markdown

```toml
[tasks.format]
run = [
  "prettier --write .",
]

[tasks.lint]
run = [
  "eslint .",
  "markdownlint '**/*.md'",
  "prettier --check .",
]

[tasks.lint-fix]
run = [
  "eslint --fix .",
  "markdownlint --fix '**/*.md'",
  "prettier --write .",
]

[tasks.test]
run = ["npm test"]
```

### Python + Shell Scripts

```toml
[tasks.format]
run = [
  "black .",
  "isort .",
  "shfmt -w scripts/",
]

[tasks.lint]
run = [
  "flake8 .",
  "mypy .",
  "shellcheck scripts/*.sh",
]

[tasks.lint-fix]
run = [
  "black .",
  "isort .",
]

[tasks.test]
run = ["pytest"]
```

### Go + Dockerfile

```toml
[tasks.format]
run = [
  "gofmt -w .",
  "goimports -w .",
]

[tasks.lint]
run = [
  "golangci-lint run",
  "hadolint Dockerfile",
]

[tasks.lint-fix]
run = [
  "golangci-lint run --fix",
]

[tasks.test]
run = ["go test ./..."]
```

## 💡 Best Practices

### Task Naming

統一的な命名規則：

- `format`: コード整形
- `lint`: エラーチェック
- `lint-fix`: 自動修正
- `test`: テスト実行
- `test-coverage`: カバレッジ付きテスト
- `test-watch`: ウォッチモード

### Command Organization

```toml
# Single command
[tasks]
format = ["prettier --write ."]

# Multiple commands (sequential)
[tasks.lint]
run = [
  "eslint .",
  "prettier --check .",
]

# Multiple commands (parallel - future)
[tasks.lint]
run = [
  { cmd = "eslint .", parallel = true },
  { cmd = "prettier --check .", parallel = true },
]
```

### Environment Variables

```toml
[tasks.test]
env = { NODE_ENV = "test" }
run = ["npm test"]

[tasks.lint]
env = { ESLINT_USE_FLAT_CONFIG = "true" }
run = ["eslint ."]
```

### Conditional Execution

```toml
[tasks.lint]
run = """
if [ -f .eslintrc.js ]; then
  eslint .
fi
"""
```

## 🔗 Related

- `configuration-detection.md` - 設定検出方法
- `supported-projects.md` - 言語別詳細
- `SKILL.md` - 基本的な使い方
