---
paths:
  - "nix/**"
  - "flake.nix"
  - "home.nix"
  - "flake.lock"
  - "docs/tools/home-manager.md"
  - "docs/tools/apm-workspace.md"
source: docs/tools/home-manager.md
---

# Home Manager Rules

Purpose: Home Manager 統合における管理方針とガイドライン。
Detailed Reference: [docs/tools/home-manager.md](../../docs/tools/home-manager.md)

## 管理方針: 静的ファイルのみ管理

ディレクトリ全体を Nix ストアへシンボリックリンクすると read-only になり、実行時生成ファイルへの書き込みができなくなる。

禁止パターン: 書き込みが必要なディレクトリ（`gh/`, `karabiner/`, `zed/`, `mise/`）をまるごと管理

実装: `nix/dotfiles-files.nix` (xdg.dirs, xdg.files)

## Flake Inputs と Agent Skills

制約: Nix flake の `inputs` は静的なリテラル定義必須。`let-in` / 動的評価は禁止（エラー: "expected a set but got a thunk"）

#### Agent Skills SSoT

- `nix/agent-skills-sources.nix`: url, flake, baseDir, selection.enable の SSoT
- `flake.nix` inputs: url, flake のみ（`agent-skills-sources.nix` と**手動同期が必要**）

新しいスキルソース追加時は両ファイルを同期し、`nix flake show` で検証。

## Worktree 検出優先度

`repoWorktreePath` > `$DOTFILES_WORKTREE` > `repoPath` > `repoWorktreeCandidates` > デフォルト候補 (`~/.config`, `~/src/*/dotfiles`, `~/dotfiles`)

実装: `nix/dotfiles-module.nix` L34-74 (`detectWorktreeScript`)

## ZDOTDIR / PATH 管理規約

- ZDOTDIR: `$HOME/.config/zsh`
- PATH 優先度: mise shims > `$HOME/{bin,.local/bin}` > 言語ツール > Homebrew > system

## Agent Skills の扱い

- managed asset は `~/.apm/catalog/**` で管理する。
- global skill の daily operation は `cd ~/.apm && mise run ...` を使う。
- Home Manager は dotfiles 配布と generation 管理を担当する。

## よくあるトラブル

| 症状                                   | 原因                                  | 対策                                                          |
| -------------------------------------- | ------------------------------------- | ------------------------------------------------------------- |
| `~/.claude/skills/` が空               | 別の flake から switch した           | `home-manager switch --flake ~/.config --impure`              |
| `~/.claude/skills/` が空               | URL 不整合                            | `agent-skills-sources.nix` と `flake.nix` の URL を比較・同期 |
| "expected a set but got a thunk"       | flake inputs に動的評価               | inputs を静的リテラル定義に変更                               |
| Permission denied / Read-only          | ディレクトリ全体が Nix ストアにリンク | `xdgConfigDirs` から除外して switch                           |
| agent catalog を直したのに反映されない | APM 側の apply 未実行                 | `cd ~/.apm && mise run apply && mise run doctor`              |

詳細なトラブルシューティング: [docs/tools/home-manager.md](../../docs/tools/home-manager.md)、[docs/disaster-recovery.md](../../docs/disaster-recovery.md)
