local utils = require "core.utils"
local M = {}

local clear_autocmds = vim.api.nvim_clear_autocmds
M.clear_autocmds = clear_autocmds

utils.autocmd("BufWritePre", { pattern = "*", command = 'let v:swapchoice = "o"' })

-- Remove whitespace on save
utils.autocmd("BufWritePre", { pattern = "*", command = ":%s/\\s\\+$//e" })

-- Don't auto commenting new lines
utils.autocmd("BufEnter", { pattern = "*", command = "set fo-=c fo-=r fo-=o" })

-- Restore cursor location when file is opened
utils.autocmd({ "BufReadPost" }, {
  pattern = { "*" },
  callback = function()
    vim.cmd 'silent! normal! g`"zv'
  end,
})

-- Highlight on yank
utils.autocmd("TextYankPost", {
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({ timeout = 300 })
  end,
})

-- Use relative line numbers in Visual mode
utils.autocmd("ModeChanged", {
  pattern = "*:[vV\x16]*",
  callback = function()
    vim.opt.relativenumber = true
  end,
})

utils.autocmd("ModeChanged", {
  pattern = "[vV\x16]*:*",
  callback = function()
    vim.opt.relativenumber = vim.o.number
  end,
})

-- make bg transparent
utils.autocmd("ColorScheme", {
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

-- Prevent LSP from attaching to non-file URI schemes (fugitive://, etc.)
utils.autocmd('BufReadPre', {
  pattern = '*',
  callback = function(args)
    local bufname = vim.api.nvim_buf_get_name(args.buf)
    if bufname:match('^%a+://') then
      vim.b[args.buf].lsp_disable = true -- tells lspconfig not to attach
    end
  end,
})

-- 競合するLSPがある場合、client.stop()をかける
-- ts_lsとbiomeが競合するので、ts_lsを止める等
local lsp_augroup = utils.augroup("LspFormatting", { clear = true })

utils.autocmd("LspAttach", {
  group = lsp_augroup,
  callback = function(args)
    vim.bo[args.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

    local bufnr = args.buf
    local client_id = args.data.client_id
    local client = vim.lsp.get_client_by_id(client_id)

    if not client then 
      vim.notify(string.format("[LSP] Failed to get client with id %d (client may have been stopped)", client_id), vim.log.levels.WARN)
      return 
    end

    -- Lazy load client manager when actually needed
    local client_manager = require "lsp/client_manager"

    -- 既に処理済みのチェック
    if client_manager.is_client_processed(args.data.client_id, bufnr) then return end
    client_manager.mark_client_processed(args.data.client_id, bufnr)

    -- クライアント停止判定を削除（すべてのLSPを起動させる）
    -- フォーマット時にどのクライアントを使うかは、formatter.luaで制御

    -- Lazy load LSP modules when LSP actually attaches
    require("lsp/keymaps").setup(client, bufnr)
    require("lsp/formatter").setup(bufnr, client, args)
    require("lsp/highlight").setup(client)
  end,
})

return M
