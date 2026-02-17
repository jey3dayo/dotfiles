# Supported Projects

対応言語とツールの詳細。

## 🌐 Language Support Matrix

| Language              | Format | Lint | Test | Status  |
| --------------------- | ------ | ---- | ---- | ------- |
| JavaScript/TypeScript | ✅     | ✅   | ✅   | Full    |
| Python                | ✅     | ✅   | ✅   | Full    |
| Go                    | ✅     | ✅   | ✅   | Full    |
| Rust                  | ✅     | ✅   | ✅   | Full    |
| Markdown              | ✅     | ✅   | ⊘    | Partial |
| Ruby                  | ✅     | ✅   | ✅   | Full    |

## 📦 JavaScript/TypeScript

### Tools

- **Format**: Prettier
- **Lint**: ESLint
- **Test**: Jest, Vitest, Mocha

### Configuration

#### mise.toml

```toml
[tasks]
format = ["prettier --write ."]
lint = ["eslint ."]
lint-fix = ["eslint --fix ."]
test = ["npm test"]
```

#### package.json

```json
{
  "scripts": {
    "format": "prettier --write .",
    "lint": "eslint .",
    "lint:fix": "eslint --fix .",
    "test": "jest"
  },
  "devDependencies": {
    "@typescript-eslint/eslint-plugin": "^6.0.0",
    "@typescript-eslint/parser": "^6.0.0",
    "eslint": "^8.0.0",
    "prettier": "^3.0.0",
    "jest": "^29.0.0"
  }
}
```

#### .eslintrc.js

```javascript
module.exports = {
  parser: "@typescript-eslint/parser",
  extends: ["eslint:recommended", "plugin:@typescript-eslint/recommended"],
  rules: {
    "@typescript-eslint/no-unused-vars": "error",
    "@typescript-eslint/no-explicit-any": "error",
  },
};
```

#### .prettierrc.json

```json
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": false,
  "printWidth": 80,
  "tabWidth": 2
}
```

### Execution Example

```bash
# Format
mise run format
# または
npm run format

# Lint
mise run lint
# または
npm run lint

# Lint fix
mise run lint-fix
# または
npm run lint:fix

# Test
mise run test
# または
npm test
```

## 🐍 Python

### Tools

- **Format**: Black, isort
- **Lint**: Flake8, pylint
- **Test**: pytest

### Configuration

#### mise.toml

```toml
[tasks]
format = ["black .", "isort ."]
lint = ["flake8 ."]
lint-fix = ["black .", "isort ."]
test = ["pytest"]
```

#### pyproject.toml

```toml
[tool.black]
line-length = 88
target-version = ['py39']

[tool.isort]
profile = "black"

[tool.pytest.ini_options]
testpaths = ["tests"]
```

#### setup.cfg (Flake8)

```ini
[flake8]
max-line-length = 88
extend-ignore = E203, W503
exclude = .git,__pycache__,build,dist
```

### Execution Example

```bash
# Format
mise run format
# または
black . && isort .

# Lint
mise run lint
# または
flake8 .

# Test
mise run test
# または
pytest
```

## 🐹 Go

### Tools

- **Format**: gofmt, goimports
- **Lint**: golangci-lint
- **Test**: go test

### Configuration

#### mise.toml

```toml
[tasks]
format = ["gofmt -w .", "goimports -w ."]
lint = ["golangci-lint run"]
lint-fix = ["golangci-lint run --fix"]
test = ["go test ./..."]
```

#### .golangci.yml

```yaml
linters:
  enable:
    - gofmt
    - goimports
    - govet
    - errcheck
    - staticcheck
    - unused

linters-settings:
  gofmt:
    simplify: true

issues:
  exclude-use-default: false
```

### Execution Example

```bash
# Format
mise run format
# または
gofmt -w . && goimports -w .

# Lint
mise run lint
# または
golangci-lint run

# Lint fix
mise run lint-fix
# または
golangci-lint run --fix

# Test
mise run test
# または
go test ./...
```

## 🦀 Rust

### Tools

- **Format**: rustfmt
- **Lint**: clippy
- **Test**: cargo test

### Configuration

#### mise.toml

```toml
[tasks]
format = ["cargo fmt"]
lint = ["cargo clippy -- -D warnings"]
lint-fix = ["cargo clippy --fix --allow-dirty"]
test = ["cargo test"]
```

