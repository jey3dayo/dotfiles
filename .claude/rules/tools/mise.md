# Mise Rules

Purpose: unified tool version management with mise-en-place. Scope: config structure, npm package migration, tool installation, and maintenance workflows.

## Configuration Structure

- Main config: `mise/config.toml` defines all tools (runtimes, CLI tools, npm packages)
- Environment-specific configs:
  - `mise/config.toml` - Default (macOS/Linux/WSL2)
  - `mise/config.pi.toml` - Raspberry Pi (excludes cargo tools and opencode for ARM compatibility)
- Directory-local: `mise.toml` for project-specific overrides
- Env vars: `.mise.env` or `[env]` section in config.toml
- Config precedence: directory-local → user config (~/.config/mise/config.toml) → global defaults

### Environment Detection

mise automatically selects the appropriate configuration based on the environment:

- **Default (macOS/Linux/WSL2)**: Uses `mise/config.toml` (includes all tools)
- **Raspberry Pi**: Uses `mise/config.pi.toml` (excludes cargo tools and opencode)

Detection happens via `scripts/setup-mise-env.sh` which sets `MISE_CONFIG_FILE` based on:

- Raspberry Pi: `/sys/firmware/devicetree/base/model` containing "Raspberry Pi"
- Default: All other environments (macOS, Linux, WSL2)

The environment detection is integrated into Zsh startup via `zsh/init/mise-env.zsh`.

**Note**: hadolint is included in `config.toml` but may fail to install on ARM environments. This is expected behavior and does not affect other tools installation.

## Tool Categories

mise/config.toml は以下の 6 カテゴリで構成されています:

### 1. Language Runtimes

```toml
[tools]
go = "1.25.5"
node = "24"
python = "3.14"
# lua/luajit は Homebrew で管理 (Neovim 依存関係のため)
```

### 2. Package Managers

```toml
[tools]
"pipx:uv" = "latest"
bun = "latest"
```

### 3. Formatters and Linters

```toml
[tools]
actionlint = "latest"
biome = "latest"
hadolint = "latest"
prettier = "latest"
shellcheck = "latest"
shfmt = "latest"
stylua = "latest"
taplo = "latest"
yamllint = "latest"
```

### 4. NPM Global Packages (Node.js グローバルパッケージ)

**完全移行完了**: 全ての npm パッケージを mise で一元管理（npm/pnpm/bun グローバルには依存しない）

```toml
[tools]
# ユーティリティ・ツール
"npm:@antfu/ni" = "latest"
"npm:corepack" = "latest"
"npm:husky" = "latest"
"npm:npm" = "latest"
"npm:npm-check-updates" = "latest"

# 開発・エディタ
"npm:@fsouza/prettierd" = "latest"
"npm:neovim" = "latest"

# プロトコルバッファ・RPC
"npm:@bufbuild/protoc-gen-es" = "latest"
"npm:@connectrpc/protoc-gen-connect-es" = "latest"

# AI・コミット支援
"npm:@openai/codex" = "latest"
"npm:aicommits" = "latest"

# ドキュメント・Lint
"npm:markdown-link-check" = "latest"
"npm:markdownlint-cli2" = "latest"
"npm:textlint" = "latest"
"npm:textlint-rule-preset-ja-technical-writing" = "latest"

# 環境変数管理
"npm:@dotenvx/dotenvx" = "latest"

# 開発ツール・Language Servers
"npm:eslint_d" = "latest"
"npm:typescript" = "latest"
"npm:typescript-language-server" = "latest"
"npm:vscode-json-languageserver" = "latest"
"npm:vscode-langservers-extracted" = "latest"
"npm:@typescript-eslint/eslint-plugin" = "latest"

# ビルドツール
"npm:esbuild" = "latest"

# ユーティリティ
"npm:zx" = "latest"

# MCP サーバー (Model Context Protocol)
"npm:@aikidosec/safe-chain" = "latest"
"npm:@benborla29/mcp-server-mysql" = "latest"
"npm:@modelcontextprotocol/server-filesystem" = "latest"
"npm:@playwright/mcp" = "latest"
"npm:@upstash/context7-mcp" = "latest"
"npm:chrome-devtools-mcp" = "latest"
"npm:exa-mcp-server" = "latest"
"npm:o3-search-mcp" = "latest"

# Claude/AI ツール
"npm:@anthropic-ai/dxt" = "latest"
"npm:@mariozechner/claude-bridge" = "latest"
"npm:@sasazame/ccresume" = "latest"
"npm:ccusage" = "latest"
"npm:dev3000" = "latest"

# クラウド・インフラ
"npm:aws-cdk" = "latest"
"npm:@google/clasp" = "latest"
"npm:@google/gemini-cli" = "latest"

# その他ツール
"npm:greptile" = "latest"
"npm:difit" = "latest"
"npm:tuyapi" = "latest"
```

