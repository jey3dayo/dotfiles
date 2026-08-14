# Plan 006: Harden WSL mise snapshots (exclude `.env*`, allowlist TaskName, escape paths)

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise. When done, update the status row for this plan
> in `plans/README.md` — unless a reviewer dispatched you and told you they
> maintain the index.
>
> **Drift check (run first)**: `git diff --stat 316ce335..HEAD -- scripts/windows/mise-wsl-task.sh scripts/windows/mise-wsl-task.ps1`
> If any in-scope file changed since this plan was written, compare the
> "Current state" excerpts against the live code before proceeding; on a
> mismatch, treat it as a STOP condition.

## Status

- Priority: P1
- Effort: S
- Risk: LOW
- Depends on: none (share branch with 005; either order is fine)
- Category: security
- Planned at: commit `316ce335`, 2026-08-14

## Why this matters

Windows CI helpers clone the repo into `/tmp` and overlay dirty files. The
tracked encrypted `.env` is included in that world-readable snapshot. The
PowerShell twin also (a) creates `/tmp/...` via `git clone` without a prior
`0700` directory, (b) accepts any `-TaskName` via a `default` branch that
runs `mise run '<name>'`, while the bash twin allowlists tasks, and
(c) embeds WSL paths into `bash -lc` / temp scripts without the same
single-quote escape used for `TaskName`. Fixing these keeps secret material
out of `/tmp` and aligns fail-closed task selection.

## Current state

- `scripts/windows/mise-wsl-task.sh`:
  - Line 9: `snapshot_root="$(mktemp -d /tmp/codex-mise-wsl-repo-XXXXXXXX)"` (0700 — good)
  - Line 43: `git clone --quiet "$repo_root" "$snapshot_root"` — copies tracked `.env`
  - Lines 60–71: overlays changed/untracked files with no `.env*` filter
  - Lines 78–102: allowlisted `check` / `ci:quick` / `ci` only; unknown → exit 1
  - Note: `ci:full` is **not** in the bash allowlist today; PS1 has it. Prefer
    adding `ci:full` to bash to match PS1 callers in `mise/local-tasks/ci.toml`
    (`ci:full:windows`).

- `scripts/windows/mise-wsl-task.ps1`:
  - Lines 61–64: `$snapshotRootWsl = "/tmp/codex-mise-wsl-repo-$snapshotId"` then
    `git clone` into that path (directory mode typically 0755)
  - Lines 91–104 area: overlay loop mirrors bash (no `.env*` skip)
  - Lines 138–181: switch with `default { mise run '{escaped TaskName}' }`
  - Lines 187–188, 214: `mise trust` / `cd` / `rm -rf` embed `$repoRootWsl`
    with `"'{0}'" -f $repoRootWsl` and **no** `'` escape (TaskName gets
    `.Replace("'", "'\''")` at line 180 only)

- Tracked encrypted env: `git ls-files` includes `.env` (do not open the file).

## Commands you will need

| Purpose                 | Command                                              | Expected on success                    |
| ----------------------- | ---------------------------------------------------- | -------------------------------------- |
| Bash syntax             | `bash -n scripts/windows/mise-wsl-task.sh`           | exit 0                                 |
| Shellcheck if available | `shellcheck scripts/windows/mise-wsl-task.sh`        | exit 0 or only pre-existing style nits |
| PS parse (optional)     | see plan 005 Step 3 parser one-liner on the ps1 path | exit 0                                 |

There are **no** existing unit tests for these two scripts. Do not invent a
full WSL harness. Prefer a small pure-helper test only if you extract a
trivial filter function; otherwise verification is syntax + manual review
of the exclude/allowlist/escape logic.

## Scope

#### In scope

- `scripts/windows/mise-wsl-task.sh`
- `scripts/windows/mise-wsl-task.ps1`
- Optional new test file **only if** you extract a tiny pure function testable
  without WSL (e.g. `should_skip_env_path`); otherwise skip tests.

#### Out of scope

- Changing how dotenvx decrypt works (plan 005)
- Performance rewrite of clone → worktree reuse (PERF finding; not this plan)
- `mise/local-tasks/ci.toml` task names (callers already use allowlisted names;
  only sync allowlists between sh/ps1)
- Reading or modifying `.env` contents

## Git workflow

