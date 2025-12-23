# Mise Rules

Purpose: unified tool version management with mise-en-place. Scope: config structure, npm package migration, tool installation, and maintenance workflows.

## Configuration Structure

- Main config: `mise/config.toml` defines all tools (runtimes, CLI tools, npm packages)
- Directory-local: `mise.toml` for project-specific overrides
- Env vars: `.mise.env` or `[env]` section in config.toml
- Config precedence: directory-local → user config (~/.config/mise/config.toml) → global defaults

## Tool Categories

### Runtimes (語言)

```toml
[tools]
node = "latest"          # Node.js runtime
python = "3.12"          # Python with specific version
ruby = "latest"
go = "latest"
rust = "latest"
lua = "5.1.5"            # Specific version for compatibility
```

### CLI Tools (命令行工具)

```toml
[tools]
ghq = "latest"
github-cli = "latest"
shellcheck = "latest"
yamllint = "latest"
taplo = "latest"         # TOML formatter/linter
```

### NPM Packages (npm全局包)

```toml
[tools]
"npm:@fsouza/prettierd" = "latest"
"npm:markdownlint-cli2" = "latest"
"npm:markdown-link-check" = "latest"
"npm:neovim" = "latest"
"npm:husky" = "latest"
```

## Migration from global-package.json

**Before (deprecated)**: npm global packages in `global-package.json`
**After (current)**: npm packages managed by mise with `npm:` prefix

Migration steps:

1. Convert `global-package.json` dependencies to `"npm:<package-name>" = "latest"` in `mise.toml`
2. Remove `global-package.json` file
3. Update docs to reference mise instead of npm global install
4. Run `mise install` to install all npm packages

Benefits:

- Single source of truth for all tools
- Version pinning and reproducibility
- Cross-platform consistency
- No global npm pollution

## Common Commands

```bash
# Install all tools from config
mise install

# Update all tools to latest versions
mise upgrade

# List installed tools
mise ls

# Check for outdated tools
mise outdated

# Activate mise in current shell
mise activate zsh

# Install specific tool
mise use node@20
mise use "npm:prettier@latest"

# Remove tool
mise uninstall node@18
```

## Integration Points

### Shell Integration (Zsh)

- Activated via `mise activate zsh` in `.zshrc`
- Provides PATH shims for all managed tools
- Auto-switching based on directory `.mise.toml`

### Neovim Integration

- Ensure npm packages like `neovim` and `prettierd` are in mise config
- No need for separate npm global install
- Neovim finds tools via mise-managed PATH

### Project-specific Overrides

```toml
# .mise.toml in project root
[tools]
node = "18.20.0"         # Pin specific version for project
"npm:typescript" = "5.3.3"
```

## Maintenance

### Weekly Updates

```bash
mise upgrade              # Update all tools
mise prune                # Remove unused versions
mise doctor               # Check for issues
```

### Troubleshooting

- `mise doctor` - diagnose configuration issues
- `mise which <tool>` - show which version is active
- `mise current` - show active versions in current directory
- `mise env` - display environment variables

### Backup and Restore

- Config files are tracked in dotfiles repo
- To restore: `git checkout mise/config.toml && mise install`
- Version history via git allows rollback

## Best Practices

1. **Centralized Package Management**: ALL npm and Python packages MUST be declared in `mise.toml`
   - ❌ Never use `npm install -g` or `pip install --user`
   - ❌ Never maintain separate `global-package.json` or `requirements-global.txt`
   - ✅ Always use `"npm:<package>"` or `"pipx:<package>"` in mise.toml
   - Rationale: Single source of truth, reproducibility, version control
2. **Version Pinning**: Use specific versions for project-critical tools
3. **Latest for Development Tools**: Use "latest" for CLI tools that don't affect build
4. **Document Breaking Changes**: Comment version pins with reason
5. **Regular Updates**: Run `mise upgrade` weekly to stay current
6. **Consolidation**: Prefer mise over tool-specific managers (nvm, rbenv, pyenv, etc.)

## Related Documentation

- Official docs: <https://mise.jdx.dev>
- Project-specific mise usage: `docs/setup.md`
- Maintenance workflows: `docs/maintenance.md`
