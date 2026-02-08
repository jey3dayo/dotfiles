# Tag Systems Reference

This document provides detailed tag system definitions for different project types.

## Common Tag Prefixes

All projects use these standard tag prefix formats:

- `category/` - Document category (documentation, guide, api, etc.)
- `audience/` - Target readers (developer, user, beginner, advanced, etc.)
- `environment/` - Environment context (macos, linux, production, etc.)
- `layer/` - Architecture layer (project-specific)
- `tool/` - Specific tool or technology

## Project-Specific Tag Systems

### dotfiles Project

**Required Tags**: `category/`, `tool/`, `layer/`, `environment/`, `audience/`

**Category Tags** (`category/`):

- `category/shell` - Shell (Zsh) configuration and optimization
- `category/editor` - Editor (Neovim) related
- `category/terminal` - Terminal (WezTerm, Tmux, Alacritty) related
- `category/git` - Git workflow and tool integration
- `category/performance` - Performance optimization and measurement
- `category/integration` - Cross-tool integration
- `category/configuration` - Configuration file management
- `category/guide` - Implementation guides
- `category/reference` - Reference documentation
- `category/maintenance` - Maintenance procedures
- `category/documentation` - Documentation management

**Tool Tags** (`tool/`):

- `tool/zsh` - Zsh shell (1.1s startup target)
- `tool/nvim` - Neovim editor (<100ms startup)
- `tool/wezterm` - WezTerm terminal
- `tool/tmux` - Tmux multiplexer
- `tool/git` - Git version control
- `tool/fzf` - Fuzzy Finder integration
- `tool/ssh` - SSH configuration
- `tool/mise` - Version management tool
- `tool/homebrew` - Package management

**Layer Tags** (`layer/`) - dotfiles-specific:

- `layer/core` - Core settings (Shell, Git)
- `layer/tool` - Tool-specific settings (Editor, Terminal)
- `layer/support` - Cross-cutting concerns (Performance, Integration)

**Environment Tags** (`environment/`):

- `environment/macos` - macOS specific
- `environment/linux` - Linux compatible
- `environment/cross-platform` - Platform independent

**Audience Tags** (`audience/`):

- `audience/developer` - For developers
- `audience/ops` - For operations staff
- `audience/beginner` - For beginners
- `audience/advanced` - For advanced users

**Special Requirements**:

- Performance impact notation required for `docs/tools/zsh.md` and `docs/tools/nvim.md`
- 3 core technologies (Zsh, Neovim, WezTerm) require ⭐⭐⭐⭐ detail level
- Monthly update frequency for core tech docs

### pr-labeler Project

**Required Tags**: `category/`, `audience/`
**Optional Tags**: `environment/`

**Category Tags** (`category/`):

- `category/documentation` - Documentation management
- `category/action` - GitHub Action definition and configuration
- `category/api` - GitHub API and Octokit related
- `category/development` - Development guide and configuration
- `category/testing` - Test strategy and implementation
- `category/deployment` - Release and deployment
- `category/cicd` - CI/CD and GitHub Actions
- `category/security` - Security and authentication
- `category/operations` - Operations and maintenance
- `category/cc-sdd` - cc-sdd related documentation

**Audience Tags** (`audience/`):

- `audience/developer` - For developers
- `audience/contributor` - For contributors
- `audience/user` - For end users
- `audience/maintainer` - For maintainers

**Environment Tags** (`environment/`):

- `environment/development` - Development environment
- `environment/testing` - Testing environment
- `environment/production` - Production environment (GitHub Actions runtime)

**Special Features**:

- cc-sdd workflow integration with `.specify/` directory
- Status tracking: ✅ 作成済, 📝 計画中, ⏳ 随時更新
- GitHub Actions specific documentation

### caad-terraform-infra Project

**Required Tags**: `category/`, `audience/`, `environment/`

**Category Tags** (`category/`):

- `category/infrastructure` - Terraform/VPN/AWS configuration
- `category/security` - SAML authentication/certificates/IAM
- `category/operations` - Operations procedures and maintenance
- `category/deployment` - Deployment
- `category/cicd` - GitHub Actions/OIDC
- `category/architecture` - Architecture design
- `category/documentation` - Documentation management

**Audience Tags** (`audience/`):

- `audience/developer` - Developers
- `audience/operations` - Operations staff
- `audience/sre` - SRE team
- `audience/architect` - System architects
- `audience/system-admin` - System administrators

**Environment Tags** (`environment/`):

- `environment/caad-aws-ndev` - Nearshore environment
- `environment/caad-aws` - CAAD environment
- `environment/shared` - Shared/common

**Special Features**:

- Multi-account AWS environment support
- mise task integration for linting and formatting
- Comprehensive directory structure (features/, security/, infrastructure/, cicd/, operations/)
- markdown-link-check integration

## Tag Format

### Metadata Block Format

All projects use this standard format:

```markdown
# [Icon] [Title]

**最終更新**: YYYY-MM-DD
**対象**: [Target Audience]
**タグ**: `category/value` `audience/value` [additional tags]
```

### Tag Separator

- **dotfiles & pr-labeler**: Comma-separated backticked tags
  - Example: `` `category/shell`, `tool/zsh`, `layer/core` ``

- **caad-terraform-infra**: Space-separated backticked tags
  - Example: `` `category/infrastructure` `audience/developer` `environment/shared` ``

## Validation Rules

### Minimum Requirements

All projects require at minimum:

- 1 `category/` tag
- 1 `audience/` tag

### Project-Specific Requirements

**dotfiles**:

- Must include: `category/`, `tool/`, `layer/`, `environment/`, `audience/`

**pr-labeler**:

- Must include: `category/`, `audience/`

**caad-terraform-infra**:

- Must include: `category/`, `audience/`, `environment/`

### Tag Value Validation

- Only use predefined tag values for each project
- Unknown tags should be flagged for review
- New tag values require updating project's documentation-guidelines.md
