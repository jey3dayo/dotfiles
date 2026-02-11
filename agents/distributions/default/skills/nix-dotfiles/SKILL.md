---
name: nix-dotfiles
description: |
  [What] Home Manager と Nix Flake を使った dotfiles 管理とトラブルシューティング。設定適用、世代管理、診断、Agent Skills 追加をサポート。
  [When] Use when: ユーザーが "スキルが配布されない"、"~/.claude/skills/ が空"、"dotfiles をデプロイ"、"設定を適用"、"Nix flake をテスト"、"home-manager"、"generations"、"rollback"、"worktree が見つからない" と言った時。
  [Keywords] home-manager, nix flake, dotfiles, agent skills, generations, rollback, worktree, flake inputs, diagnosis, スキル配布
---

# nix-dotfiles - Home Manager Dotfiles Management

## Overview

Home Manager と Nix Flake による dotfiles 管理の統合スキル。設定適用からトラブルシューティングまでをカバーします。

### 主な機能

- 設定適用 (home-manager switch)
- 世代管理 (generations, rollback)
- 診断 (スキル配布、Flake inputs、Worktree 検出、.gitignore)
- Agent Skills 追加 (flake inputs 同期)

## Quick Start

### 最頻出操作

#### 設定を適用する

```bash
# 基本形 (環境検出自動: CI/Pi/Default)
home-manager switch --flake ~/.config --impure

# dry-run で確認
home-manager switch --flake ~/.config --impure --dry-run
```

### 成功確認

```bash
# Agent Skills が配布されているか
ls -la ~/.claude/skills/

# 設定ファイルのシンボリックリンク確認
readlink ~/.config/nvim
```

### 環境検出

- CI: `mise.ci.toml`
- Pi: `mise.pi.toml`
- Default: `mise.toml`

#### 世代を確認・戻す

```bash
# 世代一覧（最新5件）
home-manager generations | head -5

# 特定世代へロールバック
home-manager switch --generation <N>
```

#### 診断を実行

```bash
# 統合診断スクリプト
~/.config/agents/skills-internal/nix-dotfiles/scripts/diagnose.sh

# 個別確認
readlink ~/.claude/skills
nix flake metadata ~/.config
home-manager generations | head -3
```

### 設定変更の基本フロー

```
編集 → ビルド検証 → 適用 → 確認
  ↓         ↓        ↓      ↓
 edit    build    switch  verify
```

### 実行例

```bash
# 1. 設定ファイルを編集
nvim ~/.config/nix/dotfiles-module.nix

# 2. ビルド検証（適用せず）
home-manager build --flake ~/.config --impure

# 3. 適用
home-manager switch --flake ~/.config --impure

# 4. 確認
ls -la ~/.config/<tool-name>
<tool> --version
```

## Core Workflows

### 新ツール追加の判定フロー

新しいツールを追加する際の判定:

```
[Q1] 実行時にファイルを生成・更新するか?
├─ Yes → [Q2] 生成ファイルは .gitignore で除外されているか?
│          ├─ Yes → [Action A] 静的ファイルのみ管理
│          └─ No  → [Action B] ディレクトリ全体を除外
└─ No  → [Action C] ディレクトリ全体を管理
```

#### Action A: 静的ファイルのみ管理

### 例

### 実装

```nix
# nix/dotfiles-files.nix
xdgConfigFiles = [
  "mise/config.toml"
  "mise/mise.toml"
  "tmux/tmux.conf"
  "tmux/copy-paste.conf"
];
```

### activation script で動的コンテンツをコピー

```nix
home.activation.dotfiles-mise = lib.hm.dag.entryAfter ["writeBoundary"] ''
  mise_config_dir="${config.xdg.configHome}/mise"
  mkdir -p "$mise_config_dir"
  if [ -d "${cleanedRepo}/mise/tasks" ]; then
    cp -r "${cleanedRepo}/mise/tasks" "$mise_config_dir/"
  fi
'';
```

#### Action B: ディレクトリ全体を除外

### 例

### 理由

- `gh/hosts.yml` (OAuth 認証情報)
- `karabiner/automatic_backups/` (自動バックアップ)
- `zed/cache/`, `zed/logs/` (キャッシュとログ)

### 実装

