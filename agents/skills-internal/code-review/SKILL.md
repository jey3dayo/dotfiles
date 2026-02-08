---
name: code-review
description: |
  [What] Configurable code review and quality assessment skill with project detection system.
  [When] Use when: code reviews, quality assessments, or evaluation guidance is needed.
  [Keywords] code review, quality assessment, review, security, performance, architecture, guidelines
  [Note] Always responds in Japanese.
version: 2.0.0
---

# Code Review (Configurable)

## Overview

Provide comprehensive code review and quality evaluation framework with configurable project detection and evaluation rules. Automatically detect project type through configuration files and deliver contextual, actionable feedback.

## Configuration System

### Configuration Sources (Priority Order)

1. **Project-specific config** (highest priority)
   - `.code-review-config.json` in project root
   - `.claude/code-review-config.json`

2. **User config**
   - `~/.claude/code-review/custom-projects.json`

3. **Default config** (fallback)
   - Built-in project detection rules
   - Generic evaluation guidelines

### Configuration File Location

```
Project Root/
├── .code-review-config.json          # Project-specific rules
└── .claude/
    └── code-review-config.json        # Alternative location

~/.claude/
└── code-review/
    └── custom-projects.json           # User-wide custom projects
```

## Core Capabilities

### Project Detection System

Configurable detection system using multiple detector types:

**Detector Types**:

- `file_exists`: Check if a file exists at specified path
- `file_pattern`: Match files using glob patterns
- `file_content`: Check file content for patterns
- `package_dependency`: Check package.json dependencies
- `directory_structure`: Verify directory structure

**Detection Process**:

```python
def detect_project_type():
    """Detect project type using configuration"""

    # 1. Load configurations (priority order)
    configs = load_configurations([
        "./.code-review-config.json",           # Project-specific
        "./.claude/code-review-config.json",    # Project alternative
        "~/.claude/code-review/custom-projects.json",  # User custom
        "default-projects.json"                 # Built-in defaults
    ])

    # 2. Sort by priority (higher first)
    projects = sort_by_priority(configs)

    # 3. Run detectors for each project
    for project in projects:
        if all_required_detectors_pass(project["detectors"]):
            return project

    # 4. Fallback to generic project
    return get_generic_project()
```

### Built-in Project Types

Default configuration includes:

| Project Type          | Priority | Key Detectors                | Tech Stack              |
| --------------------- | -------- | ---------------------------- | ----------------------- |
| Next.js Fullstack     | 100      | next dep, package.json       | typescript, react, next |
| Go Clean Architecture | 95       | go.mod, domain/usecase/infra | go, clean-architecture  |
| Go API                | 90       | go.mod, \*\_handler.go       | go                      |
| React SPA             | 80       | react dep, package.json      | typescript, react       |
| TypeScript Node.js    | 70       | package.json, tsconfig.json  | typescript, node        |
| Generic Project       | 0        | (fallback)                   | (none)                  |

### Skill Integration

Automatically load and integrate technology-specific skills:

```python
def integrate_skills(project_info):
    """Integrate skills based on project configuration"""

    skills = []

    for skill_ref in project_info["skills"]:
        skill = load_skill(skill_ref["name"])
        skill.set_priority(skill_ref["priority"])
        skill.set_focus(skill_ref["focus"])
        skills.append(skill)

    return skills
```

**Available Skills**:

- `typescript`: Type safety, strict mode, type guards, Result pattern
- `react`: Component design, hooks, performance, a11y
- `golang`: Idiomatic Go, error handling, concurrency
- `security`: OWASP Top 10, input validation, auth, data protection
- `clean-architecture`: Layer separation, dependency rules, domain modeling
- `semantic-analysis`: Symbol-level analysis, impact assessment

### Evaluation System

**Configuration-based evaluation**:

```json
{
  "evaluation": {
    "weights": {
      "code_quality": 0.2,
      "security": 0.2,
      "performance": 0.15,
      "testing": 0.15,
      "error_handling": 0.15,
      "architecture": 0.15
    },
    "guidelines": [
      "evaluation-guidelines.md",
      "typescript/guidelines.md",
      "security/guidelines.md"
    ],
    "customRules": {
      "anyTypeLimit": 2,
      "typeAssertionLimit": 5,
      "testCoverageTarget": 80
    }
  }
}
```

**Star Rating System**:

| Rating     | Description  | Criteria                                     |
| ---------- | ------------ | -------------------------------------------- |
| ⭐️⭐️⭐️⭐️⭐️ | Exceptional  | All dimensions excellent, custom rules met   |
| ⭐️⭐️⭐️⭐️   | Excellent    | Most dimensions strong, minor improvements   |
| ⭐️⭐️⭐️     | Good         | Acceptable quality, some improvements needed |
| ⭐️⭐️       | Needs Work   | Multiple issues, significant improvements    |
| ⭐️         | Major Issues | Critical problems, substantial rework        |

