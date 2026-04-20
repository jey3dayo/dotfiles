---
paths:
  - "nix/agent-skills-sources.nix"
  - "flake.nix"
  - "home.nix"
  - "scripts/apm-workspace.ps1"
  - "scripts/apm-workspace.sh"
  - "docs/tools/apm-workspace.md"
  - "docs/tools/home-manager.md"
---

# Agent Skills Source of Truth

Purpose: スキル配布と編集元の混線を防ぎ、どこを編集するかを明確にする。

## 編集場所

- managed asset は `~/.apm/catalog/.apm/skills/**` と `~/.apm/catalog/{AGENTS.md,agents/**,commands/**,rules/**}` を編集する。
- この `.config` repo で編集するのは bootstrap helper と external source mapping に限る。
- flake inputs 経由のスキルは外部由来。原則として直接編集しない。
- `~/.claude/skills/**` と Nix store 上の skill bundle は配布物。検証対象にはしてよいが、修正対象にはしない。

## 判断基準

- 同名 skill が複数箇所にある場合は ownership を確認してから編集する。
- routing 監査や patch 提案が `~/.claude/skills/**` や store 上の配布先を指していても、そのまま適用せず編集元の path に引き直す。
- local fix が必要でも、まず `~/.apm/catalog/**` か upstream source のどちらを直すべきかを判断する。
- flake input に差分を入れるのは、ユーザーが明示的に許可した意図的な fork のときだけ。

## 重複時の扱い

- managed catalog と flake input sources に同名 skill がある場合は、両方を並行修正しない。
- 原則は managed catalog を残し、外部ソースは削除、非選択、参照停止のいずれかで整理する。
- 配布設定の調整で解決できる重複は、vendor 側の直接編集より優先する。

## 配布物の見方

- 配布内容の正は `~/.apm/catalog/**` と `nix/agent-skills-sources.nix` の選択設定で決める。
- 配布後の `~/.claude/skills/**` に見える差分は、配布結果の確認材料であって編集元ではない。
