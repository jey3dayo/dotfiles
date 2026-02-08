# Kiro Configuration Loader

## Purpose

Utility to load and merge Kiro configuration from multiple sources with fallback to defaults.

## Configuration Resolution Order

1. **Project-specific**: `.kiro-config.json` in project root
2. **User-level**: `~/.config/kiro/config.json` (optional)
3. **Default**: Built-in default configuration

## Loading Logic

```typescript
interface KiroConfig {
  version: string;
  paths: {
    root: string;
    steering: string;
    specs: string;
    settings: string;
    templates: string;
    rules: string;
  };
  workflow: {
    defaultLanguage: "ja" | "en";
    autoApproval: boolean;
    phases: {
      requirements: { enabled: boolean; template?: string };
      design: { enabled: boolean; template?: string };
      tasks: { enabled: boolean; template?: string };
    };
  };
  templates: {
    specs: {
      init: string;
      requirementsInit: string;
      requirements: string;
      design: string;
      tasks: string;
    };
    steering: {
      custom: string;
    };
  };
  rules: {
    earsFormat: string;
    designPrinciples: string;
    designDiscoveryLight: string;
    designDiscoveryFull: string;
    designReview: string;
    gapAnalysis: string;
    steeringPrinciples: string;
    tasksGeneration: string;
    [key: string]: string;
  };
  validation: {
    requireApproval: boolean;
    checkTaskCoverage: boolean;
    enforcePhaseOrder: boolean;
  };
}
```

## Usage in Commands

Each command should start with:

```markdown
## Load Configuration

1. **Check for project config**: Read `.kiro-config.json` if it exists
2. **Merge with defaults**: Apply `.kiro-config.default.json` as fallback
3. **Resolve paths**: Convert relative paths to absolute paths based on working directory
```

## Path Resolution

All paths in config are relative and need to be resolved:

```
${CWD}/${config.paths.root}/${config.paths.steering}
→ /project/path/.kiro/steering/

${CWD}/${config.paths.root}/${config.paths.settings}/${config.paths.templates}/${config.templates.specs.init}
→ /project/path/.kiro/settings/templates/specs/init.json
```

## Commands Reference Pattern

When commands need to reference files:

**Before (hardcoded)**:

```
- Read `.kiro/steering/*.md`
- Verify `.kiro/specs/$1/` exists
- Read `.kiro/settings/templates/specs/init.json`
```

**After (config-based)**:

```
- Read `${KIRO_ROOT}/${STEERING_DIR}/*.md`
- Verify `${KIRO_ROOT}/${SPECS_DIR}/$1/` exists
- Read `${SETTINGS_ROOT}/${TEMPLATES_DIR}/${SPEC_INIT_TEMPLATE}`
```

## Environment Variables

Commands can export resolved paths as environment variables:

```bash
export KIRO_ROOT="${CWD}/${config.paths.root}"
export KIRO_STEERING="${KIRO_ROOT}/${config.paths.steering}"
export KIRO_SPECS="${KIRO_ROOT}/${config.paths.specs}"
export KIRO_SETTINGS="${KIRO_ROOT}/${config.paths.settings}"
export KIRO_TEMPLATES="${KIRO_SETTINGS}/${config.paths.templates}"
export KIRO_RULES="${KIRO_SETTINGS}/${config.paths.rules}"
```

## Error Handling

### Missing Config File

If `.kiro-config.json` is not found:

- Use default configuration
- Log a warning that defaults are being used
- Suggest creating config with: `/kiro:init-config`

### Invalid Config

If config is malformed:

- Report validation errors
- Fall back to defaults
- Suggest fixing or regenerating config

### Missing Directories

If configured directories don't exist:

- Report specific missing directory
- Suggest initializing with: `/kiro:init-project`
- Provide exact path that was expected

## Validation

Commands should validate configuration at startup:

1. **Required paths exist**: `root`, `steering`, `specs`, `settings`
2. **Template files accessible**: Check that referenced templates exist
3. **Rule files accessible**: Verify rule files can be read
4. **Version compatibility**: Warn if config version is newer than supported

## Migration Support

When updating configuration schema:

1. **Version check**: Compare config.version with supported version
2. **Auto-migration**: Apply transformations if schema changed
3. **Backup**: Create `.kiro-config.json.backup` before migration
4. **Report**: Show what was migrated and why

## Example: Load Config in Command

```markdown
<instructions>

## Step 1: Load Configuration

1. Use **Read** to load `.kiro-config.json` from project root
   - If not found, use `.kiro-config.default.json`
   - Parse JSON and validate structure

2. Resolve all paths relative to current working directory
   - KIRO_ROOT = ${CWD}/${config.paths.root}
   - KIRO_STEERING = ${KIRO_ROOT}/${config.paths.steering}
   - KIRO_SPECS = ${KIRO_ROOT}/${config.paths.specs}
   - ... (continue for all paths)

3. Validate required directories exist
   - If missing, report error with specific path
   - Suggest initialization command

## Step 2: Execute Command Logic

Use resolved paths instead of hardcoded `.kiro/` paths...

</instructions>
```

## Benefits

1. **Portability**: Projects can customize their Kiro structure
2. **Flexibility**: Support different team conventions
3. **Backwards compatibility**: Default config matches current structure
4. **Migration path**: Easy to update existing projects
5. **Multi-project**: Different projects can use different structures
