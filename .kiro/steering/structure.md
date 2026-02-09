# Project Structure - Personal Dotfiles

**Last Updated**: 2026-02-09
**Inclusion Mode**: Always Included

## Root Directory Organization

```
dotfiles/
├── .github/              # GitHub Actions workflows (CI/CD)
├── .kiro/steering/       # Project steering (Kiro)
├── alacritty/            # Alacritty terminal configuration
├── ghostty/              # Ghostty terminal configuration
├── wezterm/              # WezTerm terminal configuration (Lua)
├── nvim/                 # Neovim editor configuration (Lua)
├── zsh/                  # Zsh shell configuration
├── git/                  # Git configuration and aliases
├── ssh/                  # SSH configuration (hierarchical)
├── karabiner/            # Keyboard customization (macOS)
├── tmux/                 # Tmux session management
├── docs/                 # Comprehensive documentation
├── nix/                  # Home Manager modules
├── scripts/              # Bootstrap and helper scripts
├── home/                 # Entry-point dotfiles for deployment
├── mise/                 # Mise config and task definitions
├── Brewfile              # Homebrew package manifest
├── .mise.toml            # Mise tasks entrypoint
├── flake.nix             # Nix flake entrypoint
├── home.nix              # Home Manager configuration
├── README.md             # Main documentation
└── TOOLS.md              # Managed tools inventory
```

## Core Directories (Primary Technologies)

### `zsh/` - Shell Configuration

**Purpose**: Modular Zsh configuration with layered loaders and plugin bootstrap

```
zsh/
├── .zshrc/.zshenv/.zprofile/.zlogin  # Entry points (symlinked by Home Manager)
├── config/                           # Layered configs (core/tools/os)
│   ├── core/
│   ├── tools/
│   ├── os/
│   ├── loaders/
│   └── loader.zsh
├── init/                             # Bootstrap and plugin manager hooks
├── sheldon/                          # Plugin manifest (plugins.toml)
├── functions/                        # Custom functions
├── completions/                      # Completion definitions
└── README.md                         # Zsh-specific documentation
```

**Loading Order**: `config/loader.zsh` orchestrates core → tools → functions → OS

### `nvim/` - Neovim Configuration

**Purpose**: Lua-based Neovim configuration with LSP support

```
nvim/
├── init.lua              # Entry point
├── lua/
│   ├── core/             # Bootstrap and defaults
│   ├── config/           # Plugin settings and editor config
│   ├── plugins/          # Plugin specifications (Lazy.nvim)
│   └── lsp/              # LSP wiring and settings
├── snippets/             # Custom code snippets
├── spec/                 # Lua specs and helpers
└── README.md             # Neovim-specific documentation
```

**Plugin Manager**: Lazy.nvim (lazy-loading architecture)

### `wezterm/` - Terminal Configuration

**Purpose**: Lua-based WezTerm terminal configuration

```
wezterm/
├── wezterm.lua           # Entrypoint (loads config.lua)
├── config.lua            # Core config builder
├── keybinds.lua          # Keyboard shortcuts
├── ui.lua                # Theme and UI settings
├── events.lua            # Event handlers
├── os.lua                # OS-specific adjustments
├── utils.lua             # Helpers
└── README.md             # WezTerm-specific documentation
```

**Configuration Language**: Lua (type-safe configuration)

## Tool Directories (Supporting Technologies)

### `git/` - Version Control

```
git/
├── config                # メイン Git 設定（Home Manager で ~/.gitconfig にリンク）
├── alias.gitconfig       # エイリアス/ショートカット（config から include）
├── diff.gitconfig        # delta/diff 設定
├── ghq.gitconfig         # ghq ルート設定
├── 1password.gitconfig   # 署名用設定（必要に応じて include）
├── attributes            # グローバル gitattributes
└── local.gitconfig       # ローカル上書きサンプル（自動では読み込まない）
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

### `ghostty/` - Alternative Terminal

```
ghostty/
└── config               # Ghostty configuration
```

**Purpose**: Lightweight alternative terminal configuration

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

### `nix/` + Flake Files - Home Manager Configuration

```
nix/
├── dotfiles-module.nix   # Home Manager module
├── env-detect.nix        # CI/Pi/Default environment detection
└── ...                   # Additional HM helpers
flake.nix                 # Flake entrypoint
home.nix                  # Home Manager configuration
```

**Purpose**: Declarative deployment and environment selection

### `home/` - Entry-Point Dotfiles

```
home/
├── .zshrc
├── .zshenv
├── .tmux.conf
└── .gitconfig
```

**Purpose**: Files deployed to `$HOME` by Home Manager

### `mise/` - Tool & Task Configuration

```
mise/
├── config.toml           # Shared settings
├── config.default.toml   # Default tool definitions
├── config.ci.toml        # CI-specific tool definitions
├── config.pi.toml        # Raspberry Pi tool definitions
└── tasks/                # Task bundles referenced by .mise.toml
```

**Purpose**: Environment-specific tool definitions and task bundles

### `scripts/` - Bootstrap & Helpers

```
scripts/
├── bootstrap.sh          # Homebrew bootstrap (macOS)
├── setup-env.sh          # Environment setup helpers
└── openclaw-cleanup      # Optional cleanup utility
```

**Purpose**: Setup and maintenance helpers

## Documentation Structure

### `docs/` - Comprehensive Documentation

```
docs/
├── README.md                    # Documentation index
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
- **Deployment**: Home Manager deploys entry-point dotfiles (from `home/`)

### Layered Loading (Zsh)

```
Stage         | Location         | Purpose
--------------|------------------|----------------------------------
Core          | config/core/     | Base environment and PATH setup
Tools         | config/tools/    | Tool integrations (git, fzf, mise)
Functions     | functions/       | Custom functions and utilities
OS            | config/os/       | Platform-specific tweaks
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
- **Tool configs**: Tool name + format (e.g., `wezterm.lua`, `mise/config.toml`)
- **Loader-based ordering**: Zsh load order is controlled by `config/loader.zsh`

### Documentation

- **Lowercase with hyphens**: e.g., `fzf-integration.md`
- **README per directory**: Each major directory has `README.md`
- **Tool-specific**: Under `docs/tools/` (e.g., `docs/tools/zsh.md`)

### Scripts

- **Shell scripts**: `.sh` extension (e.g., `scripts/bootstrap.sh`)
- **CI scripts**: Descriptive names (e.g., `ci-local.sh`)
- **Executables**: No extension, executable bit set

## Import Organization

### Zsh Configuration

```zsh
# Load order (managed by .zshrc):
# 1. Environment (.zshenv/.zprofile)
# 2. Sheldon plugins
# 3. config/loader.zsh (core → tools → functions → OS)
# 4. Local overrides (~/.zshrc.local)
```

### Neovim Lua Modules

```lua
-- Standard import pattern:
require("core.bootstrap").setup()

-- Plugin specs live under lua/plugins/ and are auto-loaded by Lazy.nvim
```

### WezTerm Configuration

```lua
-- wezterm.lua delegates to config.lua
return require "./config"

-- config.lua composes ui/keybinds/os/events into the final config table
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
- **Guidelines**: Documentation rules referenced from `docs/README.md`
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
