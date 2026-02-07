# mise Configuration Files

## File Structure

```
mise/
├── config.toml         # Settings-only (no tools)
├── config.ci.toml      # CI (GitHub Actions, jobs=4)
├── config.default.toml # Mac/Linux/WSL2 (73 tools, jobs=8)
├── config.pi.toml      # Raspberry Pi (24 tools, jobs=2)
└── tasks/              # Shared task definitions
    ├── format.toml
    ├── lint.toml
    ├── test.toml
    └── integration.toml
```

## Environment Detection

Environment detection is handled by Home Manager (`nix/env-detect.nix`) and exported via
`home.sessionVariables` (loaded by shells through `hm-session-vars.sh`).

**Automatic Configuration Selection**:

- CI (GitHub Actions) → `config.ci.toml`
- Raspberry Pi → `config.pi.toml`
- macOS/Linux/WSL2 → `config.default.toml`

**Environment Variable**: `MISE_CONFIG_FILE` is set before mise activation by Home Manager.

## Tool Counts

| Environment  | Config File         | Tools | Jobs | Notes                                     |
| ------------ | ------------------- | ----- | ---- | ----------------------------------------- |
| CI           | config.ci.toml      | 11    | 4    | Minimal toolset for Actions               |
| Default      | config.default.toml | 73    | 8    | Full toolset (go, 46 npm, 4 cargo, 7 CLI) |
| Raspberry Pi | config.pi.toml      | 24    | 2    | Optimized (no go, minimal npm, no cargo)  |

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
- `nix/env-detect.nix` - Environment detection logic
- `nix/dotfiles-module.nix` - Home Manager wiring for `MISE_CONFIG_FILE`
- `.mise.toml` - Project-level tasks
