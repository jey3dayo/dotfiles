---
name: wezterm
description: Use when reviewing or improving WezTerm configuration files such as `wezterm.lua`, especially for GPU frontend settings, keybinding design, theme integration, copy mode, or platform-specific behavior. Do not use for generic terminal emulator comparisons.
---

# WezTerm Configuration Review

## Overview

WezTerm review should start from the actual config entry point, then move through a fixed checklist. Do not begin with style opinions or terminal-app comparisons.

Read `references/wezterm.md` only when you need detailed API examples or deeper WezTerm-specific configuration patterns.

## When to Use

- `wezterm.lua` や関連 Lua 設定をレビューしたい
- GPU frontend や描画設定が妥当か確認したい
- キーバインド、leader key、copy mode を整理したい
- テーマや他ツールとの見た目の整合を見たい
- OS ごとの差分や WSL 連携を確認したい

使わない場面:

- 一般的な terminal emulator 比較だけをしたい
- shell 設定そのものを見たい
- Neovim や tmux だけの設定を見たい

## First Pass

1. `wezterm.lua` の entry point と `require(...)` 構成を確認する
2. GPU frontend と power preference を確認する
3. leader key と主要キーバインド群を確認する
4. theme / font / opacity / copy mode を確認する
5. platform-specific 分岐があるなら OS ごとの差分を確認する

## Review Areas

### 1. Rendering and Performance

- `front_end` が適切か
- `webgpu_power_preference` や fallback 設定が妥当か
- 背景透過やフォント設定が過度に重くないか

### 2. Keybinding Design

- leader key の有無と妥当性
- tab / pane / copy mode の系統が整理されているか
- 衝突しやすいショートカットがないか

### 3. Visual Integration

- color scheme と font が一貫しているか
- opacity や cursor 設定が読みやすさを損ねていないか
- 他ツールとテーマ整合を取る必要があるか

### 4. Structure

- 設定が一枚岩すぎないか
- OS 別設定や keybinds が分離できるか
- 定数化や helper 化で読みやすくできるか

### 5. Platform-Specific Behavior

- macOS / Linux / Windows / WSL 分岐が必要か
- フォント、クリップボード、パス、shell 起動差分を吸収しているか

## Common Mistakes

- WezTerm 固有の相談ではないのに広く terminal 一般論で答える
- GPU 設定を見ずに theme や keybind から触り始める
- copy mode や leader key の設計を後回しにする
- WezTerm API の詳細が必要なのに reference を見ずに推測で書く

## Review Workflow

```text
entry point
  -> rendering
  -> keybindings
  -> visuals
  -> structure
  -> platform-specific behavior
```

必要になった時だけ `references/wezterm.md` を開き、API 名や実装例を確認する。

## References

- `references/wezterm.md`
