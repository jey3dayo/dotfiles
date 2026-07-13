# Plan 002: Add test coverage for scripts/env-detect.sh

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise. When done, update the status row for this plan
> in `plans/README.md` — unless a reviewer dispatched you and told you they
> maintain the index.
>
> **Drift check (run first)**: `git diff --stat fedff82f..HEAD -- scripts/env-detect.sh`
> If this file changed since this plan was written, compare the
> "Current state" excerpt against the live code before proceeding; on a
> mismatch, treat it as a STOP condition.

## Status

- **Priority**: P1
- **Effort**: S
- **Risk**: LOW
- **Depends on**: none
- **Category**: tests
- **Planned at**: commit `fedff82f`, 2026-07-14

## Why this matters

`scripts/env-detect.sh` determines which environment type (`ci` / `pi` /
`default`) the machine is running as, which in turn drives which
`mise/config.<type>.toml` file gets loaded across the whole dotfiles setup.
It is the fork point for every environment-specific behavior in the repo, yet
it has no test coverage at all, unlike sibling scripts in `scripts/`
(`setup-env.sh`, `replace-bold-headings.ts`, `zsh-env-loading` logic) which
all have a co-located `*.test.ts`. A silent regression here would misroute
config loading on the wrong OS/CI profile with nothing in `mise run test` to
catch it.

## Current state

- `scripts/env-detect.sh` (168 lines, POSIX `sh`, `set -eu`) prints
  diagnostic output and computes `ENV_TYPE` via this priority logic (lines
  109–119):

  ```sh
  ENV_TYPE="default"
  ENV_COLOR=$GREEN

  # Priority: CI > Pi > Default
  if [ -n "${CI:-}" ] || [ -n "${GITHUB_ACTIONS:-}" ]; then
    ENV_TYPE="ci"
    ENV_COLOR=$YELLOW
  elif is_raspberry_pi; then
    ENV_TYPE="pi"
    ENV_COLOR=$BLUE
  fi
  ```

  `is_raspberry_pi()` (lines 73–107) checks, in order: (1) `uname -m` is
  `aarch64`/`armv7l`/`armv6l` (returns 1 / not-Pi otherwise), (2)
  `/sys/firmware/devicetree/base/model` contains `"Raspberry Pi"`, (3)
  fallback: `/proc/cpuinfo` contains `"Raspberry Pi"`, `"BCM27"`, or
  `"BCM283"`.

  The script also prints `EXPECTED_CONFIG="$CONFIG_HOME/mise/config.$ENV_TYPE.toml"`
  (line 133) and reports whether that file exists — this is pure `printf`
  output, not an exit-code signal (the script always exits 0 regardless of
  whether the config file is found — confirm this with
  `sh scripts/env-detect.sh; echo "exit: $?"`).

- Test pattern to follow: `scripts/setup-env.test.ts` — uses `bun:test`
  (`describe`/`it`/`expect`), `spawnSync("sh", [scriptPath], { env: {...} })`
  to invoke the target script with a controlled environment, and
  `fs.mkdtempSync` for any filesystem fixtures needed. See
  `scripts/setup-env.test.ts:1-38` for the exact spawn helper shape (adapt
  `runSetupEnv` into a `runEnvDetect` helper for this script).

- Test runner: `mise/lib/run-ts-tests.sh` auto-discovers `*.test.ts` files
  under `scripts/` via `fd --type f --glob "*.test.ts"` — no registration
  step needed; a co-located `scripts/env-detect.test.ts` is picked up
  automatically by `mise run test:ts`.

## Commands you will need

| Purpose           | Command                               | Expected on success       |
| ----------------- | ------------------------------------- | ------------------------- |
| Run new test file | `bun test scripts/env-detect.test.ts` | all tests pass            |
| Run full TS suite | `mise run test:ts`                    | exit 0, includes new file |
| Manual smoke      | `sh scripts/env-detect.sh`            | prints diagnostic, exit 0 |

## Scope

**In scope** (the only files you should modify):

- `scripts/env-detect.test.ts` (create)

**Out of scope** (do NOT touch, even though they look related):

- `scripts/env-detect.sh` — this plan adds tests only; do not refactor or
  "fix" the detection logic even if something looks odd. If you find a real
  bug while writing tests, note it in NOTES and STOP rather than fixing it —
  that's a separate finding.
- `zsh/config/tools/mise-env.zsh` — the script's own comment says it mirrors
  this file's logic; do not touch it, this plan doesn't require parity
  changes.

## Git workflow

- Branch: `advisor/002-env-detect-tests`
- Commit message style: conventional commits, e.g. `test(scripts): add coverage for env-detect.sh`
- Do NOT push or open a PR unless the operator instructed it.

## Steps

### Step 1: Create the test file with a spawn helper

