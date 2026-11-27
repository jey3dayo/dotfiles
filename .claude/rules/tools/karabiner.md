---
paths:
  - "karabiner/**/*"
  - "docs/tools/karabiner.md"
source: docs/tools/karabiner.md
---

# Karabiner-Elements Rules

Purpose: macOS の Karabiner-Elements 設定（`karabiner/karabiner.json`）における制約を維持する。
Detailed Reference: [docs/tools/karabiner.md](../../../docs/tools/karabiner.md)

## 要約と制約

- `karabiner/karabiner.json` のプロファイル「Default profile」のみを使用する。詳細なルール構成やリーダーキー実装パターンは `docs/tools/karabiner.md` を参照する。
- デバイス別の `simple_modifications`（`international4` → `japanese_kana`、`international5` → `japanese_eisuu`）を追加する際は、EventViewer 等で確認した実機の `vendor_id` / `product_id` を使い、既存デバイスの値を流用しない。
- リーダーキー実装の `to_delayed_action` には `to_if_canceled` を入れない（次のキー入力時に変数が即リセットされ条件不一致になるため、`to_if_invoked` のみを使う）。
- 編集後は `touch ~/.config/karabiner/karabiner.json` で設定を再読み込みする。
