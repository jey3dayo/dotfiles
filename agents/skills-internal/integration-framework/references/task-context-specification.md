---
skill: integration-framework
topic: TaskContext Specification
last-updated: 2025-12-22
audience: Developer
---

# TaskContext完全仕様

## 概要

TaskContextは、Claude Code統合フレームワークにおけるすべてのタスク実行の中核となるデータ構造です。エージェント、コマンド、および統合コンポーネント間で一貫したコンテキストを提供します。

### 目的

- **統一インターフェース**: すべてのタスクで一貫したコンテキスト構造
- **情報共有**: エージェント/コマンド間でのコンテキスト共有
- **実行追跡**: タスクの起源、状態、結果を追跡
- **プロジェクト認識**: プロジェクト固有の情報を提供

### いつ使うか

- 新しいエージェントまたはコマンドを実装する際
- タスクルーティングロジックを設計する際
- エージェント間で情報を共有する際
- プロジェクトコンテキストに基づいて動作を調整する際

## 完全なインターフェース定義

```typescript
interface TaskContext {
  // コアメタデータ
  id: string; // 一意のタスク識別子（UUID）
  type: "command" | "agent"; // タスクタイプ
  source: string; // タスクの起源（user-request, agent-delegation等）

  // プロジェクト情報
  project: {
    root: string; // プロジェクトルートディレクトリ
    type: ProjectType; // プロジェクトタイプ（enum）
    stack: TechStack[]; // 技術スタック配列
    conventions: ProjectConventions; // プロジェクト規約
  };

  // 実行コンテキスト
  execution: {
    workingDirectory: string; // 現在の作業ディレクトリ
    targetFiles: string[]; // 対象ファイルリスト
    gitStatus: GitStatus; // Git状態情報
    environment: EnvironmentInfo; // 環境情報
  };

  // 意図分析
  intent: {
    primary: Intent; // 主要な意図
    secondary: Intent[]; // 副次的な意図
    confidence: number; // 信頼度（0-1）
    originalRequest: string; // 元のユーザーリクエスト
  };

  // 通信とワークフロー
  communication: {
    parentTask?: string; // 親タスクID（存在する場合）
    childTasks: string[]; // 子タスクIDリスト
    sharedData: Record<string, any>; // 共有データストア
  };

  // メタデータ
  metadata?: {
    createdAt: Date; // タスク作成時刻
    startedAt?: Date; // タスク開始時刻
    completedAt?: Date; // タスク完了時刻
    duration?: number; // 実行時間（ミリ秒）
    retryCount?: number; // 再試行回数
  };
}
```

## 型定義の詳細

### ProjectType

```typescript
enum ProjectType {
  TypeScriptReact = "typescript-react",
  TypeScriptNode = "typescript-node",
  JavaScriptReact = "javascript-react",
  JavaScriptNode = "javascript-node",
  Go = "go",
  Python = "python",
  Rust = "rust",
  Unknown = "unknown",
}
```

### TechStack

```typescript
interface TechStack {
  name: string; // 技術名（React, TypeScript等）
  version?: string; // バージョン（存在する場合）
  category: TechCategory; // カテゴリ（framework, language, tool等）
}

enum TechCategory {
  Language = "language",
  Framework = "framework",
  Library = "library",
  Tool = "tool",
  BuildSystem = "build-system",
}
```

### ProjectConventions

```typescript
interface ProjectConventions {
  // コーディング規約
  codingStandards: {
    typeSafety: boolean; // 型安全性を強制
    testRequired: boolean; // テスト必須
    documentationRequired: boolean; // ドキュメント必須
    lintingEnabled: boolean; // Lint有効
  };

  // ファイル構造規約
  fileStructure: {
    testDirectory: string; // テストディレクトリパス
    sourceDirectory: string; // ソースディレクトリパス
    buildDirectory: string; // ビルドディレクトリパス
  };

  // 命名規約
  naming: {
    fileNaming: "kebab-case" | "camelCase" | "PascalCase" | "snake_case";
    componentNaming: "PascalCase" | "camelCase";
    functionNaming: "camelCase" | "snake_case";
  };

  // コミット規約
  commitConventions: {
    conventional: boolean; // Conventional Commits準拠
    requirePrefix: boolean; // プレフィックス必須
    allowedPrefixes: string[]; // 許可されたプレフィックス
  };
}
```

