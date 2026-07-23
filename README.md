# Personal Dotfiles

最終更新: 2026-04-20
対象: 開発者
タグ: `category/setup`, `layer/core`, `environment/cross-platform`, `audience/developer`

High-performance development environment tuned for speed, consistency, and developer experience. Managed with mise bootstrap for declarative configuration.

## Highlights

- Declarative Configuration: mise bootstrap-based deployment with per-OS config selection (CI/Pi/Default)
- Performance-first dotfiles with local CI parity (`mise run ci`) before merges
- Documentation centralized in `docs/` with navigation at `docs/README.md`
- LLM/AI entrypoint available at `llms.md`, with project rules rooted in `AGENTS.md`
- Modular stack: Zsh (6-tier), Neovim (Lazy.nvim), WezTerm (tmux-style) with FZF-backed Git widgets
- Versioning via Mise + Homebrew; AI/CLI helpers documented in `CLAUDE.md` and `.claude/`

## Documentation Map

- Navigation: `docs/README.md`
- LLM/AI entrypoint: `llms.md`
- Setup (SST): `docs/setup.md`
- Performance metrics/history: `docs/performance.md`
- Maintenance cadence & troubleshooting: `docs/tools/workflows.md`
- Documentation governance: `docs/documentation.md`
- Tool inventory: `TOOLS.md`

## Getting Started

### Prerequisites

- `git`
- `zsh`
- `curl`
- `Homebrew` (macOS) or your system package manager
- `mise` (installed via `brew bundle` in this repo for macOS)

セットアップの本体は `mise bootstrap`。fresh macOS のみ、前準備として `scripts/bootstrap.sh` が Homebrew を導入します。

Linux/WSL2 package installs (examples):

```bash
# Ubuntu/Debian
sudo apt update && sudo apt install -y git zsh curl

# Fedora
sudo dnf install -y git zsh curl

# Arch
sudo pacman -S --noconfirm git zsh curl
```

Install mise on Linux/WSL2 via the official installer (`curl https://mise.run | sh`); macOS gets it from `brew bundle`.

### Quick Setup (macOS/Linux/WSL2)

```bash
# 1. Clone repository
git clone https://github.com/jey3dayo/dotfiles ~/.config
cd ~/.config

# 2. Bootstrap (installs Homebrew if needed on macOS)
sh ./scripts/bootstrap.sh   # macOS only

# 3. Configure Git identity (required)
cat > ~/.gitconfig_local << EOF
[user]
    name = Your Name
    email = your.email@example.com
EOF

# 4. Install system packages
brew bundle                      # macOS
# curl https://mise.run | sh     # Linux/WSL2（mise 未導入の場合）

# 5. Converge the machine with mise bootstrap
#    packages → dotfiles → launchd(macOS) → tools → bootstrap task の順に冪等収束
export MISE_CONFIG_FILE="$HOME/.config/mise/config.default.toml"  # 初回のみ明示（~/.zshenv 配布後は自動）
export MISE_ENV=macos  # macOS のみ。config.macos.toml（brew packages / LaunchAgents）を読み込む
mise trust && mise bootstrap --yes

# 6. Restart shell
exec zsh

# 7. Verify installation
mise bootstrap status --missing   # 全宣言部が収束していれば exit 0
zsh-help
mise doctor
```

差分だけ見たいときは `mise bootstrap --dry-run`、dotfiles のみは `mise dotfiles apply` / `mise dotfiles status`。

### What mise bootstrap does

- ✅ `[bootstrap.packages]` → brew パッケージ、`[dotfiles]` → HOME エントリポイント配布
- ✅ `[bootstrap.macos.launchd.agents]` → LaunchAgents、`[tools]` → 全開発ツール
- ✅ 冪等: 収束済みの項目はスキップ。`--dry-run` で差分プレビュー

`scripts/bootstrap.sh` は fresh macOS 向けの Homebrew 導入だけを担う前準備スクリプトです。

