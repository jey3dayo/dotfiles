---
name: cc-sdd
description: |
  [What] Claude Code Spec-Driven Development (cc-sdd) plugin. Enables Kiro-style spec-driven development. Provides configurable directory structure and customizable workflows.
  [When] Use when: users mention "kiro", "spec-driven", "specification", "steering", kiro commands (/kiro:spec-init, /kiro:spec-design), "cc-sdd", or "スペック駆動開発". Ideal when a specification-driven approach is appropriate for new feature development. Provides workflows for project guidance (Steering), specification creation (Specification), and progress tracking.
  [Keywords] kiro, spec-driven, specification, steering, cc-sdd, スペック駆動開発
---

# Claude Code Spec-Driven Development (cc-sdd)

## Overview

cc-sdd (Claude Code Spec-Driven Development) is a plugin that enables Kiro-style spec-driven development. By defining specifications before starting development and proceeding through step-by-step approvals, it achieves a high-quality development process.

### Key Features

- Configurable directory structure: Customize paths via `.kiro-config.json`
- Standardized workflow: Ready to use immediately with default settings
- Progressive Disclosure: Detailed information loaded only when needed
- Multi-project support: Different configurations per project

## When to Use

Use this plugin in the following situations:

- When a user requests cc-sdd or spec-driven development commands
- When executing commands that start with `/kiro:`
- When a specification-driven approach is appropriate for new feature development
- When you want to establish project guidelines and technical standards
- When a consistent workflow from requirements definition through design to implementation is needed

## Configuration System

### Configuration File Resolution Order

1. Project-specific: `.kiro-config.json` in the project root
2. User-level: `~/.config/kiro/config.json` (optional)
3. Default: Built-in default configuration

### Default Configuration

```json
{
  "version": "1.0.0",
  "paths": {
    "root": ".kiro",
    "steering": "steering",
    "specs": "specs",
    "settings": "settings",
    "templates": "templates",
    "rules": "rules"
  },
  "workflow": {
    "defaultLanguage": "ja",
    "autoApproval": false
  }
}
```

### Customization Example

```json
{
  "version": "1.0.0",
  "paths": {
    "root": "docs/specs",
    "steering": "guidelines",
    "specs": "features"
  }
}
```

See `@config-loader.md` for details.

## Project Structure

### Directory Structure (Default)

```
.kiro/
├── steering/           # Project-wide guides and context
│   ├── product.md
│   ├── tech.md
│   └── structure.md
├── specs/              # Development process for individual features
│   └── [feature-name]/
│       ├── spec.json
│       ├── requirements.md
│       ├── design.md
│       └── tasks.md
└── settings/           # Configuration and templates
    ├── templates/
    └── rules/
```

### Steering vs Specification

| Item        | Steering              | Specification                   |
| ----------- | --------------------- | ------------------------------- |
| Purpose     | Project-wide guidance | Development process per feature |
| Scope       | Broad, cross-cutting  | Feature-level                   |
| Update freq | On project changes    | Per feature development         |

## Basic Workflow

cc-sdd consists of 3 phases:

### Phase 0: Steering (Optional)

Create and update project-wide guidance

- Manage core steering files
- Create custom steering

Can be skipped for new features or small additions. You can start directly from spec-init.

### Phase 1: Specification Creation

Create specifications step-by-step, obtaining approval at each stage

1. Initialization: Create the basic structure for the specification
2. Requirements definition: Generate requirements in EARS format
3. Technical design: Create design based on requirements
4. Task generation: Generate implementation tasks

### Phase 2: Progress Tracking

Check progress status

- Review current progress and phase
- Evaluate quality metrics
- Check steering alignment

## Development Rules

1. Leverage configuration: Define settings appropriate for the project
2. Three-stage approval workflow: Requirements → Design → Tasks → Implementation
3. Approval required: Human review required at each phase
4. No phase skipping: Approval of previous phase is mandatory
5. Update task status: Mark tasks as complete when working on them
6. Keep Steering current: Update after significant changes

## Detailed Information

Adopts a Progressive Disclosure model. Load the following reference documents as needed:

- @workflow.md — Full workflow details and phase descriptions
- @steering-system.md — Steering system details
- @specification-system.md — Specification system details
- @commands-reference.md — Reference for all commands
- @development-rules.md — Detailed explanation of development rules
- @ears-format.md — Guide to EARS format requirements definition
- @config-loader.md — Configuration system details

## Intelligent Router

Behavior when this plugin is invoked:

### Step 1: Load Configuration

1. Check project configuration: Load `.kiro-config.json`
2. Merge with defaults: Use default values for unconfigured items
3. Path resolution: Convert relative paths to absolute paths

### Step 2: Analyze User Intent

Determine intent from user's message and route to the appropriate command:

```
"new feature" / "create spec"        → /kiro:spec-init
"requirements" / "requirements"       → /kiro:spec-requirements
"design" / "design"                   → /kiro:spec-design
"tasks" / "implementation plan"       → /kiro:spec-tasks
"progress" / "status check"           → /kiro:spec-status
```

### Step 3: Check Project State

Inspect the contents of configured directories:

1. Steering existence check: Presence of steering files
2. Existing spec check: List of spec directories and their status
3. Determine next action: Current phase and available commands

### Step 4: Execute Command and Provide Guidance

1. Pre-execution explanation: Explain which command will run and why
2. Command execution: Invoke the command with appropriate arguments
3. Post-execution guidance: Suggest next steps

## Command List

### Steering Management

- `/kiro:steering` — Manage core steering files
- `/kiro:steering-custom` — Create custom steering

### Specification Management

- `/kiro:spec-init [description]` — Initialize a new specification
- `/kiro:spec-requirements [feature]` — Generate requirements definition
- `/kiro:spec-design [feature] [-y]` — Create technical design
- `/kiro:spec-tasks [feature] [-y]` — Generate implementation tasks
- `/kiro:spec-status [feature]` — Check progress status

### Validation Tools

- `/kiro:validate-gap [feature]` — Analyze implementation gaps
- `/kiro:validate-design [feature]` — Validate design
- `/kiro:validate-impl [feature]` — Validate implementation

### Acceleration Tools

- `/kiro:spec-quick [description]` — Interactive or automatic mode

## Initial Setup

### For New Projects

1. Copy configuration file: Copy `.kiro-config.default.json` as `.kiro-config.json`
2. Create directory structure: Copy the contents of `.kiro-default/` into the project
3. Customize: Adjust settings as needed

### For Existing Projects

1. Preserve current structure: Define current paths in `.kiro-config.json`
2. Gradual migration: Migrate to new structure as needed

## Guidelines

Consider the following during development:

- Think in English, respond in the user's language: Internal reasoning in English, generated responses in the user's preferred language
- Incremental approach: Complete each phase before moving to the next
- Human review: Even when automation is possible, seek human approval for important decisions
- Documentation first: Clarify specifications before writing code
- Respect configuration: Follow project-specific settings

## Migration

Migrating from existing cc-sdd projects:

1. Review current structure: Investigate the existing `.kiro/` directory structure
2. Generate configuration file: Create a `.kiro-config.json` matching the current structure
3. Verify operation: Confirm commands work correctly
4. Restructure as needed: Gradually migrate to a better structure

See `MIGRATION.md` for details.
