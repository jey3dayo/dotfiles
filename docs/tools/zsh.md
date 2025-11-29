# 🐚 Zsh Configuration & Optimization

**最終更新**: 2025-11-30
**対象**: 開発者・上級者
**タグ**: `category/shell`, `tool/zsh`, `layer/core`, `environment/cross-platform`, `audience/advanced`

1.1s 起動のモジュラー Zsh。Sheldon + zsh-defer でロードを最小化し、FZF/Git ウィジェットと PATH 最適化を組み合わせたコアレイヤーです。性能計測と改善履歴の単一情報源は `docs/performance.md`。

## 構成サマリ

- `ZDOTDIR=$HOME/.config/zsh` に統一し、ログイン/非ログインで同一構成
- `.zshenv` で XDG と最小 PATH、`.zprofile` で mise 優先の完全 PATH を構成
- `init/completion.zsh` で compinit と zcompdump キャッシュを管理し、`init/sheldon.zsh` でプラグインを生成・ロード
- `config/loader.zsh` が core → tools → functions → os の順に統一読み込み
- `zsh-help` / `path-check` / `zsh-quick-check` で状態確認、FZF ウィジェットで ghq/git ワークフローを高速化

## ディレクトリとロード順

### ロードシーケンス

1. **.zshenv**: XDG 変数、`ZDOTDIR`、最低限の PATH（mise shims）と環境変数を定義。
2. **.zprofile**: ロケール/エディタ設定、`mise activate zsh`、PATH を mise > user > language > Android SDK > Homebrew > system の順で再構成。
3. **.zshrc**: ヒストリと zsh オプションを設定後、`init/*.zsh` を実行（補完セットアップと Sheldon キャッシュ生成）、続けて `sources/*.zsh` を読み込み。
4. **config/loader.zsh**: helper 経由で core（aliases/path utils）→ tools（brew/fzf/gh/git/mise/starship 等）→ functions → os-specific を統一ロードし、helper 関数をクリーンアップ。
5. **lazy-sources/\*.zsh**: Arch/WSL/OrbStack/FZF 追加設定などを zsh-defer で遅延読み込み。

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
- 優先順位: mise shims → `$HOME/{bin,.local/bin}` → 言語ツール（cargo/go/pnpm 等）→ Android SDK → Homebrew → system。
- `path-check` で重複や欠落を検査し、`zsh-quick-check` で PATH/ツールの健全性を一括確認。
- 補完キャッシュは `${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump` 配下に生成され、7日以上古いファイルは自動削除。

## プラグイン構成（Sheldon）

| カテゴリ              | プラグイン                                                              | 役割                                              |
| --------------------- | ----------------------------------------------------------------------- | ------------------------------------------------- |
| Core/Deferred         | zsh-defer, oh-my-zsh `functions`/`clipboard`/`sudo`                     | 起動時の遅延読み込みと基本ユーティリティ          |
| Completion/Navigation | zsh-completions, fzf-tab, zoxide                                        | 補完強化とディレクトリ移動高速化                  |
| Search/UX             | fzf, zsh-autosuggestions, fast-syntax-highlighting                      | ファジー検索と入力体験向上                        |
| Git Workflow          | fzf-git.sh                                                              | ブランチ/ワークツリー/ファイル/スタッシュピッカー |
| Tool Completions      | pnpm-shell-completion (+install), ni-completion, eza, bun, 1password/op | ツール固有補完と PATH 追加                        |
| Quality               | command-not-found, zsh-abbr                                             | 補助機能と省略語展開                              |

## キー操作とワークフロー

### ヘルプ/ステータス

```bash
zsh-help             # 総合ヘルプ
zsh-help keybinds    # キーバインド一覧
zsh-help aliases     # 省略語一覧
zsh-help tools       # インストール済みツール確認
path-check           # PATH 重複/欠落診断
zsh-quick-check      # PATH + 主要ツールの健全性チェック
```

### Git / FZF ウィジェット

```bash
^]          # ghq リポジトリ選択
^[          # ブランチ/ワークツリー切替 (fzf)
^g^g        # Git diff
^g^s        # Git status
^g^a        # Git add -p
^g^b / ^gs  # ブランチ/ワークツリー切替 (fzf)
^g^w / ^gw  # Git worktree 管理
^g^K        # プロセス kill (fzf)
```

### FZF 統合

```bash
^R          # ヒストリ検索
^T          # ファイル検索
```

## パフォーマンスと検証

- ベンチマークと改善履歴は `docs/performance.md` を参照（単一情報源）。
- 迅速な確認: `time zsh -lic exit` / `zsh-quick-check` / `path-check`。
- 詳細分析: `zmodload zsh/zprof; zprof | head -20`、必要に応じて `~/.cache/zsh/zcompdump*` を削除して `compinit` を再構築。
- 補完キャッシュやプラグイン生成は zsh 起動時に自動更新されるため、異常時は `exec zsh` で再起動して再生成。

## カスタマイズと拡張

- **PATH/環境**: `.zprofile`（優先順位）、`.zshenv`（最小構成）を編集。XDG 経由で管理。
- **プラグイン**: `sheldon/plugins.toml` に追記（`defer` テンプレート推奨）。
- **ツール別設定**: `config/tools/*.zsh` に追加（git/fzf/mise/starship など既存ファイルを踏襲）。
- **OS 別**: `config/os/macos.zsh` を基準に、`linux.zsh` / `windows.zsh` を追加すると自動検出で読み込み。
- **補完**: `zsh/completions` または `~/.config/zsh/completions` にファイルを置くと `compinit` が検出。
- **遅延スクリプト**: `lazy-sources/*.zsh` に環境依存の設定を追加し、zsh-defer 経由でロード。

## 運用・メンテナンス

- 月次: `sheldon lock --update` でプラグインキャッシュを再生成（CI 相当）。
- トラブルシュート: `rm -f ${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump* && exec zsh` で補完を再生成、`zsh -df` で最小構成起動。
- 定期確認: `zsh-help tools` で依存ツールの存在確認、`path-check` で PATH の健全性をチェック。
