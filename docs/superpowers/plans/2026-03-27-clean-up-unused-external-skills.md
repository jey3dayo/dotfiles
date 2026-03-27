# Clean Up Unused External Skills Vendored Copies

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

Goal: Remove unused `agents/external/` vendored copies and deprecated `localPath`/`localSkillsPath` code paths, consolidating all external skill acquisition through Nix flake inputs.

Architecture: Two-phase cleanup: (1) Delete inactive `agents/external/` directory, (2) Remove dead code paths from Nix lib/module and update documentation. Skills are already available via flake inputs (`agent-skills-sources.nix`), so this is pure cleanup without functional changes.

Tech Stack: Nix flake, Home Manager, bash utilities (ls, diff, rg, nix run)

---

## File Structure Map

### Deleted

- `agents/external/` — Entire directory (9 skill dirs + .gitkeep)

### Modified (Nix code)

- `agents/nix/lib.nix` — Remove `localPath` parameter, local scanning logic, simplify `discoverCatalog`
- `agents/nix/module.nix` — Remove `localSkillsPath` option, update `discoverCatalog` call, remove `localSkillIds`, preserve null-safe `enableList`
- `flake.nix` — Update `discoverCatalog` call (remove `localPath` arg)

### Modified (Documentation/Config)

- `agents/README.md` — Remove `agents/external/` section, update framing
- `mise/config.toml` — Remove `agents/external` from MD_EXCLUDES, TASK_EXCLUDES
- `.claude/rules/home-manager.md` — Remove `localSkillsPath` references (if present)
- `docs/tools/home-manager.md` — Update if references exist
- `docs/tools/nix.md` — Update if references exist
- Ignore configs (`.fdignore`, `.prettierignore`, etc.) — Remove `agents/external` patterns if present

---

## Task 1: Pre-implementation Verification

Files: None (verification only)

- [ ] **Step 1: Verify all 7 external skills exist in agent-skills-sources.nix**

Run: `grep -E "agent-browser|gh-address-comments|gh-fix-ci|skill-creator|ui-ux-pro-max|react-best-practices|web-design-guidelines" /Users/t00114/.config/nix/agent-skills-sources.nix | grep "selection.enable"`

Expected: All 7 skills appear in `selection.enable` lists

- [ ] **Step 2: Save current skills list for comparison**

Run: `ls ~/.claude/skills/ > /tmp/before.txt`

Expected: File created with current skills

- [ ] **Step 3: Confirm localPath is null in current config**

Run: `grep -A2 "discoverCatalog" /Users/t00114/.config/flake.nix | grep localPath`

Expected: `localPath = null;`

---

## Task 2: Delete agents/external/ Directory

### Files

- Delete: `agents/external/` (entire directory)

- [ ] **Step 1: Delete the directory**

Run: `rm -rf /Users/t00114/.config/agents/external/`

Expected: Directory removed

- [ ] **Step 2: Verify no skills were lost (deployment still works)**

Run: `home-manager switch --flake ~/.config --impure`

Expected: Build succeeds

- [ ] **Step 3: Compare skills list (should be identical)**

Run: ```bash
ls ~/.claude/skills/ > /tmp/after.txt
diff /tmp/before.txt /tmp/after.txt

````

Expected: No diff (all skills still present)

- [ ] **Step 4: Commit Phase 1**

Run: ```bash
git add -A
git commit -m "refactor(agents): remove agents/external/ directory

- All external skills are available via Nix flake inputs
- localPath=null means this directory was not active in distribution
- 7 skills confirmed in agent-skills-sources.nix selection.enable
- codex-system and gemini-system already in agents/internal/skills/"
````

---

## Task 3: Remove localPath from lib.nix discoverCatalog

### Files

- Modify: `agents/nix/lib.nix:244-281`

- [ ] **Step 1: Read the discoverCatalog function**

Run: `sed -n '244,281p' /Users/t00114/.config/agents/nix/lib.nix`

Expected: See current function with localPath parameter

- [ ] **Step 2: Remove localPath parameter and localSkills scanning**

Replace L244-281 with:

```nix
  # Discover all available skills from sources + distributions
  # Returns: { skillId = { id, path, source }; ... }
  discoverCatalog =
    {
      sources,
      distributionsPath ? null,
    }:
    let
      # Scan distributions first (if provided)
      distributionResult =
        if distributionsPath != null && pathExists distributionsPath then
          scanDistribution distributionsPath
        else
          {
            skills = { };
            commands = null;
            config = null;
            rules = { };
            agents = { };
          };

      # Scan each flake input source (last-wins on duplicate skill IDs)
      externalSkills = builtins.foldl' (
        acc: srcName:
        let
          src = sources.${srcName};
          scanned = scanSourceAutoDetect srcName src;
        in
        acc // scanned
      ) { } (attrNames sources);

      # Priority: distribution (internal) > external (flake inputs)
      # Nix // operator is right-biased, so left side wins on conflicts.
      # agents/internal skills override flake input skills on duplicate IDs.
    in
    distributionResult.skills // externalSkills;
```

