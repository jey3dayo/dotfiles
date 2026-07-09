---
name: nix-dotfiles
description: "Manage and troubleshoot dotfiles with Home Manager and Nix Flake. Use when users mention home-manager, Nix flake, `nixで配布`, `~/.configがnix管理`, applying configuration (`設定を適用`), generations or rollback, worktree not found, or migrating legacy home-dotfiles such as `~/.opencommit` into `~/.config`. Agent Skills distribution is handled by `~/.apm` (APM), not Nix — use `apm-usage` for that. For `mise skills add`, mise task definitions, or `mise run`, use `mise` instead."
---

# Nix Dotfiles

Home Manager + Nix Flake による dotfiles 運用。設定適用、世代管理、診断、legacy dotfile 移行をカバーする。Flake は `~/.config` にある。Agent Skills の配布は `~/.apm`(APM)が担当し、Nix 側の配布機構は廃止済み。

## Quick Start

```bash
# 適用（環境自動判定: CI は mise.ci.toml / Pi は mise.pi.toml / それ以外は mise.toml）
home-manager switch --flake ~/.config --impure

# 事前確認
home-manager switch --flake ~/.config --impure --dry-run

# 適用結果の確認
readlink ~/.config/nvim

# 世代の確認とロールバック
home-manager generations | sed -n '1,5p'
home-manager switch --generation <N>
```

設定変更の基本フロー: 編集 → `home-manager build --flake ~/.config --impure` で検証 → `switch` で適用 → symlink とツール動作を確認。

## 新規ツール追加の判断

```
[Q1] 実行時にファイルを生成・更新するか?
├─ Yes → [Q2] 生成物は .gitignore で除外済みか?
│          ├─ Yes → Action A: 静的ファイルのみ管理
│          └─ No  → Action B: ディレクトリごと除外
└─ No  → Action C: ディレクトリごと管理
```

### Action A: 静的ファイルのみ管理

```nix
# nix/dotfiles-files.nix
xdgConfigFiles = [
  "mise/config.toml"
  "tmux/tmux.conf"
];
```

動的コンテンツが必要なら activation script でコピーする:

```nix
home.activation.dotfiles-mise = lib.hm.dag.entryAfter ["writeBoundary"] ''
  mise_config_dir="${config.xdg.configHome}/mise"
  mkdir -p "$mise_config_dir"
  if [ -d "${cleanedRepo}/mise/tasks" ]; then
    cp -r "${cleanedRepo}/mise/tasks" "$mise_config_dir/"
  fi
'';
```

### Action B: ディレクトリごと除外

credential・キャッシュ・自動バックアップを含むディレクトリが対象（例: `gh/hosts.yml`, `karabiner/automatic_backups/`, `zed/cache/`）。

```gitignore
gh/hosts.yml
karabiner/automatic_backups/
zed/cache/
```

静的ファイルが必要な場合は Action A と併用する（`gh/config.yml` のみ `xdgConfigFiles` へ）。

### Action C: ディレクトリごと管理

生成物を持たない静的設定ディレクトリ（例: `alacritty`, `wezterm`, `nvim`）。

```nix
xdgConfigDirs = [
  "alacritty"
  "wezterm"
  "nvim"
];
```

## Legacy home-dotfile の移行（`~/.opencommit` など）

1. ツールが `~/.config/<tool>/...` を読めるか確認する
2. 読めるなら静的設定を `xdgConfigFiles` へ移す
3. secret・キャッシュ・生成物は tracked repo に入れない
4. home-dotfile パスしか読まないツールは、実体を `~/.config` に置き互換 symlink を張る
5. 実際の legacy パスを先に確認する（バージョンにより `~/.opencommit` / `~/.opencommitrc` が混在）

```nix
xdgConfigFiles = [
  "opencommit/config.json"
];

home.file.".opencommitrc".source =
  config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/opencommit/config.json";
```

## 診断

トラブル時はまず統合診断スクリプトを実行する:

```bash
<installed-nix-dotfiles-skill-dir>/scripts/diagnose.sh
```

3項目（世代の妥当性、symlink、worktree 検出）を `[✓]` / `[✗]` で報告する。

| ツール            | 用途                    | 実行タイミング   |
| ----------------- | ----------------------- | ---------------- |
| `diagnose.sh`     | Home Manager 統合の診断 | トラブル時       |
| `nix flake check` | Flake 構文検証          | flake.nix 編集後 |
| `mise run ci`     | フル CI チェック        | PR 作成前        |

個別コマンド（世代・symlink・flake metadata の手動確認）は `references/commands.md` を参照。

## よくある問題

| 症状                                          | 原因                                                | 対処                                                                                                                 |
| --------------------------------------------- | --------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| 設定が反映されない                            | 別 flake から switch して世代が後勝ちで上書きされた | `~/.config` から `home-manager switch --flake ~/.config --impure`                                                    |
| Flake inputs エラー                           | inputs に let-in / import を使っている              | 静的リテラル定義へ変更し `nix flake show ~/.config` で検証                                                           |
| `Dotfiles repository not found`               | worktree 検出失敗                                   | `DOTFILES_WORKTREE=/path/to/dotfiles home-manager switch ...` で一時回避、恒久対応は `repoWorktreeCandidates` を設定 |
| `Permission denied` / `Read-only file system` | 実行時書き込みが必要なディレクトリを Nix 管理にした | 対象を `xdgConfigDirs` から外して switch し、静的ファイルのみ `xdgConfigFiles` で管理                                |

worktree の恒久設定:

```nix
# nix/dotfiles-module.nix
programs.dotfiles = {
  enable = true;
  repoPath = ./.;
  repoWorktreeCandidates = [
    "/custom/path/to/dotfiles"
    "${config.home.homeDirectory}/my-dotfiles"
  ];
};
```

## References

- `references/troubleshooting.md` — 上の表で解決しない時に読む。症状 → 原因 → 確認 → 修正の詳細手順（flake inputs、worktree、.gitignore フィルタ、書き込みエラー）
- `references/commands.md` — 正確なフラグや個別診断コマンドが必要な時に読む。home-manager / nix flake の全コマンド
- `references/architecture.md` — Flake 構造、worktree SSoT、gitignore フィルタリング、activation script の仕組みを理解したい時に読む
