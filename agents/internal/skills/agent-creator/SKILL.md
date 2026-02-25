---
name: agent-creator
description: |
  [What] Guide for creating subagent definitions. Provides structure, design patterns, tool access management, and integration points.
  [When] Use when: creating new agents, improving existing agents, or thinking through tool access design and integration approaches.
  [Keywords] agent, subagent, agent definition, tool access, integration, patterns, agent design
---

# Agent Creator

A guide for creating effective subagent definitions.

## About This Skill

Agents are specialized autonomous execution units invoked via the Task tool. They have expertise in specific domains and complete work without user interaction.

### What This Skill Provides

1. Agent design patterns — 5 proven patterns
2. Tool access management — how to use full/explicit/inherited modes
3. Templates and checklists — practical starter kits
4. Real examples — best practices extracted from existing agents

## Agent Structure

### Required Elements

All agents have the following structure:

```markdown
---
name: agent-name
description: Agent's domain of expertise and usage examples
tools: ["*"] | ["tool1", "tool2", ...] | "inherit"
color: blue
model: claude-sonnet-4-5
---

# Agent Name

## Role

[Agent's domain expertise and primary responsibilities]

## Capabilities

- Capability 1
- Capability 2
- Capability 3

## Activation Context

This agent should be activated when:

- Condition 1
- Condition 2

## Tool Usage

This agent uses the following tools:

- **Tool1**: Purpose
- **Tool2**: Purpose

## Analysis Process

1. **Phase 1**: Description
2. **Phase 2**: Description
3. **Phase 3**: Description

## Output Format

[Format for structured output]

## Integration

### Parent Commands

- `/command-name`: How it integrates

### Related Agents

- `related-agent`: Description of the relationship

## Examples

[Activation examples and parameters]
```

### YAML Frontmatter

- **name** (required): Agent identifier
  - Must match the filename (excluding `.md`)
  - kebab-case format
  - Descriptive and unique name

- **description** (required): Agent's domain of expertise
  - Clear role definition
  - Include examples of when to activate
  - Include trigger keywords
  - Written from a third-party perspective ("Use this agent when...")

- **tools** (required): Tool access specification
  - `["*"]` = access to all tools
  - `["Tool1", "Tool2"]` = explicit tool list
  - `"inherit"` = inherit from parent (experimental)

- **color** (optional): Terminal color
  - `blue` = analysis agents
  - `green` = validation agents
  - `yellow` = warning/audit agents
  - `red` = critical/security agents
  - `magenta` = utility agents
  - `cyan` = information agents

- **model** (optional): Model to use
  - `claude-sonnet-4-5` (default) — fast, cost-efficient
  - `claude-opus-4-5` — for tasks requiring complex reasoning

## Detailed Reference

- For design patterns, analysis frameworks, tool access, quality criteria, testing, and advanced patterns, see `references/agent-details.md`

## Next Steps

1. Clarify purpose and activation conditions
2. Draft using the template
3. Verify execution quality through testing

## Related Resources

- `references/agent-details.md`
