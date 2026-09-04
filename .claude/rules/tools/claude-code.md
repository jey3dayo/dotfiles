---
paths:
  - "~/.claude/mise.toml"
  - "~/.claude/**"
---

# Claude Code Rules

Purpose: Claude Code marketplace plugin の更新運用。Scope: `~/.claude/mise.toml` のメンテナンス task。

- marketplace の更新は `cd ~/.claude && mise run update:claude-marketplace`（`claude plugin marketplace update`）で行う。
- plugin の追加・削除は `claude plugin` CLI で行い、`~/.claude/plugins/` を直接編集しない。
- dotfiles の更新サイクルとは独立して運用する。