Create `scripts/env-detect.test.ts` modeled on `scripts/setup-env.test.ts`'s
structure (imports, `__filename`/`__dirname`/`repoRoot`/`scriptPath`
resolution, `isWindows` skip guard since this is a POSIX `sh` script). Add a
`runEnvDetect({ extraEnv })` helper using `spawnSync("sh", [scriptPath], {
encoding: "utf8", env: { ...process.env, ...extraEnv } })`.

**Verify**: `bun test scripts/env-detect.test.ts` → runs (may have 0
assertions yet, but must not error on file structure/imports).

### Step 2: Test the CI branch

Add a test: with `CI=true` in `extraEnv` (and `GITHUB_ACTIONS` unset —
explicitly overwrite to `undefined`/delete the key if present in the parent
env, since `spawnSync`'s `env` fully replaces `process.env` inheritance for
listed keys but CI runners set `GITHUB_ACTIONS` too — assert on stdout
content, not on the runner's real env leaking through), assert
`result.stdout` matches `/Detected Environment:[\s\S]*ci/` (or a simpler
substring check for the literal `ENV_TYPE` value printed — inspect actual
output shape by running the script manually first: `CI=true sh
scripts/env-detect.sh`). Assert `result.status === 0`.

**Verify**: `bun test scripts/env-detect.test.ts -t "CI"` → passes.

### Step 3: Test the GITHUB_ACTIONS branch

Same as Step 2 but with `GITHUB_ACTIONS=true` and `CI` unset — confirms the
`||` condition's second branch independently, not just CI.

**Verify**: test passes.

### Step 4: Test the default (non-CI, non-Pi) branch

With both `CI` and `GITHUB_ACTIONS` unset, and running on the actual CI/dev
machine (which is not ARM on a typical macOS dev box — verify with `uname -m`
before writing the assertion; if the test machine itself is `aarch64`
(Apple Silicon Mac), the `is_raspberry_pi` ARCH check at line 76-83 will
still return false because the devicetree/cpuinfo checks that follow require
Linux-only paths (`/sys/firmware/devicetree/base/model`, `/proc/cpuinfo`)
that don't exist on macOS — confirm this by running
`sh scripts/env-detect.sh` locally and reading the "Detected Environment"
line before asserting), assert `ENV_TYPE` resolves to `default`.

**Verify**: test passes on the local dev machine.

### Step 5: Test the Pi-detection helper in isolation (optional but preferred)

Since `is_raspberry_pi()` reads real filesystem paths
(`/sys/firmware/devicetree/base/model`, `/proc/cpuinfo`) that can't be easily
faked cross-platform in a portable way, do NOT attempt to mock these paths.
Instead, add one test that documents current-machine behavior: run the
script unmodified and assert the "Raspberry Pi: ✓ Matched" or "✗ Not matched"
line is present and internally consistent with the top-level `ENV_TYPE`
result (i.e., if `ENV_TYPE` is `pi`, the Pi line must show matched; if not
`pi`, it must show not-matched). This catches drift between the two
detection paths without requiring OS-level mocking.

**Verify**: `bun test scripts/env-detect.test.ts` → all tests pass.

## Test plan

- `scripts/env-detect.test.ts`:
  - CI branch (`CI=true`) → `ENV_TYPE=ci`, exit 0
  - GITHUB_ACTIONS branch (`GITHUB_ACTIONS=true`, `CI` unset) → `ENV_TYPE=ci`, exit 0
  - Default branch (neither set, non-ARM or non-Pi-model host) → `ENV_TYPE=default`, exit 0
  - Consistency check: the printed "Raspberry Pi" match/no-match line agrees with `ENV_TYPE`
- Structural pattern: `scripts/setup-env.test.ts`
- Verification: `mise run test:ts` → all pass, including 4 new tests in this file.

## Done criteria

Machine-checkable. ALL must hold:

- [ ] `scripts/env-detect.test.ts` exists
- [ ] `bun test scripts/env-detect.test.ts` exits 0
- [ ] `mise run test:ts` exits 0
- [ ] No files outside `scripts/env-detect.test.ts` are modified (`git status`)
- [ ] `plans/README.md` status row updated

## STOP conditions

Stop and report back (do not improvise) if:

- `scripts/env-detect.sh`'s detection logic doesn't match the "Current state"
  excerpt (drifted since this plan was written).
- Writing the Pi-detection test reveals `is_raspberry_pi()` gives a wrong
  answer on the test machine (report as a separate bug finding — do not fix
  `env-detect.sh` in this plan).
- `bun test` can't find/execute the new file after two attempts at fixing
  import paths.

## Maintenance notes

- If `scripts/env-detect.sh`'s detection logic changes (e.g. new environment
  type added), this test file's branch coverage should be extended to match.
- A reviewer should confirm the tests actually exercise the shell script via
  `spawnSync`, not just re-implement the logic in TypeScript and test that
  instead (the latter would test nothing about the real script).
