# 🖥️ WezTerm Configuration

最終更新: 2026-09-23
対象: 開発者
タグ: `category/terminal`, `tool/wezterm`, `layer/tool`, `environment/macos`, `audience/developer`

GPU加速対応のLuaベースモジュラーターミナル設定です。

## 🤖 Claude Rules

このドキュメントの凝縮版ルールは [`.claude/rules/tools/wezterm.md`](../../.claude/rules/tools/wezterm.md) で管理されています。

- 目的: Claude AIが常に参照する簡潔なルール
- 適用範囲: YAML frontmatter `paths:` で定義
- 関係: 本ドキュメントが詳細リファレンス（SST）、Claudeルールが強制版

## 主要機能

- パフォーマンス: OpenGL フロントエンド（`max_fps = 60`）
- UI: Gruvboxテーマ、92%透明度、カスタムタブスタイル
- 多重化: Tmuxスタイルリーダーキー（`Ctrl+x`）
- コピーモード: Vim風ナビゲーション・テキスト選択

## 設定構造

```text
wezterm/
├── wezterm.lua          # エントリポイント（config.lua を require）
├── config.lua           # ベース設定・各モジュールのマージ
├── constants.lua        # 色・フォント・ウィンドウ等の定数
├── keybinds.lua         # キーバインド
├── key_tables.lua        # resize/copy/search の key table
├── ui.lua               # ビジュアルテーマ
├── events.lua           # イベント処理（タブ描画・resize・opacity）
├── utils.lua            # ユーティリティ関数
├── os.lua               # プラットフォーム検出
└── win.lua              # Windows/WSL設定
```

## 主要キーバインド

### リーダーキー: `Ctrl+x`

```lua
Ctrl+x c               -- 新タブ
Ctrl+x n/p             -- 次/前のタブ
Cmd+w                  -- タブ閉じる（確認あり）
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
/                      -- 検索
n/N                    -- 次/前の一致
q/Escape               -- 終了
```

### 直接バインド

```lua
Alt+Tab / Alt+Shift+Tab -- タブ切り替え（順/逆）
Alt+h/j/k/l             -- ペインナビゲーション
Alt+Shift+Ctrl+h/j/k/l  -- ペインリサイズ
Ctrl+plus/minus         -- フォントサイズ
Cmd/Ctrl+Click          -- リンクを開く
```

### リサイズモード: `Alt+r`

`resize_pane` key table に入る（timeout 3000ms、one-shot ではない）。

```lua
h/j/k/l                -- ペインリサイズ（1マス）
+/-/0                  -- 透明度を上げる/下げる/リセット（0.05刻み、0.1〜1.0）
Escape/q/Ctrl+c         -- 終了
```

## コア設定

### パフォーマンス

```lua
-- 描画（config.lua）
front_end = "OpenGL"
max_fps = 60

-- フォント最適化
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
-- os.lua: target_triple で Windows/macOS を判定
local is_windows = wezterm.target_triple == "x86_64-pc-windows-msvc"

-- Windows の場合のみ win.lua を適用（default_domain = "WSL:Ubuntu" など）
return is_windows and win or {}
```

## 統合機能

- テーマ: Gruvbox系配色（WezTerm・Alacritty）。Neovimは`0x96f`、tmuxのgruvboxテーマは未適用（コメントアウト）のため全ツール統一はしていない
- 透明背景: Tmux・シェルとのシームレス統合
- GPU最適化: 高速描画・低レイテンシー操作
- クロスプラットフォーム: macOS/Windows/Linux対応

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
```

---

## 概要

GPU加速とLua設定による高性能ターミナル環境
