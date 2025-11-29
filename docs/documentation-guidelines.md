# 📚 ドキュメント管理体系

**最終更新**: 2025-11-30
**対象**: 開発者・運用担当者
**タグ**: `category/documentation`, `layer/support`, `environment/cross-platform`, `audience/developer`, `audience/ops`

## 📋 概要

本文書では、dotfilesプロジェクトのドキュメント管理体系、タグ分類システム、メタデータ形式の統一ルールを定義します。ドキュメント追加・改訂時のチェックリストとして利用してください。

## 🛠️ この文書の使い方（クイックチェック）

- [ ] メタデータを更新する（最終更新・対象・タグ）
- [ ] タグを3–5個選び、`category/` `tool/` `layer/` `environment/` `audience/` のバランスを取る
- [ ] 重複した内容はSST（setup/performance/maintenance/tool docs）へ集約し、READMEには参照だけを残す
- [ ] マッピング表の行を追加・更新し、成熟度/難易度/更新頻度を見直す
- [ ] サイズが500行以内か確認（1000行超は必ず分割計画）。**zsh.md は105行に縮小済み（500行超は分割計画）**
- [ ] 相互リンクと外部リンクを確認（CIリンク切れチェックも活用）
- [ ] パフォーマンスへ影響する変更は数値・測定方法を併記

## 🏷️ タグ体系

タグは接頭辞付き形式で統一します：`category/値`, `tool/値`, `layer/値`, `environment/値`, `audience/値`

### カテゴリタグ (`category/`)

- `category/shell` - Shell (Zsh) 関連
- `category/editor` - エディタ (Neovim)
- `category/terminal` - ターミナル (WezTerm, Tmux, Alacritty)
- `category/git` - Git ワークフロー・統合
- `category/performance` - パフォーマンス測定・最適化
- `category/integration` - ツール間連携
- `category/configuration` - 設定ファイル管理
- `category/guide` - 手順書・実装ガイド
- `category/reference` - リファレンス・仕様
- `category/maintenance` - メンテナンス手順
- `category/documentation` - ドキュメント管理

### ツールタグ (`tool/`)

- `tool/zsh`（起動目標1.1s）
- `tool/nvim`（<100ms起動）
- `tool/wezterm`
- `tool/tmux`
- `tool/git`
- `tool/fzf`
- `tool/ssh`
- `tool/mise`
- `tool/homebrew`

### 層タグ (`layer/`) - dotfiles特有

- `layer/core` - 核心設定（Shell, Git）
- `layer/tool` - ツール特化設定（Editor, Terminal）
- `layer/support` - 横断的関心事（Performance, Integration）

### 環境タグ (`environment/`)

- `environment/macos`
- `environment/linux`
- `environment/cross-platform`

### 対象者タグ (`audience/`)

- `audience/developer`
- `audience/ops`
- `audience/beginner`
- `audience/advanced`

## 📝 メタデータ形式

全ドキュメントは以下の形式でメタデータを記載します：

```markdown
# [アイコン] [タイトル]

**最終更新**: YYYY-MM-DD
**対象**: [読者層]
**タグ**: `category/値`, `tool/値`, `layer/値`, `environment/値`
```

### 必須項目

- **最終更新**: YYYY-MM-DD形式。内容を改訂した日に更新する。
- **対象**: 対象者タグから選択（複数可）。原則 `audience/` を含める。
- **タグ**: 接頭辞付きタグを3–5個。`category/` と `layer/` を最低1つずつ含める。

### 推奨追加

- 依存する設定ファイル・スクリプトへのパス
- 関連ドキュメントへの相互リンク

## 🚫 重複排除と Single Source of Truth

- **Setup**: `docs/setup.md` を唯一の手順書とし、README はリンクのみ。
- **Performance**: 数値・履歴・目標は `docs/performance.md` に統一。README/docs/README では重複掲載しない。
- **Maintenance**: 定期/臨時タスクは `docs/maintenance.md` に集約。
- **Doc rules**: タグ・メタデータ・チェックリストは本ドキュメントを参照。
- **Tool settings**: 各ツールの最適化は `docs/tools/*.md` を単一ソースとし、他では概要リンクに留める。
- **Navigation**: `docs/README.md` はリンクナビのみを記載し、内容は各SSTに任せる。

## 📊 ドキュメントマッピング表

