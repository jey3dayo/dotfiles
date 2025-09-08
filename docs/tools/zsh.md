# Zsh設定

1.1秒起動（43%向上）とモジュラープラグインシステムを持つ高性能Zsh設定です。

## 主要機能

- **高性能**: 1.8秒→1.1秒起動（43%向上）
- **プラグイン管理**: Sheldon による6段階優先読み込み
- **最適化**: mise遅延読み込み（-39.88ms重要改善）
- **Git統合**: カスタムウィジェットと50以上の省略語
- **FZF統合**: リポジトリ、ファイル、プロセス検索
- **ヘルプシステム**: 包括的な `zsh-help` コマンド

## パフォーマンス指標

| 最適化項目              | 改善効果         | 影響度       |
| ----------------------- | ---------------- | ------------ |
| 全体起動                | 1.8秒→1.1秒      | 43%高速化    |
| mise ultra-defer        | 完全遅延         | クリティカル |
| brew最適化              | 最小環境         | 高影響       |
| 6段階プラグイン読み込み | 最適化タイミング | スムーズ起動 |
| ファイル コンパイル     | 全.zshファイル   | 実行時速度   |

## アーキテクチャ

### モジュラー設計

```text
zsh/
├── config/
│   ├── loader.zsh         # メインローダーシステム
│   ├── 01-environment.zsh # 環境変数
│   ├── 02-plugins.zsh     # プラグイン設定
│   ├── 03-aliases.zsh     # エイリアス・省略語
│   ├── 04-functions.zsh   # カスタム関数
│   ├── 05-bindings.zsh    # キーバインド
│   └── 06-completions.zsh # 補完設定
├── sheldon.toml           # プラグイン管理
└── .zshrc                 # メインエントリポイント
```

### 6段階プラグイン読み込み

1. **Essential**: コア機能（zsh-autosuggestions）
2. **Completion**: タブ補完強化
3. **Navigation**: ディレクトリ・ファイルナビゲーション
4. **Git**: バージョン管理統合
5. **Utility**: 開発ツール・ヘルパー
6. **Theme**: プロンプトとビジュアル要素

## 基本コマンド

### ヘルプシステム

```bash
zsh-help                    # 包括的ヘルプ
zsh-help keybinds          # キーバインド参照
zsh-help aliases           # 省略語リスト（50以上）
zsh-help tools             # インストール済みツール確認
```

### パフォーマンスツール

```bash
zsh-benchmark              # 起動時間測定
zsh-profile                # 詳細プロファイリング
```

### Gitワークフロー（ウィジェット）

```bash
^]                         # FZF ghqリポジトリ選択
^g^g                       # Git status表示
^g^s                       # Gitステージングウィジェット
^g^a                       # Git addウィジェット
^g^b                       # Gitブランチスイッチャー
^g^K                       # FZFプロセスkill
```

### FZF統合

```bash
^R                         # 履歴検索
^T                         # ファイル検索
^]                         # リポジトリ検索（ghq）
```

## 設定機能

### 省略語（50以上）

```bash
# Git ショートカット
g      → git
ga     → git add
gc     → git commit
gp     → git push
gl     → git pull
gst    → git status
gco    → git checkout

# ディレクトリナビゲーション
..     → cd ..
...    → cd ../..
....   → cd ../../..

# 共通コマンド
ll     → ls -la
la     → ls -A
l      → ls -CF
```

### 環境最適化

- **mise遅延読み込み**: 初回使用時まで遅延
- **条件付き読み込み**: 利用可能ツールのみ読み込み
- **PATH最適化**: 効率的PATH管理
- **キャッシュ活用**: コマンド補完キャッシュ

### カスタム関数

```bash
mkcd()          # ディレクトリ作成・移動
gco()           # FZF git checkout
ghq-fzf()       # リポジトリ選択
kill-fzf()      # プレビュー付きプロセスkill
```

## プラグインエコシステム

### コアプラグイン（Tier 1-2）

- **zsh-autosuggestions**: コマンド提案
- **zsh-syntax-highlighting**: シンタックス色付け
- **zsh-completions**: 強化補完
- **fzf-tab**: FZF駆動タブ補完

### 開発プラグイン（Tier 3-4）

- **zsh-abbr**: 省略語展開
- **forgit**: インタラクティブgit操作
- **zsh-you-should-use**: エイリアス提醒

### テーマ・UI（Tier 5-6）

- **starship**: クロスシェルプロンプト
- **zsh-notify**: コマンド完了通知

## カスタマイゼーション

マシン固有設定は `~/.zshrc.local` に記述：

```bash
# プライベートエイリアス
alias work="cd ~/work"

# ローカル環境変数
export CUSTOM_VAR="value"

# マシン固有最適化
if [[ $(hostname) == "work-machine" ]]; then
    # 作業環境固有設定
fi
```

## 最適化のコツ

### 起動速度

1. **定期プロファイル**: 週次 `zsh-benchmark` 実行
2. **遅延読み込み**: 重いツール（mise、nvm等）の遅延
3. **ファイルコンパイル**: 全.zshファイルのコンパイル確認
4. **プラグイン監査**: 四半期毎の未使用プラグイン削除

### メモリ使用量

1. **履歴制限**: 適切なHISTSIZE設定
2. **補完キャッシュ**: 定期キャッシュクリア
3. **プラグイン整理**: 冗長機能削除

## メンテナンス

### 定期タスク

```bash
# 週次パフォーマンスチェック
zsh-benchmark

# 月次プラグイン更新
sheldon lock --update

# 四半期クリーンアップ
zsh-help tools  # 未使用ツールチェック
```

### トラブルシューティング

```bash
# 補完リセット
rm -rf ~/.zcompdump*
compinit

# 競合チェック
zsh -df  # 最小設定で起動

# プラグイン状態確認
sheldon source
```

---

## 概要

速度、機能性、開発者体験に最適化された高性能シェル環境
