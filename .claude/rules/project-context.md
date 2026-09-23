---
paths: README.md, docs/README.md, docs/setup.md
---

# Project Context

Purpose: concise project overview for Claude. Scope: what this repo is, where to read high-level intent, and which SST docs to load.

## Mission and stack

- Goal: manage personal dotfiles for a fast, modular dev environment.
- Core stack: Zsh + WezTerm + Neovim; supporting tools include Tmux, Homebrew, Mise, Raycast, Karabiner.

## Single sources of truth

- Setup: `docs/setup.md`
- Startup benchmarks: `docs/tools/zsh.md`, `docs/tools/nvim.md` (検証 section of each)
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
- Read `docs/tools/zsh.md` and `docs/tools/nvim.md` (検証 section) for baselines and targets
