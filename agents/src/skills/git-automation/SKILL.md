---
name: git-automation
description: Smart Git workflow automation - intelligent commits with quality gates and automatic PR creation with existing PR detection. Use when committing code or creating pull requests.
disable-model-invocation: true
user-invocable: true
allowed-tools: Bash, Read, Grep, Write
argument-hint: "[commit|pr] [options]"
---

# Git Automation - Smart Git Workflow Automation

Comprehensively automates the Git workflow from commit creation to PR creation. Provides quality gates, AI-driven message generation, and existing PR detection.

## Overview

The git-automation skill provides the following two main features:

1. Smart Commit: Intelligent commit creation with quality checks
2. Auto PR: Automatic formatting, commit splitting, and PR creation/update

Both features adopt common quality gates and a no-signature policy, providing a consistent development experience.

## Basic Usage

### Smart Commit

```bash
# Basic usage (auto-staging + quality check)
/git-automation commit

# Specify message
/git-automation commit "feat: add user authentication"

# Skip quality check
/git-automation commit --no-verify

# Skip tests only
/git-automation commit --skip-tests
```

### Auto PR

```bash
# Basic usage (format -> commit -> PR creation)
/git-automation pr

# Specify title
/git-automation pr "feat: add user authentication feature"

# Specify branch
/git-automation pr --branch feature/auth

# Auto-update existing PR
/git-automation pr --update-if-exists

# Create draft PR
/git-automation pr --draft
```

## Main Options

### Commit Options

| Option         | Description                              |
| -------------- | ---------------------------------------- |
| `[message]`    | Commit message (AI-generated if omitted) |
| `--no-verify`  | Skip all quality checks                  |
| `--skip-tests` | Skip tests only                          |
| `--skip-build` | Skip build only                          |
| `--skip-lint`  | Skip lint only                           |
| `--amend`      | Amend the last commit (use with caution) |

### PR Options

| Option               | Description                               |
| -------------------- | ----------------------------------------- |
| `[title]`            | PR title (auto-generated if omitted)      |
| `--no-format`        | Skip formatting process                   |
| `--single-commit`    | Create with a single commit               |
| `--branch <name>`    | Specify branch name                       |
| `--base <branch>`    | Specify base branch                       |
| `--draft`            | Create as draft PR                        |
| `--update-if-exists` | Auto-update if existing PR exists         |
| `--force-new`        | Skip existing PR check and create new     |
| `--check-only`       | Check existing PR only (no create/update) |
| `--no-template`      | Do not use PR template                    |

## Integrated Workflow Examples

### Commit During Development (with Quality Check)

```bash
# Commit changes (run Lint -> Test -> Build)
/git-automation commit

# What it does:
# 1. Auto-stage changed files
# 2. Run Lint (auto-detected by project-detector)
# 3. Run Tests (based on project configuration)
# 4. Run Build (when necessary)
# 5. Generate AI-driven message
# 6. Create commit (no signature)
```

### When Feature is Complete (PR Creation)

```bash
# Format -> commit splitting -> PR creation
/git-automation pr

# What it does:
# 1. Auto-detect and run formatter
# 2. Semantically group changes
# 3. Split commits (format/feature/fix, etc.)
# 4. Check for existing PR
# 5. Create or update PR
```

### Existing PR Update Workflow

```bash
# Reflect additional changes to existing PR
/git-automation pr --update-if-exists

# What it does:
# 1. Run formatting
# 2. Create commit
# 3. Detect existing PR (gh pr list --head)
# 4. Auto-update PR (update title and body to latest)
```

## Quality Gates

Both features use common quality gates:

### Execution Order

```
Lint -> Test -> Build
```

### Automatic Project Detection

Uses the project-detector common utility:

```python
from shared.project_detector import detect_formatter, detect_project_type

# Detect formatter
formatters = detect_formatter()
# npm/pnpm/yarn run format
# go fmt
# black/ruff

# Detect project type
project = detect_project_type()
# JavaScript/TypeScript
# Go
# Python
# Rust
```

### Skip Conditions

- Automatically skipped when the command does not exist
- When using `--skip-*` options
- When using `--no-verify` (skip all)

## AI-Driven Message Generation

