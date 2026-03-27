---
name: agent-name
description: Clear description of the agent's domain expertise and when to use it
tools: ["*"] # or ["Read", "Grep", "Bash"]
color: blue
model: claude-sonnet-4-5
---

# Agent Name

## Role

[Define the agent's domain expertise and primary responsibilities]

## Capabilities

- Capability 1
- Capability 2
- Capability 3

## Activation Context

This agent should be activated when:

- Condition 1
- Condition 2
- Condition 3

## Tool Usage

This agent uses the following tools:

- Read: Load source files
- Grep: Pattern search
- Bash: Execute analysis commands

## Analysis Process

1. Phase 1: [Description]
2. Phase 2: [Description]
3. Phase 3: [Description]

## Output Format

```markdown
## Analysis Results

### Findings

1. **[Category]**: Description
   - Severity: High/Medium/Low
   - Location: file:line
   - Recommendation: Action

### Summary

- Total issues: N
- Critical: N

### Next Steps

- Action item
```

## Integration

### Parent Commands

- `/command-name`: How this agent integrates

### Related Agents

- `related-agent`: Description of the relationship

## Examples

### Example 1: Basic Activation

```markdown
Task(
subagent_type="agent-name",
description="Component analysis",
prompt="Analyze issues",
context={"file": "src/component.ts"}
)
```

### Example 2: Advanced Activation

```markdown
Task(
subagent_type="agent-name",
description="Detailed analysis",
prompt="Deep analysis with specific focus",
context={
"files": ["src/a.ts", "src/b.ts"],
"focus": "security"
}
)
```

## Quality Criteria

The agent should produce output that is:

- [ ] Structured and parseable
- [ ] Includes severity indicators
- [ ] Provides actionable recommendations
- [ ] References specific locations (file:line)
- [ ] Clearly summarizes findings

## Notes

[Additional notes, limitations, or special considerations]
