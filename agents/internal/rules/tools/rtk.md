# RTK (Rust Token Killer)

Purpose: RTK コマンドリファレンス。コマンドに常に `rtk` プレフィックスを付けること。
Source: <https://github.com/jey3dayo/rtk>

## ゴールデンルール

**すべてのコマンドに `rtk` プレフィックスを付ける。** RTK にフィルターがあれば適用し、なければそのままパススルーするため、常に安全に使える。`&&` チェーンでも各コマンドに付ける:

```bash
# ✅ rtk git add . && rtk git commit -m "msg" && rtk git push
# ❌ git add . && git commit -m "msg" && git push
```

## コマンドリファレンス

### Build & Compile (70-90%)

| コマンド               | 削減率 | 説明                               |
| ---------------------- | ------ | ---------------------------------- |
| `rtk cargo build`      | 80-90% | Cargo ビルド出力                   |
| `rtk cargo check`      | 80-90% | Cargo チェック出力                 |
| `rtk cargo clippy`     | 80%    | Clippy 警告をファイル別にグループ  |
| `rtk tsc`              | 83%    | TS エラーをファイル/コード別集約   |
| `rtk lint`             | 84%    | ESLint/Biome 違反をグループ        |
| `rtk prettier --check` | 70%    | フォーマット必要ファイルのみ表示   |
| `rtk next build`       | 87%    | Next.js ビルド（ルートメトリクス） |

### Test (90-99%)

| コマンド              | 削減率 | 説明               |
| --------------------- | ------ | ------------------ |
| `rtk cargo test`      | 90%    | 失敗テストのみ表示 |
| `rtk vitest run`      | 99.5%  | 失敗テストのみ表示 |
| `rtk playwright test` | 94%    | 失敗テストのみ表示 |
| `rtk test <cmd>`      | —      | 汎用テストラッパー |

### Git (59-80%)

| コマンド         | 削減率 | 説明                           |
| ---------------- | ------ | ------------------------------ |
| `rtk git status` | —      | コンパクトステータス           |
| `rtk git log`    | —      | コンパクトログ（全フラグ対応） |
| `rtk git diff`   | 80%    | コンパクト差分                 |
| `rtk git show`   | 80%    | コンパクト表示                 |
| `rtk git add`    | 59%    | 超コンパクト確認               |
| `rtk git commit` | 59%    | 超コンパクト確認               |
| `rtk git push`   | —      | 超コンパクト確認               |

> Git パススルーは全サブコマンドに対応（branch, fetch, stash, worktree 等）

### GitHub (26-87%)

| コマンド               | 削減率 | 説明                   |
| ---------------------- | ------ | ---------------------- |
| `rtk gh pr view <num>` | 87%    | コンパクト PR 表示     |
| `rtk gh pr checks`     | 79%    | コンパクト PR チェック |
| `rtk gh run list`      | 82%    | コンパクト実行一覧     |
| `rtk gh issue list`    | 80%    | コンパクト Issue 一覧  |
| `rtk gh api`           | 26%    | コンパクト API 応答    |

### JS/TS Tooling (70-90%)

| コマンド            | 削減率 | 説明                     |
| ------------------- | ------ | ------------------------ |
| `rtk pnpm install`  | 90%    | コンパクトインストール   |
| `rtk pnpm list`     | 70%    | コンパクト依存ツリー     |
| `rtk pnpm outdated` | 80%    | コンパクト更新候補       |
| `rtk npm run <s>`   | —      | コンパクトスクリプト出力 |
| `rtk npx <cmd>`     | —      | コンパクト npx 出力      |
| `rtk prisma`        | 88%    | ASCII アートなし         |

### Files & Search (60-75%)

| コマンド          | 削減率 | 説明                       |
| ----------------- | ------ | -------------------------- |
| `rtk ls <path>`   | 65%    | ツリー形式コンパクト表示   |
| `rtk read <file>` | 60%    | フィルタ付きコード読み取り |
| `rtk grep <pat>`  | 75%    | ファイル別グループ検索     |
| `rtk find <pat>`  | 70%    | ディレクトリ別グループ     |

### Infrastructure (85%)

| コマンド              | 削減率 | 説明                   |
| --------------------- | ------ | ---------------------- |
| `rtk docker ps`       | 85%    | コンパクトコンテナ一覧 |
| `rtk docker images`   | 85%    | コンパクトイメージ一覧 |
| `rtk docker logs <c>` | 85%    | 重複排除ログ           |
| `rtk kubectl get`     | 85%    | コンパクトリソース一覧 |
| `rtk kubectl logs`    | 85%    | 重複排除 Pod ログ      |

### Meta Commands

| コマンド             | 説明                                      |
| -------------------- | ----------------------------------------- |
| `rtk gain`           | トークン削減統計を表示                    |
| `rtk gain --history` | コマンド履歴と削減率                      |
| `rtk discover`       | Claude Code セッションの RTK 未使用を検出 |
| `rtk proxy <cmd>`    | フィルタなしで実行（デバッグ用）          |
| `rtk init`           | CLAUDE.md に RTK 指示を追加               |
| `rtk init --global`  | ~/.claude/CLAUDE.md に追加                |

## カスタムフィルター (.rtk/filters.toml)

プロジェクトルートに `.rtk/filters.toml` を配置すると、プロジェクト固有のフィルターを定義できる。ビルトイン・ユーザーグローバルより優先される。

```toml
schema_version = 1

[filters.my-tool]
description = "Compact my-tool output"
match_command = "^my-tool\\s+build"
strip_ansi = true
strip_lines_matching = ["^\\s*$", "^Downloading", "^Installing"]
max_lines = 30
on_empty = "my-tool: ok"
```

| フィールド             | 説明                                       |
| ---------------------- | ------------------------------------------ |
| `match_command`        | コマンドにマッチする正規表現               |
| `strip_ansi`           | ANSI エスケープシーケンスを除去            |
| `strip_lines_matching` | マッチする行を除去する正規表現の配列       |
| `max_lines`            | 出力の最大行数                             |
| `on_empty`             | フィルタ後に出力が空の場合の代替メッセージ |
