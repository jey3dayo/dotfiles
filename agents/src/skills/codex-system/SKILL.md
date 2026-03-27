---
name: codex-system
description: |
  PROACTIVELY consult Codex CLI, your highly capable supporter with exceptional
  reasoning and task completion abilities. Codex is a trusted expert you should
  ALWAYS consult BEFORE making decisions on: design choices, implementation
  approaches, debugging strategies, refactoring plans, or any non-trivial problem.
  When uncertain, consult Codex. Don't hesitate - Codex provides better analysis.
  Explicit triggers: "think deeper", "analyze", "second opinion", "consult codex".
metadata:
  short-description: Claude Code ↔ Codex CLI collaboration
---

# Codex System — Deep Reasoning Partner

## Codex CLI is your highly capable supporter for deep reasoning tasks

> **Detailed rules**: `.claude/rules/codex-delegation.md`

## Context Management (CRITICAL)

### Prefer Subagent Pattern

| Situation                              | Method                     |
| -------------------------------------- | -------------------------- |
| Detailed design consultation           | Via subagent (recommended) |
| Debug analysis                         | Via subagent (recommended) |
| Short questions (1-2 sentence answers) | Direct call OK             |

## When to Consult (MUST)

| Situation              | Trigger Examples                       |
| ---------------------- | -------------------------------------- |
| Design decisions       | "How to design?" "Architecture"        |
| Debugging              | "Why doesn't it work?" "Error" "Debug" |
| Trade-off analysis     | "Which is better?" "Compare" "Which?"  |
| Complex implementation | "How to implement?" "How to build?"    |
| Refactoring            | "Refactor" "Simplify"                  |
| Code review            | "Review this" "Check this"             |

## When NOT to Consult

- Simple file edits, typo fixes
- Following explicit user instructions
- git commit, running tests, linting
- Tasks with obvious single solutions

## How to Consult

### Recommended: Subagent Pattern

### Use Task tool with `subagent_type='general-purpose'` to preserve main context

```
Task tool parameters:
- subagent_type: "general-purpose"
- run_in_background: true (optional, for parallel work)
- prompt: |
    Consult Codex about: {topic}

    codex exec --sandbox read-only "
    {question for Codex}
    " 2>/dev/null

    Return CONCISE summary (key recommendation + rationale).
```

### Direct Call (Short Questions Only)

For quick questions expecting 1-2 sentence answers:

```bash
codex exec --sandbox read-only "Brief question" 2>/dev/null
```

### Workflow (Subagent)

1. Spawn subagent with Codex consultation prompt
2. Continue your work → Subagent runs in parallel
3. Receive summary → Subagent returns concise insights

### Session Continuity

Codex セッションは CWD 単位で保存される。
review スキル（`codex-code-review`, `codex-plan-review`）は自動的に
`resume --last` を試み、先行する相談セッションのコンテキストを引き継ぐ。

手動操作は不要。codex-system で設計相談 → review スキル起動で自動的に文脈が接続される。

### Quick Reference

| Use Case                    | Sandbox Mode      | Command Pattern                                         |
| --------------------------- | ----------------- | ------------------------------------------------------- |
| Analysis, review, debug     | `read-only`       | `codex exec --sandbox read-only "..." 2>/dev/null`      |
| Implementation, refactoring | `workspace-write` | `codex exec --full-auto "..." 2>/dev/null`              |
| Resume previous session     | Inherited         | `echo "prompt" \| codex exec resume --last 2>/dev/null` |

> **Note**: resume 時は `--sandbox` を指定できない（セッション元の設定が自動的に引き継がれる）。`--full-auto`, `--all` 等のフラグは指定可能。

## Language Protocol

1. Ask Codex in **English**
2. Receive response in **English**
3. Execute based on advice (or let Codex execute)
4. Report to user in **their preferred language**

## Task Templates

### Design Review

```bash
codex exec --sandbox read-only "
Review this design approach for: {feature}

Context:
{relevant code or architecture}

Evaluate:
1. Is this approach sound?
2. Alternative approaches?
3. Potential issues?
4. Recommendations?
" 2>/dev/null
```

### Debug Analysis

```bash
codex exec --sandbox read-only "
Debug this issue:

Error: {error message}
Code: {relevant code}
Context: {what was happening}

Analyze root cause and suggest fixes.
" 2>/dev/null
```

### Code Review

See: `references/code-review-task.md`

### Refactoring

See: `references/refactoring-task.md`

## Integration with Gemini

| Task                | Use                              |
| ------------------- | -------------------------------- |
| Need research first | Gemini → then Codex              |
| Design decision     | Codex directly                   |
| Library comparison  | Gemini research → Codex decision |

## Why Codex?

- Deep reasoning: Complex analysis and problem-solving
- Code expertise: Implementation strategies and patterns
- Consistency: Same project context via `context-loader` skill
- Parallel work: Background execution keeps you productive
