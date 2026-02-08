---
name: review
description: |
  Comprehensive code review with project-specific optimization. Multiple modes: detailed review, simple review, CI diagnosis, PR review automation.
  [What] Execute code-review skill with mode detection, project type detection, and technology stack integration
  [When] Use when: users mention "review", "レビュー", "code review", "品質確認", "CI fix", "PR fix", or need comprehensive code quality assessment
  [Keywords] review, code review, quality assessment, CI diagnosis, PR automation, レビュー
---

# Review - Comprehensive Code Review

## Overview

Execute comprehensive code review by delegating to the `code-review` skill with intelligent mode detection and project optimization.

## Important Notes

### GitHub Integration

- This command executes LOCAL reviews only
- NO GitHub PR comment posting functionality
- All review results are displayed locally
- **All output is in Japanese**

### No-Signature Policy

**IMPORTANT**: Strictly enforce in all outputs:

- Never include "Co-authored-by: Claude" in commits
- Never include "Generated with Claude Code"
- Never use emojis in commits, PRs, issues
- Never include AI signatures or watermarks

## Execution Modes

### 1. Detailed Mode (Default)

Comprehensive quality assessment:

- 5-level rating system for dimensional evaluation
- Auto-detect project type
- Technology stack skill integration (typescript, react, golang, security, etc.)
- Detailed improvement suggestions and action plans

**Usage**:

```bash
/review                    # Basic review
/review --with-impact      # With impact analysis
/review --fix              # With automatic fixes
```

### 2. Simple Mode

Fast issue detection:

- Parallel sub-agent execution (security, performance, quality, architecture)
- Prioritized issue list
- Immediate fix suggestions
- GitHub issue integration option

**Usage**:

```bash
/review --simple           # Quick review
/review --simple --fix     # Review + automatic fixes
```

### 3. CI Diagnosis Mode

Diagnose and fix GitHub Actions CI failures:

- `ci-diagnostics` skill for failure classification and fix planning
- `gh-fix-ci` skill for log retrieval assistance

**Usage**:

```bash
/review --fix-ci           # Diagnose current branch PR
/review --fix-ci 123       # Specify PR number
/review --fix-ci --dry-run # Diagnosis only (no fixes)
```

### 4. CI Diagnosis + PR Review Automation Mode

Execute both CI diagnosis and PR comment fixes in a unified flow:

- Create fix plan based on both CI failures and PR comments
- Only one PR number can be specified

**Usage**:

```bash
/review --fix-ci --fix-pr      # Both on current branch PR
/review --fix-ci 123 --fix-pr  # Specify PR number
/review --fix-ci --fix-pr --dry-run # Diagnosis/classification only
```

### 5. PR Review Automation Mode

Automatically fix GitHub PR review comments:

- `pr-review-automation` skill integration
- Priority-based comment classification (Critical/High/Major/Minor)
- Automatic fixes and quality assurance
- Tracking document generation

**Usage**:

```bash
/review --fix-pr           # Fix current branch PR
/review --fix-pr 123       # Specify PR number
/review --fix-pr --priority critical  # Fix Critical issues only
/review --fix-pr --dry-run # Dry run (no fixes)
```

## Target File Specification

Review targets are automatically determined by priority:

1. Staged changes (`git diff --cached`)
2. Last commit (`git diff HEAD~1`)
3. Diff with develop branch (`git diff origin/develop`)
4. Recently modified files

**Explicit specification**:

```bash
/review --staged           # Staged changes only
/review --recent           # Last commit only
/review --branch develop   # Diff with specified branch
```

## Serena Integration (Detailed Mode)

Add semantic analysis capabilities:

```bash
/review --with-impact      # API change impact analysis
/review --deep-analysis    # Symbol-level detailed analysis
/review --verify-spec      # Specification consistency check
```

## Workflow Integration

