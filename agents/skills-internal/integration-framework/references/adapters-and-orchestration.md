---
skill: integration-framework
topic: Adapters and Orchestration
last-updated: 2025-12-22
audience: Developer
---

# Adapters and Orchestration完全リファレンス

## 概要

AdaptersとIntegration Orchestratorは、既存のエージェントとコマンドを統合フレームワークにシームレスに統合するための中核コンポーネントです。100%の後方互換性を維持しながら、強化された機能を提供します。

### 目的

- **後方互換性**: 既存のエージェント/コマンドを変更なしで動作
- **機能強化**: TaskContext、Communication Bus等の新機能を提供
- **統一インターフェース**: 一貫したタスク実行インターフェース
- **ルーティング最適化**: インテリジェントなエージェント/コマンド選択

### いつ使うか

- 新しいエージェントまたはコマンドをフレームワークに統合する
- 既存のエージェント/コマンドに新機能を追加する
- タスクルーティングロジックをカスタマイズする
- マルチエージェントワークフローを調整する

## Integration Orchestrator

### アーキテクチャ

```typescript
class IntegrationOrchestrator {
  private contextManager: ContextManager;
  private communicationBus: CommunicationBus;
  private agentAdapter: AgentAdapter;
  private commandAdapter: CommandAdapter;
  private taskRouter: EnhancedTaskRouter;
  private errorHandler: ErrorHandler;

  // タスク実行
  async executeTask(request: TaskRequest): Promise<TaskResult>;

  // システムステータス
  getSystemStatus(): SystemStatus;

  // パフォーマンス分析
  getPerformanceAnalytics(): PerformanceAnalytics;

  // シャットダウン
  async shutdown(): Promise<void>;
}
```

### 初期化

```typescript
// Orchestratorの初期化
const orchestrator = new IntegrationOrchestrator({
  // Context Manager設定
  contextManager: {
    cacheEnabled: true,
    cacheTTL: 3600000, // 1時間
  },

  // Communication Bus設定
  communicationBus: {
    maxConcurrentWorkflows: 5,
    defaultTimeout: 30000,
  },

  // Agent Adapter設定
  agentAdapter: {
    agents: [
      { name: "error-fixer", capabilities: ["fix", "validate"] },
      { name: "orchestrator", capabilities: ["implement", "refactor"] },
      { name: "researcher", capabilities: ["analyze", "investigate"] },
      { name: "code-reviewer", capabilities: ["review", "evaluate"] },
      { name: "docs-manager", capabilities: ["document", "maintain"] },
    ],
  },

  // Command Adapter設定
  commandAdapter: {
    commands: [
      { name: "task", type: "integrated" },
      { name: "review", type: "integrated" },
      { name: "todos", type: "legacy" },
      { name: "learnings", type: "legacy" },
    ],
  },

  // Task Router設定
  taskRouter: {
    intentAnalysisEnabled: true,
    historyBasedRouting: true,
    confidenceThreshold: 0.7,
  },

  // Error Handler設定
  errorHandler: {
    maxRetries: 3,
    retryDelay: 1000,
    fallbackEnabled: true,
  },
});
```

### タスク実行

```typescript
// 基本的なタスク実行
const result = await orchestrator.executeTask({
  type: "command",
  source: "user-request",
  originalRequest: "Fix TypeScript errors",
  priority: "high",
});

// 結果の処理
if (result.success) {
  console.log("Task completed successfully");
  console.log("Agent used:", result.executedBy);
  console.log("Duration:", result.duration, "ms");
  console.log("Quality metrics:", result.qualityMetrics);
} else {
  console.error("Task failed:", result.error);
  console.log("Suggestions:", result.followUpActions);
}
```

## Agent Adapter

### アーキテクチャ

```typescript
class AgentAdapter {
  private agents: Map<string, AgentConfig>;
  private contextManager: ContextManager;
  private communicationBus: CommunicationBus;

  // エージェント登録
  registerAgent(name: string, config: AgentConfig): void;

  // エージェント実行
  async executeAgent(name: string, context: TaskContext): Promise<AgentResult>;

  // エージェント選択
  selectAgent(context: TaskContext): string;

  // エージェント能力取得
  getCapabilities(name: string): string[];
}
```

