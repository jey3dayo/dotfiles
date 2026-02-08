# Agent Skills Standard - Deep Dive

Comprehensive guide to the Agent Skills specification and how to create cross-platform, executable agent capability extensions.

## What Are Agent Skills?

**Agent Skills** are a lightweight, open format for extending AI agent capabilities with specialized knowledge and workflows. They represent a paradigm shift from static documentation to executable, discoverable knowledge packages.

**Official Specification:** <https://agentskills.io>

### Core Philosophy

> "Agents are increasingly capable but often lack the contextual information needed for reliable real-world work."

Agent Skills solve this by providing:

- **Procedural knowledge** that agents can discover and apply
- **Organizational context** specific to tools, frameworks, or domains
- **Executable workflows** via bundled scripts
- **Cross-platform portability** across multiple AI products

## Architecture & Components

### Directory Structure (Standard)

```
skill-name/
├── SKILL.md         # Required: YAML frontmatter + instructions
├── scripts/         # Optional: Executable automation
│   ├── setup.sh
│   ├── validate.py
│   └── generate.js
├── references/      # Optional: Detailed documentation
│   ├── index.md
│   └── details.md
└── assets/          # Optional: Templates, configs
    ├── templates/
    └── examples/
```

### SKILL.md (Required)

The heart of every skill. Must contain:

### 1. YAML Frontmatter (Required Fields):

```yaml
---
name: skill-identifier # Short, kebab-case identifier
description: | # How/when to use this skill
  [What] Brief capability description
  [When] Trigger conditions
  [Keywords] Comma-separated keywords for discovery
---
```

### 2. Markdown Body (Instructions):

- Procedural guidance for agents
- Best practices and patterns
- References to bundled resources
- Integration points with other skills

### Example SKILL.md:

```markdown
---
name: typescript-linter
description: |
  [What] TypeScript linting and type-checking automation
  [When] Use when working with TypeScript projects
  [Keywords] typescript, lint, type-check, tsc, eslint
---

# TypeScript Linter Skill

## Overview

Automates TypeScript linting and type-checking with configurable rules.

## Usage

### Quick Lint

Run the validation script:

\`\`\`bash
./scripts/lint.sh
\`\`\`

### Type Checking

\`\`\`bash
./scripts/type-check.sh
\`\`\`

## Configuration

See `references/config-guide.md` for ESLint and tsconfig setup.

## Templates

- `assets/templates/tsconfig.strict.json` - Strict mode config
- `assets/templates/eslintrc.recommended.json` - Recommended rules
```

### scripts/ (Optional but Recommended)

Executable workflows that agents can run. This is what makes skills **actionable**, not just informational.

### Best Practices:

```
scripts/
├── setup.sh           # Environment setup
├── validate.py        # Validation logic
├── generate.ts        # Code generation
├── test.sh            # Testing workflows
└── cleanup.sh         # Cleanup procedures
```

### Guidelines:

- **Shebang required**: `#!/usr/bin/env bash`, `#!/usr/bin/env python3`
- **Executable permissions**: `chmod +x scripts/*`
- **Cross-platform**: Use portable shell syntax or language-specific scripts
- **Error handling**: Exit codes (0 = success, non-zero = failure)
- **Documentation**: Comment scripts thoroughly

### Example `scripts/validate.sh`:

```bash
#!/usr/bin/env bash
# Validate TypeScript project configuration

set -euo pipefail

echo "🔍 Validating TypeScript configuration..."

# Check tsconfig.json exists
if [[ ! -f "tsconfig.json" ]]; then
    echo "❌ tsconfig.json not found"
    exit 1
fi

# Run type checking
if ! npx tsc --noEmit; then
    echo "❌ Type checking failed"
    exit 1
fi

echo "✅ TypeScript configuration valid"
exit 0
```

### references/ (Optional)

Detailed documentation loaded on-demand. Keeps SKILL.md concise while providing depth when needed.

### Structure:

```
references/
├── index.md           # Reference overview
├── api-docs.md        # API documentation
├── examples.md        # Usage examples
├── troubleshooting.md # Common issues
└── advanced.md        # Advanced topics
```

### Progressive Disclosure Pattern:

