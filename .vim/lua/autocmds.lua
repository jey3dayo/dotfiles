local M = {}

local clear_autocmds = vim.api.nvim_clear_autocmds
M.clear_autocmds = clear_autocmds

autocmd("BufWritePre", { pattern = "*", command = 'let v:swapchoice = "o"' })

-- Remove whitespace on save
autocmd("BufWritePre", { pattern = "*", command = ":%s/\\s\\+$//e" })

-- Don't auto commenting new lines
autocmd("BufEnter", { pattern = "*", command = "set fo-=c fo-=r fo-=o" })

-- Restore cursor location when file is opened
autocmd({ "BufReadPost" }, {
  pattern = { "*" },
  callback = function()
    vim.cmd 'silent! normal! g`"zv'
  end,
})

-- make bg transparent
autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    local hl_groups = {
      "Normal",
      "SignColumn",
      "NormalNC",
      "TelescopeBorder",
      "NvimTreeNormal",
      "EndOfBuffer",
      "MsgArea",
      -- "NonText",
    }
    for _, name in ipairs(hl_groups) do
      vim.cmd(string.format("highlight %s ctermbg=none guibg=none", name))
    end
  end,
})

-- 競合するLSPがある場合、client.stop()をかける
-- ts_lsとbiomeが競合するので、ts_lsを止める等
local lsp_augroup = augroup("LspFormatting", { clear = true })
local client_manager = require "lsp/client_manager"

autocmd("LspAttach", {
  group = lsp_augroup,
  callback = function(args)
    vim.bo[args.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

    local bufnr = args.buf
    local client_id = args.data.client_id
    local client = vim.lsp.get_client_by_id(client_id)

    if not client then
      return
    end

    -- 既に処理済みのチェック
    if client_manager.is_client_processed(args.data.client_id, bufnr) then
      return
    end
    client_manager.mark_client_processed(args.data.client_id, bufnr)

    -- クライアント停止判定
    if client_manager.should_stop_client(client) then
      client.stop()
      return
    end

    require("lsp/keymaps").setup(bufnr, client)
    require("lsp/formatter").setup(bufnr, client, args)
    require("lsp/highlight").setup(client)
  end,
})

return M
