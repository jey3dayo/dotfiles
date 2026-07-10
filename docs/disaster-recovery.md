# ディザスタリカバリガイド

最終更新: 2026-07-10
対象: dotfiles 管理者
タグ: `category/infra`, `tool/mise`, `layer/system`, `environment/cross-platform`, `audience/developer`

dotfiles 環境（mise bootstrap 配布）の障害発生時の復旧手順を記載しています。
旧 Nix Home Manager ベースの復旧手順は撤去済みです（generation ロールバックは使えません。履歴は git が正本です）。

## 目次

- [シナリオA: 最近の変更をロールバック](#シナリオa-最近の変更をロールバック)
- [シナリオB: 配布ファイルの破損・消失](#シナリオb-配布ファイルの破損消失)
- [シナリオC: シェルが起動しない](#シナリオc-シェルが起動しない)
- [シナリオD: リポジトリ自体の消失](#シナリオd-リポジトリ自体の消失)
- [検証チェックリスト](#検証チェックリスト)

---

## シナリオA: 最近の変更をロールバック

### 適用ケース

- 設定変更後にシェル・ツールの動作が不安定になった

### 手順

```bash
cd ~/.config
git log --oneline -10          # 問題のコミットを特定
git revert <commit>            # 履歴を保ったまま打ち消す
mise dotfiles apply --yes      # 配布を再収束
```

`main` 上では `git reset --hard` や `git restore` での破棄は行わない（ユーザー確認必須）。

## シナリオB: 配布ファイルの破損・消失

### 適用ケース

- `~/.zshenv` などの symlink が消えた・別物を指している
- launchd agent が消えた

### 手順

```bash
mise dotfiles status           # differs / missing を確認
mise dotfiles apply --yes      # 再適用（冪等）
mise bootstrap status          # packages / launchd 含む全体確認
mise bootstrap --yes           # マシン全体を収束
```

競合で拒否された場合のみ `mise dotfiles apply --force`（既存ファイルを上書きするため内容を確認してから）。

## シナリオC: シェルが起動しない

```bash
zsh --no-rcs                   # rc なしで起動
cd ~/.config && git status     # リポジトリの状態確認
mise dotfiles apply --yes      # エントリポイントを再配布
exec zsh
```

mise 自体が壊れている場合:

```bash
curl https://mise.run | sh     # ~/.local/bin/mise に再インストール
~/.local/bin/mise dotfiles apply --yes
```

## シナリオD: リポジトリ自体の消失

```bash
git clone https://github.com/jey3dayo/dotfiles ~/.config
cd ~/.config
brew bundle                    # macOS のみ
mise trust && mise bootstrap --yes
exec zsh
```

secret 類（`.env.local` など）は restic バックアップから復元する:

```bash
mise run backup:snapshots      # スナップショット一覧
mise run backup:restore        # ./restore に最新を復元
```

## 検証チェックリスト

```bash
mise bootstrap status --missing   # 全宣言部が収束しているか（exit 0）
zsh -lic 'echo ok'                # シェル起動
git config user.name              # git 設定（~/.gitconfig_local 経由）
mise doctor                       # mise 全体の健全性
```

macOS はあわせて launchd agents を確認する:

```bash
mise bootstrap macos launchd-agents status
curl -fsS http://127.0.0.1:8787/livez   # headroom proxy
```

## 関連ドキュメント

- `docs/setup.md` - 新規マシンのセットアップ
- `docs/tools/workflows.md` - 定期メンテナンス
- `docs/tools/nix.md` - 残存 Nix ランタイムの掃除（legacy）
