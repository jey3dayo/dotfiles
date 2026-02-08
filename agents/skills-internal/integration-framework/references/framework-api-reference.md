---
skill: integration-framework
topic: Framework API Reference
last-updated: 2025-12-22
audience: Developer
---

# Framework API完全リファレンス

## 概要

このドキュメントは、Claude Code Integration Frameworkのすべての公開APIの完全なリファレンスを提供します。Context Manager、Communication Bus、Error Handler、パフォーマンスモニタリングAPIを含みます。

### 対象読者

- フレームワークを使用する開発者
- 新しいコンポーネントを統合する開発者
- フレームワークを拡張する開発者

## Context Manager API

### コンストラクタ

```typescript
constructor(config?: ContextManagerConfig): ContextManager

interface ContextManagerConfig {
  cacheEnabled?: boolean;
  cacheTTL?: number;
  projectRoot?: string;
  autoDetection?: boolean;
}
```

### コアメソッド

#### createContext

```typescript
createContext(request: TaskRequest): TaskContext

interface TaskRequest {
  type: "command" | "agent";
  source: string;
  originalRequest: string;
  priority?: "low" | "medium" | "high";
  metadata?: Record<string, any>;
}
```

**説明**: 新しいTaskContextを作成します。

#### 戻り値

生成されたTaskContext

**例**:

```typescript
const context = contextManager.createContext({
  type: "command",
  source: "user-request",
  originalRequest: "Fix TypeScript errors",
  priority: "high",
});
```

#### loadProjectContext

```typescript
loadProjectContext(root: string): ProjectContext

interface ProjectContext {
  root: string;
  type: ProjectType;
  stack: TechStack[];
  conventions: ProjectConventions;
}
```

**説明**: プロジェクトのコンテキスト情報をロードします。

**パラメータ**:

- `root`: プロジェクトルートディレクトリ

#### 戻り値

ProjectContext

**例**:

```typescript
const projectContext = contextManager.loadProjectContext("./");
```

#### enhanceForAgent

```typescript
enhanceForAgent(
  context: TaskContext,
  agentType: string
): EnhancedTaskContext

type EnhancedTaskContext = TaskContext & {
  [key: string]: any;  // エージェント固有のコンテキスト
}
```

**説明**: エージェント固有のコンテキストを追加します。

**パラメータ**:

- `context`: ベースとなるTaskContext
- `agentType`: エージェント名

#### 戻り値

強化されたTaskContext

**例**:

```typescript
const enhanced = contextManager.enhanceForAgent(context, "error-fixer");
```

#### createChildContext

```typescript
createChildContext(
  parent: TaskContext,
  request: TaskRequest
): TaskContext
```

**説明**: 親タスクから子タスクのコンテキストを作成します。

**パラメータ**:

- `parent`: 親TaskContext
- `request`: 子タスクのリクエスト

#### 戻り値

子TaskContext

**例**:

```typescript
const childContext = contextManager.createChildContext(parentContext, {
  type: "agent",
  source: "workflow-step",
  originalRequest: "Analyze requirements",
});
```

#### shareContext

```typescript
shareContext(
  fromId: string,
  toId: string,
  data: any
): void
```

**説明**: タスク間でデータを共有します。

**パラメータ**:

- `fromId`: 送信元タスクID
- `toId`: 送信先タスクID
- `data`: 共有するデータ

**例**:

```typescript
contextManager.shareContext(task1.id, task2.id, {
  analysisResult: { issues: 5 },
});
```

#### getSharedData

```typescript
getSharedData(
  fromId: string,
  toId: string
): any | null
```

**説明**: 共有データを取得します。

**パラメータ**:

- `fromId`: 送信元タスクID
- `toId`: 受信側タスクID

#### 戻り値

共有データ（存在しない場合はnull）

**例**:

```typescript
const sharedData = contextManager.getSharedData(task1.id, task2.id);
```

### ユーティリティメソッド

#### detectProjectType

```typescript
detectProjectType(root: string): ProjectType

enum ProjectType {
  TypeScriptReact = "typescript-react",
  TypeScriptNode = "typescript-node",
  JavaScriptReact = "javascript-react",
  JavaScriptNode = "javascript-node",
  Go = "go",
  Python = "python",
  Rust = "rust",
  Unknown = "unknown"
}
```

