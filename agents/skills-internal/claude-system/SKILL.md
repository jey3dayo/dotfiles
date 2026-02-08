---
name: claude-system
description: |
  PROACTIVELY consult Claude Code for creative design, ideation, and ambiguous
  requirement exploration. Claude Code excels at: creative problem-solving,
  architectural ideation, interactive dialogue for unclear requirements, and
  fast file operations. Use when you need fresh perspectives, design brainstorming,
  or help clarifying vague user requests.
  Explicit triggers: "design ideas", "brainstorm", "explore requirements", "clarify".
version: 1.0.0
author: ~/.agents team
tags:
  - orchestration
  - design
  - ideation
  - creativity
paths:
  - references/use-cases.md
  - references/integration-patterns.md
---

# Claude System Integration

## Claude Code is your creative design partner with exceptional ideation and architectural thinking abilities.

## Context Management (CRITICAL)

**コンテキスト消費を意識してClaude Codeを使う。** 複雑なデザイン相談や対話的探索では、サブプロセス経由を推奨。

| 状況                   | 推奨方法                       |
| ---------------------- | ------------------------------ |
| 短い質問・短い回答     | 直接呼び出しOK                 |
| アーキテクチャ設計相談 | サブプロセス経由（対話的探索） |
| 要件整理・曖昧さ解消   | サブプロセス経由（深い対話）   |
| ファイル操作           | サブプロセス経由               |

```
┌──────────────────────────────────────────────────────────┐
│  Codex / Gemini                                          │
│  → 短い質問なら直接呼び出しOK                             │
│  → 対話的探索が必要ならサブプロセス経由                    │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │  Subprocess (background)                            │ │
│  │  → Calls Claude Code                                │ │
│  │  → Interactive design exploration                   │ │
│  │  → Saves design artifacts to .claude/docs/design/   │ │
│  │  → Returns design decisions and key insights        │ │
│  └────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────┘
```

## About Claude Code

Claude Code excels at:

- **Creative problem-solving** — Novel solutions and fresh perspectives
- **Architectural ideation** — System design and component structure brainstorming
- **Interactive dialogue** — Clarifying unclear requirements through conversation
- **Fast file operations** — Read/Write/Edit operations with specialized tools

Think of Claude Code as your design partner who helps you think through complex problems creatively.

### When you need creative thinking → Use subprocess → Subprocess consults Claude Code.

## Claude vs Codex vs Gemini: Choose the Right Tool

| Task                          | Claude | Codex | Gemini |
| ----------------------------- | ------ | ----- | ------ |
| Creative design ideation      | ✓      |       |        |
| Architectural brainstorming   | ✓      |       |        |
| Clarifying vague requirements | ✓      |       |        |
| Fast file operations          | ✓      |       |        |
| Reasoning & analysis          |        | ✓     |        |
| Code implementation           |        | ✓     |        |
| Debugging                     |        | ✓     |        |
| Large codebase research       |        |       | ✓      |
| Multimodal processing         |        |       | ✓      |
| Latest docs/library research  |        |       | ✓      |

## When to Consult Claude Code

ALWAYS consult Claude Code BEFORE:

1. **Creative design & ideation** - New feature concepts, architectural patterns
2. **Ambiguous requirements** - When user's intent is unclear or underspecified
3. **Design exploration** - Exploring multiple approaches, brainstorming solutions
4. **Fast file operations** - Bulk read/write operations, rapid prototyping

### Trigger Phrases (User Input)

Consult Claude Code when user says:

| Japanese                                 | English                             |
| ---------------------------------------- | ----------------------------------- |
| 「デザインアイデアを出して」「設計して」 | "Design ideas" "Design this"        |
| 「ブレストして」「アイデア出して」       | "Brainstorm" "Generate ideas"       |
| 「要件を整理して」「明確にして」         | "Clarify requirements" "Explore"    |
| 「アーキテクチャを考えて」               | "Architect this" "Design structure" |
| 「ファイルを一括で編集」                 | "Bulk edit files"                   |

## When NOT to Consult

Skip Claude Code for:

- Deep reasoning (use Codex instead)
- Code debugging (use Codex instead)
- Research tasks (use Gemini instead)
- Multimodal processing (use Gemini instead)
- Straightforward implementation (use Codex instead)

## How to Consult (via Subprocess)

### IMPORTANT: Use subprocess to preserve main context.

### Recommended: Subprocess Pattern

Create a background subprocess that calls Claude Code:

```bash
# Design exploration pattern
(
  claude -p "Design question or task" \
    --allowedTools "Read,Write,Edit,Glob,Grep,Bash" \
    --model sonnet \
    2>/dev/null > /tmp/claude_output.txt

  # Save design artifacts
  mkdir -p .claude/docs/design/
  cp /tmp/claude_output.txt .claude/docs/design/design-exploration.md

  # Return summary
  echo "=== Design Summary ==="
  head -n 20 /tmp/claude_output.txt
) &
```

### Subprocess Patterns by Task Type

### Design Ideation Pattern:

```bash
claude -p "Generate 3-5 design alternatives for {feature}.
Include pros/cons and architectural implications." \
  --allowedTools "Read,Glob,Grep" \
  --model sonnet \
  2>/dev/null > .claude/docs/design/design-alternatives.md
```

### Requirement Clarification Pattern:

```bash
claude -p "The user requested: '{vague_request}'.
Explore possible interpretations and create clarifying questions." \
  --allowedTools "Read,Glob,Grep" \
  --model sonnet \
  2>/dev/null > .claude/docs/design/requirement-clarification.md
```

