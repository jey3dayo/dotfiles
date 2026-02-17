---
skill: integration-framework
topic: Communication Bus API
last-updated: 2025-12-22
audience: Developer
---

# Communication Bus API完全リファレンス

## 概要

Communication Busは、Claude Code統合フレームワークにおけるコンポーネント間通信の中核です。イベント駆動アーキテクチャを提供し、エージェント、コマンド、および統合コンポーネント間のシームレスな相互作用を実現します。

### 目的

- **疎結合**: コンポーネント間の直接的な依存関係を排除
- **非同期通信**: イベントベースの非ブロッキング通信
- **ワークフロー調整**: マルチステップワークフローの実行管理
- **状態管理**: コンポーネント間での状態共有

### いつ使うか

- エージェント間でメッセージを送受信する
- マルチエージェントワークフローを実行する
- コンポーネント間でイベントを発行/購読する
- 非同期リクエスト-レスポンスパターンを実装する

## Communication Busインターフェース

```typescript
class CommunicationBus {
  // イベント発行
  publish(event: Event): void;

  // イベント購読
  subscribe(eventType: string, handler: EventHandler): Unsubscribe;

  // リクエスト-レスポンス
  request(
    target: string,
    message: Message,
    timeout?: number,
  ): Promise<Response>;

  // ワークフロー実行
  executeWorkflow(
    workflow: Workflow,
    context: TaskContext,
  ): Promise<WorkflowResult>;

  // メトリクス取得
  getMetrics(): BusMetrics;

  // クリーンアップ
  shutdown(): Promise<void>;
}
```

## イベント発行パターン

### 基本的なイベント発行

```typescript
// イベント定義
interface Event {
  type: string; // イベントタイプ（例: "task.started"）
  source: string; // イベント発行元
  data: any; // イベントデータ
  timestamp?: Date; // タイムスタンプ
  metadata?: EventMetadata; // メタデータ
}

// イベント発行
communicationBus.publish({
  type: "task.started",
  source: "integration-orchestrator",
  data: {
    taskId: "task-123",
    context: taskContext,
  },
  timestamp: new Date(),
});
```

### 標準イベントタイプ

```typescript
// タスクライフサイクルイベント
enum TaskEvent {
  Started = "task.started",
  Completed = "task.completed",
  Failed = "task.failed",
  Cancelled = "task.cancelled",
  Retrying = "task.retrying",
}

// エージェントイベント
enum AgentEvent {
  Invoked = "agent.invoked",
  Executing = "agent.executing",
  Completed = "agent.completed",
  Error = "agent.error",
}

// コマンドイベント
enum CommandEvent {
  Started = "command.started",
  Completed = "command.completed",
  Error = "command.error",
}

// ワークフローイベント
enum WorkflowEvent {
  Started = "workflow.started",
  StepCompleted = "workflow.step.completed",
  Completed = "workflow.completed",
  Failed = "workflow.failed",
}
```

### イベント発行例

```typescript
// タスク開始イベント
communicationBus.publish({
  type: TaskEvent.Started,
  source: "task-router",
  data: {
    taskId: context.id,
    taskType: context.type,
    intent: context.intent.primary,
  },
});

// エージェント完了イベント
communicationBus.publish({
  type: AgentEvent.Completed,
  source: "error-fixer",
  data: {
    taskId: context.id,
    result: {
      fixedErrors: 5,
      files: ["src/index.ts"],
    },
  },
});

// ワークフローステップ完了イベント
communicationBus.publish({
  type: WorkflowEvent.StepCompleted,
  source: "workflow-orchestrator",
  data: {
    workflowId: workflow.id,
    stepName: "analyze",
    stepResult: analysisResult,
  },
});
```

## イベント購読パターン

### 基本的なイベント購読

```typescript
// イベントハンドラー型
type EventHandler = (event: Event) => void | Promise<void>;

// イベント購読
const unsubscribe = communicationBus.subscribe(
  "task.completed",
  async (event) => {
    console.log("Task completed:", event.data);
    // 追加処理
    await updateMetrics(event.data);
  },
);

// 購読解除
unsubscribe();
```

### 複数イベントタイプの購読

```typescript
// パターンマッチング購読
const unsubscribe = communicationBus.subscribe(
  "task.*", // task.started, task.completed等すべて
  (event) => {
    console.log(`Task event: ${event.type}`, event.data);
  },
);

// 複数の個別イベント購読
const taskEvents = [TaskEvent.Started, TaskEvent.Completed, TaskEvent.Failed];

const unsubscribers = taskEvents.map((eventType) =>
  communicationBus.subscribe(eventType, (event) => {
    handleTaskEvent(event);
  }),
);

// すべて購読解除
unsubscribers.forEach((unsub) => unsub());
```

