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

-- Force start ESLint for JavaScript/TypeScript files
utils.autocmd({ "FileType" }, {
  pattern = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  callback = function()
    -- Check if ESLint config exists
    local config_utils = require "core.utils"
    local config_files = require("lsp.config").formatters.eslint.config_files
    if config_utils.has_config_files(config_files) then
      -- Wait a bit for LSP to initialize, then check if ESLint is running
      vim.defer_fn(function()
        local eslint_clients = vim.tbl_filter(function(client)
          return client.name == "eslint"
        end, vim.lsp.get_clients { bufnr = 0 })

        if #eslint_clients == 0 then
          -- Start ESLint manually if not running
          vim.cmd "LspStart eslint"
        end
      end, 100)
    end
  end,
})

-- Highlight on yank
utils.autocmd("TextYankPost", {
  pattern = "*",
  callback = function()
    vim.highlight.on_yank { timeout = 300 }
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
utils.autocmd("BufReadPre", {
  pattern = "*",
  callback = function(args)
    local bufname = vim.api.nvim_buf_get_name(args.buf)
    if bufname:match "^%a+://" then
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
      vim.notify(
        string.format("[LSP] Failed to get client with id %d (client may have been stopped)", client_id),
        vim.log.levels.WARN
      )
      return
    end

    -- Skip duplicate processing (modern LSP handles this automatically)
    -- Client attachment is now handled by the LSP system itself

    -- クライアント停止判定を削除（すべてのLSPを起動させる）
    -- フォーマット時にどのクライアントを使うかは、formatter.luaで制御

    -- Lazy load LSP modules when LSP actually attaches
    require("lsp/keymaps").setup(client, bufnr)
    require("lsp/formatter").setup(bufnr, client, args)
    require("lsp/highlight").setup(client)
  end,
})

return M
