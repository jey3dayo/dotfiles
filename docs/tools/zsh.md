# Zsh Configuration

最終更新: 2026-06-26
対象: 開発者・上級者
タグ: `category/shell`, `tool/zsh`, `layer/core`, `environment/cross-platform`, `audience/advanced`

Zsh は高速起動を優先した最小構成です。旧構成は `zsh.legacy/` に退避し、現行の `zsh/` は entrypoint、`lib/`、`sheldon/`、`bin/` だけで構成します。

## 方針

- `.zshenv` は全 shell で読むため、XDG、`ZDOTDIR`、mise の環境変数、最小 PATH、`.env.local` だけを扱う。
- `.zshrc` は interactive shell 用の薄い orchestrator とし、`lib/*.zsh` を明示順に読む。
- 起動時に install、update、build、plugin lock 生成をしない。
- Sheldon は `zsh-abbr` と補完 repo の取得を管理し、cache は `zsh-sheldon-refresh` で明示生成する。起動時に install/update/lock はしない。
- `abbr` 展開は維持するが、通常起動では同期ロードしない。実ターミナルでは最初の ZLE line init で読み、テストや明示確認では `ZSH_LOAD_PLUGINS=1` を使う。
- `atuin` は `Ctrl-R` 履歴検索として使う。通常起動では同期ロードせず、実ターミナルでは最初の ZLE line init で読み、明示確認では `ZSH_LOAD_ATUIN=1` を使う。
- `fzf` は cache された shell integration だけを使う。通常起動では同期ロードせず、実ターミナルでは最初の ZLE line init で読み、明示確認では `ZSH_LOAD_FZF=1` を使う。`Ctrl-R` は `atuin` 優先で、fzf は `Ctrl-T` / `Alt-C` / `^]` / `^gx` などを使う。
- `fzf-tab` は補完 UI として使う。通常起動では同期ロードせず、実ターミナルでは最初の ZLE line init で読む。hook 登録順は fzf の後、autosuggestions / syntax highlighting より前にし、Tab 補完を fzf UI にする。
- Git widgets / `fzf-git` は通常起動では同期ロードせず、実ターミナルでは最初の ZLE line init で読む。Git menu は `^gg` / `^g^g`、status は `^gs` / `^g^s`、add patch は `^ga` / `^g^a`、branch switch は `^gb` / `^g^b`、worktree menu は `^gW` / `^g^W`、stash は `^gz` / `^g^z`、file picker は `^gf` / `^g^f`、help は `^g?`。
- `zsh-autosuggestions` は入力候補表示として使う。通常起動では同期ロードせず、実ターミナルでは最初の ZLE line init で読み、明示確認では `ZSH_LOAD_AUTOSUGGESTIONS=1` を使う。
- `fast-syntax-highlighting` は入力中の syntax highlight として使う。通常起動では同期ロードせず、実ターミナルでは最初の ZLE line init で最後に読む。
- `gh` completion は cache file を使う。通常起動では同期ロードせず、実ターミナルでは最初の ZLE line init で読み、明示確認では `ZSH_LOAD_GH=1` を使う。起動時に `gh completion` は実行しない。
- `zoxide` は `z` / `j` 移動用に使う。通常起動では同期ロードせず、実ターミナルでは最初の ZLE line init で読み、明示確認では `ZSH_LOAD_ZOXIDE=1` を使う。
- `ni` / `nlx`、`eza`、`bun` の補完は戻す。起動時に生成せず、既存 completion file を読む。
- WSL 固有設定は WSL 環境でだけ読む。
- starship はデフォルト有効。切り分けや最小起動が必要な場合だけ `ZSH_DISABLE_STARSHIP=1` で無効化する。

## ロード順

1. `home/.zshenv` が `~/.config/zsh/.zshenv` を source する。
2. `zsh/.zshenv` が XDG、mise、PATH、history、`.env.local` を初期化する。
3. login shell では `zsh/.zprofile` が locale/editor と PATH 正規化を行う。
4. interactive shell では `zsh/.zshrc` が以下を順に読む。
   - `lib/path.zsh`
   - `lib/options.zsh`
   - `lib/history.zsh`
   - `lib/tool-completions.zsh`
   - `lib/completion.zsh`
   - `lib/ni.zsh`
   - `lib/gh.zsh`
   - `lib/history-search.zsh`
   - `lib/fzf.zsh`
   - `lib/fzf-tab.zsh`
   - `lib/git-widgets.zsh`
   - `lib/autosuggestions.zsh`
   - `lib/atuin.zsh`
   - `lib/zoxide.zsh`
   - `lib/wsl.zsh`
   - `lib/plugins.zsh`
   - `lib/prompt.zsh`
   - `lib/syntax-highlighting.zsh`

## ディレクトリ

