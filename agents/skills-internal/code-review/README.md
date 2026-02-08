# Code Review Plugin (v2.0)

Configurable code review and quality assessment system with flexible project detection.

## What's New in v2.0

**Configuration-Based Architecture**:

- Project detection through configuration files (no more hardcoded logic)
- Pluggable evaluation rules
- Custom project type support
- Backward compatible with v1.x

**Key Improvements**:

- Separate project-specific rules from core logic
- Easy addition of new project types
- User-customizable evaluation criteria
- JSON schema validation

## Quick Start

### 1. Install Plugin

```bash
# Add to your claude-code-marketplace
cp -r plugins/dev-tools/code-review ~/.claude/plugins/code-review
```

### 2. Use Built-in Project Types

Default project types are automatically detected:

- Next.js Fullstack
- Go API / Go Clean Architecture
- React SPA
- TypeScript Node.js
- Generic Project (fallback)

```bash
# Run review with auto-detection
/review
```

### 3. Add Custom Project Configuration

Create `.code-review-config.json` in your project root:

```json
{
  "name": "My Custom Project",
  "priority": 200,
  "detectors": [
    {
      "type": "file_exists",
      "path": "package.json",
      "condition": "required"
    }
  ],
  "techStack": ["typescript", "react"],
  "skills": [
    {
      "name": "typescript",
      "priority": "high",
      "focus": ["type_safety", "strict_mode"]
    }
  ],
  "evaluation": {
    "weights": {
      "code_quality": 0.25,
      "security": 0.2,
      "performance": 0.15,
      "testing": 0.15,
      "error_handling": 0.15,
      "architecture": 0.1
    }
  }
}
```

## Directory Structure

```
code-review/
├── SKILL.md                           # Main skill definition
├── README.md                          # This file
├── config/
│   ├── default-projects.json         # Built-in project types
│   └── examples/                      # Example configurations
│       ├── .code-review-config.json  # Generic custom project
│       └── caad-loca-project.json    # Clean Architecture example
├── schemas/
│   └── project-detection-schema.json # JSON schema
├── detectors/                         # (Reserved for future)
│   └── .gitkeep
└── evaluators/                        # (Reserved for future)
    └── .gitkeep
```

## Configuration System

### Priority-Based Detection

Configuration files are loaded in priority order:

1. **Project-specific** (priority 200+)
   - `.code-review-config.json` in project root
   - `.claude/code-review-config.json`

2. **User custom** (priority 100-199)
   - `~/.claude/code-review/custom-projects.json`

3. **Built-in defaults** (priority 0-99)
   - `config/default-projects.json`

4. **Generic fallback** (priority 0)
   - Always matches as last resort

### Detector Types

| Type                  | Description                   | Example                         |
| --------------------- | ----------------------------- | ------------------------------- |
| `file_exists`         | Check file existence          | `package.json`, `go.mod`        |
| `file_pattern`        | Glob pattern matching         | `**/*_test.go`                  |
| `file_content`        | Content pattern matching      | Check for specific imports      |
| `package_dependency`  | Check package.json dependency | `next`, `react`, `express`      |
| `directory_structure` | Verify directory exists       | `src/domain`, `infrastructure/` |

### Custom Rules

Define project-specific validation rules:

```json
{
  "evaluation": {
    "customRules": {
      "anyTypeLimit": 0,
      "typeAssertionLimit": 5,
      "testCoverageTarget": 85,
      "layerSeparation": {
        "repository": {
          "allowedImports": ["prisma", "result"]
        }
      }
    }
  }
}
```

## Examples

### Example 1: TypeScript Strict Project

Enforce zero `any` types and high test coverage:

```json
{
  "name": "TypeScript Strict",
  "priority": 150,
  "detectors": [
    {
      "type": "file_exists",
      "path": "tsconfig.json",
      "condition": "required"
    },
    {
      "type": "file_content",
      "path": "tsconfig.json",
      "pattern": "\"strict\": true",
      "condition": "required"
    }
  ],
  "skills": [
    {
      "name": "typescript",
      "priority": "high",
      "focus": ["type_safety", "any_elimination"]
    }
  ],
  "evaluation": {
    "weights": {
      "code_quality": 0.3,
      "testing": 0.25,
      "error_handling": 0.2,
      "security": 0.15,
      "performance": 0.05,
      "architecture": 0.05
    },
    "customRules": {
      "anyTypeLimit": 0,
      "typeAssertionLimit": 2,
      "testCoverageTarget": 90
    }
  }
}
```

### Example 2: Go Microservice

Focus on performance and concurrency:

