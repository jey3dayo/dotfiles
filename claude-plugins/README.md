# claude-plugins

Claude Code の marketplace と user scope plugin を宣言的に管理します。

| ファイル                     | 役割                         | Git 管理  |
| ---------------------------- | ---------------------------- | --------- |
| `plugins.toml`               | 公開してよいエントリ         | 管理対象  |
| `plugins.local.toml`         | 非公開のエントリ（同じ形式） | gitignore |
| `plugins.local.toml.example` | 非公開リストの書式例         | 管理対象  |

```bash
mise run claude:plugins             # check（読み取りのみ、不足があれば exit 2）
mise run claude:plugins -- --apply  # 不足分の marketplace add / plugin install --scope user
```

## 動作仕様

- 既存 plugin の削除は行いません。リスト外の user scope plugin と、user scope と重複する local / project 登録は報告のみ行います。
- 何度実行しても同じ結果になる冪等な動作です（揃っていれば `--apply` は no-op になります）。
- `skills-dir` marketplace の項目は、Claude が APM 管理のスキルディレクトリを plugin として表示しているだけで install できないため対象外です。リストには書かず、件数のみ info として表示します。
- 環境変数 `CLAUDE_PLUGINS_LOCAL` で非公開リストのパスを上書きできます。
- marketplace の `source` には `owner/repo`、`owner/repo#ref`、URL、ローカルパスを指定できます。ローカルパス（`./` `../` `~/` `/` で始まるもの）は絶対パスへ解決して比較します。相対パスは、リストファイルの実体（シンボリックリンクの場合はリンク先）があるディレクトリを基準にします。

## 非公開リストの同期

非公開スキルと同様に、正本は private リポジトリに置き、各 Mac ではそのファイルへのシンボリックリンクを `plugins.local.toml` として配置します。

```bash
ln -s <private-repo>/claude/plugins.toml ~/.config/claude-plugins/plugins.local.toml
```
