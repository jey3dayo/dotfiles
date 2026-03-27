# Clean Up Unused External Skills Vendored Copies

## Summary

Remove unused vendored copies in `agents/external/` and clean up deprecated `localPath`/`localSkillsPath` code paths. The `agents/external/` directory is not part of the current distribution (`localPath = null`), and its skills are already available through Nix flake inputs.

## Background

Historically, external skills took two paths:

- Path A (agents/external/): Vendored copies checked into git. Superseded by flake inputs.
- Path B (Nix flake inputs): Declared in `agent-skills-sources.nix`, fetched at build time.

Current state: `localPath = null` and `localSkillsPath` unset. Path A is **not active** in the distribution. However:

- `agents/external/` still exists as stale vendored copies (9 skills)
- `lib.nix` carries dead code for `localPath` handling
- `module.nix` has deprecated `localSkillsPath` option
- Supporting docs/rules reference these obsolete paths

This is **not a "dual-path unification"** (paths are not both active). It's cleanup of:

1. Unused vendored copies in `agents/external/`
2. Legacy override code (`localPath`, `localSkillsPath`)

## Decision

Remove obsolete vendored copies and deprecated code. Rationale:

- `localPath = null`: `agents/external/` is not scanned in current builds
- All 7 truly-external skills have `agent-skills-sources.nix` definitions
- `codex-system` and `gemini-system` are in `agents/internal/skills/` (external copies redundant)
- No local patches exist on any `agents/external/` skill
- Reduces repo size and removes misleading "dual-path" appearance

## Non-Goals

- Changing how `agents/internal/` works (distribution path stays as-is)
- Adding new external skill sources
- Changing the `selection.enable` filtering mechanism
- Refactoring `scanSource` / `scanSourceAutoDetect` (still needed for flake inputs)
- Changing `agent-skills-sources.nix` structure (all 10 source definitions remain as-is)

## Design

### Phase 1: Delete `agents/external/`

### Changes

- Delete `agents/external/` entirely (9 skill directories + `.gitkeep`)
- `codex-system` and `gemini-system` are already in `agents/internal/skills/`

### Skill ID mapping (agents/external/ dir name → agent-skills-sources.nix ID)

| `agents/external/` directory  | `selection.enable` ID   | Source               |
| ----------------------------- | ----------------------- | -------------------- |
| `agent-browser`               | `agent-browser`         | vercel-agent-browser |
| `gh-address-comments`         | `gh-address-comments`   | openai-skills        |
| `gh-fix-ci`                   | `gh-fix-ci`             | openai-skills        |
| `skill-creator`               | `skill-creator`         | openai-skills        |
| `ui-ux-pro-max`               | `ui-ux-pro-max`         | ui-ux-pro-max        |
| `vercel-react-best-practices` | `react-best-practices`  | vercel-agent-skills  |
| `web-design-guidelines`       | `web-design-guidelines` | vercel-agent-skills  |

Note: `vercel-react-best-practices` (dir name) maps to `react-best-practices` (skill ID).

### Verification

```bash
# Pre-deletion: save current skills list
ls ~/.claude/skills/ > /tmp/before.txt

# Delete and redeploy
rm -rf agents/external/
home-manager switch --flake ~/.config --impure

# Post-deployment: verify no skill loss
ls ~/.claude/skills/ > /tmp/after.txt
diff /tmp/before.txt /tmp/after.txt  # Should be empty (no changes)
```

### Phase 2: Clean up `lib.nix`, `module.nix`, and `flake.nix`

#### Current `discoverCatalog` priority (Nix `//` is right-biased)

```
local (deprecated) > distribution (agents/internal) > sources (flake inputs)
```

### New `discoverCatalog` priority

```
distribution (agents/internal) > sources (flake inputs)
```

### lib.nix changes

- Remove `localPath` parameter from `discoverCatalog`
- Remove local path scanning logic and merge step
- Remove any dead code branches guarded by `localPath != null`
- Simplify naming: remove "external" qualifier where it only referred to the directory concept

### module.nix changes

- Remove `localSkillsPath` option definition (deprecated, default `null`)
- Update `discoverCatalog` call site to remove `localPath` argument
- Remove `localSkillIds` variable and its reference in `enableList` calculation
- Keep null-safe `enableList` logic (don't simplify to `cfg.skills.enable ++ distributionSkillIds` — this breaks when `cfg.skills.enable == null`):

  ```nix
  enableList =
    if cfg.skills.enable == null
    then distributionSkillIds  # Only distribution skills when no selection
    else lib.unique (cfg.skills.enable ++ distributionSkillIds);
  ```

### flake.nix changes

- Update `discoverCatalog` call to remove `localPath` argument

### Verification

```bash
# Build verification
home-manager switch --flake ~/.config --impure  # Must succeed
nix run .#report                                # Visualize source hierarchy

# Skills verification
ls ~/.claude/skills/ > /tmp/after-phase2.txt
diff /tmp/before.txt /tmp/after-phase2.txt  # Should be empty
```

### Phase 3: Update supporting documentation and configurations

### agents/README.md

- Remove `agents/external/` section
- Replace "Internal vs External" with "Sources (flake inputs) vs Distribution (internal)" framing
- Update directory tree diagram

#### Rules and documentation files (update/remove references to `agents/external/`, `localSkillsPath`, `localPath`)

- `.claude/rules/home-manager.md`
- `.claude/rules/agent-skills-source-of-truth.md` (if exists)
- `docs/tools/home-manager.md`
- `docs/tools/nix.md`
- Any other files with `agents/external|localSkillsPath|localPath` references

#### Ignore configurations (remove `agents/external` patterns)

- `.fdignore`
- `.prettierignore`
- `.pre-commit-config.yaml`
- `.markdownlint-cli2.jsonc`
- `biome.json`
- `mise/config.toml`

### Test files

- Confirmed: no existing tests reference `agents/external/`. No changes expected.

### Final verification

```bash
# Quality checks
mise run ci

# Distribution verification
home-manager switch --flake ~/.config --impure
nix run .#report

# Residual check (no obsolete references should remain)
rg -n 'agents/external|localSkillsPath' .
# Expected: only hits in this spec file and git history
```

## Risks and Mitigations

| Risk                                  | Likelihood | Mitigation                                                                            |
| ------------------------------------- | ---------- | ------------------------------------------------------------------------------------- | ---------------------------- |
| Skill missing after migration         | Low        | Pre-verify all 7 skills in `agent-skills-sources.nix` before Phase 1                  |
| Nix refactor breaks build             | Medium     | Phase 1 validates skills are available; Phase 2 bundles all Nix changes in one commit |
| Hardcoded references to deleted paths | Low        | Residual check with `rg -n 'agents/external                                           | localSkillsPath'` in Phase 3 |
| `enableList` null-safety regression   | Medium     | Explicit null-handling preserved in Phase 2                                           |
| Ignore configurations still reference | Low        | Systematic review of ignore files in Phase 3                                          |

## Commit Strategy

Two commits for safety and atomicity:

1. Phase 1: `refactor(agents): remove agents/external/ directory`
   - Isolated filesystem change, verifiable via skill list diff

2. Phase 2 + 3: `refactor(nix): remove localPath/localSkillsPath and update docs`
   - Bundled Nix changes (`lib.nix`, `module.nix`, `flake.nix`)
   - Documentation and config updates
   - All non-build-breaking changes in one atomic commit

Rationale: Phase 2 and 3 are tightly coupled (`lib.nix` change forces `module.nix`/`flake.nix` updates). Keeping them together prevents intermediate broken states.
