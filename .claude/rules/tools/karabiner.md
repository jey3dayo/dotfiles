---
paths: karabiner/**/*
references: ghostty/config, tmux/keyconfig.conf
---

# Karabiner-Elements Rules

Purpose: Karabiner-Elements による macOS キーバインドカスタマイズ。
Scope: complex_modifications（C-x リーダーキー）、simple_modifications（デバイス別）。

## 管理ファイル

`karabiner/karabiner.json` — プロファイル「Default profile」のみ使用

## Complex Modifications ルール

### 1. C-x リーダーキー（cmux 向け）

cmux は macOS 標準ショートカット（⌘/⌃/⌥+key）のみサポートし、
2段階キーシーケンス不可。Karabiner で C-x リーダーを実装して補完する。

キーバインド設計の正典: `ghostty/config`（Ghostty と統一）
対象アプリ: `com.cmuxterm.app`

| Ctrl+X →     | 送信   | アクション                              |
| ------------ | ------ | --------------------------------------- |
| c            | ⌃X     | New Workspace                           |
| n            | ⌃⌘]    | 次の Workspace（タブ）へ                |
| p            | ⌃⌘[    | 前の Workspace（タブ）へ                |
| o            | ⌘⇧]    | 次の Surface（ペイン）へ                |
| 1〜8         | ⌃1〜⌃8 | タブ直接ジャンプ                        |
| \| (Shift+\) | ⌘D     | 右スプリット                            |
| -            | ⌘⇧D    | 下スプリット                            |
| z            | ⌘⇧↩    | ペインズーム切替                        |
| x            | ⌘W     | Surface を閉じる                        |
| h            | ⌥⌘←    | ペイン左へ                              |
| j            | ⌥⌘↓    | ペイン下へ                              |
| k            | ⌥⌘↑    | ペイン上へ                              |
| l            | ⌥⌘→    | ペイン右へ                              |
| ¥            | ⌘D     | Split Right（key_code: international3） |
| ,            | ⌘⇧R    | Workspace をリネーム（tmux 互換）       |
| r            | ⌘R     | ページリロード                          |
| /            | ⌘⇧P    | コマンドパレット                        |
| ESC          | —      | キャンセル                              |

#### 実装パターン（リーダーキー）

⚠️ `to_delayed_action` に `to_if_canceled` を入れてはいけない。
次キーが押された瞬間に変数がリセットされ、そのキーのルールが条件不一致になる。
`to_if_invoked`（タイムアウト）のみ使用すること。

### 2. コマンドキーで英数/かな切替

左右どちらの ⌘ を単体で押しても入力ソースをトグル。

## 新しいバインドの追加方法

`complex_modifications.rules[0].manipulators` に追加:

```json
{
  "description": "リーダーモード: <キー> → <ショートカット>",
  "type": "basic",
  "conditions": [
    {
      "type": "frontmost_application_if",
      "bundle_identifiers": ["^com\\.cmuxterm\\.app$"]
    },
    { "type": "variable_if", "name": "ctrl_x_leader", "value": 1 }
  ],
  "from": { "key_code": "<key>", "modifiers": { "optional": ["any"] } },
  "to": [
    { "set_variable": { "name": "ctrl_x_leader", "value": 0 } },
    { "key_code": "<target_key>", "modifiers": ["<modifier>"] }
  ]
}
```

編集後: `touch ~/.config/karabiner/karabiner.json` でリロード。

## 未実装バインド（要確認）

以下は `ghostty/config` に定義があるが cmux 対応ショートカット未確認のため未実装:

| Ctrl+X →    | ghostty アクション        | cmux 対応状況                     |
| ----------- | ------------------------- | --------------------------------- |
| Space       | ペイン均等化              | 要確認（cmux に機能があるか不明） |
| H (Shift+h) | ペインリサイズ左          | 要確認                            |
| J (Shift+j) | ペインリサイズ下          | 要確認                            |
| K (Shift+k) | ペインリサイズ上          | 要確認                            |
| L (Shift+l) | ペインリサイズ右          | 要確認                            |
| \           | 右スプリット（\| と同じ） | ⌘D（重複のため省略可）            |

確認後、対応するショートカットが判明したら「新しいバインドの追加方法」の手順で追加する。
