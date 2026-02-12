# Todo Orchestrator - 統合タスク管理システム

---

name: todo-orchestrator
description: Unified task management system with interactive execution and AI-driven analysis. Shows TODO list, allows selection, executes tasks. Use when managing tasks, checking progress, or executing planned work.
argument-hint: [add [description]] [--list] [--priority=<level>] [--suggest]
disable-model-invocation: true
user-invocable: true
allowed-tools: Read, Write, Edit, Bash, Grep, TodoWrite

---

## 概要

Todo Orchestratorは、**TodoWrite + .claude/TODO.md**を統合したインテリジェントなタスク管理システムです。インタラクティブなUI、AI駆動の優先度分析、依存関係の自動検出により、効率的なタスク実行をサポートします。

**統合データソース**:

- **TodoWrite**: セッション内タスク、リアルタイム更新
- **.claude/TODO.md**: 永続的タスク、人間編集可能、Git管理

**主な特徴**:

- **インタラクティブモード**: 番号選択 → 確認 → 実行 → 自動更新
- **AI駆動優先度分析**: 複雑度・影響範囲・依存関係を自動評価
- **依存関係管理**: ブロック状態の検出と実行順序の最適化
- **スマート実行**: 並列実行、バッチ処理、工数推定
- **品質保証統合**: 実行前後の自動チェック

## 使用方法

### 基本的な使用

```bash
# インタラクティブモード（推奨）
todo-orchestrator

# タスク一覧表示のみ
todo-orchestrator --list

# タスク追加（AI分析付き）
todo-orchestrator add "新しいタスクの説明"

# 優先度指定で追加
todo-orchestrator add "緊急タスク" --priority=P1

# AI候補提案
todo-orchestrator --suggest
```

### インタラクティブモードの基本フロー

1. **タスク表示・選択**: 統合タスク一覧（優先度ソート済み）から番号選択
2. **実行前確認**: 依存関係・影響範囲・推定工数を確認
3. **自動実行**: タスク実行、進捗表示、エラーハンドリング
4. **結果更新**: TodoWrite更新、学習データ蓄積

**選択オプション**:

- 番号指定: `1`, `3`, `1-5`, `1,3,5`
- 優先度一括: `high`, `medium`, `low`
- スキップ: `skip`, `s` で次回まで延期

## 主要機能

### 1. インタラクティブ実行

番号選択による直感的なタスク実行フロー。依存関係チェック、実行前確認、リアルタイム進捗表示。

**詳細**: [references/interactive-execution-flow.md](references/interactive-execution-flow.md)

### 2. 統合タスク管理

TodoWriteと.claude/TODO.mdを統合表示。優先度ソート、重複排除、自動同期。

**詳細**: [references/data-source-integration.md](references/data-source-integration.md)

### 3. AI駆動優先度システム

**P1 🟢 即座実行**: 1-2時間、簡単、安全、即座に着手可能
**P2 🟡 標準実行**: 半日、中程度、検証必要、標準的な作業フロー
**P3 🟠 慎重実行**: 1-2日、複雑、テスト必要、慎重な計画と実装
**P4 🟦 統合実行**: 複数コンポーネント、統合テスト、依存関係考慮
**P5 🔴 計画実行**: 1週間以上、設計検討、高リスク、大規模変更

**詳細**: [references/priority-system.md](references/priority-system.md)

### 4. Todo追加機能（AI分析）

タスク説明から自動的に以下を分析:

- **要件抽出**: タスクの具体的要件を明確化
- **影響範囲**: 変更が及ぶコンポーネントを特定
- **優先度評価**: P1-P5の自動判定（複雑度・リスク・緊急度）
- **依存関係**: ブロック/被ブロックタスクを特定
- **工数推定**: 実装時間の見積もり

**詳細**: [references/todo-add-flow.md](references/todo-add-flow.md)

### 5. スマート実行モード

```bash
# 自動最適化実行
todo-orchestrator --mode=auto

# インテリジェント優先順位
todo-orchestrator --mode=smart

# 並列実行（依存関係考慮）
todo-orchestrator --mode=parallel

# 工数推定のみ
todo-orchestrator --mode=estimate

# バッチ実行
todo-orchestrator batch high           # 高優先度一括
todo-orchestrator batch 1-5,8          # 範囲指定
todo-orchestrator batch quick          # P1のみ
```

**詳細**: [examples/smart-modes.md](examples/smart-modes.md)

## 基本使用例

### 例1: インタラクティブ選択

