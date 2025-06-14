# Dotfiles 知見管理コマンド

設定に関する新しい知見や学習事項を適切なファイルに記録します。

## 使用方法

```bash
/learnings
```

## 更新対象

### Tool別知見ファイル（必須）

知見は必ずツール別に分類して記録します：

- **`.claude/learnings-zsh.md`** - Zsh設定・パフォーマンス・プラグイン管理
- **`.claude/learnings-nvim.md`** - Neovim設定・LSP・プラグイン・Lua設定
- **`.claude/learnings-wezterm.md`** - WezTerm設定・キーバインド・テーマ
- **`.claude/learnings-git.md`** - Git設定・エイリアス・ワークフロー
- **`.claude/learnings-ssh.md`** - SSH設定・セキュリティ・接続最適化
- **`.claude/learnings-tmux.md`** - Tmux設定・セッション管理
- **`.claude/learnings-general.md`** - ツール横断・セットアップ・全般的な知見

### 統合管理ファイル

- **`.claude/context.md`** - プロジェクト概要・技術スタック・設定構造
- **`.claude/project-knowledge.md`** - 設定パターン・ベストプラクティス・回避すべきパターン
- **`.claude/project-improvements.md`** - 最適化履歴・問題解決・学習事項
- **`.claude/common-patterns.md`** - よく使う設定パターン・コマンド・スクリプト

## 実行フロー

1. 新しい設定知見・パターンを特定
2. **ツール別分類を判断**（zsh/nvim/wezterm/git/ssh/tmux/general）
3. 適切なツール別ファイルに構造化して記録
4. 関連する既存項目があれば統合・更新
5. 必要に応じて統合管理ファイルにも反映

## 知見の分類

### 設定パターン
- Zsh/Neovim/Git設定の実装パターン
- シンボリックリンク管理
- 条件分岐による環境別設定

### パフォーマンス最適化
- 起動時間短縮のテクニック
- 遅延読み込みの実装
- キャッシュ活用

### デバッグ・トラブルシューティング
- 設定の動作確認方法
- 問題の特定と解決パターン
- ログ・診断ツールの活用
