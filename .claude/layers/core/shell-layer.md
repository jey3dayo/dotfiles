# Shell Layer - Core Configuration Management

このレイヤーでは、シェル環境（主にZsh）の設定管理、パフォーマンス最適化、プラグイン管理に関する知見を体系化します。

## 🎯 責任範囲

**🔥 主要技術**: Zshはdotfiles環境の中核技術の一つ

- **設定量**: 全dotfilesの約30%を占める主要コンポーネント
- **使用頻度**: 開発作業の基盤として最高頻度で使用
- **影響範囲**: 他ツール（Git、FZF、mise等）の統合基盤

- **Zsh設定**: モジュラー設定、起動時間最適化、プラグイン管理
- **Shell統合**: Git、FZF、mise等の統合パターン
- **パフォーマンス**: 起動時間測定、プロファイリング、最適化手法
- **設定管理**: モジュール化、条件分岐、環境対応

## 📊 実装パターン

### 基本設定構造

```zsh
# モジュラー設定パターン
# config/loader.zsh - 中央ローダー
source_if_exists() {
    [[ -f "$1" ]] && source "$1"
}

# 遅延読み込みパターン
mise() {
    unfunction mise
    eval "$(mise activate zsh)"
    mise "$@"
}
```

### パフォーマンス最適化

```zsh
# 起動時間測定
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

### プラグイン管理 (Sheldon)

```toml
# 6段階優先度システム
[plugins.critical]
priority = 1
source = "path"

[plugins.performance]
priority = 2
source = "github"

[plugins.navigation]
priority = 3
source = "github"
```

#### Sheldonテンプレート変数制限

```toml
# ✅ 利用可能な展開
local = "~/.config/zsh/lazy-sources"     # チルダ展開のみ
{{ dir }}                                # sheldon内部変数
{{ file }}                               # ファイルパス変数

# ❌ 利用不可能な展開
local = "$HOME/.config/..."              # 環境変数展開不可
local = "${XDG_CONFIG_HOME}/..."         # 複合環境変数不可
local = "${XDG_CONFIG_HOME:-$HOME/.config}/..." # fallback構文不可
```

**回避策**: XDG準拠を保ちたい場合は、シンボリンクと組み合わせ

```bash
# dotfiles/zsh/lazy-sources → ~/.config/zsh/lazy-sources
ln -sf /path/to/dotfiles/zsh/lazy-sources ~/.config/zsh/lazy-sources
```

## 🔧 ベストプラクティス

### 1. 遅延読み込み戦略

- **重いツール**: mise, docker, kubectl等は遅延読み込み
- **測定**: 各プラグインの読み込み時間を定期測定
- **条件分岐**: 必要時のみプラグインを読み込み

### 2. モジュール分割

- **機能別分離**: aliases, functions, exports, keybinds
- **環境別分岐**: OS、ホスト、プロジェクト別設定
- **設定階層**: global → local → project の優先順位

### 3. パフォーマンス監視

- **起動時間**: 目標1.0秒以下
- **プロファイリング**: zsh/zprof モジュール活用
- **継続監視**: 定期的なベンチマーク実行

## 📈 現在の指標

- **起動時間**: 1.2秒 (30%改善達成 - 1.7s → 1.2s)
- **プラグイン数**: 15+ (最適化済み)
- **メモリ使用量**: 監視対象
- **設定ファイル数**: 8ファイル (モジュール化)

## 🔑 Zsh Key Features (詳細機能)

### コマンド効率化

- **Abbreviations**: 50+ コマンド短縮形（`g` → `git`, `ga` → `git add`, etc）
- **Git Widgets**: `^g^g` (status), `^g^s` (add), `^g^a` (add all), `^g^b` (branch) でGit操作
- **FZF統合**: `^]` リポジトリ選択、`^g^K` プロセス管理
- **Help System**: `zsh-help [keybinds|aliases|tools]` で詳細ヘルプ

### パフォーマンス監視

- **起動時間測定**: `zsh-benchmark` で5回平均測定
- **プロファイリング**: `zsh-profile` で詳細分析
- **継続監視**: 定期的なベンチマーク実行で回帰検出

## 🚧 最適化課題

### 高優先度

- [ ] mise初期化をさらに遅延化（目標: 50ms削減）
- [ ] プラグイン読み込み順序の最適化
- [ ] 未使用関数・エイリアスの削除

### 中優先度

- [ ] fzf統合の軽量化
- [ ] Git統合の最適化
- [ ] 条件分岐ロジックの簡素化

## 🔗 関連層との連携

- **Tools Layer**: 各ツール固有の設定と統合
- **Performance Layer**: パフォーマンス測定・最適化
- **Integration Layer**: 他ツールとの連携パターン

## 📝 設定テンプレート

### 新機能追加時のパターン

```zsh
# 1. 遅延読み込み関数定義
tool_name() {
    unfunction tool_name
    eval "$(tool_name init)"
    tool_name "$@"
}

# 2. 条件付き読み込み
if command -v tool_name >/dev/null 2>&1; then
    # ツール固有の設定
fi