### 条件付きイベント処理

```typescript
// 特定条件のイベントのみ処理
communicationBus.subscribe("agent.completed", (event) => {
  // error-fixerからのイベントのみ処理
  if (event.source === "error-fixer") {
    handleErrorFixerCompletion(event.data);
  }
});

// フィルタリング関数
const unsubscribe = communicationBus.subscribe("task.*", (event) => {
  // 高優先度タスクのみ
  if (event.data.priority === "high") {
    handleHighPriorityTask(event);
  }
});
```

## リクエスト-レスポンスパターン

### 基本的なリクエスト-レスポンス

```typescript
// メッセージ定義
interface Message {
  type: string;
  data: any;
  context?: TaskContext;
  timeout?: number;
}

// レスポンス定義
interface Response {
  success: boolean;
  data: any;
  error?: Error;
  metadata?: ResponseMetadata;
}

// リクエスト送信
const response = await communicationBus.request("error-fixer", {
  type: "fix-errors",
  data: {
    files: ["src/index.ts"],
    errorTypes: ["typescript", "lint"],
  },
  context: taskContext,
});

if (response.success) {
  console.log("Fixed errors:", response.data);
} else {
  console.error("Error fixing failed:", response.error);
}
```

### タイムアウト付きリクエスト

```typescript
// タイムアウト設定（ミリ秒）
try {
  const response = await communicationBus.request(
    "researcher",
    {
      type: "analyze-codebase",
      data: { directory: "src/" },
    },
    30000, // 30秒タイムアウト
  );

  console.log("Analysis completed:", response.data);
} catch (error) {
  if (error.code === "TIMEOUT") {
    console.error("Analysis timed out");
  }
}
```

### 並列リクエスト

```typescript
// 複数エージェントへの並列リクエスト
const requests = [
  communicationBus.request("security", {
    type: "security-scan",
    data: { files: stagedFiles },
  }),
  communicationBus.request("performance", {
    type: "performance-check",
    data: { files: stagedFiles },
  }),
  communicationBus.request("quality", {
    type: "quality-analysis",
    data: { files: stagedFiles },
  }),
];

// すべて完了を待つ
const responses = await Promise.all(requests);

// 結果を集約
const aggregatedResult = {
  security: responses[0].data,
  performance: responses[1].data,
  quality: responses[2].data,
};
```

### リクエストハンドラー登録

```typescript
// エージェントがリクエストを受信
communicationBus.registerHandler("error-fixer", async (message) => {
  switch (message.type) {
    case "fix-errors":
      return await fixErrors(message.data, message.context);

    case "validate-fixes":
      return await validateFixes(message.data);

    default:
      throw new Error(`Unknown message type: ${message.type}`);
  }
});
```

## ワークフロー実行パターン

### ワークフロー定義

```typescript
interface Workflow {
  id: string;
  name: string;
  steps: WorkflowStep[];
  onError?: ErrorHandler;
  metadata?: WorkflowMetadata;
}

interface WorkflowStep {
  name: string;
  agent: string;
  message: Message;
  dependencies?: string[]; // 依存する前ステップ
  condition?: StepCondition; // 実行条件
}

type StepCondition = (
  context: TaskContext,
  previousResults: Map<string, any>,
) => boolean;
```

### シンプルなワークフロー実行

```typescript
// ワークフロー定義
const workflow: Workflow = {
  id: "implement-feature-workflow",
  name: "Feature Implementation Workflow",
  steps: [
    {
      name: "analyze",
      agent: "researcher",
      message: {
        type: "analyze-requirements",
        data: { feature: "user-authentication" },
      },
    },
    {
      name: "implement",
      agent: "orchestrator",
      message: {
        type: "implement-feature",
        data: {}, // 前ステップの結果を使用
      },
      dependencies: ["analyze"],
    },
    {
      name: "review",
      agent: "code-reviewer",
      message: {
        type: "review-changes",
        data: {},
      },
      dependencies: ["implement"],
    },
  ],
};

// ワークフロー実行
const result = await communicationBus.executeWorkflow(workflow, taskContext);

console.log("Workflow result:", result);
console.log("Step results:", result.stepResults);
```

### 条件付きワークフロー

