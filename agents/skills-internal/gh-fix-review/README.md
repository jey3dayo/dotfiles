# PR Review Automation Skill

Automated GitHub PR review comment processing with customizable classification and fix workflows.

## Overview

This skill automatically classifies and processes GitHub Pull Request review comments from CodeRabbit, human reviewers, and other bots. It supports:

- Priority classification (Critical/High/Major/Minor)
- Category classification (Security/Performance/Bug/Style/etc.)
- Automated fixes with quality gates
- Progress tracking with TodoWrite integration
- Customizable configuration per project

## Quick Start

### 1. Basic Usage

```bash
# Start PR review automation
/review --fix-pr

# Specify PR number
/review --fix-pr 123

# Filter by priority
/review --fix-pr --priority critical,high

# Dry run mode
/review --fix-pr --dry-run
```

### 2. Configuration

Create a `.pr-review-config.json` file in your project root or home directory:

```json
{
  "priorities": {
    "critical": {
      "keywords": ["critical", "bug", "security"],
      "emoji": "🔴"
    }
  },
  "categories": {
    "security": {
      "keywords": ["security", "vulnerability"],
      "description": "Security issues"
    }
  }
}
```

## Features

### Configurable Priority Classification

Define custom keywords for each priority level:

- **Critical**: Security vulnerabilities, crashes, data loss
- **High**: Important bugs, blocking issues
- **Major**: Improvements, optimizations
- **Minor**: Style fixes, typos

### Flexible Category System

Classify comments into categories:

- Security
- Performance
- Bug
- Style
- Refactor
- Test
- Documentation
- Accessibility
- Internationalization

### Bot Integration

Configure trusted review bots:

- CodeRabbit AI
- GitHub Actions
- Dependabot
- Renovate
- SonarCloud
- Custom bots

### Quality Gates

Automated quality checks before accepting fixes:

- Type checking
- Linting
- Testing
- Auto-rollback on failure

## Configuration Files

### Loading Priority

1. Project root: `./.pr-review-config.json` (highest priority)
2. Home directory: `~/.pr-review-config.json`
3. Default configuration (built-in)

### Example Configurations

- `examples/default-config.json` - Full default configuration
- `examples/minimal-config.json` - Minimal essential settings
- `examples/security-focused.json` - Security-focused project
- `examples/performance-focused.json` - Performance-focused project

## Documentation

- [SKILL.md](SKILL.md) - Complete skill documentation
- [references/configuration.md](references/configuration.md) - Configuration reference
- [references/index.md](references/index.md) - Quick reference guide

## Configuration Schema

JSON Schema is available at `.pr-review-config.schema.json` for IDE validation and auto-completion.

## Requirements

- GitHub CLI (`gh`) installed and authenticated
- Access to PR review comments via GitHub API
- Claude Code command system

## Installation

This skill is available in the Claude Code marketplace:

```bash
# Install from marketplace
claude marketplace install gh-fix-review
```

Or manually place in your Claude Code plugins directory:

```bash
~/.claude/skills/gh-fix-review/
```

## Project-Specific Configuration

Create a project-specific configuration:

```bash
# Copy default config
cp .pr-review-config.default.json .pr-review-config.json

# Edit for your project
vim .pr-review-config.json

# Optionally add to .gitignore if not sharing
echo ".pr-review-config.json" >> .gitignore
```

## Customization Examples

### Security-Focused Project

```json
{
  "priorities": {
    "critical": {
      "keywords": ["security", "vulnerability", "exploit"]
    }
  },
  "quality_gates": {
    "test": true
  }
}
```

### Performance-Focused Project

```json
{
  "priorities": {
    "high": {
      "keywords": ["performance", "slow", "optimization"]
    }
  },
  "categories": {
    "performance": {
      "keywords": ["cache", "lazy load", "bundle size"]
    }
  }
}
```

## Integration

This skill integrates with:

- **GitHub CLI** - PR and review comment retrieval
- **TodoWrite** - Progress tracking
- **Quality Gates** - Automated quality checks
- **Agent Selector** - Optimal agent selection for fixes

## Generalization Features

This skill has been generalized from CAAD-specific implementation:

1. **Externalized Keywords** - No hardcoded rules
2. **Dynamic Categories** - Custom category definitions
3. **Bot Configuration** - Flexible bot handling
4. **Path Customization** - Configurable file paths
5. **Quality Gate Control** - Adjustable quality checks

## Support

For issues, questions, or contributions:

- Check [references/configuration.md](references/configuration.md) for troubleshooting
- Validate JSON with `jq '.' .pr-review-config.json`
- Verify GitHub CLI auth with `gh auth status`

## License

Part of Claude Code marketplace.

## Related Resources

- [GitHub CLI Documentation](https://cli.github.com/manual/)
- [CodeRabbit Documentation](https://docs.coderabbit.ai/)
- [Claude Code Documentation](https://docs.anthropic.com/claude/docs)
