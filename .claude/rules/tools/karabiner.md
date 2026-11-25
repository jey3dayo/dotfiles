---
paths: karabiner/**/*
---

# Karabiner-Elements Rules

Purpose: Karabiner-Elements による macOS キーバインドカスタマイズ。Scope: `complex_modifications`（コマンドキー英数 / かなトグル）、`simple_modifications`（デバイス別）、リーダーキー実装の汎用パターン。

## 管理ファイル

- `karabiner/karabiner.json` — プロファイル「Default profile」のみを使用します。

## Complex Modifications ルール

### 1. コマンドキーで英数 / かな切替

左右どちらの ⌘ キーを単体で押しても入力ソースをトグルします。

### 2. デバイス別 `simple_modifications`

新しいキーボードを追加するときは、`profiles[0].devices[]` の該当デバイスへ既存デバイスと同じ英数 / かなキーの入れ替えを追加します。

- `international4` → `japanese_kana`
- `international5` → `japanese_eisuu`

`vendor_id` / `product_id` は Karabiner-Elements EventViewer などで確認した実機の `identifiers` を使い、既存デバイスの値を流用しないでください。

## リーダーキー実装パターン（参考）

tmux や herdr の `C-x KEY` のような 2 段階プレフィックスを持たないアプリに対し、Karabiner でリーダーモードを後付けする汎用手法です。対象アプリを限定する場合は `frontmost_application_if` で絞り込みます。

- 変数（例: `xxx_leader`）を立ててリーダーモード ON を表現し、次のキーで任意の macOS ショートカットへ変換します。
- `to_delayed_action` には `to_if_canceled` を入れないでください。次のキーが押された瞬間に変数がリセットされ、そのキーのルールが条件不一致になります。タイムアウト用の `to_if_invoked` のみ使用します。

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

## 編集後のリロード

`touch ~/.config/karabiner/karabiner.json` で設定が再読み込みされます。
