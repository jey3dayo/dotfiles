---
paths: karabiner/**/*
---

# Karabiner-Elements Rules

Purpose: Karabiner-Elements による macOS キーバインドカスタマイズ。
Scope: complex_modifications（コマンドキー英数/かなトグル）、simple_modifications（デバイス別）、リーダーキー実装の汎用パターン。

## 管理ファイル

`karabiner/karabiner.json` — プロファイル「Default profile」のみ使用

## Complex Modifications ルール

### 1. コマンドキーで英数/かな切替

左右どちらの ⌘ を単体で押しても入力ソースをトグル。

### 2. デバイス別 simple_modifications

新しいキーボードを追加するときは、`profiles[0].devices[]` の該当 device に既存デバイスと同じ英数/かなキー入れ替えを追加する。

- `international4` → `japanese_kana`
- `international5` → `japanese_eisuu`

`vendor_id` / `product_id` は Karabiner-Elements EventViewer 等で確認した実機の `identifiers` を使い、既存デバイスの値を流用しない。

## リーダーキー実装パターン（参考）

tmux / Ghostty の `C-x KEY` のような 2 段階プレフィックスを持たないアプリに、Karabiner でリーダーモードを後付けする汎用手法。対象を限定したい場合は `frontmost_application_if` でアプリを絞る。

- 変数（例 `xxx_leader`）を立てて「リーダーモード ON」を表現し、次キーで任意の macOS ショートカットへ変換する
- ⚠️ `to_delayed_action` に `to_if_canceled` を入れてはいけない。次キーが押された瞬間に変数がリセットされ、そのキーのルールが条件不一致になる。`to_if_invoked`（タイムアウト）のみ使用する

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

> かつて cmux 向けに `C-x` リーダー（`com.cmuxterm.app` 限定）を実装していたが、cmux 廃止に伴い削除した。上記はその手法を汎用パターンとして残したもの。

## 編集後のリロード

`touch ~/.config/karabiner/karabiner.json` でリロードされる。
