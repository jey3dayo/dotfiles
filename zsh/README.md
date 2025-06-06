# Zsh Configuration

XDG Base Directory準拠のモジュラー設計によるzsh設定システム

## ✅ 現在の状況（2024-06-06）
- 🚀 **起動時間**: 1.2秒（30%改善達成）
- ✅ **全機能動作**: モジュラーローダー、Git統合、FZF統合、ヘルプシステム
- ✅ **パフォーマンス最適化**: mise超遅延化、プラグイン順序最適化、全ファイルコンパイル

## ディレクトリ構成

```
zsh/
├── .zshenv                 # 環境変数・PATH設定（XDG base directories設定）
├── .zshrc                  # メイン設定ファイル
├── .zlogin                 # ログイン後処理（補完キャッシュ最適化）
├── .zprofile               # ログイン前処理
│
├── config/                 # 設定ファイル群
│   ├── loader.zsh          # メインローダー（オーケストレーター）
│   └── loaders/            # 機能別ローダー（SOLID原則）
│       ├── helper.zsh      # 共通ヘルパー関数
│       ├── core.zsh        # Core settings読み込み
│   ├── tools/              # ツール固有設定
│   │   ├── fzf.zsh         # fzf基本設定（環境変数のみ）
│   │   ├── git.zsh         # Git設定・Widget関数
│   │   ├── debug.zsh       # デバッグ・プロファイリング機能
│   │   ├── gh.zsh          # GitHub CLI設定
│   │   ├── mise.zsh        # mise設定
│   │   └── starship.zsh    # Starshipプロンプト設定
│       ├── functions.zsh   # Functions読み込み
│       └── os.zsh          # OS固有設定読み込み
│
├── sheldon/                # プラグイン管理
│   ├── plugins.toml        # Sheldonプラグイン設定
│   └── sheldon.zsh         # Sheldon初期化スクリプト（自動生成）
│
├── sources/                # 即時読み込み設定ファイル
│   ├── completion.zsh      # 補完システム設定（XDG準拠キャッシュ管理）
│   ├── config-loader.zsh   # 設定ローダー（プラグイン管理ツール非依存）
│   ├── brew.zsh            # Homebrew設定
│   ├── path.zsh            # PATH環境変数設定
│   └── starship.zsh        # Starshipプロンプト初期化
│
├── lazy-sources/           # 遅延読み込み設定ファイル
│   ├── abbreviations.zsh   # コマンド省略形定義
│   ├── alias.zsh           # OS固有のエイリアス
│   ├── fzf.zsh             # fzf統合機能（エイリアス・関数・ウィジェット）
│   ├── git-commands.zsh    # Git関連のカスタム関数
│   ├── gh.zsh              # GitHub CLI設定
│   ├── history-search.zsh  # 履歴検索設定
│   ├── mise.zsh            # mise (バージョンマネージャー) 設定
│   ├── orbstack.zsh        # OrbStack設定
│   ├── pyenv.zsh           # Python環境設定
│   └── wsl.zsh             # WSL関連設定
│
├── functions/              # ユーティリティ関数
│   ├── cleanup-zcompdump   # 古い補完キャッシュクリーンアップ
│   └── help.zsh            # 包括的ヘルプシステム（zsh-help）
│
└── completions/            # カスタム補完ファイル
```

## 主要コンポーネント

### 1. モジュラーローダー

- `config/loader.zsh` - メインオーケストレーター（25行）
- `config/loaders/helper.zsh` - 共通ヘルパー関数（DRY原則）
- `config/loaders/core.zsh` - 必須設定の即座読み込み
- `config/loaders/tools.zsh` - 開発ツール関連の遅延読み込み
- `config/loaders/functions.zsh` - ユーティリティ関数の遅延読み込み
- `config/loaders/os.zsh` - プラットフォーム固有設定

### 2. プラグイン管理ツール非依存設計

- **config/loader.zsh**: 任意のプラグイン管理ツールで使用可能
- **互換性**: sheldon → zinit、oh-my-zsh、preztoへの移行が容易
- **フォールバック機能**: `zsh-defer`が無くても動作
- **設定の統一**: 重複したファイルの統合完了

### 3. プラグイン管理 (Sheldon)

- **sheldon/plugins.toml**: プラグインの定義・設定
- **遅延読み込み**: パフォーマンス向上のため多くのプラグインを遅延読み込み
- **使用プラグイン**:
  - `zsh-defer` - 遅延読み込み機能
  - `zsh-abbr` - コマンド省略形
  - `zsh-autosuggestions` - コマンド候補提案
  - `fast-syntax-highlighting` - 構文ハイライト
  - `fzf-tab` - fzfを使った補完UI
  - `zsh-completions` - 追加補完定義
  - その他Oh My Zshプラグイン

### 4. XDG準拠の補完キャッシュ管理

