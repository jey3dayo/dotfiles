# Zsh設定 知見・学習事項

## パフォーマンス最適化

### 起動時間短縮テクニック

#### Sheldon 6段階優先度読み込み
- **実装**: sheldon.toml の priority 設定で段階的読み込み
- **効果**: 必要な順序でプラグイン読み込み、依存関係解決
- **成果**: 起動時間 2.0s → 1.2s（30%改善）

#### mise 遅延読み込み
- **問題**: mise のフル読み込みで 39.88ms の遅延
- **解決**: 必要時のみの遅延読み込み実装
- **コード**:
```bash
# 遅延読み込みパターン
if [[ -n "$MISE_ENABLED" ]]; then
    eval "$(mise activate zsh)"
fi
```

#### キャッシュ活用
- **対象**: コマンド補完、履歴検索、プラグイン状態
- **実装**: XDG_CACHE_HOME の活用
- **効果**: 重複処理の削減

### プラグイン管理最適化

#### 条件分岐読み込み
```bash
# コマンド存在確認パターン
if command -v fzf >/dev/null 2>&1; then
    source "$ZDOTDIR/plugins/fzf.zsh"
fi
```

#### モジュラー構成
- **loader.zsh**: 中央集約的な読み込み制御
- **機能別ファイル**: aliases.zsh, functions.zsh, widgets.zsh
- **条件別ファイル**: macos.zsh, linux.zsh

## 機能実装パターン

### Git統合

#### Zsh Widgets
- **^g^g**: git status の表示
- **^g^s**: git add の実行
- **^g^a**: git add --all
- **^g^b**: ブランチ選択

#### FZF統合
- **^]**: ghq リポジトリ選択
- **^g^K**: プロセス管理
- **Ctrl+R**: 履歴検索の強化

### 略語展開システム
- **g**: git
- **ga**: git add
- **gc**: git commit
- **gp**: git push
- **gl**: git pull

## 設定管理パターン

### 環境変数管理
```bash
# XDG Base Directory 準拠
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
```

### PATH管理
```bash
# 条件付きPATH追加
typeset -U path PATH
path=(
    $HOME/.local/bin
    /opt/homebrew/bin
    $path
)
```

## デバッグ・トラブルシューティング

### パフォーマンス測定
```bash
# 起動時間測定
time zsh -i -c exit

# プロファイリング
zmodload zsh/zprof
# 設定読み込み
zprof
```

### 設定診断
```bash
# カスタムベンチマークツール
zsh-benchmark

# プロファイリングツール
zsh-profile

# 設定ヘルプ
zsh-help [keybinds|aliases|tools]
```

## よく使用するパターン

### 関数定義パターン
```bash
function func_name() {
    local arg1="$1"
    # 引数チェック
    [[ -z "$arg1" ]] && {
        echo "Usage: func_name <arg1>"
        return 1
    }
    # 処理実行
}
```

### エイリアス定義パターン
```bash
# 基本エイリアス
alias ll='ls -la'
alias la='ls -A'

# 条件付きエイリアス
if command -v exa >/dev/null 2>&1; then
    alias ls='exa'
    alias ll='exa -la'
fi
```

## 学習した回避すべきパターン

### アンチパターン
1. **全プラグイン同時読み込み**: 起動時間大幅増加
2. **重複PATH設定**: 環境変数の重複
3. **無条件コマンド実行**: 存在しないコマンドでのエラー
4. **同期的な重い処理**: バックグラウンド処理未使用

### 改善済み問題
- **mise の全機能読み込み**: 遅延読み込みで解決
- **プラグイン依存関係**: 優先度読み込みで解決
- **設定ファイル散在**: モジュラー構成で解決

## パフォーマンス指標

### 現在の状況
- **起動時間**: 1.2秒（目標: 1.0秒以下）
- **プラグイン数**: 最適化済み
- **メモリ使用量**: 軽量化達成

### ベンチマーク履歴
- **2025-06-09**: 2.0s → 1.2s（30%改善）
- **目標**: 1.0s 以下の実現

---

*Last Updated: 2025-06-14*
*Status: 継続最適化中*