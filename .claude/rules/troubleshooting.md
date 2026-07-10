# Troubleshooting: Claude Code Rules

## rules の仕組み

Claude Code は以下の2箇所から rules（markdown ファイル）を自動読み込みする。

### 読み込み順序と優先度

| レベル        | パス                   | スコープ                       | 優先度                     |
| ------------- | ---------------------- | ------------------------------ | -------------------------- |
| User-level    | `~/.claude/rules/*.md` | 全プロジェクト共通（個人設定） | 低（先に読み込み）         |
| Project-level | `.claude/rules/*.md`   | プロジェクト固有               | 高（後に読み込み、上書き） |

- `CLAUDE.md` / `.claude/CLAUDE.md` と同等の扱い
- サブディレクトリも再帰的に探索される（例: `rules/frontend/react.md`）
- シンボリックリンク対応: 共有ルールを symlink で参照可能

### ベストプラクティス

- 1ファイル1トピック（`testing.md`, `api-design.md` 等）
- ファイル名でカバー範囲が分かるようにする
- サブディレクトリでグループ化（`frontend/`, `backend/`）

## よくある問題

### スキルが配布されない

症状: `~/.claude/skills/` が空、または古い

原因: Agent Skills の配布は `~/.apm`（APM）が担当する（旧 Nix/Home Manager 配布は廃止済み）。
APM 側の deploy が未実行か、catalog と配布先がずれている。

#### 確認・解決手順

```bash
cd ~/.apm && mise run deploy && mise run doctor
```

正本は `~/.apm/catalog/skills/**`。配布先（`~/.claude/skills/**`）は直接編集しない。

### dotfiles が配布されない・古い

```bash
mise dotfiles status     # applied / differs / missing を確認
mise dotfiles apply      # 再適用（冪等）
mise bootstrap status    # packages / launchd 含む全体確認
```
