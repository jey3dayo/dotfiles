# Zsh 設定構成

このプロジェクトのzsh設定は、XDG Base Directory仕様に準拠した効率的なモジュラー設計で管理されています。

## ✅ 現在の状況 (2024-06-05)
- ✅ **完全動作**: 全ての主要機能が正常に動作
- ✅ **abbr修復済み**: 遅延読み込みで省略形機能が正常動作
- ✅ **モジュラーローダー**: プラグイン管理ツール非依存の設定システム
- ✅ **パフォーマンス最適化**: zsh-defer統合による高速起動
- ✅ **fzf統合完了**: 重複排除と責任分離による整理完了
- ✅ **Git機能統合**: Widget関数とabbreviationsの最適化・拡張
- ✅ **ヘルプシステム**: 包括的な`zsh-help`機能
- ✅ **デバッグツール**: パフォーマンス計測・プロファイリング機能

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

### パフォーマンス最適化

- 🚀 **高速起動**: 遅延読み込みによるシェル起動時間の短縮
- ⚡ **補完最適化**: XDG準拠キャッシュ + コンパイル済みファイル
- 🔄 **自動クリーンアップ**: 不要なキャッシュファイルの定期削除
- ✅ **検証済み高速化**: 最適化された読み込み順序で適切なタイミング制御

### 開発効率・保守性

- 🎯 **SOLID原則**: 単一責任原則による機能分割
- 🔧 **豊富な機能**: fzf統合、Git拡張、開発ツール統合
- 📝 **省略形**: よく使うコマンドの効率的な入力（✅ **動作中**）
- 🧪 **テスタビリティ**: 各機能を独立してテスト可能
- 🛠️ **DRY原則**: 共通機能の重複排除（✅ **fzf重複解消済み**）

### 互換性・標準準拠

- 🌐 **クロスプラットフォーム**: macOS/Linux/WSL対応
- 📁 **XDG準拠**: 標準的なディレクトリ構造
- 🔌 **プラグイン管理ツール非依存**: sheldon、zinit、oh-my-zshなど様々なツールで利用可能
- 🔄 **移行容易性**: プラグイン管理ツール変更時も設定を維持
- ✅ **実証済み信頼性**: 現在の実装はテスト済みで正常動作

## 使い方

### 初回セットアップ

1. このディレクトリを`$XDG_CONFIG_HOME/zsh`（通常`~/.config/zsh`）に配置
2. `~/.zshenv`に`export ZDOTDIR="$XDG_CONFIG_HOME/zsh"`を設定
3. sheldonをインストールして`sheldon source > sheldon/sheldon.zsh`を実行
4. ✅ **動作確認済み**: 現在のセットアップは完全に機能

### 動作確認コマンド

```bash
# 省略形のテスト（リストが表示されるはず）
abbr list

# 遅延読み込みのテスト
zsh -c "sleep 2; abbr list"

# プラグイン状況確認
sheldon list

# fzf統合機能テスト
ghq-repos  # GHQリポジトリ選択
# Ctrl+] でGHQウィジェット
# Ctrl+g, Ctrl+K でプロセス終了ウィジェット

# Git統合機能テスト
# Ctrl+g, Ctrl+g で git diff ウィジェット
# Ctrl+g, Ctrl+s で git status ウィジェット
# Ctrl+g, Ctrl+a で git add ウィジェット
# Ctrl+g, Ctrl+b で git branch select ウィジェット

# ヘルプシステムテスト
zsh-help              # 全体ヘルプ
zsh-help keybinds     # キーバインド一覧
zsh-help aliases      # abbreviations一覧
zsh-help functions    # カスタム関数一覧
zsh-help tools        # インストール済みツール確認

# デバッグ機能テスト（ZSH_DEBUG=1 環境下）
zsh-benchmark         # 起動時間計測
zsh-profile           # プロファイル情報表示
zsh-debug-info        # デバッグ情報表示
```

### 他のプラグイン管理ツールでの使用

```bash
# zinit の場合
zinit load "$ZDOTDIR/sources/config-loader.zsh"

# oh-my-zsh の場合
source "$ZDOTDIR/sources/config-loader.zsh"

# prezto の場合
zstyle ':prezto:load' pmodule 'custom'
# custom module で config-loader.zsh を読み込み
```

✅ **プラグイン管理ツール非依存**: `config-loader.zsh`はどのプラグイン管理ツールでも動作

### カスタマイズ

```bash
# 特定機能の無効化（例：OS固有設定）
# config/loaders/os.zsh をリネームまたは削除

# 新機能の追加
# config/loaders/ に新しいローダーファイルを追加
# config/loader.zsh に読み込み処理を追記
```

✅ **モジュラー設計**: 機能の追加・削除が独立して可能

### 補完キャッシュクリーンアップ

```bash
# 古い.zcompdumpファイルを手動削除
source functions/cleanup-zcompdump
cleanup_zcompdump
```

### プラグイン管理

```bash
# プラグイン追加後
sheldon source > sheldon/sheldon.zsh

# プラグイン一覧確認
sheldon list

# プラグイン更新
sheldon lock --update
```

## 状況・改善

### ✅ 最近の修正・追加機能

#### 2024-06-04
- **abbr機能**: 遅延読み込みのタイミング問題を修正
- **lazy-sources読み込み**: 適切な遅延読み込み機構を追加
- **設定統合**: モジュラーローダーシステムの動作確認
- **fzf統合**: 3つのファイル重複を1つに統合、責任分離を明確化

#### 2024-06-05
- **Git機能統合・最適化**: Widget関数とabbreviationsの大幅拡張
- **ヘルプシステム**: 包括的な`zsh-help`コマンド実装（6つのトピック対応）
- **デバッグ・プロファイリング**: `config/tools/debug.zsh`追加（パフォーマンス計測機能）
- **DRY原則適用**: Git関連ヘルパー関数による重複排除

### 📋 今後の改善予定
詳細な改善提案については [CLAUDE.md](CLAUDE.md) を参照してください。

### 🏆 達成事項
この設定は以下を成功裏に実現しています：
- プラグイン管理ツール非依存設計
- 高性能な遅延読み込み
- モジュラーで保守しやすいアーキテクチャ
- XDG準拠
- クロスプラットフォーム互換性
- 重複の排除と責任の明確な分離