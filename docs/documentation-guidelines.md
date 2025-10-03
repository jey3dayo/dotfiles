# 📚 ドキュメント管理体系

**最終更新**: 2025-10-03
**対象**: 開発者・運用担当者
**タグ**: `category/documentation`, `audience/developer`, `layer/support`

## 📋 概要

本文書では、dotfilesプロジェクトのドキュメント管理体系、タグ分類システム、メタデータ形式の統一ルールを定義します。

## 🏷️ タグ体系

タグは以下の接頭辞付き形式を使用します：`category/値`, `tool/値`, `layer/値`, `environment/値`, `audience/値`

### カテゴリタグ (`category/`)

- `category/shell` - Shell (Zsh) 関連の設定・最適化
- `category/editor` - エディタ (Neovim) 関連
- `category/terminal` - ターミナル (WezTerm, Tmux, Alacritty) 関連
- `category/git` - Git ワークフロー・ツール統合
- `category/performance` - パフォーマンス最適化・測定
- `category/integration` - ツール間統合・連携
- `category/configuration` - 各種設定ファイル管理
- `category/guide` - 実装ガイド・手順書
- `category/reference` - リファレンス・仕様書
- `category/maintenance` - メンテナンス手順
- `category/documentation` - ドキュメント管理関連

### ツールタグ (`tool/`)

- `tool/zsh` - Zsh シェル（起動時間1.1s目標）
- `tool/nvim` - Neovim エディタ（<100ms起動）
- `tool/wezterm` - WezTerm ターミナル
- `tool/tmux` - Tmux マルチプレクサ
- `tool/git` - Git バージョン管理
- `tool/fzf` - Fuzzy Finder 統合
- `tool/ssh` - SSH 設定管理
- `tool/mise` - バージョン管理ツール
- `tool/homebrew` - パッケージ管理

### 層タグ (`layer/`) - dotfiles特有

- `layer/core` - 核心設定（Shell, Git）
- `layer/tool` - ツール特化設定（Editor, Terminal）
- `layer/support` - 横断的関心事（Performance, Integration）

### 環境タグ (`environment/`)

- `environment/macos` - macOS 固有
- `environment/linux` - Linux 互換
- `environment/cross-platform` - プラットフォーム非依存

### 対象者タグ (`audience/`)

- `audience/developer` - 開発者向け
- `audience/ops` - 運用担当者向け
- `audience/beginner` - 初心者向け
- `audience/advanced` - 上級者向け

## 📝 メタデータ形式

全ドキュメントは以下の形式でメタデータを記載します：

```markdown
# [アイコン] [タイトル]

**最終更新**: YYYY-MM-DD
**対象**: [読者層]
**タグ**: `category/値`, `tool/値`, `layer/値`, `environment/値`
```

### 必須項目

- **最終更新**: YYYY-MM-DD形式
- **対象**: 対象者タグから選択（複数可）
- **タグ**: 接頭辞付きカテゴリ・ツール・層・環境タグの組み合わせ（3-5個推奨）

## 📊 ドキュメントマッピング表

