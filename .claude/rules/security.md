---
paths: .gitignore, lefthook.yml, .gitleaks.toml, docs/security.md
source: docs/security.md
---

# Security Rules

Purpose: dotfiles プロジェクトのセキュリティポリシー。
Detailed Reference: [docs/security.md](../../docs/security.md)

## 要約

- レベル1（SSH/GPG 鍵、API トークン、パスワード）は絶対にコミットしない。レベル2・3（`.env*`, `*.local`, `*.secret`, ビルド成果物、一時ファイル）は `.gitignore` に追加する。
- gitleaks は `mise run ci:gitleaks`（月次監査・手動実行）。手動スキャンは `gitleaks git --config=.gitleaks.toml -v`。
- インシデント発生時の手順は [docs/security.md §インシデント対応手順](../../docs/security.md#インシデント対応手順) を参照。
