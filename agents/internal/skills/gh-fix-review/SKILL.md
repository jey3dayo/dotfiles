---
name: gh-fix-review
description: |
  [What] Automated skill for GitHub PR review comment processing. Automatically classifies review comments (from CodeRabbit, human reviewers, bots) by priority (Critical/High/Major/Minor) and applies fixes in priority order. Integrates with TodoWrite for progress tracking and creates tracking documents
  [When] Use when: users mention "/review --fix-pr", "PR review automation", "CodeRabbit fixes", or need automated PR feedback processing. **Always responds in Japanese**
  [Keywords] /review --fix-pr, PR review automation, CodeRabbit fixes
---

# gh-fix-review Skill

A skill for automatically classifying and fixing GitHub Pull Request review comments.

## Skill Purpose

Automatically processes PR review comments (CodeRabbit, human reviewers, other bots):

- Priority classification: Automatically classifies into Critical/High/Major/Minor
- Automatic fixes: Applies fixes in priority order
- Progress management: Visualizes progress with TodoWrite integration
- Tracking: Records response status
- Customizable: Supports project-specific review rules

## Key Features

### 1. Configuration File Support

You can customize review rules by placing a `.pr-review-config.json` file in the project root or home directory.

```json
{
  "version": "1.0",
  "priorities": {
    "critical": {
      "keywords": ["critical", "bug", "security", "vulnerability"],
      "emoji": "🔴"
    },
    "high": {
      "keywords": ["important", "major", "should fix", "必須"],
      "emoji": "🟠"
    }
  },
  "categories": {
    "security": ["security", "vulnerability", "auth"],
    "performance": ["performance", "slow", "optimization"]
  },
  "tracking": {
    "output_path": "docs/_review-fixes.md"
  }
}
```

### 2. Fetching Review Comments

Fetch PR comments using the GitHub CLI:

```python
from commands.shared.git_operations import get_current_pr_number
import subprocess
import json

# Get PR number (auto-detected or explicitly specified)
pr_number = get_current_pr_number()

# Fetch PR review comments
def get_pr_review_comments(pr_number):
    """Get all review comments for a PR."""
    result = subprocess.run(
        ["gh", "pr", "view", str(pr_number), "--json", "title,body,comments,reviews"],
        capture_output=True,
        text=True
    )

    if result.returncode != 0:
        return None, result.stderr

    pr_data = json.loads(result.stdout)

    # Merge comments and reviews
    all_comments = []

    # Comments
    for comment in pr_data.get("comments", []):
        all_comments.append({
            "author": comment["author"]["login"],
            "body": comment["body"],
            "path": comment.get("path", ""),
            "line": comment.get("line", 0),
            "type": "comment"
        })

    # Reviews
    for review in pr_data.get("reviews", []):
        all_comments.append({
            "author": review["author"]["login"],
            "body": review["body"],
            "path": "",
            "line": 0,
            "type": "review"
        })

    return all_comments, pr_data.get("title", "")
```

### 3. Priority Classification (with Configuration File Support)

Automatically classify using configuration file or default rules:

