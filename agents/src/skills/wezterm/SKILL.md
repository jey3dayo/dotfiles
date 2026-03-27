---
name: wezterm
description: |
  [What] Specialized skill for reviewing WezTerm configurations. Evaluates GPU acceleration settings, keybinding design, theme integration, and cross-platform compatibility. Provides detailed assessment of performance optimization, Lua configuration patterns, and terminal emulator best practices
  [When] Use when: users mention "WezTerm", "terminal configuration", "GPU acceleration", or work with wezterm.lua config files
  [Keywords] WezTerm, terminal configuration, GPU acceleration
---

# WezTerm Configuration Review

## Overview

This skill provides specialized review guidance for WezTerm terminal emulator configurations, focusing on GPU performance optimization, keybinding ergonomics, theme consistency, and modern Lua-based configuration patterns. Evaluate configurations for performance, usability, and cross-platform compatibility.

## Core Evaluation Areas

### 1. Performance & GPU Configuration

Assess GPU acceleration and rendering performance:

#### GPU Settings

- Verify WebGpu front-end usage (recommended for modern hardware)
- Check power preference (HighPerformance vs LowPower)
- Assess software rendering fallback configuration
- Monitor rendering performance

#### Performance Metrics

- Evaluate startup time (<1s target)
- Check frame rate consistency
- Monitor memory usage
- Assess input latency

#### Optimization Strategies

- Enable hardware acceleration where available
- Configure appropriate buffer sizes
- Optimize font rendering
- Manage background opacity for performance

### 2. Keybinding Design

Review keybinding organization and ergonomics:

#### Leader Key Pattern

- Assess leader key choice (typically Ctrl+x or Ctrl+a)
- Verify Tmux-style consistency
- Check leader timeout configuration
- Evaluate mnemonic clarity

#### Keybinding Categories

1. Tab Management: New, switch, close, rename
2. Pane Management: Split (horizontal/vertical), navigate, resize, zoom
3. Copy Mode: Enter, navigate, select, yank
4. Quick Actions: Font size, transparency, search

#### Ergonomics

- Verify logical groupings
- Check for conflicts
- Assess discoverability
- Maintain consistency with other tools

### 3. Theme & Visual Integration

Evaluate theme consistency and visual design:

#### Theme Selection

- Verify theme choice (Gruvbox recommended for dotfiles consistency)
- Check color scheme appropriateness
- Assess contrast and readability
- Evaluate accessibility

#### Visual Settings

- Background opacity (<1.0 for integration)
- Font selection (monospace, ligatures)
- Font size appropriateness
- Cursor style and color

#### Cross-Tool Consistency

- Theme alignment with Zsh (Starship prompt)
- Color coordination with Neovim
- Unified visual language across tools
- Seamless terminal integration

### 4. Configuration Structure

Assess Lua configuration organization:

#### Modular Design

- Separate configuration files (keybinds.lua, ui.lua, etc.)
- Clear entry point (wezterm.lua)
- Logical file organization
- Documented structure

#### Lua Patterns

- Use WezTerm API effectively
- Implement proper error handling
- Leverage conditional logic
- Avoid hardcoded values

#### Platform Handling

- Detect OS appropriately (is_windows, is_mac)
- Apply platform-specific settings
- Handle WSL integration
- Maintain cross-platform compatibility

### 5. Copy Mode & Productivity

Review copy mode configuration and productivity features:

#### Copy Mode Design

- Vim-style keybindings (h/j/k/l navigation)
- Word/line selection (w/b/e, V)
- Search functionality
- Quick copy shortcuts (y/yy)

#### Productivity Features

- Command palette integration
- Quick launcher configuration
- SSH domain setup
- Custom spawn commands

## Common WezTerm Configuration Issues

### Performance Problems

### Issues

- Slow rendering or lag
- High CPU/GPU usage
- Poor font rendering
- Sluggish input response

### Solutions

- Enable WebGpu front-end
- Set appropriate power preference
- Optimize font settings
- Reduce background opacity if needed

### Keybinding Problems

### Issues

- Keybinding conflicts
- Unintuitive shortcuts
- Missing essential functions
- Inconsistent patterns

### Solutions

- Implement leader key pattern
- Follow Tmux conventions
- Document keybinding groups
- Test for conflicts

### Theme Problems

### Issues

- Inconsistent theming across tools
- Poor readability
- Mismatched colors
- Accessibility issues

### Solutions

- Adopt unified theme (Gruvbox)
- Verify contrast ratios
- Test in different lighting
- Align with other tools

### Configuration Structure Problems

### Issues

- Monolithic wezterm.lua
- Hardcoded values
- No platform handling
- Poor organization

### Solutions

- Modularize into separate files
- Use variables and constants
- Implement OS detection
- Document configuration flow

## WezTerm-Specific Evaluation Guidelines

### Performance Assessment

### ⭐⭐⭐⭐⭐ (5/5) Excellent

- GPU acceleration enabled
- Startup time <500ms
- Smooth rendering
- Optimized settings

