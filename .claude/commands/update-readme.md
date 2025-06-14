# README更新コマンド

複数のREADME.mdファイルを統一された構造とスタイルで更新・管理します。

## 使用方法

```bash
/project:update-readme
```

## 対象ファイル

### メインREADME
- **README.md** - ルートプロジェクト概要・クイックスタート・全体構成

### Tool別README管理

更新は必ずツール別に分類して実行します：

- **zsh/README.md** - Zsh設定詳細・パフォーマンス・起動時間最適化・使用方法
- **nvim/README.md** - Neovim設定・LSP・AI統合・プラグイン・Lua設定
- **wezterm/README.md** - WezTerm設定・キーバインド・テーマ・UI設定
- **ssh/README.md** - SSH設定・セキュリティ・1Password統合・接続最適化
- **tmux/README.md** - Tmux設定・セッション管理・プラグイン（必要に応じて作成）
- **git/README.md** - Git設定・ワークフロー・エイリアス（必要に応じて作成）

## 実行フロー

1. **Tool別現状分析**: 既存のREADMEファイルと設定状況をツール別に確認
2. **Tool別内容統合**: CLAUDE.mdとtool別learningsファイルの詳細情報をREADMEに統合
3. **Tool別構造統一**: 各ツールの特性に応じた一貫したMarkdown構造とスタイルを適用
4. **Tool間相互参照**: 適切なリンクと参照を設定
5. **Tool別情報更新**: 最新のパフォーマンス数値・機能・設定をツール別に反映

## 更新ポリシー

### 統一スタイル
- **パフォーマンス重視**: 数値的な改善を強調
- **モジュラー設計**: 各コンポーネントの独立性と統合を説明
- **実用性重視**: 実際の使用方法・コマンド・ワークフローを重視
- **メンテナンス**: 定期的な更新・最適化手順を明記

### 内容構成
```markdown
# Component Name
Brief description with key performance metrics

## ✨ Key Features
- Bulleted feature list with emojis and metrics

## 📈 Performance Metrics  
Table format with before/after comparisons

## 🏗️ Architecture
Directory structure and design principles

## 🎮 Essential Commands
Practical usage commands and workflows

## 🔧 Configuration Features
Detailed configuration options and customization

## 📊 Advanced Features
Power user features and integrations

## 📋 Maintenance
Regular tasks and troubleshooting
```

### バージョン管理
- **更新日時**: Last updated timestamp
- **変更理由**: 更新内容の簡潔な説明
- **互換性**: 既存設定との互換性維持

## 情報ソース

### 設定詳細
- **CLAUDE.md**: 技術的詳細・設計決定・パフォーマンス実績
- **設定ファイル**: 実際の設定値・オプション・プラグイン一覧
- **パフォーマンス測定**: ベンチマーク結果・最適化実績

### 使用パターン
- **よく使うコマンド**: zsh-help、ショートカット、ワークフロー
- **統合機能**: クロスツール連携・FZF統合・Git widgets
- **カスタマイズ**: 個人設定・環境別対応

## 品質チェック

### 内容検証
- **正確性**: 設定値・コマンド・パスの正確性確認
- **完全性**: 重要な機能・設定の網羅性確認
- **最新性**: パフォーマンス数値・機能の最新性確認

### 構造検証  
- **リンク**: 内部・外部リンクの動作確認
- **フォーマット**: Markdownの構文・スタイル統一
- **ナビゲーション**: 目次・セクション間の論理性

### 実用性検証
- **コマンド**: 掲載コマンドの動作確認
- **手順**: セットアップ・使用手順の検証
- **例示**: コード例・設定例の正確性

## 自動化対応

### 将来的な自動化
- **設定値抽出**: 設定ファイルからの自動値抽出
- **パフォーマンス測定**: 定期的なベンチマーク実行・結果反映
- **相互参照チェック**: リンク切れ・参照エラーの自動検出

### 手動プロセス
- **設計判断**: アーキテクチャ説明・設計原則の記述
- **使用体験**: 実際の使用感・ワークフローの記述
- **カスタマイズガイド**: 個人化・拡張方法の説明

---

*dotfiles全体の理解とメンテナンスを向上させるための包括的なドキュメント管理*