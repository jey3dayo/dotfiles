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

- [x] generation 掃除（2026-07-10 実施）: mac 11.8GiB 解放（18G→2.3G）、pi 1.9GiB 解放（3.1G→507M）。HM profile / gcroots も削除済み。pi の nix profile には `luacheck` を残置（mise 外供給）
- [x] `skills/nix-dotfiles`（repo-local Agent Skill）retire 済み（apm.yml から除去、apm install で lockfile 再生成）
- [ ] WSL2: `mise dotfiles apply` へ切替（SSH 到達手段がないため WSL2 マシン上で実行: `git pull && mise self-update && MISE_CONFIG_FILE=~/.config/mise/config.default.toml mise dotfiles apply --yes`。旧 HM symlink の残骸削除も同様に）
- [ ] Nix ランタイム自体のアンインストール判断（`docs/tools/nix.md` 参照。`bin/tree-sitter` の nix fallback と pi の `luacheck` 供給が依存）

## XDG 移行のフォローアップ

- [x] `~/.npmrc` の廃止（2026-07-10）: `home/.npmrc` → `npm/npmrc` へ移動、`NPM_CONFIG_USERCONFIG` を shell/env.sh と gui-env LaunchAgent で配布、`[dotfiles]` エントリと symlink を削除
- [x] awsume の修復（2026-07-10）: mise 管理 `pipx:awsume` へ移行（4.5.4）。破損した旧 pipx venv/bin は `~/.local/pipx/awsume-broken-backup-20260710/` に退避
- [x] ZDOTDIR と `~/.zprofile` の調査（2026-07-10）: SOURCE_TRACE で実測。ZDOTDIR 仕様どおり HOME 側 `~/.zprofile` は読まれない（brew shellenv は repo の `zsh/lib/path.zsh` がカバー済みで実害なし）。不要なら `~/.zprofile` は手動削除可