| ファイル名                    | タグ                                                                              | 成熟度     | 難易度   | 更新頻度  | 概要                                   |
| ----------------------------- | --------------------------------------------------------------------------------- | ---------- | -------- | --------- | -------------------------------------- |
| docs/README.md                | `category/guide`, `layer/core`, `environment/macos`                               | Stable     | ⭐       | Quarterly | ドキュメントインデックス・設計パターン |
| docs/setup.md                 | `category/guide`, `category/configuration`, `environment/macos`                   | Stable     | ⭐⭐     | Quarterly | セットアップガイド・ベストプラクティス |
| docs/maintenance.md           | `category/maintenance`, `category/guide`, `layer/support`                         | Stable     | ⭐⭐     | Monthly   | 改善履歴・定期メンテナンス             |
| docs/performance.md           | `category/performance`, `layer/support`, `environment/cross-platform`             | Production | ⭐⭐⭐   | Monthly   | パフォーマンス測定・最適化指標         |
| docs/tools.md                 | `category/reference`, `tool/git`, `layer/core`, `environment/macos`               | Stable     | ⭐⭐     | Quarterly | Git ツール統合・FZF 連携               |
| docs/TODO.md                  | `category/guide`, `category/maintenance`                                          | Draft      | ⭐       | Weekly    | タスク管理・課題追跡                   |
| docs/tools/zsh.md             | `category/shell`, `tool/zsh`, `layer/core`, `environment/cross-platform`          | Production | ⭐⭐⭐⭐ | Monthly   | Zsh 最適化・プラグイン管理（1.1s起動） |
| docs/tools/nvim.md            | `category/editor`, `tool/nvim`, `layer/tool`, `environment/cross-platform`        | Production | ⭐⭐⭐⭐ | Monthly   | Neovim・LSP・AI支援（<100ms起動）      |
| docs/tools/wezterm.md         | `category/terminal`, `tool/wezterm`, `layer/tool`, `environment/macos`            | Stable     | ⭐⭐⭐   | Quarterly | WezTerm 設定・GPU加速                  |
| docs/tools/ssh.md             | `category/configuration`, `tool/ssh`, `layer/tool`, `environment/cross-platform`  | Stable     | ⭐⭐     | Quarterly | SSH 階層設定・セキュリティ             |
| docs/tools/fzf-integration.md | `category/integration`, `tool/fzf`, `layer/support`, `environment/cross-platform` | Production | ⭐⭐⭐⭐ | Quarterly | FZF 統合・Git 連携・Zsh ウィジェット   |

## 🔄 更新ルール

1. **ドキュメント更新時**

   - `最終更新` 日付を必ず更新
   - 重要な変更は成熟度を見直し

2. **新規ドキュメント作成時**

   - 本体系に従ってメタデータを設定
   - マッピング表への追加
   - 成熟度は Draft から開始

3. **タグ体系の拡張**
   - 新しいカテゴリが必要な場合は本文書を更新
   - 既存ドキュメントへの影響を確認

## 📏 ドキュメントサイズ管理

### 推奨サイズガイドライン

- **推奨サイズ**: 500行以内

  - Claude Code が一度に全文を把握可能
  - 読みやすく管理しやすい分量

- **警告サイズ**: 1000行

  - 分割を検討開始
  - セクション単位での分離を計画

- **上限サイズ**: 2000行
  - 必ず分割が必要
  - Claude Code の読み込み制限に近い

### 現在のドキュメントサイズ

| ファイル名                    | 行数  | 状態    |
| ----------------------------- | ----- | ------- |
| docs/tools/zsh.md             | 480行 | ✅ 適切 |
| docs/tools/nvim.md            | 350行 | ✅ 適切 |
| docs/tools/wezterm.md         | 280行 | ✅ 適切 |
| docs/tools/fzf-integration.md | 420行 | ✅ 適切 |
| docs/performance.md           | 250行 | ✅ 適切 |
| docs/setup.md                 | 320行 | ✅ 適切 |
| docs/maintenance.md           | 290行 | ✅ 適切 |
| docs/tools/ssh.md             | 180行 | ✅ 適切 |
| docs/tools.md                 | 220行 | ✅ 適切 |
| docs/README.md                | 150行 | ✅ 適切 |
| docs/TODO.md                  | 120行 | ✅ 適切 |

## 📂 分割基準と方法

### 分割を検討すべき状況

1. **コンテンツ過多**

   - セクション数が10を超える
   - 1000行を超える

2. **対象者の違い**

   - 初心者向けと上級者向けが混在
   - 設定と実装が混在

3. **更新頻度の違い**
   - 頻繁に更新される部分と安定している部分が混在

### 分割方法（dotfiles特化）

- **ツール別分割**: 主要3技術（Zsh/Neovim/WezTerm）は独立ファイル化済み
- **レベル別分割**: 基本設定と高度な最適化を分離
- **層別分割**: Core/Tool/Support 層ごとに分離
- **段階別分割**: セットアップ、運用、トラブルシューティングで分離

## 🔍 ドキュメント健全性チェック

### 定期レビュー

