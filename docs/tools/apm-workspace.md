# APM Workspace Reference

最終更新: 2026-11-12  
対象: 開発者  
タグ: `category/infra`, `tool/apm`, `tool/mise`, `layer/agent`, `audience/developer`

Claude Rules: [.claude/rules/tools/mise.md](../../.claude/rules/tools/mise.md)  
親ドキュメント: [Mise Reference](mise.md)

global skill・agent・共通ガイドの編集と配布は、apm-workspace の checkout で行います。  
この `.config` repo は APM の編集面でも操作面でもなく、参照先を示すための説明だけを持ちます。手順の正本は apm-workspace 側の `README.md`・`AGENTS.md`・`docs/native-distribution.md` で、ここには写しません。

## 置き場所

| 対象                 | 場所                                                                        | 扱い                               |
| -------------------- | --------------------------------------------------------------------------- | ---------------------------------- |
| authoring checkout   | `~/src/github.com/jey3dayo/apm-workspace`                                   | 日常の編集・検証・配布をここで行う |
| personal skill       | checkout の `catalog/.apm/skills/<id>/`                                     | 正本                               |
| agent                | checkout の `catalog/.apm/agents/<name>.agent.md`                           | 正本                               |
| 共通ガイド           | checkout の `catalog/.apm/instructions/ai-collaboration.instructions.md`    | 正本                               |
| commands / rules     | checkout の `catalog/{commands,rules}/**`                                   | 正本                               |
| external skill / MCP | checkout の `apm.yml` / `apm.lock.yaml`                                     | 正本                               |
| consumer state       | `~/.apm`（`apm.yml`・`apm.lock.yaml`・`apm_modules/` など）                 | install 結果。編集しない           |
| 配布先               | `~/.claude/{skills,agents,rules}`・`~/.codex/AGENTS.md`・`~/.agents/skills` | 生成物。編集しない                 |

共通ガイドは `apm compile -g` が `~/.codex/AGENTS.md` と `~/.cursor/AGENTS.md` に書き出し、Claude は `~/.claude/rules/ai-collaboration.md` として読みます。

## よく使うコマンド

```bash
cd ~/src/github.com/jey3dayo/apm-workspace
mise run check        # 配布せずに検証する
mise run native:sync  # push 済みの commit を配布する
mise run doctor       # 配布状態と learning-intake を確認する
```

旧来の `~/.apm` での `mise run deploy` / `apply` / `refresh` は 2026-11-10 に廃止されています。

## APM CLI

APM CLI は `pipx:apm-cli` として mise で pin します。`.config` 側は `mise/config.dev.toml`、apm-workspace 側は checkout の `mise.toml` が pin を持ちます。
