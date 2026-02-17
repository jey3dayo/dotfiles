# Architecture

Flake 構造、Worktree SSoT、gitignore フィルタリング、用語集

## Table of Contents

1. [用語集](#用語集)
2. [Flake 構造](#flake-構造)
3. [Flake Inputs と Agent Skills 管理](#flake-inputs-と-agent-skills-管理)
4. [Worktree 検出ロジック](#worktree-検出ロジック)
5. [.gitignore-aware フィルタリング](#gitignore-aware-フィルタリング)
6. [静的 vs 動的ファイル管理](#静的-vs-動的ファイル管理)
7. [Activation Scripts](#activation-scripts)

---

## 用語集

### Worktree

Git リポジトリの作業ディレクトリ。

Home Manager は設定ファイルを Nix ストアにコピーするため、Git submodule の初期化には元の Git リポジトリ (worktree) が必要です。

### なぜ必要か

- Nix ストア内には `.git` ディレクトリが存在しない
- Git 操作（`git submodule update --init`, `git clone`）には Git リポジトリが必要
- activation script で tmux plugins や Git submodule を初期化する際に参照

### 検出方法

---

### Activation Script

Home Manager の切り替え時に実行されるスクリプト。

ファイルコピー、ディレクトリ作成、Git 操作などの初期化処理に使用。`home.activation.*` で定義します。

### 定義例

```nix
home.activation.dotfiles-mise = lib.hm.dag.entryAfter ["writeBoundary"] ''
  mise_config_dir="${config.xdg.configHome}/mise"
  mkdir -p "$mise_config_dir"
  if [ -d "${cleanedRepo}/mise/tasks" ]; then
    cp -r "${cleanedRepo}/mise/tasks" "$mise_config_dir/"
  fi
'';
```

### 実行タイミング

- `home-manager switch` 実行時
- DAG (Directed Acyclic Graph) による依存関係管理

### 一般的な用途

- 動的ファイルのコピー（mise/tasks, tmux/plugins）
- Git submodule の初期化
- ディレクトリの作成
- シンボリックリンクの作成（Home Manager が自動で行わない場合）

---

### DAG (Directed Acyclic Graph)

Activation script の依存関係を管理する仕組み。

`entryAfter`/`entryBefore` で実行順序を指定します。

### 定義例

```nix
home.activation.dotfiles-submodules = lib.hm.dag.entryAfter ["writeBoundary"] ''
  # Git submodule の初期化
'';

home.activation.dotfiles-tmux-plugins = lib.hm.dag.entryAfter ["dotfiles-submodules"] ''
  # tmux plugins のコピー（submodule 初期化後に実行）
'';
```

### 依存関係の指定

- `entryAfter ["A"]`: A の後に実行
- `entryBefore ["B"]`: B の前に実行
- `entryBetween ["A"] ["B"]`: A の後、B の前に実行

### 組み込みアンカー

- `writeBoundary`: Home Manager の設定ファイル書き込み後
- `linkGeneration`: generation のリンク作成後

---

### SSoT (Single Source of Truth)

単一の信頼できる情報源。

このプロジェクトでは:

| SSoT                                            | 管理内容              | 参照元                            |
| ----------------------------------------------- | --------------------- | --------------------------------- |
| `agent-skills-sources.nix`                      | スキルメタデータ      | `sources.nix`, `agent-skills.nix` |
| `dotfiles-module.nix` の `detectWorktreeScript` | worktree 検出ロジック | activation scripts                |
| `.gitignore`                                    | 除外ファイルパターン  | `cleanedRepo`                     |

### 利点

1. 保守性: 変更が1箇所で済む
2. 一貫性: すべての参照元で同じロジックを使用
3. テスト容易性: SSoT を個別にテスト可能

---

### cleanedRepo

`gitignore.nix` によって `.gitignore` パターンを適用したリポジトリパス。

機密情報や動的ファイルを自動除外します。

### 実装

```nix
# nix/dotfiles-module.nix L77
cleanedRepo = gitignore.lib.gitignoreSource cfg.repoPath;
```

### 効果

- `.env.keys`, `.env.local` などの機密情報を除外
- `gh/hosts.yml`, `mise/trusted-configs/` などの動的ファイルを除外
- untracked ファイルは含まれるが、`.gitignore` パターンで除外されるものは除外

### 使用箇所

```nix
# xdg.configFile で使用
"alacritty" = {
  source = "${cleanedRepo}/alacritty";
  recursive = true;
};

# activation script で使用
if [ -d "${cleanedRepo}/mise/tasks" ]; then
  cp -r "${cleanedRepo}/mise/tasks" "$mise_config_dir/"
fi
```

詳細: [.gitignore-aware フィルタリング](#gitignore-aware-フィルタリング)

---

## Flake 構造

### 基本構造

```
~/.config/
├── flake.nix              # Flake エントリポイント
├── flake.lock             # inputs のロックファイル
├── home.nix               # Home Manager 設定
├── nix/
│   ├── dotfiles-module.nix         # Dotfiles 管理モジュール (SSoT)
│   ├── agent-skills-sources.nix    # スキルメタデータ (SSoT)
│   ├── sources.nix                 # inputs + baseDir 統合
│   ├── agent-skills.nix            # スキル選択
│   └── dotfiles-files.nix          # xdg.dirs, xdg.files 定義
└── ...
```

### flake.nix

### 役割

### 重要な制約

```nix
{
  description = "Home Manager configuration with dotfiles";

  inputs = {
    # コアシステム
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Agent Skills (静的リテラル定義)
    # NOTE: agent-skills-sources.nix と手動同期が必要
    openai-skills = {
      url = "github:openai/agent-skills";
      flake = false;
    };
    vercel-skills = {
      url = "github:vercel/next.js/tree/canary/examples";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    homeConfigurations."user@hostname" = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      modules = [ ./home.nix ];
      extraSpecialArgs = { inherit inputs; };
    };
  };
}
```

### home.nix

### 役割

```nix
{ config, pkgs, inputs, ... }:

{
  imports = [
    ./nix/dotfiles-module.nix
  ];

  programs.dotfiles = {
    enable = true;
    repoPath = ./.;
  };

  home.username = "user";
  home.homeDirectory = "/home/user";
  home.stateVersion = "24.05";
}
```

### nix/dotfiles-module.nix

### 役割

### 主要な機能

1. Worktree 検出ロジック（L34-74: `detectWorktreeScript`）
2. cleanedRepo 定義（L77: `gitignore.lib.gitignoreSource`）
3. xdg.configFile の生成
4. activation scripts（mise, tmux, submodules）

### 実装パターン

```nix
{ config, lib, pkgs, ... }:

let
  cfg = config.programs.dotfiles;

  # Worktree 検出の SSoT
  detectWorktreeScript = ''
    # [L34-74] 検出ロジック（詳細は後述）
  '';

  # .gitignore-aware filter の SSoT
  cleanedRepo = gitignore.lib.gitignoreSource cfg.repoPath;

in {
  options.programs.dotfiles = {
    enable = lib.mkEnableOption "dotfiles management";
    repoPath = lib.mkOption { type = lib.types.path; };
    repoWorktreePath = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; };
    repoWorktreeCandidates = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; };
  };

  config = lib.mkIf cfg.enable {
    # xdg.configFile 生成
    xdg.configFile = /* ... */;

    # activation scripts
    home.activation.dotfiles-mise = /* ... */;
    home.activation.dotfiles-submodules = /* ... */;
    home.activation.dotfiles-tmux-plugins = /* ... */;
  };
}
```

---

## Flake Inputs と Agent Skills 管理

### Nix Flake の inputs 制約

### 重要な制約

### 禁止されているパターン

```nix
# ❌ 動的評価（let-in + import）
inputs = let
  sources = import ./nix/agent-skills-sources.nix;
  dynamicInputs = builtins.mapAttrs (_: src: { inherit (src) url flake; }) sources;
in {
  nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
} // dynamicInputs;
```

### エラー

### 理由

### Agent Skills の分割管理

### 設計アプローチ

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

#### nix/agent-skills-sources.nix (SSoT)

```nix
{
  openai-skills = {
    url = "github:openai/agent-skills";
    flake = false;
    baseDir = "skills";
    selection.enable = [
      "gh-fix-ci"
      "skill-creator"
      "task-to-pr"
    ];
  };

  vercel-skills = {
    url = "github:vercel/next.js/tree/canary/examples";
    flake = false;
    baseDir = ".";
    selection.enable = [
      "app-router"
      "api-routes"
    ];
  };
}
```

#### flake.nix (手動同期が必要)

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # NOTE: agent-skills-sources.nix と手動同期
    #       Flake spec requires literal inputs
    openai-skills = {
      url = "github:openai/agent-skills";  # ← SSoT と一致
      flake = false;
    };
    vercel-skills = {
      url = "github:vercel/next.js/tree/canary/examples";  # ← SSoT と一致
      flake = false;
    };
  };
}
```

#### nix/sources.nix (統合)

```nix
{ inputs }:

let
  agentSkills = import ./agent-skills-sources.nix;
in {
  # inputs (flake.nix) + baseDir (agent-skills-sources.nix) を結合
  openai-skills = "${inputs.openai-skills}/${agentSkills.openai-skills.baseDir}";
  vercel-skills = "${inputs.vercel-skills}/${agentSkills.vercel-skills.baseDir}";
}
```

#### nix/agent-skills.nix (スキル選択)

```nix
{ sources }:

let
  agentSkills = import ./agent-skills-sources.nix;
in
  # selection.enable でスキルを抽出
  builtins.concatLists (
    builtins.attrValues (
      builtins.mapAttrs (name: src:
        map (skill: "${sources.${name}}/${skill}") src.selection.enable
      ) agentSkills
    )
  )
```

### 新しいスキルソースを追加する際のチェックリスト

1. agent-skills-sources.nix を更新

   ```nix
   new-skill-source = {
     url = "github:org/repo";
     flake = false;
     baseDir = "skills";  # またはリポジトリルート "."
     selection.enable = [ "skill-name" ];
   };
   ```

2. **flake.nix の inputs に追加**（手動同期）

   ```nix
   inputs = {
     # ... 既存の inputs
     new-skill-source = {
       url = "github:org/repo";  # agent-skills-sources.nix と一致させる
       flake = false;
     };
   };
   ```

3. 検証

   ```bash
   # Flake 評価の成功確認
   nix flake show ~/.config

   # 新しい input が認識されているか確認
   nix flake metadata ~/.config | grep new-skill-source

   # Home Manager ビルド
   home-manager build --flake ~/.config --impure --dry-run
   ```

4. スキル配布の確認

   ```bash
   home-manager switch --flake ~/.config --impure
   ls -la ~/.claude/skills/ | grep <skill-name>
   ```

---

## Worktree 検出ロジック

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

### 実装（SSoT）

### 場所

```bash
detectWorktreeScript = ''
  repo_path="${cfg.repoPath}"
  repo_worktree="${lib.optionalString (cfg.repoWorktreePath != null) cfg.repoWorktreePath}"
  worktree=""

  # Dotfiles リポジトリの検証関数
  is_dotfiles_repo() {
    local candidate="$1"

    # Git リポジトリか確認
    if ! ${pkgs.git}/bin/git -C "$candidate" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      return 1
    fi

    # リポジトリ root を取得
    local root
    root="$(${pkgs.git}/bin/git -C "$candidate" rev-parse --show-toplevel 2>/dev/null)" || return 1

    # dotfiles の必須ファイルが存在するか確認
    if [ -f "$root/flake.nix" ] && [ -f "$root/home.nix" ] && [ -f "$root/nix/dotfiles-module.nix" ]; then
      worktree="$root"
      return 0
    fi

    return 1
  }

  # 検出ロジック（優先度順）
  if [ -n "$repo_worktree" ] && is_dotfiles_repo "$repo_worktree"; then
    :  # [1] 明示指定
  elif [ -n "''${DOTFILES_WORKTREE:-}" ] && is_dotfiles_repo "''${DOTFILES_WORKTREE}"; then
    :  # [2] 環境変数
  elif is_dotfiles_repo "$repo_path"; then
    :  # [3] repoPath
  else
    # [4] カスタム候補 + [5] デフォルト候補
    candidates=(
${worktreeCandidateLines}  # カスタム候補
      "${config.home.homeDirectory}/.config"
      "${config.home.homeDirectory}/src/github.com/$USER/dotfiles"
      "${config.home.homeDirectory}/src/dotfiles"
      "${config.home.homeDirectory}/dotfiles"
    )
    for candidate in "''${candidates[@]}"; do
      if is_dotfiles_repo "$candidate"; then
        break
      fi
    done
  fi
'';
```

### カスタム検索パスの設定

### 使用例

```nix
programs.dotfiles = {
  enable = true;
  repoPath = ./.;
  repoWorktreeCandidates = [
    "/custom/path/to/dotfiles"
    "${config.home.homeDirectory}/my-dotfiles"
  ];
};
```

### 環境変数による一時的な上書き

```bash
DOTFILES_WORKTREE=/tmp/dotfiles-test home-manager switch --flake ~/.config --impure
```

### SSoT パターン

Worktree detection logic は `nix/dotfiles-module.nix` の `detectWorktreeScript` で一元定義され、以下の activation script で再利用されます:

```nix
home.activation.dotfiles-submodules = lib.hm.dag.entryAfter ["writeBoundary"] ''
  ${detectWorktreeScript}  # ← SSoT を再利用

  if [ -n "$worktree" ]; then
    # Git submodule の初期化
    ${pkgs.git}/bin/git -C "$worktree" submodule update --init --recursive
  fi
'';

home.activation.dotfiles-tmux-plugins = lib.hm.dag.entryAfter ["dotfiles-submodules"] ''
  ${detectWorktreeScript}  # ← SSoT を再利用

  if [ -n "$worktree" ] && [ -d "$worktree/tmux/plugins" ]; then
    # tmux plugins のコピー
    cp -r "$worktree/tmux/plugins"/. "$tmux_config_dir/plugins/"
  fi
'';
```

### 利点

1. 保守性: 検出ロジックの変更が1箇所で済む
2. 一貫性: 両方の activation script で同じロジックを使用
3. テスト容易性: 検出ロジックを個別にテスト可能

---

## .gitignore-aware フィルタリング

### gitignore.nix の使用

`gitignore.nix` を使用して、`.gitignore` パターンに従ったファイルを自動除外します:

```nix
# nix/dotfiles-module.nix L77
cleanedRepo = gitignore.lib.gitignoreSource cfg.repoPath;
```

### 効果

- `.env.keys`, `.env.local` などの機密情報を除外
- `gh/hosts.yml`, `mise/trusted-configs/` などの動的ファイルを除外
- untracked ファイルは含まれるが、`.gitignore` パターンで除外されるものは除外

### .gitignore の一般的なパターン

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
tmux/plugins/

# 一時ファイル
*.swp
*.tmp
*~
```

### デバッグ

詳細なデバッグ手順は [troubleshooting.md#gitignore-フィルタリング問題](troubleshooting.md#gitignore-フィルタリング問題) を参照してください。

### クイック確認

```bash
# .gitignore のパターン確認
cat ~/.config/.gitignore | grep -E "(config|mise|gh)"

# Git の追跡状態確認
git status --ignored

# 特定ファイルが除外されるか確認
git check-ignore gh/hosts.yml
```

---

## 静的 vs 動的ファイル管理

### 判定フロー

```
[Q1] 実行時にファイルを生成・更新するか?
├─ Yes → [Q2] 生成ファイルは .gitignore で除外されているか?
│          ├─ Yes → [Action A] 静的ファイルのみ管理
│          └─ No  → [Action B] ディレクトリ全体を除外
└─ No  → [Action C] ディレクトリ全体を管理
```

### Action A: 静的ファイルのみ管理

### 例

### 実装パターン

```nix
# nix/dotfiles-files.nix
xdgConfigFiles = [
  "mise/config.toml"
  "mise/mise.toml"
  "tmux/tmux.conf"
  "tmux/copy-paste.conf"
];

# nix/dotfiles-module.nix
home.activation.dotfiles-mise = lib.hm.dag.entryAfter ["writeBoundary"] ''
  mise_config_dir="${config.xdg.configHome}/mise"
  mkdir -p "$mise_config_dir"
  if [ -d "${cleanedRepo}/mise/tasks" ]; then
    cp -r "${cleanedRepo}/mise/tasks" "$mise_config_dir/"
  fi
'';
```

### メリット

- 静的ファイルは Nix の管理下（宣言的）
- 動的ファイルは実体として配置（書き込み可能）

### Action B: ディレクトリ全体を除外

### 例

### 理由

### 実装パターン

```gitignore
# .gitignore
gh/hosts.yml
karabiner/automatic_backups/
zed/cache/
zed/logs/
```

```nix
# nix/dotfiles-files.nix

# xdg.dirs から除外（コメントアウトまたは削除）
xdgConfigDirs = [
  # "gh"         # ← 除外
  # "karabiner"  # ← 除外
  # "zed"        # ← 除外
];

# 静的ファイルのみ個別管理
xdgConfigFiles = [
  "gh/config.yml"  # 静的設定のみ
];
```

### Action C: ディレクトリ全体を管理

### 例

### 理由

### 実装パターン

```nix
# nix/dotfiles-files.nix
xdgConfigDirs = [
  "alacritty"
  "wezterm"
  "nvim"
  "btop"
  "htop"
];
```

---

## Activation Scripts

### 概要

Activation scripts は Home Manager の切り替え時に実行されるスクリプトです。

### 定義場所

### 主な activation scripts

1. `dotfiles-submodules`: Git submodule の初期化
2. `dotfiles-tmux-plugins`: tmux plugins のコピー
3. `dotfiles-mise`: mise tasks のコピー

### DAG 依存関係

```
writeBoundary
    ↓
dotfiles-submodules (Git submodule 初期化)
    ↓
dotfiles-tmux-plugins (tmux plugins コピー)
    ↓
linkGeneration
```

### 実装

```nix
home.activation.dotfiles-submodules = lib.hm.dag.entryAfter ["writeBoundary"] ''
  # Git submodule の初期化
'';

home.activation.dotfiles-tmux-plugins = lib.hm.dag.entryAfter ["dotfiles-submodules"] ''
  # tmux plugins のコピー（submodule 初期化後）
'';
```

### 実装例: dotfiles-submodules

```nix
home.activation.dotfiles-submodules = lib.hm.dag.entryAfter ["writeBoundary"] ''
  ${detectWorktreeScript}  # worktree 検出

  if [ -n "$worktree" ]; then
    echo "Initializing Git submodules in: $worktree"
    ${pkgs.git}/bin/git -C "$worktree" submodule update --init --recursive 2>/dev/null || true
  else
    echo "Warning: Dotfiles repository not found. Git submodules will not be initialized."
  fi
'';
```

### 実装例: dotfiles-tmux-plugins

```nix
home.activation.dotfiles-tmux-plugins = lib.hm.dag.entryAfter ["dotfiles-submodules"] ''
  ${detectWorktreeScript}  # worktree 検出

  tmux_config_dir="${config.xdg.configHome}/tmux"
  mkdir -p "$tmux_config_dir/plugins"

  if [ -n "$worktree" ] && [ -d "$worktree/tmux/plugins" ]; then
    echo "Copying tmux plugins from: $worktree/tmux/plugins"
    cp -r "$worktree/tmux/plugins"/. "$tmux_config_dir/plugins/" 2>/dev/null || true
  fi
'';
```

### 実装例: dotfiles-mise

```nix
home.activation.dotfiles-mise = lib.hm.dag.entryAfter ["writeBoundary"] ''
  mise_config_dir="${config.xdg.configHome}/mise"
  mkdir -p "$mise_config_dir"

  # mise/tasks/ は .gitignore で除外済みだが、cleanedRepo から取得可能
  if [ -d "${cleanedRepo}/mise/tasks" ]; then
    echo "Copying mise tasks"
    cp -r "${cleanedRepo}/mise/tasks" "$mise_config_dir/"
  fi

  # mise/trusted-configs/ は .gitignore で除外
  # ユーザーが直接 ~/.config/mise/trusted-configs/ を管理
'';
```

### ベストプラクティス

1. エラーハンドリング: `|| true` でエラーを無視（activation script の失敗を防ぐ）
2. SSoT の再利用: `detectWorktreeScript` を再利用
3. DAG 依存の明示: `entryAfter` で実行順序を明確化
4. ディレクトリの作成: `mkdir -p` で必要なディレクトリを作成
5. 条件分岐: `[ -n "$worktree" ]` で worktree 検出成功時のみ実行
