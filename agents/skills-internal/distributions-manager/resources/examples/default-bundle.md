# Default Bundle Analysis

## Overview

The `distributions/default/` bundle is the reference implementation created on 2025-02-11. It demonstrates the full capabilities of the distributions system.

---

## Structure

```
distributions/default/
├── skills/           (42 skills)
├── commands/         (42 commands, some with subcommands)
├── config/           (optional, not currently used)
└── README.md
```

---

## Skills Analysis

### Total Skills: 42

#### Mixed Sources

**From skills-internal/ (35 skills)**:

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

**From skills/ (7 skills)**:

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

**1. kiro/** (9 subcommands):

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

**2. clean/** (2 subcommands):

- files
- full

**3. shared/** (11 utilities):

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
- task-context

**4. code-review/** (1 subcommand):

- code-review

**5. document-skills/** (13 skills):

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

**6. frontend-design/** (1 subcommand):

- frontend-design

---

## Symlink Patterns

### Pattern 1: Direct Skill Link

```bash
distributions/default/skills/react -> ../../../skills-internal/react
```

**Count**: ~35 skills

---

### Pattern 2: External Skill Link

```bash
distributions/default/skills/document-skills:skill-creator -> ../../../skills/document-skills:skill-creator
```

**Count**: ~7 skills

---

### Pattern 3: Command Group Link

```bash
distributions/default/commands/kiro -> ../../../commands-internal/kiro
```

**Count**: ~7 command groups

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

**Deployed**: `skills-internal/react/` (Local wins)

---

### Example 2: Skill in Distribution Only

```
distributions/default/skills/custom-skill/
```

**Deployed**: `distributions/default/skills/custom-skill/` (No conflicts)

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
| Config         | 0 (not used)        |
| **Total**      | ~29,400             |

**Note**: Progressive disclosure ensures only relevant skills/commands are loaded per session.

---

## Related Files

- **distributions/default/README.md**: Official bundle documentation
- **agents/nix/lib.nix**: Implementation (`scanDistribution`)
- **references/creating-bundles.md**: How to create similar bundles
- **references/symlink-patterns.md**: Symlink design patterns used