### What Changed (mise bootstrap Migration)

- ✅ **Declarative Configuration**: dotfiles / LaunchAgents / packages converge via `mise bootstrap`
- ✅ **Automatic Environment Detection**: OS 別 config（default / pi / windows）を `MISE_CONFIG_FILE` で選択
- ✅ **No More Home Manager**: Nix flake は撤去済み。`mise dotfiles status` で配布状態を確認
- ✅ **Idempotent**: 再実行しても収束済みの項目はスキップされる

### Manual Setup (Already Have Homebrew)

If Homebrew is already installed, skip bootstrap and follow docs/setup.md directly.

📚 **Detailed documentation**: See `docs/setup.md` for troubleshooting and environment notes.

## Quality & CI

- Local gate: `mise run ci` (GitHub Actions equivalent)
- Formatting bundle: `mise run format` (Markdown/JS/TOML/YAML/Lua/Shell)
- Lint bundle: `mise run lint`
- Documentation rules: `docs/documentation.md`

## Core Stack

- Zsh + Sheldon: 6-tier priority loading with mise-aware PATH optimization and 50+ Git abbreviations/widgets
- Neovim + Lazy.nvim: AI assistance (Supermaven) with LSP-heavy yet fast startup
- WezTerm: Primary terminal with Lua config and tmux-style workflow; Alacritty as GPU-accelerated alternative
- Git + FZF: Widgets and fuzzy pickers for repo/status/add flows
- Versioning: Mise for language runtimes; Homebrew for system packages

## Architecture

```
dotfiles/
├── mise/          # mise config（[tools] / [dotfiles] / [bootstrap.*] / tasks）
├── .claude/       # AI assistance, commands, review criteria
├── .github/       # Workflows
├── docs/          # Human-facing documentation (SST per topic)
├── bin/           # User-facing commands on PATH
├── scripts/       # Setup and task helper scripts
│   └── bootstrap.sh  # Homebrew installer (1-shot)
├── zsh/           # Shell (6-tier loading)
├── nvim/          # Editor (Lua config, 15+ LSP)
├── git/           # Version control (widgets, abbreviations)
├── wezterm/       # Terminal (Lua config, tmux-style)
├── alacritty/     # Alternative terminal (GPU-accelerated)
├── tmux/          # Session management
└── Brewfile       # Package management (Homebrew)
```

## Shortcuts & Commands

```bash
# Shell help
zsh-help                   # Interactive help system
zsh-help keybinds          # Key bindings reference
zsh-help aliases           # Aliases reference

# Git workflow (FZF-backed widgets; see docs/tools/fzf-integration.md)
Ctrl+]                     # FZF repository selector
Ctrl+g Ctrl+g              # Git diff widget
Ctrl+g Ctrl+s              # Git status widget
Ctrl+g Ctrl+a              # Git add widget
Ctrl+g Ctrl+b / Ctrl+g s   # Git branch switcher (fzf-git powered)
Ctrl+g Ctrl+w              # Git worktree manager (fzf-git powered)
Ctrl+g Ctrl+z              # fzf-git stash picker
Ctrl+g Ctrl+f              # fzf-git file picker

# WezTerm (Ctrl+x leader key)
Ctrl+x c                   # New tab
Ctrl+x [                   # Vim-style copy mode
Alt+hjkl                   # Pane navigation

# Package management
brew bundle                # Install all packages
mise install               # Setup language versions
```

## Maintenance

- Operational cadence and troubleshooting live in `docs/tools/workflows.md`
- Weekly: `brew update && brew upgrade`, sync plugins (Sheldon/Neovim/tmux)
- Monthly: `mise bootstrap --yes` で収束確認, measure shell startup, prune unused plugins
- 配布状態の確認: `mise bootstrap status` / `mise dotfiles status`
- Always before merge: `mise run ci`

---

Status: Production-ready (2026-02-07)
License: MIT — optimized for modern development workflows with focus on speed, consistency, and developer experience.