### エージェント設定

```typescript
interface AgentConfig {
  name: string;
  capabilities: string[];
  tools: string[] | "*";
  model?: "sonnet" | "opus" | "haiku";
  preProcess?: (context: TaskContext) => TaskContext;
  postProcess?: (result: AgentResult) => AgentResult;
  errorHandler?: (error: Error, context: TaskContext) => Error | Promise<void>;
}
```

### エージェント登録

```typescript
// 新しいエージェントを登録
agentAdapter.registerAgent("custom-analyzer", {
  name: "custom-analyzer",
  capabilities: ["analyze", "metrics", "performance"],
  tools: ["Read", "Grep", "Bash", "Glob"],
  model: "sonnet",

  // 前処理: コンテキストを強化
  preProcess: (context) => {
    return {
      ...context,
      analyzerContext: {
        metricsEnabled: true,
        performanceTracking: true,
        detailedAnalysis: context.intent.confidence > 0.8,
      },
    };
  },

  // 後処理: 結果を整形
  postProcess: (result) => {
    return {
      ...result,
      formattedOutput: formatAnalysisResult(result.data),
    };
  },

  // エラーハンドリング
  errorHandler: async (error, context) => {
    console.error("Analyzer error:", error);
    // フォールバックロジック
    if (error.code === "TIMEOUT") {
      return await executeFallbackAnalysis(context);
    }
    throw error;
  },
});
```

### エージェント実行

```typescript
// エージェント実行
const result = await agentAdapter.executeAgent("error-fixer", context);

// Task tool経由での実行（後方互換性）
const legacyResult = await Task({
  subagent_type: "error-fixer",
  description: "Fix errors",
  prompt: "Fix TypeScript errors in src/",
});

// 両方とも同じエージェントを実行
// Adapterが自動的にコンテキストを変換
```

### エージェント選択ロジック

```typescript
// カスタムエージェント選択ロジック
class CustomAgentSelector {
  selectAgent(context: TaskContext): string {
    const { intent, project } = context;

    // 意図に基づく選択
    switch (intent.primary.type) {
      case IntentType.Fix:
        return "error-fixer";

      case IntentType.Implement:
        // プロジェクトタイプで分岐
        if (project.type === ProjectType.Go) {
          return "golang-orchestrator";
        }
        return "orchestrator";

      case IntentType.Analyze:
        return "researcher";

      case IntentType.Review:
        return "code-reviewer";

      default:
        // 汎用オーケストレーター
        return "orchestrator";
    }
  }
}

// Adapterに登録
agentAdapter.setSelector(new CustomAgentSelector());
```

## Command Adapter

### アーキテクチャ

```typescript
class CommandAdapter {
  private commands: Map<string, CommandConfig>;
  private contextManager: ContextManager;
  private communicationBus: CommunicationBus;

  // コマンド登録
  registerCommand(name: string, config: CommandConfig): void;

  // コマンド実行
  async executeCommand(
    name: string,
    args: string[],
    context: TaskContext,
  ): Promise<CommandResult>;

  // コマンドリスト取得
  getCommands(): string[];
}
```

### コマンド設定

```typescript
interface CommandConfig {
  name: string;
  type: "integrated" | "legacy";
  execute: (args: string[], context: TaskContext) => Promise<CommandResult>;
  preProcess?: (
    args: string[],
    context: TaskContext,
  ) => [string[], TaskContext];
  postProcess?: (result: CommandResult) => CommandResult;
}
```

### コマンド登録

