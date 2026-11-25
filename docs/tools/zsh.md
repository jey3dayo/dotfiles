---
type: reference
title: Zsh Configuration
description: 高速起動を優先した Zsh の最小構成、遅延ロード方針、読み込み順、起動時間検証
resource: docs/tools/zsh.md
tags:
  - category/shell
  - layer/core
  - tool/zsh
  - environment/cross-platform
  - audience/advanced
timestamp: 2026-11-25
audience: advanced
owner: dotfiles
---

# Zsh Configuration

Zsh は高速起動を優先した最小構成で運用しています。旧構成はリポジトリには残さず、`7eac3d54`（`refactor(zsh): rebuild startup configuration`）以前の Git 履歴にのみ残っています。現行の `zsh/` はエントリポイント、`lib/`、`completions/`、`sheldon/`、`bin/` を中心に構成しています。

Claude 向けの短いルールは [`.claude/rules/tools/zsh.md`](../../.claude/rules/tools/zsh.md) にあります。

## 設計方針

### 基本原則

- `.zshenv` は全シェルで読み込まれるため、XDG、`ZDOTDIR`、`mise` の環境変数、最小 PATH、`.env.local` のみを扱います。
- `.zshrc` は対話シェル向けの薄い orchestrator とし、`lib/<category>/*.zsh` を明示順に読み込みます。
- 起動時に install・update・build・plugin lock 生成は行いません。
- `ni` / `nlx`、`eza`、`bun` の補完は起動時に生成せず、既存の補完ファイルを読み込みます。
- `Ctrl-P` / `Ctrl-N` は `zsh/lib/core/history.zsh` の `history-beginning-search-*-end` による prefix 履歴検索を使用します（`fzf` / `atuin` とは別系統です）。
- WSL 固有設定は WSL 環境でのみ読み込みます。
- Starship はキャッシュファイルがある場合のみ読み込み、起動時に `starship init zsh` は実行しません。キャッシュがない場合や `ZSH_DISABLE_STARSHIP=1` の場合は軽量プロンプトへフォールバックします。キャッシュは `starship init zsh > ~/.cache/zsh/starship/init.zsh` で再生成します。

### 遅延ロードとキャッシュ対象

通常起動では重いプラグインやシェル統合を同期ロードせず、初回プロンプト表示（`precmd`）や対象キー・コマンドの初回実行時に読み込みます。

| 対象                       | 役割                               | 通常時の読み込みタイミング               | 明示確認フラグ                   | 備考                                                                                      |
| -------------------------- | ---------------------------------- | ---------------------------------------- | -------------------------------- | ----------------------------------------------------------------------------------------- |
| `zsh-abbr`（Sheldon）      | abbreviation 展開                  | 最初の `precmd`                          | `ZSH_LOAD_PLUGINS=1`             | キャッシュは `zsh-sheldon-refresh` で明示生成します。                                     |
| `atuin`                    | `Ctrl-R` 履歴検索                  | `Ctrl-R` の初回実行時                    | `ZSH_LOAD_ATUIN=1`               | `Ctrl-R` は `fzf` より `atuin` を優先します。                                             |
| `fzf`                      | ファイル・ディレクトリ等の絞り込み | `Ctrl-T` / `Alt-C` / `^g^c` の初回実行時 | `ZSH_LOAD_FZF=1`                 | キャッシュ済み shell integration のみ使用します（`^]` / `^gx` 等も含みます）。            |
| `fzf-tab`                  | Tab 補完の fzf UI                  | 最初の `precmd`                          | `ZSH_LOAD_FZF_TAB=1`             | hook 登録順は `fzf` の後、`autosuggestions` / `syntax-highlighting` より前にします。      |
| Git widgets / `fzf-git`    | Git 操作ウィジェット               | 最初の `precmd`                          | `ZSH_LOAD_GIT_WIDGETS=1`         | バインド一覧は [`docs/tools/fzf-integration.md`](fzf-integration.md) を参照してください。 |
| `zsh-autosuggestions`      | 入力候補の表示                     | 最初の `precmd`                          | `ZSH_LOAD_AUTOSUGGESTIONS=1`     | —                                                                                         |
| `fast-syntax-highlighting` | 入力中のシンタックスハイライト     | 最初の `precmd`（最後）                  | `ZSH_LOAD_SYNTAX_HIGHLIGHTING=1` | ZLE デコレータとして最後に読み込みます。                                                  |
| `gh` 補完                  | GitHub CLI 補完                    | 最初の `precmd`                          | `ZSH_LOAD_GH=1`                  | キャッシュファイルのみ読み込み、起動時に `gh completion` は実行しません。                 |
| `zoxide`                   | `z` / `j` によるディレクトリ移動   | `z` / `j` の初回実行時                   | `ZSH_LOAD_ZOXIDE=1`              | —                                                                                         |

## ロード順