- Branch: `advisor/secret-path-hardening` (same as plan 005)
- Commit example: `fix(windows): harden mise WSL snapshot secret and task handling`
- Do NOT push or open a PR unless instructed.
- One commit for this plan is fine (separate from 005's commit).

## Steps

### Step 1: Exclude `.env*` from bash snapshot clone/overlay

In `mise-wsl-task.sh`:

1. After `git clone`, **remove** these paths from the snapshot if present
   (encrypted tracked file still must not sit in `/tmp`):
   - `.env`
   - `.env.local`
   - `.env.keys`
   - any `.env.*` (use a careful loop / `find` limited to snapshot root depth 1,
     or explicit names — do not delete unrelated files)
2. In the overlay `changed_files` loop, **skip** when `relative_path` matches
   `.env`, `.env.local`, `.env.keys`, or `.env.*` (basename match is enough).

Keep `trap cleanup EXIT` so the snapshot is always deleted.

Verify: `bash -n scripts/windows/mise-wsl-task.sh` → exit 0

### Step 2: Align bash allowlist with PS1 (`ci:full`)

Add a `ci:full` case to the bash `case` matching PS1's command list
(`ci:verify-deploy` then check/tests/gitleaks — copy from
`mise-wsl-task.ps1:169-176`).

Verify: `bash -n` again; `rg -n 'ci:full' scripts/windows/mise-wsl-task.sh`
→ match present.

### Step 3: PS1 — 0700 snapshot root, `.env*` exclude, fail-closed TaskName, escape paths

In `mise-wsl-task.ps1`:

1. **Create** the snapshot directory with mode 0700 **before** clone, e.g. via
   `wsl.exe bash -lc` running `mkdir -m 700 ...` then `git clone ... dir`
   into the empty dir (or `mktemp -d` then clone into it). Do not leave a
   0755 parent.
2. After clone (and in the overlay loop), skip/remove the same `.env*` set as
   bash.
3. Replace `default { mise run ... }` with a fail-closed error like the bash
   `*)` branch (`Unsupported task` / exit 1). Keep explicit cases:
   `check`, `test`, `ci:quick`, `ci`, `ci:full`.
4. Introduce a small helper, e.g. `Escape-BashSingleQuoted([string]$Value)`
   that does `.Replace("'", "'\''")`, and use it for **every** path embedded
   in bash single quotes (`git clone`, `mise trust`, `cd`, `rm -rf`), not
   only TaskName.

Verify: parser check if `pwsh` exists; else rely on diff review.
`rg -n "default \\{" scripts/windows/mise-wsl-task.ps1` → no TaskName
passthrough default (or only unrelated defaults).

### Step 4: Sanity grep

#### Verify

```bash
rg -n '\.env' scripts/windows/mise-wsl-task.sh scripts/windows/mise-wsl-task.ps1
```

→ shows exclude/skip logic, not an instruction to copy `.env` into `/tmp`.

```bash
rg -n "mise run '\{0\}'" scripts/windows/mise-wsl-task.ps1
```

→ no match (arbitrary TaskName path gone).

## Test plan

- No mandatory new tests (WSL-dependent).
- If you extract `should_skip_snapshot_path()` in bash or a PS filter, a tiny
  bun/node test is optional — do not block the plan on it.

## Done criteria

- [ ] Snapshot paths never retain `.env` / `.env.local` / `.env.keys` / `.env.*`
      after clone+overlay (both sh and ps1)
- [ ] PS1 snapshot root is created mode 0700 before use
- [ ] PS1 unknown `-TaskName` fails closed (no arbitrary `mise run`)
- [ ] Bash allowlist includes `ci:full` matching PS1
- [ ] All bash-embedded paths use single-quote escaping
- [ ] `bash -n scripts/windows/mise-wsl-task.sh` exits 0
- [ ] Separate commit on `advisor/secret-path-hardening`

## STOP conditions

- Drift vs excerpts.
- Clone-into-existing-0700-dir semantics differ on the host git and break
  clone — stop and report rather than disabling excludes.
- Any change would require committing secret fixtures.

## Maintenance notes

- If a future Windows CI task genuinely needs decrypt inside the snapshot,
  gate that explicitly (copy `.env` + keys into a 0700 subdir) — do not revert
  the default exclude.
- Reviewers: confirm `ci:full` command lists stay identical between sh/ps1.
