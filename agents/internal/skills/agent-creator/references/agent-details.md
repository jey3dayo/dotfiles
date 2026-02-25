# Agent Creator - Detailed Reference

## 5 Design Patterns

### 1. Domain Expert Agent

### When to Use

- Specialized in a specific knowledge domain
- Requires comprehensive analysis capabilities
- Structured output is important

### Examples

### Characteristics

- Deep domain expertise
- Comprehensive evaluation framework
- Prioritized findings list
- Typically full tool access (`tools: ["*"]`)

### Implementation Pattern

```yaml
---
name: security
description: Expert in security analysis and vulnerability detection
tools: ["*"]
color: red
model: claude-sonnet-4-5
---
## Analysis Framework

- OWASP Top 10 evaluation
- Authentication/authorization pattern validation
- Data protection checks
- Input validation review
```

### 2. Project-Specific Agent

### When to Use

- Project-specific rules and patterns
- Architecture compliance validation
- Leverages project context

### Examples

### Characteristics

- Loads context from steering documents
- Validates project-specific patterns
- Enforces architecture boundaries
- Typically full tool access (`tools: ["*"]`)

### Implementation Pattern

```yaml
---
name: cygate-api
description: CyGate API specialist agent (Clean Architecture compliant)
tools: ["*"]
color: blue
---
## Project Context

- Clean Architecture layer boundaries
- Go idiom validation
- Business rule integrity
- Testing Trophy approach
```

### 3. Utility Agent

### When to Use

- Single-purpose focused tasks
- Deterministic and repeatable processing
- Minimal tool requirements

### Examples

### Characteristics

- Single responsibility
- Fast execution
- Explicit tool list
- Stateless

### Implementation Pattern

```yaml
---
name: format-validator
description: Specialized in code format validation
tools: ["Read", "Bash", "Glob"]
color: magenta
model: claude-sonnet-4-5
---
## Processing Flow

1. Read files
2. Apply format rules
3. Report violations
```

### 4. Orchestrator Agent

### When to Use

- Coordinates multiple subagents
- Workflow management
- Result aggregation and integration

### Examples

### Characteristics

- Tool access includes Task tool
- Delegation logic to subagents
- Result integration and reporting
- Decision-making framework

### Implementation Pattern

```yaml
---
name: code-reviewer
description: Comprehensive code review orchestrator
tools: ["*"] # includes Task tool
color: green
---

## Orchestration Strategy

1. Change analysis
2. Select specialist agents
3. Parallel execution:
   - security agent
   - performance agent
   - quality agent
4. Result aggregation
5. Unified report generation
```

### 5. Autonomous Agent

### When to Use

- Exploratory analysis
- Iterative improvement
- Self-correction capabilities

### Examples

### Characteristics

- Self-directed exploration
- Iterative refinement
- Adaptive approach
- Typically full tool access

### Implementation Pattern

```yaml
---
name: architecture-discoverer
description: Autonomous exploration of codebase architecture
tools: ["*"]
color: cyan
---
## Exploration Strategy

1. Entry point discovery
2. Dependency mapping
3. Pattern identification
4. Relationship graph construction
5. Architecture documentation generation
```

## Tool Access Modes

### Mode 1: Full Access (`tools: ["*"]`)

### When to Use

- Comprehensive exploration capabilities needed
- Unpredictable tool requirements
- Flexibility is important

### Best For

- Domain experts
- Project-specific agents
- Orchestrators
- Autonomous agents

### Example

```yaml
tools: ["*"]
```

### Mode 2: Explicit List (`tools: ["Tool1", "Tool2"]`)

### When to Use

- Tool requirements are clear and limited
- Security boundaries matter
- Performance optimization

### Best For

- Utility agents
- Single-purpose agents
- High-frequency execution agents

### Example

```yaml
tools: ["Read", "Grep", "Bash", "Glob"]
```

### Mode 3: Inherited (`tools: "inherit"`)

### When to Use

- Delegated from parent agent
- Part of a delegation chain
- Shared toolset needed

### Note

Experimental feature — use with caution.

### Tool Selection Guidelines

### Required Tools

- Read: Load file contents
- Glob: File pattern matching
- Grep: Content search

### Optional Tools

- Bash: Command execution, tests, builds
- Edit/Write: File modification (respect read-only principle)
- Task: Subagent invocation (for orchestrators)

### MCP Integration

- `mcp__serena__*`: Semantic code analysis
- `mcp__typescript__*`: TypeScript-specific features
- `mcp__o3__*`: Expert consultation
- `mcp__context7__*`: Library documentation reference

## Agent Configuration

### File Structure

```
agents/
├── security.md              # Domain expert
├── performance.md
├── typescript.md
├── kiro/                    # Grouped by context
│   ├── validate-design.md
│   ├── validate-gap.md
│   └── validate-impl.md
└── project-specific/
    ├── cygate-api.md
    └── asta-page-analyzer.md
```

### Naming Conventions

- kebab-case: `agent-name.md`
- Descriptive: name reflects domain/purpose
- Not too generic: `import-resolver` instead of `helper`
- Grouping: related agents in subdirectories

### Placement

- Global: `~/.claude/agents/`
- Project-specific: `.claude/agents/`

## Integration Points

### Invocation from Commands

Commands invoke agents via the Task tool:

```markdown
Task(
subagent_type="security",
description="Security analysis",
prompt="Analyze authentication implementation for vulnerabilities",
context={"files": security_files}
)
```

### Reference from Skills

