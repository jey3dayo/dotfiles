# Claude AI Configuration Directory

This directory contains Claude-specific configurations, documentation, and project data for AI-assisted development.

## 📁 Directory Structure

```
.claude/
├── commands/           # Claude Code custom commands
├── projects/          # Project-specific Claude data
├── todos/             # Task management files (72K)
├── local/             # Local Claude installation (177M)
├── settings.json      # Claude Code settings
└── README.md          # This documentation
```

## 🎯 Purpose

- **Command Management**: Custom Claude Code commands and workflows
- **AI Assistance**: Context for Claude AI to provide targeted help
- **Project Data**: Session-specific configurations and context
- **Task Tracking**: Persistent todo management across sessions

**Note**: General documentation has been moved to `docs/` directory for better organization and maintainability.

## 📋 Rules vs Documentation

### Two-Tier Documentation System

dotfiles employs a **Progressive Disclosure** design pattern with two distinct documentation tiers:

#### `.claude/rules/tools/` (AI Enforcement Rules)

**Purpose**: Concise 26-31 line rules for Claude AI

**Characteristics**:

- Always loaded into AI context
- YAML frontmatter with `paths:` and `source:` fields
- Condensed policy statements and constraints
- References detailed documentation via `source:` field

**Files**:

- `fzf-integration.md` → FZF bindings and integration rules
- `git.md` → Git configuration hierarchy rules
- `ssh.md` → SSH configuration security rules
- `nvim.md` → Neovim architecture and performance guards
- `wezterm.md` → WezTerm configuration consistency
- `zsh.md` → Zsh load order and caching rules

#### `docs/tools/` (Detailed Reference)

**Purpose**: Comprehensive 100-300 line implementation guides

**Characteristics**:

- Loaded on-demand by Claude when needed
- Standard markdown with metadata headers
- Complete implementation details, examples, troubleshooting
- SST (Single Source of Truth) for tool documentation

**Files**:

- `fzf-integration.md` (317 lines) - Comprehensive keybindings and workflows
- `git.md` (59 lines) - Git configuration details
- `ssh.md` (198 lines) - SSH config management
- `nvim.md` (304 lines) - Complete Neovim guide with evaluation
- `wezterm.md` (132 lines) - Terminal setup and customization
- `zsh.md` (109 lines) - Shell configuration and optimization

### Design Rationale

This separation follows:

- **skill-creator**: Progressive Disclosure (metadata → body → resources)
- **rules-creator**: Rules Hierarchy (guidelines → steering → rules → hookify)

**Benefits**:

- ✅ Token-efficient: Only load detailed docs when necessary
- ✅ Separation of concerns: User docs vs. AI enforcement rules
- ✅ Maintainability: Update rules without touching full documentation
- ✅ Consistency: Both tiers reference the same source files

## 🔧 Key Components

### Commands System

- **Custom Commands**: Project-specific Claude Code commands
- **Workflows**: Automated development workflows
- **Task Automation**: Streamlined development processes

### Project Data

- Session-specific data and configurations
- AI context preservation
- Task management and progress tracking

### Local Installation

- Claude Code CLI and dependencies
- Binary tools and utilities
- Node.js packages for functionality

## 🚀 Usage

This directory is automatically managed by Claude Code. Key files:

- **commands/**: Custom Claude Code commands and workflows
- **projects/**: Session data and project context
- **todos/**: Task management JSON files
- **settings.json**: Claude Code configuration

## 📚 Documentation

All general documentation has been consolidated in the `docs/` directory:

- **Main Guides**: `docs/` - Setup, performance, maintenance, and tools
- **Tool Documentation**: `docs/tools/` - Tool-specific configurations and guides
  - `zsh.md` - Shell configuration and optimization
  - `nvim.md` - Neovim setup and language support
  - `wezterm.md` - Terminal configuration
  - `ssh.md` - SSH configuration management
  - `fzf-integration.md` - Fuzzy search integration

## 🧹 Maintenance

- **Todos**: 18 active files, cleaned automatically
- **Local**: 177M for Claude CLI and dependencies
- **Projects**: Session-specific data, managed by Claude

---

_Last Updated: 2025-12-17_
_Total Size: 177M (mostly local installation)_