```json
{
  "name": "Go Microservice",
  "priority": 120,
  "detectors": [
    {
      "type": "file_exists",
      "path": "go.mod",
      "condition": "required"
    },
    {
      "type": "file_pattern",
      "pattern": "**/*_service.go",
      "condition": "optional"
    }
  ],
  "skills": [
    {
      "name": "golang",
      "priority": "high",
      "focus": ["concurrency", "error_handling", "performance"]
    },
    {
      "name": "security",
      "priority": "high",
      "focus": ["input_validation", "auth"]
    }
  ],
  "evaluation": {
    "weights": {
      "performance": 0.3,
      "security": 0.25,
      "error_handling": 0.2,
      "code_quality": 0.15,
      "architecture": 0.05,
      "testing": 0.05
    },
    "customRules": {
      "goroutineLeakCheck": true,
      "contextUsage": "required",
      "errorWrapping": true
    }
  }
}
```

### Example 3: Clean Architecture Enforcement

Strict layer separation rules:

```json
{
  "name": "Clean Architecture Strict",
  "priority": 180,
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
      "focus": ["layer_separation", "dependency_rule", "domain_modeling"]
    }
  ],
  "evaluation": {
    "weights": {
      "architecture": 0.4,
      "code_quality": 0.2,
      "testing": 0.15,
      "error_handling": 0.15,
      "security": 0.05,
      "performance": 0.05
    },
    "customRules": {
      "layerSeparation": {
        "domain": {
          "allowedImports": [],
          "forbiddenImports": ["application", "infrastructure", "presentation"]
        },
        "application": {
          "allowedImports": ["domain"],
          "forbiddenImports": ["infrastructure", "presentation"]
        },
        "infrastructure": {
          "allowedImports": ["domain", "application"],
          "forbiddenImports": ["presentation"]
        }
      },
      "dependencyDirection": "inward-only"
    }
  }
}
```

## Migration from v1.x

### Step 1: Identify Current Project

Check which hardcoded project type was detected in v1.x:

- "Next.js Fullstack"
- "Go API"
- "React SPA"
- etc.

### Step 2: Copy Template

```bash
# Copy appropriate example
cp config/examples/caad-loca-project.json .code-review-config.json

# Or start from generic template
cp config/examples/.code-review-config.json .code-review-config.json
```

### Step 3: Customize

Edit `.code-review-config.json`:

1. Update `name` and `description`
2. Adjust `detectors` for accurate identification
3. Modify `weights` based on project priorities
4. Add `customRules` for project-specific requirements

### Step 4: Verify

```bash
# Test detection
/review --dry-run

# Run full review
/review
```

## Schema Validation

Validate your configuration file:

```bash
# Using JSON schema validator
jsonschema -i .code-review-config.json -s schemas/project-detection-schema.json
```

## Best Practices

### Configuration Design

1. **Set appropriate priority**
   - Project-specific: 200+
   - User custom: 100-199
   - Built-in: 0-99

2. **Use specific detectors**
   - Combine multiple detectors for accuracy
   - Mark critical detectors as "required"
   - Use "optional" for supplementary checks

3. **Focus skills appropriately**
   - High priority: Core project concerns
   - Medium: Important but not critical
   - Low: Nice-to-have improvements

4. **Weight evaluation dimensions**
   - API projects: High security, performance
   - Frontend: High code quality, performance
   - Libraries: High architecture, testing

5. **Define measurable custom rules**
   - Specific limits (e.g., `anyTypeLimit: 0`)
   - Boolean flags (e.g., `errorWrapping: true`)
   - Structured rules (e.g., layer separation)

### Project Guidelines

Store custom guidelines in project:

```
Project Root/
├── .code-review-config.json
└── docs/
    ├── review-guidelines.md      # General guidelines
    ├── architecture.md            # Architecture decisions
    └── security-checklist.md      # Security requirements
```

Reference in config:

```json
{
  "evaluation": {
    "guidelines": [
      "evaluation-guidelines.md",
      "docs/review-guidelines.md",
      "docs/security-checklist.md"
    ]
  }
}
```

## Troubleshooting

### Project Not Detected

1. Check detector configuration
2. Verify file paths are correct
3. Ensure required conditions are met
4. Check priority order (higher priority checked first)

```bash
# Debug mode (shows detection process)
/review --debug
```

### Wrong Project Type Selected

1. Increase priority of correct configuration
2. Make detectors more specific
3. Add more "required" conditions

### Custom Rules Not Applied

1. Verify JSON syntax
2. Check schema validation
3. Ensure custom rules are documented in evaluation guidelines

## Contributing

### Adding New Project Types

1. Create configuration in `config/` or provide as example
2. Define clear detectors
3. Specify appropriate skills and weights
4. Document custom rules

### Extending Detectors

Future enhancement: Custom detector implementations in `detectors/`

### Custom Evaluators

Future enhancement: Custom evaluation logic in `evaluators/`

## License

Part of Claude Code Marketplace - Dev Tools Collection

## Version History

- **v2.0.0** (2025-01-15)
  - Configuration-based project detection
  - JSON schema validation
  - Custom rules support
  - Backward compatibility with v1.x

- **v1.x** (Legacy)
  - Hardcoded project detection
  - Fixed evaluation criteria
  - CAAD Loca specific rules

## Support

For issues or questions:

1. Check configuration examples in `config/examples/`
2. Validate against schema in `schemas/`
3. Review SKILL.md for detailed documentation
