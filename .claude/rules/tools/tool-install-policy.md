---
paths:
  - "Brewfile"
  - "mise/config.*.toml"
  - "mise/entry.*.toml"
  - "docs/tools/mise.md"
---

# Tool Installation Policy

Purpose: decide which layer owns a tool. Details: [docs/tools/mise.md](../../../docs/tools/mise.md); Brewfile operations and maintenance cadence: [docs/tools/workflows.md](../../../docs/tools/workflows.md).

## Layers

- mise `[tools]`: CLIs, language runtimes, dev tools, and `npm:` / `pipx:` / `cargo:` / `go:` packages. Declared in `mise/config.shared.toml` (all OS), `mise/config.workstation.toml` (default / Windows), and `mise/entry.*.toml` (per environment).
- mise bootstrap `[bootstrap.packages]`: macOS Homebrew formulae — system libs and native binaries, including some mise could also install (btop, cmake, neovim, podman, powershell, rust-analyzer, …). Declared in `mise/config.macos.toml` as `"brew:<name>" = "latest"`.
- Brewfile: casks, MAS apps, VS Code extensions, and formulae `[bootstrap.packages]` cannot express. Its `brew` lines are the exception list; known reasons are install args / `restart_service` and private or metadata-less taps (`pam-reattach` has none recorded).
- Self-updating standalone: `mise`, `claude`, `codex`. mise comes from its official installer (`curl https://mise.run | sh`) on Unix and from Chocolatey (`windows/chocolatey/packages.config`) on Windows. claude / codex come from their official installers, ensured by `[bootstrap.hooks.post-tools]` → `mise/lib/ensure-standalone.sh` (Windows: `Ensure-StandaloneCli` in `windows/setup.ps1`).

## Choosing a layer

1. GUI app, MAS app, or VS Code extension → Brewfile.
2. Ships its own installer and self-update command and should track latest → standalone.
3. New cross-platform CLI available through mise (registry or a package backend) → `[tools]`.
4. System library or macOS native binary → `[bootstrap.packages]`; add a Brewfile `brew` line only when `[bootstrap.packages]` cannot express it (install args, service restart, tap without API metadata).

Runtimes go through mise. Keep a Homebrew-installed runtime only when a formula depends on it (`brew uses --installed <name>`).

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
