---
name: integration-framework
description: |
  [What] Claude Code統合アーキテクチャガイド。TaskContext標準化、Communication Busパターン、エージェント/コマンドアダプター、エラーハンドリング、ワークフローオーケストレーションを提供します。コマンド/エージェント開発時、コンポーネント間通信実装時、または統合フレームワーク機能を使用する際に
  [When] Use when: 起動します。**常に日本語で応答します**。
  [Keywords] integration framework, Claude, Code, TaskContext, Communication, Bus
---

# Integration Framework

Claude Codeの統合フレームワークガイド。開発者向けにアーキテクチャ、コンポーネント統合、実装パターンを提供します。

## 概要

Integration Frameworkは、エージェントとコマンド間の結合性と相互運用性を改善する包括的なソリューションです。標準化されたインターフェース、インテリジェントなタスクルーティング、エラー回復、パフォーマンス最適化を提供し、既存のすべての機能を保持します。

### いつ使うか

このスキルは以下の場合に起動されます:

- 新しいコマンドやエージェントを開発する
- TaskContext構造について理解する必要がある
- Communication Busパターンを実装する
- エラーハンドリング戦略を設計する
- マルチエージェントワークフローを構築する
- コンポーネント間の統合ポイントを理解する

### トリガーキーワード

**日本語**:

- "統合フレームワーク", "インテグレーションフレームワーク"
- "TaskContext", "タスクコンテキスト"
- "Communication Bus", "コミュニケーションバス"
- "エージェント開発", "コマンド開発"
- "コンポーネント統合", "ワークフローオーケストレーション"

**English**:

- "integration framework"
- "TaskContext", "task context"
- "Communication Bus", "communication bus"
- "develop agent", "develop command", "agent development", "command development"
- "component integration", "workflow orchestration"

## コアコンセプト

### 1. TaskContext - 統一タスクコンテキスト

すべてのタスクは統一されたコンテキスト構造で動作します:

```typescript
interface TaskContext {
  id: string;
  type: "command" | "agent";
  source: string;

  project: {
    root: string;
    type: ProjectType;
    stack: TechStack[];
    conventions: ProjectConventions;
  };

  execution: {
    workingDirectory: string;
    targetFiles: string[];
    gitStatus: GitStatus;
    environment: EnvironmentInfo;
  };

  intent: {
    primary: Intent;
    secondary: Intent[];
    confidence: number;
    originalRequest: string;
  };

  communication: {
    parentTask?: string;
    childTasks: string[];
    sharedData: Record<string, any>;
  };
}
```

**詳細**: `references/task-context-specification.md`で完全な仕様を参照

### 2. Communication Bus - イベント駆動通信

コンポーネント間のシームレスな相互作用を実現:

```javascript
// イベント発行
communicationBus.publish({
  type: "task.started",
  source: "integration-orchestrator",
  data: { taskId, context },
});

// リクエスト-レスポンスパターン
const result = await communicationBus.request("error-fixer", {
  type: "fix-errors",
  files: ["src/index.ts"],
  context: enhancedContext,
});
```

**詳細**: `references/communication-bus-api.md`でAPIリファレンスを参照

### 3. Agent/Command Adapters - 統合アダプター

既存のエージェントとコマンドをフレームワークに統合:

- **Agent Adapter**: エージェントにTaskContextを提供
- **Command Adapter**: コマンド実行を標準化
- **Integration Orchestrator**: 全体の調整とルーティング

**詳細**: `references/adapters-and-orchestration.md`で実装パターンを参照

### 4. Error Handler - 高度なエラーハンドリング

包括的なエラー分類と回復:

```javascript
// 自動エラー回復
const recoveryResult = await errorHandler.handleError(error, context);

if (recoveryResult.success) {
  console.log(`✅ 自動回復成功: ${recoveryResult.strategy}`);
} else {
  console.log(`❌ 手動介入が必要: ${recoveryResult.recommendations}`);
}
```

## 詳細リファレンス

- アーキテクチャ/ワークフロー/パターン/トラブルシューティングは `references/integration-framework-details.md` を参照

## 次のステップ

1. 対象コンポーネントを洗い出し
2. 統合ポイントを選定
3. クイックスタートパターンで試作

## 関連リソース

- `references/integration-framework-details.md`