### GitStatus

```typescript
interface GitStatus {
  branch: string; // 現在のブランチ
  isClean: boolean; // クリーン状態か
  stagedFiles: string[]; // ステージされたファイル
  unstagedFiles: string[]; // ステージされていないファイル
  untrackedFiles: string[]; // 追跡されていないファイル
  ahead: number; // リモートより先行しているコミット数
  behind: number; // リモートより後れているコミット数
  lastCommit?: {
    hash: string; // コミットハッシュ
    message: string; // コミットメッセージ
    author: string; // 作者
    date: Date; // 日付
  };
}
```

### EnvironmentInfo

```typescript
interface EnvironmentInfo {
  platform: "darwin" | "linux" | "win32"; // OS
  nodeVersion?: string; // Node.jsバージョン
  npmVersion?: string; // npmバージョン
  shell: string; // シェル
  editor?: string; // エディタ
  cwd: string; // 現在のディレクトリ
  env: Record<string, string>; // 環境変数
}
```

### Intent

```typescript
interface Intent {
  type: IntentType; // 意図タイプ
  entities: Entity[]; // 抽出されたエンティティ
  keywords: string[]; // キーワード
  confidence: number; // 信頼度（0-1）
}

enum IntentType {
  Fix = "fix", // エラー修正
  Implement = "implement", // 実装
  Analyze = "analyze", // 分析
  Review = "review", // レビュー
  Refactor = "refactor", // リファクタリング
  Test = "test", // テスト
  Document = "document", // ドキュメント
  Unknown = "unknown", // 不明
}

interface Entity {
  type: EntityType; // エンティティタイプ
  value: string; // 値
  confidence: number; // 信頼度
}

enum EntityType {
  File = "file", // ファイル
  Function = "function", // 関数
  Class = "class", // クラス
  Module = "module", // モジュール
  Error = "error", // エラー
  Technology = "technology", // 技術
}
```

## TaskContextの作成

### Context Manager使用

```typescript
import { ContextManager } from "./context-manager";

const contextManager = new ContextManager();

// 基本的なコンテキスト作成
const context = contextManager.createContext({
  type: "command",
  source: "user-request",
  originalRequest: "Fix TypeScript errors",
});

// プロジェクトコンテキストをロード
const projectContext = contextManager.loadProjectContext("./");

// コンテキストをマージ
const fullContext = {
  ...context,
  project: projectContext,
};
```

### 手動作成

```typescript
const context: TaskContext = {
  id: generateUUID(),
  type: "agent",
  source: "agent-delegation",

  project: {
    root: "/Users/username/project",
    type: ProjectType.TypeScriptReact,
    stack: [
      { name: "TypeScript", version: "5.0.0", category: TechCategory.Language },
      { name: "React", version: "18.0.0", category: TechCategory.Framework },
    ],
    conventions: {
      codingStandards: {
        typeSafety: true,
        testRequired: true,
        documentationRequired: false,
        lintingEnabled: true,
      },
      fileStructure: {
        testDirectory: "src/__tests__",
        sourceDirectory: "src",
        buildDirectory: "dist",
      },
      naming: {
        fileNaming: "kebab-case",
        componentNaming: "PascalCase",
        functionNaming: "camelCase",
      },
      commitConventions: {
        conventional: true,
        requirePrefix: true,
        allowedPrefixes: ["feat", "fix", "docs", "chore"],
      },
    },
  },

  execution: {
    workingDirectory: "/Users/username/project",
    targetFiles: ["src/components/Header.tsx"],
    gitStatus: {
      branch: "main",
      isClean: false,
      stagedFiles: ["src/components/Header.tsx"],
      unstagedFiles: [],
      untrackedFiles: [],
      ahead: 0,
      behind: 0,
    },
    environment: {
      platform: "darwin",
      nodeVersion: "20.0.0",
      npmVersion: "10.0.0",
      shell: "zsh",
      cwd: "/Users/username/project",
      env: process.env,
    },
  },

  intent: {
    primary: {
      type: IntentType.Fix,
      entities: [
        { type: EntityType.Error, value: "TypeScript", confidence: 0.9 },
      ],
      keywords: ["fix", "error", "typescript"],
      confidence: 0.95,
    },
    secondary: [],
    confidence: 0.95,
    originalRequest: "Fix TypeScript errors",
  },

  communication: {
    parentTask: undefined,
    childTasks: [],
    sharedData: {},
  },

  metadata: {
    createdAt: new Date(),
    retryCount: 0,
  },
};
```

