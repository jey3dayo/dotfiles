---
paths: .claude/**/*, CLAUDE.md, codex/**/*, cursor/**/*
---

# Claude Code Usage

Purpose: guide Claude Code usage, command system, and context sources. Scope: steering docs, project quick links, and CI commands available through Claude.
Sources: AGENTS.md, CLAUDE.md, .claude/README.md.

## Context hierarchy

- Always treat `.kiro/steering/` (product, tech, structure) as high-level context; it is auto-loaded.
- Project documentation lives in `docs/`; rules are mirrored in `.claude/rules/` for Claude ingestion.
- Tool-specific details are in `docs/tools/*.md`; do not restate long snippets in replies.

## AI command system

- Global commands: `/task`, `/todos`, `/review`, `/learnings`, `allow-command`.
- Project commands: `/refactoring`, `/update-readme` tailored to dotfiles.
- Recording new insights: prefer `/learnings` with the correct layer (Shell/Editor/Terminal/Git) rather than editing large docs inline.

## Local CI via Claude

- Primary entrypoints: `./.claude/commands/ci-local.sh` or `mise run ci` to mirror GitHub Actions.
- Individual tasks: `mise run format:biome:check`, `format:markdown:check`, `format:yaml:check`, `lint:lua`, `format:lua:check`, `format:shell:check`.

## Response posture for Claude Code

- Prefer concise answers in Japanese with clear pointers to SST docs instead of repeating full guides.
- Preserve DRY: link to `docs/performance.md` for metrics, `docs/tools/workflows.md` for schedules, and `docs/documentation.md` for governance.
- Keep changes consistent with `.claude/review-criteria.md` when performing reviews.
- When asking for a numeric choice such as `1/2/3`, restate each numbered option in the same message before asking for the number-only reply.
