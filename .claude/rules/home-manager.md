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

- Home Manager公式: https://nix-community.github.io/home-manager/
- gitignore.nix: https://github.com/hercules-ci/gitignore.nix
- XDG Base Directory: https://specifications.freedesktop.org/basedir-spec/
