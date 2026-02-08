# Tool Version Management - Comprehensive Guide

This document provides detailed guidance on managing language runtimes, CLI tools, and global packages using mise as a unified tool manager.

## Core Philosophy: Centralized Package Management

**Principle:** ALL development tools and packages MUST be declared in `mise.toml` for reproducibility and version control.

### Why Centralization?

1. **Single Source of Truth**: One file tracks all dependencies
2. **Version Control**: Tools and versions committed with code
3. **Team Consistency**: Everyone uses the same tool versions
4. **Cross-Platform**: Works identically on macOS, Linux, Windows (WSL)
5. **No Global Pollution**: No accidental drift from `npm i -g` or `pip install --user`

## Configuration Structure

### Standard Layout

```toml
# mise/config.toml (or project-specific mise.toml)
[tools]
# ========================================
# Runtimes (Language Implementations)
# ========================================
node = "latest"          # Node.js runtime
python = "3.12"          # Python with specific version
ruby = "latest"
go = "latest"
rust = "latest"
lua = "5.1.5"            # Specific version for compatibility (e.g., LuaRocks/Neovim)
luajit = "latest"

# ========================================
# CLI Tools (Standalone Binaries)
# ========================================
ghq = "latest"           # Repository manager
github-cli = "latest"    # gh command
shellcheck = "latest"    # Shell script linter
yamllint = "latest"      # YAML linter
taplo = "latest"         # TOML formatter/linter

# ========================================
# NPM Global Packages
# ========================================
"npm:@bufbuild/protoc-gen-es" = "latest"
"npm:@connectrpc/protoc-gen-connect-es" = "latest"
"npm:@fsouza/prettierd" = "latest"
"npm:@openai/codex" = "latest"
"npm:aicommits" = "latest"
"npm:corepack" = "latest"
"npm:husky" = "latest"
"npm:markdown-link-check" = "latest"
"npm:markdownlint-cli2" = "latest"
"npm:neovim" = "latest"
"npm:npm" = "latest"
"npm:npm-check-updates" = "latest"
"npm:textlint" = "latest"
"npm:textlint-rule-preset-ja-technical-writing" = "latest"

# ========================================
# Python Global Packages (via pipx)
# ========================================
"pipx:black" = "latest"
"pipx:ruff" = "latest"
"pipx:poetry" = "latest"
```

### Config Hierarchy

mise supports multiple config locations with clear precedence:

1. **Project-local**: `./mise.toml` (highest priority)
2. **User global**: `~/.config/mise/config.toml`
3. **System-wide**: `/etc/mise/config.toml` (lowest priority)

**Best Practice**: Use user global config (`~/.config/mise/config.toml`) for personal tools, project-local for project-specific versions.

## Migration from global-package.json

### Step-by-Step Migration

#### Before (Deprecated Pattern)

```json
// global-package.json
{
  "name": "lib",
  "dependencies": {
    "neovim": { "version": "5.3.0", "overridden": false },
    "prettier": { "version": "3.0.0", "overridden": false },
    "typescript": { "version": "5.2.0", "overridden": false }
  }
}
```

#### After (mise Pattern)

```toml
# mise/config.toml
[tools]
"npm:neovim" = "latest"      # or specific version "5.3.0"
"npm:prettier" = "latest"
"npm:typescript" = "latest"
```

#### Migration Commands

```bash
# 1. Backup existing global packages
npm list -g --depth=0 > npm-global-backup.txt

# 2. Convert to mise.toml format (manual or scripted)
# For each package in global-package.json:
#   "package-name" → "npm:package-name" = "latest"

# 3. Add to mise/config.toml

# 4. Install via mise
mise install

# 5. Verify installation
mise ls
which prettier  # Should point to ~/.local/share/mise/installs/...

# 6. Remove old global packages (optional but recommended)
npm list -g --depth=0 --json | jq -r '.dependencies | keys[]' | xargs -I {} npm uninstall -g {}

# 7. Delete global-package.json
rm global-package.json

# 8. Update documentation
# Update any docs that reference npm install -g or global-package.json
```

### Automated Migration Script Example

