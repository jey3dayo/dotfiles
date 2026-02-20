---
paths: zsh/**/*, docs/tools/zsh.md
source: docs/tools/zsh.md
references: docs/performance.md
---

# Zsh Rules

Purpose: preserve the fast, modular Zsh setup. Scope: load order, PATH policy, plugin tiers, caching, and maintenance hooks.

**Detailed Reference**: See [docs/tools/zsh.md](../../docs/tools/zsh.md) for comprehensive implementation guide, examples, and troubleshooting.

## Load order and directories

- ZDOTDIR is ~/.config/zsh; login and non-login share the same config.
- Startup sequence: .zshenv (XDG and minimal PATH with mise shims) -> .zprofile (locale, dedupe path/cdpath/fpath, rebuild PATH order) -> .zshrc (history/options then init/_for compinit and Sheldon cache) -> sources/_ -> config/loader.zsh (core -> tools -> functions -> os) -> lazy-sources/\*.zsh (deferred).
- Respect directory roles: config/tools/_for tool configs, config/os/_ for platform overrides, completions/ for bundled completion.

## PATH and environment

- PATH priority: mise shims > $HOME/{bin,.local/bin} > language tools (deno/cargo/go/pnpm) > Android SDK > Homebrew > system.
- Use `typeset -gaU path` to dedupe; rebuild full PATH in .zprofile. Minimal PATH stays in .zshenv for non-login shells.

## Plugins and caching

- Maintain 6-stage loading via Sheldon with zsh-defer; compinit rebuilds every 24h or on completion changes and prunes zcompdump older than 7 days.
- Sheldon cache regenerates when plugins.toml changes; zsh-defer is used for slower tools (brew/gh/debug) at staged delays.
- Keep mise shims re-promoted to the front after Sheldon load.

## Operations

- Health checks: `zsh-help`, `zsh-help tools`, `path-check`, `zsh-quick-check`, `mise-status`.
- Troubleshooting: delete zcompdump files then `exec zsh`; use `zsh -df` for minimal startup; `zprof` when `ZSH_DEBUG=1` to profile.
- Key bindings and FZF widgets are sourced from docs/tools/fzf-integration.md; do not duplicate bindings elsewhere.

## Customization rules

- Add new tool configs under config/tools/\*.zsh and load via config/loader.zsh; prefer deferred loading for non-essential tools.
- OS-specific changes belong in config/os/\*.zsh and should auto-detect platform.

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
