---
name: dotfiles-integration
description: |
  [What] Specialized skill for reviewing dotfiles cross-tool integration patterns. Evaluates layer interactions (Shell/Editor/Terminal), theme consistency (Gruvbox), FZF integration, and architectural patterns. Provides detailed assessment of cross-tool workflows, dependency analysis, and performance impact
  [When] Use when: users mention "dotfiles integration", "cross-tool", "FZF integration", "theme consistency", "layer architecture", or need holistic dotfiles review
  [Keywords] dotfiles integration, cross-tool, FZF integration, theme consistency, layer architecture
---

# Dotfiles Integration Review

## Overview

This skill provides specialized review guidance for dotfiles cross-tool integration, focusing on layer interactions, theme consistency, unified workflows, and architectural patterns. Evaluate configurations for seamless tool integration, consistent user experience, and holistic system design quality.

## Core Evaluation Areas

### 1. Layer Architecture

Assess the three-layer architecture and interactions:

#### Primary Technologies (Core Layer)

- **Zsh**: Shell foundation (startup time: 1.1s target <100ms)
- **Neovim**: Editor (startup time: <100ms)
- **WezTerm**: Terminal (startup time: 800ms target <1s)

#### Integration Quality

- Verify clear separation of concerns
- Assess layer independence
- Check communication patterns
- Evaluate modularity

#### Performance Impact

- Measure cumulative startup time
- Identify cross-layer bottlenecks
- Assess memory footprint
- Monitor resource sharing

### 2. Theme Consistency

Evaluate unified theming across tools:

#### Gruvbox Integration

- Verify Gruvbox theme usage across Zsh/Neovim/WezTerm
- Check color scheme consistency
- Assess visual harmony
- Validate transparency settings

#### Theme Elements

- Background opacity coordination
- Font family consistency (UDEV Gothic)
- Color palette alignment
- Visual element uniformity

#### Accessibility

- Verify contrast ratios
- Check readability across tools
- Test in different lighting conditions
- Validate accessibility standards

### 3. FZF Integration

Review FZF cross-tool integration patterns:

#### Shell Layer Integration

- Repository navigation (`^]` ghq integration)
- Process management (`^g^K`)
- Command history (`^R`)
- File selection (`^T`)

#### Git Layer Integration

- Branch selection (`gco` function)
- Status widgets (`^g^g`)
- Git operations with FZF
- Repository management (ghq + FZF)

#### Terminal Layer Integration

- Tmux session management (`prefix + s`)
- Window selection
- Session switching (90% time reduction)

#### Editor Layer Integration

- File search (telescope/fzf-lua)
- Text search (live grep)
- Buffer management
- 60% performance improvement verification

#### Cross-Layer Workflows

- Repository → Editor → Terminal workflow
- Git operations across layers
- Unified search experience
- Consistent keybinding patterns

### 4. Dependency Management

Assess tool dependencies and interactions:

#### Direct Dependencies

- Zsh → FZF → Git integration
- Neovim → LSP servers → Mason
- WezTerm → Font files → Gruvbox theme

#### Transitive Dependencies

- FZF plugins → Completion system
- Starship → Zsh → Git status
- Tmux → WezTerm → Session management

#### Version Compatibility

- mise → Language version management
- Homebrew → Tool installation
- Plugin manager versions
- LSP server compatibility

### 5. Unified Workflows

Evaluate integrated development workflows:

#### Repository Development Workflow

```bash
# 1. Repository selection (FZF + ghq)
^]

# 2. Git operations
gco  # FZF branch checkout
^g^g # Git status with FZF

# 3. Editor integration
nvim  # fzf-lua for file operations

# 4. Terminal multiplexing
prefix + s  # FZF session selection
```

#### Session Management Workflow

- Terminal → Tmux → Sessions
- Zsh → Directory navigation
- Neovim → File editing
- Git → Version control

#### Performance Metrics

- Workflow completion time
- Context switching overhead
- Tool startup impact
- Memory usage patterns

## Common Integration Issues

### Layer Boundary Problems

**Issues**:

- Tight coupling between tools
- Unclear separation of concerns
- Redundant functionality
- Conflicting configurations

**Solutions**:

- Define clear interfaces
- Document layer responsibilities
- Remove duplication
- Establish integration contracts

### Theme Inconsistency Problems

**Issues**:

- Mismatched colors across tools
- Different transparency levels
- Inconsistent fonts
- Visual disharmony

**Solutions**:

- Adopt unified Gruvbox theme
- Standardize opacity settings
- Use consistent fonts
- Document theme standards

### FZF Integration Problems

**Issues**:

- Inconsistent keybindings
- Poor performance in some contexts
- Missing integrations
- Redundant implementations

