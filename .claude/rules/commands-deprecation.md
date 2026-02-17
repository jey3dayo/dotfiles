# Commands → Skills 移行ポリシー

## 現状（2026-02-12時点）

Commandsシステムは**廃止予定**です。現在、SkillsシステムへのPhased移行が進行中です。

### 移行フェーズ

| Phase   | ステータス | 対象                              | 期間     |
| ------- | ---------- | --------------------------------- | -------- |
| Phase 1 | ✅ 完了    | Foundation（基礎スキル作成）      | Week 1   |
| Phase 2 | ✅ 完了    | Core Workflows（主要6スキル移行） | Week 2-7 |
| Phase 3 | ✅ 完了    | Secondary（二次4スキル移行）      | Week 8   |
| Phase 4 | ✅ 完了    | Commands廃止マーキング            | Week 8   |
| Phase 5 | ✅ 完了    | 移行済みCommands削除（16+12件）   | Week 8   |
| Phase 6 | ✅ 完了    | Commands完全削除（50件）          | Week 8   |

### Phase 2 移行スキル（✅ 完了）

1. **learnings-knowledge** (2,056行) - AI駆動知見記録、7カテゴリシステム
2. **code-quality-automation** (2,989行) - lint/format/test自動実行、6言語対応
3. **implementation-engine** (1,600行) - 6フェーズ実装、セッション永続化
4. **todo-orchestrator** (3,452行) - P1-P5優先度、TodoWrite統合
5. **task-router** (3,829行) - 4フェーズ処理、Context7統合
6. **code-review-system** (3,595行) - 4モード実行、プロジェクト自動検出

### Phase 3 移行スキル（✅ 完了）

1. **git-automation** (4,451行) - Smart Commit + Auto PR、既存PR検出
2. **predictive-analysis** (3,405行) - リスク予測、4象限マトリクス
3. **documentation-management** (2,905行) - AI駆動ドキュメント管理、リンク検証
4. **project-maintenance** (4,143行) - Serenaセマンティック解析、3層セーフティ

### Phase 4 廃止マーキング（✅ 完了）

以下のCommandsファイルに廃止警告を追加：

#### Phase 3関連（6ファイル）

1. `commands/commit.md` → `git-automation`スキル
2. `commands/create-pr.md` → `git-automation`スキル
3. `commands/predict-issues.md` → `predictive-analysis`スキル
4. `commands/docs.md` → `documentation-management`スキル
5. `commands/clean/full.md` → `project-maintenance`スキル
6. `commands/clean/files.md` → `project-maintenance`スキル

#### 廃止警告内容

- 移行先スキル名とパス
- 新スキルの主要機能
- Phase 3完了日（2026-02-12）

### Phase 5 移行済みCommands削除（✅ 完了）

#### Phase 2関連（10ファイル）

1. `commands/learnings.md` → learnings-knowledge
2. `commands/polish.md` → code-quality-automation
3. `commands/implement.md` → implementation-engine
4. `commands/todos.md` → todo-orchestrator
5. `commands/create-todos.md` → todo-orchestrator
6. `commands/find-todos.md` → todo-orchestrator
7. `commands/fix-todos.md` → todo-orchestrator
8. `commands/task.md` → task-router
9. `commands/review.md` → code-review-system

**Phase 3関連（6ファイル）** ← 既にPhase 4で廃止警告追加済み:

1. `commands/commit.md` → git-automation
2. `commands/create-pr.md` → git-automation
3. `commands/predict-issues.md` → predictive-analysis
4. `commands/docs.md` → documentation-management
5. `commands/fix-docs.md` → documentation-management
6. `commands/clean/full.md` → project-maintenance
7. `commands/clean/files.md` → project-maintenance

**削除結果**: 16ファイル完全削除（廃止警告→削除への移行完了）

### Phase 5.1 Kiro Commands削除（✅ 完了）

**Kiro関連（12ファイル）** ← cc-sdd スキルで統合済み:

1. `commands/kiro/spec-init.md` → cc-sdd
2. `commands/kiro/spec-requirements.md` → cc-sdd
3. `commands/kiro/spec-design.md` → cc-sdd
4. `commands/kiro/spec-tasks.md` → cc-sdd
5. `commands/kiro/spec-impl.md` → cc-sdd
6. `commands/kiro/spec-status.md` → cc-sdd
7. `commands/kiro/spec-quick.md` → cc-sdd
8. `commands/kiro/validate-design.md` → cc-sdd
9. `commands/kiro/validate-gap.md` → cc-sdd
10. `commands/kiro/validate-impl.md` → cc-sdd
11. `commands/kiro/steering.md` → cc-sdd
12. `commands/kiro/steering-custom.md` → cc-sdd

