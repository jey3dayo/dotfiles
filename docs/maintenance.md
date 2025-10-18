# 🔧 Maintenance Guide

**最終更新**: 2025-10-17
**対象**: 開発者
**タグ**: `category/maintenance`, `category/guide`, `layer/support`, `audience/developer`

定期メンテナンス、トラブルシューティング、パフォーマンス監視のガイドです。

## 定期メンテナンス

### Weekly Tasks

```bash
# パッケージ更新
brew update && brew upgrade

# プラグイン更新
sheldon update                                                    # Zsh
nvim --headless -c 'lua require("lazy").sync()' -c 'q'          # Neovim
~/.tmux/plugins/tmp/bin/update_plugins all                       # Tmux
```

### Monthly Tasks

- パフォーマンス測定 (`zsh-benchmark`)
- 設定レビュー（未使用設定・プラグインの削除検討）
- ログファイルのクリーンアップ

### Quarterly Tasks

- 設定監査（全設定ファイルの整合性確認）
- 依存関係整理（不要な依存関係の削除）
- バックアップ検証

## パフォーマンス監視

```bash
# 設定確認
zsh-help                   # 総合ヘルプシステム
zsh-help tools             # インストール済みツール確認

# Zsh 起動時間測定
time zsh -lic exit

# プラグイン統計・クリーンアップ
nvim --headless -c 'lua require("lazy").profile()' -c 'q'
nvim --headless -c 'lua require("lazy").clean()' -c 'q'

# 詳細なパフォーマンス分析
# 詳細は docs/performance.md を参照
```

## トラブルシューティング

### 起動時間の突然の増加

**診断手順:**

1. `time zsh -lic exit` で現在の起動時間測定
2. `zsh-help tools` でツール状態確認
3. 最近の設定変更内容確認
4. プラグインの個別無効化テスト

### LSPサーバーエラー

**診断手順:**

1. `:LspInfo` でサーバー状態確認
2. `:Mason` でサーバーインストール状況確認
3. ログ確認: `~/.local/share/nvim/lsp.log`

**解決方法:**

- サーバーの再インストール
- Node.js/Python環境の確認

### Git認証エラー

**診断手順:**

1. SSH鍵確認: `ssh -T git@github.com`
2. 1Password CLI連携状況確認
3. SSH agent状態確認

## デバッグツール

```bash
# 環境変数・コマンドパス確認
env | grep -E "(SHELL|TERM|PATH|CONFIG)"
which command_name
type command_name

# 設定ファイル構文チェック
zsh -n config_file.zsh

# ログ確認
tail -f ~/.local/share/nvim/lsp.log
tail -f ~/.config/zsh/performance.log

# プロセス・メモリ監視
top -pid $(pgrep zsh)
ps aux | grep -E "(zsh|nvim|tmux)"
```

## 緊急時対応

```bash
# 設定破綻時の復旧
zsh --no-rcs                                    # 最小構成での起動

# 依存関係の再構築
brew bundle --force
mise install node@latest && npm install -g @fsouza/prettierd
mise install python@latest && pip install -r requirements.txt

# バックアップからの復元
cp ~/.config/zsh/backup/zshrc ~/.zshrc
```

## メンテナンス自動化

```bash
#!/bin/zsh
# ~/.config/scripts/maintenance.sh

# パフォーマンス測定ログ
echo "$(date): $(time zsh -lic exit 2>&1)" >> ~/.config/zsh/performance.log

# プラグイン更新
sheldon update
nvim --headless -c 'lua require("lazy").sync()' -c 'q'

# 不要ファイル削除
find ~/.config -name "*.tmp" -delete
find ~/.cache -name "*.old" -delete

# 設定バックアップ
mkdir -p ~/.config/zsh/backup
cp ~/.zshrc ~/.config/zsh/backup/zshrc.$(date +%Y%m%d)
```
