# Dotfiles 知見集

## 設定管理のベストプラクティス

### モジュラー設計パターン

- **決定**: 機能別の独立したモジュール構成
- **理由**: 保守性、テストの容易さ、選択的な設定適用
- **適用**: Zsh, Neovim, Tmux 全てで採用

### パフォーマンス最適化パターン

#### Zsh 起動最適化
- **lazy loading**: 必要時のみプラグイン読み込み
- **段階的読み込み**: 優先度に基づく6段階ローディング
- **キャッシュ活用**: コマンド完了、履歴の最適化

#### Neovim 起動最適化
- **lazy.nvim**: プラグインの遅延読み込み
- **条件分岐**: ファイルタイプ別の設定適用
- **LSP最適化**: 言語別の条件付きLSP起動

### 設定の統一パターン

#### テーマ統一
- **色設定**: Gruvbox/Tokyo Night での統一
- **フォント**: JetBrains Mono + Nerd Fonts
- **アイコン**: 一貫したアイコンセット

#### キーバインド統一
- **共通プレフィックス**: Ctrl/Cmd キーの統一使用
- **Vi モード**: 可能な限りVi風キーバインド
- **FZF統合**: 検索操作の統一

## 実装パターン

### Zsh 設定パターン

```bash
# モジュール読み込みパターン
autoload -Uz module_name

# 条件分岐パターン
if command -v tool_name >/dev/null 2>&1; then
    # tool available
fi

# 関数定義パターン
function func_name() {
    local arg1="$1"
    # function body
}
```

### Neovim Lua パターン

```lua
-- モジュール定義
local M = {}

-- 条件付き設定
if vim.fn.has('nvim-0.10') == 1 then
    -- Neovim 0.10+ specific
end

-- プラグイン設定
return {
    'plugin/name',
    config = function()
        -- setup
    end,
    lazy = true,
}
```

### Git 統合パターン

```bash
# エイリアス定義
alias g='git'
alias ga='git add'
alias gc='git commit'

# 関数ベースの複雑な操作
function git_current_branch() {
    git branch --show-current 2>/dev/null
}
```

## 避けるべきパターン

### 重複設定の回避
- **問題**: 複数箇所での同一設定
- **解決**: 共通設定ファイルの活用

### ハードコーディングの回避
- **問題**: パス、色設定の直接記述  
- **解決**: 変数化、設定ファイル分離

### 大きすぎる設定ファイル
- **問題**: 1000行超の設定ファイル
- **解決**: 機能別分割、モジュール化

## パフォーマンス計測

### Zsh 起動時間測定
```bash
# ベンチマーク実行
zsh-benchmark

# プロファイリング
zmodload zsh/zprof
# 設定読み込み後
zprof
```

### Neovim 起動時間測定
```bash
# 起動時間測定
nvim --startuptime startup.log

# プラグインマネージャー統計
:Lazy profile
```

## 設定の可搬性

### OS別の条件分岐
```bash
case "$(uname -s)" in
    Darwin)  # macOS
        ;;
    Linux)   # Linux
        ;;
esac
```

### 環境変数による設定切り替え
```bash
# 開発環境での設定変更
if [[ -n "$DEVELOPMENT_MODE" ]]; then
    # development specific settings
fi
```

## デバッグパターン

### 設定読み込みの確認
```bash
# Zsh 設定の確認
echo $ZDOTDIR
echo $fpath

# 読み込まれた設定の確認
which command_name
type command_name
```

### プラグイン状態の確認
```bash
# Sheldon プラグイン確認
sheldon list

# Neovim プラグイン確認  
:Lazy
```

## ドキュメント管理のベストプラクティス

### README.md統合パターン

**問題**: 散在したCLAUDE.mdファイルによる情報重複と保守困難

**解決策**:
1. **単一ソース**: ルートCLAUDE.mdに全情報統合
2. **階層的README**: 用途別（概要/詳細）の適切な情報配置
3. **相互参照**: 適切なリンク構造による情報アクセス

**実装パターン**:
```markdown
# Root README.md
- 概要・クイックスタート・全体構成
- パフォーマンス指標・主要機能

# Component README.md  
- 詳細設定・使用方法・カスタマイズ
- 具体的コマンド・トラブルシューティング
```

### ドキュメント構造設計原則

#### 情報の階層化
- **L1 (Root)**: プロジェクト全体・導入・概要
- **L2 (Component)**: 各ツール詳細・設定・操作
- **L3 (Technical)**: CLAUDE.md技術詳細・設計判断

#### 一貫性の確保
- **構造**: 統一されたMarkdownセクション構成
- **スタイル**: emoji・表・コードブロックの一貫使用
- **用語**: 技術用語・コマンド名の統一

#### 実用性重視
- **パフォーマンス数値**: Before/After比較表
- **実行可能コマンド**: コピペ可能なコマンド例
- **メンテナンス手順**: 定期作業・トラブルシューティング

### コマンド体系の設計

**`/project:update-readme`コマンドパターン**:
- **目的特化**: 単一責任でのコマンド設計
- **フロー明確化**: 実行手順・品質チェックの標準化
- **自動化準備**: 将来の自動実行に向けた仕様設計

**実装要素**:
```markdown
## 使用方法・対象ファイル・実行フロー
## 更新ポリシー・情報ソース・品質チェック
## 自動化対応・手動プロセス
```

## 今後の改善方向

### ドキュメント自動化
- **設定値抽出**: 設定ファイルからの自動数値更新
- **パフォーマンス測定**: 定期ベンチマーク結果の自動反映
- **リンクチェック**: 相互参照・外部リンクの自動検証

### 設定の可視化
- **依存関係図**: ツール間統合の視覚化
- **設定マップ**: 階層構造・影響範囲の明確化
- **変更追跡**: 設定変更の履歴・影響分析

### クロスプラットフォーム対応
- Linux 環境での動作確認
- Windows WSL での対応
- Docker 環境での実行