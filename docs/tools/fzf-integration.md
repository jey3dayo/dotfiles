# 🔍 FZF Integration Guide

最終更新: 2026-09-08
対象: 開発者・上級者
タグ: `category/integration`, `tool/fzf`, `layer/support`, `environment/cross-platform`, `audience/advanced`

FZF (Fuzzy Finder) は dotfiles 全体で統一的なファジー検索体験を提供する中核コンポーネントです。
FZF/Git キーバインドとワークフローの一覧は本書を単一情報源とし、他ドキュメントからは参照のみとします（重複防止）。

## 🎯 Overview

## 🤖 Claude Rules

このドキュメントの凝縮版ルールは [`.claude/rules/tools/fzf-integration.md`](../../.claude/rules/tools/fzf-integration.md) で管理されています。

- 目的: Claude AIが常に参照する簡潔なルール
- 適用範囲: YAML frontmatter `paths:` で定義
- 関係: 本ドキュメントが詳細リファレンス（SST）、Claudeルールが強制版

### 統合範囲

FZF は以下の層で横断的に統合されています：

- Shell Layer: コマンド履歴（atuin。FZFではない）、プロセス管理、ディレクトリ移動
- Git Layer: リポジトリ選択、ブランチ切り替え、ファイル選択

Tmux と Neovim は現状 FZF と統合されていません（Tmux はセッション/ウィンドウ操作に `command-prompt` を使用、Neovim は `mini.pick` を使用）。詳細は「未確認・対象外の統合」を参照。

## ⌨️ Key Bindings

### Global Shortcuts

| キーバインド   | 機能                                 | 実装場所                                             |
| -------------- | ------------------------------------ | ---------------------------------------------------- |
| `^]`           | ghq リポジトリ選択 (FZF)             | `zsh/lib/fzf.zsh`                                    |
| `^g?`          | fzf-git キーマップ表示               | `fzf-git.sh`（`zsh/lib/git-widgets.zsh` からロード） |
| `^gx` / `^g^x` | プロセス選択・kill (FZF)             | `zsh/lib/fzf.zsh`                                    |
| `^R`           | コマンド履歴検索（atuin。FZF不使用） | `zsh/lib/atuin.zsh`                                  |
| `^T`           | ファイル選択 (FZF)                   | `zsh/lib/fzf.zsh`                                    |

Note: All `^g` commands support both patterns (`^gX` or `^g^X`)

### Git Integration

| コマンド       | 機能                                                                                              | 実装場所                  |
| -------------- | ------------------------------------------------------------------------------------------------- | ------------------------- |
| `^gg` / `^g^g` | Git 操作メニュー (FZF; status/diff/add-p/branch switch/stash/git-files/worktrees/browse から選択) | `zsh/lib/git-widgets.zsh` |
| `^gs` / `^g^s` | `git status -sb` をバッファへ挿入・実行（FZF不使用）                                              | `zsh/lib/git-widgets.zsh` |
| `^ga` / `^g^a` | `git add -p` をバッファへ挿入・実行（FZF不使用）                                                  | `zsh/lib/git-widgets.zsh` |
| `^gb` / `^g^b` | `gh browse` でリポジトリを開く（FZF不使用）                                                       | `zsh/lib/git-widgets.zsh` |
| `^gB`          | ブランチ切り替え (FZF; 既存WTがあれば cd)                                                         | `zsh/lib/git-widgets.zsh` |
| `^gW` / `^g^W` | ワークツリーメニュー (FZF; Open/New/List/Prune)                                                   | `zsh/lib/git-widgets.zsh` |
| `^gw` / `^g^w` | ワークツリー一覧をバッファへ挿入 (fzf-git; 自動cdなし。`ctrl-x` で remove)                        | `fzf-git.sh`              |
| `^gz` / `^g^z` | スタッシュ確認・削除 (fzf-git; `ctrl-x` で drop)                                                  | `fzf-git.sh`              |
| `^g^f`         | Gitファイル/差分ピッカー (fzf-git)                                                                | `fzf-git.sh`              |
| `^g?`          | fzf-git キーバインドヘルプ                                                                        | `fzf-git.sh`              |

