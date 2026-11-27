---
type: reference
title: Karabiner-Elements Configuration
description: macOS 向け Karabiner-Elements のルール構成、デバイス別設定、リーダーキー実装パターン
resource: docs/tools/karabiner.md
tags:
  - category/configuration
  - layer/tool
  - tool/karabiner
  - environment/macos
  - audience/developer
timestamp: 2026-11-27
audience: developer
owner: dotfiles
---

# Karabiner-Elements Configuration

Karabiner-Elements による macOS キーバインド設定の正本です。すべての設定は [`karabiner/karabiner.json`](../../karabiner/karabiner.json) で管理し、プロファイルは「Default profile」のみを使用します。

Claude 向けの短いルールは [`.claude/rules/tools/karabiner.md`](../../.claude/rules/tools/karabiner.md) にあります。

## 現在のルール構成

### 1. コマンドキー単体押しによる英数 / かな切替（`complex_modifications`）

左右どちらの ⌘ キーを単体で押した際も、入力ソース（英数 / かな）をトグルで切り替えます。

### 2. デバイス別 `simple_modifications`

新しいキーボードを追加する際は、`profiles[0].devices[]` の該当デバイスへ既存デバイスと同じ英数 / かなキーの入れ替えを追加します。

- `international4` → `japanese_kana`
- `international5` → `japanese_eisuu`

`vendor_id` と `product_id` には、Karabiner-Elements EventViewer などで確認した実機の `identifiers` を指定してください。既存デバイスの値を流用してはいけません。

## リーダーキー実装パターン（参考）

tmux や `herdr` の `Ctrl+X` → `KEY` のような 2 段階プレフィックスを持たないアプリに対し、Karabiner でリーダーモードを後付けするための汎用パターンです。対象アプリを限定する場合は `frontmost_application_if` で絞り込みます。

- 変数（例: `xxx_leader`）を立ててリーダーモード ON を表現し、続くキー入力を任意の macOS ショートカットへ変換します。
- `to_delayed_action` には `to_if_canceled` を入れないでください。次のキーが押された瞬間に変数がリセットされ、後続キーのルールが条件不一致になります。タイムアウト解除用の `to_if_invoked` のみを使用します。

```json
{
  "description": "リーダーモード: <キー> → <ショートカット>",
  "type": "basic",
  "conditions": [
    {
      "type": "frontmost_application_if",
      "bundle_identifiers": ["^com\\.example\\.app$"]
    },
    { "type": "variable_if", "name": "xxx_leader", "value": 1 }
  ],
  "from": { "key_code": "<key>", "modifiers": { "optional": ["any"] } },
  "to": [
    { "set_variable": { "name": "xxx_leader", "value": 0 } },
    { "key_code": "<target_key>", "modifiers": ["<modifier>"] }
  ]
}
```

## 編集後の再読み込み

`karabiner/karabiner.json` を編集したあとは、次を実行すると設定が再読み込みされます。

```bash
touch ~/.config/karabiner/karabiner.json
```