### ⭐⭐⭐⭐☆ (4/5) Good

- GPU acceleration active
- Startup time <1s
- Good performance
- Minor optimization opportunities

### ⭐⭐⭐☆☆ (3/5) Standard

- Basic GPU support
- Startup time <2s
- Acceptable performance
- Some inefficiencies

### ⭐⭐☆☆☆ (2/5) Needs Improvement

- Software rendering
- Slow startup (>2s)
- Noticeable lag
- Poor optimization

### ⭐☆☆☆☆ (1/5) Requires Overhaul

- No GPU acceleration
- Very slow startup
- Frequent lag
- No performance considerations

### Keybinding Quality

Evaluate based on:

- Leader key implementation
- Logical organization
- Mnemonic clarity
- Conflict absence

### Theme Integration

Assess based on:

- Cross-tool consistency
- Readability
- Accessibility
- Visual harmony

### Configuration Structure

Assess based on:

- Modular organization
- Platform handling
- Documentation
- Maintainability

## Recommended Improvements

### Enable GPU Acceleration

### Before

```lua
-- Default or software rendering
config.front_end = "Software"
```

### After

```lua
-- Hardware acceleration
config.front_end = "WebGpu"
config.webgpu_power_preference = "HighPerformance"
```

### Implement Leader Key Pattern

### Before

```lua
-- Direct keybindings
{ key = 'c', mods = 'ALT', action = act.SpawnTab 'CurrentPaneDomain' },
{ key = 'x', mods = 'ALT', action = act.CloseCurrentPane { confirm = true } },
```

### After

```lua
-- Leader key pattern (Tmux-style)
config.leader = { key = 'x', mods = 'CTRL', timeout_milliseconds = 1000 }
keys = {
  { key = 'c', mods = 'LEADER', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'x', mods = 'LEADER', action = act.CloseCurrentPane { confirm = true } },
}
```

### Modularize Configuration

### Before

```lua
-- Monolithic wezterm.lua (200+ lines)
local config = {}
config.font = ...
config.keys = {...}
config.colors = {...}
-- everything mixed together
```

### After

```lua
-- wezterm.lua (entry point)
local config = require('wezterm').config_builder()
require('keybinds').apply(config)
require('ui').apply(config)
require('os').apply(config)
return config

-- keybinds.lua
-- ui.lua
-- os.lua (separate files)
```

## Review Workflow

When reviewing WezTerm configurations:

1. Check GPU settings: Verify WebGpu front-end and power preference
2. Test startup: Measure startup time
3. Review keybindings: Check leader key and organization
4. Evaluate theme: Verify Gruvbox consistency
5. Test copy mode: Confirm Vim-style keybindings work
6. Check structure: Verify modular organization
7. Test platform support: Verify OS-specific settings
8. Review transparency: Check background opacity
9. Test functionality: Ensure all features work
10. Compare against best practices: Assess overall quality

## 🤖 Agent Integration

This skill provides specialized knowledge to agents executing WezTerm configuration review and optimization tasks:

### Code-Reviewer Agent

- Provides: WezTerm configuration quality assessment, GPU optimization verification, theme integration confirmation
- Timing: During WezTerm configuration review
- Context:
  - ⭐️ 5-level evaluation (GPU settings, keybindings, theme integration, cross-platform support)
  - WebGpu front-end verification
  - Gruvbox theme consistency check
  - Performance assessment

### Orchestrator Agent

- Provides: WezTerm configuration optimization plan, modular structure design
- Timing: During WezTerm configuration improvement and optimization
- Context: GPU settings optimization, keybinding design, theme integration, platform support

### Error-Fixer Agent

- Provides: WezTerm configuration error fixes, Lua syntax corrections
- Timing: When handling WezTerm startup errors or configuration errors
- Context: Configuration error diagnosis, Lua syntax correction, GPU settings correction

### Auto-load Conditions

- Mentioning "WezTerm", "terminal configuration", or "GPU acceleration"
- When working with wezterm.lua or WezTerm configuration files
- Terminal emulator configuration review requests
- Dotfiles integration tasks

### Integration Example

```
User: "Review WezTerm configuration and improve GPU optimization"
    ↓
TaskContext created
    ↓
Project detection: WezTerm configuration
    ↓
Skill auto-load: wezterm, dotfiles-integration
    ↓
Agent selection: code-reviewer → orchestrator
    ↓ (skill context provided)
⭐️ 5-level evaluation + GPU optimization patterns + theme integration
    ↓
Execution complete (GPU settings optimized, performance improved)
```

## Integration with Related Skills

- code-review skill: For overall quality assessment
- zsh skill: For shell integration and theme consistency
- nvim skill: For editor integration and theme alignment
- dotfiles-integration skill: For cross-tool theming and productivity workflows

## Reference Material

The `references/` directory contains detailed WezTerm configuration documentation including:

- GPU optimization strategies
- Keybinding design patterns
- Theme integration guidelines
- Platform-specific configurations
- Performance tuning recommendations
- Copy mode configuration examples