# 3. エイリアス・略語定義
abbr tool_alias="tool_name command"
```

### デバッグ・診断パターン

```zsh
# 起動時間プロファイリング
zmodload zsh/zprof
# 設定読み込み
zprof | head -20

# 個別ファイル測定
time source config_file.zsh

# sheldon詳細診断
time zsh -i -c exit                    # 実際の起動時間測定
zsh -x -c exit 2>&1 | head -20        # 起動プロセス確認
sheldon lock --update                 # プラグイン更新・エラー確認

# プラグイン競合診断
sheldon source | head -50             # 生成されたコード確認
```

## 💡 知見・教訓

### 成功パターン

- **Sheldon 6段階優先度**: プラグイン管理の一元化で設定が簡潔に
  - 実測効果: 起動時間 2.0s → 1.2s (30%改善)
  - 段階: Critical → Performance → Navigation → Git → Tools → Optional
- **mise遅延読み込み**: 使用頻度の低いツールで大幅な起動時間短縮
  - 実測効果: -39.88ms短縮
  - パターン: 必要時のみeval実行
- **モジュール化**: 機能別分離で保守性向上
  - 構成: loader.zsh → aliases.zsh, functions.zsh, widgets.zsh

### 失敗パターン

- **過度の最適化**: 可読性を犠牲にした micro-optimization
- **依存関係の複雑化**: プラグイン間の依存関係管理の難しさ
- **設定の断片化**: あまりに細分化すると全体像が見えにくい
- **プラグイン競合**: `zsh-vi-mode`が他プラグインと競合し、1分の起動遅延発生
  - 症状: エイリアス無効化、色表示停止、起動フリーズ
  - 原因: キーバインド変更による他プラグインとの競合
  - 解決: 競合プラグインの削除、または慎重な読み込み順序設定

### 実証済み最適化手法

- **XDG Base Directory準拠**: キャッシュ効率化
- **条件付きPATH追加**: typeset -U pathで重複排除
- **プロファイリング**: zmodload zsh/zprofで詳細測定

## 🔧 Zsh初期化順序の問題解決 - compdef エラー根本対策

### 問題・背景

- **現象**: `zsh: command not found: compdef` エラーが起動時に発生
- **原因**: `compinit`実行前に`compdef`関数を使用する設定ファイル読み込み
- **影響**: 補完システムが正常に動作しない、エラーメッセージで起動体験悪化

### 根本原因の分析

```text
読み込み順序の問題:
1. sources/completion.zsh  # 補完設定のみ、compinit未実行
2. sources/config-loader.zsh  # config/tools/gh.zsh等を読み込み
3. config/tools/gh.zsh    # compdef使用 ← ここでエラー発生
```

### 解決策・アーキテクチャ改善

**1. 初期化と設定の分離**

```zsh
# 新しい構造
zsh/
├── init/                    # 初期化処理（順序依存）
│   └── completion.zsh       # compinit実行 + 基本設定
└── sources/                 # 設定適用（初期化完了前提）
    ├── styles.zsh          # 補完スタイル設定
    └── config-loader.zsh   # ツール設定読み込み
```

**2. .zshrcの明確な読み込み順序**

```zsh
# 1. 初期化処理（順序重要）
for f ("${ZDOTDIR:-$HOME}"/init/*.zsh) source "${f}"

# 2. 設定適用（初期化完了前提）
for f ("${ZDOTDIR:-$HOME}"/sources/*.zsh) source "${f}"
```

### 実装パターン

**init/completion.zsh - 初期化専用**
```zsh
# 補完システム初期化（完全初期化）
_init_completion() {
  # fpath設定
  # compinit実行
  # post-compinit hooks実行
}

# 必ず初期化を実行
_init_completion
```

**sources/styles.zsh - 設定適用専用**
```zsh
# 補完スタイル設定（compdef前提）
if (( $+functions[compdef] )); then
  _set_completion_styles
fi
```

### 適用効果・実測値

- **エラー解消**: compdefエラーが完全に解決
- **依存関係明確化**: 初期化 → 設定の順序保証
- **保守性向上**: 機能分離により責任範囲が明確

### 学習ポイント・パターン

- **依存関係のある機能は初期化フェーズで実行**
- **設定系ファイルは初期化完了を前提とする**
- **ディレクトリ名で責任範囲を明示** (`init/` vs `sources/`)
- **条件チェック** `(( $+functions[compdef] ))` で安全な実行確保

### 適用条件・注意点

- **適用条件**: Zshを主要シェルとして使用する環境
- **副作用**: 既存の設定読み込み順序に依存したカスタマイズは要調整
- **測定方法**: 起動時のエラーメッセージ確認、`zsh-benchmark`で起動時間測定

### 実装日・検証結果

- **実装日**: 2025-07-21
- **検証結果**: compdefエラー完全解消、起動時間に影響なし
- **応用可能性**: 他のシェル機能でも同様の初期化/設定分離パターンが適用可能

---

_最終更新: 2025-07-21_
_パフォーマンス状態: 最適化継続中 (目標起動時間: 1.0秒)_
_アーキテクチャ状態: 初期化順序問題解決済み_
