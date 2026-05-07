---
paths:
  - "nix/agent-skills-sources.nix"
  - "flake.nix"
  - "home.nix"
  - "docs/tools/apm-workspace.md"
  - "docs/tools/home-manager.md"
---

# Agent Skills Source of Truth

Purpose: スキル配布と編集元の混線を防ぎ、どこを編集するかを明確にする。

## 編集場所

- managed asset は personal skill なら `~/.apm/catalog/skills/**`、shared guidance なら `~/.apm/catalog/{AGENTS.md,agents/**,commands/**,rules/**}` を編集する。
- この `.config` repo で APM を操作しない。必要なら説明文書だけ更新する。
- `~/.claude/skills/**` と Nix store 上の skill bundle は配布物。検証対象にはしてよいが、修正対象にはしない。

## 判断基準

- 同名 skill が複数箇所にある場合は ownership を確認してから編集する。
- routing 監査や patch 提案が `~/.claude/skills/**` や store 上の配布先を指していても、そのまま適用せず編集元の path に引き直す。
- local fix が必要でも、まず `~/.apm/catalog/{skills/**,AGENTS.md,agents/**,commands/**,rules/**}` を正本として扱えるかを確認する。

## 重複時の扱い

- 同名 asset が複数箇所に見えても、配布先を直接編集しない。
- 原則は managed catalog を残し、配布差分は rollout 側で解消する。

## 配布物の見方

- 配布内容の正は `~/.apm/catalog/{skills/**,AGENTS.md,agents/**,commands/**,rules/**}` と `~/.apm/apm.yml` で決める。
- 配布後の `~/.claude/skills/**` に見える差分は、配布結果の確認材料であって編集元ではない。
