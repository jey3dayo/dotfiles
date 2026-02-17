# 🔍 FZF Integration Guide

**最終更新**: 2025-12-17
**対象**: 開発者・上級者
**タグ**: `category/integration`, `tool/fzf`, `layer/support`, `environment/cross-platform`, `audience/advanced`

FZF (Fuzzy Finder) は dotfiles 全体で統一的なファジー検索体験を提供する中核コンポーネントです。
FZF/Git キーバインドとワークフローの一覧は本書を単一情報源とし、他ドキュメントからは参照のみとします（重複防止）。

## 🎯 Overview

## 🤖 Claude Rules

このドキュメントの凝縮版ルールは [`.claude/rules/tools/fzf-integration.md`](../../.claude/rules/tools/fzf-integration.md) で管理されています。

- **目的**: Claude AIが常に参照する簡潔なルール（26-31行）
- **適用範囲**: YAML frontmatter `paths:` で定義
- **関係**: 本ドキュメントが詳細リファレンス（SST）、Claudeルールが強制版

### 統合範囲

FZF は以下の層で横断的に統合されています：

- **Shell Layer**: コマンド履歴、プロセス管理、ディレクトリ移動
- **Git Layer**: リポジトリ選択、ブランチ切り替え、ファイル選択
- **Terminal Layer**: Tmux セッション管理
- **Editor Layer**: Neovim ファイル検索（telescope → fzf-lua 移行済み）

## ⌨️ Key Bindings

### Global Shortcuts

| キーバインド   | 機能                   | 場所        |
| -------------- | ---------------------- | ----------- |
| `^]`           | ghq リポジトリ選択     | Shell (Zsh) |
| `^g?`          | fzf-git キーマップ表示 | Shell (Zsh) |
| `^gx` / `^g^x` | プロセス選択・kill     | Shell (Zsh) |
| `^R`           | コマンド履歴検索       | Shell (Zsh) |
| `^T`           | ファイル選択           | Shell (Zsh) |

**Note**: All `^g` commands support both patterns (`^gX` or `^g^X`)

### Git Integration

| コマンド        | 機能                                        | 実装場所                           |
| --------------- | ------------------------------------------- | ---------------------------------- |
| `^gg` / `^g^g`  | Git diff ウィジェット (FZF)                 | zsh/config/tools/git.zsh           |
| `^gs` / `^g^s`  | Git status ウィジェット (FZF)               | zsh/config/tools/git.zsh           |
| `^ga` / `^g^a`  | Git add -p ウィジェット (FZF)               | zsh/config/tools/git.zsh           |
| `^gb` / `^g^b`  | ブランチ切り替え (既存WTがあれば cd)        | zsh/config/tools/git.zsh (fzf-git) |
| `^gW` / `^g^W`  | ワークツリーメニュー (Open/New/List/Remove) | zsh/config/tools/git.zsh           |
| `^gw` / `^g^w`  | ワークツリー直接選択・cd                    | zsh/config/tools/git.zsh           |
| `^gz` / `^g^z`  | スタッシュ確認・削除 (fzf-git)              | fzf-git.sh                         |
| `^g^f`          | Gitファイル/差分ピッカー (fzf-git)          | fzf-git.sh                         |
| `^g?`           | fzf-git キーバインドヘルプ                  | fzf-git.sh                         |
| `gco()`         | FZF git checkout (ブランチ選択)             | zsh/lazy-sources/fzf.zsh           |
| `wtcd <branch>` | ブランチの worktree に即座に cd             | zsh/config/tools/git.zsh           |

### Tmux Integration

| 機能               | キーバインド | 効果                             |
| ------------------ | ------------ | -------------------------------- |
| セッション切り替え | `prefix + s` | FZF セッション選択 (90%時間短縮) |
| ウィンドウ選択     | `prefix + w` | FZF ウィンドウ選択               |

## 🛠️ Configuration

### Core Settings

#### Base Configuration

```bash
# ~/.config/zsh/config/tools/fzf.zsh
export FZF_DEFAULT_OPTS="--height 50% --reverse"
export FZF_CTRL_R_OPTS="
  --preview 'echo {}' --preview-window up:3:hidden:wrap
  --bind 'ctrl-/:toggle-preview'
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'"
```

#### Theme Integration (Gruvbox)

```bash
# Unified theme across tools
export FZF_DEFAULT_OPTS="--color=bg+:#3c3836,bg:#32302f,spinner:#fb4934"
```

### Plugin Integration

#### fzf-tab (Tab Completion Enhancement)

```bash
# zsh/sources/styles.zsh
export FZF_TAB_HOME=~/.local/share/sheldon/repos/github.com/Aloxaf/fzf-tab

# Enhanced tab completion with FZF
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
```

## 🔧 Layer-Specific Integrations

### Shell Layer Integration

**Performance Impact**: ✅ Optimized - 遅延読み込みで起動時間への影響なし

#### Key Features

- **Repository Navigation**: `^]` による ghq 統合
- **Process Management**: `^g^K` による直感的プロセス操作
- **Command History**: `^R` の強化された履歴検索

#### Implementation

```bash
# Priority loading in sheldon/plugins.toml
[plugins.fzf-tab]
github = "Aloxaf/fzf-tab"
defer = "2"  # Critical path optimization
```

