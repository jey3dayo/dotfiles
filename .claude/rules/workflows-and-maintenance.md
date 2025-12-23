---
paths: docs/maintenance.md, docs/performance.md, .github/workflows/**/*.yml, .github/PULL_REQUEST_TEMPLATE.md, .claude/commands/**/*.sh, .mise.toml, mise/config.toml, Brewfile, Brewfile.lock.json
---

# Workflows and Maintenance

Purpose: keep recurring operations and troubleshooting guardrails concise. Scope: maintenance cadences, Brewfile management, and where to log performance findings.
Sources: docs/maintenance.md.

## Cadence

- Weekly: `brew update && brew upgrade`; refresh plugins (`sheldon update`, `nvim --headless -c 'lua require("lazy").sync()' -c q`, tmux plugin updater).
- Monthly: run zsh benchmarks and review config for unused items; clean logs; record metrics in docs/performance.md.
- Quarterly: full settings audit, dependency pruning, and backup verification.

## Troubleshooting routing

- Performance regressions: follow docs/performance.md troubleshooting; log measurements there.
- Zsh recovery: `rm -rf ~/.zcompdump*` then `exec zsh`; use `zsh -df` for minimal startup.
- LSP issues: `:LspInfo`, `:Mason`, check `~/.local/share/nvim/lsp.log`; reinstall servers if needed.
- Git auth: `ssh -T git@github.com`, confirm 1Password CLI and SSH agent status.

## Debug commands

- Env checks: `env | grep -E "(SHELL|TERM|PATH|CONFIG)"`, `which`, `type`.
- Logs: `tail -f ~/.local/share/nvim/lsp.log`, `tail -f ~/.config/zsh/performance.log`.
- Process watch: `top -pid $(pgrep zsh)`, `ps aux | grep -E "(zsh|nvim|tmux)"`.

## Automation and scripts

- Maintenance script pattern: log zsh startup time, update plugins, clear temporary files, back up key configs (see sample in docs/maintenance.md).
- Keep backups under ~/.config/zsh/backup with dated filenames.

## Brewfile management

- Maintain 20-section layout (taps, core libs, build tools, dev tools, languages, shell/terminal, CLI, monitoring, devops/cloud, databases, security/network, linters, package mgmt, documentation, lang build tools, specialized, casks, fonts, MAS, VSCode, Go packages).
- Special cases: `node` link:false (managed by mise), `mysql` restart_service:changed, `utf8proc` args:["HEAD"], `postgresql@14` pinned.
- Workflow for adding packages: install, `brew bundle dump --force --file=/tmp/brewfile-new.txt`, diff against Brewfile, insert alphabetically within the right section, then `brew bundle check` and `brew bundle install --no-upgrade` to validate.
- Monthly regeneration: backup current, dump to temp, review diffs, run checks, and test install with `--no-upgrade --verbose`.

## Backups and recovery

- For Brewfile changes, keep dated backups before large edits.
- Emergency shell recovery: `zsh --no-rcs` to bypass config; reinstall dependencies via `brew bundle --force` and `mise install ...` when required.
