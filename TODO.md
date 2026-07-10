# TODO

## Home Manager / Nix 撤去（段階的完全撤去）

2026-07-10 に dotfiles 配布・launchd agents・headroom venv・tmux submodule 初期化を
mise bootstrap（`mise/config.toml` + `mise/config.default.toml`）へ移管済み。
Home Manager は generation 管理のみの legacy 状態。

### 撤去状況（2026-07-10 コード撤去完了）

- [x] mac: `mise bootstrap` 切替・検証・冪等確認済み
- [x] Raspberry Pi: `mise dotfiles apply` 切替済み（`~/.aicommits.pre-mise-backup` に旧設定の OPENAI_KEY を退避）
- [ ] WSL2: `mise dotfiles apply` へ切替（hm:* タスクは撤去済みのため mise 経由のみ）
- [x] `flake.nix` / `flake.lock` / `nix/*.nix` / `users/` / `home.nix` / `hosts/` を削除
- [x] `hm:*` タスク / `mise/lib/{home-manager,nixfmt}.sh` / lefthook・lint・format の nix フックを削除
- [x] CI の nix 検証（validate.yml / hm:deploy）を撤去し、mise dotfiles 検証へ置換
- [x] docs / rules の HM 記述整理（home-manager.md 削除、nix.md は runtime 掃除用に legacy 残置）
- [x] 未使用 shim 正本の削除（`home/.gitconfig`, `home/.tmux.conf`, `home/.zshrc`）

### 残タスク

- [ ] generation 掃除（mac / pi）: `home-manager remove-generations all && nix-collect-garbage -d`（destructive、実行前に要確認）
- [x] `skills/nix-dotfiles`（repo-local Agent Skill）retire 済み（apm.yml から除去、apm install で lockfile 再生成）
- [ ] Nix ランタイム自体のアンインストール判断（`docs/tools/nix.md` 参照）

## XDG 移行のフォローアップ

- [ ] `~/.npmrc` の廃止: `NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"` を shell / GUI / launchd の全経路へ配布してから `[dotfiles]` エントリと shim を削除
- [ ] awsume の修復: pipx の Python interpreter が失われ起動不能（XDG とは別問題）。`pipx reinstall awsume` 等で復旧
- [ ] ZDOTDIR 構成で HOME 側 `~/.zprofile` が読まれていない可能性を調査（login shell の初期化経路確認）
