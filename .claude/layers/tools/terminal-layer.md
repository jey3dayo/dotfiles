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

### 基本設定

```tmux
# ~/.tmux.conf
# リーダーキー設定
set -g prefix C-x
unbind C-b
bind C-x send-prefix

# 設定リロード
bind r source-file ~/.tmux.conf \; display-message "Config reloaded!"

# ペイン分割
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"

# ペイン移動 (vim-like)
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R
```

### プラグイン管理

```tmux
# TPM (Tmux Plugin Manager)
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'

# 自動保存・復元
set -g @continuum-restore 'on'
set -g @continuum-save-interval '15'

run '~/.tmux/plugins/tpm/tpm'
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

### シェル統合

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

# Tmux自動起動
if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
    tmux attach-session -t default || tmux new-session -s default
fi
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

### 失敗パターン
- **過度のカスタマイズ**: 設定の複雑化とメンテナンス困難
- **フォント設定**: fallback設定不備によるレンダリング問題
- **プラグイン依存**: tmuxプラグイン多用による起動時間増加

### パフォーマンス教訓
- **WebGpu vs OpenGL**: 環境によるパフォーマンス差異
- **スクロールバック**: 大量履歴によるメモリ使用量増加
- **アニメーション**: 無効化による体感速度向上

## 🔗 関連層との連携

- **Shell Layer**: Zsh統合、プロンプト設定
- **Editor Layer**: Neovim統合、編集ワークフロー
- **Performance Layer**: 起動時間、レスポンス最適化

---

*最終更新: 2025-06-20*
*パフォーマンス状態: WebGpu最適化済み*
*統合状態: シェル・エディタ統合完了*