- [ ] **Step 3: Verify syntax**

Run: `nix eval .#lib --file /Users/t00114/.config/agents/nix/lib.nix 2>&1 | head -5`

Expected: No syntax errors (may show attrset content)

- [ ] **Step 4: Verify comment reflects new priority**

Run: `grep "Priority:" /Users/t00114/.config/agents/nix/lib.nix`

Expected: `# Priority: distribution > external sources`

---

## Task 4: Remove localSkillsPath option from module.nix

### Files

- Modify: `agents/nix/module.nix` (line varies, search for `localSkillsPath`)

- [ ] **Step 1: Find localSkillsPath option definition**

Run: `grep -n "localSkillsPath" /Users/t00114/.config/agents/nix/module.nix | head -5`

Expected: Shows line numbers (typically around L30, L33, L42)

- [ ] **Step 2: Remove localSkillsPath option (use grep to locate exact section)**

Find the option definition block (look for `localSkillsPath = mkOption {`)

Delete the entire option definition block (typically 5-10 lines)

Expected: Option removed from config options

- [ ] **Step 3: Update discoverCatalog call to remove localPath argument**

Find: `localPath = cfg.localSkillsPath;` in the `discoverCatalog` call

Replace the call with:

```nix
  catalog = agentLib.discoverCatalog {
    inherit (cfg) sources distributionsPath;
  };
```

Expected: No `localPath` in call

- [ ] **Step 5: Remove localSkillIds variable**

Find and delete: `localSkillIds = lib.attrNames (lib.filterAttrs (_: skill: skill.source == "local") catalog);`

Expected: Variable removed

- [ ] **Step 6: Update enableList to remove localSkillIds reference (preserve null-safety)**

Find the `enableList` calculation (should be around L38-42)

Replace with:

```nix
  enableList =
    if cfg.skills.enable == null then
      distributionSkillIds  # Only distribution skills when no selection
    else
      lib.unique (cfg.skills.enable ++ distributionSkillIds);
```

Expected: Null-safe logic preserved, localSkillIds reference removed

- [ ] **Step 7: Verify Nix syntax**

Run: `nix-instantiate --eval /Users/t00114/.config/agents/nix/module.nix 2>&1 | head -3`

Expected: No syntax errors

---

## Task 5: Update flake.nix discoverCatalog call

### Files

- Modify: `flake.nix:158-161`

- [ ] **Step 1: Find discoverCatalog call in flake.nix**

Run: `grep -n -A3 "discoverCatalog" /Users/t00114/.config/flake.nix | head -10`

Expected: Shows L158-161 with `localPath = null;`

- [ ] **Step 2: Remove localPath argument**

Replace:

```nix
            catalog = agentLib.discoverCatalog {
              inherit sources;
              localPath = null;
              distributionsPath = ./agents/internal;
            };
```

With:

```nix
            catalog = agentLib.discoverCatalog {
              inherit sources;
              distributionsPath = ./agents/internal;
            };
```

Expected: `localPath = null;` line removed

- [ ] **Step 3: Verify flake eval**

Run: `nix flake check ~/.config 2>&1 | grep -E "error|warning" | head -5`

Expected: No errors (warnings ok)

---

## Task 6: Test Nix changes before committing

Files: None (testing only)

- [ ] **Step 1: Build with Nix changes**

Run: `home-manager switch --flake ~/.config --impure 2>&1 | tail -20`

Expected: Build succeeds, no errors about missing localPath

- [ ] **Step 2: Verify skills still present**

Run: ```bash
ls ~/.claude/skills/ > /tmp/after-phase2.txt
diff /tmp/before.txt /tmp/after-phase2.txt

````

Expected: No diff

- [ ] **Step 3: Visualize source hierarchy**

Run: `nix run .#report 2>&1 | grep -A5 "source\|distribution" | head -20`

Expected: No "local" source in output

---

## Task 7: Update agents/README.md

**Files:**

- Modify: `agents/README.md`

- [ ] **Step 1: Find agents/external section in README**

Run: `grep -n "external" /Users/t00114/.config/agents/README.md | head -10`

Expected: Shows section references

- [ ] **Step 2: Remove or update agents/external section**

Remove the entire section describing `agents/external/`

If present, replace "Internal vs External" framing with "Sources (flake inputs) vs Distribution (internal)"

Expected: No mentions of agents/external/ directory

- [ ] **Step 3: Update directory tree diagram**

Look for a tree diagram showing `agents/external/`

Remove `external/` from the diagram, ensure `internal/` and `n/` are present

Expected: Updated tree diagram

---

## Task 8: Update mise/config.toml ignore patterns

**Files:**

- Modify: `mise/config.toml:31-32`

- [ ] **Step 1: Find agents/external in config**

Run: `grep -n "agents/external" /Users/t00114/.config/mise/config.toml`

Expected: Shows L31-32 with `#agents/external` in MD_EXCLUDES and TASK_EXCLUDES

- [ ] **Step 2: Remove agents/external from MD_EXCLUDES**