```
$ todo-orchestrator

=== 統合タスク一覧 ===
[1] 🟢 P1 | Fix login validation bug (1h)
[2] 🟡 P2 | Add user profile page (4h)
[3] 🟠 P3 | Refactor auth module (1d) [blocks: 1]
[4] 🟦 P4 | Implement SSO integration (2d) [blocked by: 3]

実行するタスク番号を選択: 1

=== 実行前確認 ===
タスク: Fix login validation bug
優先度: P1 (即座実行)
推定工数: 1時間
依存関係: なし
影響範囲: auth/login.ts, tests/auth.test.ts

実行しますか? (y/n/skip): y

[実行中] Fix login validation bug...
✓ コード修正完了
✓ テスト実行: PASS
✓ Lint/Format: PASS

[完了] タスク完了。TodoWrite更新済み。
```

### 例2: タスク追加（AI分析）

```
$ todo-orchestrator add "パスワードリセット機能の実装"

[分析中] タスク要件を分析しています...

=== AI分析結果 ===
優先度: P2 (標準実行)
理由: 標準的な機能追加、既存パターン踏襲可能

推定工数: 4-6時間
- メール送信設定: 1h
- トークン生成・検証: 2h
- UI実装: 1-2h
- テスト: 1h

影響範囲:
- auth/password-reset.ts (新規)
- auth/email-service.ts (変更)
- pages/reset-password.tsx (新規)

依存関係:
- メール送信機能が必要 (SMTP設定)

追加しますか? (y/n/edit): y
✓ タスク追加完了
```

### 例3: 高優先度バッチ実行

```
$ todo-orchestrator batch high

=== 高優先度タスク（P1-P2） ===
[1] 🟢 P1 | Fix validation bug (1h)
[2] 🟢 P1 | Update error messages (30m)
[3] 🟡 P2 | Add loading states (2h)

3タスクを実行します。続行しますか? (y/n): y

[1/3] Fix validation bug... ✓ 完了 (52m)
[2/3] Update error messages... ✓ 完了 (28m)
[3/3] Add loading states... ✓ 完了 (1h 45m)

=== バッチ実行完了 ===
成功: 3/3
合計時間: 3h 5m
```

## データソース統合

### TodoWrite（セッション内）

- リアルタイム更新
- 会話コンテキスト内
- 一時的なタスク

### .claude/TODO.md（永続的）

- Git管理可能
- 人間編集可能
- プロジェクト全体

### 統合表示

両ソースを統合し、優先度ソート、重複排除、自動同期。

**詳細**: [references/data-source-integration.md](references/data-source-integration.md)

## 品質保証チェックリスト

### 計画段階

- [ ] 要件が明確化されている
- [ ] 影響範囲が特定されている
- [ ] 依存関係が確認されている
- [ ] 優先度が適切に設定されている

### 実行段階

- [ ] 実行前確認が完了している
- [ ] 依存タスクがブロックされていない
- [ ] 実行ログが記録されている
- [ ] エラーハンドリングが適切

### 完了段階

- [ ] テストが全て成功している
- [ ] Lint/Formatが通っている
- [ ] TodoWriteが更新されている
- [ ] 学習データが蓄積されている

## 関連スキル・コマンド

- **[task-context](../task-context/)**: タスクコンテキスト管理（軽依存）
- **TodoWrite**: 統合必須ツール
- **/task**: 自然言語タスク実行
- **/learnings**: 実行パターン学習

## 制約・注意事項

### 実行制約

- **依存関係**: ブロックされているタスクは自動スキップ
- **並列実行**: ファイル競合がある場合は順次実行
- **エラー時**: 実行を中断し、状態をロールバック

### データ整合性

- TodoWriteと.claude/TODO.mdの同期を定期確認
- 重複タスクは統合表示時に自動マージ
- 優先度変更時は両ソースに反映

### 品質保証

- P1-P2は実行前確認を簡略化可能
- P3-P5は必ず実行前確認を行う
- テスト失敗時は自動ロールバック

## 詳細リファレンス

- **[インタラクティブ実行フロー](references/interactive-execution-flow.md)**: Phase 1-3の詳細UI
- **[優先度システム](references/priority-system.md)**: P1-P5の判定基準と実行戦略
- **[Todo追加フロー](references/todo-add-flow.md)**: AI駆動分析の5要素
- **[データソース統合](references/data-source-integration.md)**: TodoWrite + .claude/TODO.md統合
- **[実行パターン集](examples/interactive-patterns.md)**: 実際の実行例とログ
- **[スマート実行モード](examples/smart-modes.md)**: auto/smart/parallel/estimate/batch
