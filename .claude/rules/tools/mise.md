---
paths: mise/**/*, .mise.toml, scripts/setup-mise-env.sh, zsh/.zshenv, bash/.bashrc, docs/setup.md, docs/maintenance.md, docs/tools/mise.md
---

# Mise Rules

Purpose: unified tool version management with mise-en-place. Scope: config structure, npm package migration with pnpm backend, tool installation, and maintenance workflows.

## Configuration Structure

mise設定は環境別ファイルで管理されています:

### Main config: `mise/config.toml`

**内容**: 設定のみ（ツール定義なし）

- グローバル設定: `experimental`, `env_file`, `trusted_config_paths`
- **pnpmバックエンド設定**: `settings.npm.package_manager = "pnpm"` - npmバックエンドがpnpmを使用
- 環境変数定義
- **重要**: ツールは定義しない（マージによる意図しない追加を防ぐため）

### Environment-specific configs

- **`mise/config.default.toml`** - デフォルト（macOS/Linux/WSL2）
  - jobs = 8（デスクトップ/ワークステーション向け）
  - 全ツール（go, node, python, npm packages, cargo tools, CLI tools, formatters/linters）

- **`mise/config.pi.toml`** - Raspberry Pi（ARMサーバー環境）
  - jobs = 2（メモリ制約: 並列数削減でスワップ回避）
  - 最小ツールセット（goランタイム latest版を含む、npm軽量版、cargo全除外）

- **`mise/config.ci.toml`** - CI/CD（GitHub Actions最適化）
  - jobs = 4（GitHub Actions runners: 2コア）
  - CI必須ツールのみ（formatters, linters, npm packages, CLI tools）
  - 大幅に削減されたツールセットで高速インストール
  - 除外: 全language runtimes（Actions提供）、開発ツール、MCP/Claude/Cloudツール

### Directory-local: `mise.toml`

プロジェクト固有のオーバーライド（例: .mise.toml at repo root）

### Env vars: `.mise.env` or `[env]` section

環境変数定義（dotenvx 暗号化サポート）

### Config precedence

directory-local → environment-specific (via MISE_CONFIG_FILE) → user config → global defaults

## Directory Layout (mise/)

```
mise/
├── README.md              # mise 運用の概要
├── config.toml            # 共通設定のみ（ツール定義なし、env/設定）
├── config.default.toml    # macOS/Linux/WSL2 向けフル構成
├── config.pi.toml         # Raspberry Pi 向け最小構成
├── config.ci.toml         # CI/CD 向け最小構成
└── tasks/                 # mise run で使うタスク群
    ├── format.toml        # 汎用フォーマット
    ├── lint.toml          # 汎用 lint
    ├── test.toml          # テスト実行
    ├── integration.toml   # format/lint/check などの統合タスク
    └── local.toml         # ローカル専用（brew/hm/skills/更新）
```

`.mise.toml` はリポジトリルートに置き、`task_config.includes` で `mise/tasks/*.toml` を読み込む。

## Task Design (Generic vs Local)

- 汎用: `mise/tasks/{format,lint,test,integration}.toml` に集約
- ローカル専用: `mise/tasks/local.toml` に集約（Homebrew, Home Manager, skills, update など）
- 追加タスクはまず汎用に入れるか検討し、環境依存・運用系のみ `local.toml` に置く

## Variable-driven Control

`mise/config.toml` の `[env]` を使って、タスクの対象や挙動を制御する。

- `MD_GLOB`: Markdown 対象（例: `**/*.md`）
- `MD_EXCLUDES`: Markdown 除外（例: `#agents/skills`）
- `TASK_EXCLUDES`: `fd` の除外指定（例: `--exclude agents/skills`）
- `MARKDOWN_LINK_CONFIG`: `markdown-link-check` 用設定ファイル
- `YAMLLINT_CONFIG_FILE`: `yamllint` 設定ファイル
- `*_FILES` 系: 特定ファイルだけ処理（`SH_FILES`, `PY_FILES`, `LUA_FILES`, `TOML_FILES`, `BIOME_FILES`, `PRETTIER_FILES`, `YAML_FILES`）

`TASK_EXCLUDES` は汎用タスクの除外に使う。現在は `agents/skills` のみ除外し、`agents/skills-internal` は汎用 lint/format 対象に含める。

### Environment Detection

mise automatically selects the appropriate configuration based on the environment:

- **CI/CD**: Uses `mise/config.ci.toml` when `CI=true` or `GITHUB_ACTIONS=true`
- **Default (macOS/Linux/WSL2)**: Uses `mise/config.default.toml` (includes all tools)
- **Raspberry Pi**: Uses `mise/config.pi.toml` (optimized for server environment)

**Detection Method (Home Manager)**:

Environment detection is now managed by Home Manager's Nix module (`nix/env-detect.nix`), which sets `MISE_CONFIG_FILE` via `home.sessionVariables`:

- **CI**: `$CI` or `$GITHUB_ACTIONS` environment variables
- **Raspberry Pi**: ARM architecture + `/sys/firmware/devicetree/base/model` containing "Raspberry Pi"
- **Default**: All other environments (WSL2, macOS, generic Linux)

Priority: CI > Raspberry Pi > Default

The environment variable is automatically loaded via `hm-session-vars.sh` (sourced by shells). No manual configuration required.

**Note**: hadolint is included in `config.default.toml` but may fail to install on ARM environments. This is expected behavior and does not affect other tools installation.

### Environment-specific Package Exclusions

#### Raspberry Pi Optimizations (`config.pi.toml`)

