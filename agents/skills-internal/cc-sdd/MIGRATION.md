# cc-sdd Migration Guide

## Overview

This guide helps you migrate from the legacy cc-sdd skill to the standardized cc-sdd plugin with configurable directory structure.

## Migration Scenarios

### Scenario 1: New Project

For new projects starting with cc-sdd:

1. **Copy default configuration**

   ```bash
   cp .kiro-config.default.json .kiro-config.json
   ```

2. **Copy default directory structure**

   ```bash
   cp -r .kiro-default .kiro
   ```

3. **Customize if needed**

   Edit `.kiro-config.json` to match your project structure.

4. **Initialize first specification**

   ```bash
   /kiro:spec-init "Your feature description"
   ```

### Scenario 2: Existing cc-sdd Project (Legacy Structure)

For projects already using cc-sdd with `.kiro/` directory:

#### Option A: Keep Current Structure (Recommended)

1. **Create config matching current structure**

   ```bash
   # Copy default config
   cp .kiro-config.default.json .kiro-config.json
   ```

   The default config matches the legacy structure, so no changes needed:

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
     }
   }
   ```

2. **Verify existing structure**

   ```bash
   ls -la .kiro/
   # Should show: steering/, specs/, settings/
   ```

3. **Test commands**

   ```bash
   /kiro:spec-status [existing-feature]
   ```

#### Option B: Migrate to New Structure

If you want to reorganize your project:

1. **Define new structure in config**

   Create `.kiro-config.json`:

   ```json
   {
     "version": "1.0.0",
     "paths": {
       "root": "docs/specifications",
       "steering": "guidelines",
       "specs": "features",
       "settings": "config"
     }
   }
   ```

2. **Move existing files**

   ```bash
   # Create new structure
   mkdir -p docs/specifications/{guidelines,features,config}

   # Move steering files
   mv .kiro/steering/* docs/specifications/guidelines/

   # Move spec files
   mv .kiro/specs/* docs/specifications/features/

   # Move settings
   mv .kiro/settings/* docs/specifications/config/

   # Remove old directory
   rm -rf .kiro
   ```

3. **Verify migration**

   ```bash
   /kiro:spec-status [feature-name]
   ```

### Scenario 3: Multiple Projects with Different Structures

For teams managing multiple projects with different conventions:

1. **Project A: Traditional structure**

   `.kiro-config.json`:

   ```json
   {
     "paths": {
       "root": ".kiro",
       "steering": "steering",
       "specs": "specs"
     }
   }
   ```

2. **Project B: Documentation-centric**

   `.kiro-config.json`:

   ```json
   {
     "paths": {
       "root": "docs",
       "steering": "architecture",
       "specs": "features"
     }
   }
   ```

3. **Project C: Monorepo**

   `.kiro-config.json`:

   ```json
   {
     "paths": {
       "root": "engineering/specs",
       "steering": "guidelines",
       "specs": "projects"
     }
   }
   ```

## Configuration Validation

After migration, validate your configuration:

1. **Check config syntax**

   ```bash
   # Read and parse config
   cat .kiro-config.json | jq .
   ```

2. **Verify paths exist**

   ```bash
   # For default config
   ls -la .kiro/steering/
   ls -la .kiro/specs/
   ls -la .kiro/settings/
   ```

3. **Test commands**

   ```bash
   # List existing specs
   /kiro:spec-status

   # Check specific spec
   /kiro:spec-status [feature-name]
   ```

## Common Issues

### Issue 1: Commands Can't Find Files

**Symptom**: Error messages like "No spec found for [feature]"

**Solution**:

1. Check that `.kiro-config.json` exists:

   ```bash
   cat .kiro-config.json
   ```

2. Verify paths in config match actual directory structure:

   ```bash
   # If config says root is ".kiro"
   ls -la .kiro/

   # If config says specs is "specs"
   ls -la .kiro/specs/
   ```

3. Ensure case sensitivity matches (especially on case-sensitive filesystems)

### Issue 2: Template Files Not Found

**Symptom**: Error messages like "Template file not found"

**Solution**:

1. Check that settings directory has templates:

   ```bash
   ls -la .kiro/settings/templates/specs/
   ```

2. If missing, copy from plugin defaults:

   ```bash
   cp -r [plugin-path]/.kiro-default/settings .kiro/
   ```

### Issue 3: Invalid JSON Configuration

**Symptom**: Error parsing `.kiro-config.json`

**Solution**:

1. Validate JSON syntax:

   ```bash
   jq . .kiro-config.json
   ```

2. If invalid, restore from default:

   ```bash
   cp .kiro-config.default.json .kiro-config.json
   ```

### Issue 4: Permission Errors

**Symptom**: Can't read/write files in `.kiro/` directory

**Solution**:

```bash
# Fix permissions
chmod -R u+rw .kiro/
```

## Backward Compatibility

The standardized plugin maintains full backward compatibility:

- **Default configuration** matches legacy structure (`.kiro/`)
- **All existing commands** work without changes
- **Existing specs** are recognized automatically
- **No forced migration** - legacy projects work as-is

## Best Practices

### For New Projects

1. **Use default structure** unless you have specific requirements
2. **Commit config file** to version control
3. **Document customizations** in project README

### For Existing Projects

1. **Start with config matching current structure** (zero-downtime migration)
2. **Test thoroughly** before reorganizing
3. **Migrate incrementally** if changing structure

### For Teams

1. **Establish conventions** across projects
2. **Share config templates** for different project types
3. **Document rationale** for custom structures

## Rollback Procedure

If migration causes issues:

1. **Remove config file**

   ```bash
   rm .kiro-config.json
   ```

   Plugin will use built-in defaults (legacy structure).

2. **Restore from backup** (if you reorganized files)

   ```bash
   # If you backed up before migration
   rm -rf .kiro
   mv .kiro.backup .kiro
   ```

3. **Report issue** with details of what went wrong

## Migration Checklist

Use this checklist to ensure smooth migration:

- [ ] Read this migration guide
- [ ] Backup current `.kiro/` directory (if exists)
- [ ] Choose migration scenario (new, keep structure, or reorganize)
- [ ] Create `.kiro-config.json` matching chosen scenario
- [ ] Move files if reorganizing
- [ ] Validate configuration with `jq`
- [ ] Test with `/kiro:spec-status`
- [ ] Test creating new spec with `/kiro:spec-init`
- [ ] Update team documentation
- [ ] Commit changes to version control

## Getting Help

If you encounter issues during migration:

1. **Check this guide** for common issues
2. **Validate configuration** using provided commands
3. **Consult plugin documentation** in `SKILL.md`
4. **Review config schema** in `.kiro-config.schema.json`

## Next Steps

After successful migration:

1. **Explore customization options** in `shared/config-loader.md`
2. **Review workflow documentation** in `references/workflow.md`
3. **Set up team conventions** if working in a team
4. **Consider automation** for multi-project setups
