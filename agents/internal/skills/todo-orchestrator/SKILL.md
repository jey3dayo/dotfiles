---
name: todo-orchestrator
description: Unified task management system with interactive execution and AI-driven analysis. Shows TODO list, allows selection, executes tasks. Use when managing tasks, checking progress, or executing planned work.
argument-hint: "[add [description]] [--list] [--priority=<level>] [--suggest]"
disable-model-invocation: true
user-invocable: true
allowed-tools: Read, Write, Edit, Bash, Grep, TodoWrite
---

# Todo Orchestrator - Unified Task Management System

## Overview

Todo Orchestrator is an intelligent task management system integrating **TodoWrite + .claude/TODO.md**. It supports efficient task execution through an interactive UI, AI-driven priority analysis, and automatic dependency detection.

### Integrated Data Sources

- TodoWrite: In-session tasks, real-time updates
- .claude/TODO.md: Persistent tasks, human-editable, Git-managed

### Key Features

- Interactive mode: Number selection → confirmation → execution → automatic update
- AI-driven priority analysis: Automatic evaluation of complexity, impact scope, and dependencies
- Dependency management: Detection of blocked states and optimization of execution order
- Smart execution: Parallel execution, batch processing, effort estimation
- Quality assurance integration: Automatic checks before and after execution

## Usage

### Basic Usage

```bash
# Interactive mode (recommended)
todo-orchestrator

# List tasks only
todo-orchestrator --list

# Add task (with AI analysis)
todo-orchestrator add "Description of new task"

# Add with priority specified
todo-orchestrator add "Urgent task" --priority=P1

# AI suggestion proposals
todo-orchestrator --suggest
```

### Basic Flow in Interactive Mode

1. Task display and selection: Select by number from integrated task list (sorted by priority)
2. Pre-execution confirmation: Check dependencies, impact scope, and estimated effort
3. Automatic execution: Task execution, progress display, error handling
4. Result update: TodoWrite update, learning data accumulation

### Selection Options

- Number specification: `1`, `3`, `1-5`, `1,3,5`
- Bulk by priority: `high`, `medium`, `low`
- Skip: `skip`, `s` to postpone to next time

## Key Features

### 1. Interactive Execution

Intuitive task execution flow via number selection. Dependency check, pre-execution confirmation, real-time progress display.

### Details

### 2. Unified Task Management

Integrated display of TodoWrite and .claude/TODO.md. Priority sorting, deduplication, automatic synchronization.

### Details

### 3. AI-Driven Priority System

### P1 🟢 Immediate Execution

### P2 🟡 Standard Execution

### P3 🟠 Careful Execution

### P4 🟦 Integrated Execution

### P5 🔴 Planned Execution

### Details

### 4. Todo Addition Feature (AI Analysis)

Automatically analyzes the following from task descriptions:

- Requirement extraction: Clarify specific requirements of the task
- Impact scope: Identify components affected by changes
- Priority evaluation: Automatic determination of P1-P5 (complexity, risk, urgency)
- Dependencies: Identify blocking/blocked tasks
- Effort estimation: Estimate implementation time

### Details

### 5. Smart Execution Mode

```bash
# Automatic optimized execution
todo-orchestrator --mode=auto

# Intelligent priority ordering
todo-orchestrator --mode=smart

# Parallel execution (respecting dependencies)
todo-orchestrator --mode=parallel

# Effort estimation only
todo-orchestrator --mode=estimate

# Batch execution
todo-orchestrator batch high           # Bulk high-priority
todo-orchestrator batch 1-5,8          # Range specification
todo-orchestrator batch quick          # P1 only
```

### Details

## Basic Usage Examples

### Example 1: Interactive Selection

