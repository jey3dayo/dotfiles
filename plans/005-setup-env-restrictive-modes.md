# Plan 005: Create decrypted `.env.local` with mode 0600 from the start

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise. When done, update the status row for this plan
> in `plans/README.md` — unless a reviewer dispatched you and told you they
> maintain the index.
>
> **Drift check (run first)**: `git diff --stat 316ce335..HEAD -- scripts/setup-env.sh scripts/windows/setup-env.ps1 scripts/setup-env.test.ts scripts/windows/setup-env.ps1.test.ts`
> If any in-scope file changed since this plan was written, compare the
> "Current state" excerpts against the live code before proceeding; on a
> mismatch, treat it as a STOP condition.

## Status

- Priority: P1
- Effort: S
- Risk: LOW
- Depends on: none
- Category: security
- Planned at: commit `316ce335`, 2026-08-14

## Why this matters

`scripts/setup-env.sh` decrypts dotenvx output into a temp file under the
default umask (often `0644`), then `mv`s it to `.env.local`, then `chmod 600`.
Between create and `chmod`, and on any crash after `mv` but before `chmod`,
plaintext secrets can be group/world-readable. The Windows twin
`setup-env.ps1` never applies an owner-only ACL at all. Closing the window
keeps decrypted secrets owner-only for the whole lifetime of the file.

Do **not** print or assert secret _values_ in tests — only modes/ACLs and
non-secret markers (e.g. that a file exists and mode bits match).

## Current state

- `scripts/setup-env.sh` — Unix decrypt path. Critical lines today:

  ```sh
  # scripts/setup-env.sh:52-56
  TEMP_FILE="$ENV_LOCAL.tmp.$$"
  if DOTENV_PRIVATE_KEY_PATH="$ENV_KEYS" dotenvx decrypt -f "$ENV_FILE" --stdout >"$TEMP_FILE" 2>/dev/null; then
    mv "$TEMP_FILE" "$ENV_LOCAL"
    chmod 600 "$ENV_LOCAL"
  ```

- `scripts/windows/setup-env.ps1` — Windows decrypt path. Writes then moves
  with no ACL hardening:

  ```powershell
  # scripts/windows/setup-env.ps1:70-72
  [System.IO.File]::WriteAllText($tempFile, ($output -join [Environment]::NewLine), (New-Object System.Text.UTF8Encoding($false)))
  Move-Item -LiteralPath $tempFile -Destination $envLocal -Force
  Write-Output "✓ .env.local updated successfully"
  ```

- `scripts/setup-env.test.ts` — bun tests for the shell script. The
  "generates .env.local when missing" case asserts content/status but **not**
  file mode (`scripts/setup-env.test.ts:95-127`).
- `scripts/windows/setup-env.ps1.test.ts` — race/concurrency coverage; no ACL
  assertions.

## Commands you will need

| Purpose      | Command                              | Expected on success |
| ------------ | ------------------------------------ | ------------------- |
| TS tests     | `mise run test:ts`                   | exit 0              |
| Shell syntax | `sh -n scripts/setup-env.sh`         | exit 0              |
| Focused bun  | `bun test scripts/setup-env.test.ts` | all pass            |

## Scope

#### In scope (the only files you should modify)

- `scripts/setup-env.sh`
- `scripts/windows/setup-env.ps1`
- `scripts/setup-env.test.ts`
- `scripts/windows/setup-env.ps1.test.ts` (only if you can assert ACL/mode
  portably without requiring a real Windows host; otherwise skip PS1 test
  changes and note it in NOTES)

#### Out of scope

- `.env` / `.env.keys` / `.env.local` contents — never open or rewrite them
- `scripts/launchd/launchd-gui-env.sh`, `bin/aicommits-with-env`
- Changing decrypt tooling (dotenvx) or when decrypt runs
- Docs (handled by plan 007)

## Git workflow

- Branch: `advisor/secret-path-hardening` (shared with plan 006 — create if
  missing; reuse if already on it)
- Commit style (conventional, English subject): match recent history, e.g.
  `fix(env): create .env.local with mode 0600 before publish`
