# Mise Configuration Reference

最終更新: 2026-06-25
対象: 開発者
タグ: `category/configuration`, `tool/mise`, `layer/tool`, `environment/cross-platform`, `audience/developer`

Claude Rules: [.claude/rules/tools/mise.md](../../.claude/rules/tools/mise.md)
親ドキュメント: [Mise Reference](mise.md)

## Tool Categories (shared + workstation + config.default.toml)

通常の default 環境の effective toolset は `mise/config.shared.toml`、`mise/config.workstation.toml`、`mise/config.default.toml` の additive な構成です。default / Windows 間で完全に同じ key/value は workstation overlay に、default / Windows / Pi の 3 者間で完全に同じ key/value は shared overlay に集約し、各 OS 別ファイルには固有または異なる宣言だけを残します。CI は `config.ci.toml` 単独の最小構成です。

### Workstation overlay (`config.workstation.toml`)

`MISE_ENV` に `workstation` が含まれる開発機（macOS/Linux/WSL2 と Windows）でロードされる共通 tools です。Pi と CI ではロードしません。

```toml
[tools]
# Language Runtimes
python = "3.14"
rust = "stable"

# Package Managers
bun = "latest"

# NPM Global Packages
"npm:npm" = "latest"
"npm:agent-browser" = "latest"
"npm:dev-browser" = "latest"
"npm:@fsouza/prettierd" = "latest"
"npm:neovim" = "latest"
"npm:@bufbuild/protoc-gen-es" = "latest"
"npm:@connectrpc/protoc-gen-connect-es" = "latest"
"npm:clawdbot" = "latest"
"npm:vibe-kanban" = "latest"
"npm:eslint_d" = "latest"
"npm:typescript" = "latest"
"npm:vscode-langservers-extracted" = "latest"
"npm:@typescript-eslint/eslint-plugin" = "latest"
"npm:esbuild" = "latest"
"npm:zx" = "latest"

# MCP サーバー
"npm:@aikidosec/safe-chain" = "latest"
"npm:@benborla29/mcp-server-mysql" = "latest"
"npm:@modelcontextprotocol/server-filesystem" = "latest"
"npm:@playwright/mcp" = "latest"
"npm:exa-mcp-server" = "latest"

# Claude/AI ツール
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

# Rust CLI
"cargo:bandwhich" = "latest"
"cargo:needle-cli" = "0.15.0"
"cargo:similarity-ts" = "0.5.0"
"cargo:wrkflw" = "0.8.0"
"cargo:starship" = "latest"

# CLI Tools
delta = "latest"
"pipx:apm-cli" = "0.28.0"
bat = "latest"
fzf = "latest"
lazygit = "latest"
ripgrep = "latest"
usage = "latest"
zoxide = "latest"
"aqua:evilmartians/lefthook" = "latest"
```

### 1. Language Runtimes

```toml
[tools]
deno = "latest"
go = "latest"
node = "lts"
julia = "latest"
# lua/luajit は Homebrew で管理 (Neovim 依存関係のため)
```

### 2. Package Managers

```toml
[tools]
"github:astral-sh/uv" = "latest"
```

`pipx:uv` は uv 自身を uvx 経由で入れる自己参照構造になり、uv 更新時に `uv tool install uv` が停滞するため避ける。`config.windows.toml` / `config.ci.toml` も同じ理由で `"github:astral-sh/uv"` に統一済み。

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

完全移行完了: 全ての npm パッケージを mise で一元管理（npm/pnpm/bun グローバルには依存しない）

```toml
[tools]
# ユーティリティ・ツール
"npm:@antfu/ni" = "latest"
"npm:corepack" = "latest"
"npm:npm-check-updates" = "latest"

# 開発・エディタ

# プロトコルバッファ・RPC

# AI・コミット支援
"npm:aicommits" = "latest"
"npm:opencommit" = "latest"

# ドキュメント・Lint
"npm:dbdocs" = "latest"
"npm:@google/design.md" = "latest"
"npm:markdown-link-check" = "latest"
"npm:markdownlint-cli2" = "latest"
"npm:textlint" = "latest"
"npm:textlint-rule-preset-ja-technical-writing" = "latest"

# 環境変数管理
"npm:@dotenvx/dotenvx" = "latest"

# 開発ツール・Language Servers
"npm:tsx" = "latest"
"npm:typescript-language-server" = "latest"
"npm:vscode-json-languageserver" = "latest"

# ビルドツール

# ユーティリティ

# MCP サーバー (Model Context Protocol)
"npm:@upstash/context7-mcp" = "latest"
"npm:chrome-devtools-mcp" = "latest"
"npm:o3-search-mcp" = "latest"

# Claude/AI ツール
"npm:@anthropic-ai/dxt" = "latest"
"npm:@sasazame/ccresume" = "latest"

# クラウド・インフラ

# その他ツール
```

### 5. Cargo-based Tools

```toml
[tools]
"cargo:similarity-css" = "0.5.0"
"cargo:tree-sitter-cli" = { version = "0.26.9", default-features = "false" }
```

#### 環境別の取り扱い

- Default (`config.default.toml`): 全てのcargoツールをインストール
- Raspberry Pi (`config.pi.toml`): cargoツールセクション自体を除外（ARM互換性考慮）

Go/Cargo 由来の CLI は Brewfile ではなく mise の `[tools]` で管理します。Homebrew は OS/GUI/ネイティブ formula の正本です。

### 6. CLI Tools

```toml
[tools]
atuin = "latest"
aws-cli = "latest"
buf = "latest"
eza = "latest"
fd = "latest"
gitleaks = "latest"
"go:github.com/fujiwara/lambroll/cmd/lambroll" = "latest"
"go:github.com/golangci/golangci-lint/cmd/golangci-lint" = "latest"
"go:github.com/google/wire/cmd/wire" = "latest"
"go:github.com/k1LoW/git-wt" = "latest"
"go:golang.org/x/tools/cmd/goimports" = "0.46.0"
"pipx:awslabs-terraform-mcp-server" = "1.0.18"
"pipx:serena-agent" = "1.5.3"
"github:cli/cli" = "latest"
glab = "latest"
hexyl = "latest"
jq = "latest"
"aqua:anomalyco/opencode" = "latest"
saml2aws = "latest"
terraform = "latest"
trivy = "latest"
yazi = "latest"
```

#### 環境別の取り扱い

- Default: 全てのCLIツールをインストール
- Raspberry Pi: 全てのCLIツールをインストール

### Raspberry Pi 運用メモ（重要）

- `luacheck` は **mise の tools には直接定義しない**（`luacheck@latest` は registry に存在せず WARN の原因）。
- Pi 環境では `luacheck` は luarocks など mise 外で供給する。
- `mise run doctor` で `plugin yarn is not installed` が出る場合は `mise plugins install yarn` を実行する。