Skills can reference agents for specific capabilities:

```markdown
For security-specific analysis, this skill delegates to the `security` agent.
```

### Agent-to-Agent Delegation

Agents can invoke other agents:

```markdown
Task(
subagent_type="type-analyzer",
description="Type safety analysis",
prompt="Analyze type safety of functions",
context=context
)
```

## Quality Criteria

### Required Elements Checklist

- [ ] Clear role definition and domain expertise
- [ ] YAML frontmatter with all required fields
- [ ] Explicit capabilities list
- [ ] Documented activation context (when to use)
- [ ] Output format specification
- [ ] Tool access appropriate to the role

### Best Practices

- [ ] Follow single responsibility principle
- [ ] Output is structured and parseable
- [ ] Integrates with existing agent ecosystem
- [ ] Uses established patterns from similar agents
- [ ] Provides activation examples
- [ ] Documents expected inputs and outputs
- [ ] Respects read-only principle

### Anti-Patterns (Avoid)

- ❌ Generic "do everything" agents (too broad)
- ❌ Duplicating existing agent functionality
- ❌ Excessive tool access permissions (request only what's needed)
- ❌ File modification without explicit user request
- ❌ Missing integration guidance
- ❌ Unclear activation criteria

## Agent vs Skill vs Command Decision Matrix

| Aspect         | Agent                     | Skill                       | Command                |
| -------------- | ------------------------- | --------------------------- | ---------------------- |
| **Invocation** | Via Task tool             | Auto-trigger                | User types `/cmd`      |
| **Autonomy**   | Autonomous execution      | Context-aware guidance      | User-driven            |
| **Scope**      | Focused subtask           | Domain expertise            | Workflow coordination  |
| **State**      | Stateless per invocation  | Context across conversation | Session-based          |
| **Examples**   | `security`, `performance` | `typescript`, `react`       | `/review`, `/refactor` |

### When to Choose Agent

- Task is a delegatable subcomponent of a larger workflow
- Autonomous execution without user interaction is needed
- Output is returned to a parent process
- Expertise is focused and repeatable

### When to Choose Skill

- Domain expertise spans multiple interactions
- Context builds throughout a conversation
- Keyword-based auto-triggering adds value
- Guidance is more important than execution

### When to Choose Command

- User explicitly initiates a workflow
- Multi-phase coordination is needed
- Session management is required
- Direct user interaction is essential

## Agent Output Format

### Structured Output

Agents should return structured and parseable results:

```markdown
## Analysis Results

### Findings

1. **[Category]**: Description
   - Severity: High/Medium/Low
   - Location: file:line
   - Recommendation: Action item

### Summary

- Total issues: N
- Critical: N
- Actionable: N

### Next Steps

1. Action item
2. Action item
```

### Integration-Friendly Format

- Consistent headings for parsing
- Severity/priority indicators
- Provide file:line references
- Separate findings from recommendations

## Model Selection

### claude-sonnet-4-5 (Default)

### When to Use

- Most analysis tasks
- Pattern recognition
- Cost efficiency matters
- Fast execution needed

### Best For

- Utility agents
- Standard domain experts
- High-frequency execution agents

### claude-opus-4-5

### When to Use

- Complex reasoning required
- Nuanced decision-making
- Deep architecture analysis
- Trade-off evaluation

### Best For

- Architecture reviews
- Design validation
- Complex problem solving

## Templates and Resources

### Starter Template

Basic structure is available at `resources/templates/agent-template.md`.

### Real Examples

Refer to the following real examples:

- `resources/examples/domain-expert-agent.md` - Security agent example
- `resources/examples/project-specific-agent.md` - Project-specific example
- `resources/examples/validator-agent.md` - Validation agent example

### Quality Checklist

A comprehensive checklist is available at `resources/checklist.md`.

## Testing Agents

### Activation Test

```python
# Invoke via Task tool
result = Task(
  subagent_type="your-agent",
  description="Test description",
  prompt="Test task",
  context={"test": "data"}
)
```

### Validation Items

1. Tool access: Can it access the declared tools?
2. Output format: Is it structured as documented?
3. Integration: Does it work correctly with parent commands/workflows?
4. Edge cases: Can it handle missing/invalid input?

## Advanced Patterns

### Multi-Agent Workflow

```markdown
1. Parent command identifies needs
2. Command invokes Agent A (analysis)
3. Agent A returns structured findings
4. Command invokes Agent B with Agent A's output (validation)
5. Command aggregates results
```

### Conditional Agent Selection

```markdown
Based on project type:

- TypeScript project → invoke `typescript` agent
- Go project → invoke `golang` agent
- Python project → invoke `python` agent
```

### Parallel Agent Execution

```python
# Concurrent execution (single message, multiple Task calls)
results = await parallel_execute([
  Task(subagent_type="security", ...),
  Task(subagent_type="performance", ...),
  Task(subagent_type="quality", ...)
])

# Aggregate results after all complete
```

## Next Steps

After creating an agent:

1. Test invocation via Task tool
2. Verify tool access works as expected
3. Validate output format
4. Document integration in parent command/skill
5. Add examples to agent documentation
6. Consider converting to skill if broader scope is needed

## Related Resources

- command-creator skill: How to create commands that use agents
- rules-creator skill: How to create rules that agents validate
- skill-creator skill: For broader domain ecosystems
- agents-and-commands skill: Differences between agents and commands
- integration-framework skill: Integration patterns

---

Use this skill to create consistent, well-integrated, high-quality subagents.
