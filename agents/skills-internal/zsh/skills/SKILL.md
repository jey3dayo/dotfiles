---
name: zsh
description: |
  [What] Specialized skill for reviewing Zsh configurations. Evaluates startup performance, plugin management, PATH optimization, and modular design patterns. Provides detailed assessment of loading strategies, shell performance metrics, and 2025 best practices compliance
  [When] Use when: users mention "Zsh", "shell optimization", "startup time", "plugin management", or work with .zsh files and shell configurations
  [Keywords] Zsh, shell optimization, startup time, plugin management
---

# Zsh Configuration Review

## Overview

This skill provides specialized review guidance for Zsh shell configurations, focusing on startup performance optimization, plugin management, and modern shell configuration patterns. Evaluate configurations for performance metrics, modular design, and compliance with 2025 Zsh best practices.

**Context7 Integration**: This skill leverages Context7 MCP for up-to-date Zsh, oh-my-zsh, and zinit documentation. Generic documentation has been removed in favor of Context7 queries.

## Core Evaluation Areas

### 1. Startup Performance

Assess and optimize shell initialization time:

#### Performance Metrics

- Measure current startup time (`zsh-benchmark`)
- Compare against target (<100ms ideal, <1s acceptable)
- Identify bottlenecks through profiling
- **Goal**: Achieve <100ms startup time

#### Optimization Strategies (Dotfiles-Specific)

```zsh
# Tiered lazy loading (6-stage recommended):
# 1. Essential (core functionality)
# 2. Completion (tab enhancement)
# 3. Navigation (file/directory tools)
# 4. Git (version control)
# 5. Utility (development tools)
# 6. Theme (visual elements)

# Example: Sheldon plugin priorities
sheldon source  # Optimized plugin cache
zsh-defer -t 2 source /path/to/non-critical.zsh
```

#### Performance Monitoring

- Establish baseline metrics
- Track performance regression
- Profile plugin load times with `zprof`
- Monitor memory usage

### 2. Plugin Management

Evaluate plugin ecosystem and loading strategies:

#### Plugin Manager (2025 Best Practices)

**For oh-my-zsh questions**, use Context7:

```
Query: mcp__plugin_context7_context7__query-docs
Library ID: /ohmyzsh/ohmyzsh
```

**For zinit questions**, use Context7:

```
Query: mcp__plugin_context7_context7__query-docs
Library ID: /zdharma-continuum/zinit
```

**Dotfiles uses Sheldon** (Rust-based, modern):

- ⭐⭐⭐⭐⭐ Compliant with 2025 standards
- High-speed loading, TOML configuration
- Auto-update support, low learning curve

#### Loading Priorities (Dotfiles Pattern)

Verify tiered loading implementation in `sheldon/plugins.toml`:

```toml
# Priority 1: Essential
[plugins.zsh-defer]
github = "romkatv/zsh-defer"

# Priority 2: Completion (deferred)
[plugins.zsh-completions]
github = "zsh-users/zsh-completions"
defer = true

# Priority 6: Theme (last)
[templates]
defer = "{{ hooks?.pre | nl }}{% for file in files %}zsh-defer source \"{{ file }}\"\n{% endfor %}{{ hooks?.post | nl }}"
```

#### Plugin Organization

- Verify plugin necessity
- Avoid redundant functionality
- Document plugin purposes
- Regular plugin audits

### 3. Modular Architecture (Dotfiles Pattern)

Review configuration structure and organization:

#### Directory Structure (Dotfiles Standard)

```
zsh/
├── config/
│   ├── loader.zsh          # Main loader
│   ├── core/               # Core settings
│   ├── loaders/            # Module loaders
│   ├── os/                 # OS-specific (macos.zsh)
│   └── tools/              # Tool configs (brew, fzf, git, mise, starship)
├── functions/              # Custom functions
├── init/                   # Initialization scripts
├── lazy-sources/           # Deferred loading
└── sheldon/                # Plugin manager
```

#### Configuration Patterns

- Apply DRY principles
- Avoid configuration duplication
- Implement conditional loading
- Cleanup helper functions after use (unset)

#### Extensibility

- Support machine-specific settings (`.zshrc.local`)
- Enable environment-specific configurations
- Maintain backward compatibility
- Document extension points

### 4. PATH Management (Dotfiles Pattern)

Evaluate PATH construction and optimization:

#### PATH Strategy (macOS Specific)

```zsh
# .zprofile - After macOS path_helper
path=(
  $HOME/.mise/shims(N-)           # 1. Version managers (highest priority)
  $HOME/{bin,.local/bin}(N-)      # 2. User binaries
  $HOME/.cargo/bin(N-)            # 3. Rust toolchain
  /opt/homebrew/bin(N-)           # 4. Homebrew
  $path                            # 5. System paths (fallback)
)
typeset -gaU PATH  # Remove duplicates
```

#### Priority Configuration

- Version-managed tools (mise/asdf) highest priority
- User binaries before system binaries
- Homebrew before system paths
- System paths as fallback

#### Validation

- Verify path existence before adding (`(N-)` glob qualifier)
- Monitor PATH length
- Test tool resolution order
- Document PATH priorities

### 5. Error Handling & Robustness

Assess reliability and error management:

#### Graceful Degradation

