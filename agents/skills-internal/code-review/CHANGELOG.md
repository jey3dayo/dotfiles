# Changelog

All notable changes to the Code Review plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2025-01-15

### Added

- **Configuration-based project detection system**
  - JSON schema validation for configuration files
  - Priority-based detection with pluggable rules
  - Multiple configuration sources (project-specific, user, built-in)

- **Flexible detector types**
  - `file_exists`: Check file existence
  - `file_pattern`: Glob pattern matching
  - `file_content`: Content pattern matching
  - `package_dependency`: Package.json dependency checking
  - `directory_structure`: Directory structure verification

- **Custom rules support**
  - Project-specific validation rules in configuration
  - Arbitrary custom rule definitions
  - Structured rule objects (e.g., layer separation)

- **Built-in project types**
  - Next.js Fullstack (priority 100)
  - Go Clean Architecture (priority 95)
  - Go API (priority 90)
  - React SPA (priority 80)
  - TypeScript Node.js (priority 70)
  - Generic Project fallback (priority 0)

- **Example configurations**
  - CAAD Loca project template with Result<T,E> pattern
  - Generic custom project template
  - Multiple scenario examples in documentation

- **Comprehensive documentation**
  - README.md with quick start guide
  - SKILL.md with full API reference
  - MIGRATION.md for v1.x users
  - Schema documentation

### Changed

- **Project detection abstracted from code to configuration**
  - Removed hardcoded detection logic from `detailed-mode.md`
  - Moved CAAD Loca specific rules to example configuration
  - Evaluation weights now configurable per project

- **Skill integration now configuration-driven**
  - Skills specified in configuration with priority and focus
  - Technology stack identifiers moved to config

- **Evaluation guidelines referenced, not embedded**
  - Guidelines loaded from paths specified in configuration
  - Support for project-specific guideline files

### Deprecated

- v1.x hardcoded project detection (still works via built-in defaults)
- Direct embedding of CAAD Loca rules in code

### Removed

- None (backward compatible)

### Fixed

- Project detection conflicts (now resolved by priority system)
- Inability to customize evaluation for specific projects
- Hardcoded project-specific logic scattered across files

### Security

- JSON schema validation prevents malformed configurations
- No execution of user-provided code (configuration only)

## [1.x] - Legacy

### Features

- Hardcoded project detection
- Fixed evaluation criteria per project type
- CAAD Loca specific patterns embedded
- Basic skill integration
- ⭐️ 5-level evaluation system

### Limitations

- No customization without code changes
- Project-specific rules mixed with core logic
- Limited extensibility

---

## Migration Notes

### From 1.x to 2.0

**For standard projects**: No action required. Built-in defaults provide same behavior.

**For custom projects**: Create `.code-review-config.json` in project root.

See `MIGRATION.md` for detailed migration guide.

### Backward Compatibility

v2.0 maintains backward compatibility through built-in default configurations that replicate v1.x behavior:

- Same project types detected
- Same evaluation weights
- Same skill integration patterns

Custom projects using CAAD Loca patterns should migrate to configuration file.

---

## Roadmap

### [2.1.0] - Planned

- Custom detector implementations
- Custom evaluator plugins
- Configuration inheritance
- Team-wide configuration templates

### [2.2.0] - Future

- Visual configuration editor
- Configuration validation CLI
- Performance metrics in evaluation
- Integration with external code quality tools

### [3.0.0] - Vision

- Plugin ecosystem for detectors and evaluators
- AI-powered custom rule generation
- Real-time configuration validation in editors
- Cloud-based configuration sharing

---

## Contributing

To contribute to this plugin:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with example projects
5. Submit a pull request

For bugs and feature requests, open an issue in the repository.

---

## License

Part of Claude Code Marketplace - Dev Tools Collection

---

## Acknowledgments

- Original code-review skill design
- CAAD Loca project for Clean Architecture patterns
- Community feedback and feature requests
