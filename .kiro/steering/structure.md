# Project Structure - Personal Dotfiles

**Last Updated**: 2025-10-21
**Inclusion Mode**: Always Included

## Root Directory Organization

```
dotfiles/
├── .claude/              # AI assistance configuration and commands
├── .github/              # GitHub Actions workflows (CI/CD)
├── .kiro/                # Spec-driven development (Kiro framework)
├── .serena/              # Coding agent memories and context
├── alacritty/            # Alacritty terminal configuration
├── docs/                 # Comprehensive documentation
├── git/                  # Git configuration and aliases
├── karabiner/            # Keyboard customization (macOS)
├── nvim/                 # Neovim editor configuration (Lua)
├── raycast/              # Raycast productivity extensions
├── ssh/                  # SSH configuration (hierarchical)
├── tmux/                 # Tmux session management
├── wezterm/              # WezTerm terminal configuration (Lua)
├── zsh/                  # Zsh shell configuration
├── Brewfile              # Homebrew package manifest
├── mise.toml             # Mise version management
├── setup.sh              # Automated setup script
├── README.md             # Main documentation
└── TOOLS.md              # Managed tools inventory
```

## Core Directories (Primary Technologies)

### `zsh/` - Shell Configuration

**Purpose**: Modular Zsh configuration with 6-tier loading system

```
zsh/
├── .zshrc                # Main Zsh configuration (symlinked to ~/.zshrc)
├── .zshenv               # Environment variables (symlinked to ~/.zshenv)
├── configs/              # Modular configuration files
│   ├── 00-env.zsh       # Tier 1: Environment setup
│   ├── 10-path.zsh      # Tier 1: PATH configuration
│   ├── 20-aliases.zsh   # Tier 2: Command aliases
│   ├── 30-functions.zsh # Tier 3: Custom functions
│   ├── 40-keybinds.zsh  # Tier 4: Keyboard shortcuts
│   ├── 50-prompt.zsh    # Tier 5: Prompt configuration
│   └── 60-completion.zsh# Tier 6: Completion system
├── plugins/              # Plugin-specific configurations
└── README.md             # Zsh-specific documentation
```

**Loading Order**: Files loaded numerically (00 → 60) for optimized startup

### `nvim/` - Neovim Configuration

**Purpose**: Lua-based Neovim configuration with LSP support

```
nvim/
├── init.lua              # Entry point
├── lua/
│   ├── config/           # Core configuration
│   │   ├── options.lua  # Editor options
│   │   ├── keymaps.lua  # Key mappings
│   │   └── autocmds.lua # Auto commands
│   ├── plugins/          # Plugin specifications (Lazy.nvim)
│   │   ├── lsp.lua      # LSP configuration
│   │   ├── treesitter.lua # Syntax parsing
│   │   ├── telescope.lua # Fuzzy finder
│   │   └── ...          # Other plugins
│   └── utils/            # Utility functions
├── snippets/             # Custom code snippets
└── README.md             # Neovim-specific documentation
```

**Plugin Manager**: Lazy.nvim (lazy-loading architecture)

### `wezterm/` - Terminal Configuration

**Purpose**: Lua-based WezTerm terminal configuration

```
wezterm/
├── wezterm.lua           # Main configuration
├── config/               # Modular configuration
│   ├── appearance.lua   # Theme and colors
│   ├── keys.lua         # Keyboard shortcuts
│   ├── tabs.lua         # Tab management
│   └── panes.lua        # Pane management
└── README.md             # WezTerm-specific documentation
```

**Configuration Language**: Lua (type-safe configuration)

## Tool Directories (Supporting Technologies)

### `git/` - Version Control

```
git/
├── config                # Git configuration (symlinked to ~/.gitconfig)
├── ignore                # Global gitignore
├── attributes            # Git attributes
└── templates/            # Commit/hook templates
```

**Key Feature**: 50+ custom abbreviations and Zsh widgets

### `tmux/` - Session Management

```
tmux/
├── tmux.conf             # Main configuration (symlinked to ~/.tmux.conf)
└── plugins/              # Tmux plugins
```

**Role**: Secondary to WezTerm's built-in pane management

### `alacritty/` - Alternative Terminal

```
alacritty/
└── alacritty.toml        # TOML configuration
```

**Purpose**: GPU-accelerated lightweight alternative to WezTerm

### `ssh/` - SSH Configuration

```
ssh/
├── config                # Main SSH config (hierarchical includes)
├── config.d/             # Modular host configurations
│   ├── personal         # Personal servers
│   ├── work             # Work environments
│   └── github           # GitHub-specific
└── README.md             # SSH setup documentation
```

**Architecture**: Hierarchical includes for security and organization

### `karabiner/` - Keyboard Customization

```
karabiner/
└── karabiner.json        # Karabiner Elements configuration
```

**Purpose**: macOS keyboard remapping for ergonomic workflows

### `raycast/` - Productivity Tools

```
raycast/
└── extensions/           # Custom Raycast extensions
    ├── [uuid]/          # Extension-specific directories
    │   └── *.js         # Extension scripts
    └── ...
```

**Integration**: Spotify, AWS, Arc browser, color utilities

## Documentation Structure

### `docs/` - Comprehensive Documentation

