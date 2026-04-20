# APM Workspace Reference

最終更新: 2026-04-19  
対象: 開発者  
タグ: `category/infra`, `tool/apm`, `tool/mise`, `layer/agent`, `audience/developer`

Claude Rules: [.claude/rules/tools/mise.md](../../.claude/rules/tools/mise.md)  
親ドキュメント: [Mise Reference](mise.md)

`~/.apm` を user/global skill workspace として扱う運用の正本です。  
この `.config` repo は bootstrap と maintenance helper だけを持ち、日常の APM 操作は `~/.apm` から行います。

## Goal

- canonical repo: `apm-workspace`
- local working copy: `~/.apm`
- global manifest: `~/.apm/apm.yml`
- downloaded dependency sources: `~/.apm/apm_modules/`
- workspace task file: `~/.apm/mise.toml`
- 通常同期: `cd ~/.apm && mise run migrate-external && mise run apply`
- Codex 向け補助: `apm compile --target codex --output ~/.codex/AGENTS.md`

## Global Dependency Contract

global skill 管理では、依存の持ち方を次の 2 つに固定します。

- external global skills:
  - `~/.apm/apm.yml` に upstream ref を記録する
  - 例: `microsoft/apm-sample-package`, `obra/superpowers/skills/writing-plans`
  - 正本は upstream repo
- downloaded dependency sources:
  - `apm install -g` で `~/.apm/apm_modules/` に取得される
  - `apm_modules/` は cache / install artifact であり、手編集しない

## Managed Catalog Contract

repo-managed skill は、現在は single managed catalog package として global manifest に登録されています。

- tracked global package:
  - `~/.apm/catalog/.apm/skills/<id>/`
  - `~/.apm/catalog/AGENTS.md`
  - `~/.apm/catalog/agents/**`
  - `~/.apm/catalog/commands/**`
  - `~/.apm/catalog/rules/**`
  - ここを直接編集し、`stage-catalog` で正規化する
- manifest reference:
  - `~/.apm/apm.yml` には `jey3dayo/apm-workspace/catalog#main` を記録する
  - managed skill も `apm.yml` の upstream ref から install される

日常運用では `~/.apm/catalog/` と `~/.apm/apm.yml` を見ます。

## External Mapping

external skill の対応付けは `~/.config/nix/agent-skills-sources.nix` を正本として管理します。

- `mise run migrate-external` が enabled source から canonical upstream ref を導出する
- `~/.apm/apm.yml` と `~/.apm/apm.lock.yaml` に実際の install 状態を書き出す
- `mise run doctor` で `unpinned` と overlap を確認する

固定のスキル一覧はこの文書に持たず、必要なときは `nix/agent-skills-sources.nix` と `~/.apm/apm.yml` を確認します。

## Responsibility Split

`.config` 側の責務:

- `~/.apm` checkout の bootstrap
- `~/.apm` checkout が持つ `mise.toml` の存在確認
- `nix/agent-skills-sources.nix` から canonical upstream ref を導出
- managed catalog の build / register helper
- runtime guidance の同期 helper

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
- `~/.apm` checkout に `mise.toml` があることを確認する

`~/.apm/mise.toml` は workspace repo 自身が正本です。`.config` 側 template の注入や強制上書きは行いません。

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

- `apply`: catalog drift と stale managed link cleanup を内部で処理したうえで、`apm.yml` の global dependencies を `apm install -g` で deploy
- `update`: checkout 更新 + `apm deps update -g` + `apm install -g`
- `list`: `apm deps list -g`
- `doctor`: workspace / targets / dependency 状態の確認。external の `unpinned` 件数、managed-vs-external の overlap 件数、catalog の `skills / agents / commands / rules / instructions` 状態、target の `config / agents / commands / rules / skills` presence も表示する
- `format`: workspace 内の Markdown / TOML / YAML を整形する
- `ci:check`: format check + `validate` + `validate-catalog` + `smoke-catalog` をまとめて実行する
- `ci`: `format` → `ci:check` → `apply` → `doctor` の順で、ローカル配布まで含めて回す
- `migrate-external`: enabled external skills を upstream ref として manifest へ記録
- `validate-catalog`: managed catalog package の正規化状態、manifest ref、required asset の欠落を fail fast で検出する
- `catalog:tidy`: `stage-catalog` → `validate-catalog` → `doctor` の整理導線
- `apply` / `update` / `register-catalog`: install 後に tracked `AGENTS.md` / `agents/` / `commands/` / `rules/` を runtime target に同期する

maintenance-only commands は `~/.config/scripts/apm-workspace.ps1|.sh` に残します。

- `pin-external`: lockfile の `resolved_commit` で external refs を再固定する repair helper
- `validate`: `apm compile --validate`
- catalog maintenance:
  - `bundle-catalog`
  - `stage-catalog`
  - `register-catalog`
  - `smoke-catalog`

## External Reference Flow

external global skills を manifest に反映する時は次を使います。

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
- managed catalog と競合しないことを `mise run doctor` で確認する
- install 状態が崩れている時は `apm prune` を 1 回実行する

`apply` / `update` は、まず catalog drift を検出し、その後に stale managed skill link や junction を user target 側から掃除してから `apm install -g` を実行します。Windows で `Cannot call rmtree on a symbolic link` が出るケースのガードです。

加えて、`apm install -g` が exit 0 でも diagnostics に `packages failed` / `error(s)` を出した場合は、workspace script 側で failure として扱います。partial integration failure を成功扱いしないためです。

- ソースは `~/.apm/apm_modules/` に取得される

これで、external skill は upstream repo を正本にしたまま `apm.yml` に残ります。

## Managed Catalog Layout

- managed catalog location:
  - `~/.apm/catalog/.apm/skills/<id>/`
  - `~/.apm/catalog/AGENTS.md`
  - `~/.apm/catalog/agents/**`
  - `~/.apm/catalog/commands/**`
  - `~/.apm/catalog/rules/**`
- manifest model:
  - `~/.apm/apm.yml` は `jey3dayo/apm-workspace/catalog#main` を持つ
  - `apm install -g` はその ref から managed skill を deploy する
- editing model:
  - `~/.apm/catalog/` を直接編集する
  - `stage-catalog` / `validate-catalog` で正規化と検証を行う
  - `apply` / `register-catalog` で runtime target へ同期する

catalog maintenance commands は `~/.config/scripts/apm-workspace.ps1|.sh` に残っていますが、通常の daily flow では `~/.apm` workspace 側 task を使います。

## Environment Variables

- `APM_WORKSPACE_DIR`
  - default: `~/.apm`
- `APM_WORKSPACE_REPO`
  - default: `https://github.com/jey3dayo/apm-workspace.git`
- `APM_WORKSPACE_NAME`
  - default: repo 名 (`apm-workspace`)
- `APM_CODEX_OUTPUT`
  - default: `~/.codex/AGENTS.md`

## APM CLI Installation Policy

- `.config` 側では `github:microsoft/apm` を `mise` で pin しておく
- `~/.apm/mise.toml` にも同じ tool 定義を注入し、workspace 側の `mise install` / `mise update` で運用する
- 通常導線: `cd ~/.apm && mise install && mise run migrate-external && mise run apply`
- 公式 installer:
  - macOS / Linux: `curl -sSL https://aka.ms/apm-unix | sh`
  - Windows: `irm https://aka.ms/apm-windows | iex`
- 公式 installer は `mise` が使えない時の手動復旧用 fallback
