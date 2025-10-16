# 📖 Dotfiles Architecture & Documentation

**最終更新**: 2025-10-16
**対象**: 開発者
**タグ**: `category/guide`, `layer/core`, `environment/macos`

高性能macOS開発環境の設計思想とドキュメント体系を説明します。

## 🎯 設計思想

### 主要3技術の中核化

**Core Technologies**: Zsh + WezTerm + Neovim

この3技術がコード量・使用頻度・機能において中核を担い、他のツールはこれらを補完する支援的役割を果たします。

| Technology  | Role         | Performance | 詳細ガイド                     |
| ----------- | ------------ | ----------- | ------------------------------ |
| **Zsh**     | Shell環境    | 1.1s起動    | [zsh.md](tools/zsh.md)         |
| **Neovim**  | Editor環境   | <100ms起動  | [nvim.md](tools/nvim.md)       |
| **WezTerm** | Terminal環境 | 800ms起動   | [wezterm.md](tools/wezterm.md) |

### 設計原則

1. **Performance First**: 主要3技術の起動時間最適化
2. **Modular Design**: 明確な責任分離と階層化
3. **Primary Integration**: 3技術間のシームレス連携
4. **Unified Theme**: Gruvboxベース統一テーマ

## 🏗️ アーキテクチャ

### 層別構造（Layer-Based Architecture）

```
┌─────────────────────────────────────────┐
│         Support Layer                    │
│  Performance | Integration | Monitoring  │
│  横断的関心事                            │
└─────────────────────────────────────────┘
            ↑
┌─────────────────────────────────────────┐
│         Tool Layer                       │
│  Editor (Neovim) | Terminal (WezTerm)   │
│  ツール特化実装                          │
└─────────────────────────────────────────┘
            ↑
┌─────────────────────────────────────────┐
│         Core Layer                       │
│  Shell (Zsh) | Git                      │
│  核心設定                                │
└─────────────────────────────────────────┘
```

### ディレクトリ構造

```
dotfiles/
├── zsh/                   # Core: Shell configuration
│   ├── config/            # 設定ディレクトリ
│   │   ├── 01-environment.zsh
│   │   ├── 02-plugins.zsh
│   │   └── tools/         # ツール固有設定
│   └── sheldon/           # プラグイン管理
│
├── nvim/                  # Tool: Editor configuration
│   ├── lua/
│   │   ├── config/        # コア設定
│   │   ├── plugins/       # プラグイン設定
│   │   └── utils/         # ユーティリティ
│   └── init.lua
│
├── wezterm/               # Tool: Terminal configuration
│   ├── wezterm.lua
│   ├── keybinds.lua
│   └── ui.lua
│
├── git/                   # Core: Version control
│   ├── config
│   └── ignore
│
├── docs/                  # Documentation
│   ├── tools/             # ツール別ドキュメント
│   ├── performance.md     # Support: パフォーマンス
│   ├── maintenance.md     # Support: メンテナンス
│   └── setup.md           # ガイド
│
└── .claude/               # AI support
    └── commands/          # カスタムコマンド
```

## 📚 ドキュメント体系

### ドキュメント階層

#### 1. トップレベルドキュメント

- **[README.md](../README.md)**: ユーザー向け概要・クイックスタート
- **[CLAUDE.md](../CLAUDE.md)**: AI向け技術詳細・設計原則
- **[TOOLS.md](../TOOLS.md)**: 管理対象ツール一覧・ナビゲーション

#### 2. Core Layer ドキュメント

- **[Shell (Zsh)](tools/zsh.md)**: 1.1s起動、6段階プラグイン、パフォーマンス最適化
- **Git Integration**: FZF統合、50+省略語、カスタムウィジェット

#### 3. Tool Layer ドキュメント

- **[Editor (Neovim)](tools/nvim.md)**: <100ms起動、15+言語LSP、AI統合
- **[Terminal (WezTerm)](tools/wezterm.md)**: GPU加速、Lua設定、tmuxスタイル
- **[SSH](tools/ssh.md)**: 階層設定、セキュリティ管理

#### 4. Support Layer ドキュメント

- **[Performance](performance.md)**: 測定・監視・最適化戦略
- **[Maintenance](maintenance.md)**: 定期メンテナンス・トラブルシューティング
- **[FZF Integration](tools/fzf-integration.md)**: ツール間統合

