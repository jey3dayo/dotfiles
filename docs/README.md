# 📖 Dotfiles Documentation

**最終更新**: 2025-10-03
**対象**: 開発者・初心者
**タグ**: `category/guide`, `layer/core`, `environment/macos`

⚡ High-performance macOS development environment configuration.

## Quick Start

- **[Setup Guide](setup.md)** - Complete installation instructions
- **[Tools](tools.md)** - Essential commands and configurations
- **[Performance](performance.md)** - Benchmarks and optimizations
- **[Maintenance](maintenance.md)** - Regular maintenance and troubleshooting

## Current Status

**Configuration**: Production ready  
**Last Updated**: 2025-09-08

## Architecture

```text
dotfiles/
├── zsh/               # Shell configuration (modular, optimized)
├── nvim/              # Neovim configuration (Lua-based)
├── wezterm/           # Primary terminal configuration
├── git/               # Version control configuration
├── tmux/              # Terminal multiplexer
├── mise.toml          # Version management
└── Brewfile           # Package management
```

## Core Stack

**Primary**: Zsh + WezTerm + Neovim  
**Support**: Tmux, Homebrew, Mise, FZF, GitHub CLI

## Tool-Specific Documentation

### Core Stack (Primary Tools)

- **[Zsh](tools/zsh.md)** - Shell configuration, 1.1s startup, modular plugin system
- **[Neovim](tools/nvim.md)** - Editor config, <100ms startup, 15+ languages, AI integration
- **[WezTerm](tools/wezterm.md)** - Primary terminal, GPU acceleration, Lua configuration

### Supporting Tools

- **[SSH](tools/ssh.md)** - SSH configuration, hierarchical setup, security management
- **[FZF Integration](tools/fzf-integration.md)** - Unified fuzzy search across all tools

### Component Configurations

- **Git**: Enhanced workflows with 50+ abbreviations and custom widgets
- **Tmux**: Session management and terminal multiplexing
- **Homebrew**: Package management via Brewfile
- **Mise**: Multi-language version management
- **Terraform**: Infrastructure as Code with LSP support

---

_Optimized for speed, consistency, and developer experience._
