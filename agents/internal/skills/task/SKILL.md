---
name: task
description: |
  Intelligent task router with automatic agent selection. Analyze natural language task descriptions and route to optimal agent/command.
  [What] Parse task intent, integrate project context, select optimal agent, and execute with appropriate strategy
  [When] Use when: users mention "task", "タスク実行", provide natural language task descriptions, or need intelligent agent routing for development tasks
  [Keywords] task, intelligent routing, agent selection, natural language, task execution, orchestration
---

# Task - Intelligent Task Router

## Overview

Analyze natural language task descriptions and automatically route to the optimal agent/command for execution.

## Core Mission

Parse natural language tasks, understand project context, and select the optimal agent/command/toolchain to deliver practical results.

## Processing Architecture

### Phase 1: Multi-Layer Task Analysis

Analyze tasks from multiple perspectives:

#### Intent Analysis

- Primary intent detection (implementation, debugging, review, etc.)
- Task category classification
- Complexity assessment

#### Structural Decomposition

- Identify targets, constraints, scope
- Analyze dependencies
- Determine if simple or complex task

### Phase 2: Dynamic Context Integration

Integrate project information and execution history:

- Auto-detect project type (Next.js, React, Go, etc.)
- Load technology stack information
- Enhance with execution history
- Validate constraints

### Phase 3: Intelligent Agent Selection

Select optimal agent with confidence-based scoring:

### Simple Tasks

- Single agent execution
- Direct task completion

### Complex Tasks

- Multi-agent coordination
- Task decomposition and parallel execution

### Agent Capability Mapping

- error-fixer: Error fixing, type safety, code quality
- orchestrator: Implementation, refactoring, task decomposition
- code-reviewer: Code review, quality assessment, security
- researcher: Investigation, analysis, root cause analysis
- docs-manager: Documentation management, link validation
- serena: Semantic analysis, symbol search

### Phase 4: Execution & Optimization

Execute with real-time optimization:

- Display execution plan
- Execute single or multi-agent strategy
- Enhance results with context
- Record metrics (execution time, quality score, etc.)
- Save context for future reference

## Advanced Features

### Deep Thinking Mode

Enable with `--deep-think` or `--thinking` flags:

- Enhanced analysis for complex tasks
- Focus areas: root cause analysis, design decisions, optimization strategies, implementation strategies
- Complexity-based threshold (0.7)

### Focus Area Detection

- Root cause: "なぜ" (why), "why", "原因" (cause), "cause"
- Design: "設計" (design), "design", "アーキテクチャ" (architecture), "architecture"
- Optimization: "最適" (optimal), "optimal", "改善" (improve), "improve"
- Implementation: "実装" (implement), "implement", "方法" (method), "method"

### Continuous Learning System

Record execution results and improve future accuracy:

- Track task patterns and success rates
- Record agent performance metrics
- Generate recommendations based on history
- Calculate expected time and best agent

## Usage Examples

### Basic Usage

```bash
# Natural language task specification
/task "Review this code and check quality"
/task "Implement user authentication feature"
/task "Improve performance"

# Git/branch-related reviews
/task "Review against origin/develop"
/task "Review the latest commit"
```

### Advanced Usage

```bash
# Multi-step tasks
/task "Implement new feature, write tests, and update documentation"

# Constrained tasks
/task "Implement a REST API in Go following Clean Architecture"

# Analysis tasks
/task "Investigate why this test is failing and propose a fix"

# Semantic analysis tasks
/task "Find all implementations of the AuthService interface"
/task "Find all places calling the getUserById method"
```

### Interactive Mode

```bash
# Interactive execution
/task --interactive "Solve a complex problem"

# Dry run
/task --dry-run "Large-scale refactoring"

# Verbose logging
/task --verbose "Performance optimization"

# Deep Thinking mode
/task --deep-think "Task requiring complex technical decisions"
/task --thinking "Investigate why this error occurs"
```

## Integration Points

### Shared Utilities

This command integrates with shared utilities:

- integration-framework: TaskContext standardization and Communication Bus patterns
- agents-only: Agent selection logic and capability matrix
- project-detector: Project type detection (referenced from integration-framework)

### Skill Integration

Auto-loads relevant skills based on task analysis:

### Framework Skills

- integration-framework: TaskContext standardization, Communication Bus patterns

### Technology Stack Skills

- typescript: Type safety, any-type elimination, Result<T,E> patterns
- react: Component design, Hooks, performance optimization
- golang: Idiomatic Go, error handling, concurrency
- security: OWASP Top 10, input validation, authentication

## Execution Flow

```
/task "Fix TypeScript type errors"
    ↓
TaskContext creation (project detection)
    ↓
Technology stack detection: TypeScript
    ↓
Auto-load skills: ["typescript", "code-quality-improvement"]
    ↓
Agent selection: error-fixer
    ↓ (with skill context)
TypeScript type safety patterns + 3-layer fix strategy
    ↓
Execution complete
```

## Notes

- Always executes via agent-based execution (no direct command execution)
- All output is in English
- Metrics tracked: execution time, quality score, resource usage
- Learning system records all executions for future improvement