**削除理由**: cc-sdd スキル（agents/internal/skills/cc-sdd/）で既に完全統合済み

### Phase 6 Commands完全削除（✅ 完了）

#### 全Commandsディレクトリ削除（50ファイル）

#### トップレベル（32ファイル）

- spec-_, validate-_, steering-\* (kiro重複)
- agent-selector.md, claude-metadata-analyzer.md (統合関連)
- context7-integration.md, integration-matrix.md (統合関連)
- task-context.md, skill-mapping-engine.md (統合関連)
- project-detector.md, error-handler.md (shared重複)
- debug-chrome.md, maintain-claude.md, make-it-pretty.md (未移行)
- contributing.md, migration-guide.md, README.md (ドキュメント)
- その他

#### shared/（18ファイル）

- \*.py: agent_selector.py, project_detector.py, ci_operations.py等
- \*.md: 各種統合ドキュメント

#### 削除理由

- 主要機能は13スキルに完全移行済み
- 統合関連ドキュメントは integration-framework スキルに統合
- shared/ユーティリティはスキル内で再実装
- 未移行Commandsは使用頻度低く、必要時に再実装可能

**Commands廃止完了**: agents/internal/commands/ ディレクトリ全体削除

## 移行統計

### 総合

- 移行完了スキル数: 13件（Foundation 3件 + Core 6件 + Secondary 4件）
- 元のコマンド行数: 2,020行（Phase 3分のみ）
- 新スキル総行数: 32,425行（Phase 1-3合計）
- 拡張率: 16.1倍（体系的仕様化と実用例追加）
- Progressive Disclosure効率: 初回ロード平均8.8%（91.2%トークン削減）

### Phase別詳細

#### Phase 1 (Foundation)

- agents-only: 1,663行
- docs-index: 862行
- integration-framework: 統合実施

#### Phase 2 (Core Workflows)

- 総行数: 17,521行
- 平均トークン削減: 91.9%

#### Phase 3 (Secondary)

- 総行数: 14,904行
- 平均トークン削減: 69%

## 開発ガイドライン

### 新規機能開発

**必須**: 新規機能は**Skillsとして実装**してください。Commandsとしての実装は禁止です。

#### 理由

- Commands廃止予定のため、新規Commandsは技術的負債となる
- Skillsの方が機能的に優れている（Progressive Disclosure、サポートファイル、高度な制御）
- 移行作業の負担を増やさない

### 既存Commands修正

**移行予定のCommands**: 最小限の修正のみ（重大なバグ修正のみ）
**移行対象外のCommands**: 通常通り修正可能（ただしSkills移行を推奨）

### 移行期間中のルール

**両対応が必要な期間**: Phase 2完了まで（約1ヶ月）

- 既存Commandsはそのまま動作する
- 新規Skillsから旧Commandsを呼び出す場合あり
- ドキュメントでは両方を併記（Commandsに「廃止予定」マーク）

## Skills vs Commands

### Skillsの利点

1. Progressive Disclosure: 初回ロード軽量（<20KB）、詳細は必要時にロード
2. サポートファイル: ディレクトリ構造でテンプレート、サンプル、スクリプトを整理
3. 呼び出し制御: `disable-model-invocation`, `user-invocable`で実行タイミングを細かく制御
4. Agent Skills標準: 複数のAIツール間で相互運用可能
5. 動的コンテキスト注入: `` `!command` ``でリアルタイムデータ取得

### Commandsの制限

- 単一ファイル（`.md`）、全体がコンテキストにロード
- 大規模Commandsでコンテキストウィンドウ圧迫
- サポートファイルの管理が困難
- 呼び出し制御が限定的

## 質問・フィードバック

移行に関する質問や提案は、`agents-only`スキルまたは`integration-framework`スキルを参照してください。

---

**最終更新**: 2026-02-12
**移行完了**: Phase 1-5（Foundation + Core + Secondary + 廃止警告 + Commands削除）
**残存Commands**: なし（完全削除完了）
**次回作業**: Skills運用と継続的改善
