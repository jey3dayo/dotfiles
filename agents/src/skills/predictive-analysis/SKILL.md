---
name: predictive-analysis
description: Predictive code analysis for identifying potential risks, anti-patterns, and future maintenance issues. Use when assessing code health or planning refactoring.
disable-model-invocation: false
user-invocable: true
allowed-tools: Read, Grep, Glob, Bash
argument-hint: [target-path]
---

# Predictive Code Analysis

Analyzes codebases to proactively predict and identify risks that may become problems in the future.

## Overview

The predictive code analysis system evaluates the following risk categories:

- Technical debt: Growing complexity, code that is difficult to maintain
- Security risks: Insufficient input validation, vulnerability patterns
- Performance bottlenecks: Inefficient algorithms, scalability issues

## Basic Usage

```bash
# Analyze entire project
/predictive-analysis

# Analyze a specific directory
/predictive-analysis src/

# Analyze by component
/predictive-analysis src/components/
```

## Risk Assessment Framework

### Risk Levels

| Level    | Description                                        | Response Deadline        |
| -------- | -------------------------------------------------- | ------------------------ |
| Critical | Requires immediate fix, impacts production         | Immediately              |
| High     | Requires urgent response, potential future failure | Within 1 week            |
| Medium   | Requires planned response, impacts maintainability | Within 1 month           |
| Low      | Improvement recommended, long-term quality         | Next refactoring session |

### Evaluation Criteria

Each risk is evaluated from the following perspectives:

1. Likelihood: The probability that this issue will actually occur
2. Impact: The severity of damage if it occurs
3. Timeline: Predicted timeframe for the issue to surface
4. Effort: Comparison of effort to fix now vs. fix later

## Analysis Process

### 1. Pattern Recognition

- Detection of common code patterns that cause problems
- Identification of hotspots where complexity is growing
- Discovery of anti-patterns that break down at scale
- Identification of potential time bombs (hardcoded values, assumptions)

### 2. Risk Classification

The analysis classifies findings into the following categories:

#### Technical Debt

- High-complexity functions
- Code duplication
- Tight coupling
- Frequently changed files

#### Security Risks

- Insufficient input validation
- Weak authentication/authorization
- Exposure of secrets
- Unsafe data processing

#### Performance Bottlenecks

- O(n²) or worse algorithms
- Memory leaks
- Inefficient queries
- Scalability constraints

### 3. Report Generation

Each prediction includes:

- Specific code location: filename, line number, function name
- Issue description: why it will become a problem in the future
- Impact estimate: timeline and scope of impact
- Fix suggestion: prioritized preventive measures

## Quick Start

### Basic Usage Flow

1. Run analysis: Specify target and start analysis
2. Risk assessment: Review detected issues and risk levels
3. Decide response plan: Plan response based on priority
4. Track: Manage as Todo/Issue (optional)

### Tracking Options After Analysis

After analysis completes, you can choose from the following tracking methods:

```
"How would you like to track these predictions?"

1. Create Todos: Track resolution progress
2. Create GitHub Issues: Generate issues with detailed information
3. Summary only: Provide actionable report without creating tasks
```

## Output Example

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔮 Predictive Code Analysis Report
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Critical] Security Risk
📍 Location: src/auth/login.ts:45-67
⚠️ Issue: User input concatenated into SQL string without input validation
📅 Timeline: Can be exploited immediately
💥 Impact: Risk of SQL injection attacks
🛠️ Mitigation: Use prepared statements or ORM

[High] Performance Bottleneck
📍 Location: src/api/search.ts:120-145
⚠️ Issue: O(n²) nested loop for data filtering
📅 Timeline: Latency occurs when data exceeds 1,000 records
💥 Impact: Response time over 10 seconds, degraded UX
🛠️ Mitigation: Switch to O(n) algorithm using Map/Set
```

## Detailed References

For more detailed information, see:

- [Risk Assessment Framework](references/risk-assessment-framework.md): Evaluation criteria and severity determination details
- [Analysis Methodology](references/analysis-methodology.md): Static analysis and pattern detection implementation
- [Issue Categorization](references/issue-categorization.md): Classification details for technical debt/security/performance
- [Mitigation Strategies](references/mitigation-strategies.md): Fix patterns by category

## Practical Examples

Real-world usage examples:

- [Risk Report Examples](examples/risk-report-examples.md): Actual analysis reports and response examples
- [Project-Specific Analysis](examples/project-specific-analysis.md): Analysis patterns by framework/language
- [Preventive Measures](examples/preventive-measures.md): Concrete preventive measures and implementation examples

## Dependencies

- project-detector: Automatic project type detection
- MCP Serena: Code structure analysis and dependency tracking

## Important Notes

This skill does NOT:

- Add signatures or watermarks indicating AI generation
- Change repository settings or permissions
- Automatically fix code without permission

All suggestions are subject to human review and approval.
