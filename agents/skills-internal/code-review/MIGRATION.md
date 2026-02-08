# Migration Guide: v1.x → v2.0

This guide helps you migrate from the old hardcoded project detection system to the new configuration-based system.

## Overview of Changes

### v1.x (Old)

- Hardcoded project detection in `detailed-mode.md`
- Fixed evaluation criteria per project type
- CAAD Loca specific rules embedded in code
- Limited customization options

### v2.0 (New)

- Configuration-based project detection
- JSON schema validation
- Pluggable evaluation rules
- Full customization support
- Backward compatible with default configs

## Migration Steps

### Step 1: Understand Current Detection

**v1.x Detection Logic** (hardcoded in `detailed-mode.md`):

```python
def analyze_project():
    """Old hardcoded detection"""

    project_info = {
        "type": None,
        "stack": [],
        "structure": {}
    }

    # Hardcoded checks
    if os.path.exists("go.mod"):
        project_info["stack"].append("go")
        if glob.glob("**/*_handler.go"):
            project_info["type"] = "api"

    if os.path.exists("package.json"):
        # More hardcoded checks...
        if "next" in deps:
            project_info["type"] = "fullstack"

    return project_info
```

**v2.0 Detection** (configuration-driven):

```python
def detect_project_type():
    """New configuration-based detection"""

    # Load configurations
    configs = load_configurations([
        "./.code-review-config.json",
        "~/.claude/code-review/custom-projects.json",
        "default-projects.json"
    ])

    # Execute detectors from config
    for project in sort_by_priority(configs):
        if all_detectors_pass(project["detectors"]):
            return project

    return get_generic_project()
```

### Step 2: Map Old Project Types to New Configs

| v1.x Project Type       | v2.0 Config Template               | Priority |
| ----------------------- | ---------------------------------- | -------- |
| "Next.js Fullstack"     | `default-projects.json` (built-in) | 100      |
| "Go API"                | `default-projects.json` (built-in) | 90       |
| "Go Clean Architecture" | `default-projects.json` (built-in) | 95       |
| "React SPA"             | `default-projects.json` (built-in) | 80       |
| "TypeScript Node.js"    | `default-projects.json` (built-in) | 70       |
| "CAAD Loca" (custom)    | `examples/caad-loca-project.json`  | 150      |

### Step 3: Choose Migration Path

#### Option A: Use Built-in Defaults (Recommended for Most)

If your project matches a standard type, no migration needed:

```bash
# Just run review - detection is automatic
/review
```

**Built-in defaults handle**:

- Next.js with TypeScript/React
- Go API servers
- React Single Page Applications
- TypeScript Node.js backends

#### Option B: Add Project-Specific Config

For custom requirements or CAAD Loca-like projects:

1. **Copy template**:

   ```bash
   cp ~/.claude/plugins/code-review/config/examples/.code-review-config.json .code-review-config.json
   ```

2. **Customize for your project**:

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

3. **Test detection**:

   ```bash
   /review --debug
   ```

### Step 4: Migrate CAAD Loca Specific Rules

**Old**: Hardcoded in `caad-loca-patterns.md`

**New**: Configuration file with custom rules

```bash
# Copy CAAD Loca template
cp ~/.claude/plugins/code-review/config/examples/caad-loca-project.json .code-review-config.json
```

**Key customizations in config**:

```json
{
  "name": "CAAD Loca Next",
  "priority": 150,
  "detectors": [
    {
      "type": "directory_structure",
      "path": "src/lib/repositories",
      "condition": "required"
    },
    {
      "type": "directory_structure",
      "path": "src/lib/services",
      "condition": "required"
    }
  ],
  "evaluation": {
    "customRules": {
      "resultPattern": {
        "required": true,
        "layers": ["repository", "service", "action", "transform"]
      },
      "typeSafety": {
        "anyTypeLimit": 0,
        "typeAssertionLimit": 0
      },
      "layerSeparation": {
        "repository": {
          "allowedImports": ["prisma", "result"]
        }
      }
    }
  }
}
```

### Step 5: Update Evaluation Guidelines

**Old**: Guidelines embedded in code

**New**: Reference guidelines in config

1. **Keep existing guidelines**:

   ```
   Project Root/
   ├── .code-review-config.json
   └── docs/
       ├── review-guidelines.md
       └── architecture.md
   ```

2. **Reference in config**:

   ```json
   {
     "evaluation": {
       "guidelines": [
         "evaluation-guidelines.md",
         "docs/review-guidelines.md",
         "docs/architecture.md"
       ]
     }
   }
   ```

### Step 6: Verify Migration