### 5. Cargo-based Tools

```toml
[tools]
"cargo:bandwhich" = "latest"
"cargo:needle-cli" = "latest"
"cargo:similarity-ts" = "latest"
"cargo:wrkflw" = "latest"
```

**環境別の取り扱い**:

- **Default** (`config.toml`): 全てのcargoツールをインストール
- **Raspberry Pi** (`config.pi.toml`): cargoツールセクション自体を除外（ARM互換性考慮）

注: bat, ripgrep, hexyl, zoxide, typos-lsp は Homebrew で管理 (Brewfile 参照)

### 6. CLI Tools

```toml
[tools]
aws-cli = "latest"
eza = "latest"
fd = "latest"
"github:cli/cli" = "latest"
jq = "latest"
opencode = "latest"
yazi = "latest"
```

**環境別の取り扱い**:

- **Default**: 全てのCLIツールをインストール
- **Raspberry Pi**: `opencode` を除外（x86_64のみサポート）

## Migration History

### Phase 1: global-package.json → mise (完了)

**Before**: npm global packages in `global-package.json`
**After**: npm packages managed by mise with `npm:` prefix

### Phase 2: npm/pnpm/bun グローバル → mise (完了)

**Before**: 混在したパッケージ管理（npm グローバル 30+ パッケージ、bun グローバル 9 パッケージ）
**After**: 完全に mise で一元管理

削除実績:

- npm グローバルから 2,624 パッケージを削除（MCP サーバー、開発ツール、Language Server 等）
- bun グローバルは package.json が空で実質未使用（PATH で解決されない）
- 維持: npm グローバルのローカルリンク（astro-my-profile, zx-scripts）のみ

Benefits:

- Single source of truth for all tools
- Version pinning and reproducibility
- Cross-platform consistency
- No global npm/pnpm/bun pollution
- Automatic installation via mise hooks

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

## mise と Homebrew の使い分け

### mise で管理するツール

- **全ての開発ツール**: フォーマッター、Linter、CLI ツール
- **全ての npm/pipx パッケージ**: "npm:" または "pipx:" プレフィックス付き
- **開発用の言語ランタイム**: Node.js, Python, Go
- **理由**: バージョン固定、プロジェクト別オーバーライド、再現性

### Homebrew で管理するツール

- **Neovim とその依存関係**: lua, luajit, luarocks, libuv, tree-sitter 等
- **システムレベルのライブラリ**: 複数のツールから参照されるライブラリ
- **GUI アプリケーション**: cask で管理
- **システムツール用の言語ランタイム**: 必要な場合のみ (python@3.11, python@3.12 等)
- **理由**: システム安定性、ビルド時間削減、OS 統合

### ハイブリッド運用パターン

- **Node.js**: Homebrew 版 (システム依存関係用) + mise 版 (開発用)
- **Python**: Homebrew 版 (システムツール用) + mise 版 (開発用)
- **Rust**: Homebrew 版 (rust-analyzer と共に) のみ使用
- **Lua**: Homebrew 版 (Neovim 依存関係) のみ使用

## Best Practices

1. **Centralized Package Management**: ALL npm and Python packages MUST be declared in `mise/config.toml`
   - ❌ Never use `npm install -g`, `pnpm add -g`, `bun add -g`, or `pip install --user`
   - ❌ Never maintain separate `global-package.json` or `requirements-global.txt`
   - ✅ Always use `"npm:<package>"` or `"pipx:<package>"` in mise/config.toml
   - Rationale: Single source of truth, reproducibility, version control
2. **Global Package Manager Check**: Regularly verify no duplicate packages
   - Run `npm -g list --depth=0` - should only show local links (astro-my-profile, zx-scripts)
   - Run `ls ~/.bun/install/global/node_modules/.bin` - should be empty or minimal
   - If duplicates found, add to mise/config.toml and `npm uninstall -g <package>`
3. **Version Pinning**: Use specific versions for project-critical tools
4. **Latest for Development Tools**: Use "latest" for CLI tools that don't affect build
5. **Document Breaking Changes**: Comment version pins with reason
6. **Regular Updates**: Run `mise upgrade` weekly to stay current
7. **Consolidation**: Prefer mise over tool-specific managers (nvm, rbenv, pyenv, npm/pnpm/bun global, etc.)
8. **Avoid Duplication**: Never install the same tool in both Homebrew and mise (except hybrid runtime patterns)

## Related Documentation

- Official docs: <https://mise.jdx.dev>
- Project-specific mise usage: `docs/setup.md`
- Maintenance workflows: `docs/maintenance.md`
