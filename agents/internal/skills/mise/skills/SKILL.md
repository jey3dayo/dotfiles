---
name: mise
description: |
  [What] Specialized skill for mise (mise-en-place) task runner, tool version manager, and package manager. Provides best practices for mise.toml structure, task definitions, dependency management, tool/package centralization, and workflow automation
  [When] Use when: users mention "mise", "mise-en-place", "mise.toml", work with task runner configurations, tool version management, npm/Python package migration, or need guidance on Centralized Package Management
  [Keywords] mise, mise-en-place, mise.toml, tool management, package management, npm global, python packages
---

# mise - Task Runner Configuration Expert

## Overview

This skill provides specialized guidance for working with mise (mise-en-place), a modern task runner and development environment manager. Evaluate and create mise.toml configurations following 2025 best practices, focusing on task dependencies, parallel execution, and maintainable workflows.

mise combines:

- Task Runner: Execute development workflows with dependency management
- Tool Version Manager: Manage language runtimes and tools
- Environment Manager: Handle project-specific environment variables

## Core Capabilities

### 1. Task Definition Design

Create well-structured task definitions with proper separation of concerns.

#### run - Task Implementation

Define what the task actually does:

- Purpose: Contains the actual commands to execute
- Execution: Runs serially inside the task's shell
- Usage: Core logic, command sequences, inline sub-tasks

### Example

```toml
[tasks.test]
description = "Run test suite"
run = [
  "cargo test --all-features",
  { task = "post-test-metrics" }  # Inline sub-task
]
```

#### depends - Prerequisites

Declare what must complete before this task starts:

- Purpose: Pure declarative prerequisites
- Execution: Builds global DAG, runs once, enables parallelism
- Usage: Ordering constraints, shared setup tasks, fan-out patterns

### Example

```toml
[tasks.test]
description = "Run test suite"
depends = ["build", "lint"]  # Parallel execution
run = "cargo test"
```

### Key Distinction

- `run`: WHAT this task does (imperative)
- `depends`: WHAT must finish BEFORE (declarative)

### 2. Alias Management

Design effective task shortcuts for developer productivity.

### Alias Strategy

- Single character (`b`, `t`, `l`): Daily-use tasks (build, test, lint)
- Two characters (`cb`, `fmt`, `ci`): Common operations
- Prefix with `+` (`+ci`, `+all`): Meta-tasks that orchestrate others

### Example

```toml
[tasks.build]
description = "Build project"
alias = ["b"]
run = "cargo build --release"

[tasks.test]
description = "Run tests"
alias = ["t"]
depends = ["build"]
run = "cargo test"

[tasks."+ci"]
description = "Full CI pipeline"
depends = ["lint", "test", "build"]
```

### 3. Dependency Management

Structure task dependencies for optimal parallelism and correctness.

#### Pattern A: Parallel Fan-Out, Serial Fan-In

```toml
[tasks.build]
run = "cargo build --release"

[tasks.lint]
run = "eslint ."

[tasks.test]
depends = ["build", "lint"]  # build & lint run in parallel
run = "cargo test"
```

#### Pattern B: Meta-Task Orchestration

```toml
[tasks.release]
description = "Build, sign and publish"
run = [
  { task = "build" },
  { task = "sign" },
  { tasks = ["publish-github", "publish-s3"] },  # Parallel
]
```

#### Pattern C: File Task Integration

```bash
#!/usr/bin/env bash
#MISE description="Apply database migrations"
#MISE alias=["dbm"]
#MISE depends=["setup-db"]
prisma migrate deploy
```

### 4. Configuration Structure

Organize mise.toml for maintainability and clarity.

### Recommended Order

1. `[settings]` - Global mise settings
2. `[env]` - Project-wide environment variables
3. `[tools]` - Tool versions
4. `[tasks]` - Task definitions (see internal structure below)

### Task Section Internal Structure

Within the `[tasks]` section, organize tasks logically by responsibility:

1. Individual Commands - Concrete tasks that perform actual work
   - Example: `format:terraform`, `lint:app`, `build:frontend`
   - Characteristics: Contains `run` with actual commands