```typescript
// 条件に基づいてステップを実行
const workflow: Workflow = {
  id: "code-quality-workflow",
  name: "Code Quality Workflow",
  steps: [
    {
      name: "lint",
      agent: "error-fixer",
      message: {
        type: "run-lint",
        data: { files: stagedFiles },
      },
    },
    {
      name: "type-check",
      agent: "error-fixer",
      message: {
        type: "type-check",
        data: { files: stagedFiles },
      },
    },
    {
      name: "fix-errors",
      agent: "error-fixer",
      message: {
        type: "fix-errors",
        data: {},
      },
      dependencies: ["lint", "type-check"],
      condition: (context, results) => {
        // エラーが見つかった場合のみ実行
        const lintErrors = results.get("lint")?.errors || [];
        const typeErrors = results.get("type-check")?.errors || [];
        return lintErrors.length > 0 || typeErrors.length > 0;
      },
    },
  ],
};
```

### 並列ステップ実行

```typescript
// 依存関係のないステップを並列実行
const workflow: Workflow = {
  id: "parallel-review-workflow",
  name: "Parallel Review Workflow",
  steps: [
    {
      name: "security-review",
      agent: "security",
      message: {
        type: "security-scan",
        data: { files: stagedFiles },
      },
    },
    {
      name: "performance-review",
      agent: "performance",
      message: {
        type: "performance-check",
        data: { files: stagedFiles },
      },
    },
    {
      name: "quality-review",
      agent: "quality",
      message: {
        type: "quality-analysis",
        data: { files: stagedFiles },
      },
    },
    // 上記3つが完了後に実行
    {
      name: "aggregate-results",
      agent: "code-reviewer",
      message: {
        type: "aggregate-reviews",
        data: {},
      },
      dependencies: ["security-review", "performance-review", "quality-review"],
    },
  ],
};

// Communication Busが自動的に並列実行を最適化
const result = await communicationBus.executeWorkflow(workflow, taskContext);
```

### エラーハンドリング付きワークフロー

```typescript
const workflow: Workflow = {
  id: "resilient-workflow",
  name: "Resilient Workflow",
  steps: [
    {
      name: "primary-analysis",
      agent: "researcher",
      message: {
        type: "deep-analysis",
        data: { target: "src/" },
      },
    },
    {
      name: "implementation",
      agent: "orchestrator",
      message: {
        type: "implement",
        data: {},
      },
      dependencies: ["primary-analysis"],
    },
  ],
  onError: async (error, stepName, context) => {
    console.error(`Workflow error at step ${stepName}:`, error);

    // エラー回復を試みる
    if (stepName === "primary-analysis") {
      // フォールバック: 簡易分析を実行
      return await communicationBus.request("researcher", {
        type: "quick-analysis",
        data: { target: "src/" },
      });
    }

    // 回復不可能 - エラーを再スロー
    throw error;
  },
};
```

## メトリクスとモニタリング

### BusMetrics型定義

```typescript
interface BusMetrics {
  // メッセージ統計
  messages: {
    published: number;
    delivered: number;
    failed: number;
  };

  // リクエスト統計
  requests: {
    total: number;
    successful: number;
    failed: number;
    timedOut: number;
    averageResponseTime: number;
  };

  // ワークフロー統計
  workflows: {
    total: number;
    completed: number;
    failed: number;
    averageExecutionTime: number;
  };

  // 購読者統計
  subscribers: {
    total: number;
    byEventType: Record<string, number>;
  };
}
```

### メトリクス取得

```typescript
// メトリクスを取得
const metrics = communicationBus.getMetrics();

console.log("Communication Bus Metrics:");
console.log(`- Published messages: ${metrics.messages.published}`);
console.log(`- Successful requests: ${metrics.requests.successful}`);
console.log(
  `- Average response time: ${metrics.requests.averageResponseTime}ms`,
);
console.log(`- Completed workflows: ${metrics.workflows.completed}`);
```

### リアルタイムモニタリング

```typescript
// メトリクスイベントを購読
communicationBus.subscribe("bus.metrics.updated", (event) => {
  const metrics = event.data as BusMetrics;

  // パフォーマンス警告
  if (metrics.requests.averageResponseTime > 5000) {
    console.warn(
      "⚠️ High average response time:",
      metrics.requests.averageResponseTime,
    );
  }

  // エラー率警告
  const errorRate = metrics.requests.failed / metrics.requests.total;
  if (errorRate > 0.1) {
    console.warn("⚠️ High error rate:", (errorRate * 100).toFixed(2) + "%");
  }
});
```