補足: `gco` は `zsh-abbr/user-abbreviations` に定義された `git checkout` の静的 abbreviation であり、FZF によるブランチ選択は行わない。`wtcd` という関数・コマンドはリポジトリ内に存在しない（旧ドキュメントの記述を削除）。

## 🛠️ Configuration

### Core Settings

#### Base Configuration

```bash
# zsh/lib/fzf.zsh
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:-"--height 50% --reverse"}"
export FZF_CTRL_T_COMMAND="${FZF_CTRL_T_COMMAND:-"fd --type f --hidden --follow --exclude .git --exclude node_modules --exclude .worktrees --exclude .claude/worktrees --exclude tmp --exclude dist --exclude build"}"
export FZF_CTRL_T_OPTS="${FZF_CTRL_T_OPTS:-"--preview 'bat -n --color=always {}' --bind 'ctrl-/:change-preview-window(down|hidden|)'"}"
```

`^R` (履歴検索) は atuin (`zsh/lib/atuin.zsh`) が担当しており、FZF 側に `FZF_CTRL_R_OPTS` などの専用設定は存在しない。FZF 用の Gruvbox 配色 (`--color=...`) もリポジトリ内には設定されていない。

### Plugin Integration

#### fzf-tab (Tab Completion Enhancement)

```bash
# zsh/lib/fzf-tab.zsh
zstyle ':completion:*' menu no
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:*' fzf-flags '-i'
zstyle ':fzf-tab:*' fzf-bindings 'tab:down' 'btab:up' 'ctrl-o:toggle'
```

## 🔧 Layer-Specific Integrations

### Shell Layer Integration

#### Key Features

- Repository Navigation: `^]` による ghq 統合
- Process Management: `^gx` / `^g^x` によるプロセス選択・kill
- Command History: `^R` (atuin、FZF不使用)

#### Implementation

`sheldon/plugins.toml` の `fzf-tab` / `fzf-git` はいずれも `apply = ["noop"]` で登録されており、sheldon 側の `defer` 設定は使われていない。実際の読み込みは `zsh/lib/fzf-tab.zsh` と `zsh/lib/git-widgets.zsh` が `add-zsh-hook precmd` でインタラクティブシェル起動後に一度だけ実行する形で行われる。

```bash
# zsh/sheldon/plugins.toml (抜粋)
[plugins.fzf-tab]
github = "Aloxaf/fzf-tab"
apply = ["noop"]

[plugins.fzf-git]
github = "junegunn/fzf-git.sh"
apply = ["noop"]
```

#### fzf-git (Git Pickers)

- `^g^f` / `^gf`: Git files / diff picker
- `^gw` / `^g^w`: Worktree selector (remove with `ctrl-x`)
- `^gz` / `^g^z`: Stash picker (`ctrl-x` to drop)
- `^g?`: Keybinding list
- ブランチ切り替えは fzf-git の `branches` ウィジェットではなく、自前実装の `^gB` (`zsh/lib/git-widgets.zsh` の `_zsh_git_switch_branch`) が担う。

### Git Layer Integration

#### Key Features

- Branch Selection: 直感的ブランチ切り替え
- File Selection: ステージング・差分確認の効率化
- Repository Management: ghq + FZF による統合管理

#### Implementation

```bash
# zsh/lib/git-widgets.zsh (抜粋、worktree-aware なブランチ切り替え)
_zsh_git_switch_branch() {
  _zsh_git_is_repo || return 1
  (( $+functions[_fzf_git_branches] )) || return 1

  local branch
  branch="$(_fzf_git_branches --no-multi)"
  [[ -n "$branch" ]] || return 0

  local worktree_path
  worktree_path="$(
    git worktree list --porcelain | awk -v target="$branch" '
      $1=="worktree" { path=$2 }
      $1=="branch" {
        br=$2
        sub("^refs/heads/", "", br)
        if (br == target) { print path; exit }
        path=""
      }
    '
  )"

  if [[ -n "$worktree_path" && -d "$worktree_path" ]]; then
    cd "$worktree_path" || return
    return 0
  fi

  if git rev-parse --verify --quiet "$branch" >/dev/null 2>&1; then
    git switch "$branch"
  else
    git switch --track --guess "$branch"
  fi
}
```

