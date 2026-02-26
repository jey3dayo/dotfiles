---
name: agents-only
description: Agent selection framework with capability matrix and task classification. Use when routing tasks, selecting optimal agents, or understanding agent capabilities. Focuses exclusively on agent orchestration via Task tool.
disable-model-invocation: false
user-invocable: false
---

# Agents - Agent Selection Framework

A framework for selecting the optimal agent based on task intent and context. Specialized for agent invocation via the Task tool.

## Purpose

- Task routing: Automatic agent selection based on intent analysis
- Capability matrix: Capability definitions and evaluation criteria for 7 agents
- Skill integration: Tech stack detection and relevant skill suggestions
- Context7 integration: Score optimization through library documentation utilization

## Quick Reference

### Key Functions

#### select_optimal_agent(task_description, context=None)

Returns the optimal agent and Skills to invoke for a given task.

```python
result = select_optimal_agent("Refactor TypeScript React app", context)
# {
#   "agent_type": "orchestrator",
#   "task_type": "implementation",
#   "skills": [
#     {"name": "typescript", "confidence": 0.86, ...},
#     {"name": "react", "confidence": 0.80, ...}
#   ],
#   "prompt": "..."  # with recommended Skill list
# }
```

### When to Use

#### detect_relevant_skills(task_description, context=None)

Estimates which Skills an agent should run alongside, based on tech stack detection and language-specific keywords.

```python
skills = detect_relevant_skills(
    "Fix security bug in React TypeScript app",
    context={"project": {"language": "typescript", "frameworks": ["react"]}}
)
# -> [SkillSuggestion(name="typescript", reason="...", confidence=0.86), ...]
```

### When to Use

#### calculate_agent_scores(context)

Calculates scores for each agent to determine the optimal agent.

```python
scores = calculate_agent_scores({
    "intents": [{"type": "error", "confidence": 0.9}],
    "has_documentation": True
})
# -> [{"name": "error-fixer", "confidence": 0.95, ...}, ...]
```

### When to Use

## Available Agents (7 agents)

### 1. error-fixer

- Specialty: Error detection, automatic fixing, type safety
- Quality score: 0.92 | **Speed score**: 0.90
- Best for: TypeScript errors, ESLint violations, improving type safety

### 2. orchestrator

- Specialty: Implementation, refactoring, task decomposition
- Quality score: 0.90 | **Speed score**: 0.85
- Best for: New feature implementation, large-scale refactoring, architectural changes

### 3. researcher

- Specialty: Investigation, analysis, debugging
- Quality score: 0.85 | **Speed score**: 0.80
- Best for: Root cause investigation, codebase analysis, problem diagnosis

### 4. code-reviewer

- Specialty: Code review, quality evaluation, security checks
- Quality score: 0.95 | **Speed score**: 0.70
- Best for: Code quality evaluation, design review, security audits

### 5. github-pr-reviewer

- Specialty: GitHub PR review, semantic analysis, Context7 integration
- Quality score: 0.96 | **Speed score**: 0.85
- Best for: GitHub PR reviews, comprehensive quality evaluation, documentation verification

### 6. docs-manager

- Specialty: Documentation management, link validation, structure optimization
- Quality score: 0.90 | **Speed score**: 0.95
- Best for: Documentation maintenance, link fixing, Markdown optimization

### 7. serena

- Specialty: Semantic analysis, symbol search, dependency analysis
- Quality score: 0.94 | **Speed score**: 0.88
- Best for: Code exploration, symbol search, reference tracking, safe refactoring

## Detailed References

For detailed implementation logic and matrices, refer to the following references:

- [Agent Capabilities Matrix](references/agent-capabilities.md) — Full capability matrix and evaluation criteria
- [Selection Algorithm](references/selection-algorithm.md) — Multi-layer analysis algorithm and score calculation
- [Task Classification](references/task-classification.md) — Task intent analysis patterns
- [Context7 Integration](references/context7-integration.md) — Context7 integration and score adjustment

## Examples

For practical usage examples and patterns, refer to:

- [Routing Patterns](examples/routing-patterns.md) — Common routing scenarios
- [Skill Suggestions](examples/skill-suggestions.md) — Automatic skill suggestion patterns
