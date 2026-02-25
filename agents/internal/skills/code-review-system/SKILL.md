---
name: code-review-system
description: Comprehensive code review with multiple modes - detailed (5-star evaluation), simple (parallel agents), PR review, CI diagnostics. Use when reviewing code quality, fixing PR comments, or diagnosing CI failures.
argument-hint: "[--simple] [--staged|--recent|--branch <name>] [--with-impact] [--fix] [--fix-ci [pr-number]] [--fix-pr [pr-number]]"
disable-model-invocation: true
user-invocable: true
allowed-tools: Task, Bash(gh:*), Read, Grep, Glob
---

# Code Review System - Integrated Code Review System

A skill that performs comprehensive code reviews. Provides multiple review modes and delivers reviews optimized for your project.

## ⚠️ Important Notes

### GitHub Integration

- This system performs local reviews only
- There is no feature to post comments to GitHub PRs
- Review results are displayed locally
- All review results are output in English

### No-Signature Policy

### IMPORTANT

- ❌ **NEVER** include "Co-authored-by: Claude" in commits
- ❌ **NEVER** include "Generated with Claude Code"
- ❌ **NEVER** use emojis in commits, PRs, or issues
- ❌ **NEVER** include AI signatures or watermarks

## Execution Modes

### 1. Detailed Mode (Default)

Performs comprehensive quality assessment:

- ⭐️ Multi-dimensional evaluation with 5-star rating system
- Automatic project type detection
- Tech stack-specific skill integration (typescript, react, golang, security, etc.)
- Detailed improvement suggestions and action plan

### Usage Examples

```bash
/review                    # Basic review
/review --with-impact      # With impact analysis
/review --fix              # With auto-fix
```

### 2. Simple Mode

Focused on rapid issue discovery:

- Parallel sub-agent execution (security, performance, quality, architecture)
- Prioritized issue list
- Immediate fix suggestions
- GitHub issue integration option

### Usage Examples

```bash
/review --simple           # Quick review
/review --simple --fix     # Review + auto-fix
```

### 3. CI Diagnostics Mode

Diagnoses GitHub Actions CI failures and creates fix plans.

- Generates failure classification and fix plans using the `ci-diagnostics` skill
- Assists with log retrieval using the `gh-fix-ci` skill

### Usage Examples

```bash
/review --fix-ci           # Diagnose PR on current branch
/review --fix-ci 123       # Specify PR number
/review --fix-ci --dry-run # Diagnose only (no fix)
```

### 4. CI Diagnostics + PR Comment Fix Mode

Runs CI diagnostics and PR comment fixes in the same flow. Creates a fix plan based on results from both.

### Usage Examples

```bash
/review --fix-ci --fix-pr      # Run both for PR on current branch
/review --fix-ci 123 --fix-pr  # Specify PR number
/review --fix-ci --fix-pr --dry-run # Diagnose/classify only
```

## Usage

### Basic Usage

```bash
# Detailed mode (default)
/review

# Simple mode
/review --simple
```

### Target File Selection

Review targets are automatically determined in the following priority order:

1. Staged changes (`git diff --cached`)
2. Previous commit (`git diff HEAD~1`)
3. Diff with development branch (`git diff origin/develop`, etc.)
4. Recently modified files

### Explicit Specification

```bash
/review --staged           # Staged changes only
/review --recent           # Previous commit only
/review --branch develop   # Diff with specified branch
```

### Serena Integration (Detailed Mode)

Adds semantic analysis capabilities:

```bash
/review --with-impact      # API change impact analysis
/review --deep-analysis    # Symbol-level detailed analysis
/review --verify-spec      # Spec consistency verification
```

### Workflow Integration

```bash
/review --fix              # Review + auto-fix
/review --create-issues    # Review + create GitHub issues
/review --learn            # Review + record learning data
```

### PR Review Fix

Auto-fix GitHub PR review comments:

```bash
/review --fix-pr           # Fix PR on current branch
/review --fix-pr 123       # Specify PR number
/review --fix-pr --priority critical  # Fix critical issues only
/review --fix-pr --dry-run # Dry run (no fix)
```

## Option Reference

### Mode Selection

- `--simple`: Use simple mode (default is detailed mode)
- `--fix-ci [PR number]`: CI diagnostics mode (GitHub Actions)
- `--fix-ci --fix-pr [PR number]`: CI diagnostics + PR comment fix mode

### Target Specification

- `--staged`: Staged changes only
- `--recent`: Previous commit only
- `--branch <name>`: Diff with specified branch

### Serena Integration (Detailed Mode Only)

- `--with-impact`: API change impact analysis
- `--deep-analysis`: Deep semantic analysis
- `--verify-spec`: Spec consistency verification

### Workflow

- `--fix`: Apply auto-fix
- `--create-issues`: Create GitHub issues
- `--learn`: Record learning data

### PR Review Fix

- `--fix-pr [PR number]`: PR review comment fix mode
- `--priority <level>`: Priority level to fix (critical/high/major/minor)
- `--bot <name>`: Only comments from a specific bot (e.g., coderabbitai)
- `--category <cat>`: Specific category only (security/bug/style/etc)
- `--dry-run`: Dry run (classify only, no fix)

### CI Diagnostics

- `--fix-ci [PR number]`: CI diagnostics mode (GitHub Actions)
- `--dry-run`: Dry run (diagnose only, no fix)

## Project-Specific Customization

This system operates in the following priority order:

1. Project-specific command: If `./.claude/commands/review.md` exists, it is executed
2. Project-specific guidelines: If `./.claude/review-guidelines.md` exists, it is applied
3. Generic review: If neither exists, the code-review skill's default behavior is used

To define project-specific evaluation guidelines, place a file in one of the following locations:

- `./.claude/review-guidelines.md`
- `./docs/review-guidelines.md`
- `./docs/guides/review-guidelines.md`

If these files exist, they are automatically integrated into the evaluation guidelines.

Details: [project-customization.md](references/project-customization.md)

## Tech Stack-Specific Skills

The code-review skill automatically integrates the following skills:

- typescript: TypeScript-specific perspectives (type safety, strict mode, type guards)
- react: React-specific perspectives (hooks, performance, component design)
- golang: Go-specific perspectives (error handling, concurrency, idioms)
- security: Security perspectives (input validation, authentication/authorization, data protection)
- clean-architecture: Architecture perspectives (layer separation, dependency rules, domain modeling)

The appropriate skill is automatically selected based on the project type.

Details: [tech-stack-skills.md](references/tech-stack-skills.md)

## Detailed References

- [Execution Mode Details](references/execution-modes.md) - Detailed specs and execution flows for 4 modes
- [Skill Integration Details](references/skill-integration-detail.md) - Skill integration details and flow
- [Project Customization](references/project-customization.md) - Hybrid behavior and guidelines
- [Tech Stack-Specific Skills](references/tech-stack-skills.md) - Project detection and evaluation criteria

## Usage Examples

- [Review Workflows](examples/review-workflows.md) - 5 practical workflows
- [Troubleshooting](examples/troubleshooting-solutions.md) - Common issues and solutions

## Troubleshooting

### Checkpoint creation fails

This is normal when there are no changes. Having existing checkpoints is also fine.

### GitHub issue creation fails

```bash
# Verify gh CLI is installed
gh --version

# Check authentication status
gh auth status
```

### Serena options not working

Verify that the Serena MCP server is configured (`.claude/mcp.json`).

## Related Commands

- `/fix`: Run direct error fix (error-fixer agent)
- `/todos`: TODO list management
- `/learnings`: View learning data
- `/task`: Generic task execution

---

### Goal
