# Task Decomposition Guide

## Purpose

Break complex tasks appropriately and visualize progress using `TaskCreate`/`TaskList`/`TaskUpdate`.

## Complexity Assessment

### Simple (No Decomposition Needed)

All of the following are true:

- Single-file change
- Change is clear (straightforward modification or bug fix)
- Can be completed in 3 steps or fewer

**Examples**:

- Fixing a typo
- Updating a single function
- Updating a config file

**Action**: Do not use TaskCreate; implement directly.

### Complex (Decomposition Needed)

Any of the following are true:

- Multiple files are changed
- Includes architectural changes
- More than 3 steps of work
- Impacts multiple components/modules

**Examples**:

- Adding a new feature
- Refactoring
- Fixing bugs across multiple areas
- API changes

**Action**: Register subtasks with TaskCreate.

## TaskCreate Patterns

### Feature Addition Pattern

**Example**: Add user authentication

```markdown
TaskCreate #1: "Define data models"
description: Define User and Session models and create database schema
activeForm: "Defining data models"

TaskCreate #2: "Implement auth APIs"
description: Implement POST /auth/login, POST /auth/logout endpoints
activeForm: "Implementing auth APIs"
blockedBy: [#1]

TaskCreate #3: "Implement middleware"
description: Implement JWT validation middleware and apply to protected routes
activeForm: "Implementing middleware"
blockedBy: [#2]

TaskCreate #4: "Add tests"
description: Add integration tests for the authentication flow
activeForm: "Adding tests"
blockedBy: [#3]
```

**Dependency reasoning**:

- Data model → API → middleware → tests (linear dependency)

### Refactoring Pattern

**Example**: Reorganize component directory structure

```markdown
TaskCreate #1: "Design new directory structure"
description: Define component taxonomy and plan the moves
activeForm: "Designing directory structure"

TaskCreate #2: "Move Atomic components"
description: Move basic components like Button, Input
activeForm: "Moving Atomic components"
blockedBy: [#1]

TaskCreate #3: "Move Composite components"
description: Move composite components like Form, Modal
activeForm: "Moving Composite components"
blockedBy: [#2]

TaskCreate #4: "Fix import paths"
description: Update all import paths to the new locations
activeForm: "Fixing import paths"
blockedBy: [#3]

TaskCreate #5: "Run tests and verify"
description: Run all tests and confirm there are no import errors
activeForm: "Running tests"
blockedBy: [#4]
```

**Dependency reasoning**:

- Design → Atomic move → Composite move → import fixes → tests (linear dependency)

### Bug Fix Pattern

**Example**: Fix a data race bug

```markdown
TaskCreate #1: "Investigate root cause"
description: Identify where the data race occurs and why
activeForm: "Investigating root cause"

TaskCreate #2: "Fix state management"
description: Adjust state management logic to prevent the race
activeForm: "Fixing state management"
blockedBy: [#1]

TaskCreate #3: "Handle edge cases"
description: Add guards for identified edge cases
activeForm: "Handling edge cases"
blockedBy: [#2]

TaskCreate #4: "Add regression tests"
description: Add tests to prevent regressions
activeForm: "Adding regression tests"
blockedBy: [#3]
```

**Dependency reasoning**:

- Investigation → fix → edge cases → tests (linear dependency)

## Dependency Inference Rules

### Linear Dependency (blockedBy: [previous task])

Use linear dependency when:

- Order is clear (data model → API → UI)
- Output of one task is input to the next

### Parallel Execution (no blockedBy)

Parallel execution is possible when:

- Modules/files are independent
- No mutual dependency
- Can be worked on at the same time

**Example**:

```markdown
TaskCreate #1: "Implement user API"
TaskCreate #2: "Implement product API"

# #1 and #2 can run in parallel (independent resources)
```

### Multiple Dependencies (blockedBy: [#1, #2])

Use multiple dependencies when:

- Completion of multiple tasks is required
- Integration task

**Example**:

```markdown
TaskCreate #1: "Implement user API"
TaskCreate #2: "Implement product API"
TaskCreate #3: "Integration tests"
blockedBy: [#1, #2]
```

## When to Use TaskUpdate

### At Start

```
TaskUpdate taskId: "1" status: "in_progress"
```

- Run immediately after retrieving the next task with `TaskList`
- Only choose tasks with empty `blockedBy`

### At Completion

```
TaskUpdate taskId: "1" status: "completed"
```

- Only when the task is fully complete
- Do not mark `completed` if tests are failing

### When Deleting a Task

```
TaskUpdate taskId: "1" status: "deleted"
```

- When the task is no longer needed
- When requirements change and the task becomes invalid

## Implementation Flow

```
Step 2: Task decomposition and planning
  ├─ Complexity assessment (Simple/Complex)
  ├─ If Complex:
  │   ├─ Register subtasks with TaskCreate
  │   ├─ Infer dependencies (set blockedBy)
  │   └─ Plan approval (for large changes)
  └─ If Simple: go directly to Step 3

Step 5: Subtask implementation loop
  ├─ Get next task with TaskList
  │   └─ Condition: blockedBy is empty, by ID order
  ├─ TaskUpdate status: "in_progress"
  ├─ Implement the task
  ├─ TaskUpdate status: "completed"
  └─ Repeat until all tasks are complete
```

## Notes

- Do not over-decompose (5-7 tasks is a good target)
- Each task should be understandable on its own
- `activeForm` should be present tense and user-facing
- Set dependencies explicitly (do not rely on guesswork)
- Always run TaskUpdate at task start and completion