```python
import json
import os

def load_config():
    """Load PR review configuration."""

    # Project root configuration file takes priority
    config_paths = [
        ".pr-review-config.json",
        os.path.expanduser("~/.pr-review-config.json")
    ]

    for config_path in config_paths:
        if os.path.exists(config_path):
            with open(config_path) as f:
                return json.load(f)

    # Default configuration
    return get_default_config()


def get_default_config():
    """Get default configuration."""
    return {
        "version": "1.0",
        "priorities": {
            "critical": {
                "keywords": [
                    "critical", "bug", "security", "vulnerability",
                    "broken", "error", "failure", "crash"
                ],
                "emoji": "🔴"
            },
            "high": {
                "keywords": [
                    "important", "major", "should fix", "必須",
                    "required", "blocking", "urgent"
                ],
                "emoji": "🟠"
            },
            "major": {
                "keywords": [
                    "consider", "recommend", "推奨", "improvement",
                    "optimize", "refactor"
                ],
                "emoji": "🟡"
            },
            "minor": {
                "keywords": [
                    "nit", "style", "formatting", "typo",
                    "suggestion", "optional"
                ],
                "emoji": "🟢"
            }
        },
        "categories": {
            "security": ["security", "vulnerability", "auth", "permission", "xss", "sql injection"],
            "performance": ["performance", "slow", "optimization", "cache", "memory"],
            "bug": ["bug", "error", "broken", "fail", "incorrect"],
            "style": ["style", "format", "naming", "convention", "prettier", "eslint"],
            "refactor": ["refactor", "clean", "simplify", "duplication", "dry"],
            "test": ["test", "coverage", "mock", "assertion"],
            "docs": ["documentation", "comment", "readme", "説明"]
        },
        "tracking": {
            "output_path": "docs/_review-fixes.md",
            "include_in_git": False
        },
        "filters": {
            "ignore_bots": [],
            "only_bots": []
        }
    }


def classify_comment_priority(comment_body, config):
    """Classify comment priority based on configuration."""

    body_lower = comment_body.lower()

    for priority, settings in config["priorities"].items():
        if any(keyword in body_lower for keyword in settings["keywords"]):
            return priority

    return "minor"  # default


def classify_comment_category(comment_body, config):
    """Classify comment category based on configuration."""

    body_lower = comment_body.lower()

    for category, keywords in config["categories"].items():
        if any(keyword in body_lower for keyword in keywords):
            return category

    return "other"


def classify_pr_comments(comments, config):
    """Classify all PR comments."""

    classified = {
        "critical": [],
        "high": [],
        "major": [],
        "minor": []
    }

    for comment in comments:
        priority = classify_comment_priority(comment["body"], config)
        category = classify_comment_category(comment["body"], config)

        comment["priority"] = priority
        comment["category"] = category

        classified[priority].append(comment)

    return classified
```

### 4. Tracking Document Generation

Record response status:

```python
import datetime

def generate_tracking_document(pr_number, pr_title, classified_comments, config):
    """Generate tracking document for PR review fixes."""

    now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    # Count by priority
    counts = {
        priority: len(comments)
        for priority, comments in classified_comments.items()
    }

    total = sum(counts.values())

    content = f"""# PR #{pr_number} Review Fix Tracking

**Last Updated**: {now}
**PR**: #{pr_number} - {pr_title}
**Total Comments**: {total}

## Summary by Priority

| Priority | Count | Done | Remaining |
|----------|-------|------|-----------|
"""

    for priority in ["critical", "high", "major", "minor"]:
        emoji = config["priorities"][priority]["emoji"]
        content += f"| {emoji} {priority.capitalize()} | {counts[priority]} | 0 | {counts[priority]} |\n"

    content += "\n## Details\n\n"

    # Add each priority section
    for priority in ["critical", "high", "major", "minor"]:
        if classified_comments[priority]:
            emoji = config["priorities"][priority]["emoji"]
            content += f"\n### {emoji} {priority.upper()}\n\n"

            for i, comment in enumerate(classified_comments[priority], 1):
                file_info = f"{comment['path']}:{comment['line']}" if comment['path'] else "General"

                content += f"""#### [{i}] {comment['category']} - {comment['author']}

- **File**: `{file_info}`
- **Status**: Not addressed
- **Details**:
```

<!-- markdownlint-disable MD052 -->

{comment['body'][:200]}...

<!-- markdownlint-enable MD052 -->

```

"""

    return content
```

### 5. Automatic Fix Execution

Apply fixes in priority order:

```python
from commands.shared.quality_gates import QualityGates

def apply_pr_review_fixes(classified_comments, config, dry_run=False):
    """Apply fixes for PR review comments."""

    from commands.shared.todo_integration import TodoManager

    # Create Todo list
    todo_manager = TodoManager()

    # Add in order: Critical -> High -> Major -> Minor
    for priority in ["critical", "high", "major", "minor"]:
        emoji = config["priorities"][priority]["emoji"]
        for comment in classified_comments[priority]:
            todo_manager.add_todo(
                f"{emoji} Fix {comment['category']}: {comment['body'][:50]}..."
            )

    # Set first Todo to in_progress
    if todo_manager.todos:
        todo_manager.mark_in_progress(0)

    # Display with TodoWrite tool
    # ...

    if dry_run:
        print("Dry run mode: fixes will not be applied")
        return

    # Quality gates
    gates = QualityGates()

    # Apply fixes in priority order
    for priority in ["critical", "high", "major", "minor"]:
        for comment in classified_comments[priority]:
            emoji = config["priorities"][priority]["emoji"]
            print(f"\n{emoji} Fixing: {comment['category']} - {comment['body'][:50]}...")

            # Apply fix (agent invocation)
            fix_success = apply_single_fix(comment)

            if fix_success:
                # Quality check
                results = gates.run_all(type_check=True, lint=True, test=False)

                if all(r.success for r in results.values()):
                    print("  Fix completed")
                    todo_manager.mark_current_completed()
                    todo_manager.start_next()

                    # Update tracking document
                    update_tracking_status(comment, "completed")
                else:
                    print("  Quality check failed, rolling back")
                    rollback_fix(comment)
                    todo_manager.mark_current_completed()
                    todo_manager.start_next()
                    update_tracking_status(comment, "failed")


def apply_single_fix(comment):
    """Apply a single fix using appropriate agent."""

    from commands.shared.agent_selector import select_optimal_agent

    # Select agent
    agent_info = select_optimal_agent(
        f"Fix {comment['category']} issue: {comment['body']}",
        context={
            "file_path": comment['path'],
            "line_number": comment['line']
        }
    )

    # Execute agent
    # Use Task tool
    # ...

    return True  # success
```