- **SKILL.md**: Overview + quick start (< 5KB ideal)
- **references/**: Detailed guides (loaded only when needed)

### assets/ (Optional)

Templates, configuration files, and resources.

### Structure:

```
assets/
├── templates/
│   ├── config.template.json
│   └── workflow.template.yaml
├── examples/
│   └── sample-project/
└── schemas/
    └── config.schema.json
```

## Progressive Disclosure: The 3-Phase Model

Agent Skills are designed for **efficient context management** through progressive disclosure.

### Phase 1: Discovery 🔍

### What Loads:

- Skill name
- Description (from YAML frontmatter)
- Keywords

### Agent Behavior:

- Loads ALL skill names/descriptions at startup
- Builds internal index for task matching
- Minimal memory footprint (< 1KB per skill)

**Goal:** Fast initialization, broad capability awareness

### Phase 2: Activation ⚡

### Trigger Conditions:

- Task keywords match skill description
- User explicitly mentions skill
- Related skill already activated

### What Loads:

- Full SKILL.md content
- References to scripts/references/assets (not content yet)

### Agent Behavior:

- Reads instructions completely
- Understands available resources
- Plans execution strategy

**Goal:** Just-in-time context loading

### Phase 3: Execution 🚀

### What Loads:

- Specific reference files (on-demand)
- Script content (when executed)
- Asset files (as needed)

### Agent Behavior:

- Executes bundled scripts
- Loads templates for generation
- References detailed docs for complex tasks

**Goal:** Maximum efficiency, load only what's needed

### Performance Benefits

| Phase      | Skills Count | Memory per Skill | Total Load |
| ---------- | ------------ | ---------------- | ---------- |
| Discovery  | 100 skills   | 0.5 KB           | 50 KB      |
| Activation | 3-5 skills   | 5 KB             | 15-25 KB   |
| Execution  | 1-2 skills   | 10-50 KB         | 10-100 KB  |

**Result:** Handle hundreds of skills with minimal overhead.

## Cross-Platform Portability

### Supported Platforms

Agent Skills work with:

- **Claude Code** (Anthropic)
- **GitHub Copilot** (Microsoft)
- **Cursor** (Anysphere)
- **VS Code Extensions** (various)
- **OpenAI Codex**
- Custom agent implementations

### "Build Once, Deploy Everywhere"

The open format means:

1. **Single skill directory** works across platforms
2. **No vendor lock-in** - skills are portable files
3. **Community sharing** - publish to GitHub, share with teams
4. **Version control** - skills tracked in git like code

### Platform-Specific Notes

### Claude Code:

- Skills loaded from `~/.claude/skills/`
- Supports all standard components
- Progressive disclosure fully implemented

### GitHub Copilot:

- Skills in `.github/copilot/skills/`
- Focus on code generation use cases
- Limited script execution (security model)

### Cursor:

- Skills in `.cursor/skills/`
- Strong emphasis on references/ for context
- Interactive script execution prompts

**Best Practice:** Test skills on primary platform, validate portability assumptions.

## Skill Design Patterns

### Pattern 1: Information Skill (No Scripts)

**Use Case:** Knowledge reference, best practices, guidelines

```
skill-name/
├── SKILL.md         # Complete instructions
└── references/      # Detailed docs
    ├── api.md
    └── examples.md
```

**Example:** React Hooks patterns, TypeScript idioms

### Pattern 2: Automation Skill (With Scripts)

**Use Case:** Executable workflows, validation, code generation

```
skill-name/
├── SKILL.md         # Overview + usage
├── scripts/         # Automation
│   ├── validate.sh
│   └── generate.py
└── assets/          # Templates
    └── templates/
```

**Example:** Project scaffolding, linting automation, deployment workflows

### Pattern 3: Hybrid Skill (Full Stack)

**Use Case:** Complex domains requiring both knowledge and automation

```
skill-name/
├── SKILL.md         # Overview
├── scripts/         # Workflows
│   ├── setup.sh
│   └── validate.py
├── references/      # Deep docs
│   ├── architecture.md
│   └── troubleshooting.md
└── assets/          # Resources
    ├── templates/
    └── examples/
```

**Example:** Framework setup (Next.js, Django), tool ecosystems (Docker, Kubernetes)

## Best Practices

### SKILL.md Writing

✅ **DO:**

- Write clear, action-oriented instructions
- Use concrete examples
- Reference bundled resources explicitly
- Include error handling guidance
- Optimize for agent parsing (clear structure)

❌ **DON'T:**

- Make SKILL.md > 10KB (use references/)
- Assume prior context (agents may load skill cold)
- Use vague language ("maybe", "probably")
- Embed large code blocks (use assets/)

### scripts/ Best Practices

✅ **DO:**

- Include shebang (`#!/usr/bin/env bash`)
- Set executable permissions
- Use portable syntax (POSIX shell, Python 3+)
- Provide clear error messages
- Exit with appropriate codes

❌ **DON'T:**

- Hardcode paths or assumptions
- Require interactive input (agents can't provide)
- Use platform-specific tools without fallbacks
- Skip error handling

### Progressive Disclosure Strategy

✅ **DO:**

- Keep SKILL.md focused and scannable
- Move details to references/
- Use clear section headers
- Link to references explicitly

❌ **DON'T:**

- Dump everything in SKILL.md
- Create circular references
- Over-nest documentation
- Hide critical info in references/

### Cross-Platform Considerations

✅ **DO:**

- Test on multiple platforms if possible
- Document platform-specific behaviors
- Use standard tools (bash, python, node)
- Provide fallbacks for platform differences

❌ **DON'T:**

- Rely on platform-specific features
- Assume certain tools installed
- Hard-code file paths
- Use proprietary formats

## Validation Checklist

Use this checklist to ensure Agent Skills compliance:

### Structure

- [ ] SKILL.md exists with YAML frontmatter
- [ ] `name` field is kebab-case identifier
- [ ] `description` includes [What], [When], [Keywords]
- [ ] scripts/ have shebang and executable permissions
- [ ] Directory structure follows standard

### Content

- [ ] Instructions are clear and actionable
- [ ] Examples are concrete and tested
- [ ] References are correctly linked
- [ ] Error scenarios documented

### Progressive Disclosure

- [ ] SKILL.md < 10KB (ideally < 5KB)
- [ ] Details moved to references/
- [ ] Clear distinction between overview and deep-dive

### Cross-Platform

- [ ] Scripts use portable syntax
- [ ] No hardcoded paths
- [ ] Platform differences documented
- [ ] Tested on at least one platform

### Documentation

- [ ] README or SKILL.md explains purpose
- [ ] Usage examples provided
- [ ] Prerequisites listed
- [ ] Troubleshooting guidance included

## Migration Guide

### From Static Documentation

### Before (Markdown Doc):

```markdown
# TypeScript Guide

TypeScript is a typed superset of JavaScript.

## Setup

Install TypeScript: `npm install -g typescript`

## Usage

Run: `tsc file.ts`

## Best Practices

Use strict mode, avoid `any`, etc.
```

### After (Agent Skill):

```
typescript-guide/
├── SKILL.md
├── scripts/
│   ├── setup.sh           # Automates npm install
│   └── validate.ts        # Checks tsconfig
└── references/
    ├── best-practices.md  # Detailed guide
    └── troubleshooting.md # Common issues
```

### Benefits:

- Agents can execute setup automatically
- Progressive disclosure keeps context efficient
- Validation can run before compilation

### From Tool-Specific Docs to Skills

**Before:** Separate docs for each tool (README.md, CONTRIBUTING.md, etc.)

**After:** Unified skills that agents discover dynamically

### Migration Steps:

1. Identify repeatable knowledge domains
2. Create skill directory structure
3. Extract procedures into scripts/
4. Move detailed guides to references/
5. Write concise SKILL.md with overview
6. Add YAML frontmatter with keywords
7. Test with agent platform

## Examples from the Wild

### Example 1: mise Tool Management Skill

```
mise/
├── SKILL.md                      # Tool management overview
├── scripts/
│   ├── migrate-npm-packages.sh  # Automates migration
│   └── validate-config.sh       # Validates mise.toml
├── references/
│   ├── tool-management.md       # Detailed guide
│   └── troubleshooting.md       # Common issues
└── assets/
    └── templates/
        └── mise-config.toml     # Template config
```

### Key Features:

- Executable migration script
- Validation automation
- Detailed reference guides
- Template for quick start

### Example 2: React Testing Skill

```
react-testing/
├── SKILL.md                 # Testing overview
├── scripts/
│   ├── setup-vitest.sh     # Setup Vitest
│   └── generate-test.ts    # Test file generator
├── references/
│   ├── testing-patterns.md # Best practices
│   └── mocking-guide.md    # Mocking strategies
└── assets/
    └── templates/
        └── component.test.tsx.template
```

### Key Features:

- Automated test setup
- Template-based generation
- Pattern documentation
- Mocking examples

## Resources

### Official Specifications

- **Agent Skills**: <https://agentskills.io>
- **What Are Skills**: <https://agentskills.io/what-are-skills>
- **Skill Structure**: <https://agentskills.io/skill-structure>

### Platform Documentation

- **Claude Code Skills**: Claude Code documentation
- **OpenAI Codex Skills**: <https://developers.openai.com/codex/skills/>
- **GitHub Copilot Extensions**: GitHub documentation

### Community

- **Agent Skills GitHub**: <https://github.com/agentskills> (if available)
- **Examples Repository**: Community-contributed skills
- **Discussion Forum**: Platform-specific communities

## FAQ

### Q: Do all skills need scripts/?

**A:** No. Information-only skills (patterns, best practices) don't require scripts. Use them when automation adds value.

### Q: How do I handle secrets in skills?

**A:** Never commit secrets. Use environment variables or prompt for input. Document required env vars in SKILL.md.

### Q: Can skills depend on other skills?

**A:** Yes, but document dependencies clearly. Agents may need to activate multiple skills.

### Q: How do I version skills?

**A:** Use git tags or semantic versioning in directory names (e.g., `skill-v1.0.0/`). Document breaking changes.

### Q: Are skills language-specific?

**A:** No, but some platforms have language preferences. Python/bash/node are most portable.

### Q: How do I test skills?

**A:** Test on your primary agent platform. Validate scripts manually. Check cross-platform compatibility if targeting multiple agents.

## Conclusion

Agent Skills represent a **paradigm shift** in how we package knowledge for AI agents:

- **From static docs → executable capabilities**
- **From single-platform → cross-platform portability**
- **From monolithic → progressive disclosure**
- **From informational → actionable**

By following this standard, you create knowledge packages that agents can discover, understand, and execute reliably across multiple platforms.

### Build once, deploy everywhere. Extend agent capabilities, not just documentation.