#### 5. メタドキュメント

- **[Documentation Guidelines](documentation-guidelines.md)**: タグ体系・メタデータ・品質基準

### ドキュメント管理原則

全ドキュメントは統一されたメタデータ形式に従います：

```markdown
# [アイコン] [タイトル]

**最終更新**: YYYY-MM-DD
**対象**: [読者層]
**タグ**: `category/値`, `tool/値`, `layer/値`, `environment/値`
```

詳細は [Documentation Guidelines](documentation-guidelines.md) を参照。

## 🔧 設計パターン

### 1. モジュラー設計パターン

**原則**: 単一責任の原則に基づく明確な分離

**実装例（Zsh）**:

```
config/
├── core/              # コア機能
├── tools/             # ツール統合
└── functions/         # カスタム関数
```

### 2. 階層的設定パターン

**原則**: 環境依存を階層化して管理

**実装例（SSH）**:

```
~/.ssh/config          # ベース設定
~/.ssh/config.d/       # 環境別設定
├── personal
├── work
└── project
```

### 3. 遅延読み込みパターン

**原則**: パフォーマンスのための段階的初期化

**実装例（Zsh）**:

```toml
# sheldon/plugins.toml
[plugins.tier1-essential]  # 即座
[plugins.tier2-completion] # 必要時
[plugins.tier6-theme]      # 最後
```

### 4. 統合パターン

**原則**: ツール間のシームレスな連携

**実装例（FZF統合）**:

- Git: `Ctrl+g Ctrl+g` でstatus
- Zsh: `Ctrl+]` でリポジトリ選択
- ディレクトリ: `Ctrl+t` でファイル検索

## 📊 品質保証

### パフォーマンス目標

| Component | Target | Current    | Status |
| --------- | ------ | ---------- | ------ |
| Zsh       | <100ms | **1.1s**   | 🟡     |
| Neovim    | <200ms | **<100ms** | ✅     |
| WezTerm   | <1s    | **800ms**  | ✅     |

### メンテナンス頻度

| タスク             | 頻度      | コマンド                 |
| ------------------ | --------- | ------------------------ |
| パッケージ更新     | Weekly    | `brew update && upgrade` |
| パフォーマンス測定 | Monthly   | `time zsh -lic exit`     |
| プラグイン更新     | Monthly   | `sheldon update`         |
| 設定監査           | Quarterly | 手動レビュー             |

### Local CI Checks

```bash
# 全てのCIチェックをローカル実行
mise run ci

# 個別チェック
mise run format:biome:check
mise run format:markdown:check
mise run lint:lua
mise run format:shell:check
```

## 🚀 Quick Navigation

### 初めての方

1. [Setup Guide](setup.md) - インストール・初期設定
2. [README](../README.md) - 主要機能とコマンド
3. [TOOLS](../TOOLS.md) - ツール一覧

### 開発者向け

1. [Performance](performance.md) - 最適化戦略
2. [Maintenance](maintenance.md) - メンテナンス手順
3. [Documentation Guidelines](documentation-guidelines.md) - ドキュメント管理

### ツール別詳細

- [Zsh Configuration](tools/zsh.md)
- [Neovim Configuration](tools/nvim.md)
- [WezTerm Configuration](tools/wezterm.md)
- [SSH Configuration](tools/ssh.md)
- [FZF Integration](tools/fzf-integration.md)

## 🔄 継続的改善

### 改善プロセス

1. **測定**: パフォーマンス・品質メトリクス収集
2. **分析**: ボトルネック・課題の特定
3. **計画**: 改善策の優先順位付け
4. **実装**: 段階的な変更適用
5. **検証**: 効果測定と文書化

### 最近の改善

| 日付       | 内容                       | 効果                    |
| ---------- | -------------------------- | ----------------------- |
| 2025-10-16 | ドキュメント体系リファクタ | 情報の重複排除・明確化  |
| 2025-09    | AIコマンドシステム統合     | 開発効率向上            |
| 2025-07    | パフォーマンス目標達成     | 全主要指標クリア        |
| 2025-01    | mise即座初期化・PATH最適化 | Zsh 1.8s→1.1s (43%改善) |

---

_Architecture is not about perfection, but about continuous evolution towards better design._
