---
name: code-review
description: |
  [What] Configurable code review and quality assessment skill with project detection system.
  [When] Use when: code reviews, quality assessments, or evaluation guidance is needed.
  [Keywords] code review, quality assessment, review, security, performance, architecture, guidelines
  [Note] Always responds in Japanese.
version: 3.0.0
argument-hint: "[--simple] [--staged|--recent|--branch <name>] [--with-impact] [--fix]"
user-invocable: true
---

# Code Review — Local Code Quality Assessment

Comprehensive code review framework with dual-mode operation. Automatically detect project type and integrate technology stack-specific skills to deliver contextual, actionable feedback.

## Important Notes

- This skill performs **local reviews** and optionally addresses open PR review comments
- All review results are output in **Japanese**

### No-Signature Policy (CRITICAL)

- NEVER add `Co-authored-by: Claude` to commits
- NEVER use emojis in commits, PRs, issues, or git content
- NEVER add "Generated with Claude Code" signatures
- NEVER include AI attribution in any output

## Review Modes

### 1. Detailed Mode (Default)

Comprehensive quality assessment with structured evaluation:

- ⭐️ 5-level evaluation system across multiple dimensions
- Project type auto-detection (Go API, React SPA, Next.js fullstack, etc.)
- Technology stack-specific skill integration (typescript, react, golang, security, etc.)
- Detailed improvement proposals with action plans
- Impact analysis with Serena integration (optional)

When to use: Comprehensive quality gates, pre-release assessment, architecture evaluation, learning/mentoring, establishing quality baselines.

```bash
/review                    # Detailed review (default)
/review --with-impact      # With semantic impact analysis
/review --deep-analysis    # Deep symbol-level analysis
```

### 2. Simple Mode

Quick practical analysis focused on immediate issues:

- Sub-agent composition (security, performance, quality, architecture agents)
- Fast issue detection and classification
- Immediate actionable fixes
- Problem prioritization by severity

When to use: Daily development workflow, quick sanity checks, rapid problem identification, CI/CD integration.

```bash
/review --simple           # Quick review
/review --simple --fix     # With auto-fix
```

### Mode Selection

- `--simple` flag → Simple Mode
- `--with-impact`, `--deep-analysis`, `--verify-spec` → Detailed Mode with Serena
- Default (no flags) → Detailed Mode

## Options

### Mode

- `--simple`: Use simple mode (default is detailed mode)

### Target

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
- `--no-comments`: Skip PR review comment check

## Configuration System

### Configuration Sources (Priority Order)

1. **Project-specific config** (highest priority)
   - `.code-review-config.json` in project root
   - `.claude/code-review-config.json`

2. User config
   - `~/.claude/code-review/custom-projects.json`

3. **Default config** (fallback)
   - Built-in project detection rules

### Project-Specific Guidelines

Place review guidelines in one of:

- `./.claude/review-guidelines.md`
- `./docs/review-guidelines.md`
- `./docs/guides/review-guidelines.md`

These are automatically integrated into evaluation criteria.

## Built-in Project Types

| Project Type          | Priority | Key Detectors                | Tech Stack              |
| --------------------- | -------- | ---------------------------- | ----------------------- |
| Next.js Fullstack     | 100      | next dep, package.json       | typescript, react, next |
| Go Clean Architecture | 95       | go.mod, domain/usecase/infra | go, clean-architecture  |
| Go API                | 90       | go.mod, \*\_handler.go       | go                      |
| React SPA             | 80       | react dep, package.json      | typescript, react       |
| TypeScript Node.js    | 70       | package.json, tsconfig.json  | typescript, node        |
| Generic Project       | 0        | (fallback)                   | (none)                  |

## Technology Stack Integration

Automatically invoke relevant technology-specific skills based on project detection:

- typescript: Type safety, strict mode, type guards, Result pattern
- react: Component design, hooks usage, performance optimization
- golang: Idiomatic Go, error handling, concurrency patterns
- security: Input validation, authentication, authorization, encryption
- clean-architecture: Layer separation, dependency rules, domain modeling
- semantic-analysis: Symbol-level analysis, impact assessment, reference tracking

## Star Rating System

| Rating     | Description  | Criteria                                     |
| ---------- | ------------ | -------------------------------------------- |
| ⭐️⭐️⭐️⭐️⭐️ | Exceptional  | All dimensions excellent, custom rules met   |
| ⭐️⭐️⭐️⭐️   | Excellent    | Most dimensions strong, minor improvements   |
| ⭐️⭐️⭐️     | Good         | Acceptable quality, some improvements needed |
| ⭐️⭐️       | Needs Work   | Multiple issues, significant improvements    |
| ⭐️         | Major Issues | Critical problems, substantial rework        |

## Quality Standards

All reviews must:

- Respond in Japanese
- Provide specific file:line references
- Include concrete code examples
- Offer actionable remediation steps
- Prioritize by severity and impact
- Respect no-signature policy
- Create checkpoints before analysis

## References

Progressive disclosure — loaded as needed:

- [Detailed Mode](references/detailed-mode.md) — 5-level evaluation execution guide
- [Simple Mode](references/simple-mode.md) — Parallel sub-agent execution guide
- [Evaluation Framework](references/evaluation-framework.md) — Star rating system definition
- [Project Customization](references/project-customization.md) — Guidelines integration
- [Tech Stack Skills](references/tech-stack-skills.md) — Project detection and tech-specific criteria
- [PR Comment Integration](references/pr-comment-integration.md) — Post-review PR comment handling

## Examples

- [Review Workflows](examples/review-workflows.md) — 5 practical workflows
- [Troubleshooting](examples/troubleshooting-solutions.md) — Common issues and solutions

## Related

- `code-review-system` — PR workflow (CI diagnosis, comment handling, auto-fix)
- `gh-fix-ci` — GitHub Actions CI failure diagnosis
- `gh-address-comments` — PR review comment handling
- `codex-code-review` — Codex-delegated code review

---

### Goal
