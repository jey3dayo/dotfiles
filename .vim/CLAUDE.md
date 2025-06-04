# Neovim設定リファクタリング計画

## 概要
この.vimプロジェクトは良く整理されたNeovim設定ですが、軽微な改善の余地があります。

## 改善項目

### 高優先度
1. **重複プラグイン定義の削除**
   - `lua/plugins/input.lua`内の`keaising/im-select.nvim`重複を解決

2. **共通定義の統合**
   - ファイルタイプ定義配列を共通モジュールに移動
   - 共通dependency配列の統一

### 中優先度
3. **設定読み込みパターンの統一**
   - `config = function() require "config/..." end`と`opts = require "config/..."`の使い分け基準明確化

4. **プラグイン分類の最適化**
   - `tool.lua`の細分化検討（git関連とterminal関連の分離）

## 対象ファイル
- `lua/plugins/input.lua` - 重複削除
- `lua/plugins/lang.lua` - 共通定義抽出
- `lua/utils/common.lua` - 共通モジュール作成（必要に応じて）

## 現状評価
✅ 優秀: 明確な機能分離、一貫した命名規則、適切なディレクトリ構造
🔧 改善: 軽微な重複除去、設定パターン統一

