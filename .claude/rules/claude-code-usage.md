---
paths: .claude/**/*, CLAUDE.md, codex/**/*, cursor/**/*
---

# Claude Code Usage

Purpose: guide Claude Code usage, command system, and context sources. Scope: steering docs, project quick links, and CI commands available through Claude.
Sources: AGENTS.md, CLAUDE.md, .claude/README.md.

## Context hierarchy

- Documentation entry points and precedence are defined in `docs/documentation.md`; do not restate them here.

## Local CI via Claude

- Primary entrypoint: `mise run ci` to mirror GitHub Actions.
- Individual tasks: see `docs/tools/mise-tasks.md`.

## Response posture for Claude Code

- Prefer concise answers in Japanese with clear pointers to SST docs instead of repeating full guides.
- Preserve DRY: link to `docs/tools/zsh.md` / `docs/tools/nvim.md` for startup metrics, `docs/tools/workflows.md` for schedules, and `docs/documentation.md` for governance.
- For code review, use the built-in `/code-review` command.
- When asking for a numeric choice such as `1/2/3`, restate each numbered option in the same message before asking for the number-only reply.
