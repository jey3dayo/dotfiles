# Claude AI Configuration Directory

This directory contains Claude-specific configuration, commands, and rule files for AI-assisted work in this repository.

## Purpose

- `commands/`: Claude Code custom commands and helper scripts
- `rules/`: compact AI-facing rules derived from canonical project docs
- `doc-standards/`: metadata and tag references for documentation maintenance
- `settings.json`: Claude Code local settings

## Documentation Model

- Canonical human-readable documentation lives in [`docs/`](../docs/)
- High-level AI context lives in [`.kiro/steering/`](../.kiro/steering/)
- `.claude/rules/` stays compact and points back to canonical docs instead of duplicating them

The documentation contract is defined in [`docs/documentation.md`](../docs/documentation.md).

## Key Entry Points

- [`../docs/README.md`](../docs/README.md) - documentation navigation
- [`rules/project-context.md`](rules/project-context.md) - concise project overview for Claude
- [`rules/claude-code-usage.md`](rules/claude-code-usage.md) - Claude-specific operating guidance
- [`../README.md`](../README.md) - repository overview

## Notes

- Keep detailed procedures, metrics, and long examples in `docs/`
- Update `.claude/rules/` only when the corresponding canonical document changes
- Prefer adding new project knowledge to existing docs before creating new rule files

Last Updated: 2026-03-23
