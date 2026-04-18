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
workspace-root `.apm/` を global skill 正本として説明しません。

## Internal Bundled Skills Contract

internal bundled skill は、external upstream ref と同じ扱いにはしません。

- 現在の正本:
  - `~/.config/agents/src/skills/<id>/`
  - rollback / seed / migration source として残す
- current global rule:
  - internal bundled skill を `~/.apm/apm.yml` へ `./packages/*` で書き戻さない
  - `packages/` を internal global skills の将来形として説明しない
- target direction:
  - internal skill は `.config` 側の source から生成される internal APM bundle / package reference に寄せる
  - その publish / install path が安定するまでは legacy rollback 側に残す
- current pilot staging:
  - `mise run migrate-internal[:profile]` は `~/.apm/.internal-seed/<id>/` へ seed する
  - global `apm.yml` は変えない
  - `mise run bundle-internal[:profile]` は `~/.apm/.internal-seed/internal-<profile>/` に valid APM bundle artifact を生成する

first batch の pilot 候補は次の 3 つです。

- `apm-usage`
- `atomic-commit`
- `greptileai`

これらは single-file skill で、internal migration contract の検証に向いています。  
ただし現時点では、どれも通常の daily flow にまだ入っていません。

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

`dev-browser` は internal bundled skill に shadow されるため、global `apm.yml` へは追加しません。

## Responsibility Split

`.config` 側の責務:

- `~/.apm` checkout の bootstrap
- managed `~/.apm/mise.toml` の注入
- `nix/agent-skills-sources.nix` から canonical upstream ref を導出
- legacy bundled skill の seed helper
- internal bundled skill pilot の contract と inventory 管理
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
mise run validate
mise run doctor
```

`~/.apm/mise.toml` の主要 task:

- `apply`: `apm.yml` の global dependencies を `apm install -g` で deploy
- `update`: checkout 更新 + `apm deps update -g` + `apm install -g`
- `list`: `apm deps list -g`
- `validate`: `apm compile --validate`
- `doctor`: workspace / targets / dependency 状態の確認。internal inventory の `listed / source / status` と、profile ごとの `skills / tracked / manifest` も表示する
- `migrate-internal[:profile]`: internal pilot skills を `~/.apm/.internal-seed/` へ seed
- `bundle-internal[:profile]`: profiled internal pilot skills から valid APM bundle artifact を生成
- `stage-internal`: generated bundle を `~/.apm/internal-bundles/` へコピーし canonical upstream ref を出す
- `register-internal`: staged bundle が commit/push 済みなら upstream ref として `apm.yml` へ登録する
- `smoke-internal`: generated internal bundle を temp project install で smoke verify
- `migrate-external`: enabled external skills を upstream ref として manifest へ記録
- `migrate`: `migrate-internal` の compatibility alias。legacy automation 互換のためだけに残す

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
- internal bundled skill が勝つ ID は external ref を記録しない
- `apm install -g <upstream-ref>` で `~/.apm/apm.yml` と `~/.apm/apm.lock.yaml` を更新する

`apply` / `update` / `register-internal[:profile]` は、legacy 配布で残った internal skill link や junction が user target 側にあれば先に掃除してから `apm install -g` を実行します。Windows で `Cannot call rmtree on a symbolic link` が出るケースのガードです。
- ソースは `~/.apm/apm_modules/` に取得される

これで、external skill の source of truth は upstream repo のまま `apm.yml` に残ります。

## Internal Migration Status

internal bundled skill migration は、profile ごとの upstream bundle registration まで進んでいます。

- normal flow:
  - `migrate-external` + `apply`
  - 対象は external upstream refs のみ
- internal pilot helper:
  - `mise run migrate-internal`
  - default では `~/.config/agents/src/internal-apm-first-batch.txt` を読む
  - profile は `next-simple` `medium` `heavy` `remaining` を追加で選べる
  - seed 先は `~/.apm/.internal-seed/`
- internal bundle helper:
  - `mise run bundle-internal`
  - output は `~/.apm/.internal-seed/internal-<profile>/`
  - `apm.yml` と `.apm/skills/...` を含む valid APM package artifact を作る
- internal staging helper:
  - `mise run stage-internal`
  - generated bundle を `~/.apm/internal-bundles/internal-<profile>/` へ同期する
  - `jey3dayo/apm-workspace/internal-bundles/internal-<profile>#main` のような candidate upstream ref を表示する
- internal registration helper:
  - `mise run register-internal`
  - staged path に uncommitted / unpushed change がある間は明示的に止まる
  - push 済みなら `apm install -g <upstream-ref>` で global manifest へ登録する
- internal smoke helper:
  - `mise run smoke-internal`
  - generated bundle を temp project へ `apm install <bundle> --target codex` して確認する
  - 成功時は `.agents/skills/<id>/SKILL.md` が揃うことを assert する
- not normal flow:
  - `mise run migrate -- <skill>`
  - `./packages/*` を `apm.yml` に戻すこと
- current helper:
  - `migrate-internal` は `~/.config/agents/src/skills/<id>/` を pilot/reference 用に seed するだけ
  - source layout は `<skill>/SKILL.md` と `<skill>/skills/SKILL.md` の両方を許容する
  - `bundle-internal` は publish/install 前提の artifact を生成するだけ
  - `stage-internal` は repo-tracked publish candidate を作るだけで global manifest はまだ変えない
  - `register-internal` は staged path が push 済みの時だけ global manifest を更新する
  - `migrate` はその compatibility alias
  - global `apm.yml` の dependency truth は変えない
  - current registered profiles は `first-batch` `next-simple` `medium` `heavy` `remaining`

2026-04-19 時点の APM 0.8.11 では、`apm install -g <local-path>` は user scope で拒否されます。  
そのため `bundle-internal` は今は validation / publication prep 用であり、direct global install にはまだ使いません。

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
