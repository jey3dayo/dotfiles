---
paths: nix/**, flake.nix, home.nix
---

# Home Manager Rules

Purpose: Home Manager統合における管理方針とガイドライン。

## 用語集

このドキュメントで使用する重要な用語:

### Worktree

Git リポジトリの作業ディレクトリ。Home Manager は設定ファイルを Nix ストアにコピーするため、Git submodule の初期化には元の Git リポジトリ (worktree) が必要。

### Activation Script

Home Manager の切り替え時に実行されるスクリプト。ファイルコピー、ディレクトリ作成、Git 操作などの初期化処理に使用。`home.activation.*` で定義。

### DAG (Directed Acyclic Graph)

Activation script の依存関係を管理する仕組み。`entryAfter`/`entryBefore` で実行順序を指定。

### SSoT (Single Source of Truth)

単一の信頼できる情報源。このプロジェクトでは:

- `agent-skills-sources.nix`: スキルメタデータの SSoT
- `dotfiles-module.nix` の `detectWorktreeScript`: worktree 検出ロジックの SSoT

### cleanedRepo

`gitignore.nix` によって `.gitignore` パターンを適用したリポジトリパス。機密情報や動的ファイルを自動除外。

**実装**: `nix/dotfiles-module.nix` L77

## 管理方針

### 方針1: 静的ファイルのみ管理（採用）

**原則**: 書き込みが必要なディレクトリはHome Manager管理から除外する

**理由**: ディレクトリ全体をNixストアへシンボリックリンクすると、リンク先がread-onlyのため、実行時に生成されるファイル（バックアップ、ログ、状態ファイル等）への書き込みができなくなる。

### 管理対象

#### 含める（静的な設定ファイル）

- 人が編集する設定ファイル
- read-onlyで問題ないディレクトリ
- 例: `alacritty/`, `wezterm/`, `nvim/`, `btop/`, `htop/`

#### 除外（書き込みが必要）

- 実行時に生成・更新されるファイルを含むディレクトリ
- 例:
  - `gh/` - `hosts.yml`への書き込み
  - `karabiner/` - `automatic_backups/`への書き込み
  - `zed/` - `cache/`, `logs/`への書き込み
  - `mise/` - `trusted-configs/`への書き込み（既に管理済みだが`.gitignore`で除外）

**実装**: `nix/dotfiles-files.nix` (xdg.dirs, xdg.files)

## Flake Inputs と Agent Skills 管理

### Nix Flake の inputs 制約

**重要な制約**: Nix flake の `inputs` セクションは**静的な attrset**（リテラル定義）である必要があります。

**禁止されているパターン**:

```nix
# ❌ 動的評価（let-in + import）
inputs = let
  sources = import ./nix/agent-skills-sources.nix;
  dynamicInputs = builtins.mapAttrs (_: src: { inherit (src) url flake; }) sources;
in { ... } // dynamicInputs;
```

**エラー**: `error: expected a set but got a thunk`

**理由**: flake 評価時に inputs は完全に静的である必要があり、実行時評価（thunk）は許可されません。

### Agent Skills の分割管理

**設計アプローチ**: SSoT（Single Source of Truth）とフラットな inputs の併用

| ファイル                       | 役割               | 管理項目                                     |
| ------------------------------ | ------------------ | -------------------------------------------- |
| `nix/agent-skills-sources.nix` | SSoT（メタデータ） | url, flake, baseDir, selection.enable        |
| `flake.nix` inputs             | Flake inputs定義   | url, flake のみ（**手動同期が必要**）        |
| `nix/sources.nix`              | 統合処理           | inputs と baseDir を結合してスキルパスを生成 |
| `nix/agent-skills.nix`         | スキル選択         | selection.enable を抽出                      |

**トレードオフ**:

- ✅ Flake 仕様に準拠
- ✅ メタデータは SSoT で集約管理
- ❌ URL/flake 属性が重複（制約上の妥協）

**実装**: `nix/agent-skills-sources.nix`, `nix/sources.nix`

**実装例**:

```nix
# nix/agent-skills-sources.nix (SSoT)
{
  openai-skills = {
    url = "github:openai/skills";
    flake = false;
    baseDir = "skills";
    selection.enable = [ "gh-fix-ci" "skill-creator" ];
  };
}

# flake.nix (手動同期が必要)
inputs = {
  # NOTE: agent-skills-sources.nix と手動同期
  #       Flake spec requires literal inputs
  openai-skills = {
    url = "github:openai/skills";
    flake = false;
  };
};

# nix/sources.nix (統合)
let
  agentSkills = import ./agent-skills-sources.nix;
  inputs = /* flake inputs */;
