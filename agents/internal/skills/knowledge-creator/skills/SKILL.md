---
name: knowledge-creator
description: |
  [What] Intelligent knowledge classification and creation system. Analyzes knowledge descriptions to automatically determine the optimal format (Skill/Agent/Command/Rules) and routes to appropriate creator tools
  [When] Use when: users want to create documentation, mention "create skill/agent/command/rules", "classify knowledge", "スキル作成", "知識分類", or need guidance on which format to use for their knowledge
  [Keywords] create skill, create agent, create command, create rules, classify doc, knowledge management, スキル作成, エージェント作成, コマンド作成, ルール作成, 知識分類, ドキュメント分類
---

# knowledge-creator - Intelligent Knowledge Classification & Creation

## Overview

This skill provides intelligent classification of knowledge and automatic routing to the appropriate creation tool. Following the [Agent Skills standard](https://agentskills.io), this skill helps create **agent capability extensions** that are portable, executable, and follow progressive disclosure principles.

### Core Capability

### Standards Compliance

## Agent Skills Philosophy

Agent Skills are **lightweight, open format extensions** that package:

- Instructions (procedural guidance)
- Scripts (executable components)
- References (supporting materials)
- Assets (templates, resources)

### Key Principle

### Progressive Disclosure Architecture

Agent Skills follow a 3-phase model:

1. **Discovery Phase** 🔍
   - Agents load only skill names + descriptions at startup
   - Minimal memory footprint
   - Fast initialization

2. **Activation Phase** ⚡
   - Task matches skill's purpose
   - Agent accesses full instructions
   - References loaded on-demand

3. **Execution Phase** 🚀
   - Agent follows guidance
   - Executes bundled scripts if needed
   - Loads templates/resources dynamically

## Classification Framework

### Decision Tree (Simplified)

```
Natural Language Knowledge Description
    ↓
Intent Analysis + Task Characteristics
    ↓
Format Selection:
  Q1: Repeatable knowledge? → Skill
  Q2: Autonomous task execution? → Agent
  Q3: User-interactive operation? → Command
  Q4: Project-specific constraints? → Rules
    ↓
Route to appropriate creator tool
    ↓
Guide through creation process
```

### Format Comparison (Agent Skills Perspective)

| Format  | Purpose                   | Trigger         | Reusability            | Execution  | Scripts Support   |
| ------- | ------------------------- | --------------- | ---------------------- | ---------- | ----------------- |
| Skill   | Capability extension      | Keyword/context | High (cross-platform)  | Referenced | ✅ Recommended    |
| Agent   | Autonomous task execution | Task type       | Medium (similar tasks) | Automated  | ✅ Recommended    |
| Command | Interactive operation     | User invocation | Project-specific       | Manual     | ⚠️ Optional       |
| Rules   | Constraints & guidelines  | Always active   | Project-specific       | Enforced   | ❌ Not applicable |

### Additional Knowledge Domains

| Domain                  | Skill Reference       | Purpose                                                   | Keywords                                   |
| ----------------------- | --------------------- | --------------------------------------------------------- | ------------------------------------------ |
| Distribution Management | distributions-manager | Bundle creation, deployment architecture, Nix integration | distributions, bundle, symlink, deployment |

### Agent Skills Standard Structure

```
skill-name/
├── SKILL.md         (required: YAML + instructions)
├── scripts/         (optional: executable workflows)
├── references/      (optional: detailed documentation)
└── assets/          (optional: templates, resources)
```

### When to Use Each Format

#### Skill ✨

### Best For

- Capability extension for agents (e.g., mise tool management, React patterns)
- Technology-specific best practices with executable workflows
- Cross-platform, repeatable knowledge
- Knowledge requiring Progressive Disclosure (overview + detailed references)
- Automation-ready procedures with optional scripts

### Structure Components

- SKILL.md: YAML frontmatter + instructions (required)
- scripts/: Automation workflows, validation tools (recommended)
- references/: Detailed documentation (optional, for complex topics)
- assets/: Templates, config files (optional)

### Examples

- Tool ecosystem knowledge (mise, Docker, Kubernetes) + setup scripts
- Framework patterns (React hooks, Vue composition API) + code generators
- Language conventions (TypeScript best practices) + linting automation

### Indicators

- "繰り返し使う知識" (repeatable knowledge)
- "他のプラットフォームでも使える" (usable in other platforms/agents)
- "自動化できる手順" (automatable procedures)
- "ベストプラクティス" (best practices)
- Technology/framework names in description

### Cross-Platform Benefit

#### Agent 🤖

### Best For

- Autonomous task execution
- Multi-step workflows
- Tasks requiring decision-making
- Domain-specific operations

### Examples

- Code review automation
- Error fixing workflows
- Deployment procedures
- Security scanning

### Indicators

- "自動実行" (automatic execution)
- "タスクの実行" (task execution)
- "ワークフロー" (workflow)
- Verbs like "implement", "fix", "review", "analyze"

#### Command 📝

### Best For

- User-initiated operations
- Interactive workflows
- Project-specific tasks
- Single-purpose operations

### Examples

- Git commit helpers
- Code formatting triggers
- Test runners
- Build orchestration

### Indicators

- "手動実行" (manual execution)
- "ユーザーが起動" (user invoked)
- "対話的" (interactive)
- Starts with "/" in description

#### Rules 📋

### Best For

- Project-specific constraints
- Coding standards
- Process guidelines
- Architectural decisions

### Examples

- Type safety requirements
- Error handling patterns
- File structure conventions
- Naming standards

### Indicators

- "プロジェクト固有" (project-specific)
- "ルール" (rules)
- "制約" (constraints)
- "~してはいけない" (must not)

## Usage Workflow

### Step 1: Describe Knowledge

User provides natural language description:

> "I want to document how to migrate npm packages to mise configuration"

### Step 2: Analysis

System analyzes:

- Keywords: "migrate", "npm packages", "mise"
- Context: Tool management, configuration
- Reusability: High (applicable to any mise project)
- Execution: Reference material, not automated

### Classification Confidence

### Step 3: Recommendation

```
📊 Classification Result:

Format: Skill
Confidence: 95%

Reasoning:
- Repeatable knowledge about mise tool management
- Applicable across multiple projects
- Technical best practices
- Requires detailed reference documentation

Next Steps:
1. Create skill structure
2. Write SKILL.md with Progressive Disclosure
3. Add detailed references
4. Provide templates and examples

Integration:
- Will be triggered by keywords: "mise", "npm migration", "tool management"
- Compatible with existing mise skill
- Can be referenced by agents and commands
```

### Step 4: Route to Creator

Based on classification, route to:

- Skill → `skill-creator` skill
- Agent → `agent-creator` skill
- Command → `command-creator` skill
- Rules → `rules-creator` skill

### Special Routing Rules

#### Distribution & Deployment

For questions about distributions, bundles, or deployment:

- Bundle management → `distributions-manager` skill
- Nix deployment issues → `distributions-manager` skill (architecture reference)
- Symlink patterns → `distributions-manager` skill
- Priority conflicts → `distributions-manager` skill (priority-mechanism reference)
- Custom bundle creation → `distributions-manager` skill (creating-bundles reference)

## Quick Start Examples

### Example 1: Tool Knowledge

### Input

> "mise設定のベストプラクティスをまとめたい"

### Analysis

- Repeatable knowledge ✓
- Cross-project applicable ✓
- Technical best practices ✓
- → **Skill** (90% confidence)

### Action

### Example 2: Automation Task

### Input

> "コードレビューを自動化したい"

### Analysis

- Autonomous execution ✓
- Multi-step workflow ✓
- Decision-making required ✓
- → **Agent** (95% confidence)

### Action

### Example 3: User Operation

### Input

> "Git commitを簡単にするコマンドが欲しい"

### Analysis

- User-initiated ✓
- Interactive operation ✓
- Project-specific ✓
- → **Command** (90% confidence)

### Action

### Example 4: Project Constraints

### Input

> "anyを使わないルールを設定したい"

### Analysis

- Project-specific constraint ✓
- Coding standard ✓
- Always enforced ✓
- → **Rules** (85% confidence)

### Action

## Advanced Features

### Hybrid Classification

Some knowledge may fit multiple categories:

### Example

- **Primary:** Skill (configuration knowledge)
- **Secondary:** Agent (validation automation)

### Recommendation

1. Create Skill for mise configuration
2. Create Agent that references the Skill
3. Link them via Agent Integration section

### Confidence Thresholds

- ≥ 90%: Direct recommendation
- 70-89%: Present top 2 options with trade-offs
- < 70%: Ask clarifying questions

### Clarifying Questions

When confidence is low:

```
🤔 Need Clarification:

Your description could fit multiple formats:
1. Skill (repeatable knowledge)
2. Command (user operation)

Questions:
- Will this be used across multiple projects?
- Should it execute automatically or require user action?
- Is it project-specific or general-purpose?

Based on your answers, I'll recommend the best format.
```

## Integration with Existing Creators

### Skill Creator Integration

### When

### Actions

1. Activate `skill-creator` skill
2. Provide analyzed context
3. Guide Progressive Disclosure structure
4. Ensure YAML frontmatter completeness

### Agent Creator Integration

### When

### Actions

1. Activate `agent-creator` skill
2. Map keywords to tool selection
3. Determine agent type (Domain Expert, Orchestrator, etc.)
4. Configure color and model settings

### Command Creator Integration

### When

### Actions

1. Activate `command-creator` skill
2. Determine design pattern (Simple, Phase-Based, Session Management)
3. Generate YAML frontmatter
4. Integrate with shared libraries

### Rules Creator Integration

### When

### Actions

1. Activate `rules-creator` skill
2. Determine rules type (Guidelines, Rules, Steering, Hookify)
3. Place in appropriate location
4. Define enforcement mechanism

## Best Practices

### For Users

✅ **DO:**

- Describe knowledge in natural language
- Mention technology/framework names
- Explain intended usage (repeatable? project-specific?)
- Provide examples of similar knowledge

❌ **DON'T:**

- Force a specific format without analysis
- Mix multiple unrelated knowledge items
- Skip the classification step
- Ignore confidence scores

### For Classification

✅ **DO:**

- Analyze keywords thoroughly
- Consider reusability and scope
- Check existing knowledge for patterns
- Present confidence scores honestly

❌ **DON'T:**

- Classify with <70% confidence without questions
- Ignore project context
- Skip reasoning explanation
- Recommend formats user explicitly rejected

## References

### Detailed Documentation

For in-depth classification logic and Agent Skills standards, see:

- `references/agent-skills-standard.md` - **Agent Skills specification deep dive**, Progressive Disclosure, cross-platform portability, scripts/ best practices
- `references/decision-logic.md` - Complete decision tree, confidence calculation, edge cases
- `references/format-comparison.md` - Detailed comparison of all four formats with pros/cons

### Templates & Examples

- `resources/decision-trees/intent-analysis.md` - Intent classification patterns
- `resources/decision-trees/format-selection.md` - Visual decision flowcharts
- `resources/templates/` - Scaffolds for each format (Agent Skills compliant)
- `resources/examples/` - Real-world classification examples

### External Resources

- Agent Skills Specification: <https://agentskills.io>
- What Are Agent Skills: <https://agentskills.io/what-are-skills>
- OpenAI Codex Skills: <https://developers.openai.com/codex/skills/>

## 🤖 Agent Integration

This skill provides knowledge classification to agents and commands:

### Orchestrator Agent

- Context: Knowledge format recommendations
- Timing: When creating documentation structure
- Use Case: Planning documentation architecture

### Error-Fixer Agent

- Context: Misclassified knowledge detection
- Timing: When reviewing documentation structure
- Use Case: Suggesting reclassification

### 自動ロード条件

- "create skill", "create agent", "create command", "create rules" mentioned
- "スキル作成", "エージェント作成", "コマンド作成", "ルール作成" mentioned
- "classify doc", "classify knowledge", "知識分類" mentioned
- User asks "どの形式で作るべき?" (which format should I use?)

## Trigger Conditions

Activate this skill when:

- User wants to create documentation but unsure of format
- Mentions "create skill/agent/command/rules"
- Asks about knowledge classification or organization
- Uses Japanese equivalents: "スキル作成", "知識分類", etc.
- Discusses documentation structure or best practices
- Needs guidance on where to place knowledge

## See Also

- skill-creator - Create new skills with Progressive Disclosure
- agent-creator - Create autonomous task agents
- command-creator - Create interactive user commands
- rules-creator - Create project rules and steering documents
- Integration Framework - TaskContext and agent/command integration patterns