```
$ todo-orchestrator

=== Integrated Task List ===
[1] 🟢 P1 | Fix login validation bug (1h)
[2] 🟡 P2 | Add user profile page (4h)
[3] 🟠 P3 | Refactor auth module (1d) [blocks: 1]
[4] 🟦 P4 | Implement SSO integration (2d) [blocked by: 3]

Select task number to execute: 1

=== Pre-execution Confirmation ===
Task: Fix login validation bug
Priority: P1 (Immediate execution)
Estimated effort: 1 hour
Dependencies: None
Impact scope: auth/login.ts, tests/auth.test.ts

Proceed? (y/n/skip): y

[Running] Fix login validation bug...
✓ Code fix completed
✓ Test execution: PASS
✓ Lint/Format: PASS

[Done] Task completed. TodoWrite updated.
```

### Example 2: Task Addition (AI Analysis)

```
$ todo-orchestrator add "Implement password reset feature"

[Analyzing] Analyzing task requirements...

=== AI Analysis Results ===
Priority: P2 (Standard execution)
Reason: Standard feature addition, can follow existing patterns

Estimated effort: 4-6 hours
- Email sending setup: 1h
- Token generation and validation: 2h
- UI implementation: 1-2h
- Tests: 1h

Impact scope:
- auth/password-reset.ts (new)
- auth/email-service.ts (modify)
- pages/reset-password.tsx (new)

Dependencies:
- Email sending feature required (SMTP setup)

Add? (y/n/edit): y
✓ Task added
```

### Example 3: High-Priority Batch Execution

```
$ todo-orchestrator batch high

=== High-Priority Tasks (P1-P2) ===
[1] 🟢 P1 | Fix validation bug (1h)
[2] 🟢 P1 | Update error messages (30m)
[3] 🟡 P2 | Add loading states (2h)

Execute 3 tasks. Continue? (y/n): y

[1/3] Fix validation bug... ✓ Done (52m)
[2/3] Update error messages... ✓ Done (28m)
[3/3] Add loading states... ✓ Done (1h 45m)

=== Batch Execution Complete ===
Success: 3/3
Total time: 3h 5m
```

## Data Source Integration

### TodoWrite (In-Session)

- Real-time updates
- Within conversation context
- Temporary tasks

### .claude/TODO.md (Persistent)

- Git-manageable
- Human-editable
- Whole project

### Integrated Display

Both sources are integrated with priority sorting, deduplication, and automatic synchronization.

### Details

## Quality Assurance Checklist

### Planning Stage

- [ ] Requirements are clearly defined
- [ ] Impact scope is identified
- [ ] Dependencies are confirmed
- [ ] Priority is appropriately set

### Execution Stage

- [ ] Pre-execution confirmation is complete
- [ ] Dependent tasks are not blocked
- [ ] Execution log is recorded
- [ ] Error handling is appropriate

### Completion Stage

- [ ] All tests pass
- [ ] Lint/Format passes
- [ ] TodoWrite is updated
- [ ] Learning data is accumulated

## Related Skills and Commands

- [integration-framework](../integration-framework/): TaskContext standardization and workflow integration (lightweight dependency)
- TodoWrite: Required integration tool
- /task: Natural language task execution
- /learnings: Execution pattern learning

## Constraints and Notes

### Execution Constraints

- Dependencies: Blocked tasks are automatically skipped
- Parallel execution: Sequential execution when file conflicts exist
- On error: Execution is interrupted and state is rolled back

### Data Consistency

- Periodically verify synchronization between TodoWrite and .claude/TODO.md
- Duplicate tasks are automatically merged in integrated display
- Priority changes are reflected in both sources

### Quality Assurance

- P1-P2 can simplify pre-execution confirmation
- P3-P5 must always perform pre-execution confirmation
- Automatic rollback on test failure

## Detailed Reference

- [Interactive Execution Flow](references/interactive-execution-flow.md): Detailed UI for Phases 1-3
- [Priority System](references/priority-system.md): P1-P5 determination criteria and execution strategies
- [Todo Addition Flow](references/todo-add-flow.md): 5 elements of AI-driven analysis
- [Data Source Integration](references/data-source-integration.md): TodoWrite + .claude/TODO.md integration
- [Execution Pattern Collection](examples/interactive-patterns.md): Actual execution examples and logs
- [Smart Execution Modes](examples/smart-modes.md): auto/smart/parallel/estimate/batch