in {
  openai-skills = "${inputs.openai-skills}/${agentSkills.openai-skills.baseDir}";
}
```

### 新しいスキルソースを追加する際のチェックリスト

1. **agent-skills-sources.nix を更新**

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

3. **検証**

   ```bash
   # Flake 評価の成功確認
   nix flake show

   # 新しい input が認識されているか確認
   nix flake metadata | grep new-skill-source

   # Home Manager ビルド
   home-manager build --flake ~/.config --impure --dry-run
   ```

4. **スキル配布の確認**

   ```bash
   home-manager switch --flake ~/.config --impure
   ls -la ~/.claude/skills/ | grep <skill-name>
   ```

### トラブルシューティング（Flake Inputs）

#### Agent Skills が配布されない

**症状**: `~/.claude/skills/` が空または一部のスキルのみ存在

**確認手順**:

```bash
# 1. Home Manager generation の確認
home-manager generations | head -3

# 2. 最新 generation に agent-skills が含まれるか
ls -la $(home-manager generations | head -1 | awk '{print $NF}')/home-files/.claude/skills/

# 3. flake inputs の認識確認
nix flake metadata ~/.config | grep -E "(openai-skills|vercel)"
```

**原因と対策**:

**原因1**: 別の flake から `home-manager switch` を実行した

- Generation が上書きされ、`~/.config` の設定が反映されていない
- **対策**: `~/.config` から再度 switch を実行

  ```bash
  home-manager switch --flake ~/.config --impure
  ```

**原因2**: flake.nix と agent-skills-sources.nix の不整合

- 手動同期が必要な URL/flake 属性が一致していない
- **確認**: 両ファイルの URL 一覧を比較

  ```bash
  # agent-skills-sources.nix の URL 一覧
  rg 'url = ' nix/agent-skills-sources.nix

  # flake.nix の inputs URL 一覧
  rg 'url = "github:.*skills' flake.nix
  ```

- **対策**: 不一致箇所を手動同期（agent-skills-sources.nix → flake.nix）

**原因3**: selection.enable の設定ミス

- スキル名が catalog に存在しない、またはタイポ

- **確認**: スキル名が catalog に存在するか

  ```bash

  mise run skills:report
  ```

- **対策**: `nix/agent-skills-sources.nix` の `selection.enable` を修正

**参考**: `~/.claude/rules/troubleshooting.md` の「Nix Home Manager でスキルが配布されない」セクション

#### "expected a set but got a thunk" エラー

**症状**: `nix flake show/metadata/check` が失敗

```
error: expected a set but got a thunk
```

**原因**: flake.nix の inputs セクションで動的評価を使用している

**確認手順**:

```bash
# inputs セクションを確認
rg "inputs\s*=" flake.nix -A 10

