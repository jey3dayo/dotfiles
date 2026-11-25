---
type: reference
title: WezTerm Configuration
description: WezTerm の Lua モジュール構成、キーバインド、外観設定、プラットフォーム分岐
resource: docs/tools/wezterm.md
tags:
  - category/terminal
  - layer/tool
  - tool/wezterm
  - environment/cross-platform
  - audience/developer
timestamp: 2026-11-25
audience: developer
owner: dotfiles
---

# WezTerm Configuration

GPU 加速に対応した、Lua ベースのモジュラー WezTerm 設定です。

Claude 向けの短いルールは [`.claude/rules/tools/wezterm.md`](../../.claude/rules/tools/wezterm.md) にあります。

## 主要機能

- パフォーマンス: OpenGL フロントエンド（`max_fps = 60`）
- UI: Gruvbox テーマ、92% 透明度、カスタムタブスタイル
- 多重化: tmux スタイルのリーダーキー（`Ctrl+x`）
- コピーモード: Vim 風のナビゲーションとテキスト選択

## 設定構造

```text
wezterm/
├── wezterm.lua          # エントリポイント（config.lua を require）
├── config.lua           # ベース設定と各モジュールのマージ
├── constants.lua        # 色・フォント・ウィンドウなどの定数
├── keybinds.lua         # キーバインド
├── key_tables.lua       # resize / copy / search の key table
├── ui.lua               # ビジュアルテーマ
├── events.lua           # イベント処理（タブ描画・resize・opacity）
├── utils.lua            # ユーティリティ関数
├── os.lua               # プラットフォーム検出
└── win.lua              # Windows / WSL 設定
```

## 主要キーバインド

### リーダーキー: `Ctrl+x`

```lua
Ctrl+x c               -- 新タブ
Ctrl+x n/p             -- 次 / 前のタブ
Cmd+w                  -- タブを閉じる（確認あり）
Ctrl+x |               -- 水平分割
Ctrl+x -               -- 垂直分割
Ctrl+x z               -- ペイン拡大
Ctrl+x x               -- ペインを閉じる
```

### コピーモード: `Ctrl+x [`

```lua
h/j/k/l                -- ナビゲーション
w/b/e                  -- 単語移動
^/$                    -- 行頭 / 行末
v/V                    -- 選択 / 行選択
y/yy                   -- コピー（選択範囲 / 行）
/                      -- 検索
n/N                    -- 次 / 前の一致
q/Escape               -- 終了
```

### 直接バインド

```lua
Alt+Tab / Alt+Shift+Tab -- タブ切り替え（順 / 逆）
Alt+h/j/k/l             -- ペインナビゲーション
Alt+Shift+Ctrl+h/j/k/l  -- ペインリサイズ
Ctrl+plus/minus         -- フォントサイズ変更
Cmd/Ctrl+Click          -- リンクを開く
```

### リサイズモード: `Alt+r`

`resize_pane` key table に入ります（timeout 3000ms、one-shot ではありません）。

```lua
h/j/k/l                -- ペインリサイズ（1 マス）
+/-/0                  -- 透明度を上げる / 下げる / リセット（0.05 刻み、0.1〜1.0）
Escape/q/Ctrl+c        -- 終了
```

## コア設定

### パフォーマンス

```lua
-- 描画（config.lua）
front_end = "OpenGL"
max_fps = 60

-- フォント設定（constants.lua / ui.lua）
font = "UDEV Gothic 35NFLG"
font_size = 16.0
```

### ビジュアルテーマ

```lua
color_scheme = "Gruvbox dark, hard (base16)"
window_background_opacity = 0.92
window_decorations = "RESIZE"
native_macos_fullscreen_mode = true
initial_cols = 180
initial_rows = 50
tab_bar_at_bottom = true
use_fancy_tab_bar = false
```

### プラットフォーム検出

```lua
-- os.lua: target_triple で Windows を判定
local is_windows = wezterm.target_triple == "x86_64-pc-windows-msvc"

-- Windows の場合のみ win.lua を適用（default_domain = "WSL:Ubuntu" など）
return is_windows and win or {}
```

## 統合機能

- テーマ: WezTerm と Alacritty は Gruvbox 系配色です。Neovim は `0x96f`、tmux の Gruvbox テーマは未適用（コメントアウト）のため、全ツールでの配色統一はしていません。
- 透明背景: tmux やシェルとシームレスに統合します。
- クロスプラットフォーム: macOS / Windows / Linux に対応しています。

## トラブルシューティング

```bash
# パフォーマンスデバッグ（ソフトウェア描画で起動）
wezterm start --config 'front_end="Software"'

# 設定の一時退避
mv ~/.config/wezterm ~/.config/wezterm.backup
```

## メンテナンス

```bash
# WezTerm 更新（Brewfile では cask "wezterm@nightly" を使用）
brew upgrade --cask --greedy-latest wezterm@nightly
```
