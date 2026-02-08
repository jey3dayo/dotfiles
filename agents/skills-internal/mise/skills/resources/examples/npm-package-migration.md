# NPM Package Migration Example

Real-world example of migrating from `global-package.json` to mise-managed npm packages.

## Before Migration

### Directory Structure

```
~/src/dotfiles/
├── global-package.json
├── mise/config.toml (existing, no npm packages)
└── docs/maintenance.md (references npm install -g)
```

### global-package.json (deprecated)

```json
{
  "name": "lib",
  "dependencies": {
    "@bufbuild/protoc-gen-es": {
      "version": "2.2.0",
      "overridden": false
    },
    "@connectrpc/protoc-gen-connect-es": {
      "version": "1.6.1",
      "overridden": false
    },
    "aicommits": {
      "version": "1.11.0",
      "overridden": false
    },
    "corepack": {
      "version": "0.29.4",
      "overridden": false
    },
    "husky": {
      "version": "9.1.6",
      "overridden": false
    },
    "neovim": {
      "version": "5.3.0",
      "overridden": false
    },
    "npm-check-updates": {
      "version": "17.1.4",
      "overridden": false
    },
    "npm": {
      "version": "10.9.0",
      "overridden": false
    },
    "textlint-rule-preset-ja-technical-writing": {
      "version": "10.0.1",
      "overridden": false
    },
    "textlint": {
      "version": "14.3.0",
      "overridden": false
    }
  }
}
```

### Old mise/config.toml (partial)

```toml
[tools]
node = "latest"
python = "3.12"

# No npm packages yet
```

### Old docs/maintenance.md (partial)

```markdown
# Dependency Reconstruction

\`\`\`bash
brew bundle --force
mise install node@latest && npm install -g @fsouza/prettierd
mise install python@latest && pip install -r requirements.txt
\`\`\`
```

## Migration Process

### Step 1: Backup Current State

```bash
# Backup global npm packages
npm list -g --depth=0 > npm-global-backup-20241224.txt

# Backup global-package.json
cp global-package.json global-package.json.backup

# Commit current state
git add -A
git commit -m "chore: backup before mise migration"
```

### Step 2: Convert to mise Format

### Manual Conversion Script:

```bash
#!/usr/bin/env bash
# convert-npm-to-mise.sh

set -euo pipefail

INPUT="global-package.json"
OUTPUT="mise-npm-packages.toml"

echo "# NPM Global Packages" > "${OUTPUT}"

# Extract package names from global-package.json
jq -r '.dependencies | keys[]' "${INPUT}" | sort | while IFS= read -r pkg; do
    echo "\"npm:${pkg}\" = \"latest\"" >> "${OUTPUT}"
done

echo ""
echo "✅ Converted packages written to ${OUTPUT}"
echo "   Please review and add to mise/config.toml"
```

### Generated mise-npm-packages.toml:

```toml
# NPM Global Packages
"npm:@bufbuild/protoc-gen-es" = "latest"
"npm:@connectrpc/protoc-gen-connect-es" = "latest"
"npm:aicommits" = "latest"
"npm:corepack" = "latest"
"npm:husky" = "latest"
"npm:neovim" = "latest"
"npm:npm-check-updates" = "latest"
"npm:npm" = "latest"
"npm:textlint-rule-preset-ja-technical-writing" = "latest"
"npm:textlint" = "latest"
```

### Step 3: Update mise/config.toml

```toml
# mise/config.toml (updated)

[tools]
# ========================================
# Runtimes
# ========================================
node = "latest"
python = "3.12"
go = "latest"
rust = "latest"
lua = "5.1.5"
luajit = "latest"

# ========================================
# CLI Tools
# ========================================
ghq = "latest"
github-cli = "latest"
shellcheck = "latest"
yamllint = "latest"
taplo = "latest"

# ========================================
# NPM Global Packages (migrated from global-package.json)
# ========================================
"npm:@bufbuild/protoc-gen-es" = "latest"
"npm:@connectrpc/protoc-gen-connect-es" = "latest"
"npm:@fsouza/prettierd" = "latest"  # Added (was in docs but not in global-package.json)
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
# Python Global Packages
# ========================================
"pipx:black" = "latest"
"pipx:ruff" = "latest"

[tasks]
# (existing tasks)
```

### Step 4: Install via mise

```bash
# Install all tools including new npm packages
mise install

# Verify installation
mise ls | grep npm

# Test a few commands
which prettier
prettier --version

which neovim
node -e "require('neovim')"  # Should not error

which textlint
textlint --version
```

### Expected Output:

```
$ mise ls | grep npm
npm:@bufbuild/protoc-gen-es    2.2.0
npm:@connectrpc/protoc-gen-connect-es    1.6.1
npm:@fsouza/prettierd    0.25.0
npm:aicommits    1.11.0
npm:corepack    0.29.4
npm:husky    9.1.6
npm:neovim    5.3.0
npm:npm-check-updates    17.1.4
npm:npm    10.9.0
npm:textlint-rule-preset-ja-technical-writing    10.0.1
npm:textlint    14.3.0
...

$ which prettier
/Users/username/.local/share/mise/installs/npm-prettierd/0.25.0/bin/prettier
```

### Step 5: Update Documentation

### docs/maintenance.md (updated):

```markdown
# Dependency Reconstruction

\`\`\`bash

# All tools and packages managed by mise

brew bundle --force
mise install

# Verify installation

mise ls
\`\`\`
```

### docs/setup.md (updated):

```markdown
## Tool Installation

This project uses [mise](https://mise.jdx.dev) to manage all development tools:

\`\`\`bash

# Install mise

curl https://mise.run | sh

# Install all project tools

mise install

# Verify

mise doctor
\`\`\`

All npm and Python packages are declared in `mise/config.toml`. **Never use `npm install -g` or `pip install --user`.**
```

### Step 6: Remove Old Files

```bash
# Remove deprecated global-package.json
rm global-package.json

# Remove backup after verification
rm global-package.json.backup

# Clean up old global npm packages (optional)
npm list -g --depth=0 --json | \
  jq -r '.dependencies | keys[] | select(. != "npm")' | \
  xargs -I {} npm uninstall -g {}
```

### Step 7: Commit Changes

```bash
git add mise/config.toml
git add docs/maintenance.md docs/setup.md
git rm global-package.json
git commit -m "chore: migrate npm packages to mise, remove global-package.json"
```

## After Migration

### New Directory Structure

```
~/src/dotfiles/
├── mise/config.toml (updated with npm packages)
└── docs/maintenance.md (references mise install)
```

### Verification Checklist

- [ ] `mise install` completes without errors
- [ ] `mise ls` shows all npm packages
- [ ] `which <command>` points to mise-managed version for all tools
- [ ] All commands work (`prettier`, `textlint`, `neovim`, etc.)
- [ ] Documentation updated (no references to `npm install -g`)
- [ ] `global-package.json` removed
- [ ] Changes committed to git
- [ ] Team notified of new setup process

### Benefits Realized

### Before:

- 2 package managers: npm global + mise
- 2 files: `global-package.json` + `mise/config.toml`
- Potential drift: local npm packages vs tracked versions
- Manual sync required

### After:

- 1 package manager: mise
- 1 file: `mise/config.toml`
- Version-controlled: all tools tracked in git
- Automatic consistency: `mise install` handles everything

## Troubleshooting

### Issue: Old Global Packages Still Active

### Symptom:

```bash
$ which prettier
/usr/local/bin/prettier  # Old global install, not mise
```

### Solution:

```bash
# Check PATH
echo $PATH

# Ensure mise shims are first
eval "$(mise activate zsh)"

# Verify
which prettier  # Should now point to mise version

# Optionally remove old global install
npm uninstall -g prettier
```

### Issue: Package Not Found After Migration

### Symptom:

```bash
$ mise install
...
$ textlint --version
textlint: command not found
```

### Solution:

```bash
# Verify package installed
mise ls | grep textlint

# Check shim exists
ls -la ~/.local/share/mise/shims/textlint

# Try mise exec
mise exec -- textlint --version

# If still failing, reinstall
mise uninstall "npm:textlint"
mise install "npm:textlint"
```

### Issue: Neovim Node Client Not Working

### Symptom:

```lua
-- In Neovim
:checkhealth provider
-- Error: Node.js provider: neovim npm package not found
```

### Solution:

```bash
# Verify neovim package installed
mise ls | grep neovim

# Check node can require it
mise exec -- node -e "require('neovim')"

# In Neovim, use mise-managed node
vim.g.node_host_prog = vim.fn.expand("~/.local/share/mise/installs/node/latest/bin/node")
```

## Related Documents

- **Detailed Guide**: `references/tool-management.md`
- **Configuration Template**: `resources/templates/mise-config-template.toml`
- **Task Aliases**: See `SKILL.md` Section 5
