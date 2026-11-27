---
type: reference
title: Ghostty Configuration
description: Ghostty の設定方針、Ctrl+B リーダーキー操作一覧、キーバインド追加手順
resource: docs/tools/ghostty.md
tags:
  - category/terminal
  - layer/tool
  - tool/ghostty
  - environment/macos
  - audience/developer
timestamp: 2026-11-27
audience: developer
owner: dotfiles
---

# Ghostty Configuration

Ghostty ターミナルの設定とキーバインドの正本です。すべての設定は [`ghostty/config`](../../ghostty/config) で一元管理しています。

Claude 向けの短いルールは [`.claude/rules/tools/ghostty.md`](../../.claude/rules/tools/ghostty.md) にあります。

## 基本設定とリーダーキーの方針

- テーマ・フォント: テーマは `0x96f`、背景不透明度は `0.94`、フォントは `UDEV Gothic 35NFLG` を使用しています。
- macOS の Option キー: `macos-option-as-alt = left` により左 Option のみを Alt として扱い、右 Option は文字合成（`~` など）用に残しています。
- リーダーキー: **`ctrl+b`** を使用します。Ghostty 内で動作する `herdr` がプレフィックスに `ctrl+x`（およびリサイズモードに `alt+r`）を使うため、競合を避ける目的で分離しています。リーダーキーを変更する際は、`~/.config/herdr/config.toml` の `keys.prefix` と重複しないことを必ず確認してください。

## シーケンス構文の注意点

```ini
keybind = ctrl+b>KEY=action
```

大文字キーは `L` ではなく `shift+l` と記述します。Ghostty では `ctrl+b>L` と `ctrl+b>l` が同一のトリガーとして扱われ、後の定義が前の定義を上書きしてしまいます。

## `Ctrl+B` リーダーキー一覧

### タブ操作

| Ctrl+B → | アクション     | Ghostty action |
| -------- | -------------- | -------------- |
| `c`      | 新しいタブ     | `new_tab`      |
| `n`      | 次のタブ       | `next_tab`     |
| `p`      | 前のタブ       | `previous_tab` |
| `1`〜`8` | タブへ直接移動 | `goto_tab:N`   |

### ペイン分割・整理

| Ctrl+B →         | アクション         | Ghostty action      |
| ---------------- | ------------------ | ------------------- |
| `-`              | 下方向へ分割       | `new_split:down`    |
| `\` / `¥` / `\|` | 右方向へ分割       | `new_split:right`   |
| `o`              | 次のペインへ移動   | `goto_split:next`   |
| `z`              | ペインズーム切替   | `toggle_split_zoom` |
| `Space`          | ペインサイズ均等化 | `equalize_splits`   |

### ペイン移動（Vim 風）

| Ctrl+B → | アクション | Ghostty action     |
| -------- | ---------- | ------------------ |
| `h`      | 左ペインへ | `goto_split:left`  |
| `j`      | 下ペインへ | `goto_split:down`  |
| `k`      | 上ペインへ | `goto_split:up`    |
| `l`      | 右ペインへ | `goto_split:right` |

### ペインリサイズ（`Shift+HJKL`）

| Ctrl+B →  | アクション   | Ghostty action          |
| --------- | ------------ | ----------------------- |
| `Shift+H` | 左へリサイズ | `resize_split:left,32`  |
| `Shift+J` | 下へリサイズ | `resize_split:down,32`  |
| `Shift+K` | 上へリサイズ | `resize_split:up,32`    |
| `Shift+L` | 右へリサイズ | `resize_split:right,32` |

> 設定ファイル上では `shift+h` のように小文字で記述します（`H` は不可）。

### その他

| Ctrl+B → | アクション             | Ghostty action           |
| -------- | ---------------------- | ------------------------ |
| `x`      | Surface を閉じる       | `close_surface`          |
| `/`      | コマンドパレットを開く | `toggle_command_palette` |
| `r`      | 設定を再読み込み       | `reload_config`          |

## リーダーキーなしの直接バインド

| キー                | アクション           | Ghostty action                  |
| ------------------- | -------------------- | ------------------------------- |
| `Ctrl++` / `Ctrl+-` | フォントサイズ変更   | `increase/decrease_font_size:1` |
| `Ctrl+0`            | フォントサイズ初期化 | `reset_font_size`               |
| `Alt+Ctrl+H` / `L`  | タブ位置を左右移動   | `move_tab:-1` / `1`             |

## 新しいキーバインドの追加

```ini
# Ctrl+B リーダー
keybind = ctrl+b>KEY=action

# Shift+KEY の場合
keybind = ctrl+b>shift+key=action
```

追加後は `Ctrl+B` → `r`（`reload_config`）で設定を再読み込みします。

## 公式リファレンス

- [Keybind Actions Reference](https://ghostty.org/docs/config/keybind/reference) — 全アクション一覧