## 高度なパターン

### Pub/Subパターン

```typescript
// イベント発行者
class TaskOrchestrator {
  async executeTask(task: Task) {
    // タスク開始を通知
    communicationBus.publish({
      type: "task.started",
      source: "orchestrator",
      data: { taskId: task.id },
    });

    try {
      const result = await this.runTask(task);

      // 成功を通知
      communicationBus.publish({
        type: "task.completed",
        source: "orchestrator",
        data: { taskId: task.id, result },
      });

      return result;
    } catch (error) {
      // 失敗を通知
      communicationBus.publish({
        type: "task.failed",
        source: "orchestrator",
        data: { taskId: task.id, error },
      });

      throw error;
    }
  }
}

// イベント購読者（メトリクス収集）
class MetricsCollector {
  constructor() {
    communicationBus.subscribe("task.*", (event) => {
      this.recordTaskEvent(event);
    });
  }

  recordTaskEvent(event: Event) {
    // メトリクスデータベースに記録
    metricsDB.insert({
      eventType: event.type,
      timestamp: event.timestamp,
      data: event.data,
    });
  }
}
```

### Saga パターン

```typescript
// 分散トランザクション（Saga）
class SagaOrchestrator {
  async executeSaga(saga: Saga) {
    const completedSteps: string[] = [];

    try {
      for (const step of saga.steps) {
        // ステップ実行
        const result = await communicationBus.request(step.agent, step.message);

        completedSteps.push(step.name);

        // 進捗を通知
        communicationBus.publish({
          type: "saga.step.completed",
          source: "saga-orchestrator",
          data: { sagaId: saga.id, step: step.name },
        });
      }

      return { success: true, completedSteps };
    } catch (error) {
      // 補償トランザクション実行
      await this.compensate(saga, completedSteps);
      throw error;
    }
  }

  async compensate(saga: Saga, completedSteps: string[]) {
    // 逆順で補償
    for (const stepName of completedSteps.reverse()) {
      const step = saga.steps.find((s) => s.name === stepName);
      if (step?.compensation) {
        await communicationBus.request(step.agent, step.compensation);
      }
    }
  }
}
```

### Event Sourcingパターン

```typescript
// イベントストア
class EventStore {
  private events: Event[] = [];

  constructor() {
    // すべてのイベントを記録
    communicationBus.subscribe("*", (event) => {
      this.events.push(event);
    });
  }

  // イベントリプレイ
  replay(fromTimestamp: Date) {
    const relevantEvents = this.events.filter(
      (e) => e.timestamp && e.timestamp >= fromTimestamp,
    );

    for (const event of relevantEvents) {
      communicationBus.publish(event);
    }
  }

  // 状態再構築
  reconstructState(entityId: string) {
    const entityEvents = this.events.filter(
      (e) => e.data?.entityId === entityId,
    );

    let state = {};
    for (const event of entityEvents) {
      state = this.applyEvent(state, event);
    }

    return state;
  }
}
```

## エラーハンドリング

### エラータイプ

```typescript
enum BusErrorCode {
  TIMEOUT = "TIMEOUT",
  NO_HANDLER = "NO_HANDLER",
  HANDLER_ERROR = "HANDLER_ERROR",
  INVALID_MESSAGE = "INVALID_MESSAGE",
  BUS_SHUTDOWN = "BUS_SHUTDOWN",
}

class BusError extends Error {
  constructor(
    public code: BusErrorCode,
    message: string,
    public details?: any,
  ) {
    super(message);
  }
}
```

### エラーハンドリング例

```typescript
// タイムアウトエラー
try {
  const response = await communicationBus.request(
    "slow-agent",
    {
      type: "complex-task",
      data: {},
    },
    5000,
  );
} catch (error) {
  if (error instanceof BusError && error.code === BusErrorCode.TIMEOUT) {
    console.error("Request timed out");
    // フォールバック処理
  }
}

// ハンドラーエラー
try {
  await communicationBus.request("error-prone-agent", {
    type: "risky-operation",
    data: {},
  });
} catch (error) {
  if (error instanceof BusError && error.code === BusErrorCode.HANDLER_ERROR) {
    console.error("Handler failed:", error.details);
    // エラー回復処理
  }
}
```

## ベストプラクティス

### 1. イベントタイプの命名規則

```typescript
// 良い例: 階層的で説明的
"task.started";
"agent.error-fixer.completed";
"workflow.step.analyze.completed";

// 悪い例: 曖昧
"start";
"done";
"error";
```