#### rustfmt.toml

```toml
edition = "2021"
max_width = 100
tab_spaces = 4
```

#### clippy.toml

```toml
cognitive-complexity-threshold = 30
```

### Execution Example

```bash
# Format
mise run format
# または
cargo fmt

# Lint
mise run lint
# または
cargo clippy -- -D warnings

# Lint fix
mise run lint-fix
# または
cargo clippy --fix --allow-dirty

# Test
mise run test
# または
cargo test
```

## 📝 Markdown

### Tools

- **Format**: Prettier
- **Lint**: markdownlint
- **Test**: ⊘ Not applicable

### Configuration

#### mise.toml

```toml
[tasks]
format = ["prettier --write '**/*.md'"]
lint = ["markdownlint '**/*.md'"]
lint-fix = ["markdownlint --fix '**/*.md'"]
```

#### .markdownlint.json

```json
{
  "default": true,
  "MD013": false,
  "MD033": false,
  "MD041": false
}
```

#### .prettierrc.json

```json
{
  "proseWrap": "always",
  "printWidth": 80
}
```

### Execution Example

```bash
# Format
mise run format
# または
prettier --write '**/*.md'

# Lint
mise run lint
# または
markdownlint '**/*.md'

# Lint fix
mise run lint-fix
# または
markdownlint --fix '**/*.md'
```

## 💎 Ruby

### Tools

- **Format**: rubocop (auto-format)
- **Lint**: rubocop
- **Test**: rspec

### Configuration

#### mise.toml

```toml
[tasks]
format = ["rubocop -a"]
lint = ["rubocop"]
lint-fix = ["rubocop -A"]
test = ["rspec"]
```

#### .rubocop.yml

```yaml
AllCops:
  NewCops: enable
  TargetRubyVersion: 3.0

Style/StringLiterals:
  Enabled: true
  EnforcedStyle: double_quotes

Metrics/BlockLength:
  Enabled: false
```

### Execution Example

```bash
# Format
mise run format
# または
rubocop -a

# Lint
mise run lint
# または
rubocop

# Lint fix
mise run lint-fix
# または
rubocop -A

# Test
mise run test
# または
rspec
```

## 🔧 Multi-Language Projects

### Example: TypeScript + Markdown

#### mise.toml

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

### Example: Python + Shell

#### mise.toml

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

## 📊 Tool Comparison

### Format Tools

| Language | Tool     | Speed     | Config Complexity |
| -------- | -------- | --------- | ----------------- |
| JS/TS    | Prettier | Fast      | Simple            |
| Python   | Black    | Fast      | Simple            |
| Go       | gofmt    | Very Fast | None              |
| Rust     | rustfmt  | Fast      | Simple            |
| Markdown | Prettier | Fast      | Simple            |
| Ruby     | rubocop  | Medium    | Medium            |

### Lint Tools

| Language | Tool          | Features  | Auto-Fix |
| -------- | ------------- | --------- | -------- |
| JS/TS    | ESLint        | Very Rich | Partial  |
| Python   | Flake8        | Rich      | No       |
| Go       | golangci-lint | Very Rich | Partial  |
| Rust     | clippy        | Rich      | Partial  |
| Markdown | markdownlint  | Medium    | Yes      |
| Ruby     | rubocop       | Very Rich | Yes      |

## 💡 Best Practices

### Tool Selection

推奨する組み合わせ：

- **JavaScript/TypeScript**: ESLint + Prettier + Jest
- **Python**: Black + Flake8 + pytest
- **Go**: gofmt + golangci-lint + go test
- **Rust**: rustfmt + clippy + cargo test
- **Markdown**: markdownlint + Prettier

### Configuration Tips

1. Format before Lint: Format実行後にLintを実行
2. Strict Rules: 厳格なルールを設定（型安全性重視）
3. Auto-fix First: 自動修正可能なルールを優先
4. CI Integration: CIでも同じルールを実行

### Performance Optimization

```toml
[tasks.lint]
# 並列実行で高速化
run = [
  { cmd = "eslint .", parallel = true },
  { cmd = "prettier --check .", parallel = true },
]
```

## 🔗 Related

- `configuration-detection.md` - 設定検出方法
- `execution-flow.md` - 実行フロー
- `examples/mise-toml-templates.md` - テンプレート集