# let-in や import の使用を確認
rg "(let|import).*agent-skills" flake.nix
```

**対策**:

1. inputs を静的リテラル定義に変更（`let-in` を削除）
2. agent-skills-sources.nix と flake.nix の URL/flake を同期
3. `nix flake show` で検証

**参考コミット**:

- `2f1e3e34`: Agent Skills の初回統合（migrate agent skills into dotfiles）
- `139dd809`: dotfiles との統合修正（fix: integrate agent skills with dotfiles）
- `56543bda`: catalog 定義の統合（integrate catalog definitions into agent-skills-sources.nix）

**Note**: Flake inputs の静的定義要件は Nix の仕様制約によるもので、実装の歴史的経緯よりも制約の理解が重要。

## Worktree Detection

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

**実装**: `nix/dotfiles-module.nix` L34-74 (`detectWorktreeScript`)

### カスタム検索パスの設定

**使用例**:

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

**環境変数による一時的な上書き**:

```bash
DOTFILES_WORKTREE=/tmp/dotfiles-test home-manager switch --flake . --impure
```

### SSoT パターン

Worktree detection logic は `nix/dotfiles-module.nix` の `detectWorktreeScript` で一元定義され、以下の activation script で再利用されます:

- `dotfiles-tmux-plugins`: tmux plugins のコピー（submodule が必要）
- `dotfiles-submodules`: Git submodule の初期化

**利点**:

1. **保守性**: 検出ロジックの変更が1箇所で済む
2. **一貫性**: 両方の activation script で同じロジックを使用
3. **テスト容易性**: 検出ロジックを個別にテスト可能

**実装**: `nix/dotfiles-module.nix` L34-74 (`detectWorktreeScript`)

### gitignore-aware フィルタ

`gitignore.nix`を使用して、`.gitignore`パターンに従ったファイルを自動除外:

```nix
cleanedRepo = gitignore.lib.gitignoreSource cfg.repoPath;
```

これにより:

- `.env.keys`, `.env.local`などの機密情報を除外
- `gh/hosts.yml`, `mise/trusted-configs/`などの動的ファイルを除外
- untrackedファイルは含まれるが、`.gitignore`パターンで除外されるものは除外

#### デバッグ: 意図しないファイルの除外/含有

**症状**: 設定ファイルが配布されない、または機密ファイルが含まれる

**確認手順**:

```bash
# 1. .gitignore のパターン確認
cat .gitignore | grep -E "(config|mise|gh)"

# 2. Git の追跡状態確認 (untracked かつ .gitignore にマッチするものは除外)
git status --ignored

# 3. Home Manager のビルドログで cleanedRepo の内容確認
home-manager build --flake ~/.config --impure --show-trace 2>&1 | grep -A 5 "cleanedRepo"
```

**対策**:

- **除外されるべきファイルが含まれる**: `.gitignore` にパターン追加
- **必要なファイルが除外される**:
  - `.gitignore` から削除、または
  - `xdgConfigFiles` で個別管理（mise, tmux, gh パターン参照）

**実装**: `nix/dotfiles-module.nix` L77 (`cleanedRepo = gitignore.lib.gitignoreSource`)

### 新しいツールを追加する際の判定フロー

```
[Q1] 実行時にファイルを生成・更新するか?
├─ Yes → [Q2] 生成ファイルは .gitignore で除外されているか?
│          ├─ Yes → [Action A] 静的ファイルのみ管理
│          └─ No  → [Action B] ディレクトリ全体を除外
└─ No  → [Action C] ディレクトリ全体を管理

[Action A] 静的ファイルのみ管理:
  1. nix/dotfiles-files.nix の xdg.files に個別追加
  2. activation script で動的コンテンツをコピー (mise/tmux パターン)

[Action B] ディレクトリ全体を除外:
  1. .gitignore にパターン追加
  2. 静的ファイルが必要なら [Action A] を併用

[Action C] ディレクトリ全体を管理:
  1. nix/dotfiles-files.nix の xdg.dirs に追加
```

**検証コマンド** (全パターン共通):

```bash
# 1. 設定変更をビルド検証
home-manager build --flake ~/.config --impure --dry-run

# 2. 適用
home-manager switch --flake ~/.config --impure

# 3. シンボリックリンク確認
readlink ~/.config/<tool-name>

# 4. ツールが正常動作するか確認
<tool> --version
```

**実装**: `nix/dotfiles-files.nix` (xdg.dirs, xdg.files)

### tmux handling (submodule対応)

**管理方法**: activation scriptで実体化（miseパターン）

**理由**:

- `tmux/plugins/`はGit submoduleで、TPM（Tmux Plugin Manager）が実行時に更新
- read-onlyのNixストアへのsymlinkでは動作しない
- miseの`tasks/`と同様の性質（動的コンテンツ）

**実装**:

```nix
# 静的設定ファイル: xdgConfigFilesで個別管理
xdgConfigFiles = [
  "tmux/copy-paste.conf"
  "tmux/default.session.conf"
  "tmux/keyconfig.conf"
  "tmux/options.conf"
  "tmux/tmux.conf"
  "tmux/tpm.conf"
];