```typescript
// 統合型コマンド（フレームワーク機能を活用）
commandAdapter.registerCommand("analyze", {
  name: "analyze",
  type: "integrated",

  execute: async (args, context) => {
    // Communication Bus経由でエージェント実行
    const response = await communicationBus.request("researcher", {
      type: "analyze-codebase",
      data: {
        target: args[0] || "src/",
        depth: "deep",
      },
      context,
    });

    return {
      success: response.success,
      data: response.data,
      context,
    };
  },

  preProcess: (args, context) => {
    // 引数を検証・正規化
    const normalizedArgs = args.map((arg) =>
      arg.startsWith("./") ? arg : `./${arg}`,
    );

    // コンテキストを強化
    const enhancedContext = {
      ...context,
      execution: {
        ...context.execution,
        targetFiles: normalizedArgs,
      },
    };

    return [normalizedArgs, enhancedContext];
  },
});

// レガシー型コマンド（既存実装をラップ）
commandAdapter.registerCommand("legacy-command", {
  name: "legacy-command",
  type: "legacy",

  execute: async (args, context) => {
    // 既存のコマンド実装を呼び出し
    const result = await executeLegacyCommand(args);

    // Adapterが自動的に結果を標準化
    return {
      success: result.exitCode === 0,
      data: result.output,
      context,
    };
  },
});
```

### コマンド実行

```typescript
// コマンド実行
const result = await commandAdapter.executeCommand(
  "analyze",
  ["src/components"],
  context,
);

// 従来のコマンド実行（後方互換性）
// /analyze src/components
// Adapterが自動的にコンテキストを提供
```

## Enhanced Task Router

### アーキテクチャ

```typescript
class EnhancedTaskRouter {
  // ルーティング実行
  async route(request: TaskRequest): Promise<RoutingDecision>;

  // 意図分析
  analyzeIntent(request: string): Intent;

  // エージェント能力マッチング
  matchCapabilities(intent: Intent, agents: AgentConfig[]): AgentMatch[];

  // 履歴ベースルーティング
  routeBasedOnHistory(
    request: TaskRequest,
    history: ExecutionHistory[],
  ): RoutingDecision;
}
```

### ルーティング決定

```typescript
interface RoutingDecision {
  target: string; // エージェントまたはコマンド名
  targetType: "agent" | "command";
  confidence: number; // 信頼度（0-1）
  reasoning: string; // 選択理由
  alternatives: Alternative[]; // 代替案
  workflow?: Workflow; // マルチステップワークフロー
}

interface Alternative {
  target: string;
  confidence: number;
  reasoning: string;
}
```

### ルーティング実装

```typescript
// ルーティング実行
const decision = await taskRouter.route({
  type: "command",
  source: "user-request",
  originalRequest: "Fix TypeScript errors and improve code quality",
});

console.log("Routing decision:");
console.log(`- Target: ${decision.target}`);
console.log(`- Confidence: ${decision.confidence}`);
console.log(`- Reasoning: ${decision.reasoning}`);

// ワークフローが生成された場合
if (decision.workflow) {
  console.log("Multi-step workflow:");
  decision.workflow.steps.forEach((step, i) => {
    console.log(`  ${i + 1}. ${step.name} (${step.agent})`);
  });
}
```

### 意図分析

```typescript
// 自然言語からの意図抽出
const intent = taskRouter.analyzeIntent(
  "Fix all TypeScript errors in the authentication module",
);

console.log("Intent analysis:");
console.log(`- Primary: ${intent.primary.type}`); // IntentType.Fix
console.log(`- Confidence: ${intent.primary.confidence}`); // 0.95
console.log(`- Entities:`, intent.primary.entities);
// [{ type: "Error", value: "TypeScript", confidence: 0.9 },
//  { type: "Module", value: "authentication", confidence: 0.85 }]
console.log(`- Keywords:`, intent.primary.keywords);
// ["fix", "typescript", "errors", "authentication"]
```

### 能力マッチング

```typescript
// エージェント能力とのマッチング
const matches = taskRouter.matchCapabilities(
  intent,
  agentAdapter.getAllAgents(),
);

console.log("Agent matches:");
matches.forEach((match) => {
  console.log(`- ${match.agent}: ${match.score} (${match.reason})`);
});

// 出力例:
// - error-fixer: 0.95 (Fix capability + TypeScript expertise)
// - orchestrator: 0.60 (General implementation capability)
// - code-reviewer: 0.40 (Code quality evaluation)
```

