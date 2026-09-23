# Personal Dotfiles

最終更新: 2026-09-23
対象: 開発者
タグ: `category/setup`, `layer/core`, `environment/cross-platform`, `audience/developer`

High-performance development environment tuned for speed, consistency, and developer experience. Managed with mise bootstrap for declarative configuration.

## Highlights

- Declarative Configuration: mise bootstrap-based deployment with per-OS config selection (CI/Pi/Default)
- Performance-first dotfiles with local CI parity (`mise run ci`) before merges
- Documentation centralized in `docs/` with navigation at `docs/README.md`
- LLM/AI entrypoint available at `llms.md`, with project rules rooted in `AGENTS.md`
- Modular stack: Zsh (category-ordered `lib/*.zsh` with precmd-deferred plugins), Neovim (Lazy.nvim), WezTerm (tmux-style) with FZF-backed Git widgets
- Versioning via Mise + Homebrew; AI/CLI helpers documented in `CLAUDE.md` and `.claude/`

## Documentation Map

- Navigation: `docs/README.md`
- LLM/AI entrypoint: `llms.md`
- Setup (SST): `docs/setup.md`
- Startup benchmarks: `docs/tools/zsh.md`, `docs/tools/nvim.md`
- Key bindings: `docs/tools/fzf-integration.md`, `docs/tools/wezterm.md`
- Maintenance cadence, quality gates & CI: `docs/tools/workflows.md`
- Documentation governance: `docs/documentation.md`
- Tool inventory: `docs/README.md`

## Core Stack

- Zsh + Sheldon: category-ordered `zsh/lib/*.zsh` loading with mise-aware PATH optimization and precmd-deferred Git abbreviations/widgets
- Neovim + Lazy.nvim: LSP-heavy yet fast startup
- WezTerm: Primary terminal with Lua config and tmux-style workflow; Alacritty as GPU-accelerated alternative
- Git + FZF: Widgets and fuzzy pickers for repo/status/add flows
- Versioning: mise + Homebrew（層の割当は `docs/setup.md` の Package Management Philosophy）

## Architecture

```
dotfiles/
├── mise/          # mise config（[tools] / [dotfiles] / [bootstrap.*] / tasks）
├── .claude/       # AI rules and doc standards (.claude/skills/ is an APM deploy target)
├── skills/        # Repo-local Agent Skills (canonical; deployed to .claude/skills/ and .agents/skills/)
├── .github/       # Workflows
├── docs/          # Human-facing documentation (SST per topic)
├── bin/           # User-facing commands on PATH
├── scripts/       # Setup and task helper scripts
│   └── bootstrap.sh  # Homebrew installer (1-shot)
├── zsh/           # Shell (category-ordered lib/*.zsh loading)
├── nvim/          # Editor (Lua config, 15+ LSP)
├── git/           # Version control (widgets, abbreviations)
├── wezterm/       # Terminal (Lua config, tmux-style)
├── alacritty/     # Alternative terminal (GPU-accelerated)
├── tmux/          # Session management
└── Brewfile       # Package management (Homebrew)
```

## License

MIT