### Bulk File Operation Pattern:

```bash
claude -p "Bulk operation task: {description}
Files to process: {file_list}
Operation: {operation_details}" \
  --allowedTools "Read,Write,Edit,Glob,Grep,Bash" \
  --model sonnet \
  2>/dev/null > .claude/docs/design/bulk-operation-log.md
```

### Architectural Design Pattern:

```bash
claude -p "Design architecture for {system}.
Consider: scalability, maintainability, testability.
Output: component diagram (text), module structure, interaction patterns." \
  --allowedTools "Read,Write,Edit,Glob,Grep" \
  --model sonnet \
  2>/dev/null > .claude/docs/design/architecture.md
```

### Step 2: Monitor Progress

Check subprocess output:

```bash
# Check if still running
ps aux | grep claude

# Monitor output in real-time
tail -f .claude/docs/design/design-exploration.md
```

### Step 3: Receive Design Artifacts

Claude Code saves design artifacts to `.claude/docs/design/`. Extract key insights and report to user in Japanese.

## Claude CLI Commands Reference

For use within subprocesses:

```bash
# Creative design exploration (read-only)
claude -p "{design question}" \
  --allowedTools "Read,Glob,Grep" \
  --model sonnet \
  2>/dev/null

# Design with implementation (write enabled)
claude -p "{design and implement task}" \
  --allowedTools "Read,Write,Edit,Glob,Grep,Bash" \
  --model sonnet \
  2>/dev/null

# Fast iteration (Haiku for speed)
claude -p "{quick design question}" \
  --allowedTools "Read,Glob,Grep" \
  --model haiku \
  2>/dev/null

# Complex design (Opus for depth)
claude -p "{complex architectural design}" \
  --allowedTools "Read,Write,Edit,Glob,Grep,Bash" \
  --model opus \
  2>/dev/null

# Sandboxed environment (skip permissions)
claude -p "{task}" \
  --dangerously-skip-permissions \
  --allowedTools "Read,Write,Edit,Bash" \
  2>/dev/null
```

### Key CLI Options

| Option                           | Purpose                           |
| -------------------------------- | --------------------------------- |
| `-p, --print`                    | Non-interactive mode (required)   |
| `--allowedTools`                 | Restrict tool access              |
| `--model sonnet\|opus\|haiku`    | Model selection                   |
| `--system-prompt`                | Custom system prompt              |
| `--max-budget-usd`               | API cost limit                    |
| `--dangerously-skip-permissions` | Skip permission prompts (sandbox) |

## Language Protocol

1. Ask Claude in **English**
2. Subprocess receives response in **English** or **Japanese** (Claude respects user's CLAUDE.md)
3. Subprocess saves full output to `.claude/docs/design/`
4. Main receives summary, reports to user in **Japanese**

## Why Subprocess Pattern?

- **Context preservation**: Main orchestrator stays lightweight
- **Full capture**: Subprocess can save entire Claude output to file
- **Concise handoff**: Main only receives key insights
- **Parallel work**: Background subprocesses enable concurrent design exploration

## Task Templates

### Template 1: Design Exploration

```bash
claude -p "Design {feature/system}.
Requirements: {requirements}
Constraints: {constraints}
Output: 3-5 design alternatives with trade-off analysis." \
  --allowedTools "Read,Glob,Grep,Write" \
  --model sonnet \
  2>/dev/null > .claude/docs/design/design-exploration-$(date +%Y%m%d-%H%M%S).md
```

### Template 2: Requirement Clarification

```bash
claude -p "User request: '{user_request}'
Current codebase context: {context}
Task: Identify ambiguities and generate clarifying questions." \
  --allowedTools "Read,Glob,Grep" \
  --model sonnet \
  2>/dev/null > .claude/docs/design/requirement-clarification-$(date +%Y%m%d-%H%M%S).md
```

### Template 3: Architectural Brainstorming

```bash
claude -p "Brainstorm architectural approaches for {system}.
Current stack: {tech_stack}
Key requirements: {requirements}
Output: Component structure, interaction patterns, technology choices." \
  --allowedTools "Read,Glob,Grep,Write" \
  --model opus \
  2>/dev/null > .claude/docs/design/architecture-brainstorm-$(date +%Y%m%d-%H%M%S).md
```

### Template 4: Bulk File Operation

```bash
claude -p "Bulk edit task: {description}
Target files: {file_pattern}
Operation: {edit_description}
Safety: Preview changes before applying." \
  --allowedTools "Read,Write,Edit,Glob,Grep,Bash" \
  --model sonnet \
  2>/dev/null > .claude/docs/design/bulk-operation-$(date +%Y%m%d-%H%M%S).md
```

## Integration Best Practices

1. **Clear delegation boundaries**: Use Claude for design, Codex for reasoning, Gemini for research
2. **Structured output**: Save design artifacts to `.claude/docs/design/` for future reference
3. **Subprocess isolation**: Run Claude in background to avoid context contamination
4. **Cost awareness**: Use Haiku for quick tasks, Sonnet for standard, Opus for complex
5. **Tool restrictions**: Limit `--allowedTools` to minimum required for task

## Error Handling

If Claude CLI fails:

```bash
# Check authentication
claude --version

# Check Claude Code installation
which claude

# Verify permissions
ls -la ~/.claude/

# Test basic invocation
claude -p "test" --model sonnet 2>&1 | head
```

### Use Claude Code (via subprocess) for creative design, Codex for reasoning, Gemini for research.
