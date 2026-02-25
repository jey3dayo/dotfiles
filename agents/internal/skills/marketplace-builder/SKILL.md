---
name: marketplace-builder
description: Claude Code Marketplace build support. Automates category bundle management, plugin addition, and structure validation.
---

# Marketplace Builder - Claude Code Marketplace Build Support

## When to Use

This skill is automatically loaded when the following keywords are detected:

- Japanese: "marketplace", "マーケットプレイス", "プラグイン追加", "バンドル", "plugin.json", "marketplace.json"
- English: "marketplace", "plugin", "bundle", "category bundle", "marketplace.json"

## Purpose

Streamlines building and managing Claude Code Marketplaces:

1. Category bundle management: Bulk management of plugins at the category level
2. Plugin addition workflow: Standardized process for adding new plugins
3. marketplace.json management: Simple, maintainable structure
4. Structure validation: Verifying consistency of directory structure and metadata

## Category Bundle Structure Basics

### Two Approaches

#### Approach A: Category-Level Bundle (Recommended)

```
plugins/
├── {category}/
│   ├── .claude-plugin/
│   │   └── plugin.json          # Bundles the entire category
│   ├── {plugin1}/
│   │   └── skills/
│   ├── {plugin2}/
│   │   └── skills/
│   └── {plugin3}/
│       └── skills/
```

### Advantages

- ✅ Simple management (category = bundle)
- ✅ Auto-inclusion (only 1 file to update when adding new plugins)
- ✅ Compact marketplace.json
- ✅ No symbolic links required

### marketplace.json

```json
{
  "name": "your-name",
  "plugins": [
    {
      "name": "{category}-bundle",
      "source": "./plugins/{category}",
      "description": "All skills in the {category} category (N plugins)"
    }
  ]
}
```

#### Approach B: Individual Plugin Registration (Traditional)

```
plugins/
├── {category}/
│   ├── {plugin1}/
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   └── skills/
│   └── {plugin2}/
│       ├── .claude-plugin/
│       │   └── plugin.json
│       └── skills/
```

### Advantages

- ✅ High independence per individual plugin
- ✅ Fine-grained version management

### Disadvantages

- ⚠️ marketplace.json grows large
- ⚠️ Requires updating 2 files when adding a plugin

### marketplace.json

```json
{
  "name": "your-name",
  "plugins": [
    {
      "name": "{plugin1}",
      "source": "./plugins/{category}/{plugin1}",
      "description": "Description"
    },
    {
      "name": "{plugin2}",
      "source": "./plugins/{category}/{plugin2}",
      "description": "Description"
    }
  ]
}
```

### Which Should You Choose?

| Criteria          | Category Bundle   | Individual Plugin      |
| ----------------- | ----------------- | ---------------------- |
| Number of plugins | Many (10+)        | Few (<10)              |
| Update frequency  | High              | Low                    |
| Maintainer        | Single            | Multiple               |
| Distribution      | Bulk installation | Selective installation |

### Recommendation

## New Plugin Addition Workflow

### For Category Bundle Format

#### Step 1: Choose a Category

Determine the category based on the plugin's nature:

```
Examples:
- dev-tools: Development tools, code quality, reviews
- docs: Documentation creation, diagrams, presentations
- utils: Utilities, environment management
- infra: Infrastructure operations, deployment, monitoring
```

#### Step 2: Create Directory

```bash
# Create the plugin directory
mkdir -p plugins/{category}/{plugin_name}/skills

# Or place SKILL.md directly at the top level
mkdir -p plugins/{category}/{plugin_name}
```

#### Step 3: Create SKILL.md

```markdown
---
name: your-skill-name
description: Skill description
---

# Skill Name

Detailed description and usage of the skill.
```

#### Step 4: Add to Category Bundle

Edit `plugins/{category}/.claude-plugin/plugin.json`:

```json
{
  "name": "{category}-bundle",
  "version": "1.0.0",
  "description": "All skills in the {category} category",
  "author": { "name": "your-name" },
  "skills": [
    "./existing-plugin/skills/",
    "./your-plugin-name/skills/" // ← Add this
  ]
}
```

### Important

#### Step 5: Validate

```bash
# Check category bundle plugin.json
cat plugins/{category}/.claude-plugin/plugin.json | jq '.skills | length'

# Count number of plugins
ls -1 plugins/{category}/ | grep -v ".claude-plugin" | wc -l

# Consistency check (plugin.json entry count = actual plugin count)
```

### For Individual Plugin Format

#### Steps 1-3: Same as above

#### Step 4: Create plugin's plugin.json

`plugins/{category}/{plugin_name}/.claude-plugin/plugin.json`:

```json
{
  "name": "{plugin_name}",
  "version": "1.0.0",
  "description": "Plugin description",
  "author": { "name": "your-name" },
  "skills": ["./skills/"]
}
```

#### Step 5: Register in marketplace.json

`.claude-plugin/marketplace.json`:

```json
{
  "plugins": [
    {
      "name": "{plugin_name}",
      "source": "./plugins/{category}/{plugin_name}",
      "description": "Description",
      "version": "1.0.0",
      "author": { "name": "your-name" }
    }
  ]
}
```

## skills/ Structure Patterns

### Pattern A: skills/ Subdirectory (Recommended)

```
plugins/{category}/{plugin}/
└── skills/
    ├── SKILL.md
    ├── references/
    └── resources/
```

### Advantages