### 2. イベントデータの構造化

```typescript
// 良い例: 型安全で構造化
interface TaskStartedEvent {
  taskId: string;
  taskType: "command" | "agent";
  startTime: Date;
  context: TaskContext;
}

communicationBus.publish({
  type: "task.started",
  source: "orchestrator",
  data: {
    taskId: task.id,
    taskType: task.type,
    startTime: new Date(),
    context: task.context,
  } as TaskStartedEvent,
});

// 悪い例: 非構造化
communicationBus.publish({
  type: "task.started",
  source: "orchestrator",
  data: { id: task.id, type: task.type }, // 情報不足
});
```

### 3. 購読解除の管理

```typescript
// 良い例: クリーンアップ
class Component {
  private unsubscribers: Unsubscribe[] = [];

  constructor() {
    this.unsubscribers.push(
      communicationBus.subscribe("event1", this.handler1),
      communicationBus.subscribe("event2", this.handler2),
    );
  }

  destroy() {
    this.unsubscribers.forEach((unsub) => unsub());
  }
}

// 悪い例: メモリリーク
class BadComponent {
  constructor() {
    communicationBus.subscribe("event", this.handler);
    // 購読解除なし → メモリリーク
  }
}
```

### 4. エラーハンドリング

```typescript
// 良い例: 包括的エラーハンドリング
communicationBus.subscribe("task.completed", async (event) => {
  try {
    await processTaskCompletion(event.data);
  } catch (error) {
    console.error("Failed to process task completion:", error);
    // エラーイベントを発行
    communicationBus.publish({
      type: "processing.error",
      source: "task-processor",
      data: { originalEvent: event, error },
    });
  }
});

// 悪い例: エラーハンドリングなし
communicationBus.subscribe("task.completed", async (event) => {
  await processTaskCompletion(event.data); // エラーが伝播
});
```

## トラブルシューティング

### 問題1: メッセージが配信されない

```typescript
// デバッグ: イベントログを有効化
communicationBus.enableDebugMode();

// すべてのイベントをログ
communicationBus.subscribe("*", (event) => {
  console.log("Event:", event.type, "from", event.source);
});
```

### 問題2: リクエストがタイムアウト

```typescript
// タイムアウトを延長
const response = await communicationBus.request(
  "slow-agent",
  message,
  60000, // 60秒
);

// または非同期処理に変更
communicationBus.publish({
  type: "async.request",
  source: "caller",
  data: { message },
});

communicationBus.subscribe("async.response", (event) => {
  if (event.data.requestId === requestId) {
    handleResponse(event.data.response);
  }
});
```

### 問題3: メモリリーク

```typescript
// 購読解除を忘れずに
const unsubscribe = communicationBus.subscribe("event", handler);

// コンポーネント破棄時
component.onDestroy(() => {
  unsubscribe();
});

// または購読管理ヘルパー使用
class SubscriptionManager {
  private subs: Unsubscribe[] = [];

  add(unsub: Unsubscribe) {
    this.subs.push(unsub);
  }

  unsubscribeAll() {
    this.subs.forEach((unsub) => unsub());
    this.subs = [];
  }
}
```

## パフォーマンス最適化

### メッセージバッチング

```typescript
// 高頻度イベントをバッチ処理
class EventBatcher {
  private batch: Event[] = [];
  private batchInterval = 100; // ms

  constructor() {
    setInterval(() => this.flush(), this.batchInterval);
  }

  publish(event: Event) {
    this.batch.push(event);
  }

  flush() {
    if (this.batch.length > 0) {
      communicationBus.publish({
        type: "batch.events",
        source: "event-batcher",
        data: { events: this.batch },
      });
      this.batch = [];
    }
  }
}
```

### 購読者の最適化

```typescript
// 購読者数を最小化
// 悪い例: 重複した購読
communicationBus.subscribe("task.completed", handler1);
communicationBus.subscribe("task.completed", handler2);
communicationBus.subscribe("task.completed", handler3);

// 良い例: 単一の購読で配信
communicationBus.subscribe("task.completed", (event) => {
  handler1(event);
  handler2(event);
  handler3(event);
});
```

## 関連リファレンス

- **task-context-specification.md**: TaskContextとの統合
- **adapters-and-orchestration.md**: アダプターでのバス使用
- **framework-api-reference.md**: Communication Bus完全API

---

このリファレンスは、Communication BusのAPI仕様と使用パターンを提供します。エージェント間通信とワークフロー実行の実装ガイドとして使用してください。
