# Technology Stack - Personal Dotfiles

**Last Updated**: 2026-02-09
**Inclusion Mode**: Always Included

## Architecture

### Core Trinity (Primary Technologies)

The dotfiles are built around three core technologies that form the interactive foundation:

1. Zsh - Shell environment (1.1s startup)
2. WezTerm - Primary terminal emulator (800ms startup)
3. Neovim - Code editor (<100ms startup)

All other tools serve to enhance or support these core components, while deployment and environment parity are handled by Home Manager + Nix.

### Design Principles

- **Modular Configuration**: Each tool has isolated config directory
- **Performance First**: Lazy-loading and startup optimization
- **Type Safety**: Lua-based configs for WezTerm and Neovim
- **Version Control**: All configurations tracked in Git
- **Unified Theming**: Gruvbox/Tokyo Night consistency
- **Declarative Delivery**: Home Manager + Nix flake as the source of truth
- **Environment Awareness**: CI / Raspberry Pi / Default profiles selected automatically

## Core Technologies

### Shell Environment

#### Zsh

- **Configuration**: `zsh/` directory
- **Plugin Manager**: Sheldon (TOML-based, `zsh/sheldon/plugins.toml`)
- **Loading Strategy**: 6-tier priority system
  1. Base environment setup
  2. Critical path utilities
  3. Completions
  4. Interactive features
  5. Theme and prompt
  6. Optional enhancements
- **Key Plugins**:
  - `zsh-autosuggestions` - Command suggestions
  - `zsh-syntax-highlighting` - Syntax highlighting
  - `fzf` - Fuzzy finder integration
  - `mise` - Version management (39ms optimized)
- **Performance**: 1.1s startup (43% improvement)

### Terminal Emulators

#### WezTerm (Primary)

- **Configuration**: `wezterm/wezterm.lua` entrypoint with modular `*.lua` files
- **Language**: Lua-based configuration
- **Features**:
  - Tmux-style workflow (Ctrl+x leader key)
  - GPU acceleration
  - Ligature support
  - Tab/pane management
- **Startup**: 800ms (35% improvement)
- **Key Bindings**: Ctrl+x prefix (tmux-style)

#### Ghostty (Alternative)

- **Configuration**: `ghostty/config`
- **Use Case**: Lightweight alternative terminal for specific workflows

#### Alacritty (Alternative)

- **Configuration**: `alacritty/alacritty.toml`
- **Format**: TOML configuration
- **Features**:
  - GPU-accelerated rendering
  - Minimal overhead
  - Vi mode support
- **Use Case**: Lightweight alternative for specific workflows

### Code Editor

#### Neovim

- **Configuration**: `nvim/` (Lua-based)
- **Plugin Manager**: Lazy.nvim
- **LSP Support**: 15+ languages
  - TypeScript/JavaScript (tsserver)
  - Python (pyright)
  - Go (gopls)
  - Rust (rust-analyzer)
  - Lua (lua-language-server)
- **AI Assistance**: Supermaven integration
- **Startup**: <100ms (50% improvement)
- **Key Modules**:
  - `lua/core/` - bootstrap and defaults
  - `lua/config/` - plugin settings and editor config
  - `lua/plugins/` - plugin specs (Lazy.nvim)
  - `lua/lsp/` - LSP wiring and settings

- **Key Plugins**:
  - `telescope.nvim` - Fuzzy finder
  - `nvim-treesitter` - Syntax parsing
  - `mason.nvim` - LSP installer
  - `lazy.nvim` - Plugin manager

## Supporting Technologies

### Configuration & Delivery

#### Nix + Home Manager

- **Source of Truth**: `flake.nix`, `home.nix`, and `nix/` modules
- **Deployment**: `home-manager switch --flake ~/.config --impure`
- **Environment Detection**: CI / Raspberry Pi / Default profiles with per-env config

### Version Management

#### Mise (formerly rtx)

- **Configuration**:
  - `.mise.toml` for repo-wide tasks
  - `mise/config.toml` for shared settings
  - `mise/config.{default,ci,pi}.toml` for environment-specific tool definitions
- **Supported Languages**:
  - Node.js
  - Python
  - Go
  - Rust
- **Integration**: Zsh plugin (39ms startup)
- **Commands**: `mise install`, `mise use`

### Package Management

#### Homebrew

- **Configuration**: `Brewfile`
- **Categories**:
  - Core utilities (grep, ripgrep, fd)
  - Development tools (git, gh, docker)
  - Terminal tools (tmux, fzf, bat)
  - Language runtimes (managed via mise)
- **Update Strategy**: Weekly `brew update && brew upgrade`

### Session Management

#### Tmux

- **Configuration**: `tmux/tmux.conf`
- **Use Case**: Secondary to WezTerm's built-in panes
- **Key Features**:
  - Session persistence
  - Window management
  - Copy mode

### Search & Navigation

#### FZF (Fuzzy Finder)

- **Integration Points**:
  - Zsh command history (Ctrl+R)
  - Repository navigation (Ctrl+])
  - Git workflows (various Ctrl+g bindings)
  - File search
- **Documentation**: [FZF Integration Guide](../docs/tools/fzf-integration.md)