**説明**: プロジェクトタイプを自動検出します。

#### 戻り値

ProjectType

#### detectTechStack

```typescript
detectTechStack(root: string): TechStack[]

interface TechStack {
  name: string;
  version?: string;
  category: TechCategory;
}
```

**説明**: 使用されている技術スタックを検出します。

#### 戻り値

TechStack配列

#### getGitStatus

```typescript
getGitStatus(root: string): GitStatus

interface GitStatus {
  branch: string;
  isClean: boolean;
  stagedFiles: string[];
  unstagedFiles: string[];
  untrackedFiles: string[];
  ahead: number;
  behind: number;
  lastCommit?: CommitInfo;
}
```

**説明**: Git状態を取得します。

#### 戻り値

GitStatus

#### getEnvironmentInfo

```typescript
getEnvironmentInfo(): EnvironmentInfo

interface EnvironmentInfo {
  platform: "darwin" | "linux" | "win32";
  nodeVersion?: string;
  npmVersion?: string;
  shell: string;
  editor?: string;
  cwd: string;
  env: Record<string, string>;
}
```

**説明**: 環境情報を取得します。

#### 戻り値

EnvironmentInfo

#### analyzeIntent

```typescript
analyzeIntent(request: string): Intent

interface Intent {
  type: IntentType;
  entities: Entity[];
  keywords: string[];
  confidence: number;
}
```

**説明**: 自然言語リクエストから意図を分析します。

#### 戻り値

Intent

---

## Communication Bus API

### コンストラクタ

```typescript
constructor(config?: BusConfig): CommunicationBus

interface BusConfig {
  maxConcurrentWorkflows?: number;
  defaultTimeout?: number;
  enableMetrics?: boolean;
  debugMode?: boolean;
}
```

### イベント操作

#### publish

```typescript
publish(event: Event): void

interface Event {
  type: string;
  source: string;
  data: any;
  timestamp?: Date;
  metadata?: EventMetadata;
}
```

**説明**: イベントを発行します。

**パラメータ**:

- `event`: 発行するイベント

**例**:

```typescript
communicationBus.publish({
  type: "task.started",
  source: "orchestrator",
  data: { taskId: "task-123" },
});
```

#### subscribe

```typescript
subscribe(
  eventType: string,
  handler: EventHandler
): Unsubscribe

type EventHandler = (event: Event) => void | Promise<void>;
type Unsubscribe = () => void;
```

**説明**: イベントを購読します。

**パラメータ**:

- `eventType`: イベントタイプ（ワイルドカード対応: "task.\*"）
- `handler`: イベントハンドラー関数

#### 戻り値

購読解除関数

**例**:

```typescript
const unsubscribe = communicationBus.subscribe("task.completed", (event) => {
  console.log("Task completed:", event.data);
});

// 購読解除
unsubscribe();
```

### リクエスト-レスポンス

#### request

```typescript
request(
  target: string,
  message: Message,
  timeout?: number
): Promise<Response>

interface Message {
  type: string;
  data: any;
  context?: TaskContext;
  timeout?: number;
}

interface Response {
  success: boolean;
  data: any;
  error?: Error;
  metadata?: ResponseMetadata;
}
```

**説明**: エージェント/コマンドにリクエストを送信します。

**パラメータ**:

- `target`: ターゲット名
- `message`: メッセージ
- `timeout`: タイムアウト（ミリ秒、デフォルト: 30000）

#### 戻り値

`Promise<Response>`

**例**:

```typescript
const response = await communicationBus.request(
  "error-fixer",
  {
    type: "fix-errors",
    data: { files: ["src/index.ts"] },
  },
  30000,
);
```

#### registerHandler

```typescript
registerHandler(
  name: string,
  handler: RequestHandler
): void

type RequestHandler = (
  message: Message
) => Promise<Response> | Response;
```

**説明**: リクエストハンドラーを登録します。

**パラメータ**:

- `name`: ハンドラー名
- `handler`: ハンドラー関数

