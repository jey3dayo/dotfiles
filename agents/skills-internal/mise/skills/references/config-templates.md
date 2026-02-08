# mise.toml Configuration Templates

This document provides ready-to-use mise.toml templates for common project patterns and workflows.

## Table of Contents

1. [Minimal Template](#minimal-template)
2. [Full-Featured Template](#full-featured-template)
3. [Language-Specific Templates](#language-specific-templates)
4. [Common Task Patterns](#common-task-patterns)
5. [CI/CD Templates](#cicd-templates)

## Minimal Template

A basic mise.toml to get started quickly.

```toml
# mise.toml
[tools]
node = "22"

[tasks.build]
description = "Build the project"
alias = ["b"]
run = "npm run build"

[tasks.test]
description = "Run tests"
alias = ["t"]
depends = ["build"]
run = "npm test"

[tasks.lint]
description = "Lint code"
alias = ["l"]
run = "npm run lint"
```

## Full-Featured Template

Comprehensive template with all common sections and features.

```toml
# mise.toml - Project Task Runner Configuration

# === Settings ===
[settings]
jobs = 8                 # Parallel job limit
paranoid = true          # Extra validation

# === Environment ===
[env]
_.path = ['./node_modules/.bin', './bin']
NODE_ENV = "development"
LOG_LEVEL = "info"

# === Tools ===
[tools]
node = "22"              # LTS version
rust = "1.75"
python = "3.12"
go = "1.21"

# === Development Tasks ===
[tasks.dev]
description = "Start development server"
alias = ["d"]
run = "npm run dev"

[tasks.build]
description = "Build for production"
alias = ["b"]
depends = ["lint", "test"]
run = "npm run build"

[tasks.clean]
description = "Clean build artifacts"
run = "rm -rf dist/ build/ .cache/"

# === Testing ===
[tasks."test:unit"]
description = "Run unit tests"
run = "npm run test:unit"

[tasks."test:integration"]
description = "Run integration tests"
depends = ["build"]
run = "npm run test:integration"

[tasks.test]
description = "Run all tests"
alias = ["t"]
depends = ["test:unit", "test:integration"]

# === Quality Checks ===
[tasks."lint:code"]
description = "Lint source code"
run = "eslint src/"

[tasks."lint:types"]
description = "Check TypeScript types"
run = "tsc --noEmit"

[tasks.lint]
description = "Run all linters"
alias = ["l"]
depends = ["lint:code", "lint:types"]

[tasks."format:check"]
description = "Check code formatting"
run = "prettier --check ."

[tasks.format]
description = "Format code"
alias = ["f"]
run = "prettier --write ."

# === Meta Tasks ===
[tasks."+ci"]
description = "Full CI pipeline"
depends = ["lint", "test", "build"]

[tasks."+check"]
description = "Quick validation (no build)"
depends = ["lint", "format:check"]

[tasks."+fix"]
description = "Auto-fix all issues"
depends = ["format", "lint"]
```

## Language-Specific Templates

### Node.js / TypeScript

```toml
[env]
_.path = ['./node_modules/.bin']
NODE_ENV = "development"

[tools]
node = "22"

[tasks.install]
description = "Install dependencies"
run = "pnpm install"

[tasks."build:types"]
description = "Build TypeScript declarations"
run = "tsc --emitDeclarationOnly"

[tasks."build:js"]
description = "Build JavaScript"
depends = ["build:types"]
run = "esbuild src/index.ts --bundle --outfile=dist/index.js"

[tasks.build]
description = "Full build"
alias = ["b"]
depends = ["build:types", "build:js"]

[tasks.dev]
description = "Development mode with watch"
alias = ["d"]
run = "tsx watch src/index.ts"

[tasks."test:watch"]
description = "Tests in watch mode"
run = "vitest"

[tasks.test]
description = "Run all tests"
alias = ["t"]
run = "vitest run"

[tasks."type-check"]
description = "Check types without emitting"
run = "tsc --noEmit"

[tasks.lint]
description = "Lint with ESLint"
alias = ["l"]
run = "eslint ."

[tasks.format]
description = "Format with Prettier"
alias = ["f"]
run = "prettier --write ."
```

### Rust

```toml
[env]
RUST_BACKTRACE = "1"

[tools]
rust = "stable"

[tasks.build]
description = "Build project"
alias = ["b"]
run = "cargo build"

[tasks."build:release"]
description = "Build optimized release"
run = "cargo build --release"

[tasks.test]
description = "Run tests"
alias = ["t"]
run = "cargo test"

[tasks.check]
description = "Check compilation"
alias = ["c"]
run = "cargo check"

[tasks.clippy]
description = "Run Clippy linter"
alias = ["l"]
run = "cargo clippy -- -D warnings"

[tasks.fmt]
description = "Format code"
alias = ["f"]
run = "cargo fmt"

[tasks."fmt:check"]
description = "Check formatting"
run = "cargo fmt --check"

[tasks.doc]
description = "Generate documentation"
run = "cargo doc --no-deps --open"

[tasks."+ci"]
description = "Full CI checks"
depends = ["fmt:check", "clippy", "test", "build"]
```

### Python

```toml
[env]
PYTHONPATH = "src"

[tools]
python = "3.12"

[tasks.install]
description = "Install dependencies"
run = "pip install -r requirements.txt"

[tasks."install:dev"]
description = "Install dev dependencies"
run = "pip install -r requirements-dev.txt"

[tasks.test]
description = "Run pytest"
alias = ["t"]
run = "pytest tests/"

[tasks."test:cov"]
description = "Run tests with coverage"
run = "pytest --cov=src tests/"

[tasks.lint]
description = "Lint with ruff"
alias = ["l"]
run = "ruff check src/"

[tasks.format]
description = "Format with black"
alias = ["f"]
run = "black src/ tests/"

[tasks."format:check"]
description = "Check formatting"
run = "black --check src/ tests/"

[tasks."type-check"]
description = "Type check with mypy"
run = "mypy src/"

[tasks."+ci"]
description = "Full CI checks"
depends = ["format:check", "lint", "type-check", "test"]
```

### Go

```toml
[tools]
go = "1.21"

[tasks.build]
description = "Build binary"
alias = ["b"]
run = "go build -o bin/app ./cmd/app"

[tasks.test]
description = "Run tests"
alias = ["t"]
run = "go test ./..."

[tasks."test:verbose"]
description = "Run tests with verbose output"
run = "go test -v ./..."

[tasks."test:coverage"]
description = "Run tests with coverage"
run = "go test -coverprofile=coverage.out ./..."

[tasks.lint]
description = "Run golangci-lint"
alias = ["l"]
run = "golangci-lint run"

[tasks.fmt]
description = "Format code"
alias = ["f"]
run = "go fmt ./..."

[tasks.vet]
description = "Vet code"
run = "go vet ./..."

[tasks."+ci"]
description = "Full CI checks"
depends = ["fmt", "vet", "lint", "test"]
```

## Common Task Patterns

### Documentation Management

```toml
[tasks."docs:build"]
description = "Build documentation"
run = "mkdocs build"

[tasks."docs:serve"]
description = "Serve documentation locally"
alias = ["docs"]
run = "mkdocs serve"

[tasks."docs:deploy"]
description = "Deploy documentation"
depends = ["docs:build"]
run = "mkdocs gh-deploy"

[tasks."docs:lint"]
description = "Lint markdown files"
run = "markdownlint-cli2 '**/*.md'"

[tasks."docs:links"]
description = "Check broken links"
run = "markdown-link-check docs/**/*.md"
```

### Database Tasks

```toml
[tasks."db:setup"]
description = "Setup database"
run = "createdb myapp_dev"

[tasks."db:migrate"]
description = "Run migrations"
depends = ["db:setup"]
run = "prisma migrate deploy"

[tasks."db:seed"]
description = "Seed database"
depends = ["db:migrate"]
run = "node scripts/seed.js"

[tasks."db:reset"]
description = "Reset database"
run = [
  "dropdb myapp_dev --if-exists",
  { task = "db:setup" },
  { task = "db:migrate" },
  { task = "db:seed" }
]

[tasks."db:studio"]
description = "Open database studio"
alias = ["db"]
run = "prisma studio"
```

### Docker Integration

```toml
[tasks."docker:build"]
description = "Build Docker image"
run = "docker build -t myapp:latest ."

[tasks."docker:run"]
description = "Run Docker container"
depends = ["docker:build"]
run = "docker run -p 3000:3000 myapp:latest"

[tasks."docker:push"]
description = "Push to registry"
depends = ["docker:build"]
run = "docker push myapp:latest"

[tasks."compose:up"]
description = "Start services"
alias = ["up"]
run = "docker compose up -d"

[tasks."compose:down"]
description = "Stop services"
alias = ["down"]
run = "docker compose down"

[tasks."compose:logs"]
description = "View logs"
alias = ["logs"]
run = "docker compose logs -f"
```

### Release Tasks

```toml
[tasks."release:check"]
description = "Pre-release checks"
depends = ["+ci", "docs:build"]

[tasks."release:version"]
description = "Bump version"
run = "npm version patch"

[tasks."release:build"]
description = "Build release artifacts"
depends = ["release:check"]
run = "npm run build"

[tasks."release:publish"]
description = "Publish release"
depends = ["release:build"]
run = "npm publish"

[tasks.release]
description = "Full release process"
run = [
  { task = "release:check" },
  { task = "release:version" },
  { task = "release:build" },
  { task = "release:publish" }
]
```

## CI/CD Templates

### GitHub Actions Integration

```toml
[tasks."+ci"]
description = "Full CI pipeline"
depends = ["lint", "test", "build"]

[tasks."+ci:fast"]
description = "Quick CI checks"
depends = ["lint", "test:unit"]

[tasks."+ci:full"]
description = "Comprehensive CI"
depends = [
  "lint",
  "format:check",
  "type-check",
  "test",
  "build",
  "docs:build"
]
```

### Corresponding GitHub Actions:

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: jdx/mise-action@v2
        with:
          version: 2025.10.0
      - name: Run CI
        run: mise run +ci
        env:
          MISE_JOBS: 4
```

### Pre-commit Hooks

```toml
[tasks."+pre-commit"]
description = "Pre-commit validation"
depends = ["format", "lint"]

[tasks."+pre-push"]
description = "Pre-push validation"
depends = ["test", "build"]
```

### With Husky:

```json
{
  "hooks": {
    "pre-commit": "mise run +pre-commit",
    "pre-push": "mise run +pre-push"
  }
}
```

## Advanced Patterns

### Multi-Environment Tasks

```toml
[tasks."deploy:dev"]
description = "Deploy to development"
env = { ENVIRONMENT = "development" }
run = "terraform apply -var-file=dev.tfvars"

[tasks."deploy:staging"]
description = "Deploy to staging"
env = { ENVIRONMENT = "staging" }
run = "terraform apply -var-file=staging.tfvars"

[tasks."deploy:prod"]
description = "Deploy to production"
env = { ENVIRONMENT = "production" }
depends = ["+ci"]
run = "terraform apply -var-file=prod.tfvars"
```

### Conditional Tasks

```toml
[tasks.setup]
description = "Project setup"
run = [
  "[ -f .env ] || cp .env.example .env",
  { task = "install" },
  { task = "db:setup" }
]
```

### Cleanup and Maintenance

```toml
[tasks.clean]
description = "Clean all artifacts"
run = [
  "rm -rf dist/ build/ .cache/",
  "rm -rf node_modules/.cache/",
  "find . -name '*.pyc' -delete"
]

[tasks."clean:deep"]
description = "Deep clean including dependencies"
run = [
  { task = "clean" },
  "rm -rf node_modules/",
  "rm -f package-lock.json"
]
```

## Best Practices Checklist

When creating mise.toml:

- ✅ Use `[settings]`, `[env]`, `[tools]`, `[tasks]` order
- ✅ Always include `description` for tasks
- ✅ Use `depends` for prerequisites and parallelism
- ✅ Use `run` for actual commands
- ✅ Create short aliases for frequent tasks
- ✅ Group related tasks with namespaces (`build:types`, `test:unit`)
- ✅ Prefix meta-tasks with `+` (`+ci`, `+check`)
- ✅ Extract long scripts to separate files
- ✅ Use check/fix pairs for validation tasks

---

**Note:** These templates are starting points. Adapt them to your project's specific needs and tooling.