- Check tool availability before usage
- Provide fallback behaviors
- Handle missing dependencies
- Maintain shell functionality

#### Error Messages

- Implement informative error messages
- Guide users to solutions
- Document troubleshooting steps
- Provide diagnostic commands

## Zsh-Specific Evaluation Guidelines

### Startup Performance Assessment

**⭐⭐⭐⭐⭐ (5/5) Excellent**:

- Startup time <100ms
- Full lazy loading implementation
- Optimized plugin priorities
- Compiled `.zwc` files active

**⭐⭐⭐⭐☆ (4/5) Good**:

- Startup time <500ms
- Partial lazy loading
- Organized plugin loading
- Some compilation present

**⭐⭐⭐☆☆ (3/5) Standard**:

- Startup time <1s
- Basic plugin management
- Some optimization attempts
- Minimal lazy loading

**⭐⭐☆☆☆ (2/5) Needs Improvement**:

- Startup time 1-2s
- Synchronous loading
- No clear organization
- Missing optimizations

**⭐☆☆☆☆ (1/5) Requires Overhaul**:

- Startup time >2s
- No plugin management
- Monolithic configuration
- No performance considerations

### Configuration Architecture Quality

Evaluate based on:

- Modular design clarity
- Separation of concerns
- Documentation completeness
- Maintenance ease

### 2025 Best Practices Compliance

Assess based on:

- Modern plugin manager usage
- Lazy loading implementation
- Modular structure adoption
- Performance optimization techniques

## Recommended Improvements

### Optimize Startup Time

**Before**:

```zsh
# Synchronous loading
source /path/to/plugin1.zsh
source /path/to/plugin2.zsh
```

**After**:

```zsh
# Tiered lazy loading
sheldon source  # Optimized plugin cache
zsh-defer -t 2 source /path/to/non-critical.zsh
```

### Implement Modular Structure

**Before**:

```zsh
# Monolithic .zshrc (500+ lines)
export PATH=...
alias ll='ls -la'
function myfunction() { ... }
# ... everything mixed together
```

**After**:

```zsh
# Modular structure
# .zshrc (entry point)
source ~/.config/zsh/config/loader.zsh

# config/loader.zsh
_load_config core
_load_config tools
_load_config functions
```

### Optimize PATH Management

**Before**:

```zsh
# .zshrc - PATH conflicts with path_helper
export PATH=$HOME/bin:$PATH
export PATH=$HOME/.local/bin:$PATH
```

**After**:

```zsh
# .zprofile - After macOS path_helper
path=(
  $HOME/.mise/shims(N-)
  $HOME/{bin,.local/bin}(N-)
  $HOME/.cargo/bin(N-)
  /opt/homebrew/bin(N-)
  $path
)
```

## Review Workflow

When reviewing Zsh configurations:

1. **Measure baseline**: Run `zsh-benchmark` to establish current performance
2. **Check structure**: Verify modular organization (config/, tools/, functions/)
3. **Audit plugins**: Review plugin count, manager, and loading strategy
4. **Evaluate PATH**: Examine PATH construction and priorities
5. **Test lazy loading**: Verify deferred loading implementation
6. **Review documentation**: Check help systems and comments
7. **Verify compilation**: Ensure `.zwc` files exist
8. **Profile performance**: Use `zprof` for detailed analysis
9. **Compare against 2025 standards**: Assess best practices compliance

## Context7 Usage Guidelines

### When to Query Context7

**Query oh-my-zsh** for:

- Plugin documentation
- Theme configuration
- Framework features

**Query zinit** for:

- Advanced plugin management
- Turbo mode patterns
- Ice modifiers

**Query Zsh official docs** for:

- Core shell features
- Builtin functions
- Parameter expansion

### Example Queries

```
# oh-my-zsh plugin list
Library: /ohmyzsh/ohmyzsh
Query: "How to configure git plugin and available aliases"

# zinit turbo mode
Library: /zdharma-continuum/zinit
Query: "How to use turbo mode for faster plugin loading"

# Zsh builtins
Library: /websites/zsh_sourceforge_io_doc_release
Query: "How to use parameter expansion modifiers"
```

## Integration with Related Skills

- **code-review skill**: For overall quality assessment framework
- **semantic-analysis skill**: For dependency analysis between configuration files
- **dotfiles-integration skill**: For cross-tool integration patterns (FZF, Git, etc.)

## Dotfiles-Specific Patterns

### Current Dotfiles Status (as of 2025)

- **Plugin Manager**: Sheldon (Rust-based, modern)
- **Startup Time**: ~1.1s (good, but can improve to <100ms)
- **Architecture**: ⭐⭐⭐⭐⭐ Modular, clean separation
- **Lazy Loading**: ⭐⭐⭐⭐⭐ 6-stage prioritization
- **PATH Management**: ⭐⭐⭐⭐⭐ Optimized, duplicate removal
- **Compilation**: ⭐⭐⭐⭐⭐ Auto-compile `.zwc` system

### Optimization Opportunities

1. **Startup Time**: Implement more aggressive lazy loading to reach <100ms target
2. **Plugin Audit**: Review necessity of all plugins
3. **Completion Optimization**: Defer completion initialization
4. **Profile Analysis**: Use `zprof` to identify remaining bottlenecks