**例**:

```typescript
communicationBus.registerHandler("custom-agent", async (message) => {
  const result = await processMessage(message);
  return {
    success: true,
    data: result,
  };
});
```

### ワークフロー操作

#### executeWorkflow

```typescript
executeWorkflow(
  workflow: Workflow,
  context: TaskContext
): Promise<WorkflowResult>

interface Workflow {
  id: string;
  name: string;
  steps: WorkflowStep[];
  onError?: ErrorHandler;
  metadata?: WorkflowMetadata;
}

interface WorkflowResult {
  success: boolean;
  stepResults: Map<string, StepResult>;
  duration: number;
  error?: Error;
}
```

**説明**: ワークフローを実行します。

**パラメータ**:

- `workflow`: ワークフロー定義
- `context`: TaskContext

#### 戻り値

`Promise<WorkflowResult>`

**例**:

```typescript
const result = await communicationBus.executeWorkflow({
  id: "workflow-1",
  name: "Implementation Workflow",
  steps: [
    { name: "analyze", agent: "researcher", message: {...} },
    { name: "implement", agent: "orchestrator", message: {...} }
  ]
}, context);
```

### メトリクス

#### getMetrics

```typescript
getMetrics(): BusMetrics

interface BusMetrics {
  messages: {
    published: number;
    delivered: number;
    failed: number;
  };
  requests: {
    total: number;
    successful: number;
    failed: number;
    timedOut: number;
    averageResponseTime: number;
  };
  workflows: {
    total: number;
    completed: number;
    failed: number;
    averageExecutionTime: number;
  };
  subscribers: {
    total: number;
    byEventType: Record<string, number>;
  };
}
```

**説明**: Communication Busのメトリクスを取得します。

#### 戻り値

BusMetrics

**例**:

```typescript
const metrics = communicationBus.getMetrics();
console.log("Average response time:", metrics.requests.averageResponseTime);
```

### シャットダウン

#### shutdown

```typescript
shutdown(): Promise<void>
```

**説明**: Communication Busを正常にシャットダウンします。

**例**:

```typescript
await communicationBus.shutdown();
```

---

## Error Handler API

### コンストラクタ

```typescript
constructor(config?: ErrorHandlerConfig): ErrorHandler

interface ErrorHandlerConfig {
  maxRetries?: number;
  retryDelay?: number;
  fallbackEnabled?: boolean;
  errorReporting?: boolean;
}
```

### エラー作成

#### createError

```typescript
createError(
  type: ErrorType,
  code: string,
  message: string,
  context?: TaskContext
): FrameworkError

enum ErrorType {
  Configuration = "configuration",
  Execution = "execution",
  Timeout = "timeout",
  Validation = "validation",
  System = "system"
}

class FrameworkError extends Error {
  type: ErrorType;
  code: string;
  context?: TaskContext;
  recoverable: boolean;
  suggestions: string[];
}
```

**説明**: 標準化されたエラーを作成します。

#### 戻り値

FrameworkError

**例**:

```typescript
const error = errorHandler.createError(
  ErrorType.Execution,
  "AGENT_FAILED",
  "Agent execution failed",
  context,
);
```

### エラーハンドリング

#### handleError

```typescript
handleError(
  error: Error,
  context: TaskContext
): Promise<ErrorHandlingResult>

interface ErrorHandlingResult {
  success: boolean;
  strategy: string;
  data?: any;
  error?: Error;
  recommendations?: string[];
}
```

**説明**: エラーをハンドリングし、可能であれば回復を試みます。

**パラメータ**:

- `error`: エラーオブジェクト
- `context`: TaskContext

#### 戻り値

`Promise<ErrorHandlingResult>`

**例**:

```typescript
try {
  await executeTask(context);
} catch (error) {
  const result = await errorHandler.handleError(error, context);
  if (result.success) {
    console.log("Recovered using strategy:", result.strategy);
  }
}
```

#### attemptRecovery

```typescript
attemptRecovery(
  error: FrameworkError,
  context: TaskContext,
  maxAttempts?: number
): Promise<RecoveryResult>

interface RecoveryResult {
  success: boolean;
  attempts: number;
  strategy: string;
  data?: any;
}
```

