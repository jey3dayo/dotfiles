-- 自動フォーマットの状態を管理するグローバル変数
local config = require("lsp.config")

vim.g[config.format.state.global] = false

-- 自動フォーマットの状態を設定する関数
local function set_autoformat_state(scope, state)
  if type(state) ~= "boolean" then
    return
  end

  if scope == "buffer" then
    vim.b[config.format.state.global] = state
  else
    vim.g[config.format.state.global] = state
  end
end

-- 自動フォーマットを無効化するコマンドを登録
user_command("AutoFormatDisable", function(args)
  local scope = args.bang and "buffer" or "global"
  set_autoformat_state(scope, true)
end, {
  desc = "自動フォーマットを無効化",
  bang = true,
})

-- 自動フォーマットを有効化するコマンドを登録
user_command("AutoFormatEnable", function()
  set_autoformat_state("buffer", false)
  set_autoformat_state("global", false)
end, {
  desc = "自動フォーマットを有効化",
})
