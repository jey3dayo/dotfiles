# Integration Framework 詳細リファレンス

## アーキテクチャ概要

```
Integration Orchestrator
├─ Context Manager (TaskContext管理)
├─ Communication Bus (イベント駆動通信)
├─ Enhanced Task Router (インテリジェントルーティング)
├─ Error Handler (エラー回復)
│
├─ Agent Adapter
│  ├─ error-fixer
│  ├─ orchestrator
│  ├─ researcher
│  ├─ code-reviewer
│  └─ docs-manager
│
└─ Command Adapter
   ├─ /task
   ├─ /review
   ├─ /todos
   └─ /learnings
```

## クイックスタートパターン

### 基本的なタスク実行

```bash
# 自然言語タスクルーティング
/task "TypeScriptエラーを修正してコード品質を改善"

# フレームワークが自動的に:
# 1. 意図分析 → エラー修正 + 品質改善
# 2. error-fixerエージェントにルーティング
# 3. 品質パターンで修正を適用
# 4. フォローアップtodosとlearningsを生成
```

### マルチエージェントワークフロー

```bash
# 複雑な実装タスク
/task "セキュリティレビュー付きでユーザー認証を実装"

# フレームワークがワークフローを作成:
# 1. researcher → 認証要件を分析
# 2. orchestrator → 認証システムを実装
# 3. error-fixer → コード品質を確保
# 4. code-reviewer → セキュリティレビュー
```

### ハイブリッド実行

```bash
# コマンド + エージェント組み合わせ
/review --fix

# フレームワークの実行:
# 1. /reviewコマンド → プロジェクト固有のレビュー
# 2. error-fixerエージェント → 提案された修正を適用
# 3. 品質メトリクス → 統合レポート
```

## 統合ポイント

### コマンドからの使用

コマンドは自動的に統合の恩恵を受けます:

```bash
# /taskコマンドはインテリジェントルーティングを使用
/task "コード品質を改善"

# /reviewコマンドはプロジェクト検出を持つ
/review  # プロジェクトタイプを自動検出し、適切な基準を適用
```

**詳細**: `commands/task.md`, `commands/review.md`を参照

### エージェントの強化

エージェントは変更なしで強化されたコンテキストを受け取ります:

```javascript
// エージェントは自動的に以下を取得:
// - プロジェクト固有のコンテキスト
// - 強化されたエラー検出パターン
// - 履歴パフォーマンスデータ
// - 共有ワークフロー状態
```

### プロジェクト固有の設定

`.claude/integration-config.json`を作成:

```json
{
  "routing": {
    "preferredAgents": {
      "fix": "error-fixer",
      "implement": "orchestrator",
      "analyze": "researcher"
    },
    "workflowThreshold": 0.7,
    "autoFollowUp": true
  },
  "context": {
    "projectType": "typescript-react",
    "conventions": {
      "typeSafety": true,
      "testRequired": true
    }
  },
  "performance": {
    "cacheEnabled": true,
    "parallelExecution": true,
    "timeoutMs": 60000
  }
}
```

## 開発ワークフロー

### 新しいコマンドの作成

1. **TaskContextを理解**: `references/task-context-specification.md`を参照
2. **Command Adapterパターン**を使用: `references/adapters-and-orchestration.md`
3. **Communication Busと統合**: `references/communication-bus-api.md`
4. **エラーハンドリングを実装**: 統一されたError Handlerを使用

### 新しいエージェントの作成

1. **エージェント仕様を定義**: capabilities, input/output
2. **Agent Adapterで登録**: 標準化されたインターフェース
3. **TaskContextを活用**: プロジェクトコンテキストと実行状態を取得
4. **Communication Busを統合**: 他のコンポーネントとの通信

### テストとデバッグ

```bash
# デバッグモードを有効化
export CLAUDE_DEBUG=true
export CLAUDE_INTEGRATION_LOG=verbose

# 詳細なログが出力される
```

## ベストプラクティス

### 1. タスク記述

自然言語で記述的に:

```bash
# 良い
/task "ESLintエラーを修正してTypeScript型安全性を改善"

# より良い
/task "認証モジュールのコード品質問題をクリーンアップ"

# ベスト
/task "ユーザー認証のすべての型安全性問題を解決し、適切なエラーハンドリングと入力検証に焦点を当てる"
```

### 2. コンテキスト強化

関連するコンテキストを提供:

```bash
# 特定のファイルで作業
git add src/auth/*.ts
/task "セキュリティ問題のために認証実装をレビュー"
```

### 3. ワークフロー設計

複雑なタスクには、フレームワークにワークフローを作成させる:

```bash
# フレームワークが自動的にマルチステップワークフローを作成
/task "適切なエラーハンドリングとテストでOAuth2認証を実装"

# 結果:
# 1. researcher → OAuth2要件を分析
# 2. orchestrator → 認証フローを実装
# 3. error-fixer → エラーハンドリング品質を確保
# 4. code-reviewer → セキュリティとベストプラクティスのレビュー
```

### 4. 品質保証

実行後に品質メトリクスをレビュー:

```javascript
// 実行品質をチェック
if (result.qualityMetrics.overallScore < 0.8) {
  console.log("追加の品質チェックの実行を検討");
  console.log("提案:", result.followUpActions.suggestedCommands);
}
```

## 一般的なパターン

### パターン1: 単一エージェント実行

```javascript
// 直接エージェント呼び出し（後方互換性）
Task({
  subagent_type: "error-fixer",
  description: "エラーを修正",
  prompt: "TypeScriptエラーを修正",
});
```

### パターン2: オーケストレーター経由の実行

