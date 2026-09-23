---
paths: .claude/**/*, CLAUDE.md, codex/**/*, cursor/**/*
---

# Claude Code Usage

Purpose: guide Claude Code usage, command system, and context sources. Scope: steering docs, project quick links, and CI commands available through Claude.
Sources: AGENTS.md, CLAUDE.md, .claude/README.md.

## Context hierarchy

- Project documentation lives in `docs/`; rules are mirrored in `.claude/rules/` for Claude ingestion.
- Tool-specific details are in `docs/tools/*.md`; do not restate long snippets in replies.
- Recording new insights: append to the relevant `docs/tools/*.md`, then sync the compact rule in `.claude/rules/` only if needed.

## Local CI via Claude

- Primary entrypoint: `mise run ci` to mirror GitHub Actions.
- Individual tasks: `mise run format:biome:check`, `mise run format:markdown:check`, `mise run format:yaml:check`, `mise run lint:lua`, `mise run format:lua:check`, `mise run format:shell:check`.

## Response posture for Claude Code

- Prefer concise answers in Japanese with clear pointers to SST docs instead of repeating full guides.
- Preserve DRY: link to `docs/tools/zsh.md` / `docs/tools/nvim.md` for startup metrics, `docs/tools/workflows.md` for schedules, and `docs/documentation.md` for governance.
- For code review, use the built-in `/code-review` command.
- When asking for a numeric choice such as `1/2/3`, restate each numbered option in the same message before asking for the number-only reply.
