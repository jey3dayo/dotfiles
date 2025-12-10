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
- Maintenance and troubleshooting schedules: `docs/maintenance.md`
- Documentation governance: `.claude/rules/documentation-rules.md` (rules) with `docs/README.md` for navigation
- Tool details: `docs/tools/*.md` (Zsh, Neovim, WezTerm, SSH, FZF, Git)

## AI usage quick links
- Rules entrypoints: `.claude/rules/ai-tools-and-claude.md` and tool-specific rules under `.claude/rules/tools/`.
- Local CI: `./.claude/commands/ci-local.sh` or `mise run ci`.

## Performance snapshot (reference)
- Current: Zsh ~1.1s, Neovim <100ms, WezTerm ~800ms on M3 MacBook Pro.
- Targets: Zsh <100ms, Neovim <200ms, WezTerm <1s. Detailed history lives in `docs/performance.md`.
