# Command Creator 詳細リファレンス

## 5つのデザインパターン

### 1. Simple Direct Execution（シンプル実行）

### 適している場合:

- 単一ステップの操作
- クイックユーティリティ
- ステートレスな処理

**例:** `/format`, `/find-todos`

### 特徴:

- フェーズ分割不要
- 即座に結果を返す
- セッション管理不要

### テンプレート構造:

```markdown
1. 入力検証
2. 処理実行
3. 結果出力
```

### 2. Phase-Based Workflow（フェーズベース）

### 適している場合:

- 複数ステップが必要
- 各ステップで検証が必要
- 段階的な情報収集

**例:** `/review`, `/implement`

### 特徴:

- 5フェーズまで（通常は2-4フェーズ）
- 各フェーズに明確な責務
- フェーズ間で承認やフィードバック

### 標準フェーズ構造:

```markdown
### Phase 1: 分析・発見

[何を分析するか]

### Phase 2: 計画・戦略

[どう実行するか]

### Phase 3: 実行・実装

[実際の作業]

### Phase 4: 検証・確認

[結果の妥当性確認]

### Phase 5: 報告（任意）

[最終レポート]
```

### 3. Session Management（セッション管理）

### 適している場合:

- 反復的な改善作業
- 中断・再開が必要
- 進捗追跡が重要

**例:** `/refactor`, `/fix-imports`

### 特徴:

- セッション状態の永続化
- `resume`/`status`/`new` サブコマンド
- 進捗トラッキング

### セッションファイル:

```
{project}/.claude/sessions/{command}/
├── plan.md         # 計画と進捗
├── state.json      # 実行状態
└── history.log     # 操作履歴
```

### 必須サブコマンド:

- `/command resume` - セッション再開
- `/command status` - 進捗確認
- `/command new` - 新規セッション開始

### 4. Agent Orchestration（エージェント連携）

### 適している場合:

- 専門性の高い複数のサブタスク
- 並列実行が有効
- 結果の集約が必要

**例:** `/review --simple`, `/task`

### 特徴:

- Task toolでagentを呼び出し
- 並列または直列実行
- 結果の統合とレポート

### パターン:

```markdown
## Implementation

1. **タスク分析**: 必要なagentを特定
2. **並列実行**:
```

Task(subagent_type="security", ...)
Task(subagent_type="performance", ...)
Task(subagent_type="quality", ...)

```
3. **結果集約**: 各agentの出力を統合
4. **レポート生成**: 統一されたフィードバック
```

### 5. Interactive Approval（対話的承認）

### 適している場合:

- 重要な判断が必要
- 複数の選択肢がある
- ユーザーの意図確認が必須

**例:** `/kiro:spec-design`, `/scaffold`

### 特徴:

- AskUserQuestion toolを使用
- 計画を提示してから実行
- ドライラン / 本番モードの提供

### フロー:

```markdown
1. コンテキスト収集
2. 計画案を生成
3. **ユーザー承認を要求** ← 重要
4. 承認後に実行
5. 結果確認とフィードバック
```

## Shared Library統合

### 利用可能なShared Utilities

現在利用可能な共有ライブラリ:

- `commands/shared/agent-selector.md` - エージェント選択ロジック
- `commands/shared/refactoring-plan.md` - リファクタリング計画
- `commands/shared/project-detector.md` - プロジェクト

タイプ検出

- `commands/shared/error-handler.md` - エラー処理パターン

### Shared Libraryを作成すべき時

以下の条件を満たす場合:

- **3つ以上のコマンド**で使用されるロジック
- **複雑な操作**で標準化が有益
- **プラットフォーム固有**の抽象化（git、npm、dockerなど）

### 統合方法

```markdown
## Shared Libraries

このコマンドは以下のライブラリを使用します:

### 1. project-detector.md

- プロジェクトタイプの自動検出
- 技術スタックの識別
- 設定ファイルの検索

### 2. quality-checks.md

- lint実行
- test実行
- build検証
```

## ファイル構成

### 命名規則

- **kebab-case**: `command-name.md`
- **説明的**: 名前から機能が推測できる
- **一般的すぎない**: `helper` ではなく `import-resolver`

### ディレクトリ構造

```
commands/
├── [command].md              # 単独コマンド
├── shared/                   # 再利用可能ユーティリティ
│   ├── agent-selector.md
│   └── quality-checks.md
├── kiro/                     # 関連コマンドのグループ化
│   ├── spec-init.md
│   └── spec-design.md
├── clean/                    # 別のグループ例
│   ├── files.md
│   └── full.md
└── legacy/                   # 非推奨コマンド
    └── README.md
```

### グループ化の基準:

- **機能的関連性**: 同じワークフローの一部
- **ドメイン**: 特定領域に特化（kiro、clean、etc.）

## 統合ポイント

### Agentsとの統合

コマンドから専門的なagentを呼び出す:

```markdown
## Implementation

Task tool を使用して専門agentを呼び出します:

\`\`\`
Task(
subagent_type="code-reviewer",
description="コード品質レビュー",
prompt="変更されたファイルの品質をレビューしてください"
)
\`\`\`
```

### よく使用されるagents:

- `code-reviewer` - コード品質レビュー
- `security` - セキュリティ分析
- `performance` - パフォーマンス最適化
- `orchestrator` - 複雑なタスク調整

### Skillsとの統合

