---
paths: docs/performance.md, docs/tools/workflows.md, .github/workflows/**/*.yml, .github/PULL_REQUEST_TEMPLATE.md, .claude/commands/**/*.sh, .mise.toml, mise/config.toml, Brewfile, Brewfile.lock.json
source: docs/tools/workflows.md
---

# Workflows and Maintenance

Purpose: 定期メンテナンスとトラブルシューティングのクイックリファレンス。
Detailed Reference: [docs/tools/workflows.md](../../docs/tools/workflows.md)

## Maintenance Cadence

| 頻度   | 作業                                                           |
| ------ | -------------------------------------------------------------- |
| 週次   | `brew update && brew upgrade` + `mise upgrade`; プラグイン更新 |
| 月次   | zsh ベンチマーク・ログ整理・`mise prune`・Nix GC               |
| 四半期 | 全設定監査・依存関係プルーニング・バックアップ検証             |

## Code Quality コマンド

```bash
mise run ci           # 検証のみ（format + lint + test）
mise run ci:quick     # クイックチェック（format + lint）
mise run format       # 自動フォーマット適用
```

## Brewfile 更新

```bash
brew bundle dump --force --file=/tmp/brewfile-new.txt
diff Brewfile /tmp/brewfile-new.txt
brew bundle check
```

- ランタイム・汎用 CLI は mise へ（biome, prettier, stylua 等は Brewfile に追加しない）
- GUI・macOS 固有のみ Brewfile へ

## Nix Home Manager 月次クリーンアップ

```bash
home-manager remove-generations 90d && nix-collect-garbage -d
df -h /nix/store
```

詳細は `.claude/rules/nix-maintenance.md` を参照。

## Troubleshooting Routing

| 症状               | 対応先                                                    |
| ------------------ | --------------------------------------------------------- |
| パフォーマンス低下 | `docs/performance.md`                                     |
| Zsh トラブル       | `rm -rf ~/.zcompdump*` → `exec zsh`; `zsh -df` でミニマル |
| LSP 問題           | `:LspInfo`, `:Mason`, `~/.local/share/nvim/lsp.log`       |
| Git 認証           | `ssh -T git@github.com`, 1Password CLI・SSH agent 確認    |

詳細は [docs/tools/workflows.md](../../docs/tools/workflows.md) を参照。
