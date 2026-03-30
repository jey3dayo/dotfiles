---
name: rtk
description: Use when Codex should reduce CLI context noise with RTK, decide whether to prefix commands with `rtk`, set up `rtk init`, inspect `rtk gain`, or maintain `.rtk/filters.toml` in repositories that use RTK.
---

# RTK

## Overview

Use RTK to compress noisy CLI output before it reaches the model context window. Prefer it for token-heavy external commands such as test runners, build tools, git, GitHub CLI, package managers, and file/search commands.

Read `references/command-reference.md` when you need the detailed command families, install options, or this repository's integration points.

## Quick Workflow

1. Confirm whether the repository already uses RTK.
   - Look for `.rtk/filters.toml`, `rtk` in tool configs, or existing RTK-specific rules.
2. Prefer `rtk <command>` for external commands that emit large or repetitive output.
3. If RTK is installed globally, run `rtk init --global` so the hook can transparently rewrite supported Bash commands.
4. Run `rtk gain` or `rtk gain --history` to verify the benefit and identify the noisiest commands.
5. If RTK filtering hides information you need for debugging, switch that command to `rtk proxy <command>`.

## Prefer RTK For

- Test, build, and check commands such as `cargo test`, `vitest run`, `playwright test`, `tsc`, `next build`, and lint commands
- Git and GitHub commands such as `git status`, `git diff`, `git log`, `gh pr view`, and `gh pr checks`
- JS and TS package tooling such as `pnpm install`, `pnpm outdated`, `npm run <script>`, and `npx <cmd>`
- File and search exploration such as `ls`, `read`, `grep`, and `find`
- Container and orchestration logs such as `docker logs`, `kubectl logs`, and `kubectl get`

## Use Raw Commands Carefully

Use raw commands, or `rtk proxy <command>`, when:

- The command is a shell builtin or mutates shell session state
- The command output is already tiny and wrapping adds no value
- You need raw, unfiltered output to debug formatter or filter behavior
- The current shell hook does not cover the command and explicit wrapping is clearer

Do not assume every shell builtin behaves correctly through a subprocess wrapper.

## Setup

### Install RTK

Choose the install path that matches the repository or machine:

- Run `mise install` when the active mise config already declares `rtk`
- Run `brew install rtk` on macOS or Linux when Homebrew is the standard tool path
- Use the official install script or release binaries when `mise` or Homebrew are not the right fit

### Enable Automatic Rewriting

```bash
rtk init --global
```

This installs the PreToolUse hook so supported Bash commands are automatically rewritten to RTK equivalents.

### Verify Savings

```bash
rtk gain
rtk gain --history
```

Use the savings output as operational evidence, not just as a vanity metric.

## Filters

Project-local filters live in `.rtk/filters.toml`. Update filters when:

- A frequently used command still emits too much boilerplate
- A project-specific tool has stable noise that can be stripped safely
- You want a compact success path without hiding actionable failures

Keep filters conservative. Remove repeated noise, not real errors.

## This Repository

In this repository:

- RTK itself is already declared in `mise/config.default.toml` and `mise/config.windows.toml`
- Project-local RTK filters live in `.rtk/filters.toml`
- Bundled skills under `agents/src/skills/<name>/` are picked up by the existing skill distribution flow

For this repo, validate or distribute a bundled RTK skill with the existing tasks:

- `mise run skills:validate:internal`
- `mise run skills:validate`
- `mise run skills:install`
- `mise run skills:install:windows:codex`

Do not add a new `mise` task unless the existing distribution flow cannot pick the skill up.

## Example

```bash
rtk git status
rtk git diff
rtk vitest run
rtk tsc
rtk gain
```

## Common Mistakes

- Wrapping every shell builtin blindly and assuming shell state will persist
- Using raw `git`, `gh`, `test`, or `lint` commands in RTK-enabled repositories out of habit
- Forgetting `rtk proxy <command>` when filtered output is too compact to debug
- Editing `.rtk/filters.toml` aggressively enough to remove real failures
- Treating `rtk gain` as marketing only instead of validating actual workflow benefit
