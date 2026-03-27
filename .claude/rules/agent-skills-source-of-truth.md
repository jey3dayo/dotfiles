---
paths: agents/src/skills/**, nix/agent-skills-sources.nix, flake.nix, home.nix, docs/tools/home-manager.md
---

# Agent Skills Source of Truth

Purpose: スキル配布と編集元の混線を防ぎ、正しい source のみを変更する。

## 編集優先順位

- `agents/src/skills/**` はこの repo で管理する source of truth。スキル修正はまずここを編集する。
- flake inputs 経由のスキルは外部由来。原則として直接編集しない。
- `~/.claude/skills/**` と Nix store 上の skill bundle は配布物。検証対象にはしてよいが、修正対象にはしない。

## 変更ルール

- 同名 skill が複数箇所にある場合は ownership を確認してから編集する。
- routing 監査や patch 提案が `~/.claude/skills/**` や store 上の配布先を指していても、そのまま適用せず source path に引き直す。
- local fix が必要でも、まず `src` への移管、override、重複整理を検討する。
- flake input に差分を入れるのは、ユーザーが明示的に許可した意図的な fork のときだけ。

## 重複対応

- `src` と flake input sources に同名 skill がある場合は、両方を並行修正しない。
- 原則は `src` を残し、外部ソースは削除、非選択、参照停止のいずれかで整理する。
- 配布設定の調整で解決できる重複は、vendor 側の直接編集より優先する。

## 配布時の扱い

- 配布内容の正は `agents/src/skills/**` と選択設定で決める。
- 配布後の `~/.claude/skills/**` に見える差分は、配布結果の確認材料であって source of truth ではない。
