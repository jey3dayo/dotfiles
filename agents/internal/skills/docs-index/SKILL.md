---
name: docs-index
description: |
  [What] Documentation navigation hub for Claude Code. Provides quick access to all skills, commands, agents, and guides with bilingual support (Japanese/English).
  [When] Use when: searching for documentation, finding specific skills/commands/agents, understanding system capabilities, navigating Claude Code ecosystem, or looking for implementation guides.
  [Keywords] documentation, docs, navigation, index, skills, commands, agents, guides, reference, search, ドキュメント, ナビゲーション, 検索
disable-model-invocation: false
user-invocable: true
---

# Documentation Index - Claude Code Navigation Hub

Provides quick access to documentation, skills, commands, and agents across the Claude Code environment.

## Overview

The `docs-index` skill is the documentation navigation hub for the entire Claude Code environment. Its Progressive Disclosure design allows you to quickly access the information you need.

### When to Use

This skill is activated in the following situations:

- Searching for documentation or guides
- Looking for a specific skill, command, or agent
- Understanding the features and capabilities of Claude Code
- Referencing implementation patterns or best practices
- Understanding the overall structure of the system

### Trigger Keywords

### Japanese

### English

## Quick Reference

### Main Categories

| Category | Description                            | Detailed Documentation      |
| -------- | -------------------------------------- | --------------------------- |
| Skills   | Reusable knowledge and workflows       | `indexes/skills-index.md`   |
| Commands | ⚠️ Deprecated: Migrating to Skills     | `indexes/commands-index.md` |
| Agents   | Task automation and workflow execution | `indexes/agents-index.md`   |
| Guides   | Quick-start guides and navigation tips | `guides/`                   |

### Frequently Used Documentation

1. Quick Start Guide (`guides/quick-start.md`)
   - Claude Code basic operations
   - Top 10 frequently used commands
   - How to use the skill system

2. Integration Framework (skill: `integration-framework`)
   - TaskContext standardization
   - Communication Bus patterns
   - Agent/command integration

3. Code Review (skill: `code-review`)
   - 5-star rating system
   - Automatic project detection
   - Technical skill integration

4. Spec-Driven Development (skill: `cc-sdd`)
   - Kiro-style spec-driven development
   - `/kiro:` command family
   - Steering + specification management

## Tips for Finding Documentation

### Search by Category

### Finding Skills

- Technology-specific: `typescript`, `react`, `golang`, `zsh`, `nvim`
- Documentation-related: `slide-docs`, `docs-manager`, `documentation-management`
- Development tools: `mise`, `dotenvx`, `similarity`, `tsr`
- Security: `security`, `dotfiles-integration`

### Finding Commands

- Code quality: `/polish`, `/review`, `/fix-todos`
- Task management: `/task`, `/todos`, `/create-todos`
- Git operations: `/commit`, `/create-pr`
- Spec-Driven: `/kiro:spec-init`, `/kiro:spec-design`, `/kiro:spec-impl`

### Finding Agents

- Code review: `code-reviewer`, `github-pr-reviewer`
- Error fixing: `error-fixer`
- Documentation: `docs-manager`
- Orchestration: `orchestrator`

### Keyword Mapping (Japanese to English)

| Japanese           | English               | Category      |
| ------------------ | --------------------- | ------------- |
| コードレビュー     | code review           | Skill/Command |
| タスク管理         | task management       | Command       |
| 統合フレームワーク | integration framework | Skill         |
| 品質保証           | quality assurance     | Command/Skill |
| ドキュメント       | documentation         | Skill/Command |
| エージェント選択   | agent selection       | Skill         |
| スペック駆動       | spec-driven           | Skill/Command |

## Frequently Asked Questions (FAQ)

### Q1: What is the difference between skills, commands, and agents?

- Skill: Reusable knowledge and workflows. Loaded on demand with Progressive Disclosure design.
- Command: Interactive operations that the user executes manually (e.g., `/review`, `/polish`).
- Agent: Automatic execution of complex tasks. Works in conjunction with other agents and skills.

### Q2: I want to create a new skill/command

1. Create a skill: Use the `knowledge-creator` skill
2. Create a command: Use the `command-creator` skill
3. Create an agent: Use the `agent-creator` skill

### Q3: I want to add a marketplace skill

```bash
/plugin marketplace add ~/src/github.com/jey3dayo/claude-code-marketplace
```

See the `claude-marketplace-sync` skill for details.

### Q4: Cannot find documentation

1. Check the skill list in `indexes/skills-index.md`
2. Check the command list in `indexes/commands-index.md`
3. Troubleshooting: `~/.config/.claude/rules/troubleshooting.md`

### Q5: Skill is not loading

### Nix Home Manager Environment

- Check the current generation with `home-manager generations`
- Re-apply with `home-manager switch --flake ~/.agents --impure`

## Progressive Disclosure

This skill progressively discloses information:

1. Initial load (this file): Overview and quick reference (~6KB)
2. When searching for details: Various indexes in `indexes/` (~20KB)
3. When referencing guides: Detailed guides in `guides/` (~15KB)

## References

- Global Instructions: `~/.claude/CLAUDE.md`
- Project Instructions: `~/CLAUDE.md`
- Troubleshooting: `.claude/rules/troubleshooting.md`
- Migration Guide: `commands/migration-guide.md`

## Changelog

- 2025-02-12: Initial creation. Indexed 40+ skills and 45+ commands.
