# APM Workspace Reference

最終更新: 2026-04-19
対象: 開発者
タグ: `category/infra`, `tool/apm`, `tool/mise`, `layer/agent`, `audience/developer`

Claude Rules: [.claude/rules/tools/mise.md](../../.claude/rules/tools/mise.md)
親ドキュメント: [Mise Reference](mise.md)

`~/.apm` を global APM workspace として扱う運用の正本です。  
この `.config` repo は **bootstrap と migration seed** だけを持ち、日常の APM 操作は `~/.apm/mise.toml` から実行します。

## Goal

- source of truth repo: `apm-workspace`
- local working copy: `~/.apm`
- manifest inside the checkout: `~/.apm/apm.yml`
- local package staging area inside the checkout: `~/.apm/packages/`
- workspace task file: `~/.apm/mise.toml`
- 通常配布: `cd ~/.apm && mise run apply`
- Codex 向け補助: `apm compile --target codex --output ~/.codex/AGENTS.md`

## Responsibility Split

`.config` 側の責務:

- `~/.apm` checkout の bootstrap
- `apm.yml` と `packages/README.md` の最小 scaffold
- managed `~/.apm/mise.toml` の注入
- legacy `agents/src/skills/` からの migration seed
- `nix/agent-skills-sources.nix` で有効化している external skill の vendor
- legacy Nix / Home Manager 配布の rollback 導線

`~/.apm` 側の責務:

- `apm install -g`
- `apm deps update -g`
- `apm compile`
- `apm.yml` / `apm.lock.yaml` / `packages/` の日常編集
- APM CLI 自体の更新 (`mise update`)

## Important Constraint

APM の `apm install -g` は user scope (`~/.apm/`) を使いますが、**workspace 自身の local `.apm/` content deployment は user scope ではスキップ**されます。  
そのため、repo-owned global skill を `~/.apm` で管理する場合は、`~/.apm/.apm/skills` を source-of-truth にせず、**installable local packages** として `~/.apm/packages/<skill>/` に置く前提を取ります。

ただし、実機検証した `apm 0.8.11` では **user scope の `apm install -g` が `./packages/*` local package をまだ扱えません**。  
Phase 1 ではまず `packages/` と `apm.yml` を source-of-truth として固め、実際の user-scope rollout は legacy 導線を残したまま進めます。

## Bootstrap Flow

`.config` から最初に行うのは bootstrap だけです。

```bash
cd ~/.config
mise run apm:bootstrap
```

`apm:bootstrap` は次を行います。

- `~/.apm` を `apm-workspace` checkout として用意する
- `~/.apm/apm.yml` が無ければ最小 manifest を生成する
- `~/.apm/packages/README.md` を作る
- managed `~/.apm/mise.toml` を注入する

既に `~/.apm/mise.toml` があり、かつ `.config` 管理の marker を含まない場合は上書きせず警告だけ出します。強制更新したい場合だけ `APM_BOOTSTRAP_FORCE_MISE=1` を使います。

## Daily Workflow

bootstrap 後は `~/.apm` 側へ移動します。

```bash
cd ~/.apm
mise install
mise run migrate -- apm-usage
mise run migrate-external
mise run apply
mise run validate
mise run doctor
```

`~/.apm/mise.toml` には次の task を入れます。

- `apply`: user-scope-compatible dependency だけを deploy
- `update`: checkout 更新 + `apm deps update -g` + deploy
- `list`: `apm deps list -g`
- `validate`: `apm compile --validate`
- `doctor`: workspace と deploy 先の確認
- `migrate`: legacy `~/.config/agents/src/skills/<id>` を `packages/<id>` へ seed
- `migrate-external`: `nix/agent-skills-sources.nix` の `selection.enable` を `packages/` へ vendor

## Migration Seed Flow

最初の移行は `apm-usage` を基準にします。

```bash
cd ~/.apm
mise run migrate -- apm-usage
mise run apply
```

`migrate` は `~/.config/scripts/apm-workspace.(sh|ps1)` を呼び出し、

- `~/.config/agents/src/skills/apm-usage/` を `~/.apm/packages/apm-usage/` へコピー
- workspace scope の `apm install ./packages/apm-usage` で `apm.yml` へ記録
- local package として validation まで行う

まで進めます。以後の編集は `~/.apm/packages/<skill>/` 側で行います。

external source を巻き取る時は次を使います。

```bash
cd ~/.apm
mise run migrate-external
```

`migrate-external` は次を行います。

- `~/.config/nix/agent-skills-sources.nix` の各 source を shallow clone
- その source の `selection.enable` に入っている skill だけを対象にする
- `idPrefix` がある skill は `packages/superpowers/<skill>/` のような nested package にする
- internal bundled skill (`agents/src/skills/...`) と同じ ID がある external skill は skip する
- workspace scope の `apm install ./packages/...` で `apm.yml` / `apm.lock.yaml` に記録する

これで external skill の source of truth も `~/.apm/packages/` へ寄せられます。

`apply` / `update` は `apm.yml` に `./packages/*` が入っている場合、現行 APM 制約を明示して停止します。  
その間の実 deploy は rollback 用に残している legacy 導線を使ってください。

## Legacy / Rollback

`.config` 側の legacy task は `agents:*` namespace に寄せます。

- `agents:validate`
- `agents:validate:internal`
- `agents:check:sync`
- `agents:report`
- `agents:legacy:*`

問題があれば `~/.apm` checkout 側の変更を戻してから、必要に応じて `mise run agents:legacy:install` で従来配布を再適用します。  
Home Manager 世代ベースで戻す場合は `mise run agents:legacy:rollback` を使います。

注意:
この `.config` リポジトリの branch を戻しても、`~/.apm` 側で行った編集や commit までは戻りません。

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
  - 既存 `~/.apm/packages/<skill>` を置き換えて migration したい時だけ使う

## APM CLI Installation Policy

- `.config` 側では `github:microsoft/apm` を `mise` で pin しておく
- `~/.apm/mise.toml` にも同じ tool 定義を注入し、workspace 側の `mise install` / `mise update` で運用する
- 通常導線: `cd ~/.apm && mise install`
- 公式 installer:
  - macOS / Linux: `curl -sSL https://aka.ms/apm-unix | sh`
  - Windows: `irm https://aka.ms/apm-windows | iex`
- 公式 installer は `mise` が使えない時の手動復旧用 fallback
