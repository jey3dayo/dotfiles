# Dotfiles Documentation

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

- **[Zsh](tools/zsh.md)** - Shell configuration, plugins, performance optimization
- **[Neovim](tools/nvim.md)** - LSP setup, plugin management, AI integration
- **[WezTerm](tools/wezterm.md)** - Terminal configuration, GPU acceleration, themes
- **[SSH](tools/ssh.md)** - SSH configuration, key management, security
- **[FZF Integration](tools/fzf-integration.md)** - Fuzzy search integration guide

---

_Optimized for speed, consistency, and developer experience._
