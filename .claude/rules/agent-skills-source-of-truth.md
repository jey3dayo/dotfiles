---
paths:
  - "docs/tools/apm-workspace.md"
---

# Agent Skills Source of Truth

Purpose: スキル配布と編集元の混線を防ぎ、どこを編集するかを明確にする。

## 編集場所

- managed asset は personal skill なら `~/.apm/catalog/skills/**`、shared guidance なら `~/.apm/catalog/{AGENTS.md,agents/**,commands/**,rules/**}` を編集する。
- この `.config` repo から `~/.apm` の catalog や global 配布を操作しない。必要なら説明文書だけ更新する。repo-local skill の再配布は下記の例外。
- `~/.claude/skills/**` は配布物。検証対象にはしてよいが、修正対象にはしない。

## repo-local skill の扱い

`apm.yml` の `dependencies.apm` が自リポジトリの `skills/*` を宣言している場合（この repo の `skills/{nvim,wezterm,zsh}` が該当）、その skill は managed catalog に属さない。

- 正本は repo 内の `skills/**`。`.claude/skills/**` と `.agents/skills/**` は配布先なので直接編集しない。
- 変更手順は「`skills/**` を編集 → commit → **push** → `apm install --update`」。依存はリモート ref を解決するため、push 前に `apm install` すると配布先が古い内容へ巻き戻る。`apm audit` は正本の変更を drift として報告するので、drift の解消は push 後に行う。
- `apm.lock.yaml` の更新はこの再配布の一部であり、上の「APM を操作しない」が禁じる対象には含めない。
- ドリフトの有無は `apm audit`（read-only）で確認する。`No drift detected` になれば同期済み。

## 判断基準

- 同名 skill が複数箇所にある場合は ownership を確認してから編集する。まず `apm.yml` の `dependencies.apm` に自リポジトリの宣言があるかを見る。あれば repo-local、無ければ managed catalog。
- routing 監査や patch 提案が `~/.claude/skills/**` などの配布先を指していても、そのまま適用せず編集元の path に引き直す。
- local fix が必要でも、まず `~/.apm/catalog/{skills/**,AGENTS.md,agents/**,commands/**,rules/**}` を正本として扱えるかを確認する。

## 重複時の扱い

- 同名 asset が複数箇所に見えても、配布先を直接編集しない。
- 原則は managed catalog を残し、配布差分は rollout 側で解消する。

## 配布物の見方

- 配布内容の正は `~/.apm/catalog/{skills/**,AGENTS.md,agents/**,commands/**,rules/**}` と `~/.apm/apm.yml` で決める。
- 配布後の `~/.claude/skills/**` に見える差分は、配布結果の確認材料であって編集元ではない。