```text
zsh/
├── .zshenv
├── .zprofile
├── .zshrc
├── .zlogin
├── bin/
│   ├── zsh-benchmark
│   ├── zsh-fzf-refresh
│   ├── zsh-gh-completion-refresh
│   └── zsh-sheldon-refresh
├── completions/
├── lib/
│   ├── completion.zsh
│   ├── history.zsh
│   ├── history-search.zsh
│   ├── atuin.zsh
│   ├── autosuggestions.zsh
│   ├── fzf.zsh
│   ├── fzf-tab.zsh
│   ├── git-widgets.zsh
│   ├── gh.zsh
│   ├── ni.zsh
│   ├── options.zsh
│   ├── path.zsh
│   ├── plugins.zsh
│   ├── prompt.zsh
│   ├── syntax-highlighting.zsh
│   ├── tool-completions.zsh
│   ├── wsl.zsh
│   └── zoxide.zsh
└── sheldon/
    └── plugins.toml
```

## Sheldon / abbr

現行の Sheldon plugin は `zsh-abbr`、補完 repo 取得用の `ni-completion`、`eza`、`bun`、Git widget 用の `fzf-git`、補完 UI 用の `fzf-tab`、入力候補用の `zsh-autosuggestions`、syntax highlight 用の `fast-syntax-highlighting` です。Sheldon cache が source するのは `zsh-abbr` だけで、補完 file、`fzf-git`、`fzf-tab`、`zsh-autosuggestions`、`fast-syntax-highlighting` は `lib/` 側から必要なものを直接読みます。Sheldon cache 自体は通常起動では同期ロードせず、実ターミナルでは最初の ZLE line init で読みます。

```bash
zsh-sheldon-refresh
zsh-fzf-refresh
zsh-gh-completion-refresh
ZSH_LOAD_PLUGINS=1 zsh -lic 'abbr expand gst'
ZSH_LOAD_FZF=1 ZSH_LOAD_GH=1 zsh -lic 'bindkey "^]"; bindkey "^T"; bindkey "^gx"; whence _gh'
ZSH_LOAD_GIT_WIDGETS=1 zsh -lic 'bindkey "^gg"; bindkey "^gs"; bindkey "^ga"; bindkey "^gb"; bindkey "^gW"; bindkey "^gz"; bindkey "^g^f"; bindkey "^g?"'
ZSH_LOAD_FZF_TAB=1 ZSH_LOAD_AUTOSUGGESTIONS=1 ZSH_LOAD_SYNTAX_HIGHLIGHTING=1 zsh -lic 'bindkey "^I"; whence _zsh_autosuggest_start; whence fast-theme'
```

`zsh-abbr` のユーザー定義は既定どおり `zsh-abbr/user-abbreviations` を使います。alias ではなく、入力後に展開される abbreviation として運用します。

## 保留中の機能

以下は旧構成からまだ戻していない機能です。戻す場合は 1 機能ずつ追加し、`zsh-benchmark` と `zprof` で同期起動 path に乗らないことを確認します。

| 優先度 | 機能                                     | 用途                                                          | 方針                                                |
| ------ | ---------------------------------------- | ------------------------------------------------------------- | --------------------------------------------------- |
| P3     | `pnpm-shell-completion`                  | pnpm 補完                                                     | 重さ疑いあり。必要性が出るまで保留。                |
| P3     | `pnpm-shell-completion-install`          | pnpm completion build                                         | 起動時には入れない。必要なら手動 task 化。          |
| P3     | oh-my-zsh plugins                        | `sudo` / `clipboard` / `functions` など                       | 原則戻さない。必要なものだけ個別検討。              |
| P3     | `1password-op.plugin.zsh`                | 1Password helper                                              | 起動時不要。                                        |
| P3     | 診断 helper                              | `zsh-help` / `path-check` / `zsh-quick-check` / `mise-status` | source ではなく `bin/` コマンド化する場合のみ検討。 |
| P3     | `lazy-sources/arch.zsh` / `orbstack.zsh` | 環境別設定                                                    | 該当環境で必要になった場合のみ条件付きで戻す。      |

## 検証

```bash
zsh-benchmark --runs 8 --mode interactive
zsh-benchmark --runs 3 --mode interactive-login
ZSH_PROFILE_STARTUP=1 zsh -ic 'zprof'
bun test --timeout 20000 scripts/zsh-env-loading.test.ts
mise run test:lua
home-manager build --flake ~/.config --impure
```

## 退避済み構成

旧構成は `zsh.legacy/` に残しています。FZF/Git widgets、fzf-tab、zoxide、autosuggestions、syntax highlighting、旧 `config/tools/*` はここにあります。戻す場合は 1 機能ずつ戻し、毎回 `zsh-benchmark` と `zprof` で確認します。
