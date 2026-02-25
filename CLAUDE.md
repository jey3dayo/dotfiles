# Dotfiles Project

## Quality Check (DoD)

タスク完了時に `mise run ci` を実行し、全チェックが通ることを確認する。

- Quick check (format + lint): `mise run ci:quick`
- Full check (format + lint + test + skills): `mise run ci`
- Fix (auto-format): `mise run format`
