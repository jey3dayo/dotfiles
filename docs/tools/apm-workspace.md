# APM Workspace Reference

最終更新: 2026-04-19  
対象: 開発者  
タグ: `category/infra`, `tool/apm`, `tool/mise`, `layer/agent`, `audience/developer`

Claude Rules: [.claude/rules/tools/mise.md](../../.claude/rules/tools/mise.md)  
親ドキュメント: [Mise Reference](mise.md)

`~/.apm` を user/global skill workspace として扱う運用の正本です。  
この `.config` repo は bootstrap・migration helper・rollback だけを持ち、日常の APM 操作は `~/.apm` から行います。

## Goal

- source-of-truth repo: `apm-workspace`
- local working copy: `~/.apm`
- global manifest: `~/.apm/apm.yml`
- downloaded dependency sources: `~/.apm/apm_modules/`
- workspace task file: `~/.apm/mise.toml`
- 通常同期: `cd ~/.apm && mise run migrate-external && mise run apply`
- Codex 向け補助: `apm compile --target codex --output ~/.codex/AGENTS.md`

## Global Dependency Contract

global skill 管理では、依存の持ち方を次の 3 つに固定します。

- external global skills:
  - `~/.apm/apm.yml` に upstream ref を記録する
  - 例: `microsoft/apm-sample-package`, `obra/superpowers/skills/writing-plans`
  - source of truth は upstream repo
- downloaded dependency sources:
  - `apm install -g` で `~/.apm/apm_modules/` に取得される
  - `apm_modules/` は cache / install artifact であり、手編集しない
- legacy rollback:
  - `~/.config/agents/src/skills/<id>/` と `agents:legacy:*` task を fallback として残す
  - これは global manifest の正本ではない

`packages/` は旧 migration artifact であり、通常の global workspace には不要です。  
`~/.apm/skills/` は current global model では使いません。  
workspace-root `.apm/` を global skill 正本として説明しません。

## Managed Catalog Contract

repo-managed skill は、現在は single tracked catalog package として global manifest に登録されています。

- tracked global package:
  - `~/.apm/catalog/.apm/skills/<id>/`
  - ここが repo-tracked managed skill tree
- manifest reference:
  - `~/.apm/apm.yml` には `jey3dayo/apm-workspace/catalog#main` を記録する
  - managed skill も `apm.yml` の upstream ref から install される
- authoring source:
  - `~/.config/agents/src/skills/<id>/`
  - ここが managed skill の source of truth
- not allowed:
  - managed skill を `~/.apm/apm.yml` へ `./packages/*` で書き戻すこと
  - `packages/` を managed global skills の将来形として説明すること
  - `~/.apm/skills/` を current source-of-truth と説明すること

日常運用では `~/.apm/catalog/` と `~/.apm/apm.yml` を見ます。  
`.config/agents/src/skills/` は fallback ではなく authoring lane として残します。

## Enabled External Mapping

現在 enabled な global skill は、`nix/agent-skills-sources.nix` から次の upstream refs へ対応付けます。