2. Aggregation Tasks - Tasks that orchestrate multiple related commands
   - Example: `format`, `lint`, `test`
   - Characteristics: Uses `depends` to coordinate related tasks

3. Aliases/Meta-Tasks - Top-level orchestration for common workflows
   - Example: `ci`, `+all`, `release`
   - Characteristics: High-level coordination, often used in CI/CD

### Recommended Comment Structure

```toml
# ========================================
# グローバル設定
# ========================================
[env]
...

[tools]
...

# ========================================
# コマンド（実際の処理を行うタスク）
# ========================================
[tasks."format:terraform"]
...

[tasks."lint:app"]
...

# ========================================
# エイリアス（まとめ実行のショートカット）
# ========================================
[tasks.ci]
depends = ["format", "lint", "test", "build"]
```

### Example

```toml
# mise.toml
[settings]
jobs = 8
paranoid = true

[env]
RUST_BACKTRACE = "1"
NODE_ENV = "development"

[tools]
node = "22"
rust = "stable"

[tasks.build]
description = "Build project"
run = "cargo build"
```

### 5. Tool Version Management

Manage language runtimes and global packages in a unified, version-controlled manner.

#### Core Principle: Centralized Package Management

- ✅ DO: Declare ALL npm and Python packages in `mise.toml` using `"npm:<package>"` or `"pipx:<package>"`
- ❌ DON'T: Use `npm install -g` or `pip install --user` - leads to drift and reproducibility issues

### Tool Categories

```toml
[tools]
# Runtimes
node = "22"
python = "3.12"
rust = "stable"

# CLI Tools
github-cli = "latest"
shellcheck = "latest"

# NPM Global Packages
"npm:prettier" = "latest"
"npm:typescript" = "latest"
"npm:@fsouza/prettierd" = "latest"

# Python Global Packages
"pipx:black" = "latest"
"pipx:ruff" = "latest"
```

### Migration from global-package.json

1. Convert each dependency to `"npm:<package-name>" = "latest"`
2. Remove `global-package.json` and update docs
3. Run `mise install` to install all tools
4. Verify with `mise ls` and `which <command>`

### Benefits

- Single source of truth for all tools and packages
- Version control and team consistency
- Cross-platform reproducibility
- No global npm/pip pollution

### Reference

### 6. Advanced Features

Leverage mise's advanced capabilities for complex workflows.

### Additional Dependencies

- `depends_post`: Tasks that run after this task completes
- `wait_for`: Soft dependency (only waits if already running)

### Task Properties

- `retry`: Number of retries on failure
- `timeout`: Maximum execution time
- `dir`: Working directory override
- `env`: Task-specific environment variables

### Example

```toml
[tasks.integration-test]
description = "Integration tests with retry"
depends = ["build", "setup-db"]
depends_post = ["cleanup"]
retry = 2
timeout = "10m"
env = { DATABASE_URL = "postgresql://localhost/test" }
run = "pytest tests/integration"
```

## Best Practices Summary

### File Organization

✅ **DO:**

- Keep single mise.toml at project root
- Place long scripts in `mise-tasks/` or `scripts/`
- Order sections: settings → env → tools → tasks
- Within tasks section: individual commands → aggregation tasks → aliases/meta-tasks
- Use section separator comments for readability (`# === Commands ===`)
- Use descriptive task names and always include `description`

❌ **DON'T:**

- Embed >3 lines of shell in `run` arrays
- Call `mise <task>` inside run strings (use `{ task = "x" }`)
- Create circular dependencies
- Use conflicting alias names

### Task Design

✅ **DO:**

- Use `depends` for prerequisites and parallelism
- Use `run` for core task logic
- Keep tasks focused on single responsibility
- Group related tasks with common prefixes

❌ **DON'T:**

- Mix ordering logic in `run` that belongs in `depends`
- Create deeply nested inline tasks
- Duplicate common setup across tasks (extract to shared task)

### Naming Conventions

✅ **DO:**

- Use lowercase-kebab-case for task names
- Prefix meta-tasks with `+`
- Choose intuitive short aliases
- Document complex task dependencies

## Review Workflow