#### fzf-git (Git Pickers)

```bash
# sheldon/plugins.toml
[plugins.fzf-git]
github = "junegunn/fzf-git.sh"
apply = ["source"]
```

- `^g^f`: Git files / diff picker
- `^g^b` / `^gs`: Branch switcher (worktree-aware)
- `^g^w` / `^gw`: Worktree selector (remove with `ctrl-x`)
- `^g^z`: Stash picker (`ctrl-x` to drop)
- `^g?`: Keybinding list

### Git Layer Integration

**Performance Impact**: ✅ 最適化済み - FZF統合による操作効率90%向上

#### Key Features

- **Branch Selection**: 直感的ブランチ切り替え
- **File Selection**: ステージング・差分確認の効率化
- **Repository Management**: ghq + FZF による統合管理

#### Implementation

```bash
# Worktree-aware branch switcher using fzf-git selectors
_git_switch_branch() {
  local branch
  branch=$(_fzf_git_branches | head -n1)
  [[ -z "$branch" ]] && return

  local worktree_path
  worktree_path=$(_git_worktree_for_branch "$branch")
  [[ -n "$worktree_path" ]] && cd "$worktree_path" || git switch --track --guess "$branch"
}
```

### Terminal Layer Integration

**Performance Impact**: ✅ セッション切り替え時間90%短縮

#### Key Features

- **Session Management**: FZF による高速セッション選択
- **Window Navigation**: 効率的ウィンドウ切り替え

#### Implementation

```bash
# tmux.conf integration
bind s display-popup -E "tmux list-sessions | sed -E 's/:.*$//' | \\
  grep -v \"^$(tmux display-message -p '#S')\$\" | \\
  fzf --reverse | xargs tmux switch-client -t"
```

### Editor Layer Integration

**Status**: ✅ telescope.nvim → fzf-lua 移行完了

**Performance Improvement**: 60% faster file searching

#### Key Features

- **File Search**: 高速ファイル検索
- **Text Search**: live grep 統合
- **Buffer Management**: 効率的バッファ切り替え

## 📈 Performance Metrics

### Measured Improvements

| 機能                  | 改善前   | 改善後 | 改善率 |
| --------------------- | -------- | ------ | ------ |
| セッション切り替え    | 5-8秒    | 0.5秒  | 90%↑   |
| リポジトリ選択        | 10-15秒  | 1-2秒  | 85%↑   |
| ファイル検索 (Neovim) | 151.76ms | 60ms   | 60%↑   |
| ブランチ選択          | 3-5秒    | 0.8秒  | 80%↑   |

### Startup Impact

| Component       | Load Time | Strategy              |
| --------------- | --------- | --------------------- |
| fzf core        | 0ms       | 遅延読み込み          |
| fzf-tab         | 12ms      | Priority 2 defer      |
| Git integration | 0ms       | Lazy function loading |

## 🔗 Cross-Tool Workflows

### Repository Development Workflow

```bash
# 1. Repository selection
^]                    # Select repository via FZF + ghq

# 2. Git operations
^g^g                  # Git diff with FZF
^g^s                  # Git status with FZF
^g^b / ^gs            # Branch switcher (fzf-git; cd if worktree exists)
^g^w / ^gw            # Worktree manager (fzf-git selector + create/remove)
^g^z                  # Stash picker (fzf-git; ctrl-x to drop)
^g^f                  # Git file picker (fzf-git)
gco                   # FZF branch checkout

# 3. File operations
^T                    # File selection
^R                    # Command history
```

### Development Session Workflow

```bash
# 1. Session management
prefix + s            # FZF session selection

# 2. Navigation
^]                    # Repository jumping
^g^K                  # Process management

# 3. File operations
nvim                  # fzf-lua integration
```

## 🛡️ Best Practices

### Configuration Management

1. Centralized Settings: FZF options in `config/tools/fzf.zsh`
2. Theme Consistency: Gruvbox integration across all tools
3. Performance Priority: Critical path optimization in sheldon

### Integration Patterns

1. Lazy Loading: Non-critical functions loaded on-demand
2. Widget Integration: Zsh widgets for consistent UX
3. Fallback Handling: Graceful degradation when FZF unavailable

### Performance Optimization

1. Deferred Loading: Sheldon priority management
2. Function Caching: Expensive operations cached
3. Preview Optimization: Efficient preview commands

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

#### Performance degradation

```bash
# Check plugin load times
zsh-benchmark

# Verify deferred loading
sheldon source --verbose
```

## 📚 References

### Documentation Links

- **Shell Integration**: [Shell Layer](zsh.md)
- **Terminal Integration**: [Terminal Layer](wezterm.md)
- **Performance Metrics**: [Performance Layer](../performance.md)

### Implementation Files

- `zsh/config/tools/fzf.zsh` - Core configuration
- `zsh/lazy-sources/fzf.zsh` - Function definitions
- `zsh/sources/styles.zsh` - fzf-tab integration
- `tmux/tmux.conf` - Terminal integration

---

**Last Updated**: 2025-10-03  
**Status**: Production Ready - 全層統合完了  
**Performance**: All optimization targets achieved
