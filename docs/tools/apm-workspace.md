# APM Workspace Reference

最終更新: 2026-04-19  
対象: 開発者  
タグ: `category/infra`, `tool/apm`, `tool/mise`, `layer/agent`, `audience/developer`

Claude Rules: [.claude/rules/tools/mise.md](../../.claude/rules/tools/mise.md)  
親ドキュメント: [Mise Reference](mise.md)

`~/.apm` を user/global skill workspace として扱う運用の正本です。  
この `.config` repo は bootstrap helper と補助的な tooling を持ち、日常の APM 操作は `~/.apm` から行います。

## Goal

- canonical repo: `apm-workspace`
- local working copy: `~/.apm`
- global manifest: `~/.apm/apm.yml`
- downloaded dependency sources: `~/.apm/apm_modules/`
- workspace task file: `~/.apm/mise.toml`
- 通常同期: `cd ~/.apm && mise run apply`
- Codex 向け補助: `apm compile --target codex --output ~/.codex/AGENTS.md`

## Current Global Dependency Contract

global skill 管理では、現在は managed catalog package を唯一の依存として扱います。

- tracked global package:
  - `~/.apm/apm.yml` には external skill の upstream ref と `jey3dayo/apm-workspace/catalog#main` を記録する
  - personal skill の正本は `~/.apm/catalog/skills/**`
  - shared guidance の正本は `~/.apm/catalog/{AGENTS.md,agents/**,commands/**,rules/**}`
- downloaded dependency sources:
  - `apm install -g` で `~/.apm/apm_modules/` に取得される
  - `apm_modules/` は cache / install artifact であり、手編集しない

## Managed Catalog Contract

repo-managed skill は、現在は single managed catalog package として global manifest に登録されています。

- tracked global package:
  - `~/.apm/catalog/skills/<id>/`
  - `~/.apm/catalog/AGENTS.md`
  - `~/.apm/catalog/agents/**`
  - `~/.apm/catalog/commands/**`
  - `~/.apm/catalog/rules/**`
  - ここを直接編集し、`stage-catalog` で正規化する
- manifest reference:
  - `~/.apm/apm.yml` には external skill の upstream ref と `jey3dayo/apm-workspace/catalog#main` を記録する
  - personal skill は source から管理し、external skill は upstream ref から install される

日常運用では personal skill と shared guidance は `~/.apm/catalog/`、external skill は `~/.apm/apm.yml` を見ます。

## Responsibility Split

`.config` 側の責務:

- `~/.apm` checkout の bootstrap
- `~/.apm` checkout が持つ `mise.toml` の存在確認
- `.config` 側の `mise` で APM CLI を pin する

`~/.apm` 側の責務:

- `apm.yml` / `apm.lock.yaml` の日常編集
- `apm install -g`
- `apm deps update -g`
- `apm compile`
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
mise run apply
mise run doctor
```

`~/.apm/mise.toml` の主要 task:

- `apply`: catalog drift と stale managed link cleanup を内部で処理したうえで、`apm.yml` の global dependencies を `apm install -g` で deploy
- `update`: checkout 更新 + `apm deps update -g` + `apm install -g`
- `list`: `apm deps list -g`
- `doctor`: workspace / targets / dependency 状態の確認。catalog の `skills / agents / commands / rules / instructions` 状態と、target の `config / agents / commands / rules / skills` presence も表示する
- `format`: workspace 内の Markdown / TOML / YAML を整形する
- `ci:check`: format check + `validate` + `validate-catalog` + `smoke-catalog` をまとめて実行する
- `ci`: `format` → `ci:check` → `apply` → `doctor` の順で、ローカル配布まで含めて回す
- `validate-catalog`: managed catalog package の正規化状態、manifest ref、required asset の欠落を fail fast で検出する
- `catalog:tidy`: `stage-catalog` → `validate-catalog` → `doctor` の整理導線
- `apply` / `update` / `register-catalog`: install 後に tracked `AGENTS.md` / `agents/` / `commands/` / `rules/` を runtime target に同期する

`.config` 側に残る APM command は `mise run apm:bootstrap` のみです。

`apply` / `update` は、まず catalog drift を検出し、その後に stale managed skill link や junction を user target 側から掃除してから `apm install -g` を実行します。Windows で `Cannot call rmtree on a symbolic link` が出るケースのガードです。

加えて、`apm install -g` が exit 0 でも diagnostics に `packages failed` / `error(s)` を出した場合は、workspace script 側で failure として扱います。partial integration failure を成功扱いしないためです。

- ソースは `~/.apm/apm_modules/` に取得される

## Managed Catalog Layout

- managed catalog location:
  - `~/.apm/catalog/skills/<id>/`
  - `~/.apm/catalog/AGENTS.md`
  - `~/.apm/catalog/agents/**`
  - `~/.apm/catalog/commands/**`
  - `~/.apm/catalog/rules/**`
- manifest model:
  - `~/.apm/apm.yml` は `jey3dayo/apm-workspace/catalog#main` を持つ
  - `apm install -g` はその ref から managed skill を deploy する
- editing model:
  - personal skill と shared guidance は `~/.apm/catalog/` を直接編集する
  - external skill は `~/.apm/apm.yml` の upstream ref を編集する
  - `stage-catalog` / `validate-catalog` で正規化と検証を行う
  - `apply` / `register-catalog` で runtime target へ同期する

catalog maintenance も通常運用も `~/.apm` workspace 側 task を正本として扱います。

## Environment Variables

- `APM_WORKSPACE_DIR`
  - default: `~/.apm`
- `APM_WORKSPACE_REPO`
  - default: `https://github.com/jey3dayo/apm-workspace.git`
- `APM_WORKSPACE_NAME`
  - default: repo 名 (`apm-workspace`)

## APM CLI Installation Policy

- `.config` 側では `github:microsoft/apm` を `mise` で pin しておく
- `~/.apm` repo 側も workspace 自身の `mise.toml` で同じ tool を管理する
- 通常導線: `cd ~/.apm && mise install && mise run apply`
- 公式 installer:
  - macOS / Linux: `curl -sSL https://aka.ms/apm-unix | sh`
  - Windows: `irm https://aka.ms/apm-windows | iex`
- 公式 installer は `mise` が使えない時の手動復旧用 fallback
