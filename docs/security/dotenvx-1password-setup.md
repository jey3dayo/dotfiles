# dotenvx + 1Password セットアップガイド

## 概要

dotenvxの秘密鍵 (`.env.keys`) を1Passwordで安全に管理する方法。

## 前提条件

- 1Password CLIがインストール済み (`brew install --cask 1password-cli`)
- 1Password GUIアプリでサインイン済み
- dotenvxがセットアップ済み (`.env` と `.env.keys` が存在)

## セットアップ手順

### 1. 1Password CLIの確認

```bash
# バージョン確認
op --version

# アカウントリスト確認
op account list

# サインイン(必要な場合)
eval $(op signin)
```

### 2. .env.keysを1Passwordに保存

```bash
# ~/.config/.env.keysを1Passwordドキュメントとして作成
op document create ~/.config/.env.keys \
  --title "dotfiles-env-keys" \
  --vault "Private"
```

### 3. 保存の確認

```bash
# ドキュメントが作成されたか確認
op document list --vault "Private" | grep dotfiles-env-keys

# 内容確認
op document get "dotfiles-env-keys" --vault "Private"
```

### 4. ローカルファイルのバックアップと削除(オプション)

```bash
# バックアップ作成
cp ~/.config/.env.keys ~/.config/.env.keys.backup

# 元のファイルを削除(1Passwordから復元する運用にする場合)
# rm ~/.config/.env.keys
```

## 日常運用

### .env.keysの復元

新しいマシンや環境で `.env.keys` を復元する場合:

```bash
# 1Passwordから復元
op document get "dotfiles-env-keys" --vault "Private" > ~/.config/.env.keys

# 権限設定
chmod 600 ~/.config/.env.keys
```

### 環境変数の復号化

```bash
# dotenvxで環境変数を復号化
dotenvx run -- env | grep -E 'GITLAB|OPENAI|NATURE_REMO'

# または特定のコマンドで使用
dotenvx run -- <your-command>
```

## トラブルシューティング

### 1Password CLIが認証エラーを返す

```bash
# 再サインイン
eval $(op signin)

# デバイス認証確認
op whoami
```

### .env.keysが見つからない

```bash
# 1Passwordから復元
op document get "dotfiles-env-keys" --vault "Private" > ~/.config/.env.keys
chmod 600 ~/.config/.env.keys
```

### 復号化エラー

```bash
# DOTENV_PRIVATE_KEYが正しいか確認
cat ~/.config/.env.keys | grep DOTENV_PRIVATE_KEY

# .envのDOTENV_PUBLIC_KEYと対応しているか確認
cat .env | grep DOTENV_PUBLIC_KEY
```

## セキュリティベストプラクティス

1. **秘密鍵の管理**

   - `.env.keys` は絶対にGitにコミットしない
   - `.gitignore` で明示的に除外されていることを確認
   - 1Passwordに保存したら、ローカルファイルは削除を検討

2. **権限設定**

   - `.env.keys` は必ず `chmod 600` (所有者のみ読み書き可能)
   - `.env` は `chmod 644` でOK(暗号化済みのため)

3. **バックアップ**

   - 1Passwordに保存することで自動バックアップ
   - 複数デバイスで同期可能
   - 紛失時も復元可能

4. **定期的なローテーション**
   - 秘密鍵は定期的にローテーション推奨
   - `dotenvx encrypt --key <new-key>` で再暗号化

## 関連ドキュメント

- [dotenvx公式ドキュメント](https://dotenvx.com/encryption)
- [1Password CLI リファレンス](https://developer.1password.com/docs/cli/)
- [mise Rules - dotenvx統合](../../.claude/rules/tools/mise.md)