| Skill ID | Canonical `apm.yml` reference |
| --- | --- |
| `agentation` | `benjitaylor/agentation/skills/agentation` |
| `agentation-self-driving` | `benjitaylor/agentation/skills/agentation-self-driving` |
| `gh-address-comments` | `openai/skills/skills/.curated/gh-address-comments` |
| `gh-fix-ci` | `openai/skills/skills/.curated/gh-fix-ci` |
| `skill-creator` | `openai/skills/skills/.system/skill-creator` |
| `composition-patterns` | `vercel-labs/agent-skills/skills/composition-patterns` |
| `react-best-practices` | `vercel-labs/agent-skills/skills/react-best-practices` |
| `web-design-guidelines` | `vercel-labs/agent-skills/skills/web-design-guidelines` |
| `agent-browser` | `vercel-labs/agent-browser/skills/agent-browser` |
| `ui-ux-pro-max` | `nextlevelbuilder/ui-ux-pro-max-skill/.claude/skills/ui-ux-pro-max` |
| `cloudflare` | `Heyvhuang/ship-faster/skills/cloudflare` |
| `tool-openclaw` | `Heyvhuang/ship-faster/skills/tool-openclaw` |
| `react-doctor` | `millionco/react-doctor/skills/react-doctor` |
| `prompt-review` | `tokoroten/prompt-review/.claude/skills/prompt-review` |
| `skill-auditor` | `nyosegawa/skills/skills/skill-auditor` |
| `superpowers:brainstorming` | `obra/superpowers/skills/brainstorming` |
| `superpowers:dispatching-parallel-agents` | `obra/superpowers/skills/dispatching-parallel-agents` |
| `superpowers:executing-plans` | `obra/superpowers/skills/executing-plans` |
| `superpowers:finishing-a-development-branch` | `obra/superpowers/skills/finishing-a-development-branch` |
| `superpowers:receiving-code-review` | `obra/superpowers/skills/receiving-code-review` |
| `superpowers:requesting-code-review` | `obra/superpowers/skills/requesting-code-review` |
| `superpowers:subagent-driven-development` | `obra/superpowers/skills/subagent-driven-development` |
| `superpowers:systematic-debugging` | `obra/superpowers/skills/systematic-debugging` |
| `superpowers:test-driven-development` | `obra/superpowers/skills/test-driven-development` |
| `superpowers:using-git-worktrees` | `obra/superpowers/skills/using-git-worktrees` |
| `superpowers:using-superpowers` | `obra/superpowers/skills/using-superpowers` |
| `superpowers:verification-before-completion` | `obra/superpowers/skills/verification-before-completion` |
| `superpowers:writing-plans` | `obra/superpowers/skills/writing-plans` |
| `superpowers:writing-skills` | `obra/superpowers/skills/writing-skills` |
| `codex-cli-runtime` | `openai/codex-plugin-cc/plugins/codex/skills/codex-cli-runtime` |
| `codex-result-handling` | `openai/codex-plugin-cc/plugins/codex/skills/codex-result-handling` |
| `gpt-5-4-prompting` | `openai/codex-plugin-cc/plugins/codex/skills/gpt-5-4-prompting` |
| `understand` | `Lum1104/Understand-Anything/understand-anything-plugin/skills/understand` |
| `understand-chat` | `Lum1104/Understand-Anything/understand-anything-plugin/skills/understand-chat` |
| `understand-dashboard` | `Lum1104/Understand-Anything/understand-anything-plugin/skills/understand-dashboard` |
| `understand-diff` | `Lum1104/Understand-Anything/understand-anything-plugin/skills/understand-diff` |
| `understand-explain` | `Lum1104/Understand-Anything/understand-anything-plugin/skills/understand-explain` |
| `understand-onboard` | `Lum1104/Understand-Anything/understand-anything-plugin/skills/understand-onboard` |
| `frontend-design` | `anthropics/claude-code/plugins/frontend-design/skills/frontend-design` |
| `agentic-actions-auditor` | `trailofbits/skills/plugins/agentic-actions-auditor/skills/agentic-actions-auditor` |
| `audit-context-building` | `trailofbits/skills/plugins/audit-context-building/skills/audit-context-building` |
| `sharp-edges` | `trailofbits/skills/plugins/sharp-edges/skills/sharp-edges` |
| `codeql` | `trailofbits/skills/plugins/static-analysis/skills/codeql` |
| `sarif-parsing` | `trailofbits/skills/plugins/static-analysis/skills/sarif-parsing` |
| `semgrep` | `trailofbits/skills/plugins/static-analysis/skills/semgrep` |
| `supply-chain-risk-auditor` | `trailofbits/skills/plugins/supply-chain-risk-auditor/skills/supply-chain-risk-auditor` |
| `tauri` | `EpicenterHQ/epicenter/.agents/skills/tauri` |
| `empirical-prompt-tuning` | `mizchi/chezmoi-dotfiles/dot_claude/skills/empirical-prompt-tuning` |

`dev-browser` は managed catalog に取り込まれているため、global `apm.yml` へは external ref を追加しません。

## Responsibility Split

`.config` 側の責務:

- `~/.apm` checkout の bootstrap
- managed `~/.apm/mise.toml` の注入
- `nix/agent-skills-sources.nix` から canonical upstream ref を導出
- managed catalog の build / register helper
- legacy Nix / Home Manager 配布の rollback

`~/.apm` 側の責務:

- `apm.yml` / `apm.lock.yaml` の日常編集
- `apm install -g`
- `apm deps update -g`
- `apm compile`
- external upstream ref の追加 / 更新
- `apm_modules/` の再生成
- APM CLI 自体の更新 (`mise update`)

## Bootstrap Flow

最初の 1 回だけ `.config` から bootstrap します。

```bash
cd ~/.config
mise run apm:bootstrap
```

`apm:bootstrap` は次を行います。

- `~/.apm` を `apm-workspace` checkout として用意する
- `~/.apm/apm.yml` が無ければ最小 manifest を生成する
- managed `~/.apm/mise.toml` を注入する

既に `~/.apm/mise.toml` があり、かつ `.config` 管理の marker を含まない場合は上書きせず警告だけ出します。強制更新したい場合だけ `APM_BOOTSTRAP_FORCE_MISE=1` を使います。

## Daily Workflow

bootstrap 後は `~/.apm` 側で global skills を管理します。

```bash
cd ~/.apm
mise install
mise run migrate-external
mise run apply
mise run doctor
```

`~/.apm/mise.toml` の主要 task:

- `apply`: catalog drift / legacy link cleanup を内部で処理したうえで、`apm.yml` の global dependencies を `apm install -g` で deploy
- `update`: checkout 更新 + `apm deps update -g` + `apm install -g`
- `list`: `apm deps list -g`
- `doctor`: workspace / targets / dependency 状態の確認。external の `unpinned` 件数、managed-vs-external の overlap 件数、catalog の `source / tracked / status` も表示する
- `migrate-external`: enabled external skills を upstream ref として manifest へ記録

maintenance-only commands は `~/.config/scripts/apm-workspace.ps1|.sh` に残します。

- `pin-external`: lockfile の `resolved_commit` で external refs を再固定する repair helper
- `validate`: `apm compile --validate`
- `validate-catalog`: authoring source / tracked catalog / manifest ref drift を fail fast で検出する
- catalog maintenance:
  - `bundle-catalog`
  - `stage-catalog`
  - `register-catalog`
  - `smoke-catalog`

## External Migration Flow

external global skills を manifest に登録する時は次を使います。

```bash
cd ~/.apm
mise run migrate-external
mise run apply
```

`migrate-external` は次を行います。

- `~/.config/nix/agent-skills-sources.nix` の各 source と `selection.enable` を読む
- 各 skill の canonical upstream ref を導出する
- managed catalog が勝つ ID は external ref を記録しない
- `apm install -g <upstream-ref>` で `~/.apm/apm.yml` と `~/.apm/apm.lock.yaml` を更新する
- `migrate-external` の最後に `pin-external` を自動実行し、manifest の external refs を lockfile の `resolved_commit` へ寄せる
- managed skill を巻き取った後は `mise run doctor` で `external selection overlap: count=0` を確認する
- 旧 package ownership が残っている場合は `apm prune` を 1 回実行する

`apply` / `update` は、まず catalog drift を検出し、その後に legacy 配布で残った managed skill link や junction を user target 側から掃除してから `apm install -g` を実行します。Windows で `Cannot call rmtree on a symbolic link` が出るケースのガードです。

加えて、`apm install -g` が exit 0 でも diagnostics に `packages failed` / `error(s)` を出した場合は、workspace script 側で failure として扱います。partial integration failure を成功扱いしないためです。
- ソースは `~/.apm/apm_modules/` に取得される

これで、external skill の source of truth は upstream repo のまま `apm.yml` に残ります。

## Managed Catalog Status

managed skill migration は、single tracked catalog registration まで完了しています。

- current tracked location:
  - `~/.apm/catalog/.apm/skills/<id>/`
- current manifest model:
  - `~/.apm/apm.yml` は `jey3dayo/apm-workspace/catalog#main` を持つ
  - `apm install -g` はその ref から managed skill を deploy する
- authoring model:
  - `~/.config/agents/src/skills/<id>/`
- not current model:
  - `~/.apm/skills/`
  - `~/.apm/internal-bundles/`
  - `./packages/*`

catalog maintenance commands 自体は script に残っていますが、通常の daily flow では使いません。  
必要時だけ `~/.config/scripts/apm-workspace.ps1|.sh` の maintenance lane として扱います。

## Legacy / Rollback

`.config` 側の legacy task は残します。

- `agents:validate`
- `agents:validate:internal`
- `agents:check:sync`
- `agents:report`
- `agents:legacy:*`

問題があれば `mise run agents:legacy:install` で従来配布へ戻せます。  
Home Manager 世代ベースで戻す場合は `mise run agents:legacy:rollback` を使います。

注意:
この `.config` リポジトリの branch を戻しても、`~/.apm` 側の commit や `apm.yml` 編集までは戻りません。

## Environment Variables

- `APM_WORKSPACE_DIR`
  - default: `~/.apm`
- `APM_WORKSPACE_REPO`
  - default: `https://github.com/jey3dayo/apm-workspace.git`
- `APM_WORKSPACE_NAME`
  - default: repo 名 (`apm-workspace`)
- `APM_CODEX_OUTPUT`
  - default: `~/.codex/AGENTS.md`
- `APM_BOOTSTRAP_FORCE_MISE=1`
  - managed でない `~/.apm/mise.toml` も強制的に置き換えたい時だけ使う
- `APM_MIGRATE_FORCE=1`
  - legacy vendor seed を強制的に置き換えたい時だけ使う

## APM CLI Installation Policy

- `.config` 側では `github:microsoft/apm` を `mise` で pin しておく
- `~/.apm/mise.toml` にも同じ tool 定義を注入し、workspace 側の `mise install` / `mise update` で運用する
- 通常導線: `cd ~/.apm && mise install && mise run migrate-external && mise run apply`
- 公式 installer:
  - macOS / Linux: `curl -sSL https://aka.ms/apm-unix | sh`
  - Windows: `irm https://aka.ms/apm-windows | iex`
- 公式 installer は `mise` が使えない時の手動復旧用 fallback
