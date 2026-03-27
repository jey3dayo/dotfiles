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
| SSoT              | Single Source of Truth。`agent-skills-sources.nix`（スキルメタデータ）と `dotfiles-module.nix`（worktree 検出）が SSoT             |
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

## Flake Inputs と Agent Skills 管理

### Nix Flake の inputs 制約

重要: Nix flake の `inputs` セクションは静的な attrset（リテラル定義）である必要がある。

```nix
# ❌ 動的評価（エラー: "expected a set but got a thunk"）
inputs = let
  sources = import ./nix/agent-skills-sources.nix;
  dynamicInputs = builtins.mapAttrs (_: src: { inherit (src) url flake; }) sources;
in { ... } // dynamicInputs;
```

### Agent Skills の分割管理設計

SSoT と フラットな inputs を併用する妥協的設計:

| ファイル                       | 役割               | 管理項目                                     |
| ------------------------------ | ------------------ | -------------------------------------------- |
| `nix/agent-skills-sources.nix` | SSoT（メタデータ） | url, flake, baseDir, selection.enable        |
| `flake.nix` inputs             | Flake inputs 定義  | url, flake のみ（手動同期が必要）            |
| `nix/sources.nix`              | 統合処理           | inputs と baseDir を結合してスキルパスを生成 |
| `nix/agent-skills.nix`         | スキル選択         | selection.enable を抽出                      |

#### トレードオフ

- ✅ Flake 仕様に準拠
- ✅ メタデータは SSoT で集約管理
- ❌ URL/flake 属性が重複（制約上の妥協）

### 新しいスキルソースを追加するチェックリスト

1. `agent-skills-sources.nix` を更新

   ```nix
   new-skill-source = {
     url = "github:org/repo";
     flake = false;
     baseDir = "skills";
     selection.enable = [ "skill-name" ];
   };
   ```

2. `flake.nix` の inputs に追加（手動同期）

   ```nix
   new-skill-source = {
     url = "github:org/repo";  # agent-skills-sources.nix と一致させる
     flake = false;
   };
   ```

3. 検証

   ```bash
   nix flake show
   nix flake metadata | grep new-skill-source
   home-manager build --flake ~/.config --impure --dry-run
   ```

4. スキル配布の確認

   ```bash
   home-manager switch --flake ~/.config --impure
   ls -la ~/.claude/skills/ | grep <skill-name>
   ```

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

## Agent Skills 配布アーキテクチャ

### 4段階統合フロー

1. Sources 統合: `discoverCatalog` (lib.nix L244-)
   - Distribution: `agents/src/`（主要ソース、内部スキルが優先）
   - External: Flake inputs 経由バンドル
   - 優先度: Distribution > External

2. Skills 選択: `selectSkills` (lib.nix L306-)
   - `selection.enable` で選択されたスキルのみ
   - Distribution skills は常に含まれる

3. Bundle 生成: `mkBundle` (lib.nix L320-)
   - 選択されたスキルのみ Nix store にコピー
   - rsync -aL による完全コピー（symlink を実体化）

4. 配布: Home Manager (module.nix L277-)
   - Per-skill symlink で `~/.claude/skills/` へ配布

### 外部ソース障害時の挙動

| シナリオ                       | 挙動          | 理由                                             |
| ------------------------------ | ------------- | ------------------------------------------------ |
| `nix build`（キャッシュあり）  | 成功          | `flake.lock` + `/nix/store` キャッシュで動作     |
| `nix flake update`（到達不能） | 失敗          | 新しいリビジョンのフェッチが必要                 |
| `nix build`（GC 後、到達不能） | 失敗          | キャッシュが消えており再フェッチが必要           |
| flake input 欠落               | 警告+スキップ | `builtins.hasAttr` ガードで graceful degradation |

---

## 検証レイヤー

### `nix run .#validate`（`mkValidateScript`）

実装: `agents/nix/lib.nix` L440-

| 検証項目                                 | 説明                                                   |
| ---------------------------------------- | ------------------------------------------------------ |
| 選択スキルのバンドル存在確認             | `selectedSkills` の各スキルが `bundle/` 内に存在するか |
| 選択スキルの SKILL.md 存在確認           | 各スキルに `SKILL.md` があるか                         |
| バンドル内全ディレクトリの SKILL.md 確認 | 選択外含む全ディレクトリを確認                         |
| カタログ/選択スキル数の表示              | カタログ総数・選択数・未選択数                         |

### `nix flake check`（`mkChecks`）

実装: `agents/nix/lib.nix` L499-

| 検証項目                  | 説明                                                           |
| ------------------------- | -------------------------------------------------------------- |
| `.bundle-info` の存在確認 | メタデータファイルが生成されているか                           |
| スキル数の一致確認        | `.bundle-info` の `count` と `selectedSkills` の数が一致するか |

### `validate-internal.sh`

実装: `agents/scripts/validate-internal.sh`

| 検証項目                      | 説明                                                    |
| ----------------------------- | ------------------------------------------------------- |
| skills ディレクトリの存在確認 | `agents/src/skills/` が存在するか                       |
| symlink 禁止                  | skills ディレクトリ内に symlink がないか                |
| SKILL.md 存在確認             | 各スキルに `SKILL.md` または `skills/SKILL.md` があるか |

---

## トラブルシューティング

### Agent Skills が配布されない

症状: `~/.claude/skills/` が空または一部のスキルのみ存在

```bash
# Home Manager generation の確認
home-manager generations | head -3

# flake inputs の認識確認
nix flake metadata ~/.config | grep -E "(openai-skills|vercel)"
```

原因1: 別の flake から `home-manager switch` を実行した → `~/.config` から再度 switch

```bash
home-manager switch --flake ~/.config --impure
```

原因2: `flake.nix` と `agent-skills-sources.nix` の URL 不整合

```bash
grep 'url = ' nix/agent-skills-sources.nix
grep 'url = "github:.*skills' flake.nix
```

原因3: `selection.enable` のスキル名タイポ → `mise run skills:report` で確認

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
