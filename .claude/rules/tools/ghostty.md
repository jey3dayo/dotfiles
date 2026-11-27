---
paths:
  - "ghostty/**/*"
  - "docs/tools/ghostty.md"
source: docs/tools/ghostty.md
references: karabiner/karabiner.json
---

# Ghostty Rules

Purpose: Ghostty ターミナル設定と `ctrl+b` リーダーキーの制約を維持する。
Detailed Reference: [docs/tools/ghostty.md](../../../docs/tools/ghostty.md)

## 要約と制約

- すべての設定は `ghostty/config` で一元管理する。キーバインド一覧は `docs/tools/ghostty.md` を正本とし、ここには再掲しない。
- リーダーキーは `ctrl+b` とする。Ghostty 内で動作する `herdr` が `ctrl+x`（およびリサイズモードに `alt+r`）を使うため、変更時は `~/.config/herdr/config.toml` の `keys.prefix` と重複しないことを確認する。
- シーケンス構文は `keybind = ctrl+b>KEY=action`。大文字キーは `L` ではなく `shift+l` と記述する（`ctrl+b>L` と `ctrl+b>l` は同一トリガー扱いで後勝ちになる）。
- 左 Option のみ Alt 扱い（`macos-option-as-alt = left`）、右 Option は文字合成用に残す。
- 編集後は `Ctrl+B` → `r`（`reload_config`）で設定を再読み込みする。