```
docs/
├── README.md                    # Documentation index
├── documentation-guidelines.md  # Documentation standards
├── performance.md               # Performance metrics
├── setup.md                     # Setup guide
├── maintenance.md               # Maintenance procedures
└── tools/                       # Tool-specific guides
    ├── zsh.md                   # Shell layer
    ├── nvim.md                  # Editor layer
    ├── wezterm.md               # Terminal layer
    ├── ssh.md                   # SSH configuration
    └── fzf-integration.md       # FZF workflows
```

**Organization**: Layer-based documentation (Core/Tool/Support)

### `.claude/` - AI Assistance

```
.claude/
├── README.md             # Claude Code integration guide
├── review-criteria.md    # Code review standards
└── commands/             # Custom slash commands
    ├── refactoring.md   # Refactoring workflows
    └── update-readme.md # Documentation automation
```

**Purpose**: AI-assisted development and maintenance

### `.kiro/` - Spec-Driven Development

```
.kiro/
└── steering/             # Project steering documents
    ├── product.md       # Product overview
    ├── tech.md          # Technology stack
    └── structure.md     # Project structure (this file)
```

**Purpose**: Kiro framework for structured development

## Code Organization Patterns

### Modular Configuration

- **Principle**: Each tool has isolated configuration directory
- **Benefits**: Easy to understand, update, and version control
- **Symlinks**: Setup script creates symlinks from repo to home directory

### Tiered Loading (Zsh)

```
Priority Tier | Files         | Purpose
--------------|---------------|----------------------------------
1             | 00-*.zsh      | Critical environment setup
2             | 10-*.zsh      | PATH and core utilities
3             | 20-*.zsh      | Aliases and shortcuts
4             | 30-*.zsh      | Custom functions
5             | 40-*.zsh      | Interactive features
6             | 50-*.zsh      | Theme and prompt
```

### Lazy Loading (Neovim)

- **Mechanism**: Lazy.nvim plugin manager
- **Strategy**: Load plugins on events, commands, or file types
- **Result**: <100ms startup time despite 30+ plugins

### Lua-Based Configuration

- **Tools**: Neovim, WezTerm
- **Benefits**: Type safety, better tooling, performance
- **Structure**: Modular `lua/` directories with clear separation

## File Naming Conventions

### Configuration Files

- **Dotfiles**: Leading dot (e.g., `.zshrc`, `.tmux.conf`)
- **Tool configs**: Tool name + format (e.g., `wezterm.lua`, `mise.toml`)
- **Numbered prefixes**: For load order (e.g., `00-env.zsh`, `10-path.zsh`)

### Documentation

- **Lowercase with hyphens**: `documentation-guidelines.md`, `fzf-integration.md`
- **README per directory**: Each major directory has `README.md`
- **Tool-specific**: Under `docs/tools/` (e.g., `docs/tools/zsh.md`)

### Scripts

- **Shell scripts**: `.sh` extension (e.g., `setup.sh`)
- **CI scripts**: Descriptive names (e.g., `ci-local.sh`)
- **Executables**: No extension, executable bit set

## Import Organization

### Zsh Configuration

```zsh
# Load order (managed by .zshrc):
# 1. Environment (.zshenv)
# 2. Sheldon plugins
# 3. Config files (00-*.zsh → 60-*.zsh)
# 4. Local overrides (~/.zshrc.local)
```

### Neovim Lua Modules

```lua
-- Standard import pattern:
local config = require('config.options')
local utils = require('utils.helpers')

-- Plugin specifications in plugins/ directory
-- Auto-loaded by Lazy.nvim
```

### WezTerm Configuration

```lua
-- Main wezterm.lua imports modular configs:
local appearance = require('config.appearance')
local keys = require('config.keys')

-- Returns combined configuration table
return config
```

## Key Architectural Principles

### 1. Performance First

- **Measurement**: Regular benchmarking (`zsh-benchmark`, Neovim startup profiling)
- **Optimization**: Lazy loading, deferred initialization, minimal dependencies
- **Targets**: Zsh <1.2s, Neovim <100ms, WezTerm <1s

### 2. Modularity

- **Separation**: Each tool in isolated directory
- **Independence**: Tools can be updated without affecting others
- **Reusability**: Configurations can be extracted for other projects

### 3. Type Safety

- **Lua Preference**: For tools that support it (Neovim, WezTerm)
- **Benefits**: Better IDE support, fewer runtime errors
- **Validation**: CI checks for syntax and formatting

### 4. Documentation-Driven

- **Metadata**: All docs include update date and target audience
- **Guidelines**: [Documentation Guidelines](../docs/documentation-guidelines.md)
- **Consistency**: Unified tag system (category/tool/layer/environment)

### 5. Version Control Everything

- **Tracking**: All configurations in Git
- **Excludes**: Secrets in `.gitconfig_local`, `.env` files
- **History**: Changes tracked for rollback capability

### 6. AI-Assisted Maintenance

- **Claude Code**: Integrated commands for updates and reviews
- **MCP Tools**: Serena (code analysis), O3 (technical consultation)
- **Automation**: `/refactoring`, `/update-readme` commands

### 7. Quality Gates

- **Local CI**: `mise run ci` matches GitHub Actions
- **Formatting**: Biome (JS), Prettier (Markdown), shfmt (Shell)
- **Linting**: Lua linting, YAML validation
- **Pre-commit**: Optional hooks for quality assurance

### 8. Unified Theming

- **Color Scheme**: Gruvbox/Tokyo Night across all tools
- **Typography**: JetBrains Mono with Nerd Fonts
- **Consistency**: Same visual experience in terminal, editor, documentation
