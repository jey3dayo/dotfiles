# Configuration Templates

This document provides configuration templates for documentation management.

## .docs-config.json

Project-specific documentation configuration file placed in project root.

### dotfiles Project Template

```json
{
  "project_type": "dotfiles",
  "required_tags": [
    "category/",
    "tool/",
    "layer/",
    "environment/",
    "audience/"
  ],
  "size_limits": {
    "ideal": 300,
    "acceptable": 500,
    "warning": 1000,
    "maximum": 2000
  },
  "custom_rules": {
    "performance_impact_required": ["docs/tools/zsh.md", "docs/tools/nvim.md"],
    "core_technologies": ["zsh", "nvim", "wezterm"],
    "detail_level_required": "⭐⭐⭐⭐",
    "update_frequency": {
      "core_tech": "monthly",
      "additional_tools": "quarterly"
    }
  },
  "tag_separator": ", ",
  "maturity_levels": ["Draft", "Review", "Stable", "Production"]
}
```

### pr-labeler Project Template

```json
{
  "project_type": "pr-labeler",
  "required_tags": ["category/", "audience/"],
  "optional_tags": ["environment/"],
  "size_limits": {
    "ideal": 300,
    "acceptable": 500,
    "warning": 1000
  },
  "custom_rules": {
    "cc_sdd_integration": true,
    "specify_directory": ".specify/",
    "status_tracking": {
      "created": "✅ 作成済",
      "planned": "📝 計画中",
      "auto_updated": "⏳ 随時更新"
    }
  },
  "tag_separator": ", "
}
```

### caad-terraform-infra Project Template

```json
{
  "project_type": "terraform-infra",
  "required_tags": ["category/", "audience/", "environment/"],
  "size_limits": {
    "ideal": 500,
    "acceptable": 1000,
    "warning": 2000
  },
  "custom_rules": {
    "multi_account": true,
    "environments": ["caad-aws-ndev", "caad-aws", "shared"],
    "mise_integration": true,
    "directory_structure": [
      "features/",
      "security/",
      "infrastructure/",
      "cicd/",
      "operations/"
    ]
  },
  "tag_separator": " ",
  "tools": {
    "linter": "mise lint",
    "formatter": "mise format",
    "link_checker": "markdown-link-check"
  }
}
```

### Generic Project Template

```json
{
  "project_type": "generic",
  "required_tags": ["category/", "audience/"],
  "size_limits": {
    "ideal": 300,
    "acceptable": 500,
    "warning": 1000
  },
  "tag_separator": ", "
}
```

## .markdown-link-check.json

Link validation configuration for markdown-link-check tool.

### Basic Template

```json
{
  "ignorePatterns": [
    {
      "pattern": "^http://localhost"
    },
    {
      "pattern": "^http://127.0.0.1"
    }
  ],
  "replacementPatterns": [],
  "httpHeaders": [],
  "timeout": "5s",
  "retryOn429": true,
  "retryCount": 3,
  "fallbackRetryDelay": "30s",
  "aliveStatusCodes": [200, 206]
}
```

### Advanced Template with GitHub Support

```json
{
  "ignorePatterns": [
    {
      "pattern": "^http://localhost"
    },
    {
      "pattern": "^http://127.0.0.1"
    },
    {
      "comment": "Ignore relative links",
      "pattern": "^\\."
    }
  ],
  "replacementPatterns": [
    {
      "pattern": "^/",
      "replacement": "https://github.com/your-org/your-repo/blob/main/"
    }
  ],
  "httpHeaders": [
    {
      "urls": ["https://github.com"],
      "headers": {
        "Accept": "text/html"
      }
    }
  ],
  "timeout": "10s",
  "retryOn429": true,
  "retryCount": 5,
  "fallbackRetryDelay": "60s",
  "aliveStatusCodes": [200, 206, 301, 302]
}
```

## Metadata Templates

### Standard Metadata Block

```markdown
# 📚 [Document Title]

**最終更新**: YYYY-MM-DD
**対象**: [Target Audience]
**タグ**: `category/value`, `audience/value`, [additional tags]

## 📋 Overview

Brief description of the document's purpose and scope.
```

### dotfiles Metadata Example

```markdown
# 🐚 Zsh Configuration & Optimization

**最終更新**: 2025-10-21
**対象**: 開発者・上級者
**タグ**: `category/shell`, `tool/zsh`, `layer/core`, `environment/cross-platform`, `audience/advanced`

## Performance Impact

- **Startup Time**: Target 1.1s (current: 1.05s)
- **Memory Usage**: ~50MB with all plugins
- **Measurement**: `zsh-benchmark`
```

### pr-labeler Metadata Example

```markdown
# 📝 API Reference

**最終更新**: 2025-10-21
**対象**: 開発者
**タグ**: `category/api`, `audience/developer`

## ステータス

📝 計画中
```

### caad-terraform-infra Metadata Example

```markdown
# 🔐 VPN証明書管理ガイド

**最終更新**: 2025-10-21
**対象**: 開発者、運用担当者
**タグ**: `category/security` `category/operations` `audience/developer` `audience/operations` `environment/shared`
```

## Document Icons

Standard emoji icons for document types:

- 📚 Documentation/Guidelines
- 🎯 Project Overview
- 🚀 Quick Start/Setup
- 📝 Specification/Design
- 🛠 Development/Implementation
- 🧪 Testing
- 📦 Release/Deployment
- 🔧 Configuration
- 🐛 Troubleshooting
- 🤝 Contribution
- 📊 Metrics/Analysis
- 🔐 Security
- 🐚 Shell/Terminal
- 💻 Editor/IDE
- 🌐 Network/Infrastructure
- ⚡ Performance
- 🔄 CI/CD

## Usage

### 1. Create .docs-config.json

Place in project root directory:

```bash
# For dotfiles project
cp references/config-templates.md .docs-config.json
# Edit to match project needs
```

### 2. Create .markdown-link-check.json

For link validation:

```bash
cp references/config-templates.md .markdown-link-check.json
```

### 3. Use Metadata Template

When creating new documentation:

1. Copy appropriate metadata template
2. Replace placeholders with actual values
3. Ensure required tags are included
4. Add appropriate icon

### 4. Validate Configuration

Run validation to ensure configuration is correct:

```bash
# Check documentation compliance
# (specific validation commands depend on project setup)
```

## Best Practices

### Configuration File Location

- `.docs-config.json` → Project root
- `.markdown-link-check.json` → Project root
- Documentation → `docs/` or `./docs/` directory

### Tag Consistency

- Use project-specific tag separator (comma or space)
- Ensure all required tags present
- Follow project's tag value vocabulary

### Update Frequency

- Update `最終更新` on every document change
- Review tags quarterly
- Validate links regularly (CI/CD integration recommended)

### Size Management

- Monitor document size against configured limits
- Split documents before reaching maximum
- Maintain cross-references when splitting
