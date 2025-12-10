# Personal Dotfiles

**最終更新**: 2025-11-29  
**対象**: 開発者  
**タグ**: `category/setup`, `layer/core`, `environment/macos`, `audience/developer`

High-performance macOS development environment tuned for speed, consistency, and developer experience.

## Highlights

- Performance-first dotfiles with local CI parity (`mise run ci`) before merges
- Documentation centralized in `docs/` with navigation at `docs/README.md` and AI context in `.kiro/steering/`
- Modular stack: Zsh (6-tier), Neovim (Lazy.nvim), WezTerm (tmux-style) with FZF-backed Git widgets
- Versioning via Mise + Homebrew; AI/CLI helpers documented in `CLAUDE.md` and `.claude/`

## Documentation Map

- Navigation: `docs/README.md`
- Setup (SST): `docs/setup.md`
- Performance metrics/history: `docs/performance.md`
- Maintenance cadence & troubleshooting: `docs/maintenance.md`
- AI steering (always loaded): `.kiro/steering/`
- Tool inventory: `TOOLS.md`

## Getting Started

- Canonical steps live in `docs/setup.md` (gitconfig requirements, verification, environment notes)
- TL;DR: clone, add `~/.gitconfig_local`, then run the installer

```bash
git clone https://github.com/jey3dayo/dotfiles ~/src/github.com/jey3dayo/dotfiles
cd ~/src/github.com/jey3dayo/dotfiles
# ~/.gitconfig_local を作成した上で実行（手順詳細は docs/setup.md）
sh ./setup.sh && brew bundle
exec zsh
```

## Quality & CI

- Local gate: `mise run ci` (GitHub Actions equivalent)
- Formatting bundle: `mise run format` (Markdown/JS/TOML/YAML/Lua/Shell)
- Lint bundle: `mise run lint`
- Documentation rules: `.claude/rules/documentation-rules.md`

## Core Stack

- **Zsh + Sheldon**: 6-tier priority loading with mise-aware PATH optimization and 50+ Git abbreviations/widgets
- **Neovim + Lazy.nvim**: AI assistance (Supermaven) with LSP-heavy yet fast startup
- **WezTerm**: Primary terminal with Lua config and tmux-style workflow; Alacritty as GPU-accelerated alternative
- **Git + FZF**: Widgets and fuzzy pickers for repo/status/add flows
- **Versioning**: Mise for language runtimes; Homebrew for system packages

## Architecture

```
dotfiles/
├── .claude/       # AI assistance, commands, review criteria
├── .github/       # Workflows
├── .kiro/         # Steering docs (always-loaded AI context)
├── docs/          # Human-facing documentation (SST per topic)
├── zsh/           # Shell (6-tier loading)
├── nvim/          # Editor (Lua config, 15+ LSP)
├── git/           # Version control (widgets, abbreviations)
├── wezterm/       # Terminal (Lua config, tmux-style)
├── alacritty/     # Alternative terminal (GPU-accelerated)
├── tmux/          # Session management
├── Brewfile       # Package management (Homebrew)
└── setup.sh       # Installer entrypoint
```

## Shortcuts & Commands

```bash
# Shell help
zsh-help                   # Interactive help system
zsh-help keybinds          # Key bindings reference
zsh-help aliases           # Aliases reference

# Git workflow (FZF-backed widgets; see docs/tools/fzf-integration.md)
Ctrl+]                     # FZF repository selector
Ctrl+g Ctrl+g              # Git diff widget
Ctrl+g Ctrl+s              # Git status widget
Ctrl+g Ctrl+a              # Git add widget
Ctrl+g Ctrl+b / Ctrl+g s   # Git branch switcher (fzf-git powered)
Ctrl+g Ctrl+w              # Git worktree manager (fzf-git powered)
Ctrl+g Ctrl+z              # fzf-git stash picker
Ctrl+g Ctrl+f              # fzf-git file picker

# WezTerm (Ctrl+x leader key)
Ctrl+x c                   # New tab
Ctrl+x [                   # Vim-style copy mode
Alt+hjkl                   # Pane navigation

# Package management
brew bundle                # Install all packages
mise install               # Setup language versions
```

## Maintenance

- Operational cadence and troubleshooting live in `docs/maintenance.md`
- Weekly: `brew update && brew upgrade`, sync plugins (Sheldon/Neovim/tmux)
- Monthly: measure shell startup (`time zsh -lic exit`), prune unused plugins
- Always before merge: `mise run ci`

---

**Status**: Production-ready (2025-11-29)  
**License**: MIT — optimized for modern development workflows with focus on speed, consistency, and developer experience.
