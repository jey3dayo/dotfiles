# Default Bundle Analysis

## Overview

The `distributions/default/` bundle is the reference implementation created on 2025-02-11. It demonstrates the full capabilities of the distributions system.

---

## Structure

```
distributions/default/
├── skills/           (42 skills)
├── commands/         (42 commands, some with subcommands)
├── rules/            (1 rule file)
├── agents/           (15 agent files, including kiro/ subdirectory)
├── config/           (optional, not currently used)
└── README.md
```

---

## Skills Analysis

### Total Skills: 42

#### Mixed Sources

### From skills-internal/ (35 skills)

- agent-creator
- chrome-debug
- claude-system
- code-quality-improvement
- code-review
- codex-system
- command-creator
- composition-patterns
- debug-chrome
- doc-standards
- docs-manager
- dotfiles-integration
- generate-svg
- gemini-system
- gh-address-comments
- gh-fix-ci
- gh-fix-review
- integration-framework
- keybindings-help
- markdown-docs
- marketplace-builder
- mcp-tools
- nix-dotfiles
- polish
- rules-creator
- skill-creator
- sync-origin
- task
- task-to-pr
- tsr
- ui-ux-pro-max
- web-design-guidelines
- wezterm
- agent-browser (MCP integration)
- cc-sdd (Kiro spec-driven development)

### From skills/ (7 skills)

External skills (symlinked to `skills/` directory):

- document-skills:skill-creator
- document-skills:theme-factory
- document-skills:internal-comms
- document-skills:webapp-testing
- document-skills:brand-guidelines
- document-skills:algorithmic-art
- (+ more document-skills variants)

---

## Commands Analysis

### Total Commands: 42+

#### Single Commands (35)

From `commands-internal/`:

- commit
- create-pr
- create-todos
- debug-chrome
- docs
- find-todos
- fix-docs
- fix-todos
- implement
- learnings
- maintain-claude
- make-it-pretty
- migration-guide
- predict-issues
- refactoring
- review
- todos
- contributing
- skill-up
- (+ shared utilities)

#### Command Groups (7 groups)

### 1. kiro/

- spec-design
- spec-impl
- spec-init
- spec-quick
- spec-requirements
- spec-status
- spec-tasks
- steering
- steering-custom
- validate-design
- validate-gap
- validate-impl

### 2. clean/

- files
- full

### 3. shared/

- agent-selector
- claude-metadata-analyzer
- context7-integration
- error-handler
- integration-matrix
- project-detector
- refactoring-plan
- refactoring-summary
- skill-integration
- skill-mapping-engine

### 4. code-review/

- code-review

### 5. document-skills/

- algorithmic-art
- brand-guidelines
- canvas-design
- doc-coauthoring
- docx
- frontend-design
- internal-comms
- mcp-builder
- pdf
- pptx
- skill-creator
- theme-factory
- web-artifacts-builder
- webapp-testing
- xlsx

### 6. frontend-design/

- frontend-design

---

## Rules Analysis

### Total Rules: 1

From `~/.claude/rules/`:

- claude-md-design.md

### Purpose

Rules are markdown files containing instructions and guidelines for Claude Code. They define:

- Design principles for CLAUDE.md
- Separation of responsibilities
- Documentation structure guidelines

---

## Agents Analysis

### Total Agents: 15 (14 individual + 1 subdirectory)

#### Individual Agents (14)

From `~/.claude/agents/`:

- aws-operations
- code-reviewer
- debug-operations
- deep-explore
- deployment
- docs-manager
- error-fixer
- github-pr-reviewer
- monitoring-alerts
- orchestrator
- quality-validation
- researcher
- serena
- terraform-operations

#### Agent Group: kiro/ (9 sub-agents)

- spec-design
- spec-impl
- spec-requirements
- spec-tasks
- steering
- steering-custom
- validate-design
- validate-gap
- validate-impl

### Purpose

Agents are specialized task handlers that:

- Automate complex workflows
- Provide domain-specific expertise
- Integrate with external tools and services

---

## Symlink Patterns

### Pattern 1: Direct Skill Link

```bash
distributions/default/skills/react -> ../../../skills-internal/react
```

### Count

---

