# Zsh Configuration

Minimal Zsh startup optimized for fast interactive shells.

- Environment and `.env.local`: `zsh/.zshenv`
- PATH: `zsh/lib/path.zsh`
- Interactive startup: `zsh/.zshrc`
- Sheldon cache refresh: `zsh/bin/zsh-sheldon-refresh`
- Startup benchmark: `zsh/bin/zsh-benchmark`
- History search: `atuin` on `Ctrl-R`, `Ctrl-P/N` prefix history search
- FZF shell cache: `zsh/bin/zsh-fzf-refresh`
- GitHub CLI completion cache: `zsh/bin/zsh-gh-completion-refresh`
- Navigation: `zoxide` with `z` and `j`
- Completions: `ni` / `nlx`, `eza`, and `bun`

Sheldon sources `zsh-abbr` and fetches completion repositories. Run `zsh-sheldon-refresh` after changing `zsh/sheldon/plugins.toml`.
