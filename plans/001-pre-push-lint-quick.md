# Plan 001: Pre-push hook uses fast lint instead of full network-dependent lint

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise. When done, update the status row for this plan
> in `plans/README.md` — unless a reviewer dispatched you and told you they
> maintain the index.
>
> **Drift check (run first)**: `git diff --stat fedff82f..HEAD -- lefthook.yml mise/local-tasks/integration.toml mise/local-tasks/ci.toml`
> If any in-scope file changed since this plan was written, compare the
> "Current state" excerpts against the live code before proceeding; on a
> mismatch, treat it as a STOP condition.

## Status

- **Priority**: P1
- **Effort**: S
- **Risk**: LOW
- **Depends on**: none
- **Category**: dx
- **Planned at**: commit `fedff82f`, 2026-07-14

## Why this matters

Every `git push` currently runs `mise run check:lint`, which resolves to the
full `lint` task including `lint:links` — a slow, network-dependent Markdown
link checker (per its own comment: "時間がかかるため個別実行推奨" / "slow,
recommend running individually"). This makes every push pay for an external
network check unrelated to the pushed diff, and makes pushes flaky when the
network is slow or a link check flakes. A faster `lint:quick` task (excludes
`lint:links`) already exists and is the documented recommendation for this
exact situation, but the git hook was never wired to use it.

## Current state

- `lefthook.yml:79-90` — the `pre-push` block's `lint` command runs
  `mise run check:lint`:

  ```yaml
  pre-push:
    parallel: true
    commands:
      format:
        run: mise run check:format
      lint:
        run: mise run check:lint
      test-ts:
        run: mise run test:ts
      test-lua:
        run: mise run test:lua
      gitleaks:
        run: mise run ci:gitleaks
  ```

- `mise/local-tasks/integration.toml` defines the task chain:
  - `[lint]` (line 29) — full lint, includes `lint:links`. Comment at line 31:
    "高速版は lint:quick を使うこと（lint:links 除外、~3-5s）。" (use the fast
    version `lint:quick` — excludes `lint:links`, ~3-5s).
  - `["lint:quick"]` (line 45) — the fast alternative, excludes `lint:links`.
  - `["check:lint"]` (line 73) — `run = [{ task = "lint" }]` (the slow one).
  - `["check:lint:quick"]` (line 77) — `run = [{ task = "lint:quick" }]` (the
    fast one, line 79).

- The repo's own documentation already tells contributors to prefer
  `lint:quick` for anything time-sensitive. `lint:links` remains valuable —
  just not on every push — and should continue to run via the full `mise run
ci:full` / CI pipeline (verify this is the case: `grep -n "lint:links\|ci:full"
mise/local-tasks/ci.toml`).

## Commands you will need

| Purpose        | Command                     | Expected on success           |
| -------------- | --------------------------- | ----------------------------- |
| Run fast lint  | `mise run check:lint:quick` | exit 0                        |
| Run full lint  | `mise run check:lint`       | exit 0 (slower, for contrast) |
| Lefthook check | `lefthook run pre-push`     | all commands pass             |

## Scope

**In scope** (the only files you should modify):

- `lefthook.yml`

**Out of scope** (do NOT touch, even though they look related):

- `mise/local-tasks/integration.toml` — the task definitions themselves are
  correct and don't need changing; only the hook wiring is wrong.
- `mise/local-tasks/ci.toml` — CI's own full-check task should keep running
  `lint:links`; do not remove `lint:links` from anywhere, only stop it from
  gating every local push.

## Git workflow

- Branch: `advisor/001-pre-push-lint-quick`
- Commit message style: conventional commits, e.g. `fix(lefthook): use fast lint on pre-push`
  (match `git log --oneline -10` style in this repo)
- Do NOT push or open a PR unless the operator instructed it.

## Steps

### Step 1: Point pre-push lint at the fast task

In `lefthook.yml`, change the `pre-push.commands.lint.run` line from
`mise run check:lint` to `mise run check:lint:quick`.

**Verify**: `grep -n "check:lint" lefthook.yml` → shows `check:lint:quick`
under the `pre-push` block's `lint` command, and the `pre-commit` block (if
it references `check:lint` elsewhere) is untouched — check with
`grep -n -B3 "check:lint" lefthook.yml` to confirm only the pre-push instance
changed.

### Step 2: Confirm the fast task still catches real lint errors

Run `mise run check:lint:quick` on the current tree.

**Verify**: `mise run check:lint:quick` → exit 0 (repo is currently clean per
recon; if it fails, that's a pre-existing issue — do not fix unrelated lint
errors, report it as a STOP condition instead since it means the current
tree state doesn't match this plan's assumption).

## Test plan

No new automated tests apply (this is a hook-wiring config change, not
application logic). Verification is the command re-run above, plus:

- `lefthook run pre-push` — exercises the full pre-push command set in
  parallel exactly as a real `git push` would, confirming lint no longer
  invokes `lint:links` (spot check: time the run, or temporarily add `-v` /
  check no network calls to markdown-link-check show up in output).

## Done criteria

Machine-checkable. ALL must hold:

- [ ] `lefthook.yml`'s `pre-push.commands.lint.run` reads `mise run check:lint:quick`
- [ ] `mise run check:lint:quick` exits 0
- [ ] `lefthook run pre-push` exits 0
- [ ] No files outside `lefthook.yml` are modified (`git status`)
- [ ] `plans/README.md` status row updated

## STOP conditions

Stop and report back (do not improvise) if:

- `lefthook.yml`'s pre-push block no longer looks like the "Current state"
  excerpt above (structure has changed since this plan was written).
- `mise run check:lint:quick` fails — this means there's a real lint issue in
  the tree unrelated to this plan; report it rather than fixing unrelated code.
- The `lint:quick` task no longer exists in `mise/local-tasks/integration.toml`.

## Maintenance notes

- If `lint:links` needs to run somewhere in the automated pipeline, confirm
  it's still invoked by `mise run ci:full` or the GitHub Actions workflow —
  it should not disappear entirely, only stop gating every local push.
- A reviewer should confirm no other lefthook command (`pre-commit`, etc.)
  was accidentally touched.