- **月次レビュー**: パフォーマンス関連ドキュメント（zsh.md, nvim.md, performance.md）
- **四半期レビュー**: 設定関連ドキュメント（wezterm.md, ssh.md, setup.md）
- **半期更新アラート**: 6ヶ月以上未更新のドキュメントを特定
- **年次棚卸し**: 全体的な再構成を検討

### 自動チェック項目

- **リンク切れ検証**: CI/CD での定期チェック
- **参照整合性**: 相互参照の有効性確認
- **メタデータ完全性**: 必須項目の記載確認
- **フォーマット統一**: `mise format` による自動整形

## 📊 品質指標

### 成熟度レベル

- **Draft**: 作成中・レビュー待ち
- **Review**: レビュー中・フィードバック反映中
- **Stable**: 完成・運用中（変更少ない）
- **Production**: 本番運用・高品質（パフォーマンス目標達成）

### 難易度レベル

- **⭐**: 基本的な内容・前提知識不要
- **⭐⭐**: 一定の知識が必要
- **⭐⭐⭐**: 専門的・詳細な技術知識が必要
- **⭐⭐⭐⭐**: 高度な最適化・アーキテクチャ理解が必要

### 更新頻度

- **Weekly**: 頻繁に更新（タスク管理）
- **Monthly**: 定期更新（パフォーマンス測定）
- **Quarterly**: 四半期レビュー（設定ファイル）
- **Yearly**: 年次レビューのみ（安定版）

## 🔄 dotfiles特有の考慮事項

### パフォーマンス影響の明記

パフォーマンスに影響を与える設定変更は、必ず以下を記載：

- **起動時間への影響**: Zsh (1.1s目標), Neovim (<100ms目標)
- **メモリ使用量**: プラグイン追加時の影響
- **測定方法**: `zsh-benchmark` などの測定コマンド

### 3技術中心の構成

- **Core Technologies**: Zsh, WezTerm, Neovim
  - これら3技術は最も詳細なドキュメント（⭐⭐⭐⭐）
  - 月次更新・Production 品質
- **Additional Tools**: Tmux, Homebrew, Mise など
  - 補完的なドキュメント（⭐⭐〜⭐⭐⭐）
  - 四半期更新・Stable 品質

### 統合連携の重視

ツール間連携は専用ドキュメント化：

- **FZF Integration**: Git, Zsh, ディレクトリ移動の統合
- **Shell ⇔ Terminal**: WezTerm + Zsh の連携
- **Editor ⇔ Terminal**: Neovim + WezTerm の統合

## 📝 メタデータ記載例

### Core Layer ドキュメント例

```markdown
# 🐚 Zsh Configuration & Optimization

**最終更新**: 2025-10-03
**対象**: 開発者・上級者
**タグ**: `category/shell`, `tool/zsh`, `layer/core`, `environment/cross-platform`
```

### Tool Layer ドキュメント例

```markdown
# 💻 Neovim Configuration Guide

**最終更新**: 2025-10-03
**対象**: 開発者・上級者
**タグ**: `category/editor`, `tool/nvim`, `layer/tool`, `environment/cross-platform`
```

### Support Layer ドキュメント例

```markdown
# ⚡ Performance Measurement & Optimization

**最終更新**: 2025-10-03
**対象**: 開発者・運用担当者
**タグ**: `category/performance`, `layer/support`, `environment/cross-platform`
```

## 🔗 関連リンク

- [メインドキュメント](./README.md) - ドキュメントインデックス
- [セットアップガイド](./setup.md) - 初期設定手順
- [メンテナンスガイド](./maintenance.md) - 定期メンテナンス
- [パフォーマンス指標](./performance.md) - 測定・最適化

## 📝 更新履歴

- **2025-10-03**: dotfiles プロジェクト向けドキュメント管理体系の新規定義
  - タグ体系の定義（category/tool/layer/environment/audience）
  - 11ドキュメントのマッピング表作成
  - サイズ管理・品質指標の設定
  - dotfiles特有の考慮事項（パフォーマンス・3技術中心・統合連携）を追加
