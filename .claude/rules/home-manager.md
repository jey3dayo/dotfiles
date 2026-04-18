---
paths: nix/**, flake.nix, home.nix, flake.lock, agents/nix/**, docs/tools/home-manager.md
source: docs/tools/home-manager.md
---

# Home Manager Rules

Purpose: Home Manager 統合における管理方針とガイドライン。
Detailed Reference: [docs/tools/home-manager.md](../../docs/tools/home-manager.md)

## Core rules

- Manage only static files and file-level links with Home Manager. Do not link writable directories wholesale from the Nix store.
- Keep flake `inputs` static. Agent skill metadata belongs in `nix/agent-skills-sources.nix`, while `flake.nix` keeps the matching `url` and `flake` entries in sync.
- Worktree detection, agent-skills distribution flow, and source-level `homeLinks` rules live in `docs/tools/home-manager.md`; treat that document as the canonical procedure.
- Preserve `ZDOTDIR=$HOME/.config/zsh` and the repo PATH ordering conventions when touching Home Manager-managed shell setup.

## よくあるトラブル

- Skills or rules missing after switch: rerun `home-manager switch --flake ~/.config --impure`, then verify source metadata and flake input URLs match.
- `"expected a set but got a thunk"`: remove dynamic evaluation from flake `inputs`.
- Read-only or permission failures: move the affected directory back to file-level management.
- Recovery procedures belong in [docs/disaster-recovery.md](../../docs/disaster-recovery.md).
