# mise Configuration Files

## File Structure

```
mise/
├── config.toml         # Settings-only (no tools), 常時ロード・OS別ファイルより優先
├── config.ci.toml      # CI (GitHub Actions)
├── config.default.toml # Mac/Linux/WSL2
├── config.macos.toml   # macOS 専用（bootstrap.packages 等、MISE_ENV=macos でロード）
├── config.windows.toml # Windows
├── config.pi.toml      # Raspberry Pi
├── README.md
├── lib/                # タスクから呼ばれるシェルスクリプト
│   ├── ensure-busted.sh
│   ├── lint-shell.sh
│   ├── pre-push-check.sh
│   ├── run-restic.sh
│   ├── run-ts-tests.sh
│   └── shell-format.sh
├── local-tasks/        # ルート .mise.toml の [task_config].includes 経由でのみロードされるタスク定義
│   ├── backup.toml
│   ├── ci.toml
│   ├── env.toml
│   ├── format.toml
│   ├── headroom.toml
│   ├── integration.toml
│   ├── lint.toml
│   ├── test.toml
│   └── updates.toml
└── tasks/              # mise のグローバル tasks ディレクトリとして自動ロードされるタスク定義
    └── brewfile.toml
```

`config.toml` は OS 別ファイル（`config.default.toml` 等）より優先して適用されるため、OS 間で異なる値を置くと OS 別設定を意図せず上書きしてしまう。OS 間で異なりうる値は各 OS 別ファイル側に置く。

`mise/tasks/` と `mise/local-tasks/` の違い: `mise/tasks/` は mise のグローバル tasks ディレクトリとして自動ロードされ、どのディレクトリからでも実行できる（`brewfile:restore` 等）。`mise/local-tasks/` はリポジトリルートの `.mise.toml` の `[task_config].includes` 経由で読み込まれ、`~/.config` リポジトリ内でのみロードされる。PC メンテナンス用の backup task は、資格情報と破壊的サブコマンドを含むため local に保つ。

## Environment Detection

Environment detection is handled by `zsh/.zshenv` (Raspberry Pi 判定を含む) which exports
`MISE_CONFIG_FILE` before mise activation. `mise/config.toml` は常時ロードされ、
`MISE_CONFIG_FILE` の指す OS 別 config が追加でロードされる（additive）。

### Automatic Configuration Selection

- CI (GitHub Actions) → `config.ci.toml`（workflow の env で指定）
- Raspberry Pi → `config.pi.toml`
- macOS/Linux/WSL2 → `config.default.toml`
- Windows → `config.windows.toml`（`windows/setup.ps1` が設定）

Note: fresh マシンでは `~/.zshenv` 配布前のため未設定。初回は
`export MISE_CONFIG_FILE="$HOME/.config/mise/config.default.toml"` を明示する（docs/setup.md 参照）。

## Environments

| Environment  | Config File         | Notes                             |
| ------------ | ------------------- | --------------------------------- |
| CI           | config.ci.toml      | Minimal toolset for Actions       |
| Default      | config.default.toml | Full local development toolset    |
| Windows      | config.windows.toml | Windows-specific toolset          |
| Raspberry Pi | config.pi.toml      | Optimized (minimal npm, no cargo) |

ツール数は変動するため表にハードコードせず、以下で都度確認する:

```bash
mise ls --json | jq 'length'
```

## Migration from Old Structure

Old: Single `config.toml` for Mac/WSL2, `config.pi.toml` for Pi
New: `config.toml` (settings-only), `config.default.toml` (Mac/Linux/WSL2), `config.windows.toml` (Windows), `config.pi.toml` (optimized), `config.ci.toml` (CI)

Migration: Automatic on shell restart after pulling changes. Windows still requires `MISE_CONFIG_FILE` to point at `config.windows.toml`.

### Verification

```bash
# POSIX shells
echo "$MISE_CONFIG_FILE"

# PowerShell
$env:MISE_CONFIG_FILE

mise ls --json | jq 'length'  # 現在ロードされている config のツール数を確認
```

## Development

### Common Commands

```bash
mise install             # Install all tools from active config
mise upgrade             # Update all tools
mise ls                  # List installed tools
mise outdated            # Check for updates
mise doctor              # Health check
```

### See Also

- `.claude/rules/tools/mise.md` - Comprehensive documentation
- `zsh/.zshenv` / `scripts/env-detect.sh` - Environment detection logic
- `.mise.toml` - Project-level tasks
