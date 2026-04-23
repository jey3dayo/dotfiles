# APM Workspace Reference

最終更新: 2026-04-19  
対象: 開発者  
タグ: `category/infra`, `tool/apm`, `tool/mise`, `layer/agent`, `audience/developer`

Claude Rules: [.claude/rules/tools/mise.md](../../.claude/rules/tools/mise.md)  
親ドキュメント: [Mise Reference](mise.md)

`~/.apm` を user/global skill workspace として扱う運用の正本です。  
この `.config` repo は APM の編集面でも操作面でもなく、参照先を示すための説明だけを持ちます。

## Goal

- canonical repo: `apm-workspace`
- local working copy: `~/.apm`
- global manifest: `~/.apm/apm.yml`
- downloaded dependency sources: `~/.apm/apm_modules/`
- workspace task file: `~/.apm/mise.toml`
- 通常同期: `cd ~/.apm && mise run deploy`
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
  - ここを直接編集し、`prepare:catalog` で正規化する
- manifest reference:
  - `~/.apm/apm.yml` には external skill の upstream ref と `jey3dayo/apm-workspace/catalog#main` を記録する
  - personal skill は source から管理し、external skill は upstream ref から install される

日常運用では personal skill と shared guidance は `~/.apm/catalog/`、external skill は `~/.apm/apm.yml` を見ます。

## Responsibility Split

`.config` 側の責務:

- `.config` 自身の `mise` と shell/editor integration を管理する
- APM の source of truth が `~/.apm` にあることを明示する

`~/.apm` 側の責務:

- `apm.yml` / `apm.lock.yaml` の日常編集
- `apm install -g`
- `apm deps update -g`
- `apm compile`
- `apm_modules/` の再生成
- APM CLI 自体の更新

## Daily Workflow

global skills の管理は最初から `~/.apm` 側で行います。

```bash
cd ~/.apm
mise install
mise run deploy
mise run doctor
```

`~/.apm/mise.toml` の主要 task:

- `apply`: 現在の manifest / lock を user target へ deploy
- `refresh`: checkout 更新 + `apm deps update -g`
- `list`: `apm deps list -g`
- `doctor`: workspace / targets / dependency 状態の確認。catalog の `skills / agents / commands / rules / instructions` 状態と、target の `config / agents / commands / rules / skills` presence も表示する
- `format`: workspace 内の Markdown / TOML / YAML を整形する
- `check`: format check + validation の軽量ゲート
- `verify`: `check` + catalog smoke verification
- `deploy`: `check -> apply -> doctor`
- `validate:catalog`: managed catalog package の正規化状態と required asset の欠落を fail fast で検出する
- `prepare:catalog`: tracked catalog を publishable layout へ正規化する
- `install:catalog`: commit / push 後の catalog ref を install する
- `smoke:catalog`: 生成した catalog package を temp install で検証する

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
  - `prepare:catalog` / `validate:catalog` で正規化と検証を行う
  - `apply` / `install:catalog` で runtime target へ同期する

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
- 通常導線: `cd ~/.apm && mise install && mise run deploy`
- 公式 installer:
  - macOS / Linux: `curl -sSL https://aka.ms/apm-unix | sh`
  - Windows: `irm https://aka.ms/apm-windows | iex`
- 公式 installer は `mise` が使えない時の手動復旧用 fallback
