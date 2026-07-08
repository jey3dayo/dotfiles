# Mise Configuration Reference

最終更新: 2026-06-25
対象: 開発者
タグ: `category/configuration`, `tool/mise`, `layer/tool`, `environment/cross-platform`, `audience/developer`

Claude Rules: [.claude/rules/tools/mise.md](../../.claude/rules/tools/mise.md)
親ドキュメント: [Mise Reference](mise.md)

## Tool Categories (config.default.toml)

mise/config.default.toml は以下の 6 カテゴリで構成されています:

### 1. Language Runtimes

```toml
[tools]
deno = "latest"
go = "1.26.4"
node = "lts"
python = "3.14"
julia = "latest"
rust = "stable"
# lua/luajit は Homebrew で管理 (Neovim 依存関係のため)
```

### 2. Package Managers

```toml
[tools]
"github:astral-sh/uv" = "latest"
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

完全移行完了: 全ての npm パッケージを mise で一元管理（npm/pnpm/bun グローバルには依存しない）

```toml
[tools]
# ユーティリティ・ツール
"npm:@antfu/ni" = "latest"
"npm:corepack" = "latest"
"npm:husky" = "latest"
"npm:npm" = "latest"
"npm:npm-check-updates" = "latest"
"npm:agent-browser" = "latest"
"npm:dev-browser" = "latest"

# 開発・エディタ
"npm:@fsouza/prettierd" = "latest"
"npm:neovim" = "latest"

# プロトコルバッファ・RPC
"npm:@bufbuild/protoc-gen-es" = "latest"
"npm:@connectrpc/protoc-gen-connect-es" = "latest"

# AI・コミット支援
"npm:@openai/codex" = "latest"
"npm:aicommits" = "latest"
"npm:opencommit" = "latest"
"npm:clawdbot" = "latest"
"npm:vibe-kanban" = "latest"

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
"npm:eslint_d" = "latest"
"npm:typescript" = "latest"
"npm:tsx" = "latest"
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
"aqua:rtk-ai/rtk" = "latest"
"cargo:bandwhich" = "latest"
"cargo:needle-cli" = "0.15.0"
"cargo:similarity-css" = "0.5.0"
"cargo:similarity-ts" = "0.5.0"
"cargo:wrkflw" = "0.8.0"
"cargo:starship" = "latest"
"cargo:deadnix" = "latest"
"cargo:tree-sitter-cli" = { version = "0.26.9", default-features = "false" }
"cargo:https://github.com/oppiliappan/statix" = { version = "tag:v0.5.8", crate = "statix" }
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
bat = "latest"
buf = "latest"
eza = "latest"
fd = "latest"
fzf = "latest"
gitleaks = "latest"
"go:github.com/fujiwara/lambroll/cmd/lambroll" = "latest"
"go:github.com/golangci/golangci-lint/cmd/golangci-lint" = "latest"
"go:github.com/google/wire/cmd/wire" = "latest"
"go:github.com/k1LoW/git-wt" = "latest"
"go:golang.org/x/tools/cmd/goimports" = "0.46.0"
"pipx:apm-cli" = "0.21.0"
"pipx:awslabs-terraform-mcp-server" = "1.0.18"
"pipx:serena-agent" = "1.5.3"
"github:cli/cli" = "latest"
glab = "latest"
hexyl = "latest"
jq = "latest"
lazygit = "latest"
"aqua:anomalyco/opencode" = "latest"
ripgrep = "latest"
saml2aws = "latest"
terraform = "latest"
trivy = "latest"
usage = "latest"
yazi = "latest"
zoxide = "latest"
```

#### 環境別の取り扱い

- Default: 全てのCLIツールをインストール
- Raspberry Pi: 全てのCLIツールをインストール

### Raspberry Pi 運用メモ（重要）

- `luacheck` は **mise の tools には直接定義しない**（`luacheck@latest` は registry に存在せず WARN の原因）。
- Pi 環境では `luacheck` は Nix 側（例: `nix profile` / Home Manager）で供給する。
- `mise run doctor` で `plugin yarn is not installed` が出る場合は `mise plugins install yarn` を実行する。