### Pattern 2: External Skill Link

```bash
distributions/default/skills/document-skills:skill-creator -> ../../../skills/document-skills:skill-creator
```

### Count

---

### Pattern 3: Command Group Link

```bash
distributions/default/commands/kiro -> ../../../commands-internal/kiro
```

### Count: 7 command groups

---

### Pattern 4: Rules Link

```bash
distributions/default/rules/claude-md-design.md -> ~/.claude/rules/claude-md-design.md
```

### Count: 1 rule

---

### Pattern 5: Agent Link

```bash
distributions/default/agents/code-reviewer.md -> ~/.claude/agents/code-reviewer.md
```

### Count: 14 individual agents

---

### Pattern 6: Agent Group Link

```bash
distributions/default/agents/kiro -> ~/.claude/agents/kiro
```

### Count: 1 agent group (9 sub-agents)

---

## Verification

### Structure Validation

```bash
# Count skills
ls -1 distributions/default/skills/ | wc -l
# Output: 42

# Count command directories
ls -1 distributions/default/commands/ | wc -l
# Output: 42 (includes command groups)

# Count rules
ls -1 distributions/default/rules/ | wc -l
# Output: 1

# Count agents (individual files)
ls -1 distributions/default/agents/*.md | wc -l
# Output: 14

# Count agent directories
ls -d distributions/default/agents/*/ | wc -l
# Output: 1 (kiro/)

# Count total command.ts files
find distributions/default/commands/ -name "command.ts" | wc -l
# Output: 84+ (includes subcommands)
```

### Symlink Validation

```bash
# Check for broken symlinks
find distributions/default/ -type l -exec test ! -e {} \; -print
# Output: (empty if all valid)

# Verify SKILL.md presence
find distributions/default/skills/ -type l -exec sh -c '
  target=$(readlink -f "$1")
  test -f "$target/SKILL.md" || echo "Missing: $1"
' _ {} \;
# Output: (empty if all valid)
```

### Deployment Validation

```bash
# Deploy
home-manager switch --flake ~/.config --impure

# Verify deployed skills
ls -1 ~/.claude/skills/ | wc -l
# Output: Should match or exceed 42 (includes local overrides)

# Check source attribution
mise run skills:list 2>/dev/null | jq '[.skills[] | .source] | group_by(.) | map({(.[0]): length})'
# Output: {"local": N, "external": M, "distribution": P}
```

---

## Priority Examples

### Example 1: Skill in All Sources

```
skills-internal/react/        (Local)
skills/react/                 (External)
distributions/default/skills/react/ (Distribution)
```

### Deployed

---

### Example 2: Skill in Distribution Only

```
distributions/default/skills/custom-skill/
```

### Deployed

---

## Best Practices Demonstrated

1. **Mixed sources**: Combines skills-internal/ and skills/
2. **Command groups**: Uses subdirectories for related commands (kiro/, clean/)
3. **Utility separation**: Shared utilities in `shared/` command group
4. **External integration**: Includes document-skills from external sources
5. **Namespace conventions**: Uses `:` for external skills (e.g., `document-skills:skill-creator`)

---

## Maintenance Notes

### Adding Skills

```bash
cd distributions/default/skills
ln -s ../../../skills-internal/new-skill ./
home-manager switch --flake ~/.config --impure
```

### Removing Skills

```bash
cd distributions/default/skills
rm old-skill
home-manager switch --flake ~/.config --impure
```

### Updating README

After changes, update `distributions/default/README.md` with new counts and descriptions.

---

## Token Budget

| Component      | Estimated Tokens    |
| -------------- | ------------------- |
| Skills (42)    | ~12,600 (300/skill) |
| Commands (84+) | ~16,800 (200/cmd)   |
| Rules (1)      | ~200 (200/rule)     |
| Agents (23)    | ~4,600 (200/agent)  |
| Config         | 0 (not used)        |
| **Total**      | ~34,200             |

### Note

---

## Related Files

- **distributions/default/README.md**: Official bundle documentation
- **agents/nix/lib.nix**: Implementation (`scanDistribution`)
- **references/creating-bundles.md**: How to create similar bundles
- **references/symlink-patterns.md**: Symlink design patterns used