## TaskContextの強化

### エージェント固有の強化

```typescript
// Error-fixer向け強化
const enhancedForErrorFixer = contextManager.enhanceForAgent(
  context,
  "error-fixer",
);

// 追加されるコンテキスト:
enhancedForErrorFixer.errorContext = {
  detectionPatterns: getErrorDetectionPatterns(),
  fixPatterns: loadFixPatternsDatabase(),
  qualityThresholds: getQualityThresholds(),
};

// Orchestrator向け強化
const enhancedForOrchestrator = contextManager.enhanceForAgent(
  context,
  "orchestrator",
);

// 追加されるコンテキスト:
enhancedForOrchestrator.orchestrationContext = {
  taskBreakdownStrategy: getTaskBreakdownStrategy(),
  executionConstraints: getExecutionConstraints(),
  dependencyGraph: analyzeDependencies(),
};
```

### プロジェクトコンテキストの自動検出

```typescript
// プロジェクトタイプの自動検出
function detectProjectType(rootDir: string): ProjectType {
  const hasPackageJson = existsSync(join(rootDir, "package.json"));
  const hasTsConfig = existsSync(join(rootDir, "tsconfig.json"));
  const hasGoMod = existsSync(join(rootDir, "go.mod"));
  const hasCargo = existsSync(join(rootDir, "Cargo.toml"));

  if (hasGoMod) return ProjectType.Go;
  if (hasCargo) return ProjectType.Rust;

  if (hasPackageJson) {
    const pkg = JSON.parse(readFileSync(join(rootDir, "package.json"), "utf-8"));
    const deps = { ...pkg.dependencies, ...pkg.devDependencies };

    if (deps.react && hasTsConfig) return ProjectType.TypeScriptReact;
    if (deps.react) return ProjectType.JavaScriptReact;
    if (hasTsConfig) return ProjectType.TypeScriptNode;
    return ProjectType.JavaScriptNode;
  }

  return ProjectType.Unknown;
}

// 技術スタックの自動検出
function detectTechStack(rootDir: string): TechStack[] {
  const stack: TechStack[] = [];

  if (existsSync(join(rootDir, "package.json"))) {
    const pkg = JSON.parse(readFileSync(join(rootDir, "package.json"), "utf-8"));
    const deps = { ...pkg.dependencies, ...pkg.devDependencies };

    Object.entries(deps).forEach(([name, version]) => {
      const category = categorize Technology(name);
      if (category) {
        stack.push({
          name,
          version: version as string,
          category
        });
      }
    });
  }

  return stack;
}
```

## TaskContextの共有

### 親子タスク間の共有

```typescript
// 親タスクからデータを共有
parentContext.communication.sharedData.analysisResult = {
  issues: 5,
  severity: "high",
  files: ["src/index.ts"],
};

// 子タスクを作成
const childContext = contextManager.createChildContext(parentContext, {
  type: "agent",
  source: "agent-delegation",
  originalRequest: "Fix issues found in analysis",
});

// 子タスクは親の共有データにアクセス可能
const analysisResult = childContext.communication.sharedData.analysisResult;
```

### シブリングタスク間の共有

```typescript
// Context Manager経由で共有
contextManager.shareContext(task1Id, task2Id, {
  key: "value",
  data: "shared-data",
});

// task2がtask1の共有データにアクセス
const sharedData = contextManager.getSharedData(task1Id, task2Id);
```

