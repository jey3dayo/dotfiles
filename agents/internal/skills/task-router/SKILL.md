---
name: task-router
description: Intelligent task router with multi-layer analysis and automatic agent selection. Analyzes natural language requests, selects optimal agents, and orchestrates execution. Use when user provides task descriptions like "review this code" or "improve performance".
argument-hint: <task-description> [--interactive] [--dry-run] [--verbose] [--deep-think]
disable-model-invocation: false
user-invocable: true
context: fork
agent: general-purpose
allowed-tools: Task, Read, Grep, Glob, WebFetch
---

# Task Router - Intelligent Task Router

An next-generation integrated system that automatically selects and executes the optimal agent based on natural language task descriptions.

## 🎯 Core Mission

Analyze natural language tasks, understand the project context, then select and execute the optimal agent/command/toolchain to deliver practical results.

## 🔧 Enhanced Integration Framework

This skill uses the integration framework to provide the following advanced capabilities.

### 4 Core Components

1. Integration Orchestrator: Coordinated operation of all system components
2. Enhanced Task Router: Machine learning-based optimal agent selection
3. Standardized Interface: Seamless cooperation between agents and commands
4. Automatic Error Recovery: Advanced error handling and recovery strategies

### Implemented Features

1. Deep Natural Language Analysis: Multi-layer task intent understanding
2. Dynamic Context Integration: Comprehensive assessment of project, history, and environment
3. Intelligent Routing: Confidence-based optimal selection
4. Execution Result Optimization: Metrics-driven continuous improvement

## 📋 4 Phase Task Processing

### Phase 1: Multi-Layer Task Analysis

Analyzes tasks from multiple perspectives to determine the execution strategy.

#### 3-Layer Analysis System

1. **Semantic Layer** (meaning understanding)
   - 9 intent type classification: error, implement, fix, analyze, review, github_pr, refactor, navigate, docs
   - Task structure decomposition
   - Conversion to actionable units

2. **Intent Layer** (intent analysis)
   - Extraction of primary and secondary intents
   - Keyword-based confidence scoring
   - Task category determination

3. **Structural Layer** (structural decomposition)
   - Identification of targets, constraints, and scope
   - Dependency analysis
   - Complexity calculation (below 0.8: simple, 0.8 or above: complex)

#### Task Analysis Report

```markdown
🎯 **Task Analysis Report**
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📝 **Original Request**: "Implement user authentication"
🔍 **Interpreted Intent**: implement
🎯 **Task Category**: implementation
📊 **Complexity**: complex (0.85)
⏱️ **Estimated Time**: 2-4hr
📚 **Referenced Libraries**: express, passport, bcrypt
🔧 **Required Capabilities**: implementation, testing, security

**Decomposed Actions**:

1. Setup authentication middleware
2. Implement user registration
3. Add password hashing
4. Create login endpoint
5. Add JWT token generation
```

### Details

### Phase 2: Dynamic Context Integration

Integrates project information and execution history to determine the optimal execution strategy.

#### Information Integrated

- Project information: type, technology stack, structure, conventions
- Execution history: success rates for similar tasks, average time, recommended agents
- Environment information: resource constraints, available tools
- Library documentation: latest API information via Context7

#### Context7 Integration

Automatically detects library references in tasks and retrieves the latest documentation.

```python
# Automatic library detection
detected_libraries = detect_library_references(task_description)
# "React Hooks", "Next.js", "TypeScript", etc.

# Documentation enrichment
context = enhance_context_with_docs(context, detected_libraries)
# Latest API information is added to context.documentation
```

### Details

### Phase 3: Intelligent Agent Selection

Performs confidence-based multi-stage agent selection.

#### Selection Process

1. Intent analysis: Extract primary and secondary intents of the task
2. Capability matching: Cross-reference with agent capability matrix
3. Confidence scoring: Calculate scores from 0.0 to 1.0
4. Context7 adjustment: ±10% adjustment based on availability of library documentation
5. Execution strategy determination: Single or multiple agents

#### Agent Capability Matrix

| Agent              | Primary Capability          | Quality    | Speed      | Best Use Case                             |
| ------------------ | --------------------------- | ---------- | ---------- | ----------------------------------------- |
| error-fixer        | Error fixing, type safety   | ⭐⭐⭐⭐⭐ | ⚡⚡⚡⚡   | Type errors, lint fixes                   |
| orchestrator       | Implementation, refactoring | ⭐⭐⭐⭐⭐ | ⚡⚡⚡     | New features, large-scale changes         |
| code-reviewer      | Review, quality assessment  | ⭐⭐⭐⭐⭐ | ⚡⚡⚡⚡   | Code quality, security                    |
| researcher         | Investigation, analysis     | ⭐⭐⭐⭐⭐ | ⚡⚡⚡     | Problem investigation, technical research |
| github-pr-reviewer | PR review                   | ⭐⭐⭐⭐⭐ | ⚡⚡⚡⚡   | GitHub PR specialist                      |
| docs-manager       | Documentation management    | ⭐⭐⭐⭐   | ⚡⚡⚡⚡⚡ | Link validation, updates                  |
| serena             | Semantic analysis           | ⭐⭐⭐⭐⭐ | ⚡⚡⚡⚡⚡ | Symbol search, impact analysis            |

### Details