### 履歴ベースルーティング

```typescript
// 過去の実行履歴を活用
const decision = taskRouter.routeBasedOnHistory(request, executionHistory);

// 履歴分析:
// - 同様のタスクで error-fixer が 95% 成功
// - orchestrator は 70% 成功
// → error-fixer を選択（信頼度 0.95）
```

## ワークフロー生成

### 自動ワークフロー生成

```typescript
// 複雑なタスクに対して自動的にワークフローを生成
const request = {
  type: "command",
  source: "user-request",
  originalRequest:
    "Implement OAuth2 authentication with security review and testing",
};

const decision = await taskRouter.route(request);

// 生成されたワークフロー:
const workflow = decision.workflow;
// {
//   steps: [
//     { name: "analyze", agent: "researcher" },
//     { name: "implement", agent: "orchestrator", dependencies: ["analyze"] },
//     { name: "security-review", agent: "code-reviewer", dependencies: ["implement"] },
//     { name: "test", agent: "error-fixer", dependencies: ["implement"] }
//   ]
// }
```

### ワークフロー実行

```typescript
// Integration Orchestrator経由で実行
if (decision.workflow) {
  const result = await orchestrator.executeWorkflow(decision.workflow, context);

  console.log("Workflow execution:");
  result.stepResults.forEach((stepResult, stepName) => {
    console.log(`- ${stepName}: ${stepResult.success ? "✓" : "✗"}`);
  });
}
```

## コンテキスト強化

### エージェント固有のコンテキスト強化

```typescript
// Agent Adapterが自動的にコンテキストを強化
const enhancedContext = agentAdapter.enhanceContext(baseContext, "error-fixer");

// error-fixer固有の追加コンテキスト:
enhancedContext.errorContext = {
  detectionPatterns: [
    { type: "typescript", pattern: /error TS\d+/ },
    { type: "eslint", pattern: /\s+error\s+/ },
  ],
  fixPatterns: {
    "any-type": "Replace with proper type",
    "missing-await": "Add await keyword",
  },
  qualityThresholds: {
    maxErrors: 0,
    minCoverage: 80,
  },
};
```

### コマンド固有のコンテキスト強化

```typescript
// Command Adapterが自動的にコンテキストを強化
const enhancedContext = commandAdapter.enhanceContext(baseContext, "review");

// /review固有の追加コンテキスト:
enhancedContext.reviewContext = {
  projectType: project.type,
  reviewGuidelines: loadReviewGuidelines(project.root),
  stagedFiles: gitStatus.stagedFiles,
  reviewMode: "detailed",
};
```

## エラーハンドリング

### エラー分類

```typescript
enum ErrorCategory {
  Configuration = "configuration",
  Execution = "execution",
  Timeout = "timeout",
  Validation = "validation",
  System = "system",
}

interface AdapterError {
  category: ErrorCategory;
  code: string;
  message: string;
  context: TaskContext;
  recoverable: boolean;
  suggestions: string[];
}
```

### エラー回復戦略

```typescript
// Error Handlerによる自動回復
try {
  const result = await orchestrator.executeTask(request);
} catch (error) {
  if (error instanceof AdapterError) {
    if (error.recoverable) {
      console.log("Attempting recovery...");
      console.log("Suggestions:", error.suggestions);

      // 回復戦略を実行
      const recoveryResult = await errorHandler.attemptRecovery(
        error,
        error.context,
      );

      if (recoveryResult.success) {
        console.log("✓ Recovered successfully");
        return recoveryResult.data;
      }
    }

    console.error("✗ Unrecoverable error:", error.message);
    throw error;
  }
}
```

### フォールバック戦略

```typescript
// エージェント実行失敗時のフォールバック
agentAdapter.registerFallback("error-fixer", {
  fallbackAgent: "orchestrator",
  condition: (error) => error.code === "TIMEOUT",
  transform: (context) => {
    // コンテキストを調整
    return {
      ...context,
      intent: {
        ...context.intent,
        primary: {
          type: IntentType.Implement,
          // error-fixer → orchestratorへの意図変換
        },
      },
    };
  },
});
```

