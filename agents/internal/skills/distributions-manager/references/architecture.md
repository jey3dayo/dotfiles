# Distributions Architecture

## Overview

The distributions layer is implemented in `agents/nix/lib.nix` and integrates with the existing `discoverCatalog()` function. It provides a symlink-based bundling mechanism that coexists with the existing Local/External sources.

---

## Nix Implementation

### scanDistribution Function

```nix
# agents/nix/lib.nix (simplified)
scanDistribution = distributionPath:
  if !pathExists distributionPath then
    {}
  else
    let
      processSkillEntry = name: type:
        let entryPath = distributionPath + "/${name}";
        in
          if type == "directory" || type == "symlink" then
            if pathExists (entryPath + "/SKILL.md") then
              { ${name} = { id = name; path = entryPath; source = "distribution"; }; }
            else
              scanSource "distribution" entryPath
          else {};

      entries = readDir distributionPath;
      scannedResults = mapAttrsToList processSkillEntry entries;
    in
      foldl' (a: b: a // b) {} scannedResults;
```

### Key features

- **Directory/symlink support**: Handles both direct directories and symlinks
- **Recursive scanning**: Uses `scanSource` for nested structures
- **Lazy evaluation**: Only scans if `distributionPath` exists
- **Source tagging**: All entries marked with `source = "distribution"`

### Integration with discoverCatalog

```nix
# agents/nix/lib.nix (simplified)
discoverCatalog = { distributionsPath ? null, ... }:
  let
    distributionSkills =
      if distributionsPath != null then
        scanDistribution (distributionsPath + "/skills")
      else
        {};

    localSkills = scanSource "local" skillsPath;
    externalSkills = scanExternal skillsExternalPath;
  in
    # Priority: Distribution < External < Local
    distributionSkills // externalSkills // localSkills;
```

### Priority mechanism

---

## Command Processing

Commands support subdirectory structures:

```nix
# agents/nix/lib.nix (simplified)
processCommandEntry = name: type:
  let entryPath = commandsPath + "/${name}";
  in
    if type == "directory" || type == "symlink" then
      if pathExists (entryPath + "/command.ts") then
        { ${name} = { id = name; path = entryPath; source = "distribution"; }; }
      else
        scanCommandSource "distribution" entryPath
    else {};
```

### Subdirectory example

```
internal/commands/
├── kiro -> ../../../commands-internal/kiro/  (symlink to dir)
│   ├── spec-init/
│   │   └── command.ts
│   ├── spec-tasks/
│   │   └── command.ts
```

Each subdirectory with `command.ts` is treated as a separate command.

---

## Rules and Agents Processing

Rules and agents are `.md` files that support subdirectory structures:

```nix
# agents/nix/lib.nix (simplified)
scanDistribution = distributionPath:
  let
    rulesPath = distributionPath + "/rules";
    agentsPath = distributionPath + "/agents";

    # Scan rules directory for .md files
    scannedRules =
      if pathExists rulesPath then
        let
          ruleEntries = readDir rulesPath;
          processRuleEntry = name: type:
            let
              entryPath = rulesPath + "/${name}";
              ruleId = if hasSuffix ".md" name then
                removeSuffix ".md" name
              else
                name;
            in
              if (type == "regular" || type == "symlink") && hasSuffix ".md" name then
                { ${ruleId} = { id = ruleId; path = entryPath; source = "distribution"; }; }
              else if type == "directory" || type == "symlink" then
                # Scan subdirectory recursively
                scanRuleSubdirectory entryPath name
              else {};
        in
          foldl' (a: b: a // b) {} (mapAttrsToList processRuleEntry ruleEntries)
      else {};
  in
    { skills = ...; commands = ...; rules = scannedRules; agents = scannedAgents; };
```

### Subdirectory example

```
internal/
├── rules/
│   └── claude-md-design.md -> ~/.claude/rules/claude-md-design.md
└── agents/
    ├── aws-operations.md -> ~/.claude/agents/aws-operations.md
    ├── code-reviewer.md -> ~/.claude/agents/code-reviewer.md
    └── kiro/ -> ~/.claude/agents/kiro/  (symlink to dir)
        ├── spec-design.md
        ├── spec-impl.md
        └── validate-impl.md
```

### ID generation for subdirectories

Subdirectory structure is preserved in IDs:

- `agents/kiro/spec-design.md` → ID: `kiro/spec-design`
- `rules/frontend/react.md` → ID: `frontend/react`

These IDs are used for deployment paths:

- `.claude/agents/kiro/spec-design.md`
- `.claude/rules/frontend/react.md`

---

## Cyclic Reference Prevention

### Static Paths

Distributions are scanned **before** sources to prevent circular dependencies:

```nix
# Scan order in discoverCatalog
1. distributionSkills (static paths, no evaluation)
2. externalSkills
3. localSkills (overwrites conflicts)
```

### Path Resolution

```nix
# Static path resolution
distributionSkills = scanDistribution (distributionsPath + "/skills");
# → /nix/store/...-internal/skills

# Entries can be directories or symlinks; resolution happens at filesystem level
# Example: internal/skills/my-skill
# Nix sees: /home/j138/.config/agents/internal/skills/my-skill
```

### Key insight

---

## Deployment Flow

```mermaid
graph TD
    A[home-manager switch] --> B[discoverCatalog]
    B --> C[scanDistribution]
    C --> D[readDir internal/skills]
    D --> E[Process symlinks]
    E --> F[Merge with External/Local]
    F --> G[Generate ~/.claude/skills/]
```

### Step-by-step

1. Nix evaluation: `scanDistribution()` reads `internal/skills/`
2. Symlink processing: Each symlink is checked for `SKILL.md`
3. Catalog merge: Distribution entries merged with External/Local
4. Priority resolution: Local overwrites conflicts
5. Deployment: Symlinks created in `~/.claude/skills/`

---

## Verification

```bash
# Check Nix evaluation (dry-run)
home-manager build --flake ~/.config --impure --dry-run

# Inspect generated catalog
nix eval --json --impure --expr '
  let lib = import ~/.config/agents/nix/lib.nix { inherit (import <nixpkgs> {}) lib; };
      catalog = lib.discoverCatalog {
        distributionsPath = ~/.config/agents/internal;
        # ... other paths
      };
  in builtins.attrNames catalog.skills
' | jq

# Verify deployed skills
ls -la ~/.claude/skills/
```

---

## Design Rationale

### Why Symlinks?

- **No duplication**: Source of truth remains in `agents/internal/skills/`
- **Easy updates**: Changes to source automatically reflected
- **Nix-friendly**: Symlinks are resolved at filesystem level
- **Bundle flexibility**: Same skill can appear in multiple distributions

### Why Static Scanning?

- **Prevents cycles**: No evaluation dependencies between distributions and sources
- **Predictable order**: Distribution < External < Local
- **Simple debugging**: Scan order is explicit

### Why Optional?

- **Backwards compatibility**: Existing workflows (Local/External) unaffected
- **Incremental adoption**: Teams can opt-in gradually
- **Zero overhead**: If `distributionsPath = null`, no scanning occurs

---

## Related Files

- **agents/nix/lib.nix**: Main implementation
- **~/.config/flake.nix**: Home Manager integration (calls `discoverCatalog`)
- **agents/internal/**: Example bundle

---

## Future Considerations

- **Multi-bundle support**: Currently single distribution (`internal/`), could support multiple
- **Bundle versioning**: Semantic versioning for bundle releases
- **Validation tools**: CLI for checking bundle integrity