## Review Modes

### 1. Detailed Mode (Default)

Comprehensive quality assessment with structured evaluation.

**Features**:

- Project type auto-detection
- Configuration-based skill integration
- Multi-dimensional evaluation
- Star ratings with detailed comments
- Prioritized action plan

**Usage**:

```bash
/review                    # Detailed review
/review --with-impact      # With semantic analysis
```

### 2. Simple Mode

Quick practical analysis focused on immediate issues.

**Features**:

- Parallel sub-agent execution (security, performance, quality, architecture)
- Fast issue detection
- Immediate fix suggestions
- Severity prioritization

**Usage**:

```bash
/review --simple           # Quick review
/review --simple --fix     # With auto-fix
```

## Configuration Examples

### Example 1: Custom TypeScript Project

`.code-review-config.json`:

```json
{
  "name": "My TypeScript API",
  "priority": 200,
  "detectors": [
    {
      "type": "file_exists",
      "path": "package.json",
      "condition": "required"
    },
    {
      "type": "file_exists",
      "path": "tsconfig.json",
      "condition": "required"
    }
  ],
  "techStack": ["typescript", "node"],
  "skills": [
    {
      "name": "typescript",
      "priority": "high",
      "focus": ["type_safety", "strict_mode"]
    },
    {
      "name": "security",
      "priority": "high",
      "focus": ["input_validation", "auth"]
    }
  ],
  "evaluation": {
    "weights": {
      "code_quality": 0.25,
      "security": 0.25,
      "performance": 0.15,
      "testing": 0.15,
      "error_handling": 0.1,
      "architecture": 0.1
    },
    "customRules": {
      "anyTypeLimit": 0,
      "testCoverageTarget": 85
    }
  }
}
```

### Example 2: Project with Clean Architecture

```json
{
  "name": "Clean Architecture Project",
  "priority": 150,
  "detectors": [
    {
      "type": "directory_structure",
      "path": "src/domain",
      "condition": "required"
    },
    {
      "type": "directory_structure",
      "path": "src/application",
      "condition": "required"
    },
    {
      "type": "directory_structure",
      "path": "src/infrastructure",
      "condition": "required"
    }
  ],
  "skills": [
    {
      "name": "clean-architecture",
      "priority": "high",
      "focus": ["layer_separation", "dependency_rule"]
    }
  ],
  "evaluation": {
    "weights": {
      "architecture": 0.3,
      "code_quality": 0.2,
      "testing": 0.2,
      "error_handling": 0.15,
      "security": 0.1,
      "performance": 0.05
    },
    "customRules": {
      "layerSeparation": {
        "domain": {
          "allowedImports": [],
          "forbiddenImports": ["infrastructure", "application"]
        },
        "application": {
          "allowedImports": ["domain"],
          "forbiddenImports": ["infrastructure"]
        }
      }
    }
  }
}
```

## Migration from v1.x

For projects using the old hardcoded project detection:

1. **Identify current project type** (Next.js, Go API, React SPA, etc.)
2. **Copy appropriate template** from `config/examples/`
3. **Customize as needed** (weights, skills, custom rules)
4. **Place in project root** as `.code-review-config.json`

**Migration examples provided**:

- `config/examples/caad-loca-project.json` - Clean Architecture with Result<T,E>
- `config/examples/.code-review-config.json` - Generic custom project

## Best Practices

### Configuration Design

1. **Use specific detectors** for accurate project identification
2. **Set appropriate priority** to avoid conflicts
3. **Focus skills** on relevant areas for your project
4. **Customize weights** based on project priorities
5. **Define custom rules** for project-specific requirements

### Project-Specific Guidelines

Store custom evaluation guidelines in project:

```
Project Root/
├── .code-review-config.json
└── docs/
    └── review-guidelines.md    # Reference in config
```

Reference in configuration:

```json
{
  "evaluation": {
    "guidelines": ["evaluation-guidelines.md", "docs/review-guidelines.md"]
  }
}
```

## Schema Reference

Full schema available at: `schemas/project-detection-schema.json`

**Key properties**:

- `name`: Project type identifier
- `description`: Human-readable description
- `priority`: Detection priority (higher = checked first)
- `detectors`: Array of detection rules
- `techStack`: Technology identifiers
- `skills`: Skills to integrate with priorities
- `evaluation`: Weights, guidelines, custom rules

## Related Files

- `config/default-projects.json` - Built-in project types
- `config/examples/` - Example configurations
- `schemas/project-detection-schema.json` - Configuration schema

## Notes

- Always responds in Japanese
- Configuration files use JSON format
- Priority system ensures correct project detection
- Custom rules support arbitrary project requirements
- Backward compatible with v1.x through migration

---

**Goal**: Provide flexible, configurable code reviews that adapt to any project structure while maintaining consistent quality standards.
