# Personal Dotfiles

⚡ High-performance macOS development environment tuned for speed, consistency, and developer experience.

## Documentation

- `docs/README.md` — navigation for all human-facing docs
- `docs/documentation-guidelines.md` — tagging/metadata rules and review checklists
- `.kiro/steering/` — AI context documents always loaded in sessions
- `docs/performance.md` — single source for performance metrics and targets

## Getting Started

- Canonical setup steps live in `docs/setup.md` (gitconfig requirements, verification, and environment notes)
- TL;DR: clone, add `~/.gitconfig_local`, then run the installer

```bash
git clone https://github.com/jey3dayo/dotfiles ~/src/github.com/jey3dayo/dotfiles
cd ~/src/github.com/jey3dayo/dotfiles
# ~/.gitconfig_local を作成した上で実行（手順詳細は docs/setup.md）
sh ./setup.sh && brew bundle
exec zsh
```

## Performance & Reliability

- Metrics, targets, and history are tracked centrally in `docs/performance.md`
- Goal: sub-second shell/terminal startup and near-instant Neovim load even with AI/LSP enabled
- Use `mise run ci` locally to validate configuration drift before merges

## Core Stack

- **Zsh + Sheldon**: 6-tier priority loading with mise-aware PATH optimization
- **Neovim + Lazy.nvim**: AI assistance (Supermaven) with fast startup on M3
- **WezTerm**: Primary terminal with Lua config and tmux-style workflow; Alacritty as GPU-accelerated alternative
- **Git**: 50+ abbreviations and custom widgets backed by FZF integrations
- **Versioning**: Mise for language runtimes; Homebrew for system packages

## Architecture

```
dotfiles/
├── zsh/           # Shell (6-tier loading)
├── nvim/          # Editor (Lua config, 15+ LSP)
├── git/           # Version control (widgets, abbreviations)
├── wezterm/       # Terminal (Lua config, tmux-style)
├── alacritty/     # Alternative terminal (GPU-accelerated)
├── tmux/          # Session management
├── Brewfile       # Package management
└── .claude/       # AI assistance & documentation
```

## Shortcuts & Commands

```bash
# Shell help
zsh-help                   # Interactive help system
zsh-help keybinds          # Key bindings reference
zsh-help aliases           # Aliases reference

# Git workflow (FZF-backed widgets; see docs/tools/fzf-integration.md)
Ctrl+]                     # FZF repository selector
Ctrl+g Ctrl+g             # Git status widget
Ctrl+g Ctrl+s             # Git add widget

# WezTerm (Ctrl+x leader key)
Ctrl+x c                   # New tab
Ctrl+x [                   # Vim-style copy mode
Alt+hjkl                   # Pane navigation

# Package management
brew bundle                # Install all packages
mise install              # Setup language versions
```

## Maintenance

- Operational cadence and troubleshooting live in `docs/maintenance.md`
- Weekly: `brew update && brew upgrade`, sync plugins (sheldon/nvim/tmux)
- Monthly: measure shell startup (`time zsh -lic exit`), prune unused plugins
- Always before merge: `mise run ci`

---

**Status**: Production-ready (2025-10-16)  
**License**: MIT — optimized for modern development workflows with focus on speed, consistency, and developer experience.
