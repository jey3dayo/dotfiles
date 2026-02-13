# Home Manager ディザスタリカバリガイド

このドキュメントは、Nix Home Managerの障害発生時の復旧手順を記載しています。

## 目次

- [シナリオA: 最近の変更をロールバック](#シナリオa-最近の変更をロールバック)
- [シナリオB: 完全な破損からの復旧](#シナリオb-完全な破損からの復旧)
- [シナリオC: /nix/store破損時の復旧](#シナリオc-nixstore破損時の復旧)
- [検証チェックリスト](#検証チェックリスト)

---

## シナリオA: 最近の変更をロールバック

**適用ケース**:

- 最新のHome Manager適用後に問題が発生した
- 特定の設定変更が原因で動作が不安定になった
- スキルやツールが正常に動作しなくなった

### 手順

#### 1. 利用可能な世代を確認

```bash
home-manager generations | head -10
```

**出力例**:

```
2026-02-13 13:16 : id 7 -> /nix/store/8w8zasds1g70bv0a0dsc01mgswm1ld09-home-manager-generation (current)
2026-02-12 18:30 : id 6 -> /nix/store/m5jijcf36s32j3nj99c0bx92w0iwcpkw-home-manager-generation
2026-02-12 18:16 : id 5 -> /nix/store/zxd49h44anxs3v3hq4lvb86wmcd34p38-home-manager-generation
```

**確認ポイント**:

- `(current)` が現在の世代
- `id` が世代番号（ロールバック時に使用）
- タイムスタンプで変更時期を特定

#### 2. 特定の世代にロールバック

```bash
# 例: id 6 にロールバック
home-manager switch --generation 6
```

**重要**:

- ロールバックは即座に適用される
- 新しい世代は作成されず、指定した世代にポインタが移動する
- 元の世代（id 7）は削除されないため、再度切り替え可能

#### 3. 動作確認

```bash
# スキルの配布確認
ls -la ~/.claude/skills/ | wc -l

# 期待値: 63スキル以上（.systemを含む）

# ZSHプラグインの動作確認
zsh-help

# ターミナル再起動
exec zsh -l
```

#### 4. 問題が解決しない場合

さらに古い世代に戻すか、シナリオBの完全復旧を検討：

```bash
# 2世代前にロールバック
home-manager switch --generation 5

# それでも解決しない場合は、シナリオBへ
```

---

## シナリオB: 完全な破損からの復旧

**適用ケース**:

- すべてのgenerationsが破損している
- Home Managerプロファイルが削除された
- 複数のflakeから`home-manager switch`を実行して混乱した（troubleshooting.mdの事例）
- 設定ファイルが失われた

### 手順

#### 1. dotfilesリポジトリの再クローン

```bash
# 既存の設定を退避（念のため）
mv ~/.config ~/.config.backup-$(date +%Y%m%d-%H%M%S)

# dotfilesを再クローン
git clone https://github.com/jey3dayo/dotfiles ~/.config-recovery
cd ~/.config-recovery

# リポジトリの健全性確認
git status
git log --oneline -5
```

#### 2. 必須設定ファイルの復元

`.gitignore`で除外されている重要ファイルを再作成：

```bash
# Git設定の復元
cat > ~/.gitconfig_local << 'EOF'
[user]
    name = Your Name
    email = your.email@example.com
EOF

# SSH設定の確認（必要に応じて）
ls -la ~/.ssh/
# SSH keysがない場合は、バックアップから復元
```

#### 3. Home Managerの再適用

```bash
# 現在の~/.configを一時的に退避
mv ~/.config ~/.config.old-$(date +%Y%m%d-%H%M%S) 2>/dev/null || true

# 回復用リポジトリを正式な場所に移動
mv ~/.config-recovery ~/.config
cd ~/.config

# Home Managerを適用
home-manager switch --flake . --impure
```

**重要**:

- `--impure`フラグは必須（環境変数を使用するため）
- 初回は時間がかかる（パッケージのダウンロード）
- エラーが発生した場合は、ログを確認して個別対応

#### 4. 検証

```bash
# スキル配布の確認
ls -la ~/.claude/skills/ | wc -l
# 期待値: 63スキル以上

# ZSHプラグインの確認
ls -la ~/.config/zsh/sheldon/
# sheldon.zshが存在することを確認

# ターミナルを再起動して動作確認
exec zsh -l

# 基本コマンドのテスト
zsh-help
mise list
brew list --versions
```

#### 5. 古い設定の削除（確認後）

```bash
# 動作確認後、古いバックアップを削除
rm -rf ~/.config.old-*
rm -rf ~/.config.backup-*
```

---

## シナリオC: /nix/store破損時の復旧

**適用ケース**:

- `/nix/store`が破損した
- Nixデーモンが起動しない
- `nix-*`コマンドがすべて失敗する
- `/nix`ディレクトリのパーミッション問題

### 警告

⚠️ **このシナリオは最終手段です**。以下の影響があります：

- すべてのNixパッケージが再ダウンロードされる（数GB）
- Home Manager generationsがすべて失われる
- 復旧に30分〜1時間かかる可能性

### 手順

#### 1. Nixインストールの再初期化

```bash
# Nixを完全に削除
sudo rm -rf /nix

# Nixの再インストール（公式インストーラー）
sh <(curl -L https://nixos.org/nix/install)

# シェル再起動
exec zsh -l

# Nix動作確認
nix --version
```

#### 2. Home Managerの再インストール

```bash
# Home Managerを再インストール
nix run home-manager -- switch --flake ~/.config --impure
```

**注意**:

- 初回実行時は大量のパッケージがダウンロードされる
- ネットワーク速度により時間がかかる
- エラーが発生した場合は、flake.lockを削除して再試行:
  ```bash
  cd ~/.config
  rm flake.lock
  nix flake update
  nix run home-manager -- switch --flake . --impure
  ```

#### 3. 全パッケージの再構築

Home Manager管理外のツールも再インストール：

```bash
# Homebrewパッケージの再インストール
cd ~/.config
brew bundle

# miseツールの再インストール
mise install

# 動作確認
mise list
brew list
```

#### 4. 検証

```bash
# Nix storeの健全性チェック
nix-store --verify --check-contents

# Home Manager generationsの確認
home-manager generations
# 注: 再インストール後は1世代のみ

# スキル配布の確認
ls -la ~/.claude/skills/ | wc -l
# 期待値: 63スキル以上

# ZSHプラグインの確認
ls -la ~/.config/zsh/sheldon/sheldon.zsh
# ファイルが存在することを確認

# すべての基本ツールの動作確認
zsh-help
mise doctor
brew doctor
```

---

## 検証チェックリスト

復旧作業後、以下をすべて確認してください：

### ✅ Nix / Home Manager

- [ ] `nix --version` が正常に実行される
- [ ] `home-manager generations` で世代が表示される
- [ ] `/nix/store` のディスク使用量が正常範囲内（`df -h /nix/store`）

### ✅ スキル配布

- [ ] `ls -la ~/.claude/skills/ | wc -l` が63以上
- [ ] `cat ~/.claude/skills/.system` に"nix-home-manager"が含まれる
- [ ] スキル一覧に主要スキル（task-router, ui-ux-pro-max等）が存在

### ✅ ZSHプラグイン

- [ ] `~/.config/zsh/sheldon/sheldon.zsh` が存在する
- [ ] `zsh-help` が正常に動作する
- [ ] Ctrl+R（fzf履歴検索）が動作する
- [ ] starshipプロンプトが表示される

### ✅ 開発ツール

- [ ] `mise list` でインストール済みツールが表示される
- [ ] `brew list` でHomebrewパッケージが表示される
- [ ] `git --version` が正常に実行される
- [ ] `gh --version` が正常に実行される

### ✅ Git設定

- [ ] `~/.gitconfig_local` が存在する
- [ ] `git config user.name` と `git config user.email` が正しく設定されている

### ✅ SSH設定

- [ ] `~/.ssh/` ディレクトリが存在する
- [ ] 必要なSSH keysが配置されている
- [ ] `ssh -T git@github.com` が成功する（GitHubの場合）

---

## トラブルシューティング

### Q: ロールバック後もスキルが見つからない

**原因**: 別のflakeから`home-manager switch`が実行された可能性

**解決策**:

```bash
# 正しいflakeから再適用
cd ~/.config
home-manager switch --flake . --impure

# ~/.agentsなど他のflakeが存在しないか確認
ls -la ~ | grep -E '(agents|dotfiles)'
```

詳細: `.claude/rules/troubleshooting.md` 参照

### Q: "too many open files" エラー

**原因**: `/nix/store`の大量ファイルによるファイルディスクリプタ不足

**解決策**:

```bash
# macOSの場合、ulimitを一時的に増やす
ulimit -n 4096

# Home Managerを再適用
home-manager switch --flake ~/.config --impure
```

### Q: flake.lockのハッシュ不一致エラー

**原因**: flake.lockが古い、または破損している

**解決策**:

```bash
cd ~/.config
rm flake.lock
nix flake update
home-manager switch --flake . --impure
```

### Q: 特定のスキルだけが見つからない

**原因**: スキル配布パスの問題、または個別スキルの破損

**解決策**:

```bash
# スキル配布パスの確認
cat ~/.claude/skills/.system

# 期待値: "nix-home-manager"

# 該当スキルのシンボリックリンクを確認
ls -la ~/.claude/skills/ | grep <skill-name>

# リンク切れの場合は再適用
home-manager switch --flake ~/.config --impure
```

---

## 参考資料

- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Generations Management](https://nixos.org/manual/nix/stable/package-management/profiles.html)
- プロジェクト内ドキュメント:
  - `.claude/rules/troubleshooting.md` - スキル配布問題の対処法
  - `.claude/rules/nix-maintenance.md` - 定期メンテナンス手順
  - `.claude/rules/workflows-and-maintenance.md` - 全体的なワークフロー

---

**最終更新**: 2026-02-13
