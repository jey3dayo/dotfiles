---
name: polish
description: |
  Code quality assurance with automatic fix iteration. Execute lint/format/test and automatically fix errors until all pass (max 3 attempts).
  [What] Detect project configuration (mise.toml, package.json), run format/lint/test, and iteratively fix errors
  [When] Use when: users mention "polish", "品質保証", "lint fix", "format fix", "quality check", or need automated code quality improvement with repeated fixes
  [Keywords] polish, quality assurance, lint, format, test, automatic fix, code quality
---

# Polish - Code Quality Assurance

## Overview

Automatically polish code by executing lint/format/test and fixing errors iteratively until all checks pass (maximum 3 attempts).

## Core Capabilities

- Auto-detect project configuration (mise.toml, package.json)
- Execute format → lint → test workflow
- Iterative error fixing (max 3 attempts)
- Optional comment cleanup (with --with-comments flag)

## Workflow

1. **Detect Configuration**
   - Check for mise.toml tasks (format, lint, lint-fix)
   - Check for package.json scripts (format, lint, lint:fix, test)

2. **Execute Format**
   - Run `mise run format` or `npm run format`
   - Report formatted files

3. **Execute Lint & Fix**
   - Run lint command
   - If errors found, run lint-fix command
   - If errors remain, attempt manual fixes
   - Repeat until clean or max attempts reached

4. **Execute Tests**
   - Run test command if available
   - Fix test failures if detected
   - Repeat until passing or max attempts reached

5. **Report Results**
   - Display summary of all steps
   - Show total attempts and execution time

## Comment Cleanup (Optional)

When `--with-comments` flag is provided:

### Remove:

- Comments that merely repeat code content
- Self-evident comments (e.g., "constructor" above constructor)
- Obvious statements

### Preserve:

- WHY explanations
- Complex business logic explanations
- TODO, FIXME, HACK markers
- Non-obvious behavior warnings
- Important context information

## Usage

```bash
# Basic execution
/polish

# With comment cleanup
/polish --with-comments
```

## Configuration Detection

### mise.toml

```toml
[tasks]
format = ["prettier --write ..."]
lint = ["markdownlint ...", "prettier --check ..."]
lint-fix = ["markdownlint --fix ...", "prettier --write ..."]
test = ["jest"]
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

## Supported Projects

- JavaScript/TypeScript (ESLint, Prettier, Jest)
- Python (Black, Flake8, pytest)
- Go (gofmt, golangci-lint, go test)
- Rust (rustfmt, clippy, cargo test)
- Markdown (markdownlint, prettier)

## Notes

- Maximum 3 iteration attempts to prevent infinite loops
- Each step's success/failure is clearly reported
- If test command is not found, that step is skipped
- All output is in Japanese
