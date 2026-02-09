# Product Overview - Personal Dotfiles

**Last Updated**: 2026-02-09
**Inclusion Mode**: Always Included

## Product Overview

High-performance cross-platform (macOS/Linux/WSL2) development environment configuration optimized for speed, consistency, and developer experience. This dotfiles repository provides a complete, battle-tested setup for modern software development with focus on shell productivity, editor efficiency, terminal workflow optimization, and declarative deployment via Home Manager.

## Core Features

- **🚀 Performance-Optimized Setup**

  - Zsh startup: 1.1s (43% faster than baseline)
  - Neovim startup: <100ms (50% faster)
  - WezTerm startup: 800ms (35% faster)
  - Detailed metrics tracked in [Performance Statistics](../docs/performance.md)

- **🐚 Advanced Shell Configuration**

  - Modular plugin system with 6-tier priority loading
  - 50+ Git abbreviations and custom widgets
  - Interactive help system (`zsh-help`)
  - FZF integration for enhanced workflows

- **🔧 Modern Editor Experience**

  - Neovim with 15+ language LSP support
  - AI assistance integration (Supermaven)
  - Lazy-loading plugin architecture
  - Sub-100ms startup time

- **🖥️ Terminal Excellence**

  - WezTerm primary terminal with tmux-style workflow
  - Alacritty as GPU-accelerated alternative
  - Unified keyboard shortcuts and navigation
  - Vim-style copy mode support

- **🎨 Unified Design System**

  - Gruvbox/Tokyo Night theme consistency across all tools
  - JetBrains Mono with Nerd Font ligatures
  - GPU acceleration where available
  - Consistent color schemes and typography

- **🛠️ Development Tools Integration**
  - Mise for multi-language version management
  - Homebrew for package management
  - GitHub CLI for repository automation
  - 1Password for SSH key management

- **Declarative & Reproducible Delivery**
  - Nix Home Manager provides consistent, repeatable configuration across machines
  - Environment detection (CI/Pi/Default) keeps platform-specific differences minimal

## Target Use Case

### Primary Users

Software developers on macOS/Linux/WSL2 (and CI/Raspberry Pi environments) who value:

- **Performance**: Fast startup times and responsive tools
- **Consistency**: Unified configuration across terminal, editor, and shell
- **Productivity**: Keyboard-driven workflows with minimal mouse usage
- **Modularity**: Ability to understand and customize individual components

### Specific Scenarios

1. **Daily Development Workflow**

   - Quick terminal access with minimal startup delay
   - Seamless Git operations through custom widgets
   - Efficient code editing with LSP support
   - Multi-project navigation with FZF integration

2. **New Machine Setup**

   - Bootstrap via `scripts/bootstrap.sh` (macOS) and package installation via Homebrew/Nix
   - Apply configuration with `home-manager switch --flake ~/.config --impure`
   - Consistent environment across multiple machines
   - Version-controlled configurations
   - Easy backup and restore

3. **Performance-Conscious Development**

   - Monitored startup times via `zsh-benchmark`
   - Lazy-loading strategies for plugins
   - Optimized plugin selection (39ms mise integration)
   - Regular performance audits

4. **Cross-Tool Integration**
   - WezTerm ↔ Neovim workflow integration
   - Git ↔ FZF search capabilities
   - Terminal ↔ Editor theme synchronization
   - Unified keyboard shortcuts across tools

## Key Value Proposition

### Performance First

- **Measurable Speed**: Documented performance improvements with before/after metrics
- **Optimized Loading**: 6-tier priority system ensures critical components load first
- **Lazy Loading**: Plugins and tools load only when needed

### Developer Experience

- **Keyboard-Driven**: Minimal mouse usage with comprehensive keyboard shortcuts
- **Intelligent Help**: Built-in `zsh-help` system for discovering features
- **AI-Assisted**: Integrated Claude Code commands for maintenance and updates

### Consistency & Quality

- **Unified Theming**: Same visual experience across all tools
- **Type-Safe Configs**: Lua-based configurations for Neovim and WezTerm
- **CI/CD Validation**: Local CI checks ensure quality before commit
- **Documentation**: Comprehensive docs with clear guidelines

### Maintainability

- **Modular Architecture**: Each tool has isolated configuration
- **Version Control**: All configurations tracked in Git
- **Update Strategy**: Clear weekly/monthly/quarterly maintenance tasks
- **Rollback Capability**: Git history enables easy configuration recovery

### Production Ready

- **Battle-Tested**: Used in daily production development
- **Well-Documented**: Extensive documentation in `docs/` directory
- **Community Patterns**: Follows best practices from tool communities
- **Active Maintenance**: Regular updates and performance monitoring

## Differentiators from Other Dotfiles

1. **Performance Metrics**: Actual measured startup times with improvement tracking
2. **Layer-Based Documentation**: Organized by Core/Tool/Support layers
3. **AI Integration**: Claude Code commands for automated maintenance
4. **Spec-Driven Development**: Kiro framework integration for structured changes
5. **Declarative Configuration**: Home Manager + Nix flake for reproducible environments
6. **Quality Gates**: Local CI checks matching GitHub Actions
