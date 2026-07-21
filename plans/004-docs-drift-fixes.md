# Plan 004: Fix stale/broken documentation references

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise. When done, update the status row for this plan
> in `plans/README.md` — unless a reviewer dispatched you and told you they
> maintain the index.
>
> **Drift check (run first)**: `git diff --stat fedff82f..HEAD -- docs/tools/nix.md TOOLS.md .kiro/steering/structure.md .kiro/steering/tech.md .kiro/steering/product.md`
> If any in-scope file changed since this plan was written, compare the
> "Current state" excerpts against the live code before proceeding; on a
> mismatch, treat it as a STOP condition.

## Status

- Priority: P2
- Effort: S
- Risk: LOW
- Depends on: none
- Category: docs
- Planned at: commit `fedff82f`, 2026-07-14

## Why this matters

Four small, independent documentation drift issues were found during audit.
Each is low-cost to fix but actively misleads a reader (worse than a gap,
per the repo's docs standards): a dead link and dead task references in
`docs/tools/nix.md`, a wrong config filename in `TOOLS.md`, a stale
"Last Updated" header in `.kiro/steering/*.md` that understates how recently
those files were actually edited, and a missing pair of config filenames in
`tech.md`'s mise inventory. Bundling them into one plan is appropriate since
each fix is a single-line/paragraph edit with no interaction between them.

## Current state

### 4a. `docs/tools/nix.md` — dead link and removed task references

- Line 253 (in the "参考資料" section): ``- `docs/tools/home-manager.md` - スキル配布問題の対処法``
  — this file was deleted (confirmed: `find . -iname "home-manager.md"`
  returns nothing; `TODO.md` records "home-manager.md 削除" as done).
- Lines ~65 and ~68 reference `mise run hm:*` tasks and `NIX_CONFIG` token
  injection for `hm:*` — confirmed via
  `grep -rn "hm:" .mise.toml mise/` that zero `hm:` task definitions remain
  anywhere in the repo.

### 4b. `TOOLS.md:29` — wrong Mise config filename

- Current: `| Mise           | \`mise.toml\` | - |`
- No file named `mise.toml` exists at repo root (`find . -maxdepth 1 -iname mise.toml` → empty). The actual entrypoint is `.mise.toml` (confirmed in `.kiro/steering/structure.md`'s directory tree and `docs/tools/mise.md`).

### 4c. `.kiro/steering/{structure,tech,product}.md` — stale "Last Updated" header

- All three files currently show `**Last Updated**: 2026-03-07` (line 3 in
  each), but `git log -1 --format=%ad -- .kiro/steering/structure.md` (and
  the same for the other two) shows the actual last edit was 2026-07-10
  (commit `daf4aad4`, "docs: sync scripts directory map and agent name in
  steering and TODO"). Verify the exact date for each file independently —
  they may not all share the same last-edit date.

### 4d. `.kiro/steering/tech.md` — missing config filenames in mise inventory

- The "Mise (formerly rtx)" section's config file list currently enumerates
  `mise/config.{default,ci,pi}.toml` only (search for the exact line with
  `grep -n "config.default\|config.ci\|config.pi" .kiro/steering/tech.md`).
  It omits `mise/config.macos.toml` and `mise/config.windows.toml`, both of
  which exist (`ls mise/config*.toml`).

## Commands you will need

| Purpose                                     | Command                                                                          | Expected on success            |
| ------------------------------------------- | -------------------------------------------------------------------------------- | ------------------------------ |
| Confirm dead link                           | `find . -iname "home-manager.md"`                                                | no output                      |
| Confirm no hm: tasks                        | `grep -rn "hm:" .mise.toml mise/`                                                | no output                      |
| Confirm mise.toml absent                    | `find . -maxdepth 1 -iname mise.toml`                                            | no output                      |
| Get real last-edit date                     | `git log -1 --format=%ad --date=short -- .kiro/steering/structure.md`            | prints a date, e.g. 2026-07-10 |
| Confirm config file list                    | `ls mise/config*.toml`                                                           | lists all 6 files              |
| Markdown lint (if touched files are linted) | `mise run lint:md` (check exact task name in `mise/local-tasks/lint.toml` first) | exit 0                         |

## Scope

#### In scope (the only files you should modify)

- `docs/tools/nix.md`
- `TOOLS.md`
- `.kiro/steering/structure.md`
- `.kiro/steering/tech.md`
- `.kiro/steering/product.md`

#### Out of scope (do NOT touch, even though they look related)

- Any other content in these files beyond the specific lines identified above
  — do not do a broader documentation pass in this plan.
- `docs/tools/mise.md`, `docs/tools/workflows.md` — not part of this
  specific drift set; leave them alone even if you notice something else
  stale while working (note it in NOTES instead).

## Git workflow

- Branch: `advisor/004-docs-drift-fixes`
- Commit message style: conventional commits, e.g. `docs: fix stale references in nix.md, TOOLS.md, and kiro steering`
- Do NOT push or open a PR unless the operator instructed it.

## Steps

### Step 1: Fix `docs/tools/nix.md`

Remove the `docs/tools/home-manager.md` bullet from the "参考資料" section
(around line 253). Replace the `mise run hm:*` / `NIX_CONFIG` token
references (around lines 65, 68) with either a note that this workflow is
legacy/removed, or the current mise-bootstrap-based equivalent if one
exists — check `docs/tools/workflows.md` or `mise/local-tasks/*.toml` for
what replaced it before writing the replacement text; if nothing replaced
it, state plainly that the `hm:*` task family was removed as part of the
Home Manager migration (per `TODO.md`).

Verify: `grep -n "home-manager.md\|hm:" docs/tools/nix.md` → no matches
remain (or only remain inside a sentence explicitly explaining the removal,
not as an actionable reference/link).

### Step 2: Fix `TOOLS.md`

Change line 29's `mise.toml` to `.mise.toml`, and link it to
`docs/tools/mise.md` for the full `mise/config*.toml` breakdown (match the
existing table's link style — check how other rows in the same table format
links, e.g. `[Mise](docs/tools/mise.md)` as already used at line 71).

Verify: `grep -n "mise.toml" TOOLS.md` → shows `.mise.toml`, not the bare
`mise.toml`.

### Step 3: Fix stale "Last Updated" headers

For each of `.kiro/steering/structure.md`, `.kiro/steering/tech.md`,
`.kiro/steering/product.md`: get the real last-edit date via
`git log -1 --format=%ad --date=short -- <file>` and update that file's line
3 `**Last Updated**: <date>` to match.

Verify: For each file, `head -3 <file>` shows a date matching the
`git log` output from this step (not 2026-03-07 unless that file's git log
genuinely shows no edits since then).

### Step 4: Fix `tech.md`'s mise config inventory

Add `mise/config.macos.toml` and `mise/config.windows.toml` to the config
file list found in Step "4d" of Current state (match the existing list
format/style used for the other three filenames).

Verify: `grep -n "config.macos.toml\|config.windows.toml" .kiro/steering/tech.md` → both present.

### Step 5: Run doc lint if applicable

Verify: Check `mise/local-tasks/lint.toml` for a markdown-specific task
name (e.g. `lint:markdown`, `lint:md`) and run it against the five touched
files if such a task exists and can be scoped to specific files; otherwise
run the full `mise run check:lint:quick` (per Plan 001's fast-lint task, if
that plan has landed — otherwise `mise run check:lint`) → exit 0.

## Test plan

No automated tests apply — these are prose/content documentation fixes.
Verification is the grep/head checks in each step above, confirming the
specific stale content is gone and replaced with accurate information.

## Done criteria

Machine-checkable. ALL must hold:

- [ ] `grep -n "home-manager.md" docs/tools/nix.md` returns no matches
- [ ] `grep -n "hm:" docs/tools/nix.md` returns no actionable task references (only explanatory prose about removal, if any)
- [ ] `grep -n "mise.toml" TOOLS.md` shows `.mise.toml`, not bare `mise.toml`
- [ ] All three `.kiro/steering/*.md` "Last Updated" headers match their real `git log -1` last-edit date
- [ ] `.kiro/steering/tech.md` lists all 6 `mise/config*.toml` files (or explains why any are intentionally omitted)
- [ ] No files outside the five in-scope docs are modified (`git status`)
- [ ] `plans/README.md` status row updated

## STOP conditions

Stop and report back (do not improvise) if:

- Any of the four "Current state" claims above no longer match the live
  file content (drifted since this plan was written) — re-verify against
  the actual repo rather than assuming the plan is still accurate.
- You cannot determine what (if anything) replaced the `hm:*` task family —
  in that case, write the "removed, no direct replacement" note rather than
  inventing a replacement workflow that doesn't exist.
- A markdown lint task fails on your edits — fix formatting to match the
  linter's expectation (this is in scope, since it's part of making these
  edits land cleanly), but if the failure is unrelated to your edits (a
  pre-existing lint issue in one of these files), report it rather than
  fixing unrelated content.

## Maintenance notes

- Consider (as a follow-up, not part of this plan) whether a lint rule or
  pre-commit check could catch "Last Updated" headers going stale
  automatically — this plan only fixes the current instances.
- A reviewer should spot-check that the `hm:*` replacement text in
  `docs/tools/nix.md` is factually accurate (i.e., actually confirm no
  replacement task exists, rather than trusting the executor's claim
  unverified).