サーバー/自動化環境として最適化されており、以下のパッケージを除外:

**Performance Settings**:

- `jobs = 2` (メモリ制約対応: 並列実行数削減でスワップ回避)
  - ※ config.default.toml は `jobs = 8`（デスクトップ環境向け）

**Excluded Packages**:

サーバー/自動化環境として最適化されており、以下のカテゴリを除外:

- **大容量パッケージ**: `@openai/codex` (391MB), `@playwright/mcp` (~300MB), `aws-cdk` (~150MB) 等
- **エディタ統合ツール**: LSP、TypeScript関連、`eslint_d` 等（リモート開発でローカルマシンのLSP使用）
- **GUI/ブラウザ依存ツール**: Playwright MCP、Chrome DevTools MCP 等
- **デスクトップ開発ツール**: Claude AI開発ツール（`dxt`, `dev3000`, `ccusage` 等）
- **クラウド/インフラツール**: AWS CLI、Google Clasp、gRPC関連 等
- **全cargoツール**: ARM互換性とビルド時間考慮

詳細な除外パッケージリストは `mise/config.default.toml` と `mise/config.pi.toml` の差分を参照。

**Maintained Packages**:

軽量かつサーバー運用に有用なツールのみを維持:

- **ユーティリティ**: `@antfu/ni`, `npm`, `npm-check-updates`
- **ドキュメント**: `markdown-link-check`, `markdownlint-cli2`, `textlint`
- **フォーマッター/Linter**: `actionlint`, `biome`, `prettier`, `shellcheck`, `shfmt`, `stylua`, `taplo`, `yamllint`
- **AI/Claude**: `aicommits`, `@sasazame/ccresume`, `openclaw`
- **MCP**: `@upstash/context7-mcp`, `o3-search-mcp`
- **CLI**: `eza`, `fd`, `gh`, `goimports`, `jq`, `yazi`
- **ランタイム**: `go` (latest), `node`, `python`, `pipx:uv`

具体的なパッケージバージョンは `mise/config.pi.toml` を参照。

**Expected Benefits**:

- Install time: Significantly faster (many npm packages, aws-cli, and all cargo tools excluded)
- Disk usage: Substantially reduced
- Memory usage: Reduced during installation (parallel execution control)

## Configuration Comparison

| Config              | Toolset           | Use Case                       | Performance     |
| ------------------- | ----------------- | ------------------------------ | --------------- |
| config.default.toml | Full (all tools)  | Development (macOS/Linux/WSL2) | Longer install  |
| config.pi.toml      | Minimal (server)  | Server (Raspberry Pi ARM)      | Faster install  |
| config.ci.toml      | Minimal (CI only) | CI/CD (GitHub Actions)         | Fastest install |

## Tool Categories (config.default.toml)

mise/config.default.toml は以下の 6 カテゴリで構成されています:

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

#### 環境別の取り扱い

- **Default** (`config.default.toml`): 全てのcargoツールをインストール
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

#### 環境別の取り扱い

- **Default**: 全てのCLIツールをインストール
- **Raspberry Pi**: 全てのCLIツールをインストール

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

### Phase 3: npm → pnpm バックエンド移行 (完了)

**Before**: miseのnpmバックエンドがnpmを使用
**After**: miseのnpmバックエンドがpnpmを使用（`settings.npm.package_manager = "pnpm"`）

**Implementation Details** (Completed 2026-02-03):

1. mise updated: v2025.7.17 → v2025.12.13 (to support `settings.npm.package_manager`)
2. Bootstrap process:
   - Temporarily set `package_manager = "npm"` to install pnpm itself
   - Installed `npm:pnpm@10.28.2` using npm backend
   - Switched back to `package_manager = "pnpm"`
3. npm global cleanup:
   - Removed `@openai/codex`, `aicommits`, `markdown-link-check` from npm global
   - Verified npm global is empty (only local links remain)
4. Verification: `mise install "npm:openclawd"` confirmed using pnpm backend

Benefits:

- Single source of truth for all tools
- Version pinning and reproducibility
- Cross-platform consistency
- No global npm/pnpm/bun pollution
- Automatic installation via mise hooks
- **Faster installation**: pnpmのシンボリックリンク + グローバルストア
- **Reduced disk usage**: パッケージ重複排除
- **npm:プレフィックスのまま使用可能**: 既存の設定を変更不要

## Common Commands

```bash
# List available tasks
mise tasks

# Install all tools from config
mise install

# Run generic tasks
mise run format
mise run lint
mise run check
mise run lint:links

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
- To restore: `git checkout mise/config.default.toml mise/config.pi.toml && mise install`
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

1. **Centralized Package Management**: ALL npm and Python packages MUST be declared in environment-specific configs (`mise/config.default.toml` or `mise/config.pi.toml`)
   - ❌ Never use `npm install -g`, `pnpm add -g`, `bun add -g`, or `pip install --user`
   - ❌ Never maintain separate `global-package.json` or `requirements-global.txt`
   - ✅ Always use `"npm:<package>"` or `"pipx:<package>"` in environment-specific config files
   - **Note**: `npm:` prefix is used even though pnpm is the backend (configured via `settings.npm.package_manager = "pnpm"`)
   - Rationale: Single source of truth, reproducibility, version control
2. **Global Package Manager Check**: Regularly verify no duplicate packages
   - Run `npm -g list --depth=0` - should only show local links (astro-my-profile, zx-scripts)
   - Run `ls ~/.bun/install/global/node_modules/.bin` - should be empty or minimal
   - If duplicates found, add to environment-specific config and `npm uninstall -g <package>`
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