## パフォーマンス最適化

### 並列実行

```typescript
// 複数エージェントの並列実行
const results = await Promise.all([
  agentAdapter.executeAgent("security", securityContext),
  agentAdapter.executeAgent("performance", perfContext),
  agentAdapter.executeAgent("quality", qualityContext),
]);

// 結果を集約
const aggregatedResult = {
  security: results[0],
  performance: results[1],
  quality: results[2],
};
```

### キャッシング

```typescript
// Agent Adapterのキャッシング設定
agentAdapter.enableCache({
  ttl: 3600000, // 1時間
  maxSize: 100, // 最大100エントリ
  keyGenerator: (name, context) => {
    // キャッシュキー生成
    return `${name}:${context.project.root}:${context.intent.primary.type}`;
  },
});

// キャッシュヒット時は即座に結果を返す
const result = await agentAdapter.executeAgent("researcher", context);
// Cache hit: 2ms vs 30000ms (no cache)
```

## モニタリングとメトリクス

### システムステータス

```typescript
interface SystemStatus {
  orchestrator: {
    status: "running" | "idle" | "busy";
    activeTasks: number;
    queuedTasks: number;
  };
  agents: {
    [agentName: string]: {
      status: "available" | "busy" | "error";
      activeExecutions: number;
      totalExecutions: number;
    };
  };
  metrics: {
    successRate: number;
    averageTime: number;
    errorRate: number;
  };
}

// ステータス取得
const status = orchestrator.getSystemStatus();
console.log("System status:", status);
```

### パフォーマンス分析

```typescript
interface PerformanceAnalytics {
  agents: {
    [agentName: string]: {
      averageExecutionTime: number;
      successRate: number;
      errorRate: number;
      mostCommonErrors: string[];
    };
  };
  routing: {
    accuracy: number;
    averageConfidence: number;
    workflowGenerationRate: number;
  };
  overall: {
    totalTasks: number;
    successfulTasks: number;
    failedTasks: number;
    averageQuality: number;
  };
}

// 分析取得
const analytics = orchestrator.getPerformanceAnalytics();
console.log("Performance analytics:", analytics);
```

## ベストプラクティス

### 1. エージェント登録

```typescript
// 良い例: 明確な能力定義
agentAdapter.registerAgent("typescript-specialist", {
  name: "typescript-specialist",
  capabilities: ["typescript-fix", "type-safety", "type-inference"],
  tools: ["Read", "Edit", "Bash"],
  model: "sonnet",
});

// 悪い例: 曖昧な能力定義
agentAdapter.registerAgent("helper", {
  name: "helper",
  capabilities: ["help"], // 不明確
  tools: ["*"], // 過剰
});
```

### 2. コンテキスト強化

```typescript
// 良い例: 段階的強化
preProcess: (context) => {
  const base = context;
  const projectSpecific = addProjectContext(base);
  const agentSpecific = addAgentContext(projectSpecific);
  return agentSpecific;
};

// 悪い例: 一度に全て追加
preProcess: (context) => {
  return { ...context, ...everything }; // 肥大化
};
```

### 3. エラーハンドリング

```typescript
// 良い例: 段階的エラー処理
errorHandler: async (error, context) => {
  // 1. ログ記録
  logger.error("Agent error", { error, context });

  // 2. 回復可能性を判断
  if (isRecoverable(error)) {
    return await attemptRecovery(error, context);
  }

  // 3. フォールバックを試す
  if (hasFallback(context)) {
    return await executeFallback(context);
  }

  // 4. 失敗を通知
  throw new AdapterError({
    category: ErrorCategory.Execution,
    code: error.code,
    message: error.message,
    context,
    recoverable: false,
  });
};
```

## 関連リファレンス

- **task-context-specification.md**: TaskContextの詳細仕様
- **communication-bus-api.md**: Communication Busとの統合
- **framework-api-reference.md**: API完全リファレンス

---

このリファレンスは、AdaptersとOrchestrationの完全な実装ガイドを提供します。既存システムとの統合と新機能の追加に使用してください。
