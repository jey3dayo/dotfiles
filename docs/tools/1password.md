# 🔐 1Password CLI & Service Accounts

最終更新: 2026-04-09
対象: 開発者
タグ: `category/configuration`, `tool/1password`, `layer/tool`, `environment/cross-platform`, `audience/developer`

1Password CLI の認証運用をまとめる。人間の対話利用は desktop app integration、Codex などの自動化は service account token を使う。service account は built-in の `Private` を読めないため、自動化用のアイテムは通常 vault の `Automation` に置く。

## 🤖 Claude Rules

このドキュメントの凝縮版ルールは [`.claude/rules/tools/1password.md`](../../.claude/rules/tools/1password.md) で管理されています。

- 目的: Claude AI が 1Password CLI の認証モードと token 取り扱いを誤らないようにする
- 適用範囲: `docs/tools/1password.md`, `zsh/lib/secrets.zsh`, `powershell/profile.d/env.ps1`, `scripts/setup-env.{ps1,sh}`
- 関係: 本ドキュメントが詳細リファレンス（SST）、Claude ルールが凝縮版

## 運用方針

- 人間の手動利用: 1Password desktop app integration を使う
- 自動化利用: `OP_SERVICE_ACCOUNT_TOKEN` を使う
- 自動化用 vault: `Automation`
- `.env.keys` document: `.env.keys | dotfiles`
- service account では built-in の `Private` / `Personal` / `Employee` は読めない

## 環境変数の2層管理（.env / .env.secrets）

dotenvx 管理の環境変数は、漏洩時の影響範囲（blast radius）を絞るため2層に分ける。

| 層           | ファイル       | 注入方法                                                                             | 置くもの                                                                                                 |
| ------------ | -------------- | ------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------- |
| 常時注入層   | `.env`         | `setup-env` が `.env.local` へ復号 → mise `env_file` で全シェルに注入                | 低リスクかつ常用のキーのみ（`JINA_API_KEY`, `NODE_AUTH_TOKEN`, `GOG_ACCOUNT`, `RESTIC_REPOSITORY` など） |
| on-demand 層 | `.env.secrets` | 使う瞬間だけ `dotenvx run -f .env.secrets -- <cmd>` で注入。平文をディスクに残さない | 上記以外のすべての secret（API token, パスワード, `OP_SERVICE_ACCOUNT_TOKEN` など）                      |

on-demand 層の使い方:

```sh
ws op vault list          # zsh helper（zsh/lib/secrets.zsh）経由
ws oco                    # 任意の CLI に注入して実行
dotenvx run -f ~/.config/.env.secrets -- <cmd>   # helper が無い環境での直接形
```

定常的に使うスクリプトは helper に頼らず、「キーが未設定なら `dotenvx run -f .env.secrets` で自身を再実行する」ガードを冒頭に置く（実例: `bin/check-telegram-api`）。ガード変数と `DOTENV_PRIVATE_KEY_PATH` は `exec` の前に必ず `export` する（`VAR=1 exec cmd` は bash で exec 先に伝播せず無限再帰する）。

新しい secret は原則 `.env.secrets` に追加し、常時注入層へ入れるのは「全プロセスから見えてよい」と判断できるものに限る:

```sh
dotenvx set NEW_KEY '<値>' -fk .env.keys -f .env.secrets
```

## 関連ファイル

```text
~/.config/powershell/profile.d/env.ps1        # PowerShell 側の helper
~/.config/zsh/lib/secrets.zsh                 # Zsh 側の `ws` helper（on-demand 注入）
~/.config/.env                                # dotenvx-managed env（常時注入層）
~/.config/.env.secrets                        # dotenvx-managed env（on-demand 層）
~/.config/.env.keys                           # dotenvx 復号鍵（両層分）
~/.config/.env.local                          # .env の復号キャッシュ（gitignore 対象）
```

## 既定値

- vault: `Automation`
- item id: `mzy4lhfwqbtbtr3rm466qhrouq`
- item title: `.env.keys | dotfiles`

## Token の更新

`OP_SERVICE_ACCOUNT_TOKEN` は `dotenvx` 管理の `~/.config/.env.secrets` に
`encrypted:` 値として保存する。新しい token を発行したら、古い token
をチャットやシェル履歴に貼らず、以下の手順で上書きする。

PowerShell:

```powershell
. $HOME\.config\powershell\profile.ps1
$env:OP_SERVICE_ACCOUNT_TOKEN = Read-Host "New OP_SERVICE_ACCOUNT_TOKEN"
Save-OpServiceAccountToken
Remove-Item Env:OP_SERVICE_ACCOUNT_TOKEN -ErrorAction SilentlyContinue
```

Zsh:

```bash
read -rs "OP_SERVICE_ACCOUNT_TOKEN?New OP_SERVICE_ACCOUNT_TOKEN: "
echo
dotenvx set OP_SERVICE_ACCOUNT_TOKEN "$OP_SERVICE_ACCOUNT_TOKEN" \
  -fk ~/.config/.env.keys -f ~/.config/.env.secrets
unset OP_SERVICE_ACCOUNT_TOKEN
```

## 更新後の確認

```bash
dotenvx run -f ~/.config/.env.secrets -- op vault list
dotenvx run -f ~/.config/.env.secrets -- op item list --vault "Automation"
dotenvx run -f ~/.config/.env.secrets -- op document get "mzy4lhfwqbtbtr3rm466qhrouq" --vault "Automation"
```

期待結果:

- `Automation` だけが見える
- `.env.keys | dotfiles` が取得できる
- Windows Hello を使わずに `op` が通る

## 注意点

- 古い service account または token は 1Password 側で失効させる
- token は長寿命の秘密情報なので、必要最小権限の service account を使う
- `Automation` には自動化に必要な item だけを置く
- `Private` に置いた item は service account からは読めない
- macOS GUI アプリは `~/.config/.env.local` を自動では読まない。GUI 起動の Codex などへ secret を渡す場合は、mise bootstrap 管理の LaunchAgent（`[bootstrap.macos.launchd.agents]`）で必要な key だけを `launchctl setenv` する