- **キャッシュ場所**: `$XDG_CACHE_HOME/zsh/zcompdump`
- **自動最適化**: `.zlogin`でのバックグラウンドコンパイル
- **自動クリーンアップ**: 7日以上古いキャッシュファイルの定期削除
- **パフォーマンス**: 24時間キャッシュ + セキュリティチェックスキップ

### 5. コマンド省略形 (zsh-abbr)

- **lazy-sources/abbreviations.zsh**: 依存チェック付きコマンド省略形
- **遅延読み込み**: zsh-abbrプラグイン読み込み後に実行（✅ **タイミング問題修正済み**）
- 例: `l` → `eza -la`, `vim` → `nvim`, `gc` → `git commit -m`
- **状況**: ✅ `abbr list`コマンドで正常動作確認済み

### 6. FZF統合（✅ **2024-06-04整理完了**）

- **config/tools/fzf.zsh**: 基本設定（環境変数のみ）
- **lazy-sources/fzf.zsh**: エイリアス・関数・ウィジェット統合
- **機能**: GHQリポジトリ選択、プロセス終了、SSH接続選択
- **キーバインド**: `^]` (GHQ), `^g^K` (プロセス終了)

### 7. Git統合（✅ **2024-06-05実装完了**）

- **config/tools/git.zsh**: Git設定・Widget関数・ヘルパー関数
- **lazy-sources/abbreviations.zsh**: Git abbreviations（ga, gst, gd, gb等）
- **機能**: Git diff、status、add、branchのWidget関数
- **キーバインド**: `^g^g` (diff), `^g^s` (status), `^g^a` (add), `^g^b` (branch)

### 8. ヘルプシステム（✅ **2024-06-05実装完了**）

- **functions/help.zsh**: 包括的ヘルプシステム
- **コマンド**: `zsh-help [keybinds|aliases|functions|config|tools|benchmark]`
- **機能**: キーバインド、abbreviations、カスタム関数、設定、ツール、ベンチマーク情報
- **動的チェック**: インストール済みツールの自動検出

### 9. デバッグ・プロファイリング（✅ **2024-06-05実装完了**）

- **config/tools/debug.zsh**: デバッグ・プロファイリング機能
- **環境変数**: `ZSH_DEBUG=1` でデバッグモード有効
- **コマンド**: `zsh-benchmark` (起動時間), `zsh-profile` (プロファイル), `zsh-debug-info` (情報表示)

## 特徴・利点

### パフォーマンス

- 🚀 **起動時間**: 1.2秒（30%改善）
- ⚡ **最適化**: mise超遅延化、プラグイン順序最適化、全ファイルコンパイル
- 🔄 **XDG準拠**: キャッシュ管理 + 自動クリーンアップ

### 機能・互換性

- 🔧 **豊富な機能**: Git統合、FZF統合、ヘルプシステム、50+省略形
- 🎯 **モジュラー設計**: SOLID原則、DRY原則適用
- 🌐 **クロスプラットフォーム**: macOS/Linux/WSL対応  
- 🔌 **プラグイン管理ツール非依存**: sheldon、zinit、oh-my-zsh等で利用可能

## 使い方

### 初回セットアップ

1. このディレクトリを`$XDG_CONFIG_HOME/zsh`（通常`~/.config/zsh`）に配置
2. `~/.zshenv`に`export ZDOTDIR="$XDG_CONFIG_HOME/zsh"`を設定
3. sheldonをインストールして`sheldon source > sheldon/sheldon.zsh`を実行
4. ✅ **動作確認済み**: 現在のセットアップは完全に機能

### 主要コマンド

```bash
# ヘルプシステム
zsh-help                    # 全体ヘルプ
zsh-help keybinds          # キーバインド一覧  
zsh-help aliases           # abbreviations一覧
zsh-help tools             # インストール済みツール確認

# パフォーマンス測定（ZSH_DEBUG=1環境下）
zsh-benchmark              # 起動時間計測
zsh-profile                # プロファイル情報表示

# 主要キーバインド
# ^]                       # fzf ghq repository selector
# ^g^g, ^g^s, ^g^a, ^g^b  # Git widgets  
# ^g^K                     # fzf kill process
```

### その他のプラグイン管理ツール

```bash
# zinit の場合
zinit load "$ZDOTDIR/sources/config-loader.zsh"

# oh-my-zsh の場合  
source "$ZDOTDIR/sources/config-loader.zsh"
```

### カスタマイズ

- **機能無効化**: `config/loaders/` の対象ファイルをリネーム・削除
- **新機能追加**: `config/loaders/` に新ローダー追加 + `config/loader.zsh` に読み込み処理追記

## 📈 パフォーマンス最適化実績

### 2024-06-06実装
- **起動時間**: 1.7秒 → 1.2秒（30%改善）
- **mise超遅延化**: 39.88ms削減（最重要最適化）
- **プラグイン順序**: 優先度別6段階グルーピング
- **全ファイルコンパイル**: zsh実行速度向上
- **段階的ツール読み込み**: クリティカルパス最優先

詳細は [CLAUDE.md](CLAUDE.md) を参照