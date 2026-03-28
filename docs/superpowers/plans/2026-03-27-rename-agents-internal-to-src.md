# Rename `agents/internal/` to `agents/src/` Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

Goal: Rename `agents/internal/` to `agents/src/` and update all references across the codebase.

Architecture: Single `git mv` to rename the directory, followed by targeted find-and-replace across Nix code, scripts, CI config, and self-referential skill docs. No functional changes — pure rename.

Tech Stack: Nix, Bash, TypeScript (test), mise, GitHub Actions

---

## File Structure Map

### Renamed

- `agents/internal/` → `agents/src/` (entire directory tree, ~60 files)
- `agents/scripts/validate-internal.sh` → `agents/scripts/validate-src.sh`
- `agents/scripts/validate-internal.test.ts` → `agents/scripts/validate-src.test.ts`

### Modified (Nix)

- `flake.nix:160` — `distributionsPath = ./agents/internal` → `./agents/src`
- `home.nix:56` — `distributionsPath = ./agents/internal` → `./agents/src`
- `agents/nix/module.nix:163` — description string `./agents/internal`
- `agents/nix/lib.nix:275` — comment `agents/internal`

### Modified (Scripts & Config)

- `agents/scripts/validate-src.sh:5` — `dist_root` variable path
- `agents/scripts/validate-src.test.ts:12,15,22,34` — script name and describe label
- `mise/tasks/skills.toml:54-55` — description and run command
- `.pre-commit-config.yaml:83` — `files:` pattern
- `.github/workflows/validate.yml:11,12,21,22,62` — path filters and run command

### Modified (Self-referential skill docs — after rename)

- `agents/src/skills/distributions-manager/SKILL.md`
- `agents/src/skills/distributions-manager/references/architecture.md`
- `agents/src/skills/distributions-manager/references/priority-mechanism.md`
- `agents/src/skills/distributions-manager/references/symlink-patterns.md`
- `agents/src/skills/nix-dotfiles/SKILL.md`
- `agents/src/skills/nix-dotfiles/README.md`
- `agents/src/skills/nix-dotfiles/references/commands.md`
- `agents/src/skills/nix-dotfiles/references/troubleshooting.md`
- `agents/src/skills/docs-index/indexes/agents-index.md`

---

## Task 1: Rename the directory

### Files

- Rename: `agents/internal/` → `agents/src/`

- [ ] **Step 1: git mv でリネーム**

```bash
cd ~/.config
git mv agents/internal agents/src
```

- [ ] **Step 2: 確認**

```bash
rtk git status
# expected: renamed: agents/internal/... -> agents/src/... (多数)
ls agents/src/
# expected: agents  commands  rules  skills
```

- [ ] **Step 3: コミット**

```bash
rtk git add -A
rtk git commit -m "refactor: rename agents/internal to agents/src"
```

---

## Task 2: Nix コード更新

### Files

- Modify: `flake.nix:160`
- Modify: `home.nix:56`
- Modify: `agents/nix/module.nix:163`
- Modify: `agents/nix/lib.nix:275`

- [ ] **Step 1: flake.nix を更新**

`flake.nix:160` を Read して確認してから：

```
# before
distributionsPath = ./agents/internal;
# after
distributionsPath = ./agents/src;
```

- [ ] **Step 2: home.nix を更新**

`home.nix:56` を Read して確認してから：

```
# before
distributionsPath = ./agents/internal;
# after
distributionsPath = ./agents/src;
```

- [ ] **Step 3: module.nix の description 文字列を更新**

`agents/nix/module.nix:163` を Read して確認してから：

```
# before
description = "Path to internal assets directory (e.g., ./agents/internal).
# after
description = "Path to internal assets directory (e.g., ./agents/src).
```

- [ ] **Step 4: lib.nix のコメントを更新**

`agents/nix/lib.nix:275` を Read して確認してから：

```
# before
# agents/internal skills override flake input skills on duplicate IDs.
# after
# agents/src skills override flake input skills on duplicate IDs.
```

- [ ] **Step 5: Nix ビルド確認**

```bash
nix flake check --no-build 2>&1 | tail -5
# expected: no errors (warnings are ok)
```

- [ ] **Step 6: コミット**

```bash
rtk git add flake.nix home.nix agents/nix/module.nix agents/nix/lib.nix
rtk git commit -m "fix(nix): update agents/internal path references to agents/src"
```

---

## Task 3: スクリプト・設定ファイル更新

### Files

- Rename+Modify: `agents/scripts/validate-internal.sh` → `agents/scripts/validate-src.sh`
- Rename+Modify: `agents/scripts/validate-internal.test.ts` → `agents/scripts/validate-src.test.ts`
- Modify: `mise/tasks/skills.toml:54-55`
- Modify: `.pre-commit-config.yaml:83`
- Modify: `.github/workflows/validate.yml:11,12,21,22,62`

- [ ] **Step 1: シェルスクリプトをリネーム＆パッチ**

```bash
git mv agents/scripts/validate-internal.sh agents/scripts/validate-src.sh
```

`agents/scripts/validate-src.sh` を Read して `dist_root` 変数を確認してから Edit：

```
# before
dist_root="${repo_root}/agents/internal"
# after
dist_root="${repo_root}/agents/src"
```

- [ ] **Step 2: テストファイルをリネーム＆パッチ**

```bash
git mv agents/scripts/validate-internal.test.ts agents/scripts/validate-src.test.ts
```

`agents/scripts/validate-src.test.ts` を Read して確認してから Edit（`validate-internal` の参照を `validate-src` に全置換）：

```typescript
// before
const sourceScript = path.join(__dirname, "validate-internal.sh");
const root = fs.mkdtempSync(path.join(os.tmpdir(), "validate-internal-test-"));
const scriptPath = path.join(scriptDir, "validate-internal.sh");
describe("agents/scripts/validate-internal.sh", () => {
// after
const sourceScript = path.join(__dirname, "validate-src.sh");
const root = fs.mkdtempSync(path.join(os.tmpdir(), "validate-src-test-"));
const scriptPath = path.join(scriptDir, "validate-src.sh");
describe("agents/scripts/validate-src.sh", () => {
```

- [ ] **Step 3: mise/tasks/skills.toml を更新**

`mise/tasks/skills.toml` を Read して確認してから Edit：

```toml
# before
description = "agents/internal が SSoT ルールに準拠しているか検証"
run = "bash ./agents/scripts/validate-internal.sh"
# after
description = "agents/src が SSoT ルールに準拠しているか検証"
run = "bash ./agents/scripts/validate-src.sh"
```

- [ ] **Step 4: .pre-commit-config.yaml を更新**

`.pre-commit-config.yaml:83` を Read して確認してから Edit：

```yaml
# before
files: ^agents/internal/.*\.md$
# after
files: ^agents/src/.*\.md$
```

- [ ] **Step 5: .github/workflows/validate.yml を更新**

`.github/workflows/validate.yml` を Read して確認してから Edit（L11, L12, L21, L22, L62 を更新）：

```yaml
# before (L11, L21)
      - "agents/internal/**"
# after
      - "agents/src/**"

# before (L12, L22)
      - "agents/scripts/validate-internal.sh"
# after
      - "agents/scripts/validate-src.sh"

# before (L62)
        run: bash ./agents/scripts/validate-internal.sh
# after
        run: bash ./agents/scripts/validate-src.sh
```

- [ ] **Step 6: コミット**

```bash
rtk git add agents/scripts/validate-src.sh agents/scripts/validate-src.test.ts \
  mise/tasks/skills.toml .pre-commit-config.yaml .github/workflows/validate.yml
rtk git commit -m "fix(scripts): rename validate-internal to validate-src and update path refs"
```

---

## Task 4: スキル内 self-referential docs 更新

> **Note:** Task 1 完了後に実行すること（ファイルが `agents/src/` に移動済みであること）

### Files

- Modify: `agents/src/skills/distributions-manager/SKILL.md`
- Modify: `agents/src/skills/distributions-manager/references/architecture.md`
- Modify: `agents/src/skills/distributions-manager/references/priority-mechanism.md`
- Modify: `agents/src/skills/distributions-manager/references/symlink-patterns.md`
- Modify: `agents/src/skills/nix-dotfiles/SKILL.md`
- Modify: `agents/src/skills/nix-dotfiles/README.md`
- Modify: `agents/src/skills/nix-dotfiles/references/commands.md`
- Modify: `agents/src/skills/nix-dotfiles/references/troubleshooting.md`
- Modify: `agents/src/skills/docs-index/indexes/agents-index.md`

- [ ] **Step 1: 各ファイルを Read して `agents/internal` 参照を確認してから Edit**

各ファイルで `agents/internal` → `agents/src` に置換する。
Read → Edit のサイクルをファイルごとに繰り返す。

確認コマンド（作業前）：

```bash
grep -rn "agents/internal" agents/src/skills/
```

- [ ] **Step 2: 置換漏れがないことを確認**

```bash
grep -rn "agents/internal" agents/src/
# expected: no output
```

- [ ] **Step 3: コミット**

```bash
rtk git add agents/src/skills/
rtk git commit -m "docs(skills): update agents/internal path references to agents/src"
```

---

## Task 5: CI 検証

> **スキップ確認済みファイル（Task 1–4 に含まれない）:**
> 以下はスペックに列挙されているが、実際に `agents/internal` 参照が存在しないため変更不要：
>
> - `mise/config.toml` — 参照なし
> - `.fdignore`, `.prettierignore` — 参照なし
> - `scripts/replace-bold-headings.ts:293` — コメント例示。`agents/external` が残っているだけで実害なし（任意で更新可）
> - `docs/superpowers/specs/2026-03-27-unify-external-skills-management-design.md` — 削除済み
> - `docs/superpowers/plans/2026-03-27-clean-up-unused-external-skills.md` — 削除済み

- [ ] **Step 1: ローカル CI 実行**

```bash
mise run ci
# expected: all checks pass (format + lint + test + skills)
```

失敗した場合はエラーメッセージを確認し、対象ファイルを修正して再実行する。

- [ ] **Step 2: `agents/internal` の残存参照がないことを最終確認**

```bash
grep -r "agents/internal" . \
  --exclude-dir=.git \
  --exclude-dir=node_modules
# expected: no output
```

残存があれば修正してコミットする。

- [ ] **Step 3: home-manager switch でデプロイ確認（任意）**

```bash
home-manager switch --flake ~/.config --impure
ls ~/.claude/skills/ | wc -l
# expected: スキル数が以前と同じ
```
