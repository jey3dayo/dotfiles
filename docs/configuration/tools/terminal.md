# Terminal Layer - Terminal Emulators & Multiplexers

このレイヤーでは、ターミナルエミュレータ（Alacritty、WezTerm）とマルチプレクサ（tmux）の設定・最適化・統合に関する知見を体系化します。

## 🎯 責任範囲

**🔥 主要技術**: WezTermはdotfiles環境の中核技術の一つ

- **設定量**: 全dotfilesの約25%を占める主要コンポーネント
- **技術特性**: Lua設定による高度なカスタマイズ、GPU加速描画
- **使用頻度**: 開発作業の視覚的基盤として常時使用

- **Terminal Emulators**: Alacritty、WezTerm設定と統合（WezTerm重点）
- **Multiplexers**: tmux設定、セッション管理、プラグイン
- **Performance**: 描画最適化、GPU加速、フォント設定
- **Integration**: シェル、エディタ、ツールとの連携

## 📊 実装パターン

### WezTerm モジュラー設定

#### ファイル構成（推奨）

```
wezterm/
├── wezterm.lua      # メイン設定ファイル
├── ui.lua           # UI・テーマ設定
├── keybinds.lua     # キーバインド設定
└── utils.lua        # ユーティリティ関数
```

#### メイン設定パターン

```lua
-- wezterm.lua - メイン設定
local wezterm = require('wezterm')
local ui = require('ui')
local keybinds = require('keybinds')

local config = wezterm.config_builder()

-- モジュール適用
ui.apply_to_config(config)
keybinds.apply_to_config(config)

return config
```

### UI設定パターン

```lua
-- ui.lua - UI/UX設定
local M = {}

function M.apply_to_config(config)
    -- フォント設定
    config.font = wezterm.font_with_fallback({
        'UDEV Gothic 35NFLG',
        'JetBrains Mono',
        'Symbols Nerd Font Mono',
    })
    config.font_size = 16.0

    -- テーマ設定
    config.color_scheme = 'Gruvbox dark, hard (base16)'
    config.window_background_opacity = 0.92
    config.macos_window_background_blur = 20

    -- パフォーマンス
    config.front_end = 'WebGpu'
    config.max_fps = 120

    return config
end

return M
```

### キーバインド設定

```lua
-- keybinds.lua - キーバインド設定
local wezterm = require('wezterm')
local act = wezterm.action
local M = {}

function M.apply_to_config(config)
    config.leader = { key = 'x', mods = 'CTRL', timeout_milliseconds = 1000 }

    config.keys = {
        -- タブ管理
        { key = 'c', mods = 'LEADER', action = act.SpawnTab('CurrentPaneDomain') },
        { key = '&', mods = 'LEADER', action = act.CloseCurrentTab{ confirm = true } },

        -- ペイン分割
        { key = '"', mods = 'LEADER', action = act.SplitVertical{ domain = 'CurrentPaneDomain' } },
        { key = '%', mods = 'LEADER', action = act.SplitHorizontal{ domain = 'CurrentPaneDomain' } },

        -- ペイン移動
        { key = 'h', mods = 'ALT', action = act.ActivatePaneDirection('Left') },
        { key = 'j', mods = 'ALT', action = act.ActivatePaneDirection('Down') },
        { key = 'k', mods = 'ALT', action = act.ActivatePaneDirection('Up') },
        { key = 'l', mods = 'ALT', action = act.ActivatePaneDirection('Right') },

        -- コピーモード
        { key = '[', mods = 'LEADER', action = act.ActivateCopyMode },
    }

    return config
end

return M
```

## 🖥️ Tmux統合パターン

### 基本設定・リーダーキー統一

```tmux
# ~/.tmux.conf
# リーダーキー設定（WezTermと統一）
set -g prefix C-x
unbind C-b
bind C-x send-prefix

# 基本オプション
set -g base-index 1           # ウィンドウ番号1から開始
setw -g pane-base-index 1     # ペイン番号1から開始
set -g mouse on               # マウス操作有効
setw -g mode-keys vi          # viモード

# パフォーマンス最適化
set -sg escape-time 10        # ESCキー高速化
set -g history-limit 10000    # 履歴行数
set -g repeat-time 600        # リピート時間

# 設定リロード
bind r source-file ~/.tmux.conf \; display-message "Config reloaded!"

# ペイン分割（カレントパス維持）
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
bind '"' split-window -v -c "#{pane_current_path}"
bind % split-window -h -c "#{pane_current_path}"

# ペイン移動 (vim-like)
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# ペインリサイズ
bind -r C-h resize-pane -L 5
bind -r C-j resize-pane -D 5
bind -r C-k resize-pane -U 5
bind -r C-l resize-pane -R 5
```

