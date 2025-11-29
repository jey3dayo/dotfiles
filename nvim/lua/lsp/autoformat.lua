-- 自動フォーマットの状態を管理するグローバル変数
local utils = require "core.utils"
local config = require "lsp.config"
local state_keys = config.format.state

local function is_global_disabled()
  return vim.g[state_keys.global] == true
end

local function is_buffer_disabled(bufnr)
  return vim.b[bufnr or 0][state_keys.buffer] == true
end

-- 外部から参照できる状態チェック
local function set_state(scope, disabled)
  if scope == "buffer" then
    vim.b[0][state_keys.buffer] = disabled
    return
  end

  vim.g[state_keys.global] = disabled
end

local M = {}

function M.is_enabled(bufnr)
  return not (is_global_disabled() or is_buffer_disabled(bufnr))
end

function M.state(bufnr)
  return {
    global_disabled = is_global_disabled(),
    buffer_disabled = is_buffer_disabled(bufnr),
  }
end

-- 自動フォーマットを無効化するコマンドを登録
utils.user_command("AutoFormatDisable", function(args)
  local scope = args.bang and "global" or "buffer"
  set_state(scope, true)
end, {
  desc = "自動フォーマットを無効化（!でグローバル）",
  bang = true,
})

-- 自動フォーマットを有効化するコマンドを登録
utils.user_command("AutoFormatEnable", function()
  set_state("buffer", false)
  set_state("global", false)
end, {
  desc = "自動フォーマットを有効化",
})

return M
