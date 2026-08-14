# Plan 007: Align docs with post-mise reality (pre-push + Nix/HM leftovers)

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise. When done, update the status row for this plan
> in `plans/README.md` — unless a reviewer dispatched you and told you they
> maintain the index.
>
> **Drift check (run first)**: `git diff --stat 316ce335..HEAD -- docs/ lefthook.yml .github/workflows/ci.yml .claude/rules/setup-and-env.md .agents/skills/nvim/SKILL.md .claude/skills/nvim/SKILL.md`
> If any in-scope file changed since this plan was written, compare the
> "Current state" excerpts against the live code before proceeding; on a
> mismatch, treat it as a STOP condition.

## Status

- Priority: P1
- Effort: S
- Risk: LOW
- Depends on: none
- Category: docs
- Planned at: commit `316ce335`, 2026-08-14

## Why this matters

Several live docs and agent rules still describe Home Manager apply, a full
`mise run ci` pre-push gate, Nix validation tasks, and a Brewfile "20 section /
go type" layout that no longer exist. Operators and agents following those
pages run commands that fail or over-trust local hooks. This plan is
**documentation and comment cleanup only** — no hook behavior change unless a
doc sentence would be false; prefer fixing the docs to match `lefthook.yml`.

## Current state (evidence)

### Pre-push mismatch

- `docs/tools/workflows.md:124-128` claims:

  > `pre-push` hook は `mise run ci` を実行します。

  Actual `lefthook.yml:79-113` runs `check:format`, `check:lint:quick`,
  glob-conditional `test:ts` / `test:lua`, and `ci:gitleaks` — **not** full
  `mise run ci` (full `ci` also runs full `check` including `lint:links`).

### Stale Nix / HM / tracker pointers

- `docs/tools/nix.md:230-241` — troubleshooting still runs
  `home-manager switch --flake . --impure` / `nix flake update` even though
  the banner at lines 7–9 says cleanup-only and `flake.nix` is gone.
- `.claude/rules/setup-and-env.md:14` — "scheduled for removal (see TODO.md)"
  but tracker is `todo.txt` (no `TODO.md`).
- `.github/workflows/ci.yml:74` — comment: "Local environments use Home Manager…"
- `docs/tools/mise.md:81` — tree label `ci.toml` as "CI/CD チェック・Nix 検証"
  (file has gitleaks/verify-deploy/ci only).
- `docs/tools/mise.md:97` — lists nonexistent `agents.toml`.
- `docs/tools/mise-tasks.md:102` — claims `config.default.toml` is「macOS 専用」;
  file header says Mac/Linux/WSL2 共通; brew/launchd live in `config.macos.toml`.
- `docs/tools/workflows.md:275-284` — Brewfile "20 sections" including `go`
  type; current `Brewfile` is flat tap/brew/cask/mas/vscode (no `go "` lines).
- `docs/superpowers/plans/2026-06-20-nix-dotfiles-structure-adoption.md` —
  still instructs preserving HM flake apply under `docs/`.
- `.agents/skills/nvim/SKILL.md:112` and `.claude/skills/nvim/SKILL.md:112` —
  related skill `nix-dotfiles` (gone).

### Intentionally keep

- `todo.txt` WSL2 cutover item — still valid; do not delete.
- `docs/tools/nix.md` as a **legacy GC / generations** reference is OK if
  apply/flake sections are removed or clearly marked "only if `home-manager`
  binary and profiles still exist on this machine".
- `nix/nix.conf` — out of scope (not docs).

## Commands you will need

| Purpose                 | Command                                              | Expected on success                    |
| ----------------------- | ---------------------------------------------------- | -------------------------------------- |
| Confirm lefthook        | `rg -n "pre-push:\|mise run" lefthook.yml`           | shows format/lint:quick/tests/gitleaks |
| Confirm no flake        | `test ! -f flake.nix && test ! -f home.nix; echo ok` | `ok`                                   |
| Markdown lint (touched) | `mise run format` then focused markdownlint if easy  | exit 0                                 |
| Link/ghost grep         | see Done criteria greps                              | zero bad hits                          |

## Scope

#### In scope

- `docs/tools/workflows.md` (pre-push section + Brewfile section)
- `docs/tools/nix.md` (remove or quarantine apply/flake recovery; keep GC)
- `docs/tools/mise.md` (ci.toml label, drop `agents.toml`)
- `docs/tools/mise-tasks.md` (config.default.toml description)
- `docs/tools/mise-config.md` — only if Pi luacheck sentence must stay
  consistent with a one-line clarification (optional; do not reopen luarocks
  FIXME)
- `.claude/rules/setup-and-env.md`
- `.github/workflows/ci.yml` (comment only at the Home Manager line)
- `.agents/skills/nvim/SKILL.md` and `.claude/skills/nvim/SKILL.md` (related
  skills bullet)
- `docs/superpowers/plans/2026-06-20-nix-dotfiles-structure-adoption.md` —
  either delete, or add a superseded banner at the top pointing to mise
  bootstrap and stating "do not execute"; prefer **banner + move is overkill** —
  add a clear superseded banner and strike runnable HM steps by wrapping the
  goal in "HISTORICAL / DO NOT EXECUTE"

#### Out of scope

- Changing `lefthook.yml` behavior (docs follow code)
- Implementing WSL2 cutover or luarocks fix (direction items)
- `README.md` / `docs/README.md` `最終更新` date bumps alone (optional if you
  already edit those hubs; not required)
- Plan 005/006 script changes
- Removing `nix/` config files

## Git workflow