#### Ripgrep (rg)

- **Use Case**: Fast code search
- **Integration**: FZF backend, Neovim search

### Git Tools

#### GitHub CLI (gh)

- **Configuration**: `~/.config/gh/config.yml`
- **Features**:
  - Repository automation
  - PR/issue management
  - Authentication

#### Git Abbreviations

- **Location**: `git/config` → `~/.config/git/config` (deployed via Home Manager)
- **Count**: 50+ custom abbreviations
- **Widgets**: Custom Zsh widgets for Git operations

### Keyboard Customization

#### Karabiner Elements

- **Configuration**: `karabiner/karabiner.json`
- **Purpose**: macOS keyboard remapping
- **Use Case**: Ergonomic key modifications

### Productivity

#### Raycast

- **Extensions**: Optional scripts under `raycast/extensions/` (if present)
- **Integrations**:
  - Spotify control
  - AWS console shortcuts
  - Color utilities
  - Arc browser integration

## Development Environment

### Required Tools

```bash
# Core requirements
brew install zsh neovim wezterm

# Development tools
brew install git gh mise

# Search & navigation
brew install fzf ripgrep fd

# Shell enhancements
brew install starship sheldon

# Optional tools
brew install tmux alacritty
```

### Environment Setup

```bash
# 1. Clone repository
git clone https://github.com/jey3dayo/dotfiles ~/.config

# 2. Configure Git (REQUIRED)
cat > ~/.gitconfig_local << EOF
[user]
    name = Your Name
    email = your.email@example.com
EOF

# 3. Install packages and apply configuration
cd ~/.config
sh ./scripts/bootstrap.sh   # macOS only
brew bundle                 # macOS only
nix run home-manager -- switch --flake . --impure

# 4. Restart shell
exec zsh
```

## Common Commands

### Shell Management

```bash
zsh-help                   # Interactive help system
zsh-help keybinds          # Keyboard shortcuts reference
zsh-help aliases           # Aliases reference
zsh-benchmark              # Measure startup time
```

### Git Workflow

```bash
# Custom widgets (keyboard shortcuts)
Ctrl+]                     # FZF repository selector
Ctrl+g Ctrl+g             # Git status widget
Ctrl+g Ctrl+s             # Git add widget
Ctrl+g Ctrl+a             # Git add all widget
Ctrl+g Ctrl+b             # Git branch widget
```

### WezTerm (Ctrl+x leader)

```bash
Ctrl+x c                   # New tab
Ctrl+x [                   # Vim-style copy mode
Alt+hjkl                   # Pane navigation
Ctrl+x %                   # Vertical split
Ctrl+x "                   # Horizontal split
```

### Package Management

```bash
brew bundle                # Install all packages
brew update && brew upgrade # Update packages
mise install              # Setup language versions
mise use node@20          # Set Node version
```

### CI/Quality Checks

```bash
mise run ci                # Run all CI checks
mise run format:biome:check     # Biome formatting
mise run format:markdown:check  # Markdown formatting
mise run format:yaml:check      # YAML formatting
mise run lint:lua          # Lua linting
mise run format:shell:check     # Shell script formatting
```

## Environment Variables

### Critical Variables

```bash
# Homebrew (Apple Silicon)
PATH="/opt/homebrew/bin:$PATH"

# XDG Base Directory
XDG_CONFIG_HOME="$HOME/.config"
XDG_DATA_HOME="$HOME/.local/share"
XDG_CACHE_HOME="$HOME/.cache"

# Editor preferences
EDITOR="nvim"
VISUAL="nvim"

# Mise configuration
MISE_DATA_DIR="$XDG_DATA_HOME/mise"
```

### Optional Variables

```bash
# Performance tuning
SHELDON_CONFIG_DIR="$XDG_CONFIG_HOME/sheldon"

# Git configuration
GIT_CONFIG_GLOBAL="$HOME/.gitconfig"
GIT_CONFIG_LOCAL="$HOME/.gitconfig_local"
```

## Port Configuration

This is a dotfiles project - no server ports are used. All tools run as local applications.

## Configuration File Formats

- **Lua**: Neovim (`nvim/`), WezTerm (`wezterm/wezterm.lua` + `*.lua`)
- **TOML**: Mise (`.mise.toml`, `mise/config*.toml`), Alacritty (`alacritty/alacritty.toml`)
- **Nix**: `flake.nix`, `home.nix`, `nix/`
- **Shell**: Zsh (`zsh/`), Bash scripts
- **JSON**: Karabiner (`karabiner/karabiner.json`), VS Code
- **YAML**: GitHub Actions (`.github/workflows/`)
- **Markdown**: Documentation (`docs/`)

## AI & Automation Tools

### Claude Code Integration

- **Global Commands**: `/task`, `/review`, `/todos`, `/learnings`
- **Project Commands**: `/refactoring`, `/update-readme`
- **Review Criteria**: Defined in AI configuration (project rules)
- **CI Integration**: Local checks via `mise run ci`

### MCP Servers

- **Serena**: Semantic code analysis
- **O3**: Technical consultation
- **Context7**: Library documentation lookup
