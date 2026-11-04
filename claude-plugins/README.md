# claude-plugins

Claude Code の marketplace と user scope plugin を宣言的に管理する。

| ファイル                     | 役割                         | git       |
| ---------------------------- | ---------------------------- | --------- |
| `plugins.toml`               | 公開してよいエントリ         | 管理      |
| `plugins.local.toml`         | 非公開のエントリ（同じ形式） | gitignore |
| `plugins.local.toml.example` | 非公開リストの書式例         | 管理      |

```bash
mise run claude:plugins             # check（読み取りのみ、不足があれば exit 2）
mise run claude:plugins -- --apply  # 不足分の marketplace add / plugin install --scope user
```

- 削除はしない。リスト外の user scope plugin と、user scope と重複する local / project 登録は報告のみ。
- 何度実行しても同じ結果になる（揃っていれば apply は no-op）。
- `CLAUDE_PLUGINS_LOCAL` で非公開リストのパスを上書きできる。

## 非公開リストの同期

非公開スキルと同じく、正本は private リポジトリに置き、各 Mac ではそのファイルへのシンボリックリンクを `plugins.local.toml` として置く想定。

```bash
ln -s <private-repo>/claude/plugins.toml ~/.config/claude-plugins/plugins.local.toml
```
