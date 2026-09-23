---
paths: docs/**/*.md, README.md, CLAUDE.md
---

# Documentation Rules

Purpose: keep documentation governance rules concise for Claude. Scope: metadata and duplication control for `docs/`; SSOT boundaries live in `docs/documentation.md`.
Sources: docs/documentation.md.

Detailed Reference: [docs/documentation.md](../../docs/documentation.md)

## Metadata

- New or substantially updated `docs/**/*.md` should use OKF-compatible YAML frontmatter as canonical metadata
- Required OKF field: `type`
- Recommended OKF fields: `title`, `description`, `resource`, `tags`, `timestamp`, `audience`, `owner`
- Existing `最終更新`, `対象`, `タグ` blocks remain valid legacy aliases during migration
- Use `timestamp` / `最終更新` as `YYYY-MM-DD`
- Use 3-5 tags and include at least one `category/` and one `layer/`
- If frontmatter and legacy metadata both exist, frontmatter is canonical and conflicts must be fixed

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
- Navigation docs may use `type: index`; keep them link-oriented and avoid detailed procedures