## Context Managerメソッド

### コアメソッド

```typescript
class ContextManager {
  // コンテキスト作成
  createContext(request: TaskRequest): TaskContext;

  // プロジェクトコンテキストをロード
  loadProjectContext(root: string): ProjectContext;

  // エージェント向けに強化
  enhanceForAgent(context: TaskContext, agentType: string): EnhancedTaskContext;

  // 子コンテキストを作成
  createChildContext(parent: TaskContext, request: TaskRequest): TaskContext;

  // コンテキストを共有
  shareContext(fromId: string, toId: string, data: any): void;

  // 共有データを取得
  getSharedData(fromId: string, toId: string): any;

  // コンテキストを保存
  saveContext(context: TaskContext): void;

  // コンテキストをロード
  loadContext(id: string): TaskContext | null;
}
```

### ユーティリティメソッド

```typescript
class ContextManager {
  // プロジェクトタイプを検出
  detectProjectType(root: string): ProjectType;

  // 技術スタックを検出
  detectTechStack(root: string): TechStack[];

  // Git状態を取得
  getGitStatus(root: string): GitStatus;

  // 環境情報を取得
  getEnvironmentInfo(): EnvironmentInfo;

  // 意図を分析
  analyzeIntent(request: string): Intent;

  // プロジェクト規約をロード
  loadProjectConventions(root: string): ProjectConventions;
}
```

## 使用例

### 例1: コマンドでのTaskContext使用

```typescript
// commands/task.md実装
export async function executeTaskCommand(request: string) {
  // TaskContextを作成
  const context = contextManager.createContext({
    type: "command",
    source: "user-request",
    originalRequest: request,
  });

  // プロジェクトコンテキストをロード
  context.project = contextManager.loadProjectContext("./");

  // 意図を分析
  context.intent = contextManager.analyzeIntent(request);

  // エージェントを選択
  const agent = agentSelector.selectAgent(context);

  // エージェント向けにコンテキストを強化
  const enhancedContext = contextManager.enhanceForAgent(context, agent);

  // エージェントを実行
  const result = await executeAgent(agent, enhancedContext);

  return result;
}
```

### 例2: エージェントでのTaskContext使用

```typescript
// agents/error-fixer.ts実装
export async function executeErrorFixer(context: EnhancedTaskContext) {
  // プロジェクトタイプに基づいてパターンを選択
  const patterns = getErrorPatternsForProject(context.project.type);

  // 対象ファイルを取得
  const files = context.execution.targetFiles;

  // エラーを検出
  const errors = await detectErrors(files, patterns);

  // エラーを修正
  const fixes = await applyFixes(errors, context.errorContext.fixPatterns);

  // 結果を共有データに保存
  context.communication.sharedData.fixes = fixes;

  return {
    success: true,
    fixedErrors: errors.length,
    files: files,
  };
}
```

### 例3: マルチエージェントワークフロー

```typescript
// ワークフロー実行
export async function executeWorkflow(context: TaskContext) {
  // Step 1: researcher
  const researchContext = contextManager.createChildContext(context, {
    type: "agent",
    source: "workflow-step",
    originalRequest: "Analyze requirements",
  });

  const researchResult = await executeAgent("researcher", researchContext);

  // 分析結果を共有
  contextManager.shareContext(researchContext.id, context.id, {
    analysis: researchResult,
  });

  // Step 2: orchestrator
  const implContext = contextManager.createChildContext(context, {
    type: "agent",
    source: "workflow-step",
    originalRequest: "Implement feature",
  });

  // 親の共有データにアクセス
  const analysis = implContext.communication.sharedData.analysis;

  const implResult = await executeAgent("orchestrator", implContext);

  // Step 3: code-reviewer
  const reviewContext = contextManager.createChildContext(context, {
    type: "agent",
    source: "workflow-step",
    originalRequest: "Review implementation",
  });

  const reviewResult = await executeAgent("code-reviewer", reviewContext);

  return {
    research: researchResult,
    implementation: implResult,
    review: reviewResult,
  };
}
```

## パフォーマンスとキャッシング