## 🔗 Cross-Tool Workflows

### Repository Development Workflow

```bash
# 1. Repository selection
^]                    # Select repository via FZF + ghq

# 2. Git operations
^g^g                  # Git action menu (FZF)
^gs / ^g^s            # git status (buffer insert, no FZF)
^gB                   # Branch switcher (FZF; cd if worktree exists)
^gW / ^g^W            # Worktree menu (FZF; Open/New/List/Prune)
^gw / ^g^w            # Worktree list insert (fzf-git; no auto-cd, ctrl-x to remove)
^gz / ^g^z            # Stash picker (fzf-git; ctrl-x to drop)
^g^f                  # Git file picker (fzf-git)

# 3. File operations
^T                    # File selection
^R                    # Command history (atuin)
```

## 🛡️ Best Practices

### Configuration Management

1. Centralized Settings: FZF options in `zsh/lib/fzf.zsh`
2. Performance Priority: precmd フックによる遅延初期化（`zsh/lib/fzf-tab.zsh`, `zsh/lib/git-widgets.zsh`）

### Integration Patterns

1. Lazy Loading: Non-critical functions loaded on-demand（sheldon の `defer` は未使用、precmd フックで自前遅延ロード）
2. Widget Integration: Zsh widgets for consistent UX
3. Fallback Handling: Graceful degradation when FZF unavailable

## 🔧 Troubleshooting

### Common Issues

#### FZF not available

```bash
# Check installation
which fzf
echo $FZF_DEFAULT_OPTS

# Reinstall if needed
brew install fzf
$(brew --prefix)/opt/fzf/install
```

#### Tab completion not working

```bash
# Check fzf-tab installation
ls ~/.local/share/sheldon/repos/github.com/Aloxaf/fzf-tab

# Reload Zsh configuration
exec zsh
```

## 📚 References

### Documentation Links

- Shell Integration: [Shell Layer](zsh.md)
- Terminal Integration: [Terminal Layer](wezterm.md)
- Performance Metrics: [Performance Layer](../performance.md)

### Implementation Files

- `zsh/lib/fzf.zsh` - Core configuration, `^]` / `^T` / `^gx` widgets
- `zsh/lib/fzf-tab.zsh` - fzf-tab integration (zstyle, lazy load)
- `zsh/lib/git-widgets.zsh` - Git widgets (`^gg`/`^gs`/`^ga`/`^gb`/`^gB`/`^gW`) and fzf-git loader
- `zsh/lib/atuin.zsh` - `^R` history search (atuin, not FZF)

### 未確認・対象外の統合

以下は本ドキュメントの旧版に記載があったが、`zsh/`, `tmux/`, `nvim/` を検索しても該当する実装が確認できなかったため削除した。

- Tmux セッション/ウィンドウ切り替えの FZF 統合（`tmux/*.conf` に `fzf` の参照なし。`prefix + s` は `command-prompt "select-window -t '%%'"` であり FZF・セッション切り替えのどちらでもない。`prefix + w` の独自バインドも存在しない）
- Neovim の `telescope.nvim` → `fzf-lua` 移行（`nvim/` に `fzf` の参照なし。実際は `mini.pick` + `neogit` を使用）
- `gco()` という FZF ブランチ選択関数、`wtcd` という worktree cd 関数

### 未確認のまま残した記述

- 各種パフォーマンス数値（セッション切り替え時間、ファイル検索速度、起動時間への影響など）は、測定根拠となるベンチマークやログを本タスクの範囲では確認できなかった。特にセッション切り替えおよび Neovim ファイル検索の数値は、上記で実体なしと確認した統合（Tmux FZF連携・fzf-lua）を前提にしていた可能性があるため、次回更新時に再検証が必要。
- `^gc` / `^g^c`（`fzf-cd-widget`）、`Esc c`（`\ec`）は `zsh/lib/fzf.zsh` に実装があるが、本ドキュメントには未記載。追加提案はスコープ外のため記載していない。

---

Last Updated: 2026-09-08
Status: Corrected against zsh/lib, zsh/sheldon, tmux/, nvim/ (see 未確認・対象外の統合)
