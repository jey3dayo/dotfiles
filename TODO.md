# TODO

## Home Manager / Nix 撤去（段階的完全撤去）

2026-07-10 に dotfiles 配布・launchd agents・headroom venv・tmux submodule 初期化を
mise bootstrap（`mise/config.toml` + `mise/config.default.toml`）へ移管済み。
Home Manager は generation 管理のみの legacy 状態。

### 撤去条件（すべて満たしたら実施）

- [ ] mac: 数日間 zsh / tmux / GUI env（JINA_API_KEY）/ headroom proxy が問題なく動作
- [ ] mac: `mise bootstrap --yes` を再実行して冪等収束を確認
- [ ] WSL2: `mise bootstrap` へ切替（HM の deploy を無効化 → `mise dotfiles apply`）
- [ ] Raspberry Pi: `mise bootstrap` へ切替（`config.pi.toml` 利用。dotfiles は共通 `config.toml` で適用される）

### 撤去内容

- [ ] `flake.nix` / `flake.lock` / `nix/` / `users/` / `home.nix` を削除
- [ ] `mise/local-tasks/home-manager.toml`（`hm:*` タスク）と `mise/lib/home-manager.sh` を削除
- [ ] CI の nix 検証（`nix:check` / `nix:build:*` / `hm:deploy` 依存）を削除
- [ ] generation 掃除: `home-manager remove-generations all && nix-collect-garbage -d`
- [ ] docs / rules の Home Manager 記述を整理（`docs/tools/home-manager.md`, `docs/tools/nix.md`, `.claude/rules/{home-manager,nix-maintenance}.md`, `docs/setup.md` の legacy 注記）
- [ ] 未使用になった shim 正本の削除（`home/.gitconfig`, `home/.tmux.conf`, `home/.zshrc` — XDG ネイティブ移行で配布対象外になったもの。`nix/dotfiles-files.nix` 参照ごと削除）

## XDG 移行のフォローアップ

- [ ] `~/.npmrc` の廃止: `NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"` を shell / GUI / launchd の全経路へ配布してから `[dotfiles]` エントリと shim を削除
- [ ] awsume の修復: pipx の Python interpreter が失われ起動不能（XDG とは別問題）。`pipx reinstall awsume` 等で復旧
- [ ] ZDOTDIR 構成で HOME 側 `~/.zprofile` が読まれていない可能性を調査（login shell の初期化経路確認）
