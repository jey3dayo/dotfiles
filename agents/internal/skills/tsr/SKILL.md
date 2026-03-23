---
name: tsr
description: |
  [What] Specialized skill for detecting and removing unused TypeScript/React code (dead code). Leverages TSR (TypeScript Remove Unused) tool with flexible configuration system supporting project-specific, home directory, and default settings
  [When] Use when: users mention "unused code", "dead code", "tsr", or need codebase cleanup for TypeScript/React projects
  [Keywords] unused code, dead code, tsr
---

# TSR - TypeScript Unused Code Detection and Removal

A specialized skill for safely detecting and removing unused code (dead code) in TypeScript/React projects. The flexible configuration system allows integrated management of project-specific settings and global settings.

## New Feature: Flexible Configuration System

### Configuration File Priority (Cascading)

TSR loads and merges configurations in the following order:

1. Project root (highest priority): `.tsr-config.json`
2. Home directory: `~/.config/tsr/config.json`
3. Default settings (lowest priority): `tsr-config.default.json`

### Configuration File Format

```json
{
  "version": "1.0.0",
  "tsconfig": "tsconfig.json",
  "ignoreFile": ".tsrignore",
  "entryPatterns": ["src/.*\\.(ts|tsx)$"],
  "maxDeletionPerRun": 10,
  "includeDts": false,
  "recursive": false,
  "ignorePatterns": [],
  "verification": {
    "typeCheck": true,
    "lint": true,
    "test": false
  },
  "reporting": {
    "outputPath": "/tmp/tsr-report-{date}.txt",
    "verbose": false
  },
  "framework": {
    "type": "nextjs",
    "nextjs": {
      "appRouter": true,
      "pagesRouter": false
    }
  }
}
```

### Configuration Field Details

| Field                          | Type     | Default                      | Description                                                      |
| ------------------------------ | -------- | ---------------------------- | ---------------------------------------------------------------- |
| `version`                      | string   | "1.0.0"                      | Configuration file version                                       |
| `tsconfig`                     | string   | "tsconfig.json"              | Path to TypeScript configuration file (relative to project root) |
| `ignoreFile`                   | string   | ".tsrignore"                 | Path to exclusion pattern file                                   |
| `entryPatterns`                | string[] | ["src/.*\\.(ts\|tsx)$"]      | Entry point patterns                                             |
| `maxDeletionPerRun`            | number   | 10                           | Maximum number of deletions per run                              |
| `includeDts`                   | boolean  | false                        | Include .d.ts files in analysis targets                          |
| `recursive`                    | boolean  | false                        | Recursive deletion mode                                          |
| `ignorePatterns`               | string[] | []                           | Additional exclusion patterns (merged with .tsrignore)           |
| `verification.typeCheck`       | boolean  | true                         | Run type check after deletion                                    |
| `verification.lint`            | boolean  | true                         | Run lint after deletion                                          |
| `verification.test`            | boolean  | false                        | Run tests after deletion                                         |
| `reporting.outputPath`         | string   | "/tmp/tsr-report-{date}.txt" | Report output path ({date} is auto-replaced)                     |
| `reporting.verbose`            | boolean  | false                        | Verbose output mode                                              |
| `framework.type`               | string   | "nextjs"                     | Framework type (nextjs\|react\|node\|custom)                     |
| `framework.nextjs.appRouter`   | boolean  | true                         | Use Next.js App Router                                           |
| `framework.nextjs.pagesRouter` | boolean  | false                        | Use Next.js Pages Router                                         |

### Configuration Management Commands

```bash
# Display configuration
node config-loader.ts

# Create project configuration
cat > .tsr-config.json <<EOF
{
  "version": "1.0.0",
  "maxDeletionPerRun": 20,
  "framework": {
    "type": "nextjs",
    "nextjs": {
      "appRouter": true,
      "pagesRouter": false
    }
  }
}
EOF

# Create home directory configuration (shared across all projects)
mkdir -p ~/.config/tsr
cat > ~/.config/tsr/config.json <<EOF
{
  "verification": {
    "typeCheck": true,
    "lint": true,
    "test": true
  },
  "reporting": {
    "outputPath": "~/tsr-reports/tsr-{date}.txt",
    "verbose": true
  }
}
EOF
```

## 🎯 Core Mission

Use the `tsr` tool to detect unused exports and unused files in the project, and safely remove dead code in a gradual manner by working with the flexible configuration system and `.tsrignore` to exclude false positives.

## 🛠️ Tool Information

- Command: `tsr` (v1.3.4)
- Package: Included in devDependencies
- Supported languages: TypeScript, JavaScript (React compatible)
- Detection method: TypeScript compiler API + static analysis
- Configuration system: Cascading configuration loader

## 📋 Key Features

### 1. Unused Code Detection

