# Configuration Management Guide

dotfiles設定管理に関するパターン、ベストプラクティス、実装手法を体系化したガイドです。

## 🎯 設定管理の核心原則

### モジュラー設計パターン

- **機能別分離**: 各ツールの独立した設定構成
- **遅延読み込み**: 必要時のみプラグイン・設定を読み込み
- **条件分岐**: OS・環境別の適応的設定
- **依存関係管理**: 設定間の依存関係を明確化

### パフォーマンス最適化戦略

- **起動時間最適化**: 主要3技術（Zsh/WezTerm/Neovim）で起動時間最適化
- **遅延読み込み**: 重いツール（mise、Docker等）の遅延読み込み
- **プロファイリング**: 定期的なパフォーマンス測定

## 📊 設定ファイル管理パターン

### シンボリックリンク作成

```bash
# 基本パターン
ln -sf "$DOTFILES_DIR/config_file" "$HOME/.config_file"

# XDG Base Directory準拠
ln -sf "$DOTFILES_DIR/zsh/config" "$HOME/.config/zsh"
ln -sf "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
```

### 条件付き設定読み込み

```bash
# ローカル設定ファイルの条件付き読み込み
[[ -f "$HOME/.local_config" ]] && source "$HOME/.local_config"

# 環境別設定
if [[ -f "$HOME/.config/environment/$HOSTNAME.zsh" ]]; then
    source "$HOME/.config/environment/$HOSTNAME.zsh"
fi
```

### OS別設定分岐

```bash
# OS判定による分岐
case "$(uname -s)" in
    Darwin)
        # macOS固有設定
        export BROWSER="open"
        alias pbcopy="pbcopy"
        ;;
    Linux)
        # Linux固有設定
        export BROWSER="xdg-open"
        alias pbcopy="xclip -selection c"
        ;;
esac
```

## 🔧 パフォーマンス最適化手法

### 起動時間測定

```bash
# Zsh起動時間測定
time zsh -i -c exit

# カスタムベンチマークツール
zsh-benchmark() {
    local times=5
    local total=0
    for i in {1..$times}; do
        local start=$(date +%s.%N)
        zsh -i -c exit
        local end=$(date +%s.%N)
        local time=$(echo "$end - $start" | bc)
        total=$(echo "$total + $time" | bc)
    done
    echo "Average startup time: $(echo "scale=3; $total / $times" | bc)s"
}
```

### Neovimプロファイリング

```bash
# 起動時間詳細測定
nvim --startuptime startup.log

# プラグイン統計（lazy.nvim）
:Lazy profile
```

### 遅延読み込みパターン

```bash
# ツール遅延読み込みテンプレート
tool_name() {
    unfunction tool_name
    eval "$(tool_name init)"
    tool_name "$@"
}

# mise遅延読み込み（実証済み）
# 詳細な設定パターン: .claude/reference/tool-configurations.md を参照
```

## 🛠️ 実装ワークフロー

### 層別実装アプローチ

#### Step 1: 実装準備

1. **対象層ドキュメント確認**: 該当層の `.claude/layers/` ドキュメントを読み込み
2. **アーキテクチャ理解**: `.claude/architecture/patterns.md` で統一方針を確認
3. **依存関係把握**: 他層との連携パターンを理解

#### Step 2: 実装実行

1. **既存設定優先**: 新規作成より既存設定の編集・拡張を検討
2. **パフォーマンス重視**: 起動時間・レスポンス時間への影響を常に考慮
3. **統一パターン活用**: 各層ドキュメント内の実装テンプレートを利用

#### Step 3: 品質確保

1. **測定・検証**: 該当層の測定パターンに従い実装効果を検証
2. **統合テスト**: 他ツールとの連携に問題がないことを確認
3. **知見記録**: `/learnings` コマンドで新しい知見を層別に記録

## 🔍 デバッグ・診断パターン

### 設定診断

```bash
# コマンドパス確認
which command_name
type command_name
echo $PATH

# 環境変数診断
env | grep -E "(SHELL|TERM|PATH|HOME|CONFIG)"
```

### Zsh診断

```bash
# デバッグモード実行
zsh -x -c 'exit'

# プロファイリング
zmodload zsh/zprof
# 設定読み込み
zprof | head -20
```

### 設定ファイル検証

```bash
# 設定ファイル構文チェック
zsh -n config_file.zsh

# 個別読み込み時間測定
time source config_file.zsh
```

## 📈 設定管理の成功パターン

### 実証済み最適化手法

- **XDG Base Directory準拠**: キャッシュ効率化
- **条件付きPATH追加**: `typeset -U path`で重複排除
- **プロファイリング**: `zmodload zsh/zprof`で詳細測定
- **モジュール化**: 機能別分離による保守性向上

### 設定統合パターン

- **統一テーマ**: Gruvbox/Tokyo Nightによる視覚的一貫性
- **フォント統一**: Nerd Fontsによるアイコン表示統一
- **キーバインド統一**: vim-likeキーバインドによる操作一貫性

## 🚫 避けるべき失敗パターン

### 過度の最適化

- **micro-optimization**: 可読性を犠牲にした細かな最適化
- **設定の断片化**: 過度の分割による全体像の見えにくさ
- **依存関係の複雑化**: プラグイン間の依存関係管理困難

### 設定管理の落とし穴

- **設定の重複**: 複数箇所での同じ設定による一貫性の欠如
- **環境依存**: 特定環境でのみ動作する設定
- **バックアップ不足**: 設定変更時のバックアップ戦略不備

## 🔄 メンテナンス戦略

### 定期メンテナンス

- **週次**: パッケージ更新（`brew update && brew upgrade`）
- **月次**: プラグイン更新とパフォーマンス測定
- **四半期**: 設定監査、不要ファイル削除

### 設定変更管理

- **段階的適用**: 大きな変更は段階的に適用
- **パフォーマンス監視**: 変更前後のパフォーマンス比較
- **ロールバック準備**: 設定変更時の復元手順準備

## 🔗 関連ドキュメント

- **[Main CLAUDE.md](../../CLAUDE.md)** - プロジェクト概要とナビゲーション
- **[Performance Layer](../configuration/support/performance.md)** - パフォーマンス測定・最適化
- **[Maintenance Guide](./maintenance.md)** - メンテナンス・トラブルシューティング
- **[AI Assistance Guide](./ai-assistance.md)** - AI支援システム活用

---

_最終更新: 2025-07-07_
_適用範囲: 全層横断的設定管理_
