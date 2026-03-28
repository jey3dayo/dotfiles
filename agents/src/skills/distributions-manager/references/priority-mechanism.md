# Priority Mechanism

## Overview

The current distributions runtime uses a two-tier priority model for skill resolution:

```text
Distribution > External
```

- Distribution: bundled assets under `agents/src/`, discovered via `distributionsPath`
- External: flake-input sources configured in `programs.agent-skills.sources`

`skills.enable = null` means "all discovered skills". In that mode, the Home Manager module keeps the full merged catalog instead of narrowing to bundled skills only, so discovered external skills and their source-scoped top-level assets remain deployable.

---

## Priority Order

### Meaning

- Distribution (`agents/src/skills/`): highest priority, wins on duplicate skill IDs
- External (`sources.<name>.path`): lower priority, used when no bundled skill with the same ID exists

### Nix Implementation

```nix
# agents/nix/lib.nix (simplified)
discoverCatalog =
  {
    sources,
    distributionsPath ? null,
  }:
  let
    distributionResult =
      if distributionsPath != null && pathExists distributionsPath then
        scanDistribution distributionsPath
      else
        { skills = { }; };

    externalSkills = builtins.foldl' (
      acc: srcName:
      acc // scanSourceAutoDetect srcName sources.${srcName}
    ) { } (attrNames sources);
  in
  externalSkills // distributionResult.skills;
```

Because `//` is right-biased, bundled skills from `agents/src/skills/` override external skills with the same ID.

### Selection Behavior

```nix
# agents/nix/module.nix (simplified)
enableList =
  if cfg.skills.enable == null then
    lib.attrNames catalog
  else
    lib.unique (cfg.skills.enable ++ distributionSkillIds);

selectedSkills =
  if cfg.skills.enable == null then
    catalog
  else
    agentLib.selectSkills {
      inherit catalog;
      enable = enableList;
    };
```

- `skills.enable = null`: select the full discovered catalog
- `skills.enable = [ ... ]`: select the requested skills plus bundled distribution skills

---

## Conflict Resolution

### Scenario 1: Same Skill in Distribution and External

```text
agents/src/skills/react/            (Distribution)
<flake-input>/skills/react/         (External)
```

### Resolution

```nix
{
  react = {
    id = "react";
    path = /path/to/agents/src/skills/react;
    source = "distribution";
  };
}
```

### Winner

Distribution wins.

---

### Scenario 2: Skill in External Only

```text
<flake-input>/skills/ui-ux-pro-max/  (External)
```

### Resolution

```nix
{
  ui-ux-pro-max = {
    id = "ui-ux-pro-max";
    path = /path/to/external/skills/ui-ux-pro-max;
    source = "vercel-agent-skills";
  };
}
```

### Winner

External source is used because there is no bundled skill with the same ID.

---

### Scenario 3: Skill in Distribution Only

```text
agents/src/skills/custom-skill/  (Distribution)
```

### Resolution

```nix
{
  custom-skill = {
    id = "custom-skill";
    path = /path/to/agents/src/skills/custom-skill;
    source = "distribution";
  };
}
```

### Winner

Distribution is used.

---

## Use Cases

### Use Case 1: Ship a Bundled Default

```text
agents/src/skills/react/
<flake-input>/skills/react/
```

Result: the bundled `agents/src/skills/react/` version is selected.

---

### Use Case 2: Import an External-Only Skill

```text
<flake-input>/skills/my-skill/
```

Result: the external skill is included in the catalog and, when selected, its source can also expose top-level `agents/` and `commands/`.

---

### Use Case 3: Enable Everything

```nix
programs.agent-skills.skills.enable = null;
```

Result: all discovered bundled and external skills are selected.

---

## Cyclic Reference Prevention

### Problem

If a bundled entry points back into generated deployment output, you can create confusing self-references:

```text
agents/src/skills/... -> ~/.claude/skills/...
```

### Solution

Keep bundled entries rooted in real source paths under `agents/src/` or in external source trees. `scanDistribution` reads static filesystem paths before deployment output exists.

### Scan Order

```nix
1. distributionResult = scanDistribution(distributionsPath)
2. externalSkills = scanSourceAutoDetect(...)
3. catalog = externalSkills // distributionResult.skills
```

### Path Resolution

```text
agents/src/skills/my-skill -> ../../some-real-source/my-skill
```

`readDir` and `pathExists` resolve the symlink target at the filesystem layer. Broken links are skipped because `pathExists (entryPath + "/SKILL.md")` evaluates to `false`.

---

## Debugging Priority Issues

### Check Source Attribution

```bash
mise run skills:list 2>/dev/null | jq '.skills[] | {id, source}'
```

Expected output includes a mix of distribution and external sources, for example:

```text
{"id":"react","source":"distribution"}
{"id":"ui-ux-pro-max","source":"vercel-agent-skills"}
```

---

### Verify the Selected Catalog When `skills.enable = null`

```bash
mise run skills:list 2>/dev/null | jq '[.skills[] | .source] | group_by(.) | map({(.[0]): length})'
```

If external sources are configured and discovered, their source names should still appear in the grouped output.

---

### Trace Nix Evaluation

```bash
nix eval --show-trace --json --impure --expr '
  let
    pkgs = import <nixpkgs> {};
    agentLib = import ~/.config/agents/nix/lib.nix {
      inherit pkgs;
      nixlib = pkgs.lib;
    };
    catalog = agentLib.discoverCatalog {
      distributionsPath = ~/.config/agents/src;
      sources = {};
    };
  in
    catalog.react
' | jq
```

---

## Best Practices

1. Treat `agents/src/` as the bundled source of truth.
2. Use external sources for additive skills or upstream imports.
3. Expect `skills.enable = null` to keep all discovered skills, not just bundled ones.
4. Use real current paths in docs and symlinks; do not reference removed `internal/`, `skills-internal/`, or `commands-internal/` layers.
5. Avoid symlinks that point into generated deployment directories such as `~/.claude/skills/`.

---

## Priority Matrix

| Skill Location        | Priority | Source Tag Example    | Overwrites |
| --------------------- | -------- | --------------------- | ---------- |
| `agents/src/skills/`  | Highest  | `distribution`        | External   |
| `sources.<name>.path` | Lower    | `vercel-agent-skills` | None       |

---

## Edge Cases

### Edge Case 1: Two Bundled Entries Point to the Same Target

```text
agents/src/skills/react -> ../../shared/react
agents/src/skills/react-copy -> ../../shared/react
```

Result: both IDs are scanned because IDs come from directory names, not resolved target paths.

---

### Edge Case 2: Bundled Entry Points into an External Checkout

```text
agents/src/skills/my-skill -> ../../vendor/my-skill
```

Result: the entry is still tagged as `distribution`, because it was discovered from `agents/src/skills/`, and it wins over an external skill with the same ID.

---

### Edge Case 3: Broken Bundled Symlink

```text
agents/src/skills/broken -> ../../missing-skill
```

`pathExists (entryPath + "/SKILL.md")` returns `false`, so the broken entry is ignored and not added to the catalog.