```bash
#!/usr/bin/env bash
# migrate-npm-to-mise.sh

set -euo pipefail

MISE_CONFIG="${HOME}/.config/mise/config.toml"
BACKUP_FILE="npm-global-backup-$(date +%Y%m%d-%H%M%S).txt"

# Backup current global packages
echo "📦 Backing up global npm packages to ${BACKUP_FILE}..."
npm list -g --depth=0 > "${BACKUP_FILE}"

# Extract package names (exclude npm itself)
PACKAGES=$(npm list -g --depth=0 --json | jq -r '.dependencies | keys[] | select(. != "npm")')

# Generate mise config entries
echo ""
echo "📝 Generated mise.toml entries:"
echo ""
echo "# NPM Global Packages"
while IFS= read -r pkg; do
    echo "\"npm:${pkg}\" = \"latest\""
done <<< "${PACKAGES}"

echo ""
echo "⚠️  Please manually add these entries to ${MISE_CONFIG}"
echo "Then run: mise install"
```

## Tool Categories Deep Dive

### 1. Runtimes (Language Implementations)

### Characteristics:

- Provide language interpreters/compilers
- Often have ecosystem package managers (npm, pip, cargo, etc.)
- Version-sensitive for compatibility

### Examples:

```toml
[tools]
# Specific version for project compatibility
node = "18.20.0"          # LTS version
python = "3.11.5"         # Specific patch version

# Latest stable
node = "latest"
ruby = "latest"

# Version ranges (if supported)
go = "1.21"               # Latest 1.21.x
```

### Version Selection Strategy:

- **Project-local**: Pin specific versions for reproducibility
- **User global**: Use `"latest"` for personal tools
- **CI/CD**: Always pin specific versions

### 2. CLI Tools (Standalone Binaries)

### Characteristics:

- Self-contained executables
- No runtime dependencies (or bundled)
- Generally safe to use `"latest"`

### Examples:

```toml
[tools]
github-cli = "latest"     # Safe to auto-update
jq = "latest"             # JSON processor
ripgrep = "latest"        # Fast grep alternative
fd = "latest"             # Fast find alternative
bat = "latest"            # Cat with syntax highlighting
```

**Best Practice**: Use `"latest"` unless specific version required for compatibility.

### 3. NPM Global Packages

### Characteristics:

- JavaScript packages installed globally
- Require Node.js runtime
- Often provide CLI commands

**Prefix Syntax:** `"npm:<package-name>"`

### Examples:

```toml
[tools]
# Formatters/Linters
"npm:prettier" = "latest"
"npm:eslint" = "latest"
"npm:@biomejs/biome" = "latest"

# Build Tools
"npm:typescript" = "latest"
"npm:vite" = "latest"
"npm:webpack" = "latest"

# Development Tools
"npm:nodemon" = "latest"
"npm:pm2" = "latest"
"npm:http-server" = "latest"

# Scoped Packages
"npm:@angular/cli" = "latest"
"npm:@vue/cli" = "latest"
```

### Important Notes:

- Scoped packages (starting with `@`) must include the full scope
- Package names must match npm registry exactly
- Version can be specific (`"3.0.0"`), range (`"^3.0.0"`), or `"latest"`

### 4. Python Global Packages (via pipx)

### Characteristics:

- Python packages installed in isolated environments
- Uses `pipx` for isolation (similar to `npx`)
- Prevents dependency conflicts

**Prefix Syntax:** `"pipx:<package-name>"`

### Examples:

```toml
[tools]
# Formatters/Linters
"pipx:black" = "latest"
"pipx:ruff" = "latest"
"pipx:pylint" = "latest"

# Package Management
"pipx:poetry" = "latest"
"pipx:pipenv" = "latest"

# Development Tools
"pipx:ipython" = "latest"
"pipx:jupyter" = "latest"

# Documentation
"pipx:mkdocs" = "latest"
"pipx:sphinx" = "latest"
```

### Advantages of pipx:

- Each package in isolated virtual environment
- No dependency conflicts
- Automatic binary exposure in PATH

## Integration Patterns

### Shell Integration (Zsh Example)

### Setup in `.zshrc`:

```zsh
# Activate mise
eval "$(mise activate zsh)"

# Optional: Enable completions
eval "$(mise completion zsh)"

# Optional: Set mise home
export MISE_DATA_DIR="${HOME}/.local/share/mise"
export MISE_CONFIG_DIR="${HOME}/.config/mise"
```