**説明**: エラーからの回復を試みます。

**パラメータ**:

- `error`: FrameworkError
- `context`: TaskContext
- `maxAttempts`: 最大試行回数（デフォルト: 3）

#### 戻り値

`Promise<RecoveryResult>`

**例**:

```typescript
const recovery = await errorHandler.attemptRecovery(error, context);
```

### エラー統計

#### getErrorStatistics

```typescript
getErrorStatistics(): ErrorStatistics

interface ErrorStatistics {
  byType: Record<ErrorType, number>;
  byCode: Record<string, number>;
  total: number;
  recoveryRate: number;
  averageRecoveryTime: number;
}
```

**説明**: エラー統計を取得します。

#### 戻り値

ErrorStatistics

**例**:

```typescript
const stats = errorHandler.getErrorStatistics();
console.log("Recovery rate:", stats.recoveryRate);
```

#### createDetailedErrorReport

```typescript
createDetailedErrorReport(
  error: Error
): ErrorReport

interface ErrorReport {
  error: {
    type: string;
    message: string;
    stack: string;
  };
  context: TaskContext;
  timestamp: Date;
  suggestions: string[];
  relatedErrors: Error[];
}
```

**説明**: 詳細なエラーレポートを作成します。

#### 戻り値

ErrorReport

**例**:

```typescript
const report = errorHandler.createDetailedErrorReport(error);
console.log("Error report:", report);
```

---

## Integration Orchestrator API

### コンストラクタ

```typescript
constructor(config: OrchestratorConfig): IntegrationOrchestrator

interface OrchestratorConfig {
  contextManager: ContextManagerConfig;
  communicationBus: BusConfig;
  agentAdapter: AgentAdapterConfig;
  commandAdapter: CommandAdapterConfig;
  taskRouter: TaskRouterConfig;
  errorHandler: ErrorHandlerConfig;
}
```

### タスク実行

#### executeTask

```typescript
executeTask(
  request: TaskRequest
): Promise<TaskResult>

interface TaskResult {
  success: boolean;
  executedBy: string;
  duration: number;
  data: any;
  qualityMetrics: QualityMetrics;
  followUpActions?: FollowUpAction[];
  error?: Error;
}

interface QualityMetrics {
  overallScore: number;
  executionEfficiency: number;
  resultCompleteness: number;
}
```

**説明**: タスクを実行します。

**パラメータ**:

- `request`: TaskRequest

#### 戻り値

`Promise<TaskResult>`

**例**:

```typescript
const result = await orchestrator.executeTask({
  type: "command",
  source: "user-request",
  originalRequest: "Fix TypeScript errors",
});
```

#### executeWorkflow

```typescript
executeWorkflow(
  workflow: Workflow,
  context: TaskContext
): Promise<WorkflowResult>
```

**説明**: ワークフローを実行します（Communication Bus経由）。

**パラメータ**:

- `workflow`: ワークフロー定義
- `context`: TaskContext

#### 戻り値

`Promise<WorkflowResult>`

**例**:

```typescript
const result = await orchestrator.executeWorkflow(workflow, context);
```

### システム管理

#### getSystemStatus

```typescript
getSystemStatus(): SystemStatus

interface SystemStatus {
  orchestrator: {
    status: "running" | "idle" | "busy";
    activeTasks: number;
    queuedTasks: number;
  };
  agents: Record<string, AgentStatus>;
  metrics: SystemMetrics;
}
```

**説明**: システムステータスを取得します。

#### 戻り値

SystemStatus

**例**:

```typescript
const status = orchestrator.getSystemStatus();
console.log("Active tasks:", status.orchestrator.activeTasks);
```

#### getPerformanceAnalytics

```typescript
getPerformanceAnalytics(): PerformanceAnalytics

interface PerformanceAnalytics {
  agents: Record<string, AgentAnalytics>;
  routing: RoutingAnalytics;
  overall: OverallAnalytics;
}
```

**説明**: パフォーマンス分析を取得します。

#### 戻り値

PerformanceAnalytics

**例**:

