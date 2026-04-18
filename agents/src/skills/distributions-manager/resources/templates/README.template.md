# [Bundle Name]

[Brief description of bundle purpose and target workflow/team]

---

## Contents

### Skills

- [skill-name]: [Brief description]
- [skill-name]: [Brief description]

### Rules

- [rule-name]: [Brief description]

### Agents

- [agent-name]: [Brief description]

### Configuration

- `config/shared-rules.md`: [Description]
- `config/bundle-config.json`: [Description]

---

## Installation

This bundle is intended to be used as a `distributionsPath`.

```bash
mise run agents:legacy:install
```

## Verification

```bash
mise run agents:legacy:list 2>/dev/null | jq '.skills[] | {id, source}'
ls -la ~/.claude/skills/
ls -la ~/.claude/agents/
ls -la ~/.claude/rules/
```

---

## Usage

[Describe the intended workflow]

## Maintenance

### Adding A Skill

```bash
cd bundles/[bundle-name]/skills
ln -s ../../../src/skills/[new-skill] ./
mise run agents:legacy:install
```

### Replacing A Reused Skill With A Bundle-Specific Copy

```bash
cd bundles/[bundle-name]/skills
rm [skill-name]
cp -R ../../../src/skills/[skill-name] ./
$EDITOR [skill-name]/SKILL.md
```

### Adding A Rule

```bash
cd bundles/[bundle-name]/rules
ln -s ../../../src/rules/[rule-name].md ./
```

### Adding An Agent

```bash
cd bundles/[bundle-name]/agents
ln -s ../../../src/agents/[agent-name].md ./
```

---

## Notes

- Use `agents/src/` as the base when reusing bundled assets
- Prefer relative symlinks
- Do not reference removed legacy layer paths
- Bundled `commands/` is not part of the active Home Manager deployment path
