# Dotfiles リファクタリングコマンド

確立された設定パターンに基づいて設定ファイルのリファクタリングを実行します。

## 使用方法

```bash
/refactoring
```

## 更新対象

### Tool別リファクタリング対象

リファクタリングはツール別に分類して実行する（設定パターンと正本がツール単位で分かれているため）：

- zsh/ - Shell設定・プラグイン・パフォーマンス最適化
- nvim/ - Neovim設定・LSP・Lua設定・プラグイン管理
- wezterm/ - Terminal設定・キーバインド・テーマ・UI設定
- git/ - Git設定・エイリアス・hooks・ワークフロー
- ssh/ - SSH設定・セキュリティ・接続最適化
- tmux/ - Terminal multiplexer設定・セッション管理
- general - 横断的設定・セットアップスクリプト

## 参考ファイル

- `.claude/rules/tools/<tool>.md` - ツール別の圧縮ルール
- `docs/tools/<tool>.md` - 設定パターン・トラブルシューティングの正本
- `.claude/review-criteria.md` - レビュー観点

## 実行フロー

対象ファイルをツール別に特定し、該当ツールの rule と docs に照らして改善する。改善で得た知見は対応する `docs/tools/<tool>.md` に追記し、必要なら `.claude/rules/tools/<tool>.md` を同期する。

## リファクタリング原則

### 設定の統一性

- テーマ・カラーパレットの統一
- フォント設定の統一
- キーバインドの一貫性

### パフォーマンス最適化

- 遅延読み込みの実装
- 不要な設定の削除
- キャッシュ機能の活用

### モジュラー設計

- 機能別の設定分離
- 条件分岐による環境対応
- 再利用可能なコンポーネント化

### 保守性の向上

- 設定ファイルサイズの適正化
- 明確な命名規則
- ドキュメント・コメントの充実

## Tool別対象設定ファイル

### Zsh関連

- .zshrc, sheldon.toml, config/loader.zsh
- 各種プラグイン設定・起動時間最適化

### Neovim関連

- init.lua, plugin設定、LSP設定
- lazy.nvim設定・UI最適化

### WezTerm関連

- wezterm.lua, ui.lua, keybinds.lua
- テーマ・キーバインド・パフォーマンス設定

### Git関連

- .gitconfig, hooks, エイリアス設定
- ワークフロー最適化

### SSH関連

- ssh_config, ssh_config.d/\*, 階層的Include設定
- 1Password SSH Agent統合・セキュリティ最適化

### Tmux関連

- .tmux.conf, プラグイン設定
- セッション管理・統合設定