```typescript
const analytics = orchestrator.getPerformanceAnalytics();
console.log("Overall success rate:", analytics.overall.successRate);
```

#### shutdown

```typescript
shutdown(): Promise<void>
```

**説明**: Orchestratorを正常にシャットダウンします。

**例**:

```typescript
await orchestrator.shutdown();
```

---

## Agent Adapter API

### エージェント管理

#### registerAgent

```typescript
registerAgent(
  name: string,
  config: AgentConfig
): void

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

**説明**: エージェントを登録します。

**例**:

```typescript
agentAdapter.registerAgent("custom-agent", {
  name: "custom-agent",
  capabilities: ["analyze", "optimize"],
  tools: ["Read", "Grep", "Bash"],
});
```

#### executeAgent

```typescript
executeAgent(
  name: string,
  context: TaskContext
): Promise<AgentResult>

interface AgentResult {
  success: boolean;
  data: any;
  duration: number;
  error?: Error;
}
```

**説明**: エージェントを実行します。

**例**:

```typescript
const result = await agentAdapter.executeAgent("error-fixer", context);
```

#### selectAgent

```typescript
selectAgent(
  context: TaskContext
): string
```

**説明**: TaskContextに基づいて最適なエージェントを選択します。

#### 戻り値

エージェント名

**例**:

```typescript
const agentName = agentAdapter.selectAgent(context);
```

#### getCapabilities

```typescript
getCapabilities(
  name: string
): string[]
```

**説明**: エージェントの能力を取得します。

#### 戻り値

能力の配列

**例**:

```typescript
const capabilities = agentAdapter.getCapabilities("error-fixer");
```

---

## Command Adapter API

### コマンド管理

#### registerCommand

```typescript
registerCommand(
  name: string,
  config: CommandConfig
): void

interface CommandConfig {
  name: string;
  type: "integrated" | "legacy";
  execute: (args: string[], context: TaskContext) => Promise<CommandResult>;
  preProcess?: (args: string[], context: TaskContext) => [string[], TaskContext];
  postProcess?: (result: CommandResult) => CommandResult;
}
```

**説明**: コマンドを登録します。

**例**:

```typescript
commandAdapter.registerCommand("custom-command", {
  name: "custom-command",
  type: "integrated",
  execute: async (args, context) => {
    // コマンド実装
    return { success: true, data: result };
  },
});
```

#### executeCommand

```typescript
executeCommand(
  name: string,
  args: string[],
  context: TaskContext
): Promise<CommandResult>

interface CommandResult {
  success: boolean;
  data: any;
  context: TaskContext;
  error?: Error;
}
```

**説明**: コマンドを実行します。

**例**:

```typescript
const result = await commandAdapter.executeCommand(
  "analyze",
  ["src/components"],
  context,
);
```

#### getCommands

```typescript
getCommands(): string[]
```

**説明**: 登録されているすべてのコマンド名を取得します。

#### 戻り値

コマンド名の配列

**例**:

```typescript
const commands = commandAdapter.getCommands();
```

---

## Task Router API

### ルーティング

#### route

```typescript
route(
  request: TaskRequest
): Promise<RoutingDecision>

interface RoutingDecision {
  target: string;
  targetType: "agent" | "command";
  confidence: number;
  reasoning: string;
  alternatives: Alternative[];
  workflow?: Workflow;
}
```

**説明**: タスクのルーティングを決定します。

#### 戻り値

`Promise<RoutingDecision>`

**例**:

```typescript
const decision = await taskRouter.route(request);
```

#### analyzeIntent

```typescript
analyzeIntent(
  request: string
): Intent
```

**説明**: 自然言語リクエストから意図を分析します。

#### 戻り値

Intent

**例**:

```typescript
const intent = taskRouter.analyzeIntent("Fix TypeScript errors");
```

#### matchCapabilities

```typescript
matchCapabilities(
  intent: Intent,
  agents: AgentConfig[]
): AgentMatch[]

