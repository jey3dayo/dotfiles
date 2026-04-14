# 🐚 Zsh Configuration & Optimization

最終更新: 2026-04-09
対象: 開発者・上級者
タグ: `category/shell`, `tool/zsh`, `layer/core`, `environment/cross-platform`, `audience/advanced`

高速起動のモジュラー Zsh。Sheldon + zsh-defer でロードを最小化し、FZF/Git ウィジェットと PATH 最適化を組み合わせたコアレイヤーです。compinit は 24h/変更検知で再構築し、Sheldon キャッシュは plugins.toml 更新時に自動再生成。パフォーマンスの目標値・実測値は `docs/performance.md` を単一情報源とし、本書では構成と運用のみを扱います。

🔗 キーバインド一覧: [FZF Integration > Git Integration](./fzf-integration.md#git-integration) に集約（Zsh/FZF/Git のショートカット検索はここを参照）。

## 🤖 Claude Rules

このドキュメントの凝縮版ルールは [`.claude/rules/tools/zsh.md`](../../.claude/rules/tools/zsh.md) で管理されています。

- 目的: Claude AIが常に参照する簡潔なルール（26-31行）
- 適用範囲: YAML frontmatter `paths:` で定義
- 関係: 本ドキュメントが詳細リファレンス（SST）、Claudeルールが強制版

## 構成サマリ

- `ZDOTDIR=$HOME/.config/zsh` に統一し、ログイン/非ログインで同一構成
- `.zshenv` で XDG/最低限の PATH（mise shims のみ）と環境変数を定義、`.zprofile` で `typeset -U path` による重複除去と完全 PATH を再構成
- `init/completion.zsh` が compinit を 24h/補完更新で再構築し、7日以上の zcompdump を自動削除。`_post_compinit_hooks` で gh/mise などの補完も後追い登録
- `init/sheldon.zsh` は plugins.toml 更新検知でキャッシュ生成し、Sheldon ロード後に mise shims を最優先に再配置
- `config/loader.zsh` が core → tools → functions → os を統一ロード。tools は `fzf/git/mise/starship` を即時、brew/gh/debug 等は zsh-defer で段階遅延（3s/8s/12s/15s）
- `zsh-help` / `path-check` / `zsh-quick-check` / `mise-status` で状態確認、FZF ウィジェットと `wtcd` で ghq/git ワークフローを高速化

## ディレクトリとロード順

### ロードシーケンス

1. .zshenv: XDG 変数と `ZDOTDIR` を固定、GHQ/Android/Java/Brewfile などの環境変数を先に設定。非ログイン用の最小 PATH は mise shims のみ。
2. .zprofile: ロケール/エディタ設定、`typeset -U path cdpath fpath manpath` で重複除去、`mise activate zsh` 後に PATH を mise > user > language > Android SDK > Homebrew > system の順に再構成。
3. .zshrc: ヒストリと zsh オプションを設定後、`init/*.zsh` を実行（compinit + Sheldon キャッシュ生成・mise PATH 再優先）、続いて `sources/*.zsh`（config loader と補完スタイル）を読み込み。
4. config/loader.zsh: helper 経由で core（aliases/path utils）→ tools（即時: fzf/git/mise/starship, 遅延: brew/gh/debug 他）→ functions → os-specific を統一ロードし、helper を消去。
5. lazy-sources/\*.zsh: Arch/WSL/OrbStack/FZF/履歴検索などを zsh-defer 経由で遅延ロード（Sheldon で `dotfiles-lazy-sources` として一括管理）。

### ディレクトリ構造（主要）

```
zsh/
├── .zshenv / .zprofile / .zshrc
├── init/                # completion.zsh, sheldon.zsh
├── sources/             # config-loader.zsh, styles.zsh
├── config/
│   ├── loader.zsh
│   ├── core/            # aliases.zsh, path.zsh
│   ├── tools/           # brew.zsh, fzf(.zsh), gh.zsh, git.zsh, mise.zsh, starship.zsh, debug.zsh
│   ├── loaders/         # core.zsh, tools.zsh, functions.zsh, os.zsh, helper.zsh
│   └── os/              # macos.zsh (+ linux/windows 拡張余地)
├── functions/           # help.zsh, cleanup-zcompdump
├── lazy-sources/        # arch.zsh, fzf.zsh, history-search.zsh, orbstack.zsh, wsl.zsh
├── completions/         # プロジェクト同梱の補完
└── sheldon/plugins.toml # プラグイン定義（zsh-defer テンプレート）
```

## PATH と環境管理

- PATH の単一情報源は `.zprofile`。非ログインシェル向けの最小 PATH は `.zshenv` に限定。
- 優先順位: mise shims → `$HOME/{bin,.local/bin}` → 言語ツール（deno/cargo/go/pnpm 等）→ Android SDK → Homebrew → system。`typeset -U path` で重複を抑止。
- `path-check` で重複や欠落を検査し（mise shims は除外）、`zsh-quick-check` で PATH/主要ツール/メモリ使用をまとめて確認。
- 補完キャッシュは `${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump` 配下に生成され、24h/補完更新で再構築。7日以上古い zcompdump は自動削除し、手動では `cleanup_zcompdump` 関数でクリーンアップ。
- 1Password CLI の service account 運用は [docs/tools/1password.md](1password.md) を参照。`OP_DOTENV_KEYS_VAULT` と `OP_SERVICE_ACCOUNT_TOKEN` の扱い、token ローテーション手順もそこに集約する。

## プラグイン構成（Sheldon）

| カテゴリ              | プラグイン                                                                      | 役割                                                   |
| --------------------- | ------------------------------------------------------------------------------- | ------------------------------------------------------ |
| Bootstrap/Core        | zsh-defer, oh-my-zsh `functions`/`clipboard`/`sudo`, zsh-abbr                   | 遅延基盤と基本ユーティリティ、abbr 展開                |
| Completion/Navigation | zsh-completions (fpath 追加), fzf-tab, zoxide                                   | 補完強化とディレクトリ移動高速化（`alias j=z` + init） |
| Search/UX             | fzf, zsh-autosuggestions, fast-syntax-highlighting                              | ファジー検索・入力体験向上（highlight は最後にロード） |
| Git Workflow          | fzf-git.sh                                                                      | ブランチ/ワークツリー/ファイル/スタッシュピッカー      |
| Tool Completions      | pnpm-shell-completion (+install), ni-completion, eza, bun, 1password/op         | ツール固有補完と PATH 追加                             |
| Quality/Ops           | command-not-found, dotfiles-lazy-sources (arch/wsl/orbstack/fzf/history-search) | 補助機能と OS/FZF 拡張の遅延読込                       |

## キー操作とワークフロー

FZF/Git キーバインドとワークフローの詳細は重複を避けるため `docs/tools/fzf-integration.md` に集約し、ここでは確認系のコマンドのみ掲載します。

### ヘルプ/ステータス

```bash
zsh-help             # 総合ヘルプ
zsh-help keybinds    # キーバインド一覧
zsh-help aliases     # 省略語一覧
zsh-help tools       # インストール済みツール確認
path-check           # PATH 重複/欠落診断
zsh-quick-check      # PATH + 主要ツールの健全性チェック
mise-status          # mise のデータ/キャッシュ/アクティブツール確認
cleanup_zcompdump    # zcompdump 手動クリーンアップ（確認付き）
```

### Git / FZF ウィジェット

- Git/FZF キーバインド一覧は `docs/tools/fzf-integration.md` を参照（単一情報源）
- `wtcd <branch>`: 指定ブランチの worktree に即座に cd（補完付き）

## パフォーマンスと検証

- ベンチマークと改善履歴は `docs/performance.md` を参照（単一情報源）。
- 迅速な確認: `time zsh -lic exit` / `zsh-quick-check` / `path-check` / `mise-status`。
- 詳細分析: `export ZSH_DEBUG=1; zsh -i` → `zprof | head -20`、必要に応じて `${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump*` を削除して `compinit` を再構築。
- 補完キャッシュやプラグイン生成は zsh 起動時に自動更新（plugins.toml 更新検知で再生成）されるため、異常時は `exec zsh` で再起動して再生成。

## カスタマイズと拡張

- PATH/環境: `.zprofile`（優先順位）、`.zshenv`（最小構成）を編集。XDG 経由で管理。
- プラグイン: `sheldon/plugins.toml` に追記（`defer` テンプレート推奨）。
- ツール別設定: `config/tools/*.zsh` に追加（git/fzf/mise/starship など既存ファイルを踏襲）。
- OS 別: `config/os/macos.zsh` を基準に、`linux.zsh` / `windows.zsh` を追加すると自動検出で読み込み。
- 補完: `zsh/completions` または `~/.config/zsh/completions` にファイルを置くと `compinit` が検出。
- 遅延スクリプト: `lazy-sources/*.zsh` に環境依存の設定を追加し、zsh-defer 経由でロード。

## 運用・メンテナンス

- 月次: `sheldon lock --update` でプラグインキャッシュを再生成（CI 相当）。
- トラブルシュート: `rm -f ${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump* && exec zsh` で補完を再生成、`zsh -df` で最小構成起動。
- 定期確認: `zsh-help tools` で依存ツールの存在確認、`path-check` で PATH の健全性をチェック。
