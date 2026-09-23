---
paths:
  - "Brewfile"
  - "mise/config.*.toml"
  - "mise/entry.*.toml"
  - "docs/tools/mise.md"
---

# Tool Installation Policy

Layers and how to choose one: [docs/setup.md](../../../docs/setup.md#package-management-philosophy) (sole policy text). mise implementation details: [docs/tools/mise.md](../../../docs/tools/mise.md); Brewfile operations/cadence: [docs/tools/workflows.md](../../../docs/tools/workflows.md).

## Constraints

- Declare each tool in one layer only; two layers mean two update paths. `brew:neovim` (editor) and `npm:neovim` (Node client) are different packages, not a duplicate.
- Keep `mise` / `claude` / `codex` out of `[tools]`: a second update path conflicts with their self-update (codex's background updater ignores the install method, openai/codex#24035; Claude Code recommends its native installer). Their absence from `mise ls` is intentional.
- Do not run `mise bootstrap packages prune` for real: Brewfile exceptions are not in `[bootstrap.packages]`, so prune would remove them. `--dry-run` is fine for inspection.

## Verification

```bash
# Brewfile drift: 未取り込み and trusted 不一致 should be (なし); 未インストール is per-machine
mise run brewfile:diff

# Tools declared in both Homebrew ([bootstrap.packages] + Brewfile) and mise; expected output: neovim only
comm -12 \
  <({ grep -o '^"brew:[^"]*"' mise/config.macos.toml | sed 's/^"brew://; s/"$//'; sed -n 's/^brew "\([^"]*\)".*/\1/p' Brewfile; } | sed 's#.*/##' | sort -u) \
  <(mise ls --json | jq -r 'keys[]' | sed 's/^[a-z]*://; s#.*/##' | sort -u)
```

Moving a tool from Homebrew to mise is a migration, not a cleanup: first check `git log -S <name>` for why it is there. Then add it to `[tools]`, `mise install <tool>`, confirm `mise which <tool>`, remove its `"brew:<tool>"` entry (or Brewfile line), `brew uninstall <tool>`, then `mise run ci`.
