---
date: 2026-03-13
audience: dev
tags:
  - category/security
  - layer/project
---

# Security Reference

Claude Rules: [.claude/rules/security.md](../.claude/rules/security.md)

## 秘密情報の分類

### レベル1: 高度に機密性の高い情報（絶対にコミットしてはいけない）

- SSH 秘密鍵: `id_rsa`, `id_ed25519`, `*.pem`
- GPG 秘密鍵: `secring.gpg`, `*.key`
- API トークン: GitHub Personal Access Tokens, AWS Credentials
- パスワード: 平文パスワード、データベース認証情報
- 証明書秘密鍵: `*.key`, `*.p12`, `*.pfx`

`.gitignore` パターン:

```gitignore
**/.ssh/*_rsa
**/.ssh/*_ed25519
**/.ssh/*.pem
**/.gnupg/private-keys-v1.d/
**/.gnupg/secring.gpg
**/.aws/credentials
**/.config/gh/hosts.yml
```

### レベル2: 個人固有の情報（公開非推奨）

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

### レベル3: 一時ファイルとビルド成果物

- ビルド成果物: `result`, `result-*`, `dist/`, `build/`
- 一時ファイル: `*.tmp`, `*.log`, `.DS_Store`
- 依存関係キャッシュ: `node_modules/`, `.venv/`, `__pycache__/`

## .gitignore メンテナンス

新しいツールや設定を追加する際の確認フロー:

1. 秘密情報を含む可能性 → `.gitignore` に追加
2. 環境固有の設定 → `.gitignore` に追加、`.example` ファイルを提供
3. 一時ファイル → `.gitignore` に追加

```bash
# 新ツール newtool の例
echo "**/.config/newtool/credentials" >> .gitignore
echo "**/.config/newtool/*.local" >> .gitignore
cp .config/newtool/config.local .config/newtool/config.local.example
```

## Pre-commit Hooks（gitleaks）

### セットアップ

```yaml
# .pre-commit-config.yaml
- repo: https://github.com/gitleaks/gitleaks
  rev: v8.30.0
  hooks:
    - id: gitleaks
```

```bash
mise install           # pre-commit と gitleaks をインストール
sh ./scripts/setup-gitleaks.sh
sh ./scripts/setup-gitleaks.sh --create-baseline  # ベースライン作成（既存の警告を無視）
```

### 日常的な使用

```bash
git commit -m "feat: add new feature"     # 自動実行
pre-commit run gitleaks --all-files       # 手動実行
pre-commit run --all-files                # 全フック実行
```

### False Positive への対応

ベースラインに追加:

```bash
sh ./scripts/setup-gitleaks.sh --create-baseline
```

個別に除外（コメント）:

```python
API_KEY = "example_key_for_documentation"  # gitleaks:allow
```

### バイパス（緊急時のみ）

```bash
git commit --no-verify -m "emergency fix"   # 全フックスキップ（非推奨）
SKIP=gitleaks git commit -m "message"       # gitleaks のみスキップ
```

確認事項: なぜスキップするか？セキュリティリスクはないか？後でレビューする計画は？

## セキュリティ監査チェックリスト

### 月次

```bash
pre-commit run gitleaks --all-files
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
# 目視確認: パスワード、トークン、APIキー、個人情報、内部サーバー情報
```

### 新規ツール追加時

```bash
ls -la ~/.config/newtool/ | grep -E "(credential|secret|token|key)"
echo "**/.config/newtool/credentials" >> .gitignore
cp ~/.config/newtool/config.secret ~/.config/newtool/config.secret.example
sed -i '' 's/actual_secret/YOUR_SECRET_HERE/g' ~/.config/newtool/config.secret.example
```

## インシデント対応手順

### シナリオ1: 秘密情報を誤ってコミット（プッシュ前）

```bash
git reset --soft HEAD~1
rm path/to/secret/file   # または .env へ移行
echo "path/to/secret/file" >> .gitignore
git add .gitignore
git commit -m "fix: remove secret and update .gitignore"
```

### シナリオ2: 秘密情報をプッシュしてしまった

#### 緊急対応（10分以内）

1. 秘密情報を即座に無効化（GitHub Token 削除、AWS Credentials 無効化、SSH Key 削除）
2. プッシュしたブランチを削除（可能な場合）: `git push origin --delete branch-name`
3. チームに通知

#### 恒久対応（1時間以内）

```bash
brew install git-filter-repo
git filter-repo --path path/to/secret/file --invert-paths
git push --force-with-lease origin main  # チーム全員に通知後
# チーム全員に再クローンを依頼（古いクローンには秘密情報が残る）
```

#### 事後対応（1日以内）

- インシデントレポート（何が漏洩/いつ/誰がアクセス可能/どう無効化）
- `.gitignore` にパターン追加
- pre-commit フックの強化
- チームへのセキュリティトレーニング

### シナリオ3: パブリックリポジトリで秘密情報を発見

#### 即座（5分以内）

1. すべての秘密情報を即座に無効化
2. リポジトリを一時的にプライベートに変更（GitHub Settings → Danger Zone）

#### 緊急対応（30分以内）

```bash
git filter-repo --path path/to/secret/file --invert-paths
git push --force-with-lease origin main
# GitHub Support に連絡してキャッシュ削除を依頼
# https://support.github.com/contact
```

#### 事後対応（1週間以内）

- 全設定ファイルのセキュリティ監査
- `.gitignore` 徹底見直し
- pre-commit フック必須化
- GitHub Insights でクローン履歴確認
- アクセスログ確認・影響範囲調査

## 参考資料

- `.gitignore` — 除外パターン定義
- `.pre-commit-config.yaml` — pre-commit フック設定
- `scripts/setup-gitleaks.sh` — gitleaks セットアップスクリプト
- [GitHub: Removing sensitive data](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)
- [Gitleaks Documentation](https://github.com/gitleaks/gitleaks)
