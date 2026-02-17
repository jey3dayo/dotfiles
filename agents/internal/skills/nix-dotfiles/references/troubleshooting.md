# Troubleshooting

詳細な診断手順と解決策。

## Table of Contents

1. [Agent Skills が配布されない](#agent-skills-が配布されない)
2. [Flake inputs エラー](#flake-inputs-エラー)
3. [Worktree 検出失敗](#worktree-検出失敗)
4. [.gitignore フィルタリング問題](#gitignore-フィルタリング問題)
5. [書き込みエラー](#書き込みエラー)

---

## Agent Skills が配布されない

### 症状

### 原因

Home Manager は1プロファイルしか管理しないため、後勝ちになります。

### 確認手順

```bash
# 1. 現在の generation を確認
home-manager generations | head -3

# 2. generation の home-files に .claude が含まれるか
find /nix/store/<generation-hash>-home-manager-generation/home-files/ -path "*claude*"

# 3. dry-run でリンク生成を確認
home-manager switch --flake ~/.config --impure --dry-run 2>&1 | grep claude
```

### generation-hash の取得

```bash
# 最新 generation のパスを取得
home-manager generations | head -1 | awk '{print $NF}'

# 具体的な確認例
latest_gen=$(home-manager generations | head -1 | awk '{print $NF}')
find "$latest_gen/home-files/" -path "*claude*"
```

### 解決策

### 対策1: 正しい flake から switch を実行

```bash
home-manager switch --flake ~/.config --impure
```

### 対策2: 統合診断スクリプトで確認

```bash
~/.config/agents/skills-internal/nix-dotfiles/scripts/diagnose.sh
```

スクリプトは以下をチェックします:

- Generation の存在と `.claude` 含有
- Symlink の整合性
- Flake inputs の一貫性
- Worktree 検出

### 予防策

複数の flake から `home-manager switch` を実行しないようにします。

### オプション1: 1つの flake に統合

- 推奨: すべての Home Manager 設定を `~/.config` flake に集約

### オプション2: 実行順序を固定

- `~/.config` flake を最後に実行
- 他の flake は `~/.config` flake に import で統合

### 実装例

```nix
# ~/.config/flake.nix
{
  inputs = {
    other-config.url = "path:/path/to/other/flake";
  };

  outputs = { self, nixpkgs, home-manager, other-config, ... }: {
    homeConfigurations."user" = home-manager.lib.homeManagerConfiguration {
      modules = [
        ./home.nix
        other-config.homeModules.default
      ];
    };
  };
}
```

---

## Flake inputs エラー

### 症状

Nix flake コマンド（`show`, `metadata`, `check`）が失敗します。

### 原因

`flake.nix` の `inputs` セクションで動的評価（let-in + import）を使用しているためです。

Flake 評価時に inputs は完全に静的である必要があり、実行時評価（thunk）は許可されません。

### 禁止パターン

```nix
# ❌ 動的評価（let-in + import）
inputs = let
  sources = import ./nix/agent-skills-sources.nix;
  dynamicInputs = builtins.mapAttrs (_: src: {
    inherit (src) url flake;
  }) sources;
in {
  nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
} // dynamicInputs;
```

### 正しいパターン

```nix
# ✅ 静的リテラル定義
inputs = {
  nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  openai-skills = {
    url = "github:openai/agent-skills";
    flake = false;
  };
  # 静的リテラル定義のみ
};
```

### 確認手順

```bash
# 1. inputs セクションを確認
rg "inputs\s*=" ~/.config/flake.nix -A 10

# 2. let-in や import の使用を確認
rg "(let|import).*agent-skills" ~/.config/flake.nix

# 3. Flake 評価のテスト
nix flake show ~/.config
```

### SSoT 管理の設計

Flake の静的制約を満たしつつ、SSoT（Single Source of Truth）を維持します。

| ファイル                       | 役割               | 管理項目                              |
| ------------------------------ | ------------------ | ------------------------------------- |
| `nix/agent-skills-sources.nix` | SSoT（メタデータ） | url, flake, baseDir, selection.enable |
| `flake.nix` inputs             | Flake inputs定義   | url, flake のみ（**手動同期が必要**） |
| `nix/sources.nix`              | 統合処理           | inputs と baseDir を結合              |
| `nix/agent-skills.nix`         | スキル選択         | selection.enable を抽出               |

### トレードオフ

- ✅ Flake 仕様に準拠
- ✅ メタデータは SSoT で集約管理
- ❌ URL/flake 属性が重複（制約上の妥協）

### 実装例

```nix
# nix/agent-skills-sources.nix (SSoT)
{
  openai-skills = {
    url = "github:openai/skills";
    flake = false;
    baseDir = "skills";
    selection.enable = [ "gh-fix-ci" "skill-creator" ];
  };
  vercel-skills = {
    url = "github:vercel/next.js/tree/canary/examples";
    flake = false;
    baseDir = ".";
    selection.enable = [ "app-router" "api-routes" ];
  };
}
```

```nix
# flake.nix (手動同期が必要)
{
  inputs = {
    # NOTE: agent-skills-sources.nix と手動同期
    #       Flake spec requires literal inputs
    openai-skills = {
      url = "github:openai/skills";
      flake = false;
    };
    vercel-skills = {
      url = "github:vercel/next.js/tree/canary/examples";
      flake = false;
    };
  };
}
```

```nix
# nix/sources.nix (統合)
let
  agentSkills = import ./agent-skills-sources.nix;
  inputs = /* flake inputs from flake.nix */;
in {
  openai-skills = "${inputs.openai-skills}/${agentSkills.openai-skills.baseDir}";
  vercel-skills = "${inputs.vercel-skills}/${agentSkills.vercel-skills.baseDir}";
}
```

### 解決手順

1. **inputs を静的リテラル定義に変更**（`let-in` を削除）

2. agent-skills-sources.nix と flake.nix の URL/flake を同期

   ```bash
   # agent-skills-sources.nix の URL 一覧
   rg 'url = ' ~/.config/nix/agent-skills-sources.nix

   # flake.nix の inputs URL 一覧
   rg 'url = "github:.*skills' ~/.config/flake.nix

   # 差分があれば手動で同期
   ```

3. 検証

   ```bash
   nix flake show ~/.config
   nix flake metadata ~/.config
   home-manager build --flake ~/.config --impure --dry-run
   ```

### 参考コミット

- `2f1e3e34`: Agent Skills の初回統合（migrate agent skills into dotfiles）
- `139dd809`: dotfiles との統合修正（fix: integrate agent skills with dotfiles）
- `56543bda`: catalog 定義の統合（integrate catalog definitions into agent-skills-sources.nix）

### Note

---

## Worktree 検出失敗

### 症状

```
Error: Dotfiles repository not found
```

Activation script（`dotfiles-submodules`, `dotfiles-tmux-plugins`）が Git 操作を行う際に、元の Git リポジトリ（worktree）が必要です。

### 原因

Home Manager は設定ファイルを Nix ストアにコピーするため、Nix ストア内には `.git` ディレクトリが存在しません。

Git submodule の初期化や tmux plugins のコピーには、元の worktree が必要です。

### 検出優先度

Worktree は以下の順序で検出されます:

```
[1] repoWorktreePath (明示指定)
        ↓ 見つからない
[2] $DOTFILES_WORKTREE (環境変数)
        ↓ 見つからない
[3] repoPath (Nixストアでない場合)
        ↓ 見つからない
[4] repoWorktreeCandidates (カスタムリスト)
        ↓ 見つからない
[5] デフォルト候補 (~/.config, ~/src/*/dotfiles, ~/dotfiles)
```

各候補で `is_dotfiles_repo()` 検証を実施:

- Git リポジトリ root に `flake.nix` / `home.nix` / `nix/dotfiles-module.nix` が存在

### 実装

### 解決策

#### 一時的な上書き（環境変数）

```bash
DOTFILES_WORKTREE=/path/to/dotfiles home-manager switch --flake ~/.config --impure
```

### 使用例

- 一時的なテスト: `/tmp/dotfiles-test`
- カスタムパス: `/mnt/backup/dotfiles`
- CI 環境: `$GITHUB_WORKSPACE`

#### 恒久的な設定（Nix 設定）

```nix
# nix/dotfiles-module.nix または home.nix
programs.dotfiles = {
  enable = true;
  repoPath = ./.;
  repoWorktreeCandidates = [
    "/custom/path/to/dotfiles"
    "${config.home.homeDirectory}/my-dotfiles"
  ];
};
```

### 設定後の確認

```bash
home-manager build --flake ~/.config --impure --dry-run
```

### SSoT パターン

Worktree detection logic は `nix/dotfiles-module.nix` の `detectWorktreeScript` で一元定義され、以下の activation script で再利用されます:

- `dotfiles-tmux-plugins`: tmux plugins のコピー（submodule が必要）
- `dotfiles-submodules`: Git submodule の初期化

### 利点

1. 保守性: 検出ロジックの変更が1箇所で済む
2. 一貫性: 両方の activation script で同じロジックを使用
3. テスト容易性: 検出ロジックを個別にテスト可能

### 実装

### 確認手順

```bash
# 1. 環境変数の確認
echo $DOTFILES_WORKTREE

# 2. デフォルト候補の確認
for dir in ~/.config ~/src/*/dotfiles ~/dotfiles; do
  [ -d "$dir" ] && echo "Exists: $dir" || echo "Not found: $dir"
done

# 3. worktree 検証
check_worktree() {
  local dir=$1
  [ -d "$dir" ] && \
  [ -f "$dir/flake.nix" ] && \
  [ -f "$dir/home.nix" ] && \
  [ -f "$dir/nix/dotfiles-module.nix" ] && \
  echo "Valid: $dir"
}

check_worktree ~/.config
```

### 診断スクリプトによる確認

```bash
~/.config/agents/skills-internal/nix-dotfiles/scripts/diagnose.sh
```

スクリプトの `check_worktree()` が以下を確認します:

- `DOTFILES_WORKTREE` 環境変数
- デフォルト候補パスの存在
- 各候補での `flake.nix`, `home.nix`, `nix/dotfiles-module.nix` 確認

---

## .gitignore フィルタリング問題

### 症状

### gitignore-aware フィルタ

`gitignore.nix` を使用して、`.gitignore` パターンに従ったファイルを自動除外します:

```nix
cleanedRepo = gitignore.lib.gitignoreSource cfg.repoPath;
```

### 効果

- `.env.keys`, `.env.local` などの機密情報を除外
- `gh/hosts.yml`, `mise/trusted-configs/` などの動的ファイルを除外
- untracked ファイルは含まれるが、`.gitignore` パターンで除外されるものは除外

### 実装

### デバッグ手順

#### 1. .gitignore のパターン確認

```bash
# 特定のツールに関連するパターンを確認
cat ~/.config/.gitignore | grep -E "(config|mise|gh)"
```

### 一般的なパターン

```gitignore
# 機密情報
.env.keys
.env.local
*.pem
*.key

# 動的ファイル
gh/hosts.yml
mise/trusted-configs/
karabiner/automatic_backups/
zed/cache/
zed/logs/

# 一時ファイル
*.swp
*.tmp
*~
```

#### 2. Git の追跡状態確認

```bash
# untracked かつ .gitignore にマッチするものは除外される
git status --ignored

# 特定ファイルが tracked か確認
git ls-files | grep mise/config.toml
```

#### 3. Home Manager のビルドログで確認

```bash
# cleanedRepo の内容確認
home-manager build --flake ~/.config --impure --show-trace 2>&1 | grep -A 5 "cleanedRepo"

# dry-run で配布されるファイルを確認
home-manager switch --flake ~/.config --impure --dry-run 2>&1 | grep -E "(mise|gh|config)"
```

### 対策

#### Case 1: 除外されるべきファイルが含まれる

### 症状

### 対策

```gitignore
# .gitignore
gh/hosts.yml
mise/trusted-configs/
```

### 検証

```bash
git check-ignore gh/hosts.yml  # should output: gh/hosts.yml
```

#### Case 2: 必要なファイルが除外される

### 症状

### 対策1: .gitignore から削除

```bash
# .gitignore から該当パターンを削除
# 例: mise/config.toml が除外されている場合
```

### 対策2: xdgConfigFiles で個別管理

```nix
# nix/dotfiles-files.nix
xdgConfigFiles = [
  "mise/config.toml"
  "mise/mise.toml"
  # .gitignore で除外されていても、明示的に管理
];
```

### パターン参照

### ベストプラクティス

1. 静的ファイルは tracked に保つ: Git で追跡し、.gitignore で除外しない
2. 動的ファイルは .gitignore で除外: 実行時生成ファイルは除外
3. 個別管理が必要な場合は明示: `xdgConfigFiles` で個別管理

### 実装例

```nix
# 静的ファイルのみ管理
xdgConfigFiles = [
  "mise/config.toml"  # tracked, not in .gitignore
  "gh/config.yml"     # tracked, not in .gitignore
];

# 動的ファイルは activation script でコピー
home.activation.dotfiles-mise = lib.hm.dag.entryAfter ["writeBoundary"] ''
  # mise/trusted-configs/ は .gitignore で除外
  # 実行時に ~/.config/mise/trusted-configs/ として実体化
'';
```

---

## 書き込みエラー

### 症状

```
Error: Permission denied
Error: Read-only file system
```

### 原因

ディレクトリ全体が read-only symlink になっているためです。

Home Manager が `xdg.dirs` でディレクトリ全体を Nix ストアへ symlink すると:

- リンク先は Nix ストア（read-only）
- 実行時にファイルを生成・更新できない

### 問題のあるツール

- `gh/hosts.yml` - OAuth 認証情報の書き込み
- `karabiner/automatic_backups/` - 自動バックアップの書き込み
- `zed/cache/`, `zed/logs/` - キャッシュとログの書き込み

### 対策

#### 1. ディレクトリ全体を除外

```nix
# nix/dotfiles-files.nix

# xdg.dirs から除外（コメントアウトまたは削除）
xdgConfigDirs = [
  # "gh"         # ← 削除
  # "karabiner"  # ← 削除
  # "zed"        # ← 削除
];
```

#### 2. 静的ファイルのみ個別管理

必要な静的設定ファイルのみ `xdgConfigFiles` で管理します。

```nix
# nix/dotfiles-files.nix

xdgConfigFiles = [
  # gh: 静的 config.yml のみ管理
  "gh/config.yml"

  # karabiner: 静的設定のみ
  "karabiner/karabiner.json"
  "karabiner/assets/complex_modifications/my-rules.json"

  # zed: 静的設定のみ
  "zed/settings.json"
  "zed/keymap.json"
];
```

#### 3. 適用と確認

```bash
# 1. 設定変更をビルド検証
home-manager build --flake ~/.config --impure --dry-run

# 2. 適用
home-manager switch --flake ~/.config --impure

# 3. 実体ディレクトリとして復元されたか確認
ls -la ~/.config/gh/
# drwxr-xr-x (シンボリックリンクではなく、実体ディレクトリ)

# 4. ツールが正常動作するか確認
gh auth status
```

### パターン別の実装

#### パターン A: mise (動的ファイルが .gitignore で除外済み)

```nix
xdgConfigFiles = [
  "mise/config.toml"
  "mise/mise.toml"
];

home.activation.dotfiles-mise = lib.hm.dag.entryAfter ["writeBoundary"] ''
  mise_config_dir="${config.xdg.configHome}/mise"
  mkdir -p "$mise_config_dir"
  if [ -d "${cleanedRepo}/mise/tasks" ]; then
    cp -r "${cleanedRepo}/mise/tasks" "$mise_config_dir/"
  fi
'';
```

#### パターン B: gh (動的ファイルを完全に分離)

```nix
xdgConfigFiles = [
  "gh/config.yml"  # 静的設定のみ
];

# hosts.yml は .gitignore で除外
# ユーザーが直接 ~/.config/gh/hosts.yml を管理
```

#### パターン C: alacritty (read-only で問題ない)

```nix
xdgConfigDirs = [
  "alacritty"  # ディレクトリ全体を管理
];

# 書き込みが不要なため、symlink で問題なし
```

### 検証コマンド

```bash
# シンボリックリンクの確認
readlink ~/.config/gh
# 空 → 実体ディレクトリ
# /nix/store/... → シンボリックリンク（要対策）

# ディレクトリの書き込み権限確認
ls -ld ~/.config/gh/
# drwxr-xr-x (OK: 実体ディレクトリ)
# lrwxrwxrwx (NG: シンボリックリンク)

# ツールの動作確認
gh auth login  # 書き込みが成功するか
```
