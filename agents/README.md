# Agents Directory Structure

This directory contains Claude Code agent skills, commands, and configurations organized into internal and external assets.

## Directory Structure

```
agents/
├── internal/          # Internal assets (single source of truth)
│   ├── skills/       # Bundled skills
│   ├── commands/     # Slash commands
│   ├── agents/       # Agent definitions
│   └── rules/        # Project rules
├── external/         # External skills from marketplace
├── nix/              # Nix implementation
│   ├── lib.nix       # Core logic (scan, discover, bundle)
│   ├── module.nix    # Home Manager module
│   └── README.md     # Nix implementation details
└── scripts/          # Maintenance scripts
```

## Internal vs External

### agents/internal/

**Purpose**: Single source of truth for internal assets

**Contents**:

- **skills/**: Core skills developed and maintained in this repository
- **commands/**: Slash commands for interactive operations
- **agents/**: Subagent definitions for specialized tasks
- **rules/**: Project-specific rules and guidelines

**Distribution**: All contents are automatically distributed to `~/.claude/` via Home Manager

### agents/external/

**Purpose**: External skills from marketplace and third-party sources

**Contents**:

- Skills from Claude Code Marketplace
- Skills from OpenAI curated collection
- Skills from Vercel, Heyvhuang, and other providers

**Management**: Configured via `nix/agent-skills-sources.nix` and `flake.nix` inputs

## Usage

### Deploying Changes

```bash
# Apply all changes to ~/.claude/
home-manager switch --flake ~/.config --impure

# Verify deployment
ls ~/.claude/skills/ | wc -l
```

### Validation

```bash
# Validate internal assets structure
bash ./agents/scripts/validate-internal.sh

# Validate skill catalog
nix run .#validate
```

### Adding New Skills

**Internal skills** (developed in this repo):

1. Create skill directory under `agents/internal/skills/<skill-name>/`
2. Add `SKILL.md` with skill definition
3. Run `home-manager switch --flake ~/.config --impure`

**External skills** (from marketplace):

1. Add to `nix/agent-skills-sources.nix`
2. Add flake input to `flake.nix`
3. Run `nix flake update && home-manager switch --flake ~/.config --impure`

## Architecture

### Catalog Discovery

Skills are discovered in priority order:

1. **Local** (`localPath` - deprecated, for legacy compatibility)
2. **Distribution** (`agents/internal/` - primary source)
3. **External** (flake inputs via `sources`)

### Selection

- Distribution skills: Always included
- External skills: Filtered by `selection.enable` in `nix/agent-skills-sources.nix`
- Result: Merged catalog with unique skill IDs

### Bundling

Selected skills are bundled into Nix store and distributed via Home Manager to `~/.claude/skills/` as per-skill symlinks.

## References

- **Nix Implementation**: `agents/nix/README.md`
- **Home Manager Rules**: `.claude/rules/home-manager.md`
- **Agent Skills Sources**: `nix/agent-skills-sources.nix`

---

**Last Updated**: 2026-02-16
