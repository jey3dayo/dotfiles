# Plan 003: Align go/node version pinning strategy across mise config layers

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise. When done, update the status row for this plan
> in `plans/README.md` — unless a reviewer dispatched you and told you they
> maintain the index.
>
> **Drift check (run first)**: `git diff --stat fedff82f..HEAD -- mise/config.default.toml mise/config.windows.toml mise/config.pi.toml mise/config.ci.toml`
> If any in-scope file changed since this plan was written, compare the
> "Current state" excerpts against the live code before proceeding; on a
> mismatch, treat it as a STOP condition.

## Status

- Priority: P2
- Effort: S
- Risk: LOW
- Depends on: none
- Category: dependencies
- Planned at: commit `fedff82f`, 2026-07-14

## Why this matters

The four per-OS mise configs pin `go` and `node` inconsistently with no
documented rationale for the differences:

- `go`: `1.26.4` (default) vs `1.25.5` (windows, one minor behind) vs
  `latest` (pi)
- `node`: `lts` (default, ci) vs `24` (windows, pi — a specific major that
  may or may not track LTS as new LTS lines roll)

Nothing in the repo explains whether these are intentional platform
workarounds (e.g. a known Windows Go 1.26 bug) or accidental drift from
editing configs independently over time. Left undocumented, the next person
touching any of these files can't tell whether to "fix" the mismatch or
leave it alone — and if it's genuine drift, different platforms silently run
different toolchains with no test catching version-dependent behavior
differences.

## Current state

- `mise/config.default.toml:14` — `go = "1.26.4"`
- `mise/config.default.toml:16` — `node = "lts"`
- `mise/config.windows.toml:17` — `go = "1.25.5"`
- `mise/config.windows.toml:18` — `node = "24"`
- `mise/config.pi.toml:12` — `go = "latest"`
- `mise/config.pi.toml:13` — `node = "24"`
- `mise/config.ci.toml:19` — `node = "lts"` (no explicit `go` pin found in
  this file — confirm with `grep -n "^go" mise/config.ci.toml`; if absent,
  CI's go version comes from `config.default.toml` or system default —
  verify which before making claims about CI's actual version in your
  investigation).

No comment in any of these four files explains the divergence. This plan
does NOT assume the divergence is a bug — the investigation step below
requires the executor to determine intent (or its absence) before touching
version numbers.

## Commands you will need

| Purpose                 | Command                                                               | Expected on success                                                                                 |
| ----------------------- | --------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| Check git blame/history | `git log -p --follow -- mise/config.windows.toml \| grep -B5 "go = "` | shows any prior commit message explaining the pin                                                   |
| Validate config         | `mise config` (or `mise doctor` per profile)                          | no parse errors                                                                                     |
| Full CI                 | `mise run ci`                                                         | exit 0 (only if you actually change a pin — do not run this speculatively if you only add comments) |

## Scope

#### In scope (the only files you should modify)

- `mise/config.default.toml`
- `mise/config.windows.toml`
- `mise/config.pi.toml`
- `mise/config.ci.toml`

#### Out of scope (do NOT touch, even though they look related)

- `mise/config.macos.toml`, `mise/config.toml` — not part of this
  inconsistency (verify they don't also pin `go`/`node` differently before
  assuming this; if they do, note it in NOTES but do not expand scope
  without flagging it first).
- Any tool other than `go` and `node` (e.g. lua, python) — those have their
  own separate FIXME/tracking issue and are out of scope here.
- Actually installing/switching the runtime versions on this machine — this
  plan only edits config files; do not run `mise install` in a way that
  mutates the operator's active toolchain unless verifying config syntax
  requires it in a disposable way.

## Git workflow

- Branch: `advisor/003-mise-tool-pin-consistency`
- Commit message style: conventional commits, e.g. `docs(mise): document go/node version pin rationale` or `fix(mise): align go/node pins across configs`
- Do NOT push or open a PR unless the operator instructed it.

