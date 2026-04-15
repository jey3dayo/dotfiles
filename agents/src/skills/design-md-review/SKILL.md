---
name: design-md-review
description: Review and tune existing `DESIGN.md` files for Stitch readiness. Use when Codex needs to inspect a current DESIGN.md, check whether its structure and language are reusable for Stitch or agent-driven UI generation, identify missing sections, or propose concrete adjustments to atmosphere, colors, typography, components, and layout guidance.
---

# Design MD Review

## Overview

Use this skill to review an existing `DESIGN.md` and turn vague design notes into a reliable input for Stitch-style generation. Focus on checklist-based diagnosis first, then suggest the smallest concrete edits needed to make the file more reusable.

Read [references/design-md-criteria.md](references/design-md-criteria.md) when you need the detailed criteria, failure patterns, or optional sections beyond the core Stitch baseline.

## Review Scope

Apply this skill only to an existing `DESIGN.md`.

- If the file does not exist, stop and say this skill is for review and adjustment, not greenfield authoring.
- If the user wants a fresh file from screenshots, HTML, or a live site, use a separate creation workflow instead.
- If the user wants public-distribution polish, still start with the core Stitch checklist before discussing optional expansion sections.

## Review Workflow

1. Read the target `DESIGN.md` fully before judging any one section.
2. Check the document against the core review categories:
   - Structure
   - Visual theme and atmosphere
   - Color palette and roles
   - Typography rules
   - Component stylings
   - Layout principles
   - Stitch reusability
3. Mark each category as `OK`, `要修正`, or `不足`.
4. Prefer concrete, local feedback over abstract critique.
5. Prioritize the top 3 fixes that will most improve reuse in prompts.
6. Draft replacement or add-on text only for categories that failed or are weak.

## Core Expectations

Treat these as the baseline for a usable review.

- Keep design language natural and visual, not implementation-token heavy.
- Tie colors to both exact `hex` values and functional roles.
- Explain why a design choice exists when that explanation helps future prompt reuse.
- Describe components by appearance and behavior, not by raw class names alone.
- Capture spacing, density, and alignment principles clearly enough that another model can extrapolate a new screen.

## Output Format

Use this response structure unless the user asks for a different format.

```markdown
総合判定: OK | 調整推奨 | 大幅修正推奨

- 構造: OK | 要修正 | 不足
  理由: ...
- 雰囲気記述: OK | 要修正 | 不足
  理由: ...
- 色: OK | 要修正 | 不足
  理由: ...
- タイポグラフィ: OK | 要修正 | 不足
  理由: ...
- コンポーネント: OK | 要修正 | 不足
  理由: ...
- レイアウト: OK | 要修正 | 不足
  理由: ...
- Stitch再利用性: OK | 要修正 | 不足
  理由: ...

優先修正:

1. ...
2. ...
3. ...
```

## Adjustment Rules

- Keep feedback anchored to the current file. Do not rewrite the whole document unless the user asks.
- When proposing edits, preserve the document's existing voice unless that voice is the problem.
- Replace vague phrases such as "modern," "clean," or "nice spacing" with observable descriptions.
- If a section is missing exact values that matter to reuse, ask for them only when they cannot be inferred from the current file.
- If the document is already strong, say so explicitly and limit changes to high-signal refinements.

## Common Failure Patterns

- Core sections exist, but the content is too generic to guide generation.
- Colors are named, but not mapped to roles or `hex` values.
- Typography mentions a font family, but not hierarchy or weight usage.
- Component sections describe only one state and omit hover, focus, or surface treatment.
- Layout says "spacious" or "minimal" without any spacing or alignment principles.
- The file reads like Tailwind notes or CSS inventory instead of a semantic design system.

## Optional Follow-Up

If the user asks for help applying the review, draft only the failing sections or provide patch-ready text for them. Keep those edits consistent with the original document unless a stronger rewrite is necessary.
