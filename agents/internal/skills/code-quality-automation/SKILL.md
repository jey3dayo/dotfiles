---
name: code-quality-automation
description: Automated lint/format/test execution with iterative fixing. Use when ensuring code quality, fixing lint errors, or running full quality checks.
argument-hint: [--with-comments]
disable-model-invocation: true
user-invocable: true
allowed-tools: Bash, Read, Grep, Edit
---

# Code Quality Automation Skill

Polishes code through lint/format/test cycles, automatically repeating fixes until no errors remain.

## 🎯 Overview

Automatically detects project lint/format/test configuration and runs quality checks with iterative fixing.

### Key Features

- Auto-detection of project configuration (mise.toml, package.json)
- Automatically retries fixes up to 3 times until all errors are resolved
- Staged execution: Format → Lint → Test
- Optional automatic cleanup of verbose comments

### Supported Languages

- JavaScript/TypeScript: ESLint, Prettier, Jest
- Python: Black, Flake8, pytest
- Go: gofmt, golangci-lint
- Rust: rustfmt, clippy, cargo test
- Markdown: markdownlint, prettier
- Ruby: rubocop, rspec

## 🔄 Execution Flow

### 1. Project Configuration Detection

- `mise.toml` task detection (preferred)
- `package.json` script detection (fallback)
- Lint/Format configuration file verification

### 2. Format Execution

```bash
mise run format  # or npm run format
```

- Auto-formats code
- Applies consistent style

### 3. Lint Execution & Auto-Fix

```bash
mise run lint           # error check
mise run lint-fix       # auto-fix
# manual fix (if needed)
```

- Detects lint errors
- Auto-fixes fixable errors
- Attempts manual fix for remaining errors

### 4. Test Execution & Fix

```bash
mise run test  # or npm test
```

- Runs tests
- Fixes failing tests

### 5. Iteration

- Repeats up to 3 times until all checks pass
- Displays result of each step
- Completes when no errors remain

## 📝 Basic Usage

### Standard Execution

```bash
/polish
```

Runs all steps (format → lint → test).

### With Comment Cleanup

```bash
/polish --with-comments
```

In addition to quality checks, cleans up verbose comments:

- Removes comments that merely repeat what the code says
- Preserves WHY explanations, TODOs, and complex logic explanations
- Prompts user for confirmation before deletion

## 📊 Execution Example

```
🔧 Starting Code Polish

📋 Project configuration detection
  ✅ mise.toml detected: format, lint, lint-fix
  ✅ package.json detected: none

🎨 Step 1/3: Running Format
  $ mise run format
  ✅ Formatting complete (3 files updated)

🔍 Step 2/3: Running Lint
  $ mise run lint
  ❌ 5 errors detected

  $ mise run lint-fix
  ✅ 4 of 5 errors auto-fixed

  🔧 Manually fixing remaining 1 error...
  ✅ All lint errors resolved

✅ Step 3/3: Test execution (skipped - no test command)

🎉 Code Polish Complete!
  - Format: ✅ Success
  - Lint: ✅ Success (5 errors fixed)
  - Test: ⊘ Skipped

  Attempts: 2
  Total execution time: 12.3s
```

## 🎯 Common Use Cases

### 1. Development Quality Assurance

```bash
# Run after writing code, before creating a PR
/polish
```

Run periodically during development to maintain quality.

### 2. Post-Review Fix

```bash
# Run after addressing review feedback
/polish
```

After incorporating review feedback, verify overall quality.

### 3. Pre-Merge Final Check

```bash
# Final check before merging
/polish
# Once all pass
/commit
/create-pr
```

Run a final quality check before merging.

## 📚 Detailed References

### Configuration Detection

For detailed configuration detection logic, list of detected tasks, and priority order:
→ `references/configuration-detection.md`

### Execution Flow Details

For detailed execution logic for each step, error handling, and success/failure criteria:
→ `references/execution-flow.md`

### Comment Cleanup Rules

For `--with-comments` option behavior and patterns for comments to delete/preserve:
→ `references/comment-cleanup.md`

### Language-Specific Support

For concrete configuration examples and tool lists for each language:
→ `references/supported-projects.md`

### Workflow Examples

For real-world workflow examples and sample execution results:
→ `examples/workflow-examples.md`

### mise.toml Templates

For language-specific mise.toml configuration templates:
→ `examples/mise-toml-templates.md`

## 🔗 Related Commands

- `/test` - Run tests only
- `/fix-imports` - Fix import statements
- `/clean:full` - Full project cleanup
- `/review` - Run code review

## 💡 Tips

### Recommended: Use mise.toml

Adding `mise.toml` to your project enables unified quality checks:

```toml
[tasks]
format = ["prettier --write ."]
lint = ["eslint .", "prettier --check ."]
lint-fix = ["eslint --fix .", "prettier --write ."]
test = ["npm test"]
```

### Iterative Fixing

This skill minimizes manual intervention by repeating auto-fixes:

1. Auto-fixable errors are resolved with `lint-fix`
2. Remaining errors are attempted manually
3. Repeats until all pass (up to 3 times)

### Comment Cleanup Philosophy

`--with-comments` is a tool to improve code readability:

- Removes: redundant comments that just restate what the code does
- Preserves: WHY explanations, TODOs, warnings
