---
name: rules-creator
description: |
  [What] Guide for creating Claude Code rules. Provides guidance on when to use CLAUDE.md vs .claude/rules/ and step-by-step creation procedures.
  [When] Use when: you want to enforce project standards, guide AI behavior, or create/modify rules.
  [Keywords] rules, guidelines, project standards, policy, enforcement, claude.md
---

# Rules Creator

A guide for defining and enforcing project standards using the Claude Code rules system.

## Two-Layer Rule Structure

Claude Code rules consist of two mechanisms:

```
┌─────────────────────────────────────────┐
│ CLAUDE.md (Guidelines)                  │  ← Suggestions / Recommendations
│ - Development philosophy, best practices │
│ - AI understands and follows, but not   │
│   strictly enforced                     │
└─────────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────┐
│ .claude/rules/ (Rules)                  │  ← Enforced / Constraints
│ - Scope can be limited with paths       │
│ - AI automatically references and       │
│   adheres to these                      │
└─────────────────────────────────────────┘
```

| Type       | Enforcement Level | Location       | Purpose                                |
| ---------- | ----------------- | -------------- | -------------------------------------- |
| Guidelines | Suggestion        | CLAUDE.md      | Development philosophy, best practices |
| Rules      | Enforced          | .claude/rules/ | Constraints, standards, policies       |

## Load Order and Priority

Rules are loaded at 2 levels:

| Level         | Path                   | Scope                 | Priority                       |
| ------------- | ---------------------- | --------------------- | ------------------------------ |
| User-level    | `~/.claude/rules/*.md` | All projects (shared) | Low (loaded first)             |
| Project-level | `.claude/rules/*.md`   | Project-specific      | High (loaded later, overrides) |

- Subdirectories are recursively explored
- Symbolic links are supported

## When to Use Guidelines

- Sharing general principles
- Conveying philosophy or values
- Recommending best practices
- No enforcement needed

Examples: "Type safety should be prioritized", "Tests are important"

Location: `CLAUDE.md` (project root or `~/.claude/`)

## When to Use Rules

- Enforceable standards are required
- Clear constraints need to be defined
- Violations can be detected
- Want to scope to specific file patterns

Examples: "No use of any type", "All API endpoints require input validation"

Location: `.claude/rules/`

### Limit Scope with `paths` Frontmatter

```yaml
---
paths:
  - "src/api/**/*.{ts,tsx}"
  - "{src,lib}/**/*.ts"
---
# API Development Rules

- All API endpoints require input validation
- Use standard error response format
```

When `paths` is omitted, the rule applies to all files.

## Detailed Reference

- `references/rules-system.md` - Load order, glob patterns, structure, anti-patterns

## Resources

- `resources/templates/rule-template.md` - Rule template
- `resources/examples/type-safety-rule.md` - Type safety rule example
- `resources/examples/scoped-api-rule.md` - paths scope example
- `resources/checklist.md` - Quality checklist

## Related Skills

- cc-sdd: Project memory and pattern management via `.kiro/steering/`
- hookify plugin: Event-driven automatic actions (pre-commit hooks, etc.)