```javascript
// 強化された機能を持つ新しいアプローチ
const orchestrator = getOrchestrator();
const result = await orchestrator.executeTask({
  originalRequest: "TypeScriptエラーを修正",
  type: "command",
  source: "user-request",
});
```

### パターン3: ワークフロー実行

```javascript
// マルチエージェントワークフロー
const workflowResult = await communicationBus.executeWorkflow(
  {
    steps: [
      { name: "analyze", agent: "researcher" },
      { name: "implement", agent: "orchestrator" },
      { name: "review", agent: "code-reviewer" },
    ],
  },
  context,
);
```

## 移行ガイド

### 既存コードの互換性

フレームワークは100%の後方互換性を維持:

```javascript
// 古いアプローチはまだ動作
Task({
  subagent_type: "error-fixer",
  description: "エラーを修正",
  prompt: "TypeScriptエラーを修正",
});

// 新しいアプローチは強化された機能を提供
const result = await orchestrator.executeTask({
  originalRequest: "TypeScriptエラーを修正",
  type: "command",
  source: "user-request",
});
```

## 詳細リファレンス

より詳細な情報については、references/ディレクトリを参照してください:

- **task-context-specification.md**: TaskContext完全仕様、すべてのプロパティと型
- **communication-bus-api.md**: Communication Bus API、イベントパターン、ワークフロー実行
- **adapters-and-orchestration.md**: エージェント/コマンドアダプター実装、Integration Orchestrator
- **framework-api-reference.md**: Context Manager、Error Handler、パフォーマンス監視API

## 🤖 Agent Integration

このスキルはすべてのエージェントに統合フレームワークの知識を提供します:

### All Agents（全エージェント共通）

- **提供内容**: TaskContext標準化、Communication Busパターン、エラーハンドリング戦略
- **タイミング**: エージェント実行時に自動的にコンテキストを強化
- **コンテキスト**:
  - プロジェクト固有の実行コンテキスト
  - 強化されたエラー検出パターン
  - 履歴パフォーマンスデータ
  - 共有ワークフロー状態

### Orchestrator Agent

- **提供内容**: ワークフローオーケストレーション、マルチエージェント調整
- **タイミング**: 複雑なタスクの分割・実行時
- **コンテキスト**: Integration Orchestratorパターン、Communication Bus API

### Error-Fixer Agent

- **提供内容**: Error Handler統合、自動回復戦略
- **タイミング**: エラー修正・品質改善タスク実行時
- **コンテキスト**: エラー分類パターン、回復メカニズム、品質メトリクス

### 自動ロード条件

- コマンド開発時（command-creator使用時）
- エージェント開発時（agent-creator使用時）
- TaskContext、Communication Busに言及
- 統合フレームワーク、インテグレーションフレームワークに言及

**統合例**:

```
ユーザー: "新しいコマンドを作成したい"
    ↓
TaskContext作成
    ↓
プロジェクト検出: コマンド開発
    ↓
スキル自動ロード: integration-framework, command-creator
    ↓
エージェント選択: orchestrator
    ↓ (スキルコンテキスト提供)
統合フレームワークアーキテクチャ + コマンド作成パターン
    ↓
実行完了
```

## 関連スキル

- **command-creator**: 新しいコマンドの作成方法
- **agent-creator**: 新しいエージェントの作成方法
- **agents-and-commands**: エージェントとコマンドの使い分け

## 関連コマンド

- **/task**: インテリジェントタスクルーター（このフレームワークを使用）
- **/review**: 統合コードレビュー（プロジェクト検出を使用）

## 統合例

### 例1: /taskコマンドからの呼び出し

```bash
User: "/task Fix TypeScript errors"
  ↓
commands/task.md loads
  ↓
integration-framework skill (TaskContext理解)
  ↓
agent-selector (error-fixer選択)
  ↓
error-fixer agent (skill-enhanced context)
  ↓
Result + Learnings
```

### 例2: 新しいコマンド開発

```javascript
// Step 1: TaskContext理解
const context = contextManager.createContext(request);

// Step 2: Command Adapter使用
commandAdapter.registerCommand("my-command", {
  execute: async (args, context) => {
    // コマンドロジック
  },
});

// Step 3: Communication Bus統合
const result = await communicationBus.request("target-agent", message);
```

## パフォーマンスとモニタリング

```javascript
// システムステータス取得
const status = orchestrator.getSystemStatus();
console.log(`成功率: ${status.metrics.successRate}`);
console.log(`平均実行時間: ${status.metrics.averageTime}ms`);

// パフォーマンス分析
const analytics = orchestrator.getPerformanceAnalytics();
console.log("エージェントパフォーマンス:", analytics.agents);
console.log("ルーティング効率:", analytics.routing);
```

## トラブルシューティング

### デバッグモード

詳細なログを有効化:

```bash
export CLAUDE_DEBUG=true
export CLAUDE_INTEGRATION_LOG=verbose
```

### エラー分析

```javascript
// エラー統計を取得
const errorStats = errorHandler.getErrorStatistics();
console.log("エラー分布:", errorStats.byType);
console.log("回復成功率:", errorStats.recoveryRate);
```

## サポート

問題、質問、または貢献については:

1. **ドキュメント**: このガイドとインラインコメントを確認
2. **テスト**: 統合テストを実行して機能を検証
3. **デバッグ**: デバッグモードを有効にして詳細なログを取得
4. **パフォーマンス**: メトリクスと分析を監視して最適化

---

このスキルは、開発者がClaude Codeの統合フレームワークを理解し、効果的に活用するためのガイドです。完全な後方互換性を維持しながら、将来の拡張のための強固な基盤を提供します。