- Branch: `advisor/docs-stale-cleanup` (docs-only; **do not** mix with
  `advisor/secret-path-hardening`)
- Commit example: `docs: align pre-push and retire stale Nix/HM instructions`
- One or two commits max (e.g. workflows/mise first, nix legacy second).
- Do NOT push or open a PR unless instructed.

## Steps

### Step 1: Fix pre-push documentation

Rewrite `docs/tools/workflows.md` "pre-push の gate" to describe actual
lefthook jobs:

- `mise run check:format`
- `mise run check:lint:quick` (not full lint / not `lint:links`)
- conditional `test:ts` / `test:lua` by glob
- `mise run ci:gitleaks`

Clarify that full `mise run ci` remains the local/CI full gate and that
`mise run pre-push` is the lighter manual helper. Keep the bullet list of
path → test mapping accurate to `mise/lib/pre-push-check.sh` / lefthook globs.

Verify: `rg -n 'mise run ci' docs/tools/workflows.md` → should not claim
the hook runs full `ci` (mentions of full ci as the complete gate are OK if
worded clearly).

### Step 2: Fix Brewfile section in workflows.md

Replace the "20 sections" / `go` type table with the real layout: `tap`,
`brew`, `cask`, `mas`, `vscode`. Point CLI additions at mise per
`docs/setup.md` package split. Drop fictional examples that are not in
Brewfile if easy to spot.

Verify: `rg -n '20 セクション|golangci-lint' docs/tools/workflows.md` → no
stale taxonomy.

### Step 3: Quarantine `docs/tools/nix.md` apply path

- Delete or rewrite the "GC 後に Home Manager 適用が失敗する" section so it
  does **not** run `home-manager switch --flake` / `nix flake update` /
  `rm flake.lock`.
- Keep generation removal + `nix-collect-garbage` guidance, gated with "only
  if `home-manager` / Nix profiles still exist".
- Optionally shorten the mermaid "配布アーキテクチャ" that still shows HM
  apply — replace with a one-paragraph "historical; distribution is mise
  bootstrap now" note.

Verify: `rg -n 'home-manager switch|flake\.nix' docs/tools/nix.md` → no
instructive apply commands (mentions in "removed" prose OK).

### Step 4: Fix mise docs + agent/CI comments

1. `docs/tools/mise.md:81` — relabel `ci.toml` (e.g. gitleaks / verify-deploy /
   ci aliases). Drop Nix 検証.
2. `docs/tools/mise.md:97` — remove `agents.toml` from the list.
3. `docs/tools/mise-tasks.md:102` — state `config.default.toml` is
   Mac/Linux/WSL2 common tools; macOS brew/launchd/dotfiles extras are
   `config.macos.toml` / `config.toml` as appropriate (match `docs/setup.md`).
4. `.claude/rules/setup-and-env.md:14` — point at `todo.txt` for remaining
   WSL2 cutover; do not say `TODO.md`.
5. `.github/workflows/ci.yml:74` — replace Home Manager comment with mise /
   `MISE_CONFIG_FILE` reality.
6. nvim SKILL related-skills: remove `nix-dotfiles` bullet from both
   `.agents/skills/nvim/SKILL.md` and `.claude/skills/nvim/SKILL.md`.

**Verify** greps in Done criteria.

### Step 5: Supersede the June 2026 Nix structure plan under docs/

At the top of
`docs/superpowers/plans/2026-06-20-nix-dotfiles-structure-adoption.md`, add a
banner:

```markdown
> **SUPERSEDED (do not execute)** — Home Manager / flake distribution was
> removed; use `docs/setup.md` and `mise bootstrap` / `mise dotfiles apply`.
> Kept only as historical notes.
```

Do not re-implement any HM tasks.

Verify: first 20 lines contain `SUPERSEDED`.

### Step 6: Format touched markdown

Run repo formatter on touched md/yml as usual (`mise run format` is OK if
scoped impact is acceptable; otherwise `prettier`/`markdownlint` on touched
files).

Verify: `git diff --check` → clean.

## Test plan

- Docs-only; no new automated tests.
- Manual: greps in Done criteria must pass.

## Done criteria

- [ ] `docs/tools/workflows.md` describes lefthook pre-push accurately (not
      full `mise run ci` as the hook)
- [ ] `rg -n 'home-manager switch --flake' docs/` returns no executable
      instruction sites (superseded plan may mention historically only inside
      clearly superseded doc — prefer zero)
- [ ] `rg -n 'TODO\\.md' .claude/rules/setup-and-env.md` → no matches
- [ ] `rg -n 'Nix 検証|agents\\.toml' docs/tools/mise.md` → no matches
- [ ] `rg -n 'macOS 専用' docs/tools/mise-tasks.md` → no matches
- [ ] `rg -n 'nix-dotfiles' .agents/skills/nvim/SKILL.md .claude/skills/nvim/SKILL.md` → no matches
- [ ] Superseded banner present on the June 2026 plan file
- [ ] No files outside the in-scope list modified
- [ ] Commit(s) on `advisor/docs-stale-cleanup`

## STOP conditions

- Drift vs excerpts.
- Temptation to change `lefthook.yml` to restore full `ci` on push — stop and
  report; this plan chose docs-follow-code.
- Deleting all of `docs/tools/nix.md` without leaving GC guidance when the
  file is still linked from `docs/README.md` / workflows — prefer edit over
  delete.

## Maintenance notes

- Direction follow-ups (not this plan): WSL2 `todo.txt` item; luarocks/lua
  FIXME; eventual `+nix-removal`.
- Reviewers: ensure no new HM apply snippets were introduced while editing.
