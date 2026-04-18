# Default Distribution Analysis

## Overview

`agents/src/` is the current bundled distribution root used by this repository.

It is the source of truth for:

- bundled skills
- bundled rules
- bundled agents

The current Home Manager module does not deploy bundled `agents/src/commands/`.

---

## Structure

```text
agents/src/
├── skills/   (48 directories)
├── rules/    (2 markdown files, including nested paths)
├── agents/   (23 markdown files, including nested agent files)
└── commands/ (legacy directory, not part of active HM deployment)
```

---

## Skills

### Count

- 48 bundled skill directories

### Examples

- `agent-creator`
- `codex-code-review`
- `distributions-manager`
- `nix-dotfiles`
- `task-to-pr`

### Runtime Behavior

- scanned from `agents/src/skills/`
- tagged as `source = "distribution"`
- override external skills with the same ID

---

## Rules

### Count

- 2 bundled rule files

### Examples

- `claude-md-design.md`
- `tools/...`

### Runtime Behavior

- scanned from `agents/src/rules/`
- linked directly into target rules directories

---

## Agents

### Count

- 23 markdown agent files in total, including nested agent paths

### Examples

- `code-reviewer.md`
- `deployment.md`
- `orchestrator.md`
- `kiro/spec-design.md`

### Runtime Behavior

- scanned from `agents/src/agents/`
- merged as `externalAgents // distributionAgents`
- bundled agents win on duplicate IDs

---

## Commands

### Current State

- `agents/src/commands/` still exists in the tree
- the active Home Manager module does not link bundled commands from `distributionResult.commands`
- top-level commands currently come from external `commandsPath` sources

That means `agents/src/commands/` should not be documented as an active bundled deployment layer.

---

## Verification

```bash
mise run skills:legacy:install
mise run skills:legacy:list 2>/dev/null | jq '.skills[] | {id, source}'
```

Expected observations:

- bundled skills appear as `distribution`
- external selected skills appear with their source names
- bundled agents and rules are linked from `agents/src`

---

## Notes

- Treat `agents/src/` as the canonical bundled source tree
- Do not reintroduce removed legacy layer names into active docs
- If you need bundled command support again, it requires runtime changes, not just documentation changes
