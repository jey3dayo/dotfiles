# RTK Command Reference

## Why RTK

RTK is a CLI proxy that compresses command output before it reaches the model context window. The official site highlights average noise reduction around 89 percent and shows a typical 2-hour AI coding session dropping from roughly 210K CLI noise tokens to about 23K after RTK filtering.

Use that framing when you need to justify RTK adoption: it protects context budget, stretches session length, and lowers token cost on CLI-heavy workflows.

## High-Value Commands

Prefer these command families first because they usually produce the most repeated boilerplate:

- Build and checks: `rtk cargo build`, `rtk cargo check`, `rtk cargo clippy`, `rtk tsc`, `rtk lint`, `rtk prettier --check`, `rtk next build`
- Tests: `rtk cargo test`, `rtk vitest run`, `rtk playwright test`, `rtk test "<raw test command>"`
- Git: `rtk git status`, `rtk git diff`, `rtk git log`, `rtk git show`, `rtk git add`, `rtk git commit`, `rtk git push`
- GitHub: `rtk gh pr view <num>`, `rtk gh pr checks`, `rtk gh run list`, `rtk gh issue list`, `rtk gh api`
- JS and TS tooling: `rtk pnpm install`, `rtk pnpm list`, `rtk pnpm outdated`, `rtk npm run <script>`, `rtk npx <cmd>`, `rtk prisma`
- File and search: `rtk ls <path>`, `rtk read <file>`, `rtk grep <pattern>`, `rtk find <pattern>`
- Infra: `rtk docker ps`, `rtk docker images`, `rtk docker logs <container>`, `rtk kubectl get`, `rtk kubectl logs`

## Operational Commands

- `rtk gain`: show aggregate token savings
- `rtk gain --history`: show command history and savings trends
- `rtk discover`: detect places where RTK was not used in a Claude Code session
- `rtk proxy <cmd>`: bypass filtering for one command while keeping the same entry point
- `rtk init`: add project-level RTK instructions
- `rtk init --global`: install the global PreToolUse hook

## Installation Paths

Choose one install path based on the environment:

- `mise install` when `rtk` is already declared in the active mise config
- `brew install rtk` and `brew upgrade rtk` on macOS or Linux
- Official install script on Linux or macOS
- Pre-built release binaries on macOS, Linux, or Windows

After installation, run:

```bash
rtk init --global
rtk gain
```

## Filters

Project-local filters live in `.rtk/filters.toml`.

Good filter candidates:

- Stable download or install chatter
- Repeated success lines
- Project-specific prefixes that add no debugging value

Bad filter candidates:

- Stack traces
- Error summaries
- Per-file failures that the model needs to fix the issue

## Repository Notes

In this repository:

- `mise/config.default.toml` and `mise/config.windows.toml` already declare `rtk = "latest"`
- `.rtk/filters.toml` is the project-local override point
- Bundled skills placed under `agents/src/skills/` are distributed by the existing tasks in `mise/tasks/skills.toml`

Useful commands here:

- `mise run skills:validate:internal`
- `mise run skills:validate`
- `mise run skills:legacy:install`