### コンテキストキャッシング

```typescript
class ContextCache {
  private cache = new Map<string, TaskContext>();

  // コンテキストをキャッシュ
  set(id: string, context: TaskContext, ttl: number = 3600000) {
    this.cache.set(id, context);
    setTimeout(() => this.cache.delete(id), ttl);
  }

  // キャッシュから取得
  get(id: string): TaskContext | undefined {
    return this.cache.get(id);
  }

  // キャッシュをクリア
  clear() {
    this.cache.clear();
  }
}
```

### プロジェクトコンテキストのキャッシング

```typescript
// プロジェクトコンテキストは高コスト → キャッシュする
const projectContextCache = new Map<string, ProjectContext>();

function loadProjectContext(root: string): ProjectContext {
  if (projectContextCache.has(root)) {
    return projectContextCache.get(root)!;
  }

  const context = {
    root,
    type: detectProjectType(root),
    stack: detectTechStack(root),
    conventions: loadProjectConventions(root),
  };

  projectContextCache.set(root, context);
  return context;
}
```

## ベストプラクティス

### 1. TaskContextは不変に扱う

```typescript
// 悪い例: 直接変更
context.execution.targetFiles.push("newfile.ts");

// 良い例: 新しいオブジェクトを作成
const updatedContext = {
  ...context,
  execution: {
    ...context.execution,
    targetFiles: [...context.execution.targetFiles, "newfile.ts"],
  },
};
```

### 2. 共有データは型安全に

```typescript
// 共有データの型定義
interface AnalysisSharedData {
  issues: number;
  severity: "low" | "medium" | "high";
  files: string[];
}

// 型安全な共有
context.communication.sharedData.analysis = {
  issues: 5,
  severity: "high",
  files: ["src/index.ts"],
} as AnalysisSharedData;

// 型安全な取得
const analysis = context.communication.sharedData
  .analysis as AnalysisSharedData;
```

### 3. Context Managerを使用

```typescript
// 悪い例: 手動でTaskContext作成
const context = {
  id: uuid(),
  type: "command",
  // ... 多くのフィールド
};

// 良い例: Context Managerを使用
const context = contextManager.createContext(request);
```

### 4. エージェント固有の強化

```typescript
// 各エージェントタイプに適切な強化
const context = contextManager.enhanceForAgent(baseContext, agentType);

// エージェントは強化されたコンテキストを期待
function executeAgent(agent: string, context: EnhancedTaskContext) {
  // agentTypeに基づいて追加のコンテキストを取得
}
```

## トラブルシューティング

### 問題1: プロジェクトタイプが不明

```typescript
// デバッグ: プロジェクト検出ログ
console.log("Project detection:");
console.log("- package.json:", existsSync("package.json"));
console.log("- tsconfig.json:", existsSync("tsconfig.json"));
console.log("- go.mod:", existsSync("go.mod"));

// 手動でプロジェクトタイプを設定
context.project.type = ProjectType.TypeScriptReact;
```

### 問題2: 共有データが利用できない

```typescript
// 共有データの存在確認
if (!context.communication.sharedData.analysis) {
  console.error("Analysis data not found in shared context");
  throw new Error("Missing analysis data");
}

// デフォルト値を提供
const analysis = context.communication.sharedData.analysis || {
  issues: 0,
  severity: "low",
  files: [],
};
```

### 問題3: パフォーマンス問題

```typescript
// プロファイリング
const startTime = Date.now();
const context = contextManager.loadProjectContext("./");
const duration = Date.now() - startTime;

if (duration > 1000) {
  console.warn(`Slow context loading: ${duration}ms`);
  // キャッシュを有効化
  contextManager.enableCache();
}
```

## 関連リファレンス

- **communication-bus-api.md**: Communication Busでのコンテキスト使用
- **adapters-and-orchestration.md**: アダプターでのコンテキスト変換
- **framework-api-reference.md**: Context Manager完全API

---

このリファレンスは、TaskContextの完全な仕様と使用方法を提供します。新しいコマンドやエージェントを実装する際の決定的なガイドとして使用してください。
