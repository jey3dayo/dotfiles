# 🔐 1Password CLI & Service Accounts

最終更新: 2026-04-09
対象: 開発者
タグ: `category/configuration`, `tool/1password`, `layer/tool`, `environment/cross-platform`, `audience/developer`

1Password CLI の認証運用をまとめる。人間の対話利用は desktop app integration、Codex などの自動化は service account token を使う。service account は built-in の `Private` を読めないため、自動化用のアイテムは通常 vault の `Dotfiles Automation` に置く。

## 🤖 Claude Rules

このドキュメントの凝縮版ルールは現状未作成。必要なら `.claude/rules/tools/1password.md` を追加する。

## 運用方針

- 人間の手動利用: 1Password desktop app integration を使う
- 自動化利用: `OP_SERVICE_ACCOUNT_TOKEN` を使う
- 自動化用 vault: `Dotfiles Automation`
- `.env.keys` document: `.env.keys [dotfiles]`
- service account では built-in の `Private` / `Personal` / `Employee` は読めない

## 関連ファイル

```text
~/.config/powershell/profile.d/env.ps1        # PowerShell 側の token 読み込み
~/.config/zsh/config/tools/1password.zsh      # Zsh 側の token 読み込みと helper
~/.config/op/service-account-token            # Git 管理外の token 保存先
~/.config/.env.keys                           # dotenvx 復号鍵
```

## 既定値

- vault: `Dotfiles Automation`
- item id: `mzy4lhfwqbtbtr3rm466qhrouq`
- item title: `.env.keys [dotfiles]`

## Token の更新

`OP_SERVICE_ACCOUNT_TOKEN` は `dotenvx` 管理の `.env` に入れず、`~/.config/op/service-account-token` に保存する。新しい token を発行したら、古い token をチャットやシェル履歴に貼らず、以下の手順で上書きする。

PowerShell:

```powershell
. $HOME\.config\powershell\profile.ps1
Clear-OpServiceAccountToken
$env:OP_SERVICE_ACCOUNT_TOKEN = Read-Host "New OP_SERVICE_ACCOUNT_TOKEN"
Save-OpServiceAccountToken
Remove-Item Env:OP_SERVICE_ACCOUNT_TOKEN -ErrorAction SilentlyContinue
```

Zsh:

```bash
source ~/.config/zsh/config/tools/1password.zsh
clear-op-service-account-token
read -rs "OP_SERVICE_ACCOUNT_TOKEN?New OP_SERVICE_ACCOUNT_TOKEN: "
echo
save-op-service-account-token
unset OP_SERVICE_ACCOUNT_TOKEN
```

## 更新後の確認

```bash
op vault list
op item list --vault "Dotfiles Automation"
op document get "mzy4lhfwqbtbtr3rm466qhrouq" --vault "Dotfiles Automation"
```

期待結果:

- `Dotfiles Automation` だけが見える
- `.env.keys [dotfiles]` が取得できる
- Windows Hello を使わずに `op` が通る

## 注意点

- 古い service account または token は 1Password 側で失効させる
- token は長寿命の秘密情報なので、必要最小権限の service account を使う
- `Dotfiles Automation` には自動化に必要な item だけを置く
- `Private` に置いた item は service account からは読めない
