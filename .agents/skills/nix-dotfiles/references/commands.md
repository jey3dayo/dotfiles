# Command Reference

全コマンドリファレンス（home-manager, nix flake）

## Table of Contents

1. [home-manager Commands](#home-manager-commands)
2. [nix flake Commands](#nix-flake-commands)
3. [診断コマンド](#診断コマンド)

---

## home-manager Commands

### switch

### 用途

### 構文

```bash
home-manager switch --flake <path> [--impure]
```

### オプション

- `--flake <path>`: Flake のパス（通常は `~/.config`）
- `--impure`: 環境変数の読み込みを許可（`DOTFILES_WORKTREE`, `CI` 等）
- `--dry-run`: 実行せずに確認
- `--show-trace`: エラー時にトレースを表示

### 例

```bash
# 基本形（環境検出自動）
home-manager switch --flake ~/.config --impure

# dry-run で確認
home-manager switch --flake ~/.config --impure --dry-run

# エラー時のトレース表示
home-manager switch --flake ~/.config --impure --show-trace
```

### 環境検出

- `CI=true`: `mise.ci.toml` を使用
- `PI=true`: `mise.pi.toml` を使用
- デフォルト: `mise.toml` を使用

### 成功確認

```bash
# 設定ファイルのシンボリックリンク確認
readlink ~/.config/nvim

# generation の確認
home-manager generations | head -1
```

---

### build

### 用途

### 構文

```bash
home-manager build --flake <path> [--impure]
```

### オプション

- `--flake <path>`: Flake のパス
- `--impure`: 環境変数の読み込みを許可
- `--dry-run`: ビルドせずに確認
- `--show-trace`: エラー時にトレースを表示

### 例

```bash
# ビルド検証（適用せず）
home-manager build --flake ~/.config --impure

# dry-run で確認
home-manager build --flake ~/.config --impure --dry-run
```

### 使用場面

- 設定変更のテスト
- CI でのビルド確認
- エラーチェック

### ビルド成果物

```bash
# result symlink が作成される
ls -la ~/.config/result

# ビルド内容の確認
ls -la $(readlink ~/.config/result)
```

---

### generations

### 用途

### 構文

```bash
home-manager generations
```

### 出力例

```
2025-02-10 12:34:56 : id 42 -> /nix/store/<hash>-home-manager-generation
2025-02-09 10:20:30 : id 41 -> /nix/store/<hash>-home-manager-generation
2025-02-08 14:15:16 : id 40 -> /nix/store/<hash>-home-manager-generation
```

### フィルタリング

```bash
# 最新5世代
home-manager generations | head -5

# 最新3世代の詳細確認
home-manager generations | head -3 | while read line; do
  gen_path=$(echo "$line" | awk '{print $NF}')
  echo "Generation: $line"
  ls -la "$gen_path/home-files/.claude/" 2>/dev/null || echo "  No .claude/"
done
```

### 世代の確認

```bash
# 最新 generation のパス取得
latest_gen=$(home-manager generations | head -1 | awk '{print $NF}')

# .claude が含まれるか確認
find "$latest_gen/home-files/" -path "*claude*"

# 特定ツールの設定確認
ls -la "$latest_gen/home-files/.config/nvim/"
```

---

### switch --generation

### 用途

### 構文

```bash
home-manager switch --generation <N>
```

### 例

```bash
# 世代一覧を確認
home-manager generations | head -5

# 世代 41 へロールバック
home-manager switch --generation 41

# ロールバック後の確認
home-manager generations | head -1
ls -la ~/.claude/skills/
```

### ロールバック後の再適用

```bash
# 最新の設定に戻す
home-manager switch --flake ~/.config --impure
```

### 注意事項

- ロールバックは一時的な措置
- 設定を修正したら `home-manager switch` で再適用
- `--generation` は過去の世代を指定（最新世代の ID より小さい）

---

### remove-generations

### 用途

### 構文

```bash
home-manager remove-generations <days>
```

### 例

```bash
# 30日より古い世代を削除
home-manager remove-generations 30d

# すべての世代を削除（現在の世代以外）
home-manager remove-generations all
```

### ディスク容量の確認

```bash
# Nix ストアのサイズ
du -sh /nix/store

# 世代の数
home-manager generations | wc -l
```

### ガベージコレクション

```bash
# 使用されていない Nix パッケージを削除
nix-collect-garbage -d

# または（より詳細）
nix-store --gc
```

---

## nix flake Commands

### show

### 用途

### 構文

```bash
nix flake show <flake-ref>
```

### 例

```bash
# ~/.config flake の出力を表示
nix flake show ~/.config

# 特定の input を表示
nix flake show ~/.config#homeConfigurations
```

### 出力例

```
└───homeConfigurations
    └───user@hostname: Home Manager configuration
```

### 使用場面

- Flake 構造の確認
- outputs の存在確認
- 設定ミスのデバッグ

---

### metadata

### 用途

### 構文

```bash
nix flake metadata <flake-ref> [--json]
```

### 例

```bash
# メタデータ表示
nix flake metadata ~/.config

# JSON 形式で表示
nix flake metadata ~/.config --json
```

### 出力例

```
Resolved URL:  path:/home/user/.config
Locked URL:    path:/home/user/.config
Path:          /home/user/.config
Inputs:
├───nixpkgs: github:nixos/nixpkgs/nixpkgs-unstable
└───home-manager: github:nix-community/home-manager
```

### JSON 出力の活用

```bash
# inputs 数をカウント
nix flake metadata ~/.config --json | jq '.locks.nodes | length'
```

---

### check

### 用途

### 構文

```bash
nix flake check <flake-ref>
```

### 例

```bash
# 構文チェック
nix flake check ~/.config

# 詳細なトレース表示
nix flake check ~/.config --show-trace
```

### チェック項目

- Flake 構文の正しさ
- inputs の整合性
- outputs の型チェック

### エラー例

```
error: expected a set but got a thunk
```

→ inputs で動的評価（let-in）を使用している（[troubleshooting.md](troubleshooting.md#flake-inputs-エラー) 参照）

---

### update

### 用途

### 構文

```bash
nix flake update <flake-ref> [--update-input <input>]
```

### 例

```bash
# すべての inputs を更新
nix flake update ~/.config

# nixpkgs のみ更新
nix flake update ~/.config --update-input nixpkgs
```

### 更新後の確認

```bash
# flake.lock の差分確認
git diff ~/.config/flake.lock

# 更新内容の確認
nix flake metadata ~/.config
```

### 自動コミット

```bash
# 更新とコミット
cd ~/.config
nix flake update
git add flake.lock
git commit -m "chore: update flake inputs"
```

---

### lock

### 用途

### 構文

```bash
nix flake lock <flake-ref> [--update-input <input>]
```

### 例

```bash
# flake.lock を生成
nix flake lock ~/.config
```

### 使用場面

- flake.lock が存在しない場合
- inputs を追加した後
- 特定 input のバージョンを固定したい場合

---

## 診断コマンド

### 統合診断スクリプト

### 用途

### 構文

```bash
<installed-nix-dotfiles-skill-dir>/scripts/diagnose.sh
```

### チェック項目

1. Generation 検証（最新 generation の存在と `.claude` 含有）
2. Symlink 検証（`~/.config/result` のリンク先）
3. Worktree 検出（`DOTFILES_WORKTREE` と候補パスの検証）

### 出力例

```
=== Nix Dotfiles Diagnostic ===

Checking Home Manager generation... [✓] Generation check: .claude found in latest generation

Checking symlinks... [✓] Symlink check: ~/.config/result -> /nix/store/...

Checking worktree detection... [✓] Worktree check: Found at /home/user/.config

=== Summary ===
All checks passed ✓
```

### エラー出力例

```
=== Nix Dotfiles Diagnostic ===

Checking Home Manager generation... [✗] Generation check: .claude not found in generation
    Generation path: /nix/store/.../home-manager-generation

=== Summary ===
Some checks failed. See details above.

Quick fixes:
  - Generation issue: home-manager switch --flake ~/.config --impure
  - Worktree: Set DOTFILES_WORKTREE=/path/to/dotfiles
```

---

### Generation 確認コマンド

### 最新 generation のパス取得

```bash
home-manager generations | head -1 | awk '{print $NF}'
```

### generation に .claude が含まれるか確認

```bash
latest_gen=$(home-manager generations | head -1 | awk '{print $NF}')
find "$latest_gen/home-files/" -path "*claude*"
```

### generation の内容確認

```bash
# .claude/skills/ の内容
ls -la "$latest_gen/home-files/.claude/skills/"

# 特定ツールの設定
ls -la "$latest_gen/home-files/.config/nvim/"
```

### generation の年齢確認

```bash
gen_time=$(home-manager generations | head -1 | awk '{print $1, $2}')
gen_epoch=$(date -d "$gen_time" +%s)
now_epoch=$(date +%s)
age_hours=$(( (now_epoch - gen_epoch) / 3600 ))
echo "Generation age: $age_hours hours"
```

---

### Symlink 検証コマンド

### ~/.config/result の確認

```bash
# シンボリックリンク先
readlink ~/.config/result

# リンク先の存在確認
ls -la $(readlink ~/.config/result)
```

### 設定ファイルのシンボリックリンク確認

```bash
# nvim 設定
readlink ~/.config/nvim

# wezterm 設定
readlink ~/.config/wezterm

# 実体ディレクトリか確認
ls -ld ~/.config/gh/  # drwxr-xr-x なら実体、lrwxrwxrwx なら symlink
```

---

### Flake Inputs 確認コマンド

### flake.nix の inputs 一覧

```bash
rg 'url = ' ~/.config/flake.nix
```

### inputs 数のカウント

```bash
# flake.nix
rg -o 'url = "github:' ~/.config/flake.nix | wc -l
```

---

### Worktree 検証コマンド

### 環境変数の確認

```bash
echo $DOTFILES_WORKTREE
```

### デフォルト候補の確認

```bash
for dir in ~/.config ~/src/*/dotfiles ~/dotfiles; do
  if [ -d "$dir" ]; then
    echo "Exists: $dir"
  else
    echo "Not found: $dir"
  fi
done
```

### worktree 検証関数

```bash
check_worktree() {
  local dir=$1
  if [ -d "$dir" ] && \
     [ -f "$dir/flake.nix" ] && \
     [ -f "$dir/home.nix" ] && \
     [ -f "$dir/nix/dotfiles-module.nix" ]; then
    echo "Valid worktree: $dir"
    return 0
  else
    echo "Invalid worktree: $dir"
    return 1
  fi
}

# 使用例
check_worktree ~/.config
check_worktree ~/dotfiles
```

### Git リポジトリの確認

```bash
# Git リポジトリか確認
git -C ~/.config rev-parse --git-dir

# リポジトリの root
git -C ~/.config rev-parse --show-toplevel
```

---

## コマンドの使い分け

| コマンド                   | 用途                    | 実行タイミング   |
| -------------------------- | ----------------------- | ---------------- |
| `home-manager switch`      | 設定適用                | 設定変更後       |
| `home-manager build`       | ビルド検証              | 適用前テスト     |
| `home-manager generations` | 世代一覧                | トラブル時       |
| `nix flake show`           | Flake 構造確認          | 設定追加後       |
| `nix flake metadata`       | Flake メタデータ確認    | inputs 確認時    |
| `nix flake check`          | Flake 構文チェック      | flake.nix 編集後 |
| `nix run .#validate`       | スキル構造の検証        | スキル追加後     |
| `diagnose.sh`              | Home Manager 統合の診断 | トラブル発生時   |
| `mise run ci`              | CI チェック全体         | PR 作成前        |

---

## トラブルシューティング

詳細なトラブルシューティング手順は [troubleshooting.md](troubleshooting.md) を参照してください。

### クイックリファレンス

- [Flake inputs エラー](troubleshooting.md#flake-inputs-エラー)
- [Worktree 検出失敗](troubleshooting.md#worktree-検出失敗)
- [書き込みエラー](troubleshooting.md#書き込みエラー)
