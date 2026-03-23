---
paths: .gitignore, .pre-commit-config.yaml, .gitleaksignore, docs/security.md
source: docs/security.md
---

# Security Rules

Purpose: dotfiles プロジェクトのセキュリティポリシー。
Detailed Reference: [docs/security.md](../../docs/security.md)

## 秘密情報レベル分類

| レベル | 内容                                 | 方針                 |
| ------ | ------------------------------------ | -------------------- |
| 1      | SSH/GPG 鍵、API トークン、パスワード | 絶対にコミットしない |
| 2      | `.env*`, `*.local`, `*.secret`       | `.gitignore` に追加  |
| 3      | ビルド成果物、一時ファイル           | `.gitignore` に追加  |

## コミット禁止パターン

```gitignore
**/.ssh/*_rsa
**/.ssh/*_ed25519
**/.aws/credentials
.env
.env.*
*.local
*.secret
```

## gitleaks（月次監査・手動実行）

```bash
pre-commit run gitleaks --all-files   # 月次スキャン
pre-commit run --all-files            # 全フック実行
```

## インシデント時の即時アクション

1. トークン/キーを即座に無効化（GitHub Token、AWS Credentials、SSH Key）
2. コミット取り消しまたはブランチ削除
3. チームに通知
4. 履歴から完全削除: `git filter-repo --path <file> --invert-paths`

詳細シナリオ（プッシュ前/プッシュ後/パブリック）は [docs/security.md](../../docs/security.md) を参照。
