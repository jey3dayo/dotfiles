# WezTerm設定 知見・学習事項

## アーキテクチャ設計

### モジュラーLua設定

#### ファイル構成
```
wezterm/
├── wezterm.lua      # メイン設定ファイル
├── ui.lua           # UI・テーマ設定
├── keybinds.lua     # キーバインド設定
└── utils.lua        # ユーティリティ関数
```

#### モジュール読み込みパターン
```lua
-- wezterm.lua メインパターン
local wezterm = require 'wezterm'
local ui = require 'ui'
local keybinds = require 'keybinds'

local config = wezterm.config_builder()
ui.apply_to_config(config)
keybinds.apply_to_config(config)
return config
```

## UI・テーマ設定

### Gruvbox テーマ統一
```lua
-- カラーパレット統一パターン
config.color_scheme = 'Gruvbox dark, medium (base16)'
config.window_background_opacity = 0.92
```

### フォント設定
```lua
-- UDEV Gothic + Nerd Font パターン
config.font = wezterm.font_with_fallback {
    'UDEV Gothic 35NFLG',
    'JetBrains Mono',
    'Symbols Nerd Font Mono',
}
config.font_size = 16.0
```

### ウィンドウ・タブ設定
```lua
-- タブスタイル設定
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.show_new_tab_button_in_tab_bar = false

-- ウィンドウ装飾
config.window_decorations = "RESIZE"
config.window_close_confirmation = "AlwaysPrompt"
```

## キーバインド設計

### Leader Key方式
```lua
-- tmux風 Leader Key (Ctrl+x)
local leader = 'CTRL|x'

-- パターン例
{
    key = 'c',
    mods = leader,
    action = wezterm.action.SpawnTab 'CurrentPaneDomain',
},
```

### 主要キーバインド

#### タブ・ペイン管理
- **Leader + c**: 新しいタブ作成
- **Leader + x**: タブ/ペイン終了
- **Leader + [1-9]**: タブ切り替え
- **Leader + \\"**: 縦分割
- **Leader + %**: 横分割

#### ナビゲーション
- **Alt + hjkl**: ペイン間移動
- **Alt + Tab**: タブ間移動
- **Leader + z**: ペインズーム

#### コピーモード
- **Leader + [**: コピーモード開始
- **hjkl**: カーソル移動
- **v/V**: 選択開始（文字/行）
- **y/yy**: コピー（選択/行）
- **/**: 検索

## プラットフォーム対応

### クロスプラットフォーム設定
```lua
-- OS判定パターン
local is_windows = wezterm.target_triple == 'x86_64-pc-windows-msvc'
local is_macos = wezterm.target_triple == 'x86_64-apple-darwin'

if is_windows then
    -- Windows固有設定
    config.default_prog = { 'pwsh.exe', '-NoLogo' }
elseif is_macos then
    -- macOS固有設定
    config.default_prog = { '/bin/zsh', '-l' }
end
```

### WSL統合
```lua
-- WSL ドメイン設定
config.wsl_domains = {
    {
        name = 'WSL:Ubuntu',
        distribution = 'Ubuntu',
        default_cwd = '/home/username',
    },
}
```

## パフォーマンス最適化

### GPU加速設定
```lua
-- WebGpu バックエンド使用
config.webgpu_preferred_adapter = {
    backend = 'Vulkan',
    device_type = 'DiscreteGpu',
    vendor_id = 0x10de, -- NVIDIA
}

-- フレームレート制限
config.max_fps = 120
```

### メモリ最適化
```lua
-- スクロールバック制限
config.scrollback_lines = 10000

-- 画像プロバイダー最適化
config.enable_kitty_graphics = true
```

## 高度な機能

### イベントハンドリング
```lua
-- タブタイトル動的変更
wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
    local title = tab.active_pane.title
    if title and #title > 0 then
        return string.format(' %s ', title)
    end
    return string.format(' %d ', tab.tab_index + 1)
end)
```

### 条件分岐処理
```lua
-- ワークスペース別設定
wezterm.on('update-right-status', function(window, pane)
    local workspace = window:active_workspace()
    window:set_right_status(workspace .. ' ')
end)
```

## 統合機能

### Zsh統合
- **共通テーマ**: Gruvbox カラーパレット統一
- **キーバインド**: vi風操作の一貫性
- **フォント**: Nerd Font統一

### Tmux風操作
- **Leader Key**: Ctrl+x でTmux風操作
- **ペイン管理**: 分割・移動・リサイズ
- **セッション**: ワークスペース機能

### 開発ワークフロー
- **Git統合**: カラー表示・差分表示
- **ログ表示**: 構文ハイライト
- **ファイル監視**: tail -f等の最適化

## デバッグ・トラブルシューティング

### 設定診断
```lua
-- デバッグ情報表示
wezterm.log_info('Debug message')

-- 設定検証
config.debug_key_events = true
```

### パフォーマンス診断
- **GPU使用状況**: タスクマネージャー等で確認
- **メモリ使用量**: プロセス監視
- **フレームレート**: fps表示機能

## よく使用するパターン

### 設定分岐パターン
```lua
-- 機能有効化条件分岐
if wezterm.gui then
    -- GUI固有設定
    config.window_background_opacity = 0.92
else
    -- CLI環境設定
end
```

### 動的設定パターン
```lua
-- 時間帯別テーマ
local function get_appearance()
    if wezterm.gui then
        return wezterm.gui.get_appearance()
    end
    return 'Dark'
end

if get_appearance():find 'Dark' then
    config.color_scheme = 'Gruvbox dark, medium (base16)'
else
    config.color_scheme = 'Gruvbox light, medium (base16)'
end
```

## 学習した回避すべきパターン

### アンチパターン
1. **巨大な単一設定ファイル**: 保守性悪化
2. **重複キーバインド**: 操作混乱
3. **過度な透明度**: 視認性低下
4. **未最適化GPU設定**: パフォーマンス低下

### 改善済み問題
- **設定ファイル分散**: モジュラー構成で解決
- **プラットフォーム依存**: 条件分岐で解決
- **キーバインド重複**: Leader Key方式で解決

## 設定管理のベストプラクティス

### バージョン管理
- **Git管理**: 設定変更履歴の追跡
- **コメント**: 設定理由の記録
- **モジュール化**: 機能別の分離

### テスト方法
- **段階的適用**: 小さな変更から適用
- **バックアップ**: 既存設定の保持
- **検証**: 各機能の動作確認

## パフォーマンス指標

### 現在の状況
- **起動時間**: 高速起動達成
- **GPU使用率**: 効率的なレンダリング
- **メモリ使用量**: 適正範囲内

### 将来の改善計画
- **更なる最適化**: GPU設定の調整
- **機能拡張**: より高度な統合機能
- **ワークフロー改善**: 開発体験の向上

---

*Last Updated: 2025-06-14*
*Status: 安定稼働中・機能拡張継続*