- [Agent Detailed Profiles](references/agent-profiles.md)
- [Selection Algorithm](references/agent-selection-logic.md)

### Phase 4: Execution & Optimization

Performs execution and real-time optimization.

#### Execution Flow

1. Display execution plan: strategy, agents, confidence, estimated time
2. Metrics initialization: start time, status
3. Apply Context7 documentation: provide library information to agents
4. Agent-based execution: always execute using agents
5. Result enhancement: quality score calculation, metrics update
6. Context persistence: recording to learning system

#### Execution Strategy

- **Simple tasks** (complexity < 0.8): Execute with single agent
- **Complex tasks** (complexity >= 0.8): Collaborative execution with multiple agents

```markdown
🚀 **Task Execution Plan** (Agent-Based)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 **Strategy**: single_agent
🤖 **Primary Agent**: orchestrator
🎯 **Confidence**: 92.5%
⏱️ **Estimated Time**: 2-3hr
📚 **Library Docs**: express, passport, bcrypt
```

### Details

## 🧠 Deep Thinking Mode

For tasks requiring complex technical judgment, Deep Thinking mode is activated.

### How to Enable

```bash
/task --deep-think "Task requiring complex technical judgment"
/task --thinking "Investigate why this error occurs"
```

### Automatic Focus Area Determination

The following focus areas are automatically determined from the task content.

- root_cause_analysis: When containing "why", "cause", "reason"
- design_decisions: When containing "design", "architecture", "pattern"
- optimization_strategies: When containing "optimal", "improve", "performance"
- implementation_strategies: When containing "implement", "method", "approach"

## 🎯 Usage Examples

### Basic Usage

```bash
# Specify task in natural language
/task "Review this code and check quality"
/task "Implement user authentication feature"
/task "Improve performance"
/task "Fix documentation links"

# Git/branch-related review
/task "Review origin/develop"
/task "Review differences with origin/main"
```

### Advanced Usage

```bash
# Complex multi-step tasks
/task "Implement new feature, write tests, and update documentation"

# Tasks with constraints
/task "Implement REST API in Go following Clean Architecture"

# Analysis tasks
/task "Investigate why this test fails and suggest a fix"

# Semantic analysis tasks
/task "Find all implementations of the AuthService interface"
/task "Find all places that call the getUserById method"
```

### Library Documentation via Context7 Integration

```bash
/task "How to use useState and useEffect in React Hooks"
/task "Implement data fetching with Next.js 14 App Router"
/task "Implement a function using generic types in TypeScript"
/task "Apply responsive design with Tailwind CSS"
```

### Interactive Mode

```bash
# Interactive execution
/task --interactive "Solve a complex problem"

# Dry run
/task --dry-run "Large-scale refactoring"

# Execution with detailed logs
/task --verbose "Performance optimization"
```

### Details

## 📊 Continuous Learning System

A system that learns from task execution and improves future accuracy.

### Information Recorded

- Task ID, intent, project type
- Agents used
- Execution metrics (time, quality score, resource usage)
- Execution results (success/failure)

### Generated Recommendations

The following are generated from similar tasks.

- Success rate: Probability of success for similar tasks
- Expected time: Average execution time
- Recommended agent: Agent that demonstrated the highest performance

```markdown
## 🧠 Learning Insights

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
**Pattern Detected**: "implement" tasks in Go projects
**Success Rate**: 87% (35/40 executions)
**Average Time**: 18m (±5m)

**Recommendations**:

- Use 'researcher' agent (95% success)
- Include Clean Architecture context
- Pre-load project conventions
```

## 🔄 Integration Points

### Integration Framework

- integration-framework: TaskContext standardization, Communication Bus pattern
- mcp-tools: Context7 and other MCP server integrations

### Command Integration

- TodoWrite: Automatically add follow-up tasks after execution
- Learnings: Automatically record insights gained from execution
- Review: Automatically launch review after implementation task completion

### Technology Stack-Specific Skills (Auto-detected)

| Detection Condition      | Skill             | Provided Content                                             |
| ------------------------ | ----------------- | ------------------------------------------------------------ |
| TypeScript project       | typescript        | Type safety, any type elimination, Result<T,E> pattern       |
| React project            | react             | Component design, Hooks, performance optimization            |
| Go language project      | golang            | Idiomatic Go, error handling, concurrency                    |
| API/backend              | security          | OWASP Top 10, input validation, authentication/authorization |
| Semantic analysis needed | semantic-analysis | Symbol search, impact analysis, dependency tracking          |

### Details

## 📁 Reference Documentation

### Architecture Details

- [Processing Architecture Details](references/processing-architecture.md) - Detailed 4-Phase flow
- [Agent Selection Logic](references/agent-selection-logic.md) - Multi-layer analysis algorithm

### Agents and Skills

- [Agent Detailed Profiles](references/agent-profiles.md) - Capability matrix details
- [Skill Integration Guide](references/skill-integration-guide.md) - Automatic integration patterns

### Practical Examples and Error Handling

- [Usage Pattern Collection](examples/usage-patterns.md) - Practical usage examples
- [Error Recovery Strategies](examples/error-recovery-strategies.md) - Error handling details

## 🎯 Goal

A truly intelligent development assistant that can execute any development task in natural language without being aware of the underlying agents.
