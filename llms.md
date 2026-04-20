# LLM Context for `~/.config`

このファイルは、LLM/AI エージェントが `~/.config` リポジトリを読むときの最小限の入口です。詳細や運用判断はここではなく、必ず正本を参照してください。

## Source of Truth

- Repo 固有ルール: `AGENTS.md`
- 人間向けの正本ドキュメント: `docs/`
- ドキュメント体系の正本: `docs/documentation.md`
- セットアップの正本: `docs/setup.md`
- 運用・保守・品質チェックの正本: `docs/tools/workflows.md`
- AI 向け高レベル文脈: `.kiro/steering/`
- Claude 向け入口: `CLAUDE.md`

優先順位は `AGENTS.md` に従います。`docs/` 配下の詳細手順はこの repo では正本です。

## Repository Summary

- 個人用 dotfiles リポジトリです
- Home Manager を中心に、macOS / Linux / WSL2 / Windows の開発環境を管理します
- 開発ツールは原則 `mise`、システム依存と GUI は `Homebrew`、Windows bootstrap は `Chocolatey` を使います
- ドキュメントは `docs/` に集約し、`README.md` やハブ文書はナビゲーションを担当します

## What To Read First

目的別の入口:

- ルール確認: `AGENTS.md`
- 全体像把握: `README.md`
- AI セッション向け背景: `.kiro/steering/product.md`, `.kiro/steering/tech.md`, `.kiro/steering/structure.md`
- 初期セットアップ: `docs/setup.md`
- 日常運用と品質チェック: `docs/tools/workflows.md`
- ツール別詳細: `docs/tools/*.md`

## Quality Gates

変更時は次を満たします。

- 型エラー 0
- リント違反 0
- テスト成功
- フォーマッター適用済み

代表コマンド:

```bash
mise run format
mise run lint
mise run test
mise run ci
```

日常の軽量確認は `mise run ci:quick` を使います。詳細は `docs/tools/workflows.md` を参照してください。

## Important Conventions

- 指示された範囲のみ変更する
- 既存ファイルの編集を優先し、新規ファイル作成は必要最小限にする
- `docs/` の内容を別の場所へ重複して再掲しない
- ツール追加時は、まず `mise` で管理できるかを検討する
- `README.md` は入口、詳細は `docs/` の正本へ置く

## Key Paths

```text
AGENTS.md                Project-specific rules
README.md                Human-facing overview
CLAUDE.md                Thin AI entry point
.kiro/steering/          Always-loaded AI context
docs/                    Human-facing source of truth
docs/tools/              Tool-specific source documents
mise/                    Mise config and tasks
nix/                     Home Manager modules
windows/                 Windows bootstrap and setup
scripts/                 Bootstrap and helper scripts
```

## When Unsure

実装や運用判断に迷ったら、この順で確認してください。

1. `AGENTS.md`
2. 対応する `docs/` の正本
3. `.kiro/steering/`
4. `README.md` / `docs/README.md`

このファイルは要約です。正本の内容と矛盾した場合は、必ず正本を優先してください。
