---
paths: docs/performance.md, docs/tools/workflows.md, .github/workflows/**/*.yml, .github/PULL_REQUEST_TEMPLATE.md, .claude/commands/**/*.sh, .mise.toml, mise/config.toml, Brewfile, Brewfile.lock.json
source: docs/tools/workflows.md
---

# Workflows and Maintenance

Purpose: 定期メンテナンスとトラブルシューティングのクイックリファレンス。
Detailed Reference: [docs/tools/workflows.md](../../docs/tools/workflows.md)

## Core rules

- Weekly, monthly, and quarterly maintenance details live only in `docs/tools/workflows.md`.
- Keep this rule focused on routing and decision criteria; do not duplicate operational tables here.
- Put runtime and generic CLI tools under mise. Reserve Brewfile for GUI apps and macOS-specific packages.
- Route Nix cleanup details to [docs/tools/nix.md](../../docs/tools/nix.md).

## Troubleshooting Routing

- Performance issues: `docs/performance.md`
- Zsh, LSP, Git auth, and maintenance troubleshooting: `docs/tools/workflows.md`
- Tool-specific issues: the corresponding `docs/tools/*.md`