## Steps

### Step 1: Investigate whether the divergence is intentional

Run `git log --follow -p -- mise/config.windows.toml | grep -B8 'go = "1.25.5"'`
and the equivalent for `mise/config.pi.toml`'s `go = "latest"` and the
`node = "24"` pins. Look for any commit message mentioning a Windows-specific
Go bug, a Pi memory/arch constraint, or a Node compatibility issue.

Verify: You can state, with evidence (a commit hash + message, or "no
evidence found"), whether each divergent pin is documented as intentional.

### Step 2a (if divergence is intentional): Add a rationale comment

For each divergent pin found to be intentional in Step 1, add a one-line
comment directly above it in the TOML file citing the reason and, if
applicable, the commit hash where it was introduced. Example:

```toml
# Pinned behind default (see abc1234): Go 1.26.x has a known issue on Windows ARM64 runners
go = "1.25.5"
```

Verify: `grep -n -B1 "go = \"1.25.5\"" mise/config.windows.toml` → shows
the new comment.

### Step 2b (if divergence is NOT intentional / no evidence found): Align pins

Standardize on one strategy per tool. Recommended default (confirm this
doesn't break anything in Step 3 before committing to it): pin `go` to the
same explicit version across all four files (use the `config.default.toml`
value, `1.26.4`, as the canonical version unless Step 1 surfaced a real
blocker), and pin `node` to `"lts"` everywhere (replacing the `"24"` pins in
`config.windows.toml` and `config.pi.toml`) unless Step 1 found a reason
`"24"` was deliberately chosen over `"lts"`.

Verify: `grep -n "^go = \|^node = " mise/config.default.toml mise/config.windows.toml mise/config.pi.toml mise/config.ci.toml` → all four `go` values match (or CI's absence is confirmed intentional), all `node` values match.

### Step 3: Validate config syntax after any change

Verify: Run `taplo format --check mise/config.default.toml mise/config.windows.toml mise/config.pi.toml mise/config.ci.toml` (or `mise run check:toml` if that task exists — check `mise/local-tasks/*.toml` for the exact task name first) → exit 0, no syntax errors introduced.

## Test plan

No new automated tests apply — this is a config-value/comment change, not
application logic. Verification is the syntax check in Step 3, plus manual
confirmation that `mise config` (run in each profile context, e.g.
`MISE_CONFIG_FILE=mise/config.windows.toml mise config get tools.go` if that
subcommand exists — check `mise config --help` first) reports the expected
version per file.

## Done criteria

Machine-checkable. ALL must hold:

- [ ] Either every divergent `go`/`node` pin has a rationale comment (2a), or
      all pins are aligned to one strategy per tool (2b) — not a mix of both
      without explanation
- [ ] TOML syntax validation passes on all four touched files
- [ ] No files outside the four in-scope configs are modified (`git status`)
- [ ] `plans/README.md` status row updated

## STOP conditions

Stop and report back (do not improvise) if:

- The current pins in any of the four files no longer match the "Current
  state" excerpts above (drifted since this plan was written).
- Step 1's investigation is inconclusive (no commit evidence either way) AND
  you're not confident aligning the pins is safe — in that case, prefer
  Step 2a's "no evidence found, flagging for human review" comment over
  guessing and changing a version number that might break a real platform
  constraint.
- Changing a pin would require also bumping `mise.lock` / relockfile in a way
  this plan didn't anticipate — report instead of resolving lockfile drift
  unilaterally.

## Maintenance notes

- If Step 1 uncovers a genuine platform-specific constraint, make sure the
  rationale comment is discoverable — a future contributor editing
  `config.default.toml`'s `go` version should be pointed at the Windows/Pi
  file's comment so they don't bump one without checking the others.
- A reviewer should treat "aligned pins" (2b) with slightly more scrutiny
  than "documented divergence" (2a) — the former is a live behavior change
  (different toolchain version actually gets installed) while the latter is
  purely documentation.