**Solutions**:

- Unify keybinding patterns
- Optimize FZF configurations
- Complete integration coverage
- Centralize FZF settings

### Dependency Conflict Problems

**Issues**:

- Version conflicts
- Circular dependencies
- Unnecessary dependencies
- Outdated tools

**Solutions**:

- Document dependency tree
- Use version managers (mise)
- Audit dependencies regularly
- Maintain update schedule

## Integration-Specific Evaluation Guidelines

### Cross-Layer Integration Quality

**⭐⭐⭐⭐⭐ (5/5) Excellent**:

- Seamless tool transitions
- Unified theme (Gruvbox)
- Comprehensive FZF integration
- Clear layer boundaries
- <3s total startup time

**⭐⭐⭐⭐☆ (4/5) Good**:

- Good tool integration
- Mostly consistent theme
- Extensive FZF usage
- Defined layer structure
- <5s total startup time

**⭐⭐⭐☆☆ (3/5) Standard**:

- Basic integration
- Partial theme consistency
- Some FZF integration
- Acceptable boundaries
- <8s total startup time

**⭐⭐☆☆☆ (2/5) Needs Improvement**:

- Minimal integration
- Inconsistent theming
- Limited FZF usage
- Unclear boundaries
- > 8s total startup time

**⭐☆☆☆☆ (1/5) Requires Overhaul**:

- No integration strategy
- Conflicting themes
- No FZF integration
- No layer design
- Very slow startup

### FZF Integration Coverage

Evaluate based on:

- Shell integration completeness
- Git workflow coverage
- Terminal multiplexing
- Editor integration
- Performance improvements

### Theme Consistency

Assess based on:

- Color scheme uniformity
- Font consistency
- Transparency coordination
- Visual harmony

### Workflow Efficiency

Assess based on:

- Context switching speed
- Operation completion time
- Keybinding consistency
- User experience quality

## Recommended Improvements

### Unify Theme Implementation

**Before**:

```lua
-- WezTerm: custom colors
config.colors = { background = '#1d2021', ... }

-- Neovim: different theme
vim.cmd('colorscheme onedark')

-- Zsh: no theme coordination
```

**After**:

```lua
-- Unified Gruvbox across all tools
-- WezTerm
config.color_scheme = 'Gruvbox Dark'

-- Neovim
vim.cmd('colorscheme gruvbox')

-- Zsh (Starship)
format = """... # Gruvbox colors
```

### Centralize FZF Configuration

**Before**:

```bash
# Different FZF settings per tool
# Zsh: one config
# Git: another config
# Nvim: separate plugin config
```

**After**:

```bash
# Centralized FZF configuration
# config/tools/fzf.zsh
export FZF_DEFAULT_OPTS="--color=bg+:#3c3836,bg:#32302f..."

# Git integration references global settings
# Neovim fzf-lua uses same theme
# Tmux FZF uses shared config
```

### Optimize Cross-Layer Workflows

**Before**:

```bash
# Manual, disconnected workflow
cd ~/projects/repo
git status
nvim file.txt
tmux new-session
```

**After**:

```bash
# Integrated FZF workflow
^]                # FZF ghq repo selection (auto-cd)
^g^g              # Git status with FZF file selection
<leader>ff        # Neovim FZF file search
prefix + s        # FZF session management
```

## Review Workflow

When reviewing dotfiles integration:

1. **Map layer architecture**: Identify core technologies and supporting tools
2. **Check theme consistency**: Verify Gruvbox usage across Zsh/Neovim/WezTerm
3. **Audit FZF integration**: Review shell/git/terminal/editor coverage
4. **Analyze dependencies**: Map tool relationships and version constraints
5. **Test workflows**: Execute common development workflows end-to-end
6. **Measure performance**: Assess cumulative startup time and memory usage
7. **Review documentation**: Check integration patterns documentation
8. **Identify coupling**: Find tight coupling and refactoring opportunities
9. **Verify modularity**: Ensure clear separation of concerns
10. **Compare against best practices**: Assess overall integration quality

## Integration with Related Skills

- **zsh skill**: For shell layer optimization and plugin management
- **nvim skill**: For editor layer configuration and LSP integration
- **wezterm skill**: For terminal layer and GPU optimization
- **code-review skill**: For overall quality assessment framework
- **semantic-analysis skill**: For dependency graph analysis

## Reference Material

The `references/` directory contains detailed integration documentation including:

- FZF integration patterns and metrics
- Layer architecture guidelines
- Theme consistency standards
- Workflow optimization strategies
- Dependency management practices
- SSH configuration patterns
- Cross-tool performance impact analysis
