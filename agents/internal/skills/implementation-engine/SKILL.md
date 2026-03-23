---
name: implementation-engine
description: Smart feature implementation with session persistence and project architecture adaptation. Use when implementing features from URLs/files/descriptions, resuming work, or verifying implementations.
argument-hint: [source|resume|finish|verify]
disable-model-invocation: true
user-invocable: true
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, WebFetch
---

# Implementation Engine

A smart feature implementation engine. Fully adapts to project architecture and freely manages interruption and resumption with session persistence.

## Overview

The Implementation Engine implements features from any source (URLs, local files, descriptions) and automatically adapts to the project's code conventions and architecture patterns. With session management, work can be resumed precisely even after interruption.

## Session Intelligence

### How Session Management Works

Session files are stored in the `implement/` folder of the **current project directory** (not the HOME directory or parent directories).

```
<project-root>/
└── implement/
    ├── plan.md          # Implementation plan and progress
    └── state.json       # Session state and checkpoints
```

### Automatic Resume

- When `/implement` is executed, if the `implement/` directory exists, it automatically resumes from where it left off
- For new implementations, automatically creates the directory and files

### Session Operation Commands

```bash
/implement                  # Auto-detect and resume or start new
/implement resume           # Explicitly resume
/implement status           # Check progress
/implement new [source]     # Start new session (ignore existing)
```

## 6-Phase Execution Framework

The Implementation Engine follows these 6 phases in order:

### Phase 1: Initial Setup & Analysis

### Required Initial Steps

1. Check for `implement/` directory (within current working directory)
2. Detect session files (`state.json`, `plan.md`)
3. Resume if session exists, create new if not
4. Conduct complete analysis before starting implementation

### Source Detection

- Web URLs (GitHub, GitLab, CodePen, JSFiddle, documentation sites)
- Local paths (files, folders, existing code)
- Implementation plans (.md files with checklists)
- Feature descriptions (for research)

### Project Understanding

- Architecture patterns (analyzed with Glob/Read)
- Existing dependencies and versions
- Code conventions and established patterns
- Testing methods and quality standards

### Phase 2: Strategic Planning

### Plan Creation

- Map source features to project architecture
- Identify dependency compatibility
- Design integration approach
- Break down into testable units

### `implement/plan.md` Format

```markdown
# Implementation Plan - [timestamp]

## Source Analysis

- **Source Type**: [URL/Local/Description]
- **Core Features**: [Features to implement]
- **Dependencies**: [Required libraries/frameworks]
- **Complexity**: [Estimated effort]

## Target Integration

- **Integration Points**: [Connection points]
- **Affected Files**: [Files to change/create]
- **Pattern Matching**: [How to adapt to project style]

## Implementation Tasks

[Prioritized checklist]

## Validation Checklist

- [ ] All features implemented
- [ ] Tests written and passing
- [ ] No broken functionality
- [ ] Documentation updated
- [ ] Integration points verified
- [ ] Performance acceptable

## Risk Mitigation

- **Potential Issues**: [Identified risks]
- **Rollback Strategy**: [git checkpoints]
```

### Phase 3: Intelligent Adaptation

### Dependency Resolution

- Map source libraries to existing ones
- Reuse existing utilities to avoid duplication
- Transform patterns to match the codebase
- Update deprecated approaches to modern standards

### Code Transformation

- Unify naming conventions
- Follow error handling patterns
- Maintain state management approach
- Preserve testing style

### Large Repository Support

Uses smart sampling:

- Prioritize core functionality (main features, critical paths)
- Fetch supporting code as needed
- Skip generated files, test data, documentation
- Focus on implementation code

### Phase 4: Implementation Execution

### Execution Process

1. Implement core functionality
2. Add supporting utilities
3. Integrate with existing code
4. Update tests to cover new features
5. Verify that everything works correctly

### Progress Tracking

- Update `implement/plan.md` when each item is completed
- Record checkpoints in `implement/state.json`
- Create meaningful git commits at logical points

### Phase 5: Quality Assurance

### Verification Steps

- Run existing lint commands
- Run the test suite
- Check for type errors
- Verify integration points
- Confirm no regressions

### Phase 6: Implementation Validation

### Integration Analysis

1. Coverage Check - Verify all planned features are implemented
2. Integration Points - Verify all connections are working
3. Test Coverage - Confirm new code is tested
4. TODO Scan - Discover remaining TODOs
5. Documentation - Confirm documentation reflects changes

### Validation Report Format

```
IMPLEMENTATION VALIDATION
├── Features Implemented: 12/12 (100%)
├── Integration Points: 8/10 (2 pending)
├── Test Coverage: 87%
├── Build Status: Passing
└── Documentation: Needs update

PENDING ITEMS:
- [List of incomplete items]

ENHANCEMENT OPPORTUNITIES:
1. [List of improvement opportunities]
```

## Deep Validation Process

### All validation commands (`finish`, `verify`, `complete`, `enhance`) execute the same comprehensive process

When any of these commands is executed, the following are automatically run:

1. Deep Original Source Analysis - Thoroughly analyze every aspect of the original code/requirements
2. Requirements Verification - Compare current implementation with original requirements
3. Comprehensive Testing - Create tests for all new code
4. Deep Code Analysis - Check for incomplete TODOs, hardcoded values, error handling
5. Automatic Refinement - Fix failing tests, complete partial implementations
6. Integration Analysis - Thorough analysis of integration points
7. Completeness Report - Report on feature coverage, test coverage, performance benchmarks

### Results

## Execution Guarantee

### The workflow always follows this order

1. Setup session - Create/load state files first
2. Analyze source & target - Complete understanding
3. Write plan - Write complete implementation plan in `implement/plan.md`
4. Show plan - Present plan overview before implementation
5. Execute systematically - Execute while updating according to plan
6. Validate integration - Run validation when requested

### Never do the following

- Start implementation without a written plan
- Skip source or project analysis
- Bypass session file creation
- Start coding before showing the plan
- Use emoji in commits, PRs, or git-related content

## Usage Examples

### Single Source

```bash
/implement https://github.com/user/feature
/implement ./legacy-code/auth-system/
/implement "Payment processing like Stripe"
```

### Multiple Sources

```bash
/implement https://github.com/projectA ./local-examples/
```

### Resuming Session

```bash
/implement              # Auto-detect and resume
/implement resume       # Explicitly resume
/implement status       # Check progress
```

### Deep Validation Commands

```bash
/implement finish       # Complete with thorough testing and validation
/implement verify       # Deep validation against requirements
/implement complete     # Ensure 100% feature completeness
/implement enhance      # Refine and optimize implementation
```

## Detailed Reference

For more detailed information, refer to the following reference files:

- Phase-by-Phase Guide (`references/phase-by-phase-guide.md`) - Detailed procedures for each of the 6 phases
- Session Management (`references/session-management.md`) - Detailed plan.md/state.json management
- Deep Validation Process (`references/deep-validation-process.md`) - Deep Validation 7 steps
- Adaptation Patterns (`references/adaptation-patterns.md`) - Dependency resolution and code transformation patterns
- Source Detection (`references/source-detection.md`) - Web/Local/description determination logic
- Implementation Workflows (`examples/implementation-workflows.md`) - Implementation workflow examples
- Risk Mitigation (`examples/risk-mitigation.md`) - Rollback strategies and git checkpoints

## Dependencies

- project-detector - Automatic detection of project structure (reference only, light dependency)

## Trigger Keywords

- implementation, implement, 実装
- feature development, 機能開発
- code migration, コード移行
- adapt code, コード適応
- resume implementation, 実装再開
- validate implementation, 実装検証
