---
paths:
  - "docs/**/*.md"
  - "README.md"
  - "CLAUDE.md"
---

# Documentation Rules

Purpose: keep documentation governance rules concise for Claude. Scope: metadata and duplication control for `docs/`; SSOT boundaries live in `docs/documentation.md`.
Sources: docs/documentation.md.

Detailed Reference: [docs/documentation.md](../../docs/documentation.md)

## Metadata

- All `docs/**/*.md` use OKF-compatible YAML frontmatter as canonical metadata
- Required OKF field: `type`
- Recommended OKF fields: `title`, `description`, `resource`, `tags`, `timestamp`, `audience`, `owner`
- Use `timestamp` as `YYYY-MM-DD`
- Use 3-5 tags and include at least one `category/` and one `layer/`
- Do not add legacy body metadata (`最終更新`, `対象`, `タグ`); if any remains, treat frontmatter as canonical and remove the legacy block

## Rule authoring

- Keep `.claude/rules/**/*.md` compact
- When a rule is derived from `docs/`, keep `source:` or `Sources:` aligned with that canonical file
- Store long procedures, examples, tables, and histories in `docs/`, not in rules

## Update workflow

- Update the canonical `docs/` file first
- Sync the compact rule only if needed
- Refresh `timestamp` and keep links consistent
- Avoid bold-only headings or bold list labels (`scripts/replace-bold-headings.ts` enforces plain headings/labels)
- Run `mise run format:markdown:check` after edits
- Search for duplicate text before adding new prose

## Size guidance

- Target <=500 lines per doc; warn at 1000, mandatory split plan at 2000.

## Duplication control

- Tool versions live in `mise/*.toml`. Docs keep WHY (fixed for breaking changes, etc.) but not version numbers.

## Frontmatter note

- Use YAML frontmatter with `paths` as a list in rule files
- Keep brace globs quoted
- Navigation docs may use `type: index`; keep them link-oriented and avoid detailed procedures