- Unused exports: exports not referenced from other files
- Unused files: files not used anywhere in the project
- Entry point tracking: specify entry points with regex patterns

### 2. Safe Deletion Workflow

- Detection mode (`tsr`): Report unused code (no changes)
- Deletion mode (`tsr --write`): Actually execute deletion
- Recursive mode (`tsr --recursive`): Run repeatedly until clean
- Automatic verification: Automatically run type-check/lint/test based on configuration

### 3. False Positive Exclusion

- .tsrignore: Define false positive patterns
- Automatic framework exclusion: Automatically determine files specific to Next.js/React
- Custom patterns: Set project-specific exclusion patterns

## 🚀 Basic Usage

### Quick Start

```bash
# 1. Generate configuration file
node config-loader.ts > config-summary.txt

# 2. Create project-specific configuration (optional)
cat > .tsr-config.json <<EOF
{
  "version": "1.0.0",
  "maxDeletionPerRun": 15,
  "framework": {
    "type": "nextjs",
    "nextjs": {
      "appRouter": true
    }
  }
}
EOF

# 3. Detect dead code
pnpm tsr:check

# 4. After reviewing report, execute deletion
pnpm tsr:fix
```

### package.json Scripts

```json
{
  "scripts": {
    "tsr:check": "tsr 'src/.*\\.(ts|tsx)$'",
    "tsr:fix": "tsr -w 'src/.*\\.(ts|tsx)$'",
    "tsr:config": "node config-loader.ts"
  }
}
```

## 📊 Typical Usage Flow

### Step 1: Check Configuration

```bash
# Check current configuration
pnpm tsr:config

# Example output:
# TSR Configuration
# ==================================================
# Project Root: /path/to/project
# Config Source: project
#
# Resolved Paths:
#   tsconfig: /path/to/project/tsconfig.json
#   ignoreFile: /path/to/project/.tsrignore
#   outputPath: /tmp/tsr-report-20260115.txt
#
# Settings:
#   Framework: nextjs
#   Max Deletion: 15
#   Include .d.ts: false
#   Recursive: false
# ==================================================
```

### Step 2: Detection

```bash
# Detect dead code and output report
pnpm tsr:check > /tmp/tsr-report.txt
```

### Step 3: Report Analysis

Review the report and categorize into:

1. Safe to delete: Clearly unused
2. Needs review: Possibly a false positive
3. Keep: Needed but usage cannot be tracked

### Step 4: Update .tsrignore

Add false positive patterns to `.tsrignore`:

```
# Next.js-specific files
src/app/**/page.tsx
src/app/**/layout.tsx
src/app/api/**/*.ts

# Test-related
*.test.ts
*.spec.ts
src/mocks/**
```

### Step 5: Gradual Deletion

```bash
# Delete based on configuration (up to maxDeletionPerRun)
pnpm tsr:fix

# Automatic verification is run (based on verification settings)
# - pnpm type-check (verification.typeCheck: true)
# - pnpm lint (verification.lint: true)
# - pnpm test (verification.test: true)
```

## 🎯 Practical Use Cases

### 1. Regular Codebase Cleanup

```bash
# Run weekly or after feature additions
pnpm tsr:check > /tmp/tsr-$(date +%Y%m%d).txt

# Analyze with skill
# After skill launch: load and analyze /tmp/tsr-{date}.txt
```

### 2. Cleanup After Refactoring

```bash
# Detect dead code after refactoring
pnpm tsr:check > /tmp/tsr-after-refactor.txt

# Review results and delete
pnpm tsr:fix
```

### 3. CI/CD Integration

```yaml
# GitHub Actions example
- name: Check for dead code
  run: pnpm tsr:check
```

## 📋 .tsrignore File Configuration

### Basic Structure

```
# Comment lines start with #

# Specify files with glob patterns
*.config.ts
src/app/**/page.tsx

# Specific files
middleware.ts
next-env.d.ts
```

### Auto-generation

The `.tsrignore` file can be auto-generated based on the configuration file:

```typescript
import { loadTsrConfig, generateTsrIgnore } from "./config-loader";

const config = await loadTsrConfig("/path/to/project");
const ignoreContent = await generateTsrIgnore(config);
console.log(ignoreContent);
```

See `references/tsrignore.md` for details.

## ⚠️ Constraints and Notes

### Possibility of False Positives

The following may be in use but could be falsely detected:

1. Next.js-specific files
   - `page.tsx`, `layout.tsx`, `loading.tsx`, `error.tsx`
   - API Routes (`src/app/api/**/*.ts`)
   - Middleware (`middleware.ts`)

2. Dynamic imports
   - Lazy loading via `import()`
   - String-based imports

3. Test-related
   - Test files (`_.test.ts`, `_.spec.ts`)
   - Storybook (\*.stories.tsx)
   - Mock data (src/mocks/\*\*)

