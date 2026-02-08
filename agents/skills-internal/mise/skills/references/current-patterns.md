# Current Patterns - Real-World mise.toml Examples

This document shows practical mise.toml patterns extracted from actual projects, demonstrating how to apply best practices in real-world scenarios.

## Source Project: Claude Code Dotfiles

The examples below are from a Claude Code project's mise.toml, showing documentation management tasks.

## Project Structure

### Complete mise.toml

```toml
# Claude Code プロジェクト管理用 mise 設定

[env]
_.path = ['./node_modules/.bin']

[tools]
node = '22'         # 最新LTS
fd = 'latest'       # ファイル検索用
prettier = 'latest' # コードフォーマッター

# === ドキュメント管理 ===
[tasks."docs:lint"]
description = "Markdownファイルのlintチェック"
run = "markdownlint-cli2 'commands/**/*.md' 'docs/**/*.md' 'skills/**/*.md' 'agents/**/*.md' 'CLAUDE.md' '*.md'"

[tasks."docs:fix"]
description = "Markdownファイルの自動修正"
run = "markdownlint-cli2 --fix 'commands/**/*.md' 'docs/**/*.md' 'skills/**/*.md' 'agents/**/*.md' 'CLAUDE.md' '*.md'"

[tasks."docs:links"]
description = "Markdownリンクチェック"
run = "fd -e md -X npx markdown-link-check --quiet --config .markdown-link-check.json"

[tasks."docs:links:verbose"]
description = "Markdownリンクチェック(詳細モード)"
run = "fd -e md -X npx markdown-link-check --verbose --config .markdown-link-check.json"

[tasks."docs:format"]
description = "Prettierでフォーマット"
run = "prettier --write --cache --log-level warn 'commands/**/*.md' 'docs/**/*.md' 'skills/**/*.md' 'agents/**/*.md' 'CLAUDE.md' '*.md'"

[tasks."docs:format:check"]
description = "Prettierフォーマットチェック"
run = "prettier --check --cache 'commands/**/*.md' 'docs/**/*.md' 'skills/**/*.md' 'agents/**/*.md' 'CLAUDE.md' '*.md'"

# === エイリアス ===
[tasks.format]
description = "全ての自動修正を実行"
depends = ["docs:fix", "docs:format"]

[tasks.lint]
description = "全体検証(修正はしない)"
depends = ["docs:lint", "docs:format:check", "docs:links"]
```

## Pattern Analysis

### Pattern 1: Namespace Organization

### Structure:

```toml
[tasks."docs:lint"]
[tasks."docs:fix"]
[tasks."docs:links"]
[tasks."docs:format"]
[tasks."docs:format:check"]
```

### Benefits:

- Groups related tasks with `:` separator
- Clear hierarchy: `docs:operation:variant`
- Easy to discover related tasks with `mise tasks | grep docs:`

### Usage:

```bash
mise docs:lint          # Run specific task
mise tasks | grep docs: # List all docs tasks
```

### Pattern 2: Check/Fix Pairs

### Pattern:

```toml
[tasks."docs:format:check"]
description = "Prettierフォーマットチェック"
run = "prettier --check --cache '...'"

[tasks."docs:format"]  # Note: not "docs:format:fix"
description = "Prettierでフォーマット"
run = "prettier --write --cache '...'"
```

### Convention:

- `:check` suffix for validation (CI-friendly)
- No suffix for modification (developer-friendly)
- Base command is the action, check is the variant

### Benefits:

- Clear intent: check vs modify
- CI uses `:check` tasks
- Developers use base tasks for quick fixes

### Pattern 3: Meta-Tasks with depends

### Implementation:

```toml
[tasks.format]
description = "全ての自動修正を実行"
depends = ["docs:fix", "docs:format"]

[tasks.lint]
description = "全体検証(修正はしない)"
depends = ["docs:lint", "docs:format:check", "docs:links"]
```

### Key Points:

- **No run property** - Pure orchestration via depends
- **Parallel execution** - All dependencies run concurrently
- **Short aliases** - `format` and `lint` are easy to type

### Execution Flow:

```bash
mise format
# Runs in parallel:
# - docs:fix (markdownlint-cli2 --fix)
# - docs:format (prettier --write)

mise lint
# Runs in parallel:
# - docs:lint (markdownlint-cli2)
# - docs:format:check (prettier --check)
# - docs:links (markdown-link-check)
```

