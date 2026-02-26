# 🛠️ Tools Inventory

このリポジトリで管理しているツール・アプリケーション設定の一覧です。

詳細な技術情報は [Technology Stack](.kiro/steering/tech.md) を、ツール別の実装ガイドは [docs/tools/](./docs/tools/) を参照してください。

## 📋 管理対象ツール

### Shell & Terminal

| Tool        | Config Location | Documentation                       |
| ----------- | --------------- | ----------------------------------- |
| **Zsh**     | `zsh/`          | [詳細ガイド](docs/tools/zsh.md)     |
| zsh-abbr    | `zsh-abbr/`     | -                                   |
| Starship    | `starship.toml` | -                                   |
| **WezTerm** | `wezterm/`      | [詳細ガイド](docs/tools/wezterm.md) |
| Alacritty   | `alacritty/`    | -                                   |
| Tmux        | `tmux/`         | -                                   |
| **SSH**     | `ssh/`          | [詳細ガイド](docs/tools/ssh.md)     |

### Development

| Tool           | Config Location   | Documentation                            |
| -------------- | ----------------- | ---------------------------------------- |
| **Git**        | `git/`            | [FZF統合](docs/tools/fzf-integration.md) |
| GitHub CLI     | `gh/`             | -                                        |
| **Neovim**     | `nvim/`           | [詳細ガイド](docs/tools/nvim.md)         |
| efm-langserver | `efm-langserver/` | -                                        |
| **Mise**       | `mise.toml`       | -                                        |
| Homebrew       | `Brewfile`        | -                                        |
| AWSume         | `awsume/`         | -                                        |
| Terraform      | (via Homebrew)    | -                                        |

### Linters & Formatters

| Tool        | Config Location |
| ----------- | --------------- |
| Biome       | `biome.json`    |
| Hadolint    | `hadolint.yaml` |
| shellcheck  | `shellcheckrc`  |
| pycodestyle | `pycodestyle`   |
| Stylua      | `stylua.toml`   |
| Taplo       | `taplo.toml`    |
| Yamllint    | `yamllint/`     |
| Typos       | `typos.toml`    |

### Applications

| Tool      | Config Location       |
| --------- | --------------------- |
| Btop      | `btop/`               |
| htop      | `htop/`               |
| Flipper   | `flipper/`            |
| Karabiner | `karabiner/`          |
| Vimium    | `vimium-options.json` |

## 📚 関連ドキュメント

### プロジェクト情報

- [Product Overview](.kiro/steering/product.md) - プロダクト概要、価値提案
- [Technology Stack](.kiro/steering/tech.md) - 技術スタック詳細、コマンド
- [Project Structure](.kiro/steering/structure.md) - ディレクトリ構造、パターン

### 実装ガイド

- [Documentation Index](docs/README.md) - 全ドキュメント体系
- [Setup Guide](docs/setup.md) - セットアップ手順
- [Performance](docs/performance.md) - パフォーマンス測定
- [Maintenance](.claude/rules/workflows-and-maintenance.md) - メンテナンス手順
- [Tool Install Policy](.claude/rules/tools/tool-install-policy.md) - HM/mise/Homebrew責務分離

### ツール別詳細

- [Zsh](docs/tools/zsh.md) - Shell最適化、パフォーマンス
- [Neovim](docs/tools/nvim.md) - エディタ設定、LSP、AI統合
- [WezTerm](docs/tools/wezterm.md) - ターミナル設定、キーバインド
- [SSH](docs/tools/ssh.md) - SSH階層設定、セキュリティ
- [FZF Integration](docs/tools/fzf-integration.md) - Git/Zsh統合ワークフロー

---

_このドキュメントはツールインベントリです。技術的詳細は steering documents および docs/ を参照してください。_
