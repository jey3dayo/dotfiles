# Maintenance Guide

dotfiles環境のメンテナンス、改善履歴、トラブルシューティングに関する包括的なガイドです。

## 🔄 定期メンテナンス

### Weekly Tasks

```bash
# パッケージ更新
brew update && brew upgrade

# プラグイン更新
# Zsh (Sheldon)
sheldon update

# Neovim (lazy.nvim)
nvim --headless -c 'lua require("lazy").sync()' -c 'q'

# Tmux plugins
~/.tmux/plugins/tpm/bin/update_plugins all
```

### Monthly Tasks

- **プラグイン更新**: 各種プラグインの最新版への更新
- **パフォーマンス測定**: 起動時間、レスポンス時間の測定
- **設定レビュー**: 未使用設定・プラグインの削除検討

### Quarterly Tasks

- **設定監査**: 全設定ファイルの整合性確認
- **依存関係整理**: 不要な依存関係の削除
- **バックアップ検証**: 設定バックアップの動作確認

## 📊 パフォーマンス監視

### 起動時間追跡

```bash
# Zsh起動時間測定
zsh-benchmark

# 詳細プロファイリング
zsh-profile

# 履歴データ収集
echo "$(date): $(zsh-benchmark)" >> ~/.config/zsh/performance.log
```

### プラグイン使用状況分析

```bash
# Neovimプラグイン統計
nvim --headless -c 'lua require("lazy").profile()' -c 'q'

# 未使用プラグイン検出
nvim --headless -c 'lua require("lazy").clean()' -c 'q'
```

### パフォーマンス回帰検出

```bash
# 設定変更前後の比較
zsh-benchmark > before.log
# 設定変更実行
zsh-benchmark > after.log
diff before.log after.log
```

## 📚 改善履歴

### 2025-06-09: Zsh パフォーマンス最適化

**問題**: 起動時間2秒超で開発体験悪化

**解決策**:

- Sheldon 6段階読み込み順序の実装
- mise超遅延読み込み（39.88ms削減）
- 全設定ファイルのコンパイル化

**成果**: 1.7s → 1.2s（30%改善）

### 2025-06-08: Neovim 大規模リファクタリング

**問題**: 設定散在、依存関係複雑化

**解決策**:

- Lua設定への完全移行
- lazy.nvim最適化
- LSPモジュール化

**成果**: 起動時間100ms以下、15言語LSP対応

### 2025-06-07: Git統合強化

**問題**: Git操作の煩雑さ、非効率フロー

**解決策**:

- Zsh略語展開システム
- FZF統合による高速選択
- ghqによるリポジトリ管理統合

**成果**: Git操作時間50%短縮

### 2025-06-06: WezTerm最適化

**問題**: ターミナル起動時間とレスポンス性能

**解決策**:

- GPU加速（WebGpu）有効化
- モジュラー設定の実装
- 不要アニメーション無効化

**成果**: 起動時間800ms（35%改善）

## 🛠️ トラブルシューティング

### 起動時間の突然の増加

**診断手順**:

1. `zsh-benchmark`で現在の起動時間測定
2. `zsh-profile`で詳細プロファイリング
3. 最近の設定変更内容確認
4. プラグインの個別無効化テスト

**よくある原因**:

- 新規プラグインの追加
- 重い処理の同期実行
- 設定ファイルの構文エラー

### LSPサーバーエラー

**診断手順**:

1. `:LspInfo`でサーバー状態確認
2. `:Mason`でサーバーインストール状況確認
3. ログファイル確認（`~/.local/share/nvim/lsp.log`）

**よくある解決法**:

- サーバーの再インストール
- 設定ファイルの構文確認
- Node.js/Python環境の確認

### Git認証エラー

**診断手順**:

1. SSH鍵の確認（`ssh -T git@github.com`）
2. 1Password CLI連携状況確認
3. SSH agent状態確認

**よくある解決法**:

- SSH鍵の再生成
- 1Password CLI再認証
- SSH agent再起動

### プラグイン競合