- Do NOT push or open a PR unless the operator instructed it.
- One commit for this plan is fine.

## Steps

### Step 1: Harden `scripts/setup-env.sh` create path

Before writing `$TEMP_FILE`, restrict the creation umask (or create the file
with mode 0600 another portable way). Recommended portable shape for `#!/bin/sh`:

1. Save previous umask: `old_umask=$(umask)`
2. `umask 077`
3. Create/truncate `$TEMP_FILE` empty (`: >"$TEMP_FILE"` or `touch` then
   `chmod 600`) **before** redirecting decrypt stdout into it, so the file
   never exists as 0644.
4. Run decrypt redirect into that file.
5. `mv` to `$ENV_LOCAL` (permissions follow the file on typical Unix; still
   `chmod 600 "$ENV_LOCAL"` after `mv` as defense in depth).
6. Restore `umask "$old_umask"` in a way that still runs on failure (or only
   change umask in a subshell that owns the write). Prefer keeping the
   script's failure cleanup (`rm -f "$TEMP_FILE"`) intact.

Do not use bash-only features — shebang is `#!/bin/sh`.

Verify: `sh -n scripts/setup-env.sh` → exit 0

### Step 2: Assert mode 0600 in `scripts/setup-env.test.ts`

In the existing "generates .env.local when missing" test (and the "updates
when .env is newer" test if easy), after success assert:

```ts
expect(fs.statSync(envLocal).mode & 0o777).toBe(0o600);
```

Do not assert secret string values beyond what the test already checks
(`SECRET=decrypted` fixture is fine — it is synthetic).

Verify: `bun test scripts/setup-env.test.ts` → all pass

### Step 3: Harden `scripts/windows/setup-env.ps1`

After successful `WriteAllText` + `Move-Item` (or before move on the temp
file), set an owner-only ACL equivalent to Unix 0600. Prefer .NET ACL APIs
already available in PowerShell, for example:

- Build a `FileSecurity` / `FileSystemAccessRule` that grants the current user
  FullControl and disables inheritance / removes other rules, then
  `Set-Acl` on `$envLocal` (and ideally `$tempFile` before move).

Keep behavior identical on decrypt failure (temp removed, exit 1).

If a clean ACL helper would be more than ~20 lines, a minimal
`icacls` invocation that grants only the current user is acceptable — but
prefer managed APIs if short.

Verify: PowerShell parser check if available:
`pwsh -NoProfile -Command "& { $null = [System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path scripts/windows/setup-env.ps1), [ref]$null, [ref]$errs); if ($errs) { $errs; exit 1 } }"`
→ exit 0. If `pwsh` is missing, note it and rely on review of the diff.

### Step 4: Run the suite

Verify: `mise run test:ts` → exit 0

## Test plan

- Extend `scripts/setup-env.test.ts` mode assertion as in Step 2.
- Pattern: existing fake-`dotenvx` tests in the same file.
- Optional Windows ACL assert only if the existing PS1 test harness already
  runs on this machine; otherwise document skip in NOTES.

## Done criteria

- [ ] `scripts/setup-env.sh` never leaves a newly written temp/final
      `.env.local` with mode other than `0600` on the success path
      (umask/`chmod` before publish)
- [ ] `scripts/windows/setup-env.ps1` applies owner-only ACL on success path
- [ ] `bun test scripts/setup-env.test.ts` passes with a `0o600` assertion
- [ ] `mise run test:ts` exits 0
- [ ] No files outside the in-scope list are modified
- [ ] Commit exists on `advisor/secret-path-hardening`

## STOP conditions

- Drift check shows in-scope files changed vs `316ce335` excerpts.
- Making ACL changes requires modules or elevation not available — stop and
  report rather than shipping a no-op stub.
- Any step needs to read real `.env` / `.env.keys` / `.env.local` from the
  developer's home config (use only temp fixtures).

## Maintenance notes

- Reviewers: confirm umask is restored or scoped so later script steps (none
  today) are not affected if the script grows.
- Follow-up deferred: rotating keys that may have leaked on multi-user hosts
  is an operator action, not this plan.
