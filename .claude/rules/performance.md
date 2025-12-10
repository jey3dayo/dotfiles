---
paths:
  - "docs/performance.md"
  - "docs/tools/nvim.md"
  - "docs/tools/zsh.md"
  - "docs/tools/wezterm.md"
  - "zsh/**"
  - "nvim/**"
  - "wezterm/**"
  - "alacritty/**"
  - "tmux/**"
---

# Performance Rules

Purpose: single source for performance targets, measurement commands, and troubleshooting. Scope: Zsh, Neovim, WezTerm startup, monitoring tools, and optimization phases.
Sources: docs/performance.md.

## Targets
- Current baselines: Zsh ~1.1s, Neovim <100ms, WezTerm ~800ms on M3 MacBook Pro.
- Goals: Zsh <100ms (phased plan), Neovim <200ms (met), WezTerm <1s (met); mid-term memory goal <20MB for shells.

## Measurement
- Zsh quick check: `time zsh -lic exit`; use `zsh-help` and `zsh-help tools` for status.
- Neovim: `nvim --startuptime startup.log`, `:Lazy profile`, `:LspInfo`, `:checkhealth`.
- System: `btop`, `htop`, `top`; optional script logs in ~/.config/scripts/performance-monitor.sh.
- Record all benchmark results and history updates in docs/performance.md only.

## Optimization playbook
- Zsh: maintain 6-stage plugin loading; keep mise shims highest in PATH; use compinit rebuild every 24h and on completion updates; consider instant prompt, static bundle, deferred command triggers for further -500ms.
- Neovim: keep lazy.nvim defaults lazy=true; disable providers (python/ruby) and Treesitter for files >2MB; ensure Mason manages LSP servers.
- PATH hygiene: `typeset -gaU path` to dedupe; rebuild on login in .zprofile.

## Troubleshooting
- Sudden startup increase: check plugin changes, remove zcompdump cache and restart; for Neovim, clear ~/.local/share/nvim and ~/.local/state/nvim before reinstall.
- Memory growth: inspect with ps/ top; trim history size, remove unused plugins, clear caches.
- Benchmark comparison notes stay in docs/performance.md; do not duplicate tables elsewhere.

## Review cadence
- Monthly performance review tied to maintenance tasks; log deltas and any tuning steps in docs/performance.md.
