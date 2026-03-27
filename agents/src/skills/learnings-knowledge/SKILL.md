---
name: learnings-knowledge
description: AI-driven knowledge recording with categorization and auto-suggestion. Use when capturing insights, documenting fixes, or recording architectural decisions.
argument-hint: "[category] <description> [--search <query>] [--export <format>]"
disable-model-invocation: false
user-invocable: true
---

# Learnings Knowledge - AI-Driven Knowledge Recording System

## Overview

An AI-driven system for systematically recording and sharing important insights and learnings gained during development across the entire team. Provides automatic suggestions when starting similar tasks, immediate reference to past solutions when errors occur, and design pattern suggestions during code reviews.

## When to Use

- When immediate recording is needed (🔴🟠)
  - After critical bug fixes or incident response
  - When applying architectural decisions or design patterns
  - When discovering or addressing security vulnerabilities
  - Successful performance optimization cases

- Recording to improve development efficiency (🟡)
  - Discovering effective testing strategies
  - Improving debugging techniques
  - Patterns for fixing linter errors

- Recording as best practices (🟢)
  - Discovering clean code design approaches
  - Implementing reusable components
  - Database design optimization

## 7 Knowledge Categories

| Short form | Full form                 | Purpose                          |
| ---------- | ------------------------- | -------------------------------- |
| `fix`      | `--category fix`          | Linter and code quality fixes    |
| `arch`     | `--category architecture` | Architecture and design patterns |
| `perf`     | `--category performance`  | Performance optimization         |
| `sec`      | `--category security`     | Security and authentication      |
| `test`     | `--category testing`      | Testing and quality assurance    |
| `db`       | `--category database`     | Database and persistence         |
| `ui`       | `--category ui`           | UI and components                |

### Details

## Basic Usage Examples

```bash
# No category specified (AI auto-classifies)
/learnings Learn error handling patterns

# Short form (recommended)
/learnings fix Learn linter fix patterns
/learnings arch Learn about layer boundary design
/learnings perf Learn optimization techniques
/learnings sec Learn vulnerability mitigation for authentication flows
/learnings test Learn effective testing patterns
/learnings db Learn cache strategy optimization techniques
/learnings ui Learn component design best practices

# Traditional full form (maintained for compatibility)
/learnings --category fix Learn linter fix patterns
```

## 3-Stage Knowledge Recording Process

### 🔴🟠 Stage 1: Immediate Recording of Critical Insights

### Target

```bash
/learnings arch Learn how to implement new architecture patterns
/learnings sec Learn vulnerability mitigation for authentication flows
/learnings perf Learn cache strategy optimization techniques
```

### 🟡 Stage 2: Development Efficiency Insights

### Target

```bash
/learnings test Learn effective testing patterns
/learnings fix Learn efficient debugging techniques
```

### 🟢 Stage 3: Implementation Patterns and Best Practices

### Target

```bash
/learnings arch Learn clean code design
/learnings ui Learn component design best practices
```

### Details

## How to Use Knowledge

### 1. Automatic Suggestion System

- Automatically present related insights when starting similar tasks
- Immediately reference past solutions when errors occur
- Suggest design patterns during code reviews

### 2. Searching and Referencing Knowledge

```bash
# Search by category
/learnings --search arch   # List of architecture-related insights
/learnings --search test   # List of testing-related insights

# Keyword search
/learnings --search "error handling"  # Error handling related
/learnings --search "performance"      # Performance related
```

### 3. Sharing and Exporting Knowledge

```bash
# Export in Markdown format
/learnings --export markdown > learnings.md

# Export in JSON format (for system integration)
/learnings --export json > learnings.json
```

### Details

## Measurable Impact

- Recurrence prevention rate for identical errors: 95%+
- Reduction in implementation time: average 30%
- Reduction in code review findings: 40%

## Privacy and Security

- Project-specific confidential information is automatically masked
- Personal information and credentials are excluded from recording
- Insights are shared only within project scope

## Integration with Other Commands

- `/fix`: Automatically records insights during fixes
- `/review`: Saves review findings as knowledge
- `/task`: Records solution patterns for complex tasks
- `/todos`: Automatically extracts learnings upon task completion

### Details

## Detailed Reference

- Category details: `references/learning-categories.md`
- Recording process: `references/recording-process.md`
- Usage patterns: `references/usage-patterns.md`
- Recording examples: `examples/learning-records.md`
- Integration workflows: `examples/integration-workflows.md`

---

### Goals