### Path in plugin.json

### Pattern B: SKILL.md at Top Level

```
plugins/{category}/{plugin}/
├── SKILL.md
└── references/
```

### Advantages

### Path in plugin.json

### Which Should You Choose?

- Pattern A: Many references/resources, planned future expansion
- Pattern B: Small scale, simple structure is sufficient

## Structure Validation

### Basic Validation Commands

```bash
# Check plugin count
ls -1 plugins/{category}/ | grep -v ".claude-plugin" | wc -l

# Check skills/ structure
for dir in plugins/{category}/*/; do
  name=$(basename "$dir")
  if [ -d "$dir/skills" ]; then
    echo "$name -> ./skills/"
  elif [ -f "$dir/SKILL.md" ]; then
    echo "$name -> ./ (top level)"
  fi
done

# Check category bundle entry count
cat plugins/{category}/.claude-plugin/plugin.json | jq '.skills | length'
```

### Consistency Check Script

```bash
#!/bin/bash
# validate-marketplace.sh

category=$1

# Actual plugin count
actual=$(ls -1 plugins/$category/ | grep -v ".claude-plugin" | wc -l)

# plugin.json entry count
declared=$(cat plugins/$category/.claude-plugin/plugin.json | jq '.skills | length')

echo "Actual plugin count: $actual"
echo "plugin.json entry count: $declared"

if [ "$actual" -eq "$declared" ]; then
  echo "✅ Consistency OK"
else
  echo "❌ Inconsistency: $(($actual - $declared)) plugin(s) not registered"
fi
```

## Troubleshooting

### Problem: Plugin not included in bundle

### Symptom

### Cause

### Solution

```bash
# Check plugin.json
cat plugins/{category}/.claude-plugin/plugin.json | jq '.skills'

# Add path
vim plugins/{category}/.claude-plugin/plugin.json
```

### Problem: Incorrect path for skills/ structure

### Symptom

### Cause

### Solution

```bash
# Check actual structure
ls -la plugins/{category}/{plugin_name}/

# Fix path in plugin.json
# Pattern A: "./plugin/skills/"
# Pattern B: "./plugin/"
```

### Problem: marketplace.json growing too large

### Symptom

### Cause

### Solution

```bash
# Migrate to category bundle format
# 1. Create category-level plugin.json
# 2. Update marketplace.json to use category bundles only
# 3. Remove individual plugin.json files (optional)
```

## Best Practices

### 1. Category Design

```
Good examples:
- dev-tools (development tools in general)
- docs (documentation creation in general)
- infra (infrastructure operations in general)

Bad examples:
- tools (too abstract)
- misc (miscellaneous)
- temp (temporary)
```

### 2. Plugin Naming

```
Good examples:
- mise (tool name)
- react-grid-layout (tech stack + function)
- code-review (function)

Bad examples:
- plugin1 (meaningless)
- my-tool (ambiguous)
- test (unclear purpose)
```

### 3. Writing descriptions

```json
{
  "description": "{function}. {details}, {concrete examples}"
}
```

```
Good example:
"All skills in the dev-tools category (27 plugins). React, TypeScript, Go, code review, etc."

Bad example:
"Various tools"
"Useful skill collection"
```

### 4. Version Management

```json
{
  "version": "1.0.0" // Semantic versioning
}
```

- MAJOR: Breaking changes
- MINOR: Feature additions (backward compatible)
- PATCH: Bug fixes

## Automation Script Examples

### Plugin Addition Script

```bash
#!/bin/bash
# add-plugin.sh

category=$1
plugin=$2

# 1. Create directory
mkdir -p plugins/$category/$plugin/skills

# 2. Generate SKILL.md template
cat > plugins/$category/$plugin/skills/SKILL.md <<EOF
---
name: $plugin
description: TODO: Skill description
---

# $plugin

TODO: Detailed description of the skill
EOF

# 3. Add to category bundle
# (Requires JSON editing tool: jq, etc.)
echo "✅ Plugin directory created successfully"
echo "Next steps:"
echo "1. Edit SKILL.md"
echo "2. Add path to plugins/$category/.claude-plugin/plugin.json"
```

### Bundle Validation Script

```bash
#!/bin/bash
# validate-bundle.sh

for category in plugins/*/; do
  if [ -f "$category/.claude-plugin/plugin.json" ]; then
    name=$(basename "$category")
    echo "=== $name ==="

    actual=$(ls -1 "$category" | grep -v ".claude-plugin" | wc -l)
    declared=$(cat "$category/.claude-plugin/plugin.json" | jq '.skills | length')

    echo "Actual: $actual, Registered: $declared"

    if [ "$actual" -ne "$declared" ]; then
      echo "❌ Inconsistency"
    else
      echo "✅ OK"
    fi
  fi
done
```

## Related Links

- [Official Docs: Plugin Marketplace](https://code.claude.com/docs/en/plugin-marketplaces)
- [Official Docs: Plugin Reference](https://code.claude.com/docs/en/plugins-reference)
- [Official Docs: Creating Skills](https://code.claude.com/docs/en/skills)

## Summary

By using this skill:

1. ✅ **Understand the two approaches**: Category bundles vs individual plugins
2. ✅ **Make appropriate choices**: Select structure based on project scale and requirements
3. ✅ **Standardized workflow**: Unified process for adding new plugins
4. ✅ **Structure validation**: Consistency checks and automation

### Key Principles