1. `home/.zshenv` が `~/.config/zsh/.zshenv` を読み込みます。
2. `zsh/.zshenv` が XDG、`mise`、PATH、history、`.env.local` を初期化します。
3. ログインシェルでは `zsh/.zprofile` が locale / editor の設定と PATH の正規化を行います。
4. 対話シェルでは `zsh/.zshrc` が以下の順に読み込みます。
   - Core shell state: `lib/core/path.zsh`, `lib/core/options.zsh`, `lib/core/history.zsh`
   - Completion setup: `lib/completion/completion.zsh`, `lib/completion/ni.zsh`, `lib/completion/gh-completion.zsh`, `lib/integrations/aicommits.zsh`
   - Agent integrations: `lib/integrations/agmsg.zsh`, `lib/integrations/codex.zsh`, `lib/integrations/secrets.zsh`
   - Key bindings and widgets: `lib/widgets/fzf.zsh`, `lib/widgets/fzf-tab.zsh`, `lib/widgets/git-widgets.zsh`
   - Interactive input integrations: `lib/integrations/abbr.zsh`, `lib/integrations/atuin.zsh`, `lib/integrations/zoxide.zsh`, `lib/widgets/autosuggestions.zsh`
   - Platform-specific setup: `lib/platform/wsl.zsh`
   - Prompt and final ZLE decorators: `lib/core/prompt.zsh`, `lib/widgets/syntax-highlighting.zsh`

## ディレクトリ構成

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
│   ├── completion/
│   │   ├── completion.zsh
│   │   ├── gh-completion.zsh
│   │   └── ni.zsh
│   ├── core/
│   │   ├── history.zsh
│   │   ├── options.zsh
│   │   ├── path.zsh
│   │   └── prompt.zsh
│   ├── integrations/
│   │   ├── abbr.zsh
│   │   ├── agmsg.zsh
│   │   ├── aicommits.zsh
│   │   ├── atuin.zsh
│   │   ├── codex.zsh
│   │   ├── secrets.zsh
│   │   └── zoxide.zsh
│   ├── platform/
│   │   └── wsl.zsh
│   └── widgets/
│       ├── autosuggestions.zsh
│       ├── fzf-tab.zsh
│       ├── fzf.zsh
│       ├── git-widgets.zsh
│       └── syntax-highlighting.zsh
└── sheldon/
    └── plugins.toml
```

## Sheldon と abbr の運用

現行の Sheldon プラグインは `zsh-abbr`、補完取得用の `ni-completion` / `eza` / `bun`、Git ウィジェット用の `fzf-git`、補完 UI 用の `fzf-tab`、入力候補用の `zsh-autosuggestions`、シンタックスハイライト用の `fast-syntax-highlighting` です。

Sheldon キャッシュが直接 source するのは `zsh-abbr` のみで、その他の補完ファイルやプラグインは `lib/` 側から必要なものを直接読み込みます。Sheldon キャッシュ自体も通常起動では同期ロードせず、実ターミナルでは最初の `precmd` で読み込みます。

キャッシュの再生成と読み込み確認は次のコマンドで行います。

```bash
zsh-sheldon-refresh
zsh-fzf-refresh
zsh-gh-completion-refresh
ZSH_LOAD_PLUGINS=1 zsh -lic 'abbr expand gst'
ZSH_LOAD_FZF=1 ZSH_LOAD_GH=1 zsh -lic 'bindkey "^]"; bindkey "^T"; bindkey "^gx"; whence _gh'
ZSH_LOAD_GIT_WIDGETS=1 zsh -lic 'bindkey "^gg"; bindkey "^gs"; bindkey "^ga"; bindkey "^gb"; bindkey "^gB"; bindkey "^gW"; bindkey "^gz"; bindkey "^g^f"; bindkey "^g?"'
ZSH_LOAD_FZF_TAB=1 ZSH_LOAD_AUTOSUGGESTIONS=1 ZSH_LOAD_SYNTAX_HIGHLIGHTING=1 zsh -lic 'bindkey "^I"; whence _zsh_autosuggest_start; whence fast-theme'
```

`zsh-abbr` のユーザー定義は既定どおり `zsh-abbr/user-abbreviations` を使用します。alias ではなく、入力後にコマンド文字列へ展開される abbreviation として運用します。

## 検証

目標の起動時間 `<100ms` は達成済みです（2026-09-23、Mac16,6、`zsh-benchmark --runs 8 --mode <mode>`、Shell: `/opt/homebrew/bin/zsh`）。

| mode              | avg    | min    | max    |
| ----------------- | ------ | ------ | ------ |
| interactive       | 0.072s | 0.062s | 0.085s |
| interactive-login | 0.071s | 0.059s | 0.079s |

```bash
zsh-benchmark --runs 8 --mode interactive
zsh-benchmark --runs 3 --mode interactive-login
ZSH_PROFILE_STARTUP=1 zsh -ic 'zprof'
bun test --timeout 20000 scripts/zsh-env-loading.test.ts
mise run test:lua
```

## 退避済み構成の確認

履歴上の旧構成を確認するときは次のコマンドを使用します。

```bash
git show 7eac3d54^:zsh/config/loader.zsh
git log -- zsh/config
```

機能を戻す場合は 1 機能ずつ戻し、その都度 `zsh-benchmark` と `zprof` で起動時間への影響を確認してください。
