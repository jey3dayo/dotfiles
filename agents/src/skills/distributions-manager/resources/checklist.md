# Distribution Bundle QA Checklist

## Pre-Creation

- [ ] Bundle purpose is clear
- [ ] Target workflow or team is identified
- [ ] You know which bundled assets are needed
- [ ] You understand the current priority model: Distribution > External
- [ ] You understand that bundled `commands/` is not deployed by the current Home Manager module

---

## Structure

- [ ] Bundle directory exists under `bundles/<bundle-name>/`
- [ ] `skills/` exists when bundling skills
- [ ] `rules/` exists when bundling rules
- [ ] `agents/` exists when bundling agents
- [ ] `config/` exists only if needed
- [ ] `README.md` exists at bundle root

---

## Skills

- [ ] Every skill entry is either:
  - [ ] a direct skill directory containing `SKILL.md`
  - [ ] a symlink to a valid source such as `../../../src/skills/<skill>`
- [ ] No absolute paths are used
- [ ] No removed legacy layer paths are referenced
- [ ] Broken symlinks check returns nothing

Validation:

```bash
find bundles/<bundle-name>/skills -type l -exec sh -c '
  target=$(readlink -f "$1")
  test -f "$target/SKILL.md" || echo "Missing SKILL.md: $1"
' _ {} \;
```

---

## Rules

- [ ] Every bundled rule is a valid markdown file
- [ ] Reused rules point to `agents/src/rules/...` or another real source path
- [ ] Nested rule paths are intentional

---

## Agents

- [ ] Every bundled agent is a valid markdown file or directory of markdown files
- [ ] Reused agents point to `agents/src/agents/...` or another real source path
- [ ] Nested agent paths are intentional

---

## Current Runtime Constraints

- [ ] Documentation does not claim `Local > External > Distribution`
- [ ] Documentation does not claim bundled `commands/` is deployed
- [ ] Documentation does not use removed legacy layer paths

---

## Verification

- [ ] `home-manager build --flake ~/.config --impure --dry-run` succeeds
- [ ] `mise run agents:legacy:install` succeeds
- [ ] `mise run agents:legacy:list 2>/dev/null | jq '.skills[] | {id, source}'` shows expected source attribution
- [ ] Bundled skills appear with `source = "distribution"`
- [ ] Bundled rules and agents are linked into target directories as expected

---

## Documentation

- [ ] README reflects the current contents
- [ ] Examples use `agents/src/` when referring to bundled source paths
- [ ] Templates do not mention removed layers
- [ ] Limitations are documented when a feature is not active in the runtime

---

## Cleanup

- [ ] No broken symlinks remain
- [ ] No stale historical examples were copied into active docs
- [ ] No generated deployment paths are referenced as source inputs
