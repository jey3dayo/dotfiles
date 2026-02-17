# Priority Mechanism

## Overview

The distributions layer introduces a three-tier priority system for skill and command resolution. This document explains the priority order, conflict resolution, and cyclic reference prevention.

---

## Priority Order

```
Local > External > Distribution
```

### Meaning

- **Local** (`skills-internal/`, `commands-internal/`): Highest priority, overwrites all
- **External** (`skills/`): Medium priority, overwrites Distribution
- **Distribution** (`internal/`): Lowest priority, default fallback

---

## Nix Implementation

### Right-Associative Merge

```nix
# agents/nix/lib.nix (simplified)
discoverCatalog = { distributionsPath, ... }:
  let
    distributionSkills = scanDistribution (distributionsPath + "/skills");
    externalSkills = scanExternal skillsExternalPath;
    localSkills = scanSource "local" skillsPath;
  in
    # Right-associative // operator
    distributionSkills // externalSkills // localSkills;
```

### Evaluation order

```nix
# Step 1: Merge Distribution and External
temp = distributionSkills // externalSkills;
# Step 2: Merge temp and Local
final = temp // localSkills;
```

### Result

---

## Conflict Resolution

### Scenario 1: Same Skill in All Sources

```
internal/skills/react/  (Distribution)
skills/react/                        (External)
skills-internal/react/               (Local)
```

### Resolution

```nix
{
  react = { id = "react"; path = /path/to/skills-internal/react; source = "local"; };
}
```

### Winner

---

### Scenario 2: Skill in Distribution + External Only

```
internal/skills/ui-ux-pro-max/  (Distribution)
skills/ui-ux-pro-max/                        (External)
```

### Resolution

```nix
{
  ui-ux-pro-max = { id = "ui-ux-pro-max"; path = /path/to/skills/ui-ux-pro-max; source = "external"; };
}
```

### Winner

---

### Scenario 3: Skill in Distribution Only

```
internal/skills/custom-skill/  (Distribution)
```

### Resolution

```nix
{
  custom-skill = { id = "custom-skill"; path = /path/to/bundles/.../custom-skill; source = "distribution"; };
}
```

### Winner

---

## Use Cases

### Use Case 1: Override Distribution Default

### Scenario

### Solution

```bash
# Create local override
cp -r internal/skills/react/ skills-internal/react/
# Modify skills-internal/react/SKILL.md

# Result: Local version takes precedence
```

---

### Use Case 2: Test External Skill Before Localizing

### Scenario

### Solution

```bash
# Add to skills/ (External)
git clone https://github.com/user/skill.git skills/my-skill

# Test
mise run skills:list | grep my-skill

# If satisfied, move to skills-internal/
mv skills/my-skill skills-internal/
```

---

### Use Case 3: Distribution as Fallback

### Scenario

### Solution

```bash
# Distribution provides baseline
internal/skills/baseline-skill/

# Users can override by creating:
skills-internal/baseline-skill/
```

---

## Cyclic Reference Prevention

### Problem

If bundles reference sources, and sources reference bundles:

```
bundles/ → skills-internal/ → bundles/ (loop)
```

### Solution: Static Scanning

### Distributions are scanned BEFORE sources

```nix
# Scan order
1. distributionSkills = scanDistribution(...)  # Static paths only
2. externalSkills = scanExternal(...)
3. localSkills = scanSource(...)
```

### Key insight

---

### Path Resolution

```nix
# Distribution symlink
internal/skills/my-skill → ../../../skills-internal/my-skill

# Nix resolves at filesystem level:
readDir (distributionsPath + "/skills")
# → { "my-skill" = "symlink"; }

pathExists (entryPath + "/SKILL.md")
# → Checks /path/to/skills-internal/my-skill/SKILL.md

# No evaluation loop: symlink target is not evaluated by Nix
```

---

## Debugging Priority Issues

### Check Source Attribution

```bash
# List all skills with sources
mise run skills:list 2>/dev/null | jq '.skills[] | {id, source}'

# Expected output:
# {"id": "react", "source": "local"}        (from skills-internal/)
# {"id": "ui-ux", "source": "external"}     (from skills/)
# {"id": "custom", "source": "distribution"} (from bundles/)
```

---

### Verify Precedence

```bash
# Check which version is deployed
ls -la ~/.claude/skills/react

# Expected: symlink to skills-internal/ (not bundles/)
# ~/.claude/skills/react -> /path/to/skills-internal/react
```

---

### Trace Nix Evaluation

```bash
# Evaluate catalog with trace
nix eval --show-trace --json --impure --expr '
  let
    lib = import ~/.config/agents/nix/lib.nix { inherit (import <nixpkgs> {}) lib; };
    catalog = lib.discoverCatalog {
      distributionsPath = ~/.config/agents/internal;
      skillsPath = ~/.config/agents/internal/skills;
      skillsExternalPath = ~/.config/agents/external;
    };
  in
    catalog.skills.react
' | jq
```

---

## Best Practices

1. **Use distributions for defaults**: Provide baseline skills/commands
2. **Override locally for customization**: Create local versions in `skills-internal/`
3. **Test externally before localizing**: Use `skills/` for evaluation
4. **Document overrides**: Note which skills are overridden in README
5. **Avoid distribution-to-distribution links**: Keeps priority simple

---

## Priority Matrix

| Skill Location     | Priority | Source Tag     | Overwrites      |
| ------------------ | -------- | -------------- | --------------- |
| `skills-internal/` | Highest  | `local`        | All             |
| `skills/`          | Medium   | `external`     | Distribution    |
| `internal/skills/` | Lowest   | `distribution` | None (fallback) |

---

## Edge Cases

### Edge Case 1: Same Skill in Distribution via Different Paths

```
internal/skills/react → ../../../skills-internal/react
internal/skills/react-copy → ../../../skills-internal/react
```

### Result

### Behavior

---

### Edge Case 2: Distribution Symlink to External

```
internal/skills/my-skill → ../../../skills/my-skill
```

### Priority

- Distribution entry: `source = "distribution"`
- External entry: `source = "external"`

### Winner

### Effect

---

### Edge Case 3: Broken Symlink in Distribution

```
internal/skills/broken → ../../../skills-internal/nonexistent
```

### Nix behavior

```nix
pathExists (entryPath + "/SKILL.md")
# → false (symlink broken)

# Entry is skipped, no error
```

### Validation

---

## Related References

- **architecture.md**: Nix merge implementation
- **creating-bundles.md**: Bundle creation considering priority
- **symlink-patterns.md**: Symlink design patterns
- **resources/checklist.md**: Validation checklist (Priority section)
