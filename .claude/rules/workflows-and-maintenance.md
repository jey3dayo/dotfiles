---
paths: docs/tools/workflows.md, .github/workflows/**/*.yml, .github/PULL_REQUEST_TEMPLATE.md, .mise.toml, mise/config.toml, Brewfile, Brewfile.lock.json
source: docs/tools/workflows.md
---

# Workflows and Maintenance

Purpose: 定期メンテナンスとトラブルシューティングのクイックリファレンス。
Detailed Reference: [docs/tools/workflows.md](../../docs/tools/workflows.md)

## Core rules

- Weekly, monthly, and quarterly maintenance details live only in `docs/tools/workflows.md`.
- Keep this rule focused on routing and decision criteria; do not duplicate operational tables here.
- Put runtime and generic CLI tools under mise. Brewfile holds casks, MAS apps, VS Code extensions, and formula exceptions; other Homebrew formulae go in `[bootstrap.packages]` (see `.claude/rules/tools/tool-install-policy.md`).
- Route leftover Nix store cleanup to the Nix Runtime Cleanup section in [docs/tools/workflows.md](../../docs/tools/workflows.md).

## Troubleshooting Routing

- Startup performance issues: `docs/tools/workflows.md` (Troubleshooting Routing), then `docs/tools/zsh.md` / `docs/tools/nvim.md` for baselines
- Zsh, LSP, Git auth, and maintenance troubleshooting: `docs/tools/workflows.md`
- Tool-specific issues: the corresponding `docs/tools/*.md`