### Benefits:

- Automatic PATH management
- Tool shimming (fake binaries that route to mise-managed versions)
- Directory-based version switching

### Neovim Integration

### Ensure tools are available:

```toml
[tools]
# Language servers and formatters Neovim needs
"npm:typescript-language-server" = "latest"
"npm:vscode-langservers-extracted" = "latest"  # HTML/CSS/JSON LSP
"npm:@fsouza/prettierd" = "latest"
"npm:neovim" = "latest"                        # Node.js client

"pipx:python-lsp-server" = "latest"
"pipx:black" = "latest"
```

### Neovim Lua Config:

```lua
-- ~/.config/nvim/lua/config/mise.lua

-- Ensure mise-managed tools are in PATH
vim.env.PATH = vim.fn.expand("~/.local/share/mise/shims") .. ":" .. vim.env.PATH

-- Verify tool availability
local function check_tool(name)
  return vim.fn.executable(name) == 1
end

-- Example usage in LSP config
if check_tool("typescript-language-server") then
  require("lspconfig").tsserver.setup({})
end
```

### CI/CD Integration

### GitHub Actions Example:

```yaml
name: CI

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install mise
        uses: jdx/mise-action@v2
        with:
          version: 2025.10.0 # Pin version for reproducibility

      - name: Install tools
        run: mise install

      - name: Verify installation
        run: mise ls

      - name: Run tests
        run: |
          # Tools installed by mise are now in PATH
          npm test
          python -m pytest
```

### GitLab CI Example:

```yaml
default:
  image: ubuntu:latest
  before_script:
    - curl https://mise.run | sh
    - export PATH="${HOME}/.local/bin:${PATH}"
    - mise install

test:
  script:
    - mise exec -- npm test
```

## Troubleshooting

### Common Issues

#### Issue 1: Tool Not Found After Installation

### Symptoms:

```bash
$ mise install
...installation succeeds...
$ which prettier
prettier not found
```

### Solutions:

```bash
# 1. Verify installation
mise ls | grep prettier

# 2. Check shim exists
ls -la ~/.local/share/mise/shims/prettier

# 3. Verify PATH contains mise shims
echo $PATH | grep mise

# 4. Reload shell or reactivate mise
eval "$(mise activate zsh)"

# 5. Use mise exec explicitly
mise exec -- prettier --version
```

#### Issue 2: Version Conflict with System Tools

### Symptoms:

```bash
$ which node
/usr/bin/node  # System version, not mise version

$ node --version
v14.0.0  # Old system version

$ mise current node
20.0.0  # mise thinks it's using v20
```

### Solutions:

```bash
# 1. Check PATH order
echo $PATH
# mise shims should come FIRST

# 2. Fix PATH in shell config (.zshrc)
# Ensure mise activation is AFTER any other PATH modifications
export PATH="/usr/local/bin:$PATH"  # System paths
eval "$(mise activate zsh)"         # mise shims (should be last)

# 3. Reload shell
exec zsh

# 4. Verify
which node  # Should now point to ~/.local/share/mise/...
```

#### Issue 3: NPM Package Command Not Found

### Symptoms:

```bash
$ mise install "npm:prettier"
...succeeds...
$ prettier --version
prettier: command not found
```

### Solutions:

```bash
# 1. Check if binary name differs from package name
npm view prettier bin
# Output: { prettier: 'bin/prettier.cjs' }

# 2. Verify mise created shim
ls -la ~/.local/share/mise/shims/ | grep prettier

# 3. Try mise exec
mise exec -- prettier --version

# 4. Reinstall with correct package name
mise uninstall "npm:prettier"
mise install "npm:prettier@latest"

# 5. For scoped packages, ensure @ is included
mise install "npm:@angular/cli"
```

#### Issue 4: Python pipx Package Issues

### Symptoms:

```bash
$ mise install "pipx:black"
Error: pipx backend not available
```

### Solutions:

```bash
# 1. Ensure pipx is installed
mise install pipx

# 2. Verify pipx works
pipx --version

# 3. Reinstall package
mise install "pipx:black"

# 4. Check pipx environment
pipx list
```

### Performance Issues

#### Slow Shell Startup

### Diagnosis:

