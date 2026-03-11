---
paths: ghostty/**/*
references: karabiner/karabiner.json
---

# Ghostty Rules

Purpose: Ghostty terminal keybind 管理。Scope: C-x リーダーキーシーケンス、スプリット操作、タブ管理。

## 管理ファイル

`ghostty/config` — すべての設定を一元管理

## Sequence 構文

```ini
keybind = ctrl+x>KEY=action
```

重要: 大文字キーは `L` ではなく `shift+l` と書くこと。
`ctrl+x>L` と `ctrl+x>l` は Ghostty では**同一トリガー**として扱われ、
後の定義が前を上書きする。

## C-x リーダーキー一覧

### Tabs

| Ctrl+X → | アクション       | Ghostty action |
| -------- | ---------------- | -------------- |
| c        | 新しいタブ       | `new_tab`      |
| n        | 次のタブ         | `next_tab`     |
| p        | 前のタブ         | `previous_tab` |
| 1〜8     | タブ直接ジャンプ | `goto_tab:N`   |

### Splits

| Ctrl+X →   | アクション       | Ghostty action      |
| ---------- | ---------------- | ------------------- |
| -          | 下スプリット     | `new_split:down`    |
| \ / ¥ / \| | 右スプリット     | `new_split:right`   |
| o          | 次のペイン       | `goto_split:next`   |
| z          | ペインズーム切替 | `toggle_split_zoom` |
| Space      | ペイン均等化     | `equalize_splits`   |

### Pane Navigation（Vim 風）

| Ctrl+X → | アクション | Ghostty action     |
| -------- | ---------- | ------------------ |
| h        | ペイン左へ | `goto_split:left`  |
| j        | ペイン下へ | `goto_split:down`  |
| k        | ペイン上へ | `goto_split:up`    |
| l        | ペイン右へ | `goto_split:right` |

### Pane Resize（Shift+HJKL）

| Ctrl+X → | アクション | Ghostty action          |
| -------- | ---------- | ----------------------- |
| Shift+H  | リサイズ左 | `resize_split:left,32`  |
| Shift+J  | リサイズ下 | `resize_split:down,32`  |
| Shift+K  | リサイズ上 | `resize_split:up,32`    |
| Shift+L  | リサイズ右 | `resize_split:right,32` |

> 設定ファイルには `shift+h` と記述すること（`H` は不可）

### その他

| Ctrl+X → | アクション       | Ghostty action           |
| -------- | ---------------- | ------------------------ |
| x        | Surface を閉じる | `close_surface`          |
| /        | コマンドパレット | `toggle_command_palette` |
| r        | config リロード  | `reload_config`          |

## 新しいバインドの追加方法

```ini
# Ctrl+X リーダー
keybind = ctrl+x>KEY=action

# Shift+KEY の場合
keybind = ctrl+x>shift+key=action
```

追加後: `C-x r`（`reload_config`）でリロード。

## 公式リファレンス

- [Keybind Actions Reference](https://ghostty.org/docs/config/keybind/reference) — 全アクション一覧

## cmux との対応

cmux は Ghostty の C-x シーケンスを持たないため、Karabiner-Elements で補完している。
`karabiner/karabiner.json` → `.claude/rules/tools/karabiner.md` を参照。