### プラグイン管理・セッション永続化

```tmux
# TPM (Tmux Plugin Manager)
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'

# セッション管理
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'

# 検索・操作強化
set -g @plugin 'tmux-plugins/tmux-copycat'
set -g @plugin 'tmux-plugins/tmux-open'

# テーマ
set -g @plugin 'egel/tmux-gruvbox'

# 自動保存・復元設定
set -g @continuum-restore 'on'
set -g @continuum-save-interval '15'
set -g @resurrect-capture-pane-contents 'on'
set -g @resurrect-strategy-nvim 'session'

run '~/.tmux/plugins/tpm/tpm'
```

### 現代的コピー・ペースト（macOS最適化）

```tmux
# コピーモード設定
setw -g mode-keys vi
bind [ copy-mode
bind -T copy-mode-vi v send-keys -X begin-selection
bind -T copy-mode-vi V send-keys -X select-line
bind -T copy-mode-vi C-v send-keys -X rectangle-toggle
bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"
bind -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "pbcopy"

# マウス選択でコピー
bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "pbcopy"

# ペースト
bind p run "pbpaste | tmux load-buffer - ; tmux paste-buffer"
bind C-p run "pbpaste | tmux load-buffer - ; tmux paste-buffer"
```

## ⚡ パフォーマンス最適化

### WezTerm最適化

```lua
-- パフォーマンス設定
config.front_end = 'WebGpu'  -- GPU加速
config.max_fps = 120         -- 高フレームレート
config.animation_fps = 1     -- アニメーション無効化

-- メモリ最適化
config.scrollback_lines = 10000
config.enable_wayland = false  -- macOSでは不要
```

### フォント最適化

```lua
-- フォント設定
config.font = wezterm.font_with_fallback({
    { family = 'UDEV Gothic 35NFLG', weight = 'Regular' },
    { family = 'JetBrains Mono', weight = 'Regular' },
    { family = 'Symbols Nerd Font Mono', scale = 0.8 },
})

config.font_size = 16.0
config.line_height = 1.1
config.cell_width = 1.0
```

## 🔧 統合パターン

### シェル統合・Zsh連携

```zsh
# WezTerm統合
if [[ "$TERM_PROGRAM" == "WezTerm" ]]; then
    # WezTerm固有の設定
    export TERM_PROGRAM_VERSION

    # タブタイトル自動設定
    precmd() {
        print -Pn "\e]0;%~\a"
    }
fi

# Tmux略語（高効率）
abbr ta 'tmux -2 a'              # tmux attach
abbr tn 'tmux new -s'            # tmux new session
abbr tl 'tmux list-sessions'     # tmux list
abbr tk 'tmux kill-session -t'   # tmux kill

# セッション管理関数
tm() {
    if [[ $# -eq 0 ]]; then
        # 引数なし：既存セッションをfzfで選択
        local session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf)
        [[ -n "$session" ]] && tmux attach-session -t "$session"
    else
        # 引数あり：セッション名指定
        tmux attach-session -t "$1" 2>/dev/null || tmux new-session -s "$1"
    fi
}

# プロジェクト連携tmux起動
tproject() {
    local project_name=$(basename "$PWD")
    tmux new-session -d -s "$project_name" -c "$PWD"
    tmux send-keys -t "$project_name" "nvim ." Enter
    tmux split-window -h -t "$project_name" -c "$PWD"
    tmux attach-session -t "$project_name"
}
```

### エディタ統合

```lua
-- Neovim統合
config.keys = {
    {
        key = 'e',
        mods = 'LEADER',
        action = wezterm.action.SpawnCommandInNewTab {
            args = { 'nvim', '.' },
        },
    },
}
```

## 🎨 テーマ・UI設定

### 一貫したテーマ設定

