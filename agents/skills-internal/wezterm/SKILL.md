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

1. **Tab Management**: New, switch, close, rename
2. **Pane Management**: Split (horizontal/vertical), navigate, resize, zoom
3. **Copy Mode**: Enter, navigate, select, yank
4. **Quick Actions**: Font size, transparency, search

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

**Issues**:

- Slow rendering or lag
- High CPU/GPU usage
- Poor font rendering
- Sluggish input response

**Solutions**:

- Enable WebGpu front-end
- Set appropriate power preference
- Optimize font settings
- Reduce background opacity if needed

### Keybinding Problems

**Issues**:

- Keybinding conflicts
- Unintuitive shortcuts
- Missing essential functions
- Inconsistent patterns

**Solutions**:

- Implement leader key pattern
- Follow Tmux conventions
- Document keybinding groups
- Test for conflicts

### Theme Problems

**Issues**:

- Inconsistent theming across tools
- Poor readability
- Mismatched colors
- Accessibility issues

**Solutions**:

- Adopt unified theme (Gruvbox)
- Verify contrast ratios
- Test in different lighting
- Align with other tools

### Configuration Structure Problems

**Issues**:

- Monolithic wezterm.lua
- Hardcoded values
- No platform handling
- Poor organization

**Solutions**:

- Modularize into separate files
- Use variables and constants
- Implement OS detection
- Document configuration flow

## WezTerm-Specific Evaluation Guidelines

### Performance Assessment

**⭐⭐⭐⭐⭐ (5/5) Excellent**:

- GPU acceleration enabled
- Startup time <500ms
- Smooth rendering
- Optimized settings

**⭐⭐⭐⭐☆ (4/5) Good**:

- GPU acceleration active
- Startup time <1s
- Good performance
- Minor optimization opportunities

**⭐⭐⭐☆☆ (3/5) Standard**:

- Basic GPU support
- Startup time <2s
- Acceptable performance
- Some inefficiencies

**⭐⭐☆☆☆ (2/5) Needs Improvement**:

- Software rendering
- Slow startup (>2s)
- Noticeable lag
- Poor optimization

**⭐☆☆☆☆ (1/5) Requires Overhaul**:

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

**Before**:

```lua
-- Default or software rendering
config.front_end = "Software"
```

**After**:

```lua
-- Hardware acceleration
config.front_end = "WebGpu"
config.webgpu_power_preference = "HighPerformance"
```

### Implement Leader Key Pattern

**Before**:

```lua
-- Direct keybindings
{ key = 'c', mods = 'ALT', action = act.SpawnTab 'CurrentPaneDomain' },
{ key = 'x', mods = 'ALT', action = act.CloseCurrentPane { confirm = true } },
```

**After**:

```lua
-- Leader key pattern (Tmux-style)
config.leader = { key = 'x', mods = 'CTRL', timeout_milliseconds = 1000 }
keys = {
  { key = 'c', mods = 'LEADER', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'x', mods = 'LEADER', action = act.CloseCurrentPane { confirm = true } },
}
```

### Modularize Configuration

**Before**:

```lua
-- Monolithic wezterm.lua (200+ lines)
local config = {}
config.font = ...
config.keys = {...}
config.colors = {...}
-- everything mixed together
```

**After**:

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

1. **Check GPU settings**: Verify WebGpu front-end and power preference
2. **Test startup**: Measure startup time
3. **Review keybindings**: Check leader key and organization
4. **Evaluate theme**: Verify Gruvbox consistency
5. **Test copy mode**: Confirm Vim-style keybindings work
6. **Check structure**: Verify modular organization
7. **Test platform support**: Verify OS-specific settings
8. **Review transparency**: Check background opacity
9. **Test functionality**: Ensure all features work
10. **Compare against best practices**: Assess overall quality

## 🤖 Agent Integration

このスキルはWezTerm設定レビュー・最適化タスクを実行するエージェントに専門知識を提供します:

### Code-Reviewer Agent

- **提供内容**: WezTerm設定品質評価、GPU最適化検証、テーマ統合確認
- **タイミング**: WezTerm設定レビュー時
- **コンテキスト**:
  - ⭐️5段階評価（GPU設定、キーバインディング、テーマ統合、クロスプラットフォーム対応）
  - WebGpu front-end検証
  - Gruvboxテーマ一貫性チェック
  - パフォーマンス評価

### Orchestrator Agent

- **提供内容**: WezTerm設定最適化計画、モジュール構成設計
- **タイミング**: WezTerm設定改善・最適化時
- **コンテキスト**: GPU設定最適化、キーバインディング設計、テーマ統合、プラットフォーム対応

### Error-Fixer Agent

- **提供内容**: WezTerm設定エラー修正、Lua構文修正
- **タイミング**: WezTerm起動エラー・設定エラー対応時
- **コンテキスト**: 設定エラー診断、Lua構文修正、GPU設定修正

### 自動ロード条件

- "WezTerm"、"terminal configuration"、"GPU acceleration"に言及
- wezterm.lua、wezterm設定ファイル操作時
- ターミナルエミュレータ設定レビュー要求
- dotfiles統合タスク時

**統合例**:

```
ユーザー: "WezTerm設定をレビューしてGPU最適化を改善"
    ↓
TaskContext作成
    ↓
プロジェクト検出: WezTerm設定
    ↓
スキル自動ロード: wezterm, dotfiles-integration
    ↓
エージェント選択: code-reviewer → orchestrator
    ↓ (スキルコンテキスト提供)
⭐️5段階評価 + GPU最適化パターン + テーマ統合
    ↓
実行完了（GPU設定最適化、パフォーマンス向上）
```

## Integration with Related Skills

- **code-review skill**: For overall quality assessment
- **zsh skill**: For shell integration and theme consistency
- **nvim skill**: For editor integration and theme alignment
- **dotfiles-integration skill**: For cross-tool theming and productivity workflows

## Reference Material

The `references/` directory contains detailed WezTerm configuration documentation including:

- GPU optimization strategies
- Keybinding design patterns
- Theme integration guidelines
- Platform-specific configurations
- Performance tuning recommendations
- Copy mode configuration examples
