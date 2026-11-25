---
type: reference
title: 1Password CLI & Service Accounts
description: 1Password CLI の認証運用、dotenvx の 2 層環境変数管理、service account token の更新手順
resource: docs/tools/1password.md
tags:
  - category/configuration
  - layer/tool
  - tool/1password
  - environment/cross-platform
  - audience/developer
timestamp: 2026-11-25
audience: developer
owner: dotfiles
---

# 1Password CLI & Service Accounts

この文書は、1Password CLI の認証運用と `dotenvx` による環境変数管理の正本です。人間の対話利用では desktop app integration を、Codex などの自動化では service account token を使用します。service account は組み込み vault の `Private` を読めないため、自動化用のアイテムは通常 vault の `Automation` に置きます。

Claude 向けの短いルールは [`.claude/rules/tools/1password.md`](../../.claude/rules/tools/1password.md) にあります。

## 運用方針

- 人間の手動利用: 1Password desktop app integration を使います。
- 自動化利用: `OP_SERVICE_ACCOUNT_TOKEN` を使います。
- 自動化用 vault: `Automation`
- `.env.keys` document: `.env.keys | dotfiles`
- 制約: service account では組み込み vault の `Private` / `Personal` / `Employee` は読めません。

## 環境変数の 2 層管理（`.env` / `.env.secrets`）

`dotenvx` で管理する環境変数は、漏洩時の影響範囲（blast radius）を抑えるため 2 層に分離します。

| 層           | ファイル       | 注入方法                                                                                   | 置くもの                                                                                 |
| ------------ | -------------- | ------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------- |
| 常時注入層   | `.env`         | `setup-env` が `.env.local` へ復号し、`mise` の `env_file` で全シェルへ注入                | 低リスクかつ常用のキーのみ（`NODE_AUTH_TOKEN`, `GOG_ACCOUNT`, `RESTIC_REPOSITORY` など） |
| on-demand 層 | `.env.secrets` | 使用する瞬間のみ `dotenvx run -f .env.secrets -- <cmd>` で注入（平文をディスクに残さない） | 上記以外のすべての secret（API token、パスワード、`OP_SERVICE_ACCOUNT_TOKEN` など）      |

### on-demand 層の使い方

```sh
ws op vault list                                  # zsh helper（zsh/lib/integrations/secrets.zsh）経由
ws aicommits                                      # 任意の CLI に注入して実行
dotenvx run -f ~/.config/.env.secrets -- <cmd>    # helper がない環境での直接実行
```

- 定常的に使うスクリプトは helper に頼らず、「キーが未設定なら `dotenvx run -f .env.secrets` で自身を再実行する」ガードを冒頭に置きます（実例: `bin/check-telegram-api`）。ガード変数と `DOTENV_PRIVATE_KEY_PATH` は `exec` の前に必ず `export` してください（`VAR=1 exec cmd` は bash で exec 先に伝播せず無限再帰になります）。
- 新しい secret は原則 `.env.secrets` に追加します。常時注入層へ入れるのは「全プロセスから見えてよい」と判断できるものに限ります。

```sh
dotenvx set NEW_KEY '<値>' -fk .env.keys -f .env.secrets
```

## 関連ファイル

```text
~/.config/powershell/profile.d/env.ps1        # PowerShell 側の helper
~/.config/zsh/lib/integrations/secrets.zsh    # Zsh 側の `ws` helper（on-demand 注入）
~/.config/scripts/setup-env.sh                # POSIX 向け .env 復号スクリプト
~/.config/scripts/windows/setup-env.ps1       # Windows 向け .env 復号スクリプト
~/.config/.env                                # dotenvx 管理の環境変数（常時注入層）
~/.config/.env.secrets                        # dotenvx 管理の環境変数（on-demand 層）
~/.config/.env.keys                           # dotenvx 復号鍵（両層分）
~/.config/.env.local                          # .env の復号キャッシュ（gitignore 対象）
```

## 既定値

- vault: `Automation`
- item id: `mzy4lhfwqbtbtr3rm466qhrouq`
- item title: `.env.keys | dotfiles`

## Token の更新

`OP_SERVICE_ACCOUNT_TOKEN` は `dotenvx` 管理の `~/.config/.env.secrets` に `encrypted:` 値として保存します。新しい token を発行したら、チャットやシェル履歴に残さないよう以下の手順で上書きします。

### PowerShell

```powershell
. $HOME\.config\powershell\profile.ps1
$env:OP_SERVICE_ACCOUNT_TOKEN = Read-Host "New OP_SERVICE_ACCOUNT_TOKEN"
Save-OpServiceAccountToken
Remove-Item Env:OP_SERVICE_ACCOUNT_TOKEN -ErrorAction SilentlyContinue
```

### Zsh

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

以下の結果が確認できれば正常です。

- `Automation` のみが一覧に表示されること
- `.env.keys | dotfiles` が取得できること
- Windows Hello を使わずに `op` が通ること

## 注意点

- 古い service account または token は、更新確認後に 1Password 側で失効させてください。
- token は長寿命の秘密情報のため、必要最小権限の service account を使用します。
- `Automation` には自動化に必要な item のみを置きます。
- `Private` に置いた item は service account から参照できません。
- macOS の GUI アプリは `~/.config/.env.local` を自動では読み込みません。GUI 起動の Codex などへ secret を渡す場合は、`mise bootstrap` 管理の LaunchAgent（`[bootstrap.macos.launchd.agents]`）で必要なキーだけを `launchctl setenv` します。
