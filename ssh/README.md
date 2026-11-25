# SSH Configuration

階層的な Include 構造（`config.d/common/` → プラットフォーム別 → ローカル）で、1Password SSH Agent 統合と接続最適化設定を管理しています。

エントリポイントは [`config`](config)（`config.d/**` を Include）です。

詳細な設定構造・ホスト追加手順・トラブルシューティングは [`docs/tools/ssh.md`](../docs/tools/ssh.md) を正本として参照してください。Claude 向けの短いルールは [`.claude/rules/tools/ssh.md`](../.claude/rules/tools/ssh.md) にあります。