**診断手順**:

1. 最小構成での起動テスト
2. プラグインの段階的有効化
3. 設定ファイルの依存関係確認

**実例**: zsh-vi-mode競合

- **症状**: 1分の起動遅延、エイリアス無効化
- **原因**: キーバインド変更による他プラグインとの競合
- **解決**: 競合プラグインの削除、読み込み順序調整

## 🔍 デバッグツール

### 設定診断

```bash
# 環境変数確認
env | grep -E "(SHELL|TERM|PATH|HOME|CONFIG)"

# コマンドパス確認
which command_name
type command_name

# 設定ファイル構文チェック
zsh -n config_file.zsh
```

### ログ確認

```bash
# システムログ
tail -f /var/log/system.log

# アプリケーションログ
tail -f ~/.local/share/nvim/lsp.log

# カスタムログ
tail -f ~/.config/zsh/performance.log
```

### パフォーマンス分析

```bash
# プロセス監視
top -pid $(pgrep zsh)

# メモリ使用量
ps aux | grep -E "(zsh|nvim|tmux)"

# ファイル使用量
du -sh ~/.config/* | sort -hr
```

## 🚨 緊急時対応

### 設定破綻時の復旧

```bash
# 最小構成での起動
zsh --no-rcs

# 設定ファイルの段階的読み込み
source ~/.zshrc.minimal

# バックアップからの復元
cp ~/.config/zsh/backup/zshrc ~/.zshrc
```

### 依存関係エラー

```bash
# 依存関係の再構築
brew bundle --force

# Node.js環境の再構築
mise install node@latest
npm install -g @fsouza/prettierd

# Python環境の再構築
mise install python@latest
pip install -r requirements.txt
```

## 📋 メンテナンス自動化

### 定期実行スクリプト

```bash
#!/bin/bash
# ~/.config/scripts/maintenance.sh

# パフォーマンス測定
echo "$(date): $(zsh-benchmark)" >> ~/.config/zsh/performance.log

# プラグイン更新
sheldon update
nvim --headless -c 'lua require("lazy").sync()' -c 'q'

# 不要ファイル削除
find ~/.config -name "*.tmp" -delete
find ~/.cache -name "*.old" -delete

# 設定バックアップ
cp ~/.zshrc ~/.config/zsh/backup/zshrc.$(date +%Y%m%d)
```

### crontab設定

```bash
# 週次メンテナンス
0 9 * * 0 ~/.config/scripts/maintenance.sh

# 月次レポート
0 9 1 * * ~/.config/scripts/monthly-report.sh
```

## 🔄 設定変更ワークフロー

### 変更前の準備

1. **現在の状態記録**
   - パフォーマンス測定実行
   - 設定ファイルのバックアップ
   - 動作確認項目のリスト作成

2. **影響範囲の特定**
   - 変更する設定の依存関係確認
   - 影響を受ける可能性のある機能の特定

### 変更の実行

1. **段階的適用**
   - 小さな変更から開始
   - 各段階での動作確認
   - 問題発生時の迅速な切り戻し

2. **検証**
   - 基本機能の動作確認
   - パフォーマンス測定
   - 統合テストの実行

### 変更後の確認

1. **パフォーマンス比較**
   - 変更前後の起動時間比較
   - メモリ使用量の確認
   - レスポンス時間の測定

2. **知見の記録**
   - 変更内容の文書化
   - 問題点と解決策の記録
   - 次回への教訓の整理

## 🔗 関連ドキュメント

- **[Main CLAUDE.md](../../CLAUDE.md)** - プロジェクト概要とナビゲーション
- **[Configuration Guide](./configuration.md)** - 設定管理・実装パターン
- **[AI Assistance Guide](./ai-assistance.md)** - AI支援システム活用
- **[Performance Layer](../layers/support/performance-layer.md)** - パフォーマンス測定詳細

---

_最終更新: 2025-07-07_
_メンテナンス状態: 定期タスク実行中_
_トラブルシューティング: 既知問題解決済み_
