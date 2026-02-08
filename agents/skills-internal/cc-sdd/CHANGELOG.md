# Changelog

All notable changes to cc-sdd plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-15

### Added

- Configurable directory structure via `.kiro-config.json`
- JSON schema for configuration validation (`.kiro-config.schema.json`)
- Default configuration with legacy-compatible structure
- Configuration loader system with fallback to defaults
- Progressive disclosure architecture for efficient context loading
- Multi-project support with per-project configuration
- Standardized command pattern with config resolution
- Comprehensive migration guide (MIGRATION.md)
- Configuration documentation (shared/config-loader.md)
- Complete README with quick start and examples

### Changed

- Converted from skill to plugin architecture
- Made all directory paths configurable
- Updated commands to use config-based paths instead of hardcoded `.kiro/`
- Enhanced SKILL.md with configuration examples
- Improved command documentation with config usage patterns

### Fixed

- Path resolution for different project structures
- Template and rule file discovery with custom paths
- Multi-project compatibility issues

### Compatibility

- Fully backward compatible with legacy `.kiro/` structure
- Default configuration matches legacy directory layout
- Existing projects work without changes
- Zero-downtime migration path

## [0.x.x] - Legacy

Previous versions as cc-sdd skill in ~/.claude/skills/cc-sdd/

### Features from Legacy

- Kiro-style spec-driven development workflow
- 3-phase approval process (Requirements → Design → Tasks)
- EARS-format requirements
- Steering system for project-wide guidance
- Specification system for feature-level development
- Validation tools (gap, design, implementation)
- Quick-start workflow with interactive mode

### Migration Notes

See [MIGRATION.md](MIGRATION.md) for detailed migration instructions from legacy skill to standardized plugin.

## Version History

### Version Numbering

- **1.x.x**: Standardized plugin with configurable structure
- **0.x.x**: Legacy skill with hardcoded `.kiro/` paths

### Upgrade Path

From legacy skill:

1. Copy `.kiro-config.default.json` to `.kiro-config.json`
2. Optionally reorganize directory structure
3. Update any custom scripts or integrations
4. Test with existing specs

No breaking changes for default configuration users.
