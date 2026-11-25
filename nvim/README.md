# Neovim Configuration

カンマリーダー、Neovim 組み込みの `vim.pack`（遅延ロードは自前ローダー）をベースにした Lua 設定です。`blink.cmp` による補完、`mini.nvim` を中心とした編集環境、Mason 管理の LSP スタックを組み合わせています。

エントリポイントは [`init.lua`](init.lua) です。

詳細な設定構造・起動性能・LSP / プラグイン構成・キーバインドは [`docs/tools/nvim.md`](../docs/tools/nvim.md)（[検証](../docs/tools/nvim.md#検証)を含む）を正本として参照してください。Claude 向けの短いルールは [`.claude/rules/tools/nvim.md`](../.claude/rules/tools/nvim.md) にあります。
