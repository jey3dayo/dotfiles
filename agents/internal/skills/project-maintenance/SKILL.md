---
name: project-maintenance
description: Project cleanup and maintenance automation with Serena semantic analysis and safety checks. Use when cleaning up unused code or maintaining project health.
disable-model-invocation: true
user-invocable: true
allowed-tools: Read, Grep, Glob, Bash, mcp__serena__*
argument-hint: "[full|files] [options]"
---

# Project Maintenance - Project Maintenance Automation

A skill that automates project cleanup and maintenance. Achieves safe and efficient code organization using MCP Serena's semantic analysis and safety checks.

## Basic Usage

```bash
# Full cleanup (comprehensive analysis)
/project-maintenance full

# Targeted cleanup (file-level)
/project-maintenance files [pattern]

# Preview mode
/project-maintenance full --dry-run
/project-maintenance files --dry-run
```

## Cleanup Strategies

### 1. Full Cleanup (Serena Semantic Analysis)

Comprehensively cleans up the entire project:

- Unused symbol detection: Track references for functions, classes, variables
- Debug code removal: console.log, print, TODO, etc.
- Import statement cleanup: Automatic removal of unused imports
- Documentation consolidation: Eliminate duplication and ensure consistency

### Execution Phases

1. Safety check (create Git checkpoint)
2. Serena semantic analysis
3. Unused code detection
4. Staged cleanup execution
5. Verification and report generation

### 2. Targeted Cleanup (File-Level)

Cleans up specific files and patterns:

- Temporary files: `_.log`, `_.tmp`, `*~`
- System files: .DS_Store, Thumbs.db
- Cache files: \*.pyc, **pycache**
- Project-specific: custom pattern support

### Protection Features

- Automatic exclusion of `.claude/`, `.git/`, `node_modules/`
- Configuration file protection (.env, config/\*)
- Active process check

## Safety Checks

The following are performed for all operations:

1. Pre-validation
   - Confirm Git status
   - Warning for uncommitted changes
   - Automatic checkpoint creation

2. Reference verification
   - Serena dependency tracking
   - Ensure accuracy of unused code detection
   - Safety through staged deletion

3. Post-validation
   - Run tests (if available)
   - Lint/type check
   - Ensure rollback capability

## Quick Start

```bash
# 1. Full cleanup (recommended)
/project-maintenance full

# 2. Remove only temporary files
/project-maintenance files "**/*.{log,tmp}"

# 3. Preview before executing
/project-maintenance full --dry-run

# 4. If a problem occurs
git reset --hard HEAD~1  # return to checkpoint
```

## Key Features

### MCP Serena Integration

- Semantic analysis: Understands meaning, not just syntax
- Dependency tracking: Safe deletion decisions
- Efficient search: Optimized pattern matching
- Structural understanding: Grasp of entire project

### Project Detection

Integration with project-detector enables:

- Automatic project type detection
- Selection of appropriate cleanup rules
- Tech stack-specific optimization

### Execution Modes

```bash
# Default: comprehensive cleanup
/project-maintenance full

# Selective cleanup
/project-maintenance full --code-only
/project-maintenance full --docs-only
/project-maintenance full --files-only

# Safe mode
/project-maintenance full --dry-run
```

## Execution Report Example

```markdown
🧹 **Cleanup Report**
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 📋 Summary

- Files processed: 45
- Lines removed: 892
- Files deleted: 12
- Documentation consolidated: 3 → 1

## 🔍 Code Analysis (MCP Serena)

- Unused functions: 8 removed
- Unused imports: 23 cleaned
- Debug statements: 15 removed
- TODO items: 7 tracked

## 📁 File Cleanup

- Temporary files: 12 removed (3.2MB freed)
- Log files: 8 removed (15.7MB freed)
- Cache files: 34 removed (128MB freed)
```

## Detailed References

For detailed specifications and best practices for this skill, see:

- [Full Cleanup Strategy](references/full-cleanup-strategy.md) - Details of Serena semantic analysis
- [Targeted Cleanup Strategy](references/targeted-cleanup-strategy.md) - File-level cleanup
- [Safety Checks](references/safety-checks.md) - Pre-validation and reference verification
- [Cleanup Policies](references/cleanup-policies.md) - Deletion policy and backup

Practical examples and workflows:

- [Cleanup Workflows](examples/cleanup-workflows.md) - Execution examples and best practices
- [Safety Validation](examples/safety-validation.md) - Safety check execution examples
- [Rollback Strategies](examples/rollback-strategies.md) - How to handle problems

## Important Notes

- For large projects, staged execution is recommended
- For team development, prior consultation is recommended
- Verify important configuration files in advance
- Exclusion patterns can be defined in a `.cleanupignore` file

## Integration with Other Commands

- `/review`: Quality check after cleanup
- `/polish`: Run lint/format/test
- `/docs`: Final documentation quality check