| ファイル名                       | タグ                                                                                                          | 成熟度     | 難易度   | 更新頻度  | 概要                                   |
| -------------------------------- | ------------------------------------------------------------------------------------------------------------- | ---------- | -------- | --------- | -------------------------------------- |
| docs/README.md                   | `category/guide`, `layer/support`, `environment/macos`, `audience/developer`                                  | Stable     | ⭐       | Quarterly | ドキュメントインデックス・設計パターン |
| docs/documentation-guidelines.md | `category/documentation`, `layer/support`, `environment/cross-platform`, `audience/developer`, `audience/ops` | Stable     | ⭐⭐     | Quarterly | タグ体系・メタデータ・品質基準         |
| docs/setup.md                    | `category/guide`, `category/configuration`, `layer/core`, `environment/macos`, `audience/beginner`            | Stable     | ⭐⭐     | Quarterly | セットアップガイド・ベストプラクティス |
| docs/maintenance.md              | `category/maintenance`, `category/guide`, `layer/support`, `audience/developer`                               | Stable     | ⭐⭐     | Monthly   | 改善履歴・定期メンテナンス             |
| docs/performance.md              | `category/performance`, `layer/support`, `environment/cross-platform`, `audience/developer`, `audience/ops`   | Production | ⭐⭐⭐   | Monthly   | パフォーマンス測定・最適化指標         |
| docs/tools/zsh.md                | `category/shell`, `tool/zsh`, `layer/core`, `environment/cross-platform`, `audience/advanced`                 | Production | ⭐⭐⭐⭐ | Monthly   | Zsh 最適化・プラグイン管理（1.1s起動） |
| docs/tools/nvim.md               | `category/editor`, `tool/nvim`, `layer/tool`, `environment/cross-platform`, `audience/advanced`               | Production | ⭐⭐⭐⭐ | Monthly   | Neovim・LSP・AI支援（<100ms起動）      |
| docs/tools/wezterm.md            | `category/terminal`, `tool/wezterm`, `layer/tool`, `environment/macos`, `audience/developer`                  | Stable     | ⭐⭐⭐   | Quarterly | WezTerm 設定・GPU加速                  |
| docs/tools/ssh.md                | `category/configuration`, `tool/ssh`, `layer/tool`, `environment/cross-platform`, `audience/developer`        | Stable     | ⭐⭐     | Quarterly | SSH 階層設定・セキュリティ             |
| docs/tools/fzf-integration.md    | `category/integration`, `tool/fzf`, `layer/support`, `environment/cross-platform`, `audience/advanced`        | Production | ⭐⭐⭐⭐ | Quarterly | FZF 統合・Git 連携・Zsh ウィジェット   |

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

- **推奨サイズ**: 500行以内（Claude Code が全文把握しやすい）
- **警告サイズ**: 1000行（分割計画を必ず検討）
- **上限サイズ**: 2000行（強制分割）

### 現在のドキュメントサイズ（2025-11-30 時点）

| ファイル名                       | 行数 | 状態    |
| -------------------------------- | ---- | ------- |
| docs/tools/zsh.md                | 105  | ✅ 適切 |
| docs/tools/nvim.md               | 301  | ✅ 適切 |
| docs/tools/wezterm.md            | 132  | ✅ 適切 |
| docs/tools/fzf-integration.md    | 292  | ✅ 適切 |
| docs/tools/ssh.md                | 198  | ✅ 適切 |
| docs/performance.md              | 286  | ✅ 適切 |
| docs/setup.md                    | 67   | ✅ 適切 |
| docs/maintenance.md              | 140  | ✅ 適切 |
| docs/README.md                   | 87   | ✅ 適切 |
| docs/documentation-guidelines.md | 296  | ✅ 適切 |

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
- **zsh.md 分割パターン（サイズ超過時の例）**: 基本設定 / プラグイン管理 / パフォーマンス計測・チューニング / トラブルシュート

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
- **サイズ監視**: `wc -l docs/**/*.md` で閾値確認（zsh.md は優先的に分割計画）

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

- **起動時間への影響**: 影響がある場合は `docs/performance.md` の目標値と測定手順を参照し、本文では重複せずリンクで案内する。
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

- **2025-11-30**: zsh.md の再構成に伴いサイズ表と分割方針を更新（105行に縮小）
- **2025-11-27**: クイックチェックリスト追加・サイズ実測更新・zsh.md 分割候補を明示
- **2025-10-17**: 全ドキュメントへの audience タグ適用・日付統一
  - 全11ドキュメントに `audience/` タグを追加
  - `最終更新` 日付を 2025-10-17 に統一
  - ドキュメントマッピング表の更新
  - メタデータ形式の完全準拠確認
- **2025-10-03**: dotfiles プロジェクト向けドキュメント管理体系の新規定義
  - タグ体系の定義（category/tool/layer/environment/audience）
  - 11ドキュメントのマッピング表作成
  - サイズ管理・品質指標の設定
  - dotfiles特有の考慮事項（パフォーマンス・3技術中心・統合連携）を追加
