---
paths: .kiro/steering/**/*.md, README.md, docs/README.md, docs/setup.md, docs/performance.md
---

# Project Context

Purpose: concise project overview for Claude. Scope: what this repo is, where to read high-level intent, and which SST docs to load.

## Mission and stack

- Goal: manage personal dotfiles for a fast, modular dev environment.
- Core stack: Zsh + WezTerm + Neovim; supporting tools include Tmux, Homebrew, Mise, Raycast, Karabiner.

## Steering documents (always load)

- Location: `.kiro/steering/`
- Files: `product.md` (overview), `tech.md` (stack and commands), `structure.md` (directory and naming).

## Single sources of truth

- Setup: `docs/setup.md`
- Performance metrics/history: `docs/performance.md`
- Maintenance schedules, workflows, and troubleshooting: `docs/tools/workflows.md`
- Brewfile management: `docs/tools/workflows.md`
- Tool installation policy: `docs/tools/mise.md` and `docs/tools/workflows.md`
- Documentation governance: `docs/documentation.md`
- Tool details: `docs/tools/*.md` (Zsh, Neovim, WezTerm, SSH, FZF, Git)

## AI usage quick links

- Rules entrypoints: `.claude/rules/claude-code-usage.md` and tool-specific rules under `.claude/rules/tools/`.
- Local CI: `./.claude/commands/ci-local.sh` or `mise run ci`.

## Performance reference

- Do not duplicate current metrics here
- Read `docs/performance.md` for baselines, targets, and history