### Commit Message

```
[type]([scope]): [subject]

[body]
```

### Type

### Generation Process

1. Analyze changed files
2. Parse diff content
3. Check recent commit history (detect conventions)
4. Generate Conventional Commits-compliant message

### PR Title and Body

### Title

### Body Structure

```markdown
## Overview

- Change summary (with emoji)

## Changes

### Number of Commits (N)

- Detailed file list

## Test Plan

- Checklist

## Checklist

- Quality items
```

## Existing PR Detection and Response

### Detection Logic

```python
def check_existing_pr(branch_name):
    """Check if there is an existing PR for the current branch"""
    result = subprocess.run(
        ["gh", "pr", "list", "--head", branch_name,
         "--json", "number,title,url,state"],
        capture_output=True,
        text=True
    )

    prs = json.loads(result.stdout)
    # Only target OPEN or DRAFT PRs
    open_prs = [pr for pr in prs if pr['state'] in ['OPEN', 'DRAFT']]
    return open_prs[0] if open_prs else None
```

### Response Policy Decision

| Situation            | Action                                |
| -------------------- | ------------------------------------- |
| `--check-only`       | Check only, no action                 |
| `--force-new`        | Force create new                      |
| `--update-if-exists` | Existing PR -> update, none -> create |
| No existing PR       | Create new                            |
| Existing PR (dialog) | User choice (update/new/cancel)       |

### PR Update

```python
def update_pull_request(pr_number, pr_title, pr_body):
    """Update the title and body of an existing PR"""
    update_command = f"""gh pr edit {pr_number} \
        --title "{pr_title}" \
        --body "$(cat <<'EOF'
{pr_body}
EOF
)""""

    subprocess.run(update_command, shell=True)
```

## Important Design Principles

### No-Signature Policy

### Never Do the Following

- Add "Co-authored-by"
- Add "Generated with Claude Code"
- Add AI/Assistant attribution
- Change Git settings or credentials
- Use emoji (in commits, PRs)

### Reason

### Error Handling

- Prevent partial commits
- Clear error messages
- Provide recovery procedures
- Provide fallback strategies

### Dependent Skills

- integration-framework (required): TaskContext standardization
- code-quality-automation (recommended): Quality check integration
- project-detector (required): Automatic project detection

## Troubleshooting

### Quality Check Failure

```bash
# Run while skipping tests
/git-automation commit --skip-tests

# Skip all quality checks
/git-automation commit --no-verify
```

### Formatter Not Detected

```bash
# Skip formatting
/git-automation pr --no-format

# Run after manual formatting
npm run format
/git-automation pr --no-format
```

### Existing PR Detection Error

```bash
# GitHub CLI not authenticated
gh auth login

# Skip existing PR check
/git-automation pr --force-new
```

## Detailed Reference

For more detailed information, refer to the following documents:

- [Commit Quality Gates](references/commit-quality-gates.md) - Lint/Test/Build execution rules
- [Commit Message Generation](references/commit-message-generation.md) - AI-driven generation logic
- [PR Creation Flow](references/pr-creation-flow.md) - Format -> Commit -> Push -> PR creation
- [PR Format Rules](references/pr-format-rules.md) - Templates, signature policy
- [Existing PR Detection](references/existing-pr-detection.md) - Detection, update, response policy
- [Commit Workflows](examples/commit-workflows.md) - Practical examples and best practices
- [PR Workflows](examples/pr-workflows.md) - New PR / update / draft, etc.
- [Troubleshooting](examples/troubleshooting.md) - Common issues and solutions

## Constraints and Notes

- Must be executed inside a Git repository
- GitHub CLI (`gh`) installation and authentication required (for PR features)
- Pre-installation of formatter recommended (for PR features)
- Direct push to protected branches may fail

## Integration with Integration Framework

Unified state management using TaskContext:

```python
from shared.task_context import TaskContext, save_context

context = TaskContext(
    task_description="Git automation execution",
    source="/git-automation"
)

# Record metrics
context.metrics["quality_gate_status"] = "passed"
context.metrics["commit_count"] = len(commits)
context.communication["shared_data"]["pr_url"] = pr_url

# Persist context
save_context(context)
```
