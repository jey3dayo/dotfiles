---
paths: ghostty/**/*
references: karabiner/karabiner.json
---

# Ghostty Rules

Purpose: Ghostty terminal のキーバインド管理。Scope: `ctrl+b` リーダーキーシーケンス、スプリット操作、タブ管理。

## 管理ファイル

- `ghostty/config` — すべての設定を一元管理します。

## Leader キーの方針

leader は **`ctrl+b`** です。Ghostty 内で動作する herdr が prefix に `ctrl+x` を使うため、衝突を避ける目的で Ghostty 側を `ctrl+b` に分離しています。leader を変更する際は、herdr の prefix（`~/.config/herdr/config.toml` の `keys.prefix`）と重複しないことを必ず確認してください。

## Sequence 構文

```ini
keybind = ctrl+b>KEY=action
```

大文字キーは `L` ではなく `shift+l` と記述します。Ghostty では `ctrl+b>L` と `ctrl+b>l` が**同一トリガー**として扱われ、後の定義が前の定義を上書きします。

## C-b リーダーキー一覧

### Tabs

| Ctrl+B → | アクション       | Ghostty action |
| -------- | ---------------- | -------------- |
| c        | 新しいタブ       | `new_tab`      |
| n        | 次のタブ         | `next_tab`     |
| p        | 前のタブ         | `previous_tab` |
| 1〜8     | タブ直接ジャンプ | `goto_tab:N`   |

### Splits

| Ctrl+B →   | アクション       | Ghostty action      |
| ---------- | ---------------- | ------------------- |
| -          | 下スプリット     | `new_split:down`    |
| \ / ¥ / \| | 右スプリット     | `new_split:right`   |
| o          | 次のペイン       | `goto_split:next`   |
| z          | ペインズーム切替 | `toggle_split_zoom` |
| Space      | ペイン均等化     | `equalize_splits`   |

### Pane Navigation（Vim 風）

| Ctrl+B → | アクション | Ghostty action     |
| -------- | ---------- | ------------------ |
| h        | ペイン左へ | `goto_split:left`  |
| j        | ペイン下へ | `goto_split:down`  |
| k        | ペイン上へ | `goto_split:up`    |
| l        | ペイン右へ | `goto_split:right` |

### Pane Resize（Shift+HJKL）

| Ctrl+B → | アクション | Ghostty action          |
| -------- | ---------- | ----------------------- |
| Shift+H  | リサイズ左 | `resize_split:left,32`  |
| Shift+J  | リサイズ下 | `resize_split:down,32`  |
| Shift+K  | リサイズ上 | `resize_split:up,32`    |
| Shift+L  | リサイズ右 | `resize_split:right,32` |

> 設定ファイルには `shift+h` と記述します（`H` は不可）。

### その他

| Ctrl+B → | アクション       | Ghostty action           |
| -------- | ---------------- | ------------------------ |
| x        | Surface を閉じる | `close_surface`          |
| /        | コマンドパレット | `toggle_command_palette` |
| r        | config リロード  | `reload_config`          |

## 新しいバインドの追加方法

```ini
# Ctrl+B リーダー
keybind = ctrl+b>KEY=action

# Shift+KEY の場合
keybind = ctrl+b>shift+key=action
```

追加後は `C-b r`（`reload_config`）で設定を再読み込みします。

## 公式リファレンス

- [Keybind Actions Reference](https://ghostty.org/docs/config/keybind/reference) — 全アクション一覧