## Usage

### Basic Execution

```bash
# Auto-detect PR for current branch
/review --fix-pr

# Explicitly specify PR number
/review --fix-pr 123

# Only specific priority
/review --fix-pr --priority critical

# Dry run
/review --fix-pr --dry-run
```

### Filtering Options

```bash
# Only comments from specific bot
/review --fix-pr --bot coderabbitai

# Only specific category
/review --fix-pr --category security,bug

# Combination of multiple conditions
/review --fix-pr --priority critical,high --category security
```

## Configuration File

### Location

Configuration files are loaded in the following priority order:

1. Project root: `.pr-review-config.json`
2. Home directory: `~/.pr-review-config.json`
3. Default configuration (when no configuration file exists)

### Configuration Examples

Refer to the `examples/` directory for detailed configuration examples.

- `examples/default-config.json` - Default configuration
- `examples/caad-config.json` - Configuration for CAAD project
- `examples/minimal-config.json` - Minimal configuration

## Output Example

```markdown
Starting GitHub PR review fixes

PR Information
PR Number: #123
Title: Full automation of VPN certificate management
Review Comments: 45

Priority Classification
Critical: 4
High: 8
Major: 15
Minor: 18

Creating tracking document
docs/\_review-fixes.md has been generated

Todo list created (45 items)

Starting to fix Critical issues...

[1/4] terraform/scripts/1_check-certificate-expiry.sh:142
Issue: Bug in ACM certificate information parsing
Fix: Corrected --query array order
Fix completed

...
```

## Integration Features

### GitHub CLI Integration

```bash
# Fetch PR information
gh pr view 123 --json title,body,comments,reviews

# Auto-detect PR number
gh pr view --json number --jq '.number'
```

### Quality Assurance Integration

```python
from commands.shared.quality_gates import QualityGates

gates = QualityGates()
results = gates.run_all(
    type_check=True,
    lint=True,
    test=False  # Tests are typically skipped for PR review fixes
)
```

### Agent Integration

```python
from commands.shared.agent_selector import select_optimal_agent

# Select optimal agent according to fix type
agent_info = select_optimal_agent(
    task_description=f"Fix {category} issue in {file_path}",
    context={
        "project_type": project_info.project_type,
        "category": category
    }
)
```

## Important Notes

### GitHub CLI Requirements

```bash
# gh CLI installation and authentication required
gh --version
gh auth status
```

### Tracking File

- The tracking file path can be customized in the configuration file
- Default is `docs/_review-fixes.md`
- Recommended to exclude from commits via `.gitignore`
- Can be deleted after fixes are complete

### Limitations of Automatic Fixes

- Simple fixes can be automated
- Complex logic changes require manual review
- Automatic rollback when quality check fails

## Trigger Conditions

Use this skill in the following cases:

1. When the `/review --fix-pr` command is executed
2. For automatic processing of GitHub PR review comments
3. For bulk fixing of bot comments such as CodeRabbit
4. For responding to review feedback by priority

## Output Format

All output is provided in **Japanese**:

- PR information summary
- Priority-based comment classification
- Fix progress report
- Completion summary

---

### Use this skill to efficiently process PR review feedback and improve code quality

## Detailed Reference

- `references/configuration.md` - Configuration file details
- `references/customization.md` - Customization guide
- `references/integration.md` - Integration with other tools
- `examples/` - Configuration file examples
