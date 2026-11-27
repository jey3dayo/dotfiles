---
type: runbook
title: Security Reference
description: dotfiles リポジトリにおける秘密情報の分類、.gitignore 管理、gitleaks 運用、インシデント対応手順
resource: docs/security.md
tags:
  - category/security
  - layer/support
  - environment/cross-platform
  - audience/developer
timestamp: 2026-11-27
audience: developer
owner: dotfiles
---

# Security Reference

この文書は、dotfiles リポジトリにおける秘密情報の分類、流出防止（`.gitignore` / gitleaks）、および万一の漏洩時のインシデント対応手順を定義する正本です。

Claude 向けの短いルールは [`.claude/rules/security.md`](../.claude/rules/security.md) にあります。

## 秘密情報の分類

### レベル 1: 高度に機密性の高い情報（絶対にコミットしない）

- SSH 秘密鍵: `id_rsa`, `id_ed25519`, `*.pem`
- GPG 秘密鍵: `secring.gpg`, `*.key`
- API トークン: GitHub Personal Access Tokens, AWS Credentials
- パスワード: 平文パスワード、データベース認証情報
- 証明書秘密鍵: `*.key`, `*.p12`, `*.pfx`

主な `.gitignore` パターン:

```gitignore
**/.ssh/*_rsa
**/.ssh/*_ed25519
**/.ssh/*.pem
**/.gnupg/private-keys-v1.d/
**/.gnupg/secring.gpg
**/.aws/credentials
**/.config/gh/hosts.yml
```

### レベル 2: 個人固有の情報（公開非推奨）

- 環境変数ファイル: `.env`, `.env.local`, `.envrc`
- 設定ファイルのローカル上書き: `config.local`, `*.secret`
- セッショントークン

```gitignore
.env
.env.*
!.env.example
.envrc
*.local
*.secret
```

### レベル 3: 一時ファイルとビルド成果物

- ビルド成果物: `result`, `result-*`, `dist/`, `build/`
- 一時ファイル: `*.tmp`, `*.log`, `.DS_Store`
- 依存関係キャッシュ: `node_modules/`, `.venv/`, `__pycache__/`

## `.gitignore` メンテナンス

新しいツールや設定を追加する際は、以下の順で確認します。

1. 秘密情報を含む可能性があるファイルは `.gitignore` に追加します。
2. 環境固有の設定は `.gitignore` に追加し、必要に応じて `.example` ファイルを用意します。
3. 一時ファイルやキャッシュも `.gitignore` に追加します。

```bash
# 新ツール newtool の例
echo "**/.config/newtool/credentials" >> .gitignore
echo "**/.config/newtool/*.local" >> .gitignore
cp .config/newtool/config.local .config/newtool/config.local.example
```

## Lefthook と gitleaks の運用

### セットアップ

```bash
mise install           # lefthook と gitleaks をインストール
lefthook install       # Git hook をインストール
sh ./scripts/setup-gitleaks.sh
sh ./scripts/setup-gitleaks.sh --create-baseline  # ベースラインを作成（既存の検出結果を除外）
```

### 日常的な使用

```bash
git commit -m "feat: add new feature"     # pre-commit で自動実行
lefthook run pre-commit                   # ステージ済みファイル向けの hook を手動実行
gitleaks git --config=.gitleaks.toml -v   # 手動スキャン
mise run ci:gitleaks                      # CI と同じシークレットスキャン
```

### 誤検知（False Positive）への対応

ベースラインへ追加する場合:

```bash
sh ./scripts/setup-gitleaks.sh --create-baseline
```

該当行を個別に除外する場合（コメント付与）:

```python
API_KEY = "example_key_for_documentation"  # gitleaks:allow
```

### バイパス（緊急時のみ）

```bash
git commit --no-verify -m "emergency fix"   # 全フックをスキップ（非推奨）
SKIP=gitleaks git commit -m "message"       # gitleaks のみスキップ
```

バイパスを使う前に、「なぜスキップが必要か」「秘密情報流出のリスクはないか」「後で検証・レビューする手段があるか」を必ず確認してください。

## セキュリティ監査チェックリスト

### 月次確認

```bash
mise run ci:gitleaks
git ls-files -o --exclude-standard | grep -E "\.(env|key|pem|credentials)$"
find ~/.ssh -type f -name "id_*" ! -name "*.pub" -exec ls -la {} \;
gpg --list-keys --with-colons | grep "^pub"
gh auth status
aws sts get-caller-identity
```

### コミット前（毎回）

```bash
git diff --cached --name-only
git diff --cached
# 目視確認: パスワード、トークン、API キー、個人情報、内部サーバー情報が含まれていないか
```

### 新規ツール追加時

```bash
ls -la ~/.config/newtool/ | grep -E "(credential|secret|token|key)"
echo "**/.config/newtool/credentials" >> .gitignore
cp ~/.config/newtool/config.secret ~/.config/newtool/config.secret.example
sed -i '' 's/actual_secret/YOUR_SECRET_HERE/g' ~/.config/newtool/config.secret.example
```

## インシデント対応手順

### シナリオ 1: 秘密情報を誤ってコミットした（プッシュ前）

```bash
git reset --soft HEAD~1
rm path/to/secret/file   # または .env / .env.secrets へ移行
echo "path/to/secret/file" >> .gitignore
git add .gitignore
git commit -m "fix: remove secret and update .gitignore"
```

### シナリオ 2: 秘密情報をプッシュしてしまった

#### 緊急対応（10 分以内）

1. 漏洩した秘密情報を即座に無効化します（GitHub Token 削除、AWS Credentials 無効化、SSH 鍵削除など）。
2. プッシュした作業ブランチを削除できる場合は削除します（`git push origin --delete branch-name`）。
3. 共有利用している環境や関係者がいる場合は速やかに通知します。

#### 恒久対応（1 時間以内）

```bash
brew install git-filter-repo
git filter-repo --path path/to/secret/file --invert-paths
git push --force-with-lease origin main
# 別マシンの既存クローンも再クローンします（古いクローンには秘密情報が残ります）
```

#### 事後対応（1 日以内）

- インシデントの記録（何が漏洩したか、いつ発生したか、誰がアクセス可能だったか、どう無効化したか）を残します。
- `.gitignore` に該当パターンを追加します。
- Lefthook のフックや `.gitleaks.toml` の検知ルールを見直します。
- 運用手順や再発防止チェック項目を更新します。

### シナリオ 3: パブリックリポジトリで秘密情報を発見した

#### 即座の対応（5 分以内）

1. 対象となるすべての秘密情報を即座に無効化します。
2. 必要に応じてリポジトリを一時的にプライベートへ変更します（GitHub Settings → Danger Zone）。

#### 緊急対応（30 分以内）

```bash
git filter-repo --path path/to/secret/file --invert-paths
git push --force-with-lease origin main
# GitHub Support に連絡してキャッシュ削除を依頼します
# https://support.github.com/contact
```

#### 事後対応（1 週間以内）

- 全設定ファイルのセキュリティ監査を実施します。
- `.gitignore` の除外パターンを徹底的に見直します。
- Lefthook のフックがすべての利用マシンで有効になっているか確認します。
- GitHub Insights でクローン履歴やアクセス状況を確認し、影響範囲を調査します。

## 参考資料

- `.gitignore` — 除外パターン定義
- `lefthook.yml` — Git hook の設定
- `scripts/setup-gitleaks.sh` — gitleaks セットアップスクリプト
- [GitHub: Removing sensitive data](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)
- [Gitleaks Documentation](https://github.com/gitleaks/gitleaks)
