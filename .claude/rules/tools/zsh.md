# Zsh Rules

Purpose: preserve the fast, modular Zsh setup. Scope: load order, PATH policy, plugin tiers, caching, and maintenance hooks.
Sources: docs/tools/zsh.md, docs/performance.md.

## Load order and directories
- ZDOTDIR is ~/.config/zsh; login and non-login share the same config.
- Startup sequence: .zshenv (XDG and minimal PATH with mise shims) -> .zprofile (locale, dedupe path/cdpath/fpath, rebuild PATH order) -> .zshrc (history/options then init/* for compinit and Sheldon cache) -> sources/* -> config/loader.zsh (core -> tools -> functions -> os) -> lazy-sources/*.zsh (deferred).
- Respect directory roles: config/tools/* for tool configs, config/os/* for platform overrides, completions/ for bundled completion.

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
- Add new tool configs under config/tools/*.zsh and load via config/loader.zsh; prefer deferred loading for non-essential tools.
- OS-specific changes belong in config/os/*.zsh and should auto-detect platform.
