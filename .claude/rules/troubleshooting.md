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

### Nix Home Manager でスキルが配布されない

**症状**: `~/.claude/skills/` が空（`.system` のみ）

**原因**: 別の `home-manager switch` が後から実行され、generation が上書きされた。
Home Manager は1プロファイルしか管理しないため、後勝ちになる。

#### 確認手順

```bash
# 現在の generation を確認
home-manager generations | head -3

# generation の home-files に .claude が含まれるか
find /nix/store/<generation-hash>-home-manager-generation/home-files/ -path "*claude*"

# dry-run でリンク生成を確認
home-manager switch --flake ~/.agents --impure --dry-run 2>&1 | grep claude
```

**解決**: 再度 `~/.agents` から switch を実行

```bash
home-manager switch --flake ~/.agents --impure
```

**予防**: 複数の flake から `home-manager switch` を実行しない。
1つの flake に統合するか、実行順序を固定する。
