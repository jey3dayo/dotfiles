# mise Configuration Files

## File Structure

```
mise/
├── config.toml         # Settings-only (no tools)
├── config.ci.toml      # CI (GitHub Actions, jobs=4)
├── config.default.toml # Mac/Linux/WSL2 (75 tools, jobs=8)
├── config.windows.toml # Windows (77 tools, jobs unset)
├── config.pi.toml      # Raspberry Pi (32 tools, jobs=2)
└── tasks/              # Shared task definitions
    ├── format.toml
    ├── lint.toml
    ├── test.toml
    └── integration.toml
```

`config.toml` は OS 別ファイル（`config.default.toml` 等）より優先して適用されるため、OS 間で異なる値を置くと OS 別設定を意図せず上書きしてしまう。OS 間で異なりうる値は各 OS 別ファイル側に置く。

## Environment Detection

Environment detection is handled by `zsh/.zshenv` (Raspberry Pi 判定を含む) which exports
`MISE_CONFIG_FILE` before mise activation. `mise/config.toml` は常時ロードされ、
`MISE_CONFIG_FILE` の指す OS 別 config が追加でロードされる（additive）。

#### Automatic Configuration Selection

- CI (GitHub Actions) → `config.ci.toml`（workflow の env で指定）
- Raspberry Pi → `config.pi.toml`
- macOS/Linux/WSL2 → `config.default.toml`
- Windows → `config.windows.toml`（`windows/setup.ps1` が設定）

Note: fresh マシンでは `~/.zshenv` 配布前のため未設定。初回は
`export MISE_CONFIG_FILE="$HOME/.config/mise/config.default.toml"` を明示する（docs/setup.md 参照）。

## Tool Counts

| Environment  | Config File         | Tools | Jobs  | Notes                                        |
| ------------ | ------------------- | ----- | ----- | -------------------------------------------- |
| CI           | config.ci.toml      | 19    | 4     | Minimal toolset for Actions                  |
| Default      | config.default.toml | 106   | 8     | Full local development toolset               |
| Windows      | config.windows.toml | 84    | unset | Windows-specific toolset, uses mise defaults |
| Raspberry Pi | config.pi.toml      | 32    | 2     | Optimized (minimal npm, no cargo)            |

## Migration from Old Structure

Old: Single `config.toml` for Mac/WSL2, `config.pi.toml` for Pi
New: `config.toml` (settings-only), `config.default.toml` (Mac/Linux/WSL2), `config.windows.toml` (Windows), `config.pi.toml` (optimized), `config.ci.toml` (CI)

Migration: Automatic on shell restart after pulling changes. Windows still requires `MISE_CONFIG_FILE` to point at `config.windows.toml`.

#### Verification

```bash
# POSIX shells
echo "$MISE_CONFIG_FILE"

# PowerShell
$env:MISE_CONFIG_FILE

mise ls --json | jq 'length'  # Should match the active config count above
```

## Development

#### Common Commands

```bash
mise install             # Install all tools from active config
mise upgrade             # Update all tools
mise ls                  # List installed tools
mise outdated            # Check for updates
mise doctor              # Health check
```

#### See Also

- `.claude/rules/tools/mise.md` - Comprehensive documentation
- `nix/env-detect.nix` - Environment detection logic
- `.mise.toml` - Project-level tasks
