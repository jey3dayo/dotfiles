# Home Manager 設計リファレンス

最終更新: 2026-03-23
対象: Nix dotfiles 管理者
タグ: `category/infra`, `tool/home-manager`, `layer/system`, `environment/macos`

Home Manager 統合の設計・実装・トラブルシューティングの詳細リファレンスです。

🔗 Claude Rules: [`.claude/rules/home-manager.md`](../../.claude/rules/home-manager.md)（コンパクト版）

---

## 用語集

| 用語              | 説明                                                                                                                               |
| ----------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| Worktree          | Git リポジトリの作業ディレクトリ。Home Manager は設定を Nix ストアにコピーするため、Git submodule の初期化には元の worktree が必要 |
| Activation Script | Home Manager 切り替え時に実行されるスクリプト。`home.activation.*` で定義し、`entryAfter`/`entryBefore` で DAG を構成              |
| DAG               | Directed Acyclic Graph。Activation script の依存関係管理。実行順序を明示的に指定                                                   |
| SSoT              | Single Source of Truth。Home Manager 配布は `dotfiles-module.nix` と `dotfiles-files.nix` が SSoT                                  |
| cleanedRepo       | `gitignore.nix` で `.gitignore` パターンを適用したリポジトリパス。機密・動的ファイルを自動除外                                     |

---

## 管理方針の背景

### 方針: 静的ファイルのみ管理

原則: 書き込みが必要なディレクトリは Home Manager 管理から除外する

理由: ディレクトリ全体を Nix ストアへシンボリックリンクすると、リンク先が read-only のため、実行時に生成されるファイル（バックアップ、ログ、状態ファイル等）への書き込みができなくなる。

### 管理対象の判定フロー

```
[Q1] 実行時にファイルを生成・更新するか?
├─ Yes → [Q2] 生成ファイルは .gitignore で除外されているか?
│          ├─ Yes → [Action A] 静的ファイルのみ個別管理
│          └─ No  → [Action B] ディレクトリ全体を除外
└─ No  → [Action C] ディレクトリ全体を管理

[Action A] nix/dotfiles-files.nix の xdg.files に個別追加
           activation script で動的コンテンツをコピー (mise/tmux パターン)
[Action B] .gitignore にパターン追加。静的ファイルが必要なら [Action A] を併用
[Action C] nix/dotfiles-files.nix の xdg.dirs に追加
```

### 含める（静的な設定ファイル）

- 人が編集する設定ファイル: `alacritty/`, `wezterm/`, `nvim/`, `btop/`, `htop/`

### 除外（書き込みが必要）

| ディレクトリ | 除外理由                                   |
| ------------ | ------------------------------------------ |
| `gh/`        | `hosts.yml` への書き込み（OAuth 認証情報） |
| `karabiner/` | `automatic_backups/` への書き込み          |
| `zed/`       | `cache/`, `logs/` への書き込み             |
| `mise/`      | `trusted-configs/` への書き込み            |

実装: `nix/dotfiles-files.nix`

---

## Flake Inputs 方針

`flake.nix` の inputs は Home Manager 実行に必要な最小構成だけを持ちます。

- `nixpkgs`
- `home-manager`
- `flake-utils`
- `gitignore`

agent skills / agents / commands / rules の配布は Nix から外し、`~/.apm` workspace 側の APM 運用に委譲します。`.config` 側の責務は dotfiles 配布と Home Manager generation 管理です。

---

## Worktree 検出アルゴリズム

### 検出優先度

```
[1] repoWorktreePath（明示指定）
        ↓ 見つからない
[2] $DOTFILES_WORKTREE（環境変数）
        ↓ 見つからない
[3] repoPath（Nix ストアでない場合）
        ↓ 見つからない
[4] repoWorktreeCandidates（カスタムリスト）
        ↓ 見つからない
[5] デフォルト候補（~/.config, ~/src/*/dotfiles, ~/dotfiles）
```

各候補で `is_dotfiles_repo()` 検証: Git リポジトリ root に `flake.nix` / `home.nix` / `nix/dotfiles-module.nix` が存在するか確認。

実装: `nix/dotfiles-module.nix` L34-74 (`detectWorktreeScript`)

### 環境変数による一時的な上書き

```bash
DOTFILES_WORKTREE=/tmp/dotfiles-test home-manager switch --flake . --impure
```

---

## Agent Skills

managed asset は `~/.apm/catalog/**` で管理します。  
Home Manager は dotfiles 配布と generation 管理を担い、agent skills の日常運用は `~/.apm` で行います。

- managed catalog layout:
  - `~/.apm/catalog/.apm/skills/`
  - `~/.apm/catalog/AGENTS.md`
  - `~/.apm/catalog/agents/`
  - `~/.apm/catalog/commands/`
  - `~/.apm/catalog/rules/`
- daily operation:
  - `cd ~/.apm && mise run apply`
  - `cd ~/.apm && mise run doctor`
  - `cd ~/.apm && mise run validate-catalog`

---

## 検証レイヤー

### Nix 側

- `nix flake check`
- `nix build .#default`
- `mise run hm:check`

これらは flake と Home Manager build の構成チェックです。

### APM 側

- `cd ~/.apm && mise run validate`
- `cd ~/.apm && mise run validate-catalog`
- `cd ~/.apm && mise run doctor`

managed catalog と global skill 配布の整合性確認は APM workspace 側で行います。

---

## トラブルシューティング

### Agent Skills が配布されない

Home Manager は agent skills を配布しません。`~/.apm` workspace 側で確認します。

```bash
cd ~/.apm
mise run doctor
mise run apply
```

`.config` から `~/.apm` checkout を用意し直す場合は `mise run apm:bootstrap` を使います。

### "expected a set but got a thunk" エラー

原因: `flake.nix` の inputs で動的評価を使用

```bash
grep -A 10 "inputs\s*=" flake.nix
```

対策: inputs を静的リテラル定義に変更（`let-in` を削除）

### 書き込みエラー（Permission denied / Read-only file system）

原因: ディレクトリ全体が Nix ストアへリンクされている

1. 該当ディレクトリを `xdgConfigDirs` から削除
2. `home-manager switch` を実行
3. 実体ディレクトリとして復元

---

## 参考

- [Home Manager 公式ドキュメント](https://nix-community.github.io/home-manager/)
- [gitignore.nix](https://github.com/hercules-ci/gitignore.nix)
- [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/)
- `docs/disaster-recovery.md` - 破損時の復旧手順
