---
name: integration-framework
description: |
  [What] Claude Code integration architecture guide. Provides TaskContext standardization, Communication Bus patterns, agent/command adapters, error handling, and workflow orchestration. Activates when developing commands/agents, implementing inter-component communication, or using integration framework features.
  [When] Use when: developing new commands or agents, understanding TaskContext structure, implementing Communication Bus patterns, designing error handling strategies, building multi-agent workflows, or understanding integration points between components.
  [Keywords] integration framework, Claude, Code, TaskContext, Communication, Bus
---

# Integration Framework

Claude Code integration framework guide. Provides architecture, component integration, and implementation patterns for developers.

## Overview

The Integration Framework is a comprehensive solution for improving coupling and interoperability between agents and commands. It provides standardized interfaces, intelligent task routing, error recovery, and performance optimization while preserving all existing functionality.

### When to Use

This skill is activated in the following cases:

- Developing new commands or agents
- Understanding the TaskContext structure
- Implementing Communication Bus patterns
- Designing error handling strategies
- Building multi-agent workflows
- Understanding integration points between components

### Trigger Keywords

### Japanese

- "統合フレームワーク", "インテグレーションフレームワーク"
- "TaskContext", "タスクコンテキスト"
- "Communication Bus", "コミュニケーションバス"
- "エージェント開発", "コマンド開発"
- "コンポーネント統合", "ワークフローオーケストレーション"

### English

- "integration framework"
- "TaskContext", "task context"
- "Communication Bus", "communication bus"
- "develop agent", "develop command", "agent development", "command development"
- "component integration", "workflow orchestration"

## Core Concepts

### 1. TaskContext - Unified Task Context

All tasks operate with a unified context structure:

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

### Details

### 2. Communication Bus - Event-Driven Communication

Enables seamless interaction between components:

```javascript
// Publish an event
communicationBus.publish({
  type: "task.started",
  source: "integration-orchestrator",
  data: { taskId, context },
});

// Request-response pattern
const result = await communicationBus.request("error-fixer", {
  type: "fix-errors",
  files: ["src/index.ts"],
  context: enhancedContext,
});
```

### Details

### 3. Agent/Command Adapters - Integration Adapters

Integrates existing agents and commands into the framework:

- Agent Adapter: Provides TaskContext to agents
- Command Adapter: Standardizes command execution
- Integration Orchestrator: Overall coordination and routing

### Details

### 4. Error Handler - Advanced Error Handling

Comprehensive error classification and recovery:

```javascript
// Automatic error recovery
const recoveryResult = await errorHandler.handleError(error, context);

if (recoveryResult.success) {
  console.log(`✅ Auto-recovery successful: ${recoveryResult.strategy}`);
} else {
  console.log(
    `❌ Manual intervention required: ${recoveryResult.recommendations}`,
  );
}
```

## Detailed Reference

- For architecture, workflows, patterns, and troubleshooting, see `references/integration-framework-details.md`

## Next Steps

1. Identify target components
2. Select integration points
3. Prototype using quick-start patterns

## Related Resources

- `references/integration-framework-details.md`
