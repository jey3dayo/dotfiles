# TSR Configuration Migration Guide

This guide helps you migrate from the old TSR skill setup to the new flexible configuration system.

## What's New

The new TSR plugin introduces:

- **Cascading Configuration**: Project > Home > Default
- **JSON Schema Validation**: Structured configuration with validation
- **Framework Detection**: Automatic detection and configuration
- **Flexible Verification**: Configure type-check, lint, test per project
- **Template Reports**: Date-templated output paths

## Migration Steps

### Step 1: Backup Existing Configuration

```bash
# Backup .tsrignore if it exists
cp .tsrignore .tsrignore.backup

# Backup any package.json TSR scripts
grep "tsr" package.json > tsr-scripts.backup.txt
```

### Step 2: Choose Configuration Template

Select the appropriate template for your project:

```bash
# For Next.js App Router
cp examples/nextjs-app-router.json .tsr-config.json

# For Next.js Pages Router
cp examples/nextjs-pages-router.json .tsr-config.json

# For React (non-Next.js)
cp examples/react-app.json .tsr-config.json

# For Node.js
cp examples/nodejs-app.json .tsr-config.json
```

### Step 3: Migrate .tsrignore Patterns

You have two options:

#### Option A: Keep .tsrignore (Recommended)

Keep your existing `.tsrignore` file. It will be merged with the configuration.

```json
{
  "ignoreFile": ".tsrignore"
}
```

#### Option B: Migrate to Configuration

Move patterns to the configuration file:

```json
{
  "ignorePatterns": [
    "src/app/debug/**",
    "src/lib/test-utils/**",
    "src/experimental/**"
  ]
}
```

### Step 4: Update package.json Scripts

Old scripts:

```json
{
  "scripts": {
    "tsr:check": "tsr 'src/.*\\.(ts|tsx)$'",
    "tsr:fix": "tsr -w 'src/.*\\.(ts|tsx)$'"
  }
}
```

New scripts (add config display):

```json
{
  "scripts": {
    "tsr:check": "tsr 'src/.*\\.(ts|tsx)$'",
    "tsr:fix": "tsr -w 'src/.*\\.(ts|tsx)$'",
    "tsr:config": "node config-loader.ts"
  }
}
```

### Step 5: Verify Configuration

```bash
# Display merged configuration
node config-loader.ts

# Expected output:
# TSR Configuration
# ==================================================
# Project Root: /path/to/project
# Config Source: project
#
# Resolved Paths:
#   tsconfig: /path/to/project/tsconfig.json
#   ignoreFile: /path/to/project/.tsrignore
#   outputPath: /tmp/tsr-report-20260115.txt
# ==================================================
```

### Step 6: Test

```bash
# Run a dry run check
pnpm tsr:check > /tmp/tsr-test.txt

# Verify results
wc -l /tmp/tsr-test.txt

# If results look correct, run deletion
pnpm tsr:fix
```

## Configuration Mapping

### Old Setup → New Setup

| Old Approach                 | New Approach                              |
| ---------------------------- | ----------------------------------------- |
| Hard-coded `.tsrignore` path | Configurable `ignoreFile` field           |
| Manual pattern management    | Framework-based auto-generation           |
| No verification automation   | Configurable `verification` settings      |
| Fixed report location        | Template-based `reporting.outputPath`     |
| No configuration reuse       | Global `~/.config/tsr/config.json`        |
| Command-line flags           | Configuration file with schema validation |

## Advanced Migration Scenarios

### Scenario 1: Multiple Projects with Shared Settings

Create a global configuration:

```bash
# Create global config
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

# Each project inherits these settings
# Override in project .tsr-config.json as needed
```

### Scenario 2: CI/CD Integration

Old GitHub Actions:

```yaml
- name: Check for dead code
  run: pnpm tsr:check
```

New GitHub Actions (with config display):

```yaml
- name: Display TSR configuration
  run: node config-loader.ts

- name: Check for dead code
  run: pnpm tsr:check
```

### Scenario 3: Monorepo Setup

Each package can have its own configuration:

```
monorepo/
├── .tsr-config.json          # Root config (shared defaults)
├── packages/
│   ├── web/
│   │   └── .tsr-config.json  # Web-specific config
│   ├── api/
│   │   └── .tsr-config.json  # API-specific config
│   └── shared/
│       └── .tsr-config.json  # Shared-specific config
```

## Troubleshooting

### Issue: Configuration Not Applied

**Symptom**: Changes to `.tsr-config.json` don't seem to take effect

**Solution**:

```bash
# Verify JSON syntax
cat .tsr-config.json | jq .

# Check config priority
node config-loader.ts

# Ensure no typos in field names
diff .tsr-config.json examples/nextjs-app-router.json
```

### Issue: Old Patterns Not Working

**Symptom**: `.tsrignore` patterns not being respected

**Solution**:

```bash
# Check ignoreFile path
node config-loader.ts | grep "ignoreFile"

# Verify .tsrignore exists
ls -la .tsrignore

# Check glob patterns are correct
cat .tsrignore
```

### Issue: Reports in Wrong Location

**Symptom**: Reports not saved to expected location

**Solution**:

```bash
# Check resolved output path
node config-loader.ts | grep "outputPath"

# Update in config
vim .tsr-config.json
# "reporting": {
#   "outputPath": "/desired/path/tsr-{date}.txt"
# }
```

## Rollback

If you need to rollback to the old setup:

```bash
# Restore .tsrignore
cp .tsrignore.backup .tsrignore

# Remove new config
rm .tsr-config.json

# Restore old scripts
# (manual edit of package.json)

# Use old command directly
pnpm tsr 'src/.*\.(ts|tsx)$'
```

## Benefits of Migration

1. **Centralized Configuration**: All settings in one place
2. **Type Safety**: JSON schema validation
3. **Reusability**: Share settings across projects
4. **Flexibility**: Override defaults per project
5. **Automation**: Framework-specific detection
6. **Verification**: Automated quality checks

## Migration Checklist

- [ ] Backup existing configuration
- [ ] Choose and copy configuration template
- [ ] Migrate .tsrignore patterns (if desired)
- [ ] Update package.json scripts
- [ ] Verify configuration with `node config-loader.ts`
- [ ] Test with dry run (`pnpm tsr:check`)
- [ ] Run deletion (`pnpm tsr:fix`)
- [ ] Update CI/CD workflows (if applicable)
- [ ] Document project-specific settings
- [ ] Consider creating global config for shared settings

## Support

For issues or questions:

1. Check `references/workflow.md` for detailed workflows
2. Review `examples/README.md` for configuration examples
3. Consult `SKILL.md` for complete documentation
4. Open an issue in the marketplace repository

---

**Estimated Migration Time**: 5-10 minutes per project
**Difficulty**: Easy
**Breaking Changes**: None (backward compatible with .tsrignore)
