# AI 開発協働ガイド

この `AGENTS.md` は `~/.config` リポジトリ専用のプロジェクトルールです。
共通の作業原則・DoD・Failure Policy・基本ワークフローは共通ガイドを参照し、このファイルには repo 固有の差分だけを書くこと。共通ガイドは runtime 別に配布される同一内容の文書で、Codex は `~/.codex/AGENTS.md`、Claude は `~/.claude/rules/ai-collaboration.md` を読む（正本は apm-workspace checkout の `~/src/github.com/jey3dayo/apm-workspace/catalog/.apm/instructions/ai-collaboration.instructions.md`）。
この repo で作業するエージェントは、まずこの文書でプロジェクト固有ルールを確認してください。

## ドキュメントの役割分担

- このファイル: この repo のプロジェクト固有ルールと上書き事項の正本
- 共通ガイド（runtime 別配布先 `~/.codex/AGENTS.md` / `~/.claude/rules/ai-collaboration.md`、正本は `~/src/github.com/jey3dayo/apm-workspace/catalog/.apm/instructions/ai-collaboration.instructions.md`）: 共通ルール。この repo 固有のルールは持たない
- `docs/`: 詳細な手順・運用・設計の正本
- `.claude/rules/`: Claude 向けの圧縮ルールと導線
- `CLAUDE.md`: Claude 向けの薄い入口

## 優先順位

1. ユーザーの明示的な指示
2. この `AGENTS.md`
3. `docs/` の各正本
4. `.claude/rules/` の圧縮ルール
5. `CLAUDE.md`
6. 共通ガイド（`~/.codex/AGENTS.md` / `~/.claude/rules/ai-collaboration.md`）

## この Repo の追加ルール

- `docs/` 配下の手順・運用・設計は、この repo では正本として扱う
- パッケージ管理の責務分離（どの層でツールを管理するか）は `docs/setup.md` の Package Management Philosophy を正本とし、他の文書へ再掲しない
- apm-workspace の共通ガイドは全 repo 共通の配布元であり、この repo 固有の運用判断には使わない
- 非軽微な変更の独立レビューは、Claude セッションからは組み込み `/code-review`、または `agmsg-delegation` の review 経路で Codex reviewer を起動する。Codex セッション内では手動差分確認または別プロセスの `codex exec` で代替可
- 共通ルールをこのファイルへ再掲しない。必要な場合は共通ガイドを参照する
- 番号付き選択肢は、スクロールなしで意味が分かる短さに保つ

## Codex のプロファイルと abbr

- 共通設定は `~/.codex/config.toml`、用途別の差分は `~/.codex/<name>.config.toml` に置く。プロファイルは共通設定に重ね、同じキーだけを上書きする
- 通常は Terra medium を基本にし、難しい設計・調査には `design`、Luna を使う作業には `luna` を選ぶ。具体的なモデル名と推論強度は各 TOML を確認する
- 用途別のモデル・推論強度・権限はプロファイルで管理する。プロファイルを使う abbr は `zsh-abbr/user-abbreviations` で `codex --profile <name>` を指定する
- Plan の推論強度とモデルの選択は別に扱う。Plan に入るだけでモデルも切り替わると想定せず、必要ならモデル選択機能で切り替える
- 変更後は abbr の構文・展開、プロファイルの読み込み、共通設定と重ねた値を確認する
- この運用ルールは本ファイルで管理し、APM が生成する `~/.codex/AGENTS.md` は直接編集しない