```gitignore
# .gitignore
gh/hosts.yml
karabiner/automatic_backups/
zed/cache/
zed/logs/
```

### 静的ファイルが必要な場合は Action A を併用

```nix
xdgConfigFiles = [
  "gh/config.yml"  # 静的設定のみ
];
```

#### Action C: ディレクトリ全体を管理

### 例

### 理由

### 実装

```nix
# nix/dotfiles-files.nix
xdgConfigDirs = [
  "alacritty"
  "wezterm"
  "nvim"
];
```

### Agent Skills 追加フロー

新しい Agent Skill ソースを追加する手順:

#### 1. agent-skills-sources.nix を更新

```nix
# nix/agent-skills-sources.nix
{
  # 既存スキル...

  new-skill-source = {
    url = "github:org/repo";
    flake = false;
    baseDir = "skills";  # またはリポジトリルート "."
    selection.enable = [ "skill-name" ];
  };
}
```

#### 2. flake.nix の inputs に追加（手動同期が必要）

```nix
# flake.nix
{
  inputs = {
    # ... 既存の inputs
    new-skill-source = {
      url = "github:org/repo";  # agent-skills-sources.nix と一致させる
      flake = false;
    };
  };
}
```

### 重要

#### 3. 検証

```bash
# Flake 評価の成功確認
nix flake show ~/.config

# 新しい input が認識されているか
nix flake metadata ~/.config | grep new-skill-source

# Home Manager ビルド
home-manager build --flake ~/.config --impure --dry-run
```

#### 4. スキル配布の確認

```bash
# 適用
home-manager switch --flake ~/.config --impure

# スキルが配布されたか確認
ls -la ~/.claude/skills/ | grep <skill-name>
```

## Diagnostic Commands

### 統合診断スクリプト

```bash
~/.config/agents/skills-internal/nix-dotfiles/scripts/diagnose.sh
```

### チェック項目

1. **Generation 検証**: 最新 generation の存在と `.claude` 含有確認
2. **Symlink 検証**: `~/.config/result` と `~/.claude/skills/` のリンク先確認
3. **Flake Inputs 一貫性**: `flake.nix` と `agent-skills-sources.nix` の URL 一致確認
4. **Worktree 検出**: `DOTFILES_WORKTREE` と候補パスの検証

### 出力形式

```
[✓] Generation check: Latest generation found
[✓] Symlink check: All symlinks valid
[✗] Flake inputs check: URL mismatch found
[✓] Worktree check: ~/.config detected
```

### 手動診断コマンド集

#### Generation 確認

```bash
# 最新 generation の確認
home-manager generations | head -3

# generation に .claude が含まれるか
find /nix/store/<hash>-home-manager-generation/home-files/ -path "*claude*"

# dry-run でリンク生成を確認
home-manager switch --flake ~/.config --impure --dry-run 2>&1 | grep claude
```

#### Symlink 検証

```bash
# ~/.config/result の確認
readlink ~/.config/result

# ~/.claude/skills/ のリンク先
readlink ~/.claude/skills

# Nix ストア内のスキル一覧
ls -la $(readlink ~/.claude/skills)
```

#### Flake metadata

```bash
# Flake 情報の確認
nix flake metadata ~/.config

# inputs 一覧
nix flake show ~/.config

# 特定 input の URL 確認
nix flake metadata ~/.config | grep -E "(openai-skills|vercel)"
```

### 既存ツールとの使い分け

| ツール               | 用途                    | 実行タイミング   |
| -------------------- | ----------------------- | ---------------- |
| `diagnose.sh`        | Home Manager 統合の診断 | トラブル発生時   |
| `nix run .#validate` | スキル構造の検証        | スキル追加後     |
| `nix flake check`    | Flake 構文の検証        | flake.nix 編集後 |
| `mise run ci`        | CI チェック全体         | PR 作成前        |

## Common Issues & Quick Fixes

### スキル配布問題

### 症状

### クイック診断

```bash
~/.config/agents/skills-internal/nix-dotfiles/scripts/diagnose.sh
```

### 原因と対策

1. **別の flake から switch を実行した**
   - Generation が上書きされた
   - **対策**: `~/.config` から再度 switch を実行

     home-manager switch --flake ~/.config --impure

     ```

     ```