Find line: `MD_EXCLUDES = "... #agents/external ..."`

Remove ` #agents/external` from the excludes list

- [ ] **Step 3: Remove agents/external from TASK_EXCLUDES**

Find line: `TASK_EXCLUDES = "--exclude agents/external ..."`

Remove `--exclude agents/external` from the excludes list

Expected: Both exclude patterns removed

---

## Task 9: Check and update rule files

**Files:**

- Check: `.claude/rules/home-manager.md`
- Check: `docs/tools/home-manager.md`
- Check: `docs/tools/nix.md`

- [ ] **Step 1: Search for agents/external or localSkillsPath references**

Run: ```bash
rg -n "agents/external|localSkillsPath" .claude/rules/ docs/tools/ 2>/dev/null
```

Expected: Shows any remaining references

- [ ] **Step 2: Update found references**

For each file found:

- Remove or update references to `agents/external/`
- Remove or update references to `localSkillsPath`
- Replace "Internal vs External" with "Sources vs Distribution" if present

- [ ] **Step 3: Verify no hardcoded references remain**

Run: `rg -n "agents/external" --type md`

Expected: Only hits in git history or this plan

---

## Task 10: Check and update ignore config files

**Files:**

- Check: `.fdignore`, `.prettierignore`, `.pre-commit-config.yaml`, `.markdownlint-cli2.jsonc`, `biome.json`

- [ ] **Step 1: Search for agents/external patterns in ignore files**

Run: ```bash
rg -l "agents/external" .fdignore .prettierignore .pre-commit-config.yaml .markdownlint-cli2.jsonc biome.json 2>/dev/null
```

Expected: Lists files containing the pattern (may be none)

- [ ] **Step 2: Remove agents/external from each found file**

For each file listed:

- Edit to remove `agents/external` pattern
- Preserve structure (don't break other patterns)

Expected: Pattern removed from ignore files

---

## Task 11: Final verification and quality checks

**Files:** None (verification only)

- [ ] **Step 1: Run quality checks**

Run: `mise run ci`

Expected: All checks pass (format, lint, etc.)

- [ ] **Step 2: Final distribution test**

Run: `home-manager switch --flake ~/.config --impure`

Expected: Build succeeds

- [ ] **Step 3: Verify no residual references**

Run: ```bash
rg -n "agents/external|localSkillsPath" . --type-add 'nix:*.nix' -t nix -t md -t toml -t yaml -t json
```

Expected: Only hits in git history, spec files, or plan files

- [ ] **Step 4: Verify skills deployment**

Run: ```bash
ls ~/.claude/skills/ | wc -l
nix run .#report 2>&1 | grep "skills:" | head -5
```

Expected: Skills count stable, no "local" source

---

## Task 12: Commit Phase 2+3 changes

**Files:** All modified from Task 3-11

- [ ] **Step 1: Stage all changes**

Run: `git add -A`

Expected: All changes staged

- [ ] **Step 2: Review diff**

Run: `git diff --cached --stat`

Expected: Shows modified files (lib.nix, module.nix, flake.nix, docs, configs)

- [ ] **Step 3: Commit**

Run: ```bash
git commit -m "refactor(nix): remove localPath/localSkillsPath and update docs

- Remove localPath parameter from discoverCatalog (lib.nix)
- Remove localSkillsPath option from module.nix
- Update enableList to preserve null-safety without localSkillIds
- Remove localPath from flake.nix discoverCatalog call
- Update agents/README.md to remove agents/external section
- Remove agents/external from mise/config.toml ignore patterns
- Update rule/doc files to remove obsolete references

Phase 2+3 bundled to prevent intermediate broken states.
All external skills available via Nix flake inputs (agent-skills-sources.nix)."
```

Expected: Commit created

---

## Task 13: Post-implementation cleanup

**Files:** None

- [ ] **Step 1: Clean up temporary comparison files**

Run: `rm -f /tmp/before.txt /tmp/after.txt /tmp/after-phase2.txt`

Expected: Temp files removed

- [ ] **Step 2: Verify git log**

Run: `git log --oneline -3`

Expected: Shows 2 new commits (Phase 1, Phase 2+3)

- [ ] **Step 3: Final smoke test**

Run: ```bash
nix-collect-garbage -d
home-manager switch --flake ~/.config --impure
ls ~/.claude/skills/ | sort | head -20
```

Expected: Clean build, skills list looks correct

---

## Verification Summary

**Success criteria:**

- ✅ `agents/external/` directory deleted
- ✅ No `localPath` in Nix code (lib.nix, module.nix, flake.nix)
- ✅ No `localSkillsPath` in module.nix
- ✅ `enableList` preserves null-safety
- ✅ All skills still deployed via `~/.claude/skills/`
- ✅ No residual references to `agents/external` or `localSkillsPath`
- ✅ Quality checks pass (`mise run ci`)
- ✅ Home Manager switch succeeds

**Rollback if needed:**

```bash
git reset --hard HEAD~2  # Rollback both commits
home-manager switch --flake ~/.config --impure
```
````
