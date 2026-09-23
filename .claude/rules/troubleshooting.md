---
paths:
  - ".claude/**/*"
---

# Troubleshooting: Claude Code Rules

## よくある問題

### スキルが配布されない

症状: `~/.claude/skills/` が空、または古い

原因: Agent Skills の配布は `~/.apm`（APM）が担当する。
APM 側の deploy が未実行か、catalog と配布先がずれている。

#### 確認・解決手順

```bash
cd ~/.apm && mise run deploy && mise run doctor
```

正本は `~/.apm/catalog/skills/**`。配布先（`~/.claude/skills/**`）は直接編集しない。

### dotfiles が配布されない・古い

```bash
mise dotfiles status     # applied / differs / missing を確認
mise dotfiles apply      # 再適用（冪等）
mise bootstrap status    # packages / launchd 含む全体確認
```