2. **flake.nix と agent-skills-sources.nix の不整合**
   - URL/flake 属性が一致していない
   - **確認**:

     ```bash
     # agent-skills-sources.nix の URL 一覧
     rg 'url = ' ~/.config/nix/agent-skills-sources.nix

     # flake.nix の inputs URL 一覧
     rg 'url = "github:.*skills' ~/.config/flake.nix
     ```

   - **対策**: 不一致箇所を手動同期（agent-skills-sources.nix → flake.nix）

3. **selection.enable の設定ミス**
   - スキル名が catalog に存在しない、またはタイポ

   - **確認**:

     ```bash

     mise run skills:report
     ```

   - **対策**: `nix/agent-skills-sources.nix` の `selection.enable` を修正

### 詳細

### Flake inputs エラー

### 症状

### 原因

### 確認手順

```bash
# inputs セクションの確認
rg "inputs\s*=" ~/.config/flake.nix -A 10

# let-in や import の使用を確認
rg "(let|import).*agent-skills" ~/.config/flake.nix
```

### 対策

1. inputs を静的リテラル定義に変更（`let-in` を削除）
2. agent-skills-sources.nix と flake.nix の URL/flake を同期
3. `nix flake show ~/.config` で検証

### 詳細

### Worktree 検出失敗

### 症状

```
Error: Dotfiles repository not found
```

### 解決

```bash
# 一時的な上書き
DOTFILES_WORKTREE=/path/to/dotfiles home-manager switch --flake ~/.config --impure
```

### 恒久的な設定

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

### 詳細

### 書き込みエラー

### 症状

```
Error: Permission denied
Error: Read-only file system
```

### 原因

### 対策

1. `nix/dotfiles-files.nix` の `xdg.dirs` から該当ディレクトリを除外
2. `home-manager switch --flake ~/.config --impure` を実行
3. 実体ディレクトリとして復元される
4. 必要な静的ファイルのみ `xdg.files` で個別管理

### 例

```nix
# xdg.dirs から除外
# xdgConfigDirs = [ "gh" ];  # ← 削除

# 静的ファイルのみ個別管理
xdgConfigFiles = [
  "gh/config.yml"  # 静的設定のみ
];
```

## References Navigation

詳細なドキュメントは references/ に配置されています。

### references/troubleshooting.md

詳細な診断手順（症状 → 原因 → 確認 → 対策）

### 主なセクション

- Agent Skills が配布されない
- Flake inputs エラー
- Worktree 検出失敗
- .gitignore フィルタリング問題
- 書き込みエラー

### references/commands.md

全コマンドリファレンス（home-manager, nix flake, nix run）

### カバー範囲

- `home-manager switch`, `build`, `generations`, `switch --generation`
- `nix flake show`, `metadata`, `check`
- `nix run .#validate`
- 診断コマンド（generation 確認、symlink 検証、flake inputs 確認）

### references/architecture.md

Flake 構造、Worktree SSoT、gitignore フィルタリング、用語集

### 主なセクション

- 用語集（Worktree, Activation Script, DAG, SSoT, cleanedRepo）
- Flake 構造
- Flake Inputs と Agent Skills 管理
- Worktree 検出ロジック
- .gitignore-aware フィルタリング
- 静的 vs 動的ファイル管理
- Activation Scripts

## Scripts Usage

### diagnose.sh

統合診断スクリプト。4つのチェックを実施:

### チェック項目

1. **Generation 検証**
   - 最新 generation の存在確認
   - `~/.claude/skills/` 含有確認
   - 24時間以内チェック（警告）

2. **Symlink 検証**
   - `~/.config/result` が有効 symlink
   - リンク先が最新 generation と一致
   - `~/.claude/skills/` のリンク先

3. **Flake Inputs 一貫性**
   - `flake.nix` の inputs 数
   - `nix/agent-skills-sources.nix` のソース数
   - URL 差分検出

4. **Worktree 検出**
   - `DOTFILES_WORKTREE` 環境変数
   - デフォルト候補パス存在確認
   - 各候補で `flake.nix`, `home.nix`, `nix/dotfiles-module.nix` 確認

### 実行

```bash
~/.config/agents/skills-internal/nix-dotfiles/scripts/diagnose.sh
```

### 出力形式

```
[✓] Check name: message
[✗] Check name: message

All checks passed ✓
```

または

```
Some checks failed. See details above.
```