### Pattern 4: Tool Version Management

### Configuration:

```toml
[tools]
node = '22'         # 最新LTS
fd = 'latest'       # ファイル検索用
prettier = 'latest' # コードフォーマッター
```

### Benefits:

- Explicit version control
- Comments explain tool purpose
- Team uses consistent versions

### Alternative Patterns:

```toml
[tools]
node = "22.0.0"     # Pin exact version
node = "22"         # Latest in v22
node = "latest"     # Always latest (not recommended for reproducibility)
```

### Pattern 5: Environment Path Extension

### Configuration:

```toml
[env]
_.path = ['./node_modules/.bin']
```

### Purpose:

- Add `node_modules/.bin` to PATH
- Use npm-installed tools without npx
- Enables direct command usage in tasks

### Effect:

```bash
# Without _.path
mise run "npx prettier --write ..."

# With _.path
mise run "prettier --write ..."  # Cleaner
```

## Usage Examples

### Daily Development Workflow

```bash
# Quick format before commit
mise format

# Validate before push
mise lint

# Check specific aspect
mise docs:links
```

### CI/CD Integration

```yaml
# GitHub Actions
- name: Lint documentation
  run: mise lint

- name: Check links
  run: mise docs:links
```

### Task Composition

### Building Complex Workflows:

```toml
# Individual tasks (fine-grained)
[tasks."docs:lint"]
run = "markdownlint-cli2 ..."

[tasks."docs:format:check"]
run = "prettier --check ..."

# Meta-task (coarse-grained)
[tasks.ci]
description = "Full CI pipeline"
depends = ["lint", "test", "build"]
```

## Lessons Learned

### 1. Use depends for Orchestration

### Before (Sequential):

```toml
[tasks.format-all]
run = [
  "markdownlint-cli2 --fix '...'",
  "prettier --write '...'"
]
```

### After (Parallel):

```toml
[tasks.format]
depends = ["docs:fix", "docs:format"]
```

### Benefits:

- 2x faster (parallel execution)
- Easier to maintain (reuse existing tasks)
- Better error isolation

### 2. Consistent Naming

### Pattern:

- `namespace:action:variant`
- Examples: `docs:format`, `docs:format:check`, `docs:links:verbose`

### Benefits:

- Predictable task names
- Easy to grep and filter
- Natural grouping

### 3. Short Meta-Task Names

### Pattern:

```toml
[tasks.format]  # Not "format-all" or "format:all"
[tasks.lint]    # Not "lint-all" or "lint:check"
```

### Rationale:

- Quick to type
- Common operations deserve simple names
- Reserve namespace for implementation details

## Anti-Patterns to Avoid

### ❌ Duplicate Logic

### Bad:

```toml
[tasks.format-md]
run = "prettier --write '*.md'"

[tasks.format-all]
run = [
  "prettier --write '*.md'",
  "other formatting..."
]
```

### Good:

```toml
[tasks."docs:format"]
run = "prettier --write '*.md'"

[tasks.format]
depends = ["docs:format", "code:format"]
```

### ❌ Missing depends for Parallel Work

### Bad:

```toml
[tasks.ci]
run = [
  { task = "lint" },
  { task = "test" }
]  # Sequential
```

### Good:

```toml
[tasks.ci]
depends = ["lint", "test"]  # Parallel
```

### ❌ Inconsistent Naming

### Bad:

```toml
[tasks.check-docs]
[tasks."docs:format"]
[tasks.lintMarkdown]
```

### Good:

```toml
[tasks."docs:check"]
[tasks."docs:format"]
[tasks."docs:lint"]
```

## Summary

### Key Takeaways:

1. **Namespace with colons** - `docs:lint`, `docs:format`
2. **Use depends for meta-tasks** - Enables parallelism
3. **Check/fix pairs** - Clear CI vs development intent
4. **Short names for common tasks** - `format`, `lint`, `test`
5. **Tool version management** - Explicit in `[tools]`

### Result:

- Fast parallel execution
- Maintainable task definitions
- Clear developer workflow
- CI-friendly validation

---

**Source:** Extracted from Claude Code dotfiles project
**Date:** 2025-10-29
