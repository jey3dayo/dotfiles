---
paths: nix/**, flake.nix, home.nix
---

# Home Manager Rules

Purpose: Home Manager統合における管理方針とガイドライン。

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
   home-manager build --flake ~/src/github.com/jey3dayo/dotfiles --impure --dry-run
   ```

4. **スキル配布の確認**

   ```bash
   home-manager switch --flake ~/src/github.com/jey3dayo/dotfiles --impure
   ls -la ~/.claude/skills/ | grep <skill-name>
   ```

### トラブルシューティング（Flake Inputs）

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

- `d6888cb8`: 初回の静的化実施
- `0f56233a`: 誤って動的生成に戻した（失敗）
- `7fbed181`: 再度静的化（現在のアプローチ）

### gitignore-aware フィルタ

`gitignore.nix`を使用して、`.gitignore`パターンに従ったファイルを自動除外:

```nix
cleanedRepo = gitignore.lib.gitignoreSource cfg.repoPath;
```

これにより:

- `.env.keys`, `.env.local`などの機密情報を除外
- `gh/hosts.yml`, `mise/trusted-configs/`などの動的ファイルを除外
- untrackedファイルは含まれるが、`.gitignore`パターンで除外されるものは除外

### 新しいツールを追加する際のチェックリスト

1. ツールが実行時にファイルを生成・更新するか確認
2. 生成されるファイルが`.gitignore`で除外されているか確認
3. 除外されていない場合:
   - ディレクトリ全体を管理対象から除外
   - または、静的ファイルのみを個別に管理
4. 静的ファイルのみの場合:
   - `xdgConfigDirs`にディレクトリ名を追加
   - または`xdgConfigFiles`に個別ファイルを追加

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

## 参考

- Home Manager公式: <https://nix-community.github.io/home-manager/>
- gitignore.nix: <https://github.com/hercules-ci/gitignore.nix>
- XDG Base Directory: <https://specifications.freedesktop.org/basedir-spec/>
