---
name: project-maintenance
description: Project cleanup and maintenance automation with Serena semantic analysis and safety checks. Use when cleaning up unused code or maintaining project health.
disable-model-invocation: true
user-invocable: true
allowed-tools: Read, Grep, Glob, Bash, mcp__serena__*
argument-hint: [full|files] [options]
---

# Project Maintenance - プロジェクトメンテナンス自動化

プロジェクトクリーンアップとメンテナンスを自動化するスキル。MCP Serenaのセマンティック解析とセーフティチェックにより、安全かつ効率的なコード整理を実現します。

## 基本使用例

```bash
# フルクリーンアップ（包括的解析）
/project-maintenance full

# ターゲットクリーンアップ（ファイル単位）
/project-maintenance files [pattern]

# プレビューモード
/project-maintenance full --dry-run
/project-maintenance files --dry-run
```

## クリーンアップ戦略

### 1. フルクリーンアップ（Serenaセマンティック解析）

プロジェクト全体を包括的にクリーンアップ:

- **未使用シンボル検出**: 関数、クラス、変数の参照追跡
- **デバッグコード削除**: console.log、print、TODO等
- **import文整理**: 未使用インポートの自動削除
- **ドキュメント統合**: 重複解消と一貫性確保

### 実行フェーズ

1. セーフティチェック（Gitチェックポイント作成）
2. Serenaセマンティック解析
3. 未使用コード検出
4. 段階的クリーンアップ実行
5. 検証とレポート生成

### 2. ターゲットクリーンアップ（ファイル単位）

特定のファイル・パターンをクリーンアップ:

- **一時ファイル**: _.log, _.tmp, \*~
- **システムファイル**: .DS_Store, Thumbs.db
- **キャッシュファイル**: \*.pyc, **pycache**
- **プロジェクト固有**: カスタムパターン対応

### 保護機能

- `.claude/`, `.git/`, `node_modules/` 自動除外
- 設定ファイル保護（.env, config/\*）
- アクティブプロセスチェック

## セーフティチェック

全ての操作で以下を実行:

1. **事前検証**

   - Gitステータス確認
   - 未コミット変更の警告
   - チェックポイント自動作成

2. **参照確認**

   - Serena依存関係追跡
   - 未使用判定の精度確保
   - 段階的削除による安全性

3. **事後検証**
   - テスト実行（存在する場合）
   - リント/タイプチェック
   - ロールバック可能性確保

## クイックスタート

```bash
# 1. フルクリーンアップ（推奨）
/project-maintenance full

# 2. 一時ファイルのみ削除
/project-maintenance files "**/*.{log,tmp}"

# 3. プレビューで確認
/project-maintenance full --dry-run

# 4. 問題が発生した場合
git reset --hard HEAD~1  # チェックポイントに戻る
```

## 主要機能

### MCP Serena統合

- **セマンティック解析**: 構文だけでなく意味を理解
- **依存関係追跡**: 安全な削除判定
- **効率的検索**: パターンマッチング最適化
- **構造理解**: プロジェクト全体の把握

### プロジェクト判定

project-detectorとの統合により:

- プロジェクトタイプ自動判定
- 適切なクリーンアップルール選択
- 技術スタック固有の最適化

### 実行モード

```bash
# デフォルト: 包括的クリーンアップ
/project-maintenance full

# 選択的クリーンアップ
/project-maintenance full --code-only
/project-maintenance full --docs-only
/project-maintenance full --files-only

# セーフモード
/project-maintenance full --dry-run
```

## 実行レポート例

```markdown
🧹 **Cleanup Report**
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 📋 Summary

- Files processed: 45
- Lines removed: 892
- Files deleted: 12
- Documentation consolidated: 3 → 1

## 🔍 Code Analysis (MCP Serena)

- Unused functions: 8 removed
- Unused imports: 23 cleaned
- Debug statements: 15 removed
- TODO items: 7 tracked

## 📁 File Cleanup

- Temporary files: 12 removed (3.2MB freed)
- Log files: 8 removed (15.7MB freed)
- Cache files: 34 removed (128MB freed)
```

## 詳細リファレンス

このスキルの詳細仕様とベストプラクティスは以下を参照:

- **[フルクリーンアップ戦略](references/full-cleanup-strategy.md)** - Serenaセマンティック解析の詳細
- **[ターゲットクリーンアップ戦略](references/targeted-cleanup-strategy.md)** - ファイル単位クリーンアップ
- **[セーフティチェック](references/safety-checks.md)** - 事前検証と参照確認
- **[クリーンアップポリシー](references/cleanup-policies.md)** - 削除ポリシーとバックアップ

実用例とワークフロー:

- **[クリーンアップワークフロー](examples/cleanup-workflows.md)** - 実行例とベストプラクティス
- **[セーフティ検証](examples/safety-validation.md)** - セーフティチェック実行例
- **[ロールバック戦略](examples/rollback-strategies.md)** - 問題発生時の対処法

## 重要な注意事項

- 大規模プロジェクトでは段階的実行を推奨
- チーム開発では事前相談を推奨
- 重要な設定ファイルは事前確認
- `.cleanupignore` ファイルで除外パターン定義可能

## 他コマンドとの統合

- **`/review`**: クリーンアップ後の品質確認
- **`/polish`**: lint/format/test実行
- **`/docs`**: ドキュメント品質の最終確認
