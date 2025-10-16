# 🔧 Tools Configuration

**最終更新**: 2025-10-03
**対象**: 開発者
**タグ**: `category/reference`, `tool/git`, `layer/core`, `environment/macos`

Essential tools and their key configurations.

## Core Stack

### Zsh + WezTerm + Neovim

- **Zsh**: 6-tier priority loading, mise optimization
- **WezTerm**: Primary terminal with Lua configuration
- **Neovim**: AI assistance (Supermaven)

### Additional Tools

- **Tmux**: Terminal multiplexer
- **Mise**: Multi-language version management
- **FZF**: Unified search (files, repos, processes)
- **GitHub CLI**: Repository automation

## Essential Commands

```bash
# Performance & debugging
zsh-help                    # Comprehensive help system
zsh-help tools              # Check installed tools

# Git workflows (via abbreviations & widgets)
^]                         # fzf ghq repository selector
^g^g, ^g^s, ^g^a, ^g^b    # Git status/add/branch widgets

# WezTerm (Ctrl+x leader key)
Ctrl+x c                   # New tab
Ctrl+x [                   # Vim-style copy mode
Alt+hjkl                   # Pane navigation

# Version management
mise install              # Install language versions
mise use                  # Set project versions

# Package management
brew bundle               # Install/update all packages
```

## Local CI Checks

GitHub Actions CI と同等のチェックをローカルで実行可能です：

```bash
# 全てのCIチェックを実行
mise run ci

# 環境セットアップ（初回のみ）
./.claude/commands/ci-local.sh setup

# 個別チェック
mise run format:biome:check      # JavaScript/TypeScript/JSON フォーマット
mise run format:markdown:check   # Markdown フォーマット
mise run format:yaml:check       # YAML フォーマット
mise run lint:lua                # Lua linting
mise run format:lua:check        # Lua フォーマット
mise run format:shell:check      # Shell script フォーマット
```

### mise タスク一覧

```bash
# フォーマット系
mise run format:biome         # Biome auto-fix
mise run format:biome:check   # Biome check only
mise run format:markdown      # Markdown auto-fix
mise run format:markdown:check  # Markdown check only
mise run format:yaml          # YAML auto-fix
mise run format:yaml:check    # YAML check only
mise run format:lua           # Lua auto-format
mise run format:lua:check     # Lua format check
mise run format:shell         # Shell auto-format
mise run format:shell:check   # Shell format check

# リント系
mise run lint:lua             # Lua linting

# 統合
mise run ci                   # 全チェック実行
```

## Managed Tools

### Shell・Terminal

- Zsh, zsh-abbr, Starship, Alacritty, WezTerm, Tmux, SSH

### Development

- Git, GitHub CLI, Neovim, efm-langserver, mise, Homebrew, AWSume, Terraform

### Linters・Formatters

- Biome, Hadolint, shellcheck, pycodestyle, Stylua, Taplo, Yamllint, Typos

### Applications

- Btop, htop, Flipper, Karabiner, Vimium