```bash
/review --fix              # Review + automatic fixes
/review --create-issues    # Review + GitHub issue creation
/review --learn            # Review + learning data recording
```

## Implementation

This command delegates to the `code-review` skill:

### Mode Selection

```python
# Detect mode from command arguments
if "--fix-ci" in args and "--fix-pr" in args:
    mode = "ci_pr_combined"
elif "--fix-ci" in args:
    mode = "ci_diagnosis"
elif "--fix-pr" in args:
    mode = "pr_review_automation"
elif "--simple" in args:
    mode = "simple"
else:
    mode = "detailed"

# Detect Serena options
serena_enabled = any(opt in args for opt in ['--with-impact', '--deep-analysis', '--verify-spec'])
```

### Checkpoint Creation

Always create pre-review checkpoint:

```bash
git add -A
git commit -m "Pre-review checkpoint" || echo "No changes to commit"
```

### Skill Invocation

Delegate to appropriate skill based on mode:

- **ci_pr_combined**: Execute both `ci-diagnostics` and `pr-review-automation`
- **ci_diagnosis**: Execute `ci-diagnostics` skill
- **pr_review_automation**: Execute `pr-review-automation` skill
- **detailed/simple**: Execute `code-review` skill

## Options

### Mode Selection

- `--simple`: Use simple mode (default is detailed mode)
- `--fix-ci [PR#]`: CI diagnosis mode (GitHub Actions)
- `--fix-ci --fix-pr [PR#]`: CI diagnosis + PR comment fix mode

### Target Specification

- `--staged`: Staged changes only
- `--recent`: Last commit only
- `--branch <name>`: Diff with specified branch

### Serena Integration (Detailed Mode Only)

- `--with-impact`: API change impact analysis
- `--deep-analysis`: Deep semantic analysis
- `--verify-spec`: Specification consistency check

### Workflow

- `--fix`: Apply automatic fixes
- `--create-issues`: Create GitHub issues
- `--learn`: Record learning data

### PR Review Automation (PR Review Mode Only)

- `--fix-pr [PR#]`: PR review comment fix mode
- `--priority <level>`: Fix priority (critical/high/major/minor)
- `--bot <name>`: Specific bot comments only (e.g., coderabbitai)
- `--category <cat>`: Specific category only (security/bug/style/etc)
- `--dry-run`: Dry run (classification only, no fixes)

### CI Diagnosis (CI Diagnosis Mode Only)

- `--fix-ci [PR#]`: CI diagnosis mode (GitHub Actions)
- `--dry-run`: Dry run (diagnosis only, no fixes)

## Project-Specific Customization

### Hybrid Behavior

This command operates with the following priority:

1. **Project-specific command**: Execute `./.claude/commands/review.md` if exists
2. **Project-specific guidelines**: Apply `./.claude/review-guidelines.md` if exists
3. **Generic review**: Use code-review skill default behavior if none above

### Guideline File Customization

Define project-specific evaluation guidelines by placing files at:

- `./.claude/review-guidelines.md`
- `./docs/review-guidelines.md`
- `./docs/guides/review-guidelines.md`

These files are automatically integrated into evaluation guidelines when present.

## Technology Stack Skills

The code-review skill automatically integrates these skills:

- **typescript**: TypeScript-specific perspectives (type safety, strict mode, type guards)
- **react**: React-specific perspectives (hooks, performance, component design)
- **golang**: Go-specific perspectives (error handling, concurrency, idioms)
- **security**: Security perspectives (input validation, auth/authz, data protection)
- **clean-architecture**: Architecture perspectives (layer separation, dependency rules, domain modeling)
- **semantic-analysis**: Semantic analysis (symbol tracking, impact analysis)

Appropriate skills are auto-selected based on project type.

## Notes

- All output is in Japanese
- Creates checkpoint before review
- Automatically detects project type and loads relevant skills
- PR number auto-detection for current branch
- Supports both local and GitHub-integrated workflows
