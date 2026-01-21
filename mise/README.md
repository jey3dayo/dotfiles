# mise Configuration Files

## File Structure

```
mise/
├── config.toml         # Settings-only (no tools)
├── config.default.toml # Mac/Linux/WSL2 (73 tools, jobs=8)
├── config.pi.toml      # Raspberry Pi (24 tools, jobs=2)
└── tasks/              # Shared task definitions
    ├── format.toml
    ├── lint.toml
    ├── test.toml
    └── integration.toml
```

## Environment Detection

Environment detection is handled by `scripts/setup-mise-env.sh` (sourced in `zsh/.zshenv`).

**Automatic Configuration Selection**:
- Raspberry Pi → `config.pi.toml`
- macOS/Linux/WSL2 → `config.default.toml`

**Environment Variable**: `MISE_CONFIG_FILE` is set before mise activation.

## Tool Counts

| Environment | Config File | Tools | Jobs | Notes |
|-------------|-------------|-------|------|-------|
| Default | config.default.toml | 73 | 8 | Full toolset (go, 46 npm, 4 cargo, 7 CLI) |
| Raspberry Pi | config.pi.toml | 24 | 2 | Optimized (no go, minimal npm, no cargo) |

## Migration from Old Structure

**Old**: Single `config.toml` for Mac/WSL2, `config.pi.toml` for Pi
**New**: `config.toml` (settings-only), `config.default.toml` (full tools), `config.pi.toml` (optimized)

**Migration**: Automatic on shell restart after pulling changes. No manual steps required.

**Verification**:
```bash
echo $MISE_CONFIG_FILE
mise ls --json | jq 'length'  # Should be 73 (default) or 24 (pi)
```

## Development

**Common Commands**:
```bash
mise install             # Install all tools from active config
mise upgrade             # Update all tools
mise ls                  # List installed tools
mise outdated            # Check for updates
mise doctor              # Health check
```

**See Also**:
- `.claude/rules/tools/mise.md` - Comprehensive documentation
- `scripts/setup-mise-env.sh` - Environment detection logic
- `.mise.toml` - Project-level tasks