When reviewing existing mise.toml:

1. Check Structure: Verify section ordering and organization
2. Analyze Dependencies: Review `depends` vs `run` usage
3. Evaluate Parallelism: Identify opportunities for parallel execution
4. Validate Aliases: Check for conflicts and intuitive naming
5. Test DAG: Run `mise task deps <task>` to visualize
6. Check Best Practices: Verify against reference guidelines
7. Performance: Consider compilation time and execution efficiency

### Reference

## Common Issues

### Issue: Nested mise Calls

### Problem

```toml
[tasks.bad]
run = "mise build && mise test"  # ❌ Creates nested processes
```

### Solution

```toml
[tasks.good]
run = [
  { task = "build" },
  { task = "test" }
]
```

### Issue: Wrong Dependency Type

### Problem

```toml
[tasks.test]
run = [
  { task = "build" },  # ❌ Should be depends
  "cargo test"
]
```

### Solution

```toml
[tasks.test]
depends = ["build"]  # ✅ Proper prerequisite
run = "cargo test"
```

### Issue: Missing Parallelism

### Problem

```toml
[tasks.ci]
run = [
  { task = "lint" },
  { task = "test" },
  { task = "build" }
]  # ❌ All serial
```

### Solution

```toml
[tasks.ci]
depends = ["lint", "test", "build"]  # ✅ Parallel execution
```

## Integration

### With CI Systems

- Use `mise ci bootstrap` as single entry point
- Pin mise version: `mise use -g mise@2025.10`
- Set `MISE_JOBS=$(nproc)` for parallel execution
- Let mise orchestrate entire build pipeline

### With Development Tools

- Linters: Integrate via tasks with proper dependencies
- Formatters: Create format/format:check task pairs
- Test Runners: Use `depends` for setup tasks
- Build Systems: Coordinate with mise's DAG

## Resources

### references/

Detailed documentation loaded as needed:

- `best-practices.md` - 2025 field-tested best practices, comprehensive guide on run vs depends, command composition patterns
- `current-patterns.md` - Real-world examples from dotfiles project, practical task patterns
- `config-templates.md` - Common mise.toml templates and patterns
- `tool-management.md` - Tool version management, Centralized Package Management, npm/Python migration guides, troubleshooting

### Usage

## 🤖 Agent Integration

このスキルはmiseタスクランナー設定タスクを実行するエージェントに専門知識を提供します:

### Orchestrator Agent

- 提供内容: mise.toml設計、タスク依存関係管理、ワークフロー最適化
- タイミング: miseタスクランナー設定・最適化時
- コンテキスト:
  - タスク定義ベストプラクティス
  - 依存関係管理（depends, run連鎖）
  - コマンド構成パターン
  - 並列実行とDAG構造

### Code-Reviewer Agent

- 提供内容: mise.toml品質評価、設定レビュー
- タイミング: mise設定レビュー時
- コンテキスト: タスク構造評価、依存関係検証、ベストプラクティス準拠

### Error-Fixer Agent

- 提供内容: mise設定エラー修正、タスク依存関係修正
- タイミング: mise実行エラー対応時
- コンテキスト: 設定エラー診断、依存関係ループ検出、タスク修正

### 自動ロード条件

- "mise"、"mise-en-place"、"mise.toml"に言及
- mise.tomlファイル操作時
- タスク依存関係、エイリアスについて質問
- ワークフロー自動化の最適化要求

### 統合例

```
ユーザー: "mise.tomlのタスク依存関係を最適化"
    ↓
TaskContext作成
    ↓
プロジェクト検出: mise設定
    ↓
スキル自動ロード: mise
    ↓
エージェント選択: orchestrator
    ↓ (スキルコンテキスト提供)
mise依存関係管理パターン + DAG構造最適化
    ↓
実行完了（並列実行可能化、依存関係明確化）
```

## Trigger Conditions

Activate this skill when:

- User mentions "mise", "mise-en-place", "mise.toml"
- Working with task runner configurations
- Questions about task dependencies or aliases
- Need to optimize workflow automation
- Reviewing or creating mise configurations
- Discussion of parallel execution or DAG structures
