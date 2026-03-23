---
paths: docs/**/*.md, README.md, CLAUDE.md, TOOLS.md, global_rules.md
---

# Documentation Rules

Purpose: keep documentation governance rules concise for Claude. Scope: metadata, SSOT boundaries, and duplication control for `docs/`.
Sources: docs/documentation.md.

Detailed Reference: [docs/documentation.md](../../docs/documentation.md)

## Metadata

- All Markdown docs under `docs/` (`docs/**/*.md`) must include `最終更新`, `対象`, `タグ`
- Date format: `YYYY-MM-DD`
- Use 3-5 tags and include at least one `category/` and one `layer/`

## SSOT boundaries

- Setup: `docs/setup.md`
- Performance metrics/history: `docs/performance.md`
- Maintenance and cross-cutting troubleshooting: `docs/tools/workflows.md`
- Tool details: `docs/tools/*.md`
- Documentation system itself: `docs/documentation.md`

`README.md`, `TOOLS.md`, and `docs/README.md` are navigation only. Do not turn them into procedural or metrics-heavy docs.

## Rule authoring

- Keep `.claude/rules/**/*.md` compact
- When a rule is derived from `docs/`, keep `source:` or `Sources:` aligned with that canonical file
- Store long procedures, examples, tables, and histories in `docs/`, not in rules

## Update workflow

- Update the canonical `docs/` file first
- Sync the compact rule only if needed
- Refresh `最終更新` and keep links consistent
- Search for duplicate text before adding new prose

## Size guidance

- Target <=500 lines per doc; warn at 1000, mandatory split plan at 2000.

## Frontmatter note

- Use YAML frontmatter with `paths` as a list in rule files
- Keep brace globs quoted
