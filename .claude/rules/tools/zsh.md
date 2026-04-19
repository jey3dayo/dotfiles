---
paths: zsh/**/*, docs/tools/zsh.md
source: docs/tools/zsh.md
references: docs/performance.md
---

# Zsh Rules

Purpose: preserve the fast, modular Zsh setup. Scope: load order, PATH policy, plugin tiers, caching, and maintenance hooks.

Detailed Reference: See [docs/tools/zsh.md](../../docs/tools/zsh.md) for comprehensive implementation guide, examples, and troubleshooting.

## Core rules

- ZDOTDIR is ~/.config/zsh; login and non-login share the same config.
- Preserve the startup contract: `.zshenv` for XDG and minimal PATH, `.zprofile` for dedupe and full PATH rebuild, `.zshrc` for shell options and init scripts, then `config/loader.zsh` for `core -> tools -> functions -> os`, with `lazy-sources/*.zsh` deferred.
- PATH priority stays `mise shims -> $HOME/{bin,.local/bin} -> language tools -> Android SDK -> Homebrew -> system`. Use `typeset -gaU path` and rebuild in `.zprofile`.
- Keep Sheldon + zsh-defer as the loading model. Rebuild `compinit` on completion changes / 24h cadence, prune stale `zcompdump`, and keep mise shims re-promoted after Sheldon loads.
- Add tool config under `config/tools/*.zsh`, OS-specific changes under `config/os/*.zsh`, and bundled completions under `completions/`. Prefer deferred loading for non-essential tools.
- Health and troubleshooting should route through `zsh-help`, `zsh-help tools`, `path-check`, `zsh-quick-check`, `mise-status`, `zsh -df`, and `zprof` with `ZSH_DEBUG=1`.
- FZF and Git key bindings are documented in `docs/tools/fzf-integration.md`; do not duplicate them in rule files.

## Glob qualifiers

`.zsh` files are processed by **beautysh + `zsh -n`** only. shfmt and shellcheck are excluded (see `.pre-commit-config.yaml` and `mise/tasks/`). Zsh-specific glob qualifiers are fully supported.

Use glob qualifiers to write safe, idiomatic zsh:

```zsh
# Null glob: no error if no matches
for f in "$dir"/*.zsh(N); do ...

# Null glob + plain files only (no symlinks, no dirs)
for f in "$dir"/*.zsh(N.); do ...

# Null glob + dirs only
for d in "$dir"/*/(N); do ...
```

Do **not** use `setopt null_glob` workarounds — `(N)` in the glob itself is the idiomatic zsh way.

Do **not** add `# shellcheck shell=bash` to `.zsh` files; shellcheck does not run on them.
