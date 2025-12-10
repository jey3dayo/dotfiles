# Documentation Rules

Purpose: keep documentation governance rules concise for Claude. Scope: tagging, metadata, duplication control, and size limits for `docs/`.
Sources: docs/README.md.

## Required metadata
- Header fields must include `最終更新`, `対象`, and 3-5 prefixed tags (`category/`, `layer/`, `environment/`, `audience/`; add `tool/` when relevant).
- Date format is YYYY-MM-DD; update it on every content change.
- Include at least one `category/` and one `layer/` tag. Balance audience and environment tags for clarity.

## Tag vocabulary (short list)
- category: shell, editor, terminal, git, performance, integration, configuration, guide, reference, maintenance, documentation.
- tool: zsh, nvim, wezterm, tmux, git, fzf, ssh, mise, homebrew.
- layer: core (shell/git), tool (editor/terminal), support (performance/integration).
- environment: macos, linux, cross-platform. audience: developer, ops, beginner, advanced.

## Single source of truth boundaries
- Setup steps live in docs/setup.md; READMEs should link instead of repeating commands.
- Performance metrics and history live in docs/performance.md; other docs reference it without duplicating numbers.
- Maintenance schedules and troubleshooting live in docs/maintenance.md; repeat only pointers elsewhere.
- Tool details belong in docs/tools/*.md; cross-reference from other docs.
- Documentation governance stays in this file; keep docs/README.md as the lightweight human navigation page.

## Size and structure
- Target <=500 lines per doc; warn at 1000, mandatory split plan at 2000.
- Prefer dedicated files for Zsh/Neovim/WezTerm as the primary tools; split large docs by skill level or layer when needed.

## Update workflow
- On any doc change, refresh `最終更新`, validate tags, and keep links consistent with SSTs.
- Check for duplicate content against SST docs before adding text.
- Keep docs/README.md as navigation only; avoid embedding procedures or metrics there.

## Cross-link hygiene
- Maintain working internal links and avoid repeating data; rely on navigation docs for discovery.
- Note performance-impacting changes with a reference to docs/performance.md rather than copying values.