```bash
# 1. Check project detection
/review --debug

# 2. Run full review
/review

# 3. Compare results with v1.x
# Should produce similar ⭐️ ratings and recommendations
```

## Common Migration Scenarios

### Scenario 1: Standard Next.js Project

**v1.x**: Automatically detected as "Next.js Fullstack"

**v2.0**: Still automatically detected (built-in default)

**Action**: None required ✅

---

### Scenario 2: Custom TypeScript Project

**v1.x**: Detected as "TypeScript Node.js" but missing specific rules

**v2.0**: Create custom config

**Action**:

1. Copy template
2. Add custom rules
3. Adjust weights for your priorities

Example:

```json
{
  "name": "My TypeScript API",
  "priority": 200,
  "evaluation": {
    "weights": {
      "security": 0.3,
      "code_quality": 0.25,
      "error_handling": 0.2,
      "testing": 0.15,
      "performance": 0.05,
      "architecture": 0.05
    },
    "customRules": {
      "anyTypeLimit": 0,
      "testCoverageTarget": 85,
      "errorWrapping": true
    }
  }
}
```

---

### Scenario 3: CAAD Loca Project

**v1.x**: Used hardcoded `caad-loca-patterns.md`

**v2.0**: Use CAAD Loca template

**Action**:

```bash
cp config/examples/caad-loca-project.json .code-review-config.json
```

Verify custom rules are preserved:

- Result<T,E> pattern enforcement
- Zero `any` type policy
- Layer separation rules
- Active-only filtering patterns

---

### Scenario 4: Multi-Project Monorepo

**v1.x**: Single detection per run

**v2.0**: Per-directory configuration support

**Action**:

```
monorepo/
├── frontend/
│   └── .code-review-config.json    # React SPA config
├── backend/
│   └── .code-review-config.json    # Go API config
└── shared/
    └── .code-review-config.json    # Library config
```

Run reviews in specific directories:

```bash
cd frontend && /review
cd backend && /review
cd shared && /review
```

## Troubleshooting

### Issue 1: Wrong Project Type Detected

**Symptom**: Review uses incorrect evaluation criteria

**Solution**:

1. Check `.code-review-config.json` exists in project root
2. Verify priority is higher than default (200+)
3. Add more specific detectors

Example fix:

```json
{
  "priority": 250,
  "detectors": [
    {
      "type": "file_exists",
      "path": "unique-file.json",
      "condition": "required"
    }
  ]
}
```

### Issue 2: Custom Rules Not Applied

**Symptom**: Evaluation doesn't enforce custom rules

**Solution**:

1. Validate JSON syntax
2. Check schema compliance:

   ```bash
   jsonschema -i .code-review-config.json -s schemas/project-detection-schema.json
   ```

3. Ensure custom rules are documented in referenced guidelines

### Issue 3: Skills Not Loading

**Symptom**: Missing technology-specific evaluation

**Solution**:

1. Verify skill names match available skills
2. Check skill focus areas are valid
3. Ensure skills are installed in `~/.claude/skills/`

Valid skills:

- `typescript`
- `react`
- `golang`
- `security`
- `clean-architecture`
- `semantic-analysis`

## Rollback Plan

If migration causes issues:

```bash
# 1. Remove custom config
rm .code-review-config.json

# 2. Use v1.x behavior (built-in defaults)
/review

# 3. Or restore from backup
cp .code-review-config.json.backup .code-review-config.json
```

Built-in defaults provide v1.x compatible behavior.

## Benefits of Migration

1. **Flexibility**: Add custom project types without code changes
2. **Maintainability**: Configuration separate from core logic
3. **Reusability**: Share configs across projects/teams
4. **Validation**: JSON schema ensures correct configuration
5. **Extensibility**: Easy to add new detectors and rules

## Next Steps

After migration:

1. **Document your configuration**:
   - Add comments explaining custom rules
   - Document evaluation priorities
   - Share with team members

2. **Create team templates**:

   ```bash
   # Save as team template
   cp .code-review-config.json ~/.claude/code-review/team-template.json
   ```

3. **Integrate with CI/CD**:

   ```yaml
   # .github/workflows/code-review.yml
   - name: Code Review
     run: /review --simple
   ```

4. **Monitor and refine**:
   - Adjust weights based on review results
   - Add custom rules as patterns emerge
   - Update detectors for accuracy

## Support

For migration assistance:

1. Check examples in `config/examples/`
2. Review schema in `schemas/project-detection-schema.json`
3. Read README.md for detailed documentation
4. Consult SKILL.md for configuration reference

---

**Recommendation**: Start with built-in defaults, then gradually customize as needs emerge. Most projects won't require custom configuration.
