---
name: documentation-management
description: Intelligent project documentation manager with AI-driven content generation and link validation. Use when creating/updating documentation or fixing documentation issues.
disable-model-invocation: true
user-invocable: true
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
argument-hint: "[create|update|fix] [target]"
---

# Documentation Management

AI-driven intelligent documentation management system. Analyzes project structure and automatically generates and updates appropriate documentation.

## Overview

This skill understands the actual state of a project and comprehensively manages all related documentation.

### Core Features

- AI-driven project analysis: Analyzes the entire codebase and identifies what needs to be documented
- Progressive Disclosure strategy: Delivers information to readers in stages as needed
- Structured document generation: Creates documentation with a consistent structure
- Smart updates: Understands changes and updates all affected documentation
- Link validation: Checks link integrity within documents (integration planned)

## Basic Usage

### Mode 1: Documentation Overview Analysis

```bash
/documentation
```

Analyzes all documentation in the project and reports coverage.

### Example Output

```
DOCUMENTATION OVERVIEW
├── README.md - [status: current]
├── CHANGELOG.md - [last updated: 2024-01-15]
├── docs/
│   ├── API.md - [outdated: 3 new endpoints]
│   └── architecture.md - [incomplete: 65%]
└── Total coverage: 78%

KEY FINDINGS
- Missing: Setup instructions
- Outdated: API endpoints (3 new ones)
- Incomplete: Testing guide
```

### Mode 2: Smart Update

```bash
/documentation update
```

Compares the actual state of the codebase against the documentation and performs necessary updates.

### What It Does

1. Analyzes project structure (using project-detector)
2. Understands the actual state of the codebase (using MCP Serena)
3. Identifies gaps between documentation and reality
4. Systematically updates:
   - README.md: New features and changes
   - CHANGELOG.md: Version entries
   - API docs: New endpoints
   - Configuration docs: New options
   - Migration guides: When breaking changes exist

### Mode 3: Session Documentation

```bash
/documentation session
```

After a long coding session, analyzes the conversation history and updates documentation.

### What It Does

- Extracts changes from conversation history
- Groups by feature/fix/enhancement
- Updates appropriate documentation following the project style

### Mode 4: Automatic Context Detection

Automatically updates appropriate documentation based on session content:

| Session Content         | Documents Updated                  |
| ----------------------- | ---------------------------------- |
| New feature added       | README features, CHANGELOG         |
| Bug fix                 | CHANGELOG, troubleshooting         |
| Refactoring             | Architecture docs, migration guide |
| Security fix            | Security policy, CHANGELOG         |
| Performance improvement | Benchmarks, CHANGELOG              |

## Documentation Strategy

### Progressive Disclosure Approach

Deliver information progressively based on the reader's level of understanding:

### Layer 1: Overview (SKILL.md)

- 10-15% of content
- Basic concepts and usage examples
- Quick start

### Layer 2: Detailed Specification (references/)

- 40-50% of content
- Technical details and implementation guides
- API specifications and architecture

### Layer 3: Practical Examples (examples/)

- 30-40% of content
- Project-specific examples
- Workflow patterns

Details: [references/documentation-strategy.md](references/documentation-strategy.md)

### Structured Approach

```
project/
├── README.md              # Project overview (entry point for Progressive Disclosure)
├── CHANGELOG.md           # Change history
├── CONTRIBUTING.md        # Contribution guide
└── docs/
    ├── getting-started.md  # For beginners
    ├── api/               # API details
    ├── guides/            # Tutorials
    └── reference/         # Reference
```

## Smart Documentation Rules

### Always Do

1. Read existing documentation completely: Understand current content before updating
2. Identify the appropriate section: Find the exact location to update
3. Update in-place: Update existing sections without creating duplicates
4. Preserve custom content: Protect content manually added by the user
5. Inherit style: Follow the existing format

### Custom Content Protection

```markdown
<!-- CUSTOM:START -->

Content manually added by the user
This section is protected from automatic updates

<!-- CUSTOM:END -->
```

### CHANGELOG Management

- Group changes by type: Added, Changed, Fixed, Removed
- Suggest version bumps: Determine major/minor/patch
- Link to PRs/Issues: References to related discussions
- Maintain chronological order: Newest at the top

## Quick Start

### Creating Documentation for a New Project

```bash
# 1. Analyze project and generate documentation
/documentation create

# 2. Review generated documentation
/documentation review

# 3. Adjust as needed
/documentation update README.md
```

### Improving Documentation for an Existing Project

```bash
# 1. Analyze current state
/documentation analyze

# 2. Identify gaps
/documentation gaps

# 3. Bulk update
/documentation update --all
```

### Command Integration

Integrates seamlessly with other commands:

```bash
# Code understanding → documentation update
/understand && /documentation

# Test execution → coverage update
/test && /documentation

# Refactoring → architecture documentation update
/refactor && /documentation
```

## Dependencies

### Required

- project-detector: Project type and stack detection
- MCP Serena: Code structure analysis and symbol search

### Optional

- docs-index: Indexing large documentation sets
- markdown-docs: Documentation quality evaluation

## Documentation Types

Types of documentation that can be managed:

- API Documentation: Endpoints, parameters, responses
- Database Schema: Tables, relations, migrations
- Configuration: Environment variables, settings
- Deployment: Setup, requirements, procedures
- Troubleshooting: Common problems and solutions
- Performance: Benchmarks, optimization guides
- Security: Policies, best practices

## Detailed Reference

### Technical Specifications

- [Documentation Strategy](references/documentation-strategy.md) - Progressive Disclosure, structured approach
- [AI-Driven Analysis](references/ai-driven-analysis.md) - Project structure analysis, content generation
- [Link Validation](references/link-validation.md) - Link validation rules, auto-repair (planned)
- [Content Generation Patterns](references/content-generation-patterns.md) - Per-section generation patterns

### Practical Examples

- [Project-Specific Documentation](examples/project-specific-docs.md) - Examples by project type
- [Documentation Workflows](examples/documentation-workflows.md) - Create/update/fix workflows
- [Fix Pattern Collection](examples/fix-patterns.md) - Documentation fix patterns (planned)

## Important Notes

### Never Do

- Delete existing documentation
- Overwrite custom sections
- Make drastic changes to documentation style
- Add AI attribution markers
- Create unnecessary documentation

### Confirmation Before Execution

Confirmation is requested before performing updates:

- Update all outdated documentation
- Focus on specific files
- Create missing documentation
- Generate migration guides
- Skip specific sections

## Quality Checks

- Doc Coverage: Report undocumented features
- Freshness Check: Flag outdated documentation
- Consistency: Ensure style uniformity
- Completeness: Verify all sections exist
- Accuracy: Compare documentation against implementation

---

### Token Efficiency