# 動的plugins/: activation scriptでcp -r
home.activation.dotfiles-tmux-plugins = lib.hm.dag.entryAfter ["writeBoundary"] ''
  tmux_config_dir="${config.xdg.configHome}/tmux"
  mkdir -p "$tmux_config_dir/plugins"
  if [ -d "${cleanedRepo}/tmux/plugins" ]; then
    cp -r "${cleanedRepo}/tmux/plugins"/. "$tmux_config_dir/plugins/" 2>/dev/null || true
  fi
'';
```

**DAG依存**: `dotfiles-tmux-plugins`が`dotfiles-submodules`の後に実行されるよう、`entryAfter`に依存を追加

**実装**: `nix/dotfiles-module.nix` L252-281 (dotfiles-tmux-plugins activation)

### gh handling

**管理方法**: 静的`config.yml`のみsymlink配布

**理由**:

- `hosts.yml`は動的ファイル（OAuth認証情報）でユーザーが書き込む
- `config.yml`は静的設定で、miseパターンに倣いsymlinkで配布
- 最小限の変更で一貫性を保つ

**実装**:

```nix
# gh static config (hosts.yml is dynamic and user-managed)
".config/gh/config.yml" = {
  source = "${cleanedRepo}/gh/config.yml";
};
```

**パターン整合性**: miseが静的ファイルを個別symlink（`config.toml`等）、動的`trusted-configs/`を実体化する方式と一致

### トラブルシューティング

#### 書き込みエラーが発生する場合

症状: ツールが「Permission denied」や「Read-only file system」エラーを出す

原因: ディレクトリ全体がNixストアへリンクされている

対策:

1. 該当ディレクトリを`xdgConfigDirs`から削除
2. `home-manager switch`を実行
3. 実体ディレクトリとして復元

#### 設定ファイルが反映されない場合

症状: 設定変更がツールに反映されない

確認:

1. `readlink ~/.config/<tool>`でシンボリックリンク先を確認
2. Nixストア内のファイルに変更が含まれているか確認
3. `home-manager switch`を再実行

## Agent Skills配布アーキテクチャ

### 統合フロー

Agent Skillsは以下の4段階で統合・配布されます：

1. **Sources統合**: `discoverCatalog` (lib.nix L105-127)
   - **Distributions**: `agents/distributions/default/` （バンドル層、オプション）
   - **Internal skills**: `agents/skills-internal/` （42スキル）
   - **External skills**: Flake inputs → `agents/skills/` （symlinks）
   - **優先度**: Local > External > Distribution
   - Conflict detection: External間の重複検出
   - Local overrides: Internal skills が External/Distribution を上書き

2. **Skills選択**: `selectSkills` (lib.nix L129-138)
   - `selection.enable`で選択されたskillsのみ
   - Local skills（skills-internal/）は常に含まれる

3. **Bundle生成**: `mkBundle` (lib.nix L140-160)
   - 選択されたskillsのみをNix storeにコピー
   - rsync -aLによる完全コピー（symlinkを実体化）

4. **配布**: Home Manager (module.nix L169-178)
   - Per-skill symlinkで`~/.claude/skills/`へ配布
   - `.system`ファイルは書き込み可能

**実装**: `agents/nix/lib.nix` (scanDistribution, discoverCatalog), `agents/nix/module.nix`

### Commands配布

Commands（slash commands）の配布フロー:

- **Source**: `agents/commands-internal/` （43ファイル、subdirectories対応）
- **Bundle**: `commandsBundle` (module.nix L32-43)
  - `.md`ファイルのみフィルタリング
  - Subdirectory構造を維持（`clean/`, `kiro/`, `shared/`）
- **配布**: Recursive symlinks (module.nix L199-231)
  - `~/.claude/commands/` へ配布

**実装**: `nix/module.nix` L32-43, L199-231

### CLAUDE.md配布

Target-specific名前変更に対応（2025-02-11実装）:

- **Source**: `CLAUDE.md` (リポジトリルート)
- **配布**: `configFiles` (module.nix L245-261)
  - Claude Code: `~/.claude/CLAUDE.md`
  - OpenCode: `~/.opencode/AGENTS.md` （名前変更）
  - その他: 各targetの設定ファイル名に変換

**実装**: `nix/module.nix` L245-261

### Distributions層の実装（2025-02-11追加）

#### 概要

`agents/distributions/` ディレクトリは、複数のコンポーネント（skills、commands、config）を論理的にバンドリングするための配布層です。

#### 構造

```
agents/distributions/
  ├── README.md
  └── default/              # デフォルトバンドル
      ├── skills/           # skills-internal/* へのsymlinks
      ├── commands/         # commands-internal/*.md へのsymlinks
      └── config/           # 設定ファイル群