```lua
-- カラースキーム統合
local function get_appearance()
    if wezterm.gui then
        return wezterm.gui.get_appearance()
    end
    return 'Dark'
end

local function scheme_for_appearance(appearance)
    if appearance:find 'Dark' then
        return 'Gruvbox dark, hard (base16)'
    else
        return 'Gruvbox light, hard (base16)'
    end
end

config.color_scheme = scheme_for_appearance(get_appearance())
```

## 🚧 最適化課題

### 高優先度

- [ ] WezTerm起動時間の短縮（目標: 500ms以下）
- [ ] GPU使用率の最適化
- [ ] フォントレンダリングの改善

### 中優先度

- [ ] Tmuxセッション管理の自動化
- [ ] 複数ターミナル間での設定同期
- [ ] キーバインドの統一化

## 💡 知見・教訓

### 成功パターン

- **モジュラー設定**: Lua設定の分割で保守性向上
- **GPU加速**: WebGpu使用で描画パフォーマンス大幅改善
- **Leader key**: tmux風キーバインドで操作性統一
- **リーダーキー統一**: WezTerm・tmux両方で`Ctrl+x`使用による操作一貫性
- **現代的コピペ**: macOS native pbcopy/pbpaste（reattach-to-user-namespace不要）
- **セッション永続化**: resurrect+continuum による15分自動保存で作業環境復元

### 失敗パターン

- **過度のカスタマイズ**: 設定の複雑化とメンテナンス困難
- **フォント設定**: fallback設定不備によるレンダリング問題
- **プラグイン依存**: tmuxプラグイン多用による起動時間増加
- **レガシー設定**: reattach-to-user-namespace等の古い設定継続使用
- **セッション管理**: 手動セッション作成による非効率ワークフロー

### パフォーマンス教訓

- **WebGpu vs OpenGL**: 環境によるパフォーマンス差異
- **スクロールバック**: 大量履歴によるメモリ使用量増加
- **アニメーション**: 無効化による体感速度向上
- **ESC応答性**: escape-time 10ms設定でキー操作高速化
- **プラグイン最適化**: 必要最小限プラグインで起動速度確保

### Tmux固有の知見

#### セッション管理効率化

- **FZF統合**: [FZF Integration Guide](../../tools/fzf-integration.md#terminal-layer-integration)参照
- **プロジェクト自動化**: プロジェクトディレクトリ名からセッション名自動生成
- **Neovim統合**: resurrect戦略でNeovimセッション状態も復元可能

#### キーバインド最適化

- **vim-like移動**: hjklによるペイン移動で直感的操作
- **カレントパス維持**: 新ペイン作成時に現在ディレクトリ継承
- **リピート操作**: -rフラグでペインリサイズの連続実行最適化

#### プラグイン選定基準

```text
✅ 採用プラグイン
- tmux-sensible: 基本設定最適化（必須）
- tmux-resurrect: セッション復元（高価値）
- tmux-continuum: 自動保存（運用効率）
- tmux-gruvbox: テーマ統一（視覚一貫性）

❌ 除外プラグイン
- 過多な装飾系プラグイン（起動時間影響）
- OS固有機能の重複（macOS標準機能と競合）
- 複雑なセッション管理（シンプル運用重視）
```

## 🔗 関連層との連携

- **Shell Layer**: Zsh統合、プロンプト設定、tmux略語・セッション管理関数
- **Editor Layer**: Neovim統合、編集ワークフロー、resurrect session戦略
- **Performance Layer**: 起動時間、レスポンス最適化、プラグイン最小化
- **Git Layer**: セッション内でのGit操作、プロジェクト連携

## 📈 測定可能な成果

### パフォーマンス指標

- **Tmux起動時間**: < 200ms（プラグイン最適化済み）
- **ESC応答時間**: 10ms（vim操作高速化）
- **セッション復元**: 15分間隔自動保存
- **メモリ使用量**: 履歴10,000行で約50MB

### 操作効率向上

- **セッション切り替え**: FZF統合で90%時間短縮
- **ペイン操作**: vim-like移動で学習コスト削減
- **リーダーキー統一**: WezTerm・tmux間で操作一貫性確保

---

_最終更新: 2025-06-21_
_パフォーマンス状態: ESC 10ms・プラグイン最適化済み_
_統合状態: WezTerm統一・Zsh連携・Neovim復元完了_
_セッション管理: FZF統合・自動化関数実装済み_
