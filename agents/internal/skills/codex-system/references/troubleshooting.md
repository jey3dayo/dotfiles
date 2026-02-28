# トラブルシューティング

## Codex CLI が見つからない

```bash
# 確認
which codex
codex --version

# インストール
npm install -g @openai/codex
```

## 認証エラー

```bash
# 再認証
codex login

# ステータス確認
codex login status
```

## タイムアウト

| reasoning_effort | 推奨タイムアウト |
| ---------------- | ---------------- |
| low              | 60s              |
| medium           | 180s             |
| high             | 600s             |
| xhigh            | 900s             |

config.toml で設定:

```toml
[mcp_servers.codex]
tool_timeout_sec = 600
```

## Git リポジトリエラー

```bash
# Git 管理外で実行する場合
codex exec --skip-git-repo-check ...
```

## reasoning 出力が多すぎる

```bash
# stderr 抑制
codex exec ... 2>/dev/null

# または config.toml で
hide_agent_reasoning = true
```

## セッション継続できない

```bash
# 最近のセッション一覧
codex sessions list

# 特定セッションの詳細
codex sessions show {SESSION_ID}
```

### resume --last で前セッションを再開

resume 時は `--sandbox` を指定できない（セッション元の設定が引き継がれる）。`--full-auto`, `--all` 等のフラグは指定可能。
プロンプトは stdin 経由で渡す。

```bash
# 最新セッションを再開（CWDスコープ）
echo "follow-up instruction" | codex exec resume --last 2>/dev/null

# 全CWDのセッションから最新を再開
echo "follow-up instruction" | codex exec resume --last --all 2>/dev/null
```

### resume --last が失敗する場合

| 症状              | 原因                       | 解決策                                    |
| ----------------- | -------------------------- | ----------------------------------------- |
| No session found  | CWD内にセッションなし      | `--all` を試すか新規 `codex exec`         |
| Session corrupted | JSONL 破損                 | `~/.codex/sessions/` の該当ファイルを確認 |
| Context too large | 前セッションが巨大         | 新規 `codex exec` にフォールバック        |

## sandbox 権限エラー

| エラー            | 原因                 | 解決策                       |
| ----------------- | -------------------- | ---------------------------- |
| Permission denied | read-only で書き込み | workspace-write に変更       |
| Network blocked   | sandbox 制限         | danger-full-access（慎重に） |

## メモリ不足

大きなコードベースを分析する場合:

1. 対象ファイルを絞る
2. 段階的に分析
3. `--config context_limit=...` で調整