4. Type definitions
   - Type definition files (\*.d.ts)
   - Type-only exports

### For Safe Deletion

1. Gradual deletion: Control with `maxDeletionPerRun` setting (default 10)
2. Automatic verification: Automate post-deletion verification with `verification` settings
3. Git commit: Commit before deletion to enable rollback
4. .tsrignore management: Properly manage false positive patterns

## 🔧 Advanced Usage

### Custom Configuration Example

```json
{
  "version": "1.0.0",
  "maxDeletionPerRun": 20,
  "includeDts": false,
  "recursive": false,
  "verification": {
    "typeCheck": true,
    "lint": true,
    "test": true
  },
  "reporting": {
    "outputPath": "~/tsr-reports/tsr-{date}.txt",
    "verbose": true
  },
  "framework": {
    "type": "nextjs",
    "nextjs": {
      "appRouter": true,
      "pagesRouter": false
    }
  },
  "ignorePatterns": ["src/experimental/**", "src/deprecated/**"]
}
```

### Configuration by Project Type

#### Next.js (App Router)

```json
{
  "framework": {
    "type": "nextjs",
    "nextjs": {
      "appRouter": true,
      "pagesRouter": false
    }
  }
}
```

#### Next.js (Pages Router)

```json
{
  "framework": {
    "type": "nextjs",
    "nextjs": {
      "appRouter": false,
      "pagesRouter": true
    }
  }
}
```

#### React (non-Next.js)

```json
{
  "framework": {
    "type": "react"
  }
}
```

#### Node.js

```json
{
  "framework": {
    "type": "node"
  },
  "entryPatterns": ["src/.*\\.ts$"]
}
```

## 🤝 Integration with Other Tools and Commands

### Comparison with Knip

| Feature           | TSR                            | Knip                      |
| ----------------- | ------------------------------ | ------------------------- |
| Detection targets | Unused exports and files       | Includes unused deps too  |
| Deletion          | ✅ Automatic deletion possible | ❌ Report only            |
| Config complexity | 🟢 Simple                      | 🟡 Somewhat complex       |
| Next.js support   | 🟢 Good                        | 🟡 Requires configuration |

### Integration with Similarity Skill

```bash
# 1. Remove duplicate code with Similarity
similarity-ts --threshold 0.9 src/ > /tmp/similarity-report.md

# 2. Execute refactoring

# 3. Remove dead code with TSR
pnpm tsr:check > /tmp/tsr-report.txt
pnpm tsr:fix
```

### Combination with Refactoring Command

```bash
# 1. Improve code with /refactoring

# 2. Remove dead code with TSR
pnpm tsr:fix

# 3. Quality check (automatic execution)
# Automatically executed via verification settings
```

## 📚 Related Resources

### Detailed Documentation

- config-loader.ts: Configuration loader implementation
- tsr-config.schema.json: Configuration schema definition
- tsr-config.default.json: Default configuration
- references/workflow.md: Detailed execution workflow
- references/tsrignore.md: .tsrignore configuration guide
- references/examples.md: Practical examples and use cases

### External Resources

- TSR repository: [GitHub - line/tsr](https://github.com/line/tsr)
- Project-specific guide: `CLAUDE.md`, `.claude/essential/integration-guide.md`

## 🎯 Expected Outcomes

- Slimmer codebase: Improved maintainability by removing unused code
- Shorter build time: Reduced compile time by removing unnecessary files
- Reduced bundle size: Smaller final bundle size by eliminating unused code
- Improved code readability: Only used code remains, making it easier to understand
- Configuration flexibility: Integrated management of project-specific and global settings

## 🎓 Practical Workflow

### Initial Setup

```bash
# 1. Check configuration
pnpm tsr:config

# 2. Create project-specific configuration (if needed)
cat > .tsr-config.json <<EOF
{
  "version": "1.0.0",
  "maxDeletionPerRun": 15,
  "verification": {
    "typeCheck": true,
    "lint": true,
    "test": false
  }
}
EOF

# 3. Auto-generate .tsrignore
node config-loader.ts --generate-ignore > .tsrignore

# 4. Initial detection
pnpm tsr:check > /tmp/tsr-initial.txt

# 5. After reviewing report, execute deletion
pnpm tsr:fix
```

### Weekly Cleanup

```bash
# Step 1: Detection
pnpm tsr:check > /tmp/tsr-weekly.txt

# Step 2: Review report
# After skill launch: load and analyze /tmp/tsr-weekly.txt

# Step 3: Safe deletion
pnpm tsr:fix

# Step 4: Automatic verification (automatically run via verification settings)

# Step 5: Commit
git add -A
git commit -m "chore: remove unused code"
```

---

### When to Use

### Time Required

### Setup Time