```

#### 使用方法

**home.nix での設定**:

```nix
programs.agent-skills = {
  enable = true;

  # Option 1: distributions を使用（バンドル配布）
  distributionsPath = ./agents/distributions/default;

  # Option 2: 個別に指定（従来の方法、併用可能）
  localSkillsPath = ./agents/skills-internal;
  localCommandsPath = ./agents/commands-internal;
};
```

#### 優先度と循環参照の回避

**優先度**: Local > External > Distribution

- `localSkillsPath` が最優先（Internal skills）
- `sources` が次優先（External skills）
- `distributionsPath` が最低優先（Bundle層）

**循環参照の回避**:

distributionsは**静的パス**として扱われ、sources統合**前**にスキャンされます：

```nix
# lib.nix L105-127
discoverCatalog = { sources, localPath, distributionsPath ? null }:
  let
    # 1. distributions をスキャン（静的パス、循環なし）
    distributionResult = scanDistribution distributionsPath;

    # 2. external sources をスキャン
    externalSkills = foldl' scanSourceAutoDetect sources;

    # 3. local skills をスキャン
    localSkills = scanSource localPath;

    # 4. マージ（local > external > distribution）
  in distributionResult.skills // externalSkills // localSkills;
```

distributionsは`mkBundle`の**入力**ではなく、`discoverCatalog`の**入力**なので、循環参照は発生しません。

#### symlinkベースの実装

distributions/内はsymlinkで構成されるため：

- **実体は元のディレクトリ**（skills-internal、commands-internal）
- **sourceタグは実体のソース**を反映（"local"として表示される）
- **物理的な重複なし**（ディスク効率的）

#### 設計判断

**distributions/を追加した理由**:

1. ✅ 論理的なバンドリング単位を提供
2. ✅ カスタムバンドルの作成が容易
3. ✅ skills + commands + config の統合配布
4. ✅ 循環参照を回避する安全な実装

**既存実装との共存**:

- ❌ distributions/は既存のlocalPath/sourcesを**置き換えない**
- ✅ オプショナルな追加レイヤー
- ✅ 従来の個別配布フローも引き続き使用可能

#### `-internal`命名について

**現状**: `skills-internal/`, `commands-internal/`というサフィックス付き命名

**評価**:

- ✅ Internal（非公開）vs External（公開）の区別が明確
- ✅ distributions/配下でも元のソース名が保たれる
- ✅ 実装の本質的な問題ではない

**推奨**: 命名変更は非推奨（distributions/により論理的な整理が可能になったため、物理名は変更不要）

### 配布構造の検証

#### Skills配布確認

```bash
# 1. Catalogに全skillsが含まれているか
nix run ~/.config#list

# 2. Skills配布先の確認
ls -la ~/.claude/skills/ | wc -l
# 期待: 42 (internal) + 選択されたexternal数

# 3. Symlink構造の確認
readlink ~/.claude/skills/agent-creator
# 期待: /nix/store/.../agent-creator
```

#### Commands配布確認

```bash
# 1. Commands配布先の確認
tree ~/.claude/commands/ -L 2
# 期待: 43ファイル（root + clean/ + kiro/ + shared/）

# 2. Subdirectory構造の確認
ls -la ~/.claude/commands/kiro/ | wc -l
# 期待: kiroサブディレクトリ内のコマンド数
```

#### CLAUDE.md/AGENTS.md配布確認

```bash
# 1. Claude向け配布
readlink ~/.claude/CLAUDE.md
# 期待: /nix/store/.../CLAUDE.md

# 2. OpenCode向け配布（renamed）
readlink ~/.opencode/AGENTS.md
# 期待: /nix/store/.../AGENTS.md
```

## 参考

- Home Manager公式: <https://nix-community.github.io/home-manager/>
- gitignore.nix: <https://github.com/hercules-ci/gitignore.nix>
- XDG Base Directory: <https://specifications.freedesktop.org/basedir-spec/>