Skillsはキーワードで自動起動されますが、コマンドから明示的に言及できます:

```markdown
このコマンドは `typescript` skill を活用して型安全性を分析します。
```

### Task Toolとの連携

```markdown
## Agent Delegation Pattern

複数のagentを並列実行:

\`\`\`python

# 並列実行（single message, multiple Task calls）

results = await parallel_execute([
Task(subagent_type="security", task="脆弱性スキャン"),
Task(subagent_type="performance", task="パフォーマンス分析"),
Task(subagent_type="quality", task="コード品質チェック")
])

# 結果を集約

generate_unified_report(results)
\`\`\`
```

## 品質基準

### 必須要素チェックリスト

- [ ] YAMLフロントマターが正しい（description + argument-hint）
- [ ] 目的セクションで「なぜ」を説明
- [ ] 使用方法が明確で実行可能な例がある
- [ ] すべての引数・フラグが文書化されている
- [ ] エラー処理セクションがある
- [ ] 統合ポイントが明記されている

### ベストプラクティス

- [ ] 単一責任原則に従う（1つの明確な目的）
- [ ] 既存の類似コマンドのパターンを踏襲
- [ ] Shared librariesを適切に活用
- [ ] 関連agent/skillとの統合を文書化
- [ ] 長時間実行の場合はセッション管理を実装

### アンチパターン（避けるべきこと）

- ❌ 一回限りのタスクのためのコマンド（Task toolを直接使用すべき）
- ❌ Shared librariesに存在するロジックの複製
- ❌ 過度に複雑なコマンド（Skillにすべき）
- ❌ ファイルを直接変更するコマンド（Edit/Write toolを使用）
- ❌ 既存のagent/skillエコシステムとの統合の欠如

## Command vs Skill vs Agent 判断基準

| 観点         | Command                    | Skill                    | Agent                          |
| ------------ | -------------------------- | ------------------------ | ------------------------------ |
| **起動方法** | 明示的 `/command`          | キーワード自動起動       | Task tool経由                  |
| **複雑度**   | 線形ワークフロー           | 複雑な意思決定ツリー     | 集中的なサブタスク             |
| **状態**     | ステートレス or セッション | 会話を跨ぐコンテキスト   | 呼び出し毎にステートレス       |
| **スコープ** | 特定タスク実行             | ドメイン専門知識         | 委譲可能なサブコンポーネント   |
| **例**       | `/review`, `/format`       | `typescript`, `security` | `code-reviewer`, `performance` |

### Commandを選ぶべき時:

- ユーザーが明示的にワークフローを開始
- 複数フェーズの調整が必要
- セッション管理が必要
- 直接的なユーザーインタラクションが必須

### Skillを選ぶべき時:

- ドメイン専門知識が複数のインタラクションに跨る
- コンテキストが会話を通じて構築される
- キーワードベースの自動起動が価値ある
- ガイダンスが実行より重要

### Agentを選ぶべき時:

- タスクが大きなワークフローの委譲可能なサブコンポーネント
- ユーザーインタラクションなしの自律実行が必要
- 出力が親プロセスに戻される
- 専門知識が集中的で反復可能

## テンプレートとリソース

### スターターテンプレート

`resources/templates/command-template.md` に基本構造があります。

### 実例

以下の実例を参照してください:

- `resources/examples/simple-command.md` - シンプル実行パターン
- `resources/examples/phase-based-command.md` - フェーズベースパターン
- `resources/examples/session-managed-command.md` - セッション管理パターン

### 品質チェックリスト

`resources/checklist.md` に包括的なチェックリストがあります。

## コマンドのテスト

### ローカルテスト

1. **プロジェクト内配置**: まず `.claude/commands/` に配置
2. **YAML検証**: フロントマターが正しく解析されるか確認
3. **統合テスト**: 関連agent/skillとの連携を確認
4. **ドキュメント検証**: 例が記載通りに動作するか確認
5. **エッジケーステスト**: エラー条件を確認

### テスト手順

```bash
# 1. ローカルに配置
mkdir -p .claude/commands
cp my-command.md .claude/commands/

# 2. コマンド実行テスト
/my-command [args]

# 3. ヘルプ表示確認
/help
# → my-commandが表示されることを確認

# 4. エラーケーステスト
/my-command invalid-input
# → 適切なエラーメッセージが表示されるか確認
```

## Legacyコマンドからの移行

既存のlegacyコマンドを更新する場合:

1. `commands/legacy/README.md` で移行ガイドを確認
2. Shared librariesを使用するよう更新
3. 適用可能な場合はセッション管理を追加
4. 新しいagentシステムと統合
5. 新しいパターンでドキュメントを更新

## 次のステップ

コマンド作成後:

1. テスト用にプロジェクトの `.claude/commands/` に配置
2. プロジェクトのコマンドリストにドキュメント化
3. 汎用的に有用な場合はグローバルcommandsに共有を検討
4. より広いスコープが必要な場合はskillへの変換を検討

## 関連リソース

- **agent-creator skill**: サブエージェント定義の作成方法
- **rules-creator skill**: コマンドが強制するルールの作成方法
- **skill-creator skill**: より広いドメインの場合
- **agents-and-commands skill**: エージェントとコマンドの違い
- **integration-framework skill**: 統合パターン

---

このskillを使用して、一貫性があり、よく統合された高品質なslashコマンドを作成してください。

## 詳細リファレンス

- `references/index.md`
