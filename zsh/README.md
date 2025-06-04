# Zsh 設定構成

このプロジェクトのzsh設定は、XDG Base Directory仕様に準拠した効率的なモジュラー設計で管理されています。

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
│       ├── tools.zsh       # Tool settings読み込み
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
│   ├── fzf.zsh             # fzf設定・関数定義
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
│   ├── fzf.zsh             # fzf関連ユーティリティ
│   └── help.zsh            # ヘルプ機能
│
└── completions/            # カスタム補完ファイル
```

## 主要コンポーネント

### 1. プラグイン管理ツール

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
- **設定の統一**: abbreviationsファイルの重複を排除

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

### 5. コマンド省略形 (Abbreviations)

- **lazy-sources/abbreviations.zsh**: 依存チェック付きコマンド省略形
- **遅延読み込み**: zsh-abbrプラグイン読み込み後に実行
- 例: `l` → `eza -la`, `vim` → `nvim`, `gc` → `git commit -m`

## 特徴・利点

### パフォーマンス最適化

- 🚀 **高速起動**: 遅延読み込みによるシェル起動時間の短縮
- ⚡ **補完最適化**: XDG準拠キャッシュ + コンパイル済みファイル
- 🔄 **自動クリーンアップ**: 不要なキャッシュファイルの定期削除

### 開発効率・保守性

- 🎯 **SOLID原則**: 単一責任原則による機能分割
- 🔧 **豊富な機能**: fzf統合、Git拡張、開発ツール統合
- 📝 **省略形**: よく使うコマンドの効率的な入力
- 🧪 **テスタビリティ**: 各機能を独立してテスト可能
- 🛠️ **DRY原則**: 共通機能の重複排除

### 互換性・標準準拠

- 🌐 **クロスプラットフォーム**: macOS/Linux/WSL対応
- 📁 **XDG準拠**: 標準的なディレクトリ構造
- 🔌 **プラグイン管理ツール非依存**: sheldon、zinit、oh-my-zshなど様々なツールで利用可能
- 🔄 **移行容易性**: プラグイン管理ツール変更時も設定を維持

## 使い方

### 初回セットアップ

1. このディレクトリを`$XDG_CONFIG_HOME/zsh`（通常`~/.config/zsh`）に配置
2. `~/.zshenv`に`export ZDOTDIR="$XDG_CONFIG_HOME/zsh"`を設定
3. sheldonをインストールして`sheldon source > sheldon/sheldon.zsh`を実行

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

### カスタマイズ

```bash
# 特定機能の無効化（例：OS固有設定）
# config/loaders/os.zsh をリネームまたは削除

# 新機能の追加
# config/loaders/ に新しいローダーファイルを追加
# config/loader.zsh に読み込み処理を追記
```

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
```

## 改善提案

詳細な改善提案については [CLAUDE.md](CLAUDE.md) を参照してください。