interface AgentMatch {
  agent: string;
  score: number;
  reason: string;
}
```

**説明**: 意図とエージェント能力をマッチングします。

#### 戻り値

AgentMatch配列

**例**:

```typescript
const matches = taskRouter.matchCapabilities(intent, agents);
```

---

## ユーティリティ関数

### getOrchestrator

```typescript
getOrchestrator(): IntegrationOrchestrator
```

**説明**: グローバルOrchestratorインスタンスを取得します。

#### 戻り値

IntegrationOrchestrator

**例**:

```typescript
const orchestrator = getOrchestrator();
```

### initializeFramework

```typescript
initializeFramework(
  config?: FrameworkConfig
): Promise<void>

interface FrameworkConfig {
  // すべてのコンポーネント設定を含む
}
```

**説明**: フレームワークを初期化します。

**例**:

```typescript
await initializeFramework({
  contextManager: { cacheEnabled: true },
  communicationBus: { defaultTimeout: 30000 },
});
```

---

## 型定義

### 共通型

```typescript
type TaskType = "command" | "agent";

type ProjectType =
  | "typescript-react"
  | "typescript-node"
  | "javascript-react"
  | "javascript-node"
  | "go"
  | "python"
  | "rust"
  | "unknown";

type IntentType =
  | "fix"
  | "implement"
  | "analyze"
  | "review"
  | "refactor"
  | "test"
  | "document"
  | "unknown";

type TechCategory =
  | "language"
  | "framework"
  | "library"
  | "tool"
  | "build-system";

type ErrorType =
  | "configuration"
  | "execution"
  | "timeout"
  | "validation"
  | "system";

type Priority = "low" | "medium" | "high";
```

---

## エラーコード

### Context Manager

- `CTX_INVALID_REQUEST`: 無効なリクエスト
- `CTX_PROJECT_NOT_FOUND`: プロジェクトが見つからない
- `CTX_CONTEXT_NOT_FOUND`: コンテキストが見つからない

### Communication Bus

- `BUS_TIMEOUT`: タイムアウト
- `BUS_NO_HANDLER`: ハンドラーが登録されていない
- `BUS_HANDLER_ERROR`: ハンドラーエラー
- `BUS_INVALID_MESSAGE`: 無効なメッセージ
- `BUS_SHUTDOWN`: Busがシャットダウン済み

### Agent Adapter

- `AGENT_NOT_FOUND`: エージェントが見つからない
- `AGENT_EXECUTION_FAILED`: エージェント実行失敗
- `AGENT_TIMEOUT`: エージェントタイムアウト

### Command Adapter

- `CMD_NOT_FOUND`: コマンドが見つからない
- `CMD_INVALID_ARGS`: 無効な引数
- `CMD_EXECUTION_FAILED`: コマンド実行失敗

### Error Handler

- `ERR_UNRECOVERABLE`: 回復不可能なエラー
- `ERR_MAX_RETRIES`: 最大再試行回数に到達
- `ERR_FALLBACK_FAILED`: フォールバック失敗

---

## ベストプラクティス

### エラーハンドリング

```typescript
// 常にエラーをキャッチして適切に処理
try {
  const result = await orchestrator.executeTask(request);
} catch (error) {
  if (error instanceof FrameworkError) {
    // Framework固有のエラー
    console.error(`Framework error [${error.code}]:`, error.message);
    if (error.recoverable) {
      const recovery = await errorHandler.attemptRecovery(error, context);
    }
  } else {
    // 予期しないエラー
    console.error("Unexpected error:", error);
  }
}
```

### リソースクリーンアップ

```typescript
// 使用後は必ずクリーンアップ
try {
  await orchestrator.executeTask(request);
} finally {
  await orchestrator.shutdown();
}
```

### タイムアウト設定

```typescript
// 適切なタイムアウトを設定
const response = await communicationBus.request(
  "agent",
  message,
  60000, // 重い処理には長めのタイムアウト
);
```

---

## 関連リファレンス

- **task-context-specification.md**: TaskContext詳細仕様
- **communication-bus-api.md**: Communication Bus詳細API
- **adapters-and-orchestration.md**: Adapters詳細実装

---

このAPIリファレンスは、Integration Frameworkのすべての公開APIを網羅しています。新しいコンポーネントの実装時に参照してください。
