# 🖥️ WezTerm Configuration

**最終更新**: 2025-10-17
**対象**: 開発者
**タグ**: `category/terminal`, `tool/wezterm`, `layer/tool`, `environment/macos`, `audience/developer`

GPU加速対応のLuaベースモジュラーターミナル設定です。

## 主要機能

- **パフォーマンス**: WebGpu GPU加速
- **UI**: Gruvboxテーマ、92%透明度、カスタムタブスタイル
- **多重化**: Tmuxスタイルリーダーキー（`Ctrl+x`）
- **コピーモード**: Vim風ナビゲーション・テキスト選択

## 設定構造

```text
wezterm/
├── wezterm.lua          # メインエントリポイント
├── keybinds.lua         # キーバインド（13KB）
├── ui.lua               # ビジュアルテーマ
├── events.lua           # イベント処理
├── utils.lua            # ユーティリティ関数
├── os.lua               # プラットフォーム検出
└── win.lua              # Windows/WSL設定
```

## 主要キーバインド

### リーダーキー: `Ctrl+x`

```lua
Ctrl+x c               -- 新タブ
Ctrl+x n/p             -- 次/前のタブ
Ctrl+x &               -- タブ閉じる
Ctrl+x |               -- 水平分割
Ctrl+x -               -- 垂直分割
Ctrl+x z               -- ペイン拡大
Ctrl+x x               -- ペイン閉じる
```

### コピーモード: `Ctrl+x [`

```lua
h/j/k/l                -- ナビゲーション
w/b/e                  -- 単語移動
^/$                    -- 行頭/末尾
v/V                    -- 選択/行選択
y/yy                   -- コピー（選択/行）
q/Escape               -- 終了
```

### 直接バインド

```lua
Alt+Tab                -- タブ切り替え
Alt+h/j/k/l            -- ペインナビゲーション
Alt+Shift+Ctrl+h/j/k/l -- ペインリサイズ
Ctrl+plus/minus        -- フォントサイズ
```

## コア設定

### パフォーマンス

```lua
-- GPU加速
front_end = "WebGpu"
webgpu_power_preference = "HighPerformance"

-- フォント最適化
font = "UDEV Gothic 35NFLG"
font_size = 16.0
```

### ビジュアルテーマ

```lua
color_scheme = "Gruvbox Dark"
window_background_opacity = 0.92
tab_bar_at_bottom = true
use_fancy_tab_bar = false
```

### プラットフォーム検出

```lua
-- Windows/macOS設定自動切り替え
local is_windows = utils.is_windows()
local config = {}

if is_windows then
    config.default_domain = "WSL:Ubuntu"
end
```

## 統合機能

- **統一テーマ**: 他dotfilesツールとのGruvbox統一
- **透明背景**: Tmux・シェルとのシームレス統合
- **GPU最適化**: 高速描画・低レイテンシー操作
- **クロスプラットフォーム**: macOS/Windows/Linux対応

## トラブルシューティング

```bash
# GPU サポート確認
wezterm ls-fonts --list-system

# パフォーマンスデバッグ（ソフトウェア描画）
wezterm start --config 'front_end="Software"'

# 設定リセット
mv ~/.config/wezterm ~/.config/wezterm.backup
```

## メンテナンス

```bash
# WezTerm 更新
brew upgrade wezterm

# 設定チェック
wezterm check
```

---

## 概要

GPU加速とLua設定による高性能ターミナル環境
