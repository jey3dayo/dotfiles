---
paths:
  - "Brewfile"
  - "mise/config.*.toml"
  - ".claude/rules/workflows-and-maintenance.md"
---

# Tool Installation Policy

## Purpose

Three-layer tool management architecture policy defining responsibility boundaries between Homebrew, mise, and Home Manager.

## Scope

- Homebrew: System dependencies, GUI applications, Neovim ecosystem
- mise: CLI tools, language runtimes, development environments
- Home Manager: Configuration distribution only (no tool installation)

## Sources

- `.claude/rules/workflows-and-maintenance.md`: Brewfile management workflows
- `.claude/rules/tools/mise.md`: mise runtime management

## Three-Layer Architecture

### Home Manager

**Responsibility**: Configuration distribution ONLY

- Distributes dotfiles (`.zshrc`, `.config/starship.toml`, etc.)
- Links configuration files to `$HOME`
- Does NOT install binaries or tools

**Rationale**: Home Manager manages configurations, not tool provisioning. Tool installation is delegated to mise or Homebrew.

**Example**: starship configuration is managed by Home Manager, but the starship binary is installed by mise.

### mise

**Responsibility**: CLI tools, language runtimes, development environments

- Cross-platform CLI tools (ripgrep, fd, bat, eza, etc.)
- Language runtimes (Node.js, Python, Ruby, Go, Rust)
- Development tools (AWS CLI, kubectl, terraform, etc.)
- Environment-specific configurations (`default`, `pi`, `ci`)

**Advantages**:

- Version pinning per project (`.tool-versions`)
- Environment isolation (no global pollution)
- Cross-platform compatibility (macOS/Linux/WSL2)
- Fast installation/switching

**Key files**:

- `mise/config.default.toml`: Main environment (180+ tools)
- `mise/config.pi.toml`: Raspberry Pi environment (50 tools)
- `mise/config.ci.toml`: CI/CD environment (20 tools)

### Homebrew

**Responsibility**: System dependencies, GUI applications, macOS-specific tools

- System libraries (libffi, openssl, utf8proc, etc.)
- GUI applications via Cask (Brave, Visual Studio Code, Docker, etc.)
- App Store applications via MAS (Xcode, 1Password, etc.)
- Neovim ecosystem (tree-sitter library, dependencies)
- Tools with complex native dependencies (mysql, podman)

**Advantages**:

- Native macOS integration
- System-level libraries
- GUI application management
- Robust dependency resolution

**Current state**: 229 formulae + 79 casks (as of 2026-02-12)

## Decision Flowchart

```
New tool required
    ↓
[1] Is it a GUI application?
    YES → Homebrew (cask)
    NO → Continue
    ↓
[2] Is it a system library or dependency?
    YES → Homebrew (brew)
    NO → Continue
    ↓
[3] Is it a CLI tool or language runtime?
    YES → mise
    NO → Continue
    ↓
[4] Is it Neovim ecosystem?
    YES → Check dependency type
        - Library (tree-sitter) → Homebrew
        - CLI tool (tree-sitter-cli) → mise
    NO → mise (default)
```

## Language Runtime Policy

Language runtimes follow a hybrid pattern based on system dependencies:

| Runtime  | mise | Homebrew              | Rationale                                  |
| -------- | ---- | --------------------- | ------------------------------------------ |
| Node.js  | ✅   | ❌                    | Pure JavaScript, no system deps            |
| Python   | ✅   | ⚠️ (only if needed)   | System tools may require specific versions |
| Ruby     | ✅   | ❌                    | Version switching essential                |
| Go       | ✅   | ❌                    | Single-version toolchain                   |
| Rust     | ✅   | ❌                    | rustup/mise handles toolchain              |
| Java/JVM | ✅   | ⚠️ (for system tools) | mise handles development versions          |
| Perl     | ⚠️   | ✅                    | macOS system dependency                    |

**Legend**:

- ✅ Primary installation method
- ❌ Not recommended
- ⚠️ Only if system tool requires it

**Hybrid pattern decision criteria**:

1. **System tool dependency**: Does a Homebrew formula require this runtime?
   - YES → Keep in Homebrew (e.g., `python@3.13` for system tools)
   - NO → Use mise only
2. **Development use**: Is this for project development?
   - YES → mise (with version pinning)
   - NO → Homebrew (if system-wide version is acceptable)

**Example**: `python@3.11` was removed from Brewfile because no system tools require it. Projects use mise-managed Python versions.

## starship Case Study

**Migration path**: Homebrew → Home Manager → mise

**Final architecture**:

- Binary: `mise install starship` (mise/config.default.toml)
- Configuration: Home Manager manages `~/.config/starship.toml`

**Rationale**:

- starship is a cross-platform CLI tool (mise responsibility)
- Home Manager distributes configuration only (no binary installation)
- Version pinning enables reproducibility across environments
- Aligns with three-layer architecture principles

**Related**:

- PR #106: Home Manager starship configuration
- PR #108: starship binary moved to mise
- Commit e40c34ac: Rust toolchain moved to mise

## Common Violations

### ❌ Anti-patterns

```toml
# BAD: Installing GUI app via mise
[tools]
"visual-studio-code" = "latest"  # Should use Homebrew cask

# BAD: Installing system library via mise
[tools]
"libffi" = "latest"  # Should use Homebrew brew

# BAD: Duplicate tool in both systems
# Brewfile: brew "ripgrep"
# mise/config.default.toml: ripgrep = "latest"
```

### ✅ Correct patterns

```ruby
# GOOD: GUI app via Homebrew
cask "visual-studio-code"

# GOOD: System library via Homebrew
brew "libffi"

# GOOD: CLI tool via mise only
[tools]
ripgrep = "14.1.1"
```

### Neovim ecosystem distinction

```ruby
# Homebrew (system library)
brew "tree-sitter"  # C library for Neovim

# mise (CLI tool)
[tools]
tree-sitter = "latest"  # tree-sitter-cli for development
```

## Verification Commands

### Check for duplicate tools

```bash
# Extract Homebrew formulae
grep '^brew ' Brewfile | sed 's/brew "\(.*\)".*/\1/' | sort > /tmp/brew_tools.txt

# Extract mise tools
grep '^\w\+\s*=' mise/config.default.toml | sed 's/\s*=.*//' | sort > /tmp/mise_tools.txt

# Find duplicates
comm -12 /tmp/brew_tools.txt /tmp/mise_tools.txt
```

**Expected result**: Empty (no duplicates)

**Known exceptions**:

- `tree-sitter` (library) vs `tree-sitter` (CLI) - Different packages
- `python@3.13` (system) vs `python` (mise) - Hybrid pattern

### Check mise tool availability

```bash
# Verify deleted Brewfile tools exist in mise
for tool in usage tree-sitter-cli zx pipx rust; do
  echo -n "$tool: "
  grep -q "^$tool\s*=" mise/config.default.toml && echo "✅ in mise" || echo "❌ missing"
done
```

### Validate Brewfile structure

```bash
# Check for policy comments
head -5 Brewfile | grep -q "# Homebrew policy:" && echo "✅ Policy documented" || echo "❌ Missing policy"

# Check for removed tools
grep -E '^brew "(usage|pipx|python@3.11|python@3.12|rust|tree-sitter-cli|zx)"' Brewfile
# Expected: No output (tools removed)
```

## Migration Checklist

When migrating a tool from Homebrew to mise:

1. **Verify mise availability**

   ```bash
   mise registry | grep <tool-name>
   ```

2. **Add to mise configuration**

   ```toml
   [tools]
   <tool-name> = "latest"  # or specific version
   ```

3. **Test mise installation**

   ```bash
   mise install <tool-name>
   mise exec <tool-name> -- <command>
   ```

4. **Remove from Brewfile**

   ```bash
   # Delete the brew line
   grep -v '^brew "<tool-name>"' Brewfile > Brewfile.tmp
   mv Brewfile.tmp Brewfile
   ```

5. **Uninstall Homebrew version**

   ```bash
   brew uninstall <tool-name>
   ```

6. **Verify command availability**

   ```bash
   which <tool-name>  # Should point to ~/.local/share/mise/installs
   <tool-name> --version
   ```

7. **Update documentation**
   - Add migration note to commit message
   - Update `.claude/rules/workflows-and-maintenance.md` if needed

8. **Test across environments**

   ```bash
   mise run ci  # Local CI validation
   # SSH to Raspberry Pi and test
   # Verify GitHub Actions pass
   ```

## Exception Handling

### When to keep tools in Homebrew

1. **Neovim dependencies**: System libraries required by Neovim plugins

   ```ruby
   brew "tree-sitter"      # C library
   brew "luajit"           # Lua interpreter
   brew "utf8proc"         # Unicode library
   ```

2. **System tool dependencies**: Tools required by other Homebrew formulae

   ```bash
   # Check dependencies before removing
   brew uses --installed <tool-name>
   ```

3. **Complex native compilation**: Tools with difficult cross-platform builds

   ```ruby
   brew "mysql"            # Complex native deps
   brew "podman"           # Requires QEMU/vde
   ```

4. **macOS-specific integration**: Tools that need system-level integration

   ```ruby
   brew "defaultbrowser"   # macOS default browser API
   brew "daipeihust/tap/im-select"  # Input method switching
   ```

### When mise is NOT suitable

1. **GUI applications**: Always use Homebrew cask
2. **System libraries**: Always use Homebrew formulae
3. **MAS applications**: Always use Homebrew MAS
4. **Tools not in mise registry**: Check availability first

   ```bash
   mise registry | grep <tool-name>
   # If not found, use Homebrew or request addition to mise registry
   ```

## Maintenance Procedures

### Monthly audit (recommended)

1. **Check for duplicates**

   ```bash
   comm -12 /tmp/brew_tools.txt /tmp/mise_tools.txt
   ```

2. **Review mise registry updates**

   ```bash
   mise registry update
   mise outdated
   ```

3. **Validate Brewfile policy compliance**

   ```bash
   # Check for CLI tools in Brewfile (should be minimal)
   grep '^brew ' Brewfile | wc -l  # Target: <50 CLI tools
   ```

4. **Update documentation**
   - Refresh tool counts in this document
   - Update migration examples
   - Document new exceptions

### Quarterly review

1. **Re-evaluate hybrid patterns**: Check if system tools still require specific runtimes
2. **Consolidate mise configurations**: Merge redundant environment configs
3. **Prune unused tools**: Remove tools no longer needed
4. **Update mise to latest version**: `mise self-update`

## References

- PR #106: Home Manager starship prompt
- PR #108: starship binary moved to mise
- Commit 01ea391b: Brewfile alignment with policy
- Commit e40c34ac: Rust toolchain moved to mise
- `.claude/rules/workflows-and-maintenance.md`: Brewfile workflows
- `.claude/rules/tools/mise.md`: mise runtime management
- `.claude/rules/workflows-and-maintenance.md`: Tool Management Philosophy

## Change Log

- 2026-02-12: Initial policy document created
- 2026-02-12: Removed 7 tools from Brewfile (usage, pipx, python@3.11, python@3.12, rust, tree-sitter-cli, zx)
- 2026-02-12: Added policy comments to Brewfile
- 2026-02-12: Documented starship migration path