```bash
# Benchmark shell startup
time zsh -i -c exit

# Profile mise activation
time eval "$(mise activate zsh)"
```

### Optimization:

```zsh
# ~/.zshrc

# Option 1: Lazy load mise
if command -v mise &>/dev/null; then
    eval "$(mise activate zsh --shims)"  # Faster, only adds shims to PATH
fi

# Option 2: Cache mise activation (advanced)
MISE_CACHE="${HOME}/.cache/mise-activation.zsh"
if [[ ! -f "${MISE_CACHE}" ]] || [[ ~/.config/mise/config.toml -nt "${MISE_CACHE}" ]]; then
    mise activate zsh > "${MISE_CACHE}"
fi
source "${MISE_CACHE}"
```

## Best Practices Checklist

### Configuration

- [ ] Use `~/.config/mise/config.toml` for personal global tools
- [ ] Use project `./mise.toml` for project-specific versions
- [ ] Pin versions in projects, use `"latest"` for personal tools
- [ ] Group tools by category with comments
- [ ] Alphabetize within categories for maintainability

### Package Management

- [ ] Declare ALL npm packages with `"npm:"` prefix
- [ ] Declare ALL Python packages with `"pipx:"` prefix
- [ ] Remove `global-package.json` and `requirements-global.txt`
- [ ] Never use `npm install -g` or `pip install --user`
- [ ] Document any exceptions with clear rationale

### Version Control

- [ ] Commit `mise.toml` or `mise/config.toml` to git
- [ ] Add `.mise.lock` if using experimental lockfile feature
- [ ] Update `.gitignore` to exclude `node_modules/`, `venv/`, etc.
- [ ] Document tool requirements in project README

### Team Collaboration

- [ ] Onboard team with `mise install` in setup docs
- [ ] Pin critical tool versions for consistency
- [ ] Document any platform-specific tool requirements
- [ ] Include mise version in CI/CD config

### Maintenance

- [ ] Run `mise upgrade` regularly (weekly/monthly)
- [ ] Review `mise outdated` for updates
- [ ] Test updates before committing version bumps
- [ ] Keep mise itself updated: `mise self-update`

## Advanced Patterns

### Task Aliases with Tool Management

Combine tool management with task automation:

```toml
# ~/.config/mise/config.toml

[tools]
node = "22"
"npm:prettier" = "latest"
"npm:eslint" = "latest"

[tasks.format]
description = "Format code"
run = "prettier --write ."

[tasks.lint]
description = "Lint code"
run = "eslint ."

[tasks.format-check]
description = "Check formatting"
run = "prettier --check ."

[tasks.ci]
description = "CI pipeline"
depends = ["format-check", "lint"]
```

### Usage:

```bash
mise run format      # Uses mise-managed prettier
mise run lint        # Uses mise-managed eslint
mise run ci          # Runs both checks in parallel
```

### Directory-Specific Tool Overrides

Use project-local config to override user global settings:

```toml
# ~/projects/legacy-app/mise.toml
[tools]
node = "14.21.0"  # Override global node version
"npm:typescript" = "4.9.5"  # Specific old version

# Inherits all other tools from ~/.config/mise/config.toml
```

### Conditional Tool Installation

Use mise hooks for conditional tool loading:

```toml
# mise.toml
[tools]
node = "latest"
"npm:aws-cdk" = "latest"  # Only needed for AWS projects

[hooks]
# Custom hook to warn if AWS tools missing
enter = "~/.config/mise/hooks/check-aws-tools.sh"
```

```bash
#!/usr/bin/env bash
# ~/.config/mise/hooks/check-aws-tools.sh

if [[ -f "cdk.json" ]] && ! mise current "npm:aws-cdk" &>/dev/null; then
    echo "⚠️  This project uses AWS CDK. Run: mise install"
fi
```

## Related Resources

- **Official Docs**: <https://mise.jdx.dev>
- **Tool Registry**: <https://mise.jdx.dev/registry.html>
- **GitHub**: <https://github.com/jdx/mise>
- **Community**: <https://github.com/jdx/mise/discussions>

## See Also

- `best-practices.md` - Task runner best practices
- `config-templates.md` - Common configuration templates
- `current-patterns.md` - Real-world usage patterns from dotfiles
