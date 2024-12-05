local M = {}

local autocmd = vim.api.nvim_create_autocmd
M.autocmd = autocmd

local augroup = vim.api.nvim_create_augroup
M.augroup = augroup

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

local userLspConfig = augroup("UserLspConfig", { clear = true })

-- 競合するLSPがある場合、client.stop()をかける
-- ts_lsとbiomeが競合するので、ts_lsを止める等
autocmd("LspAttach", {
  group = userLspConfig,
  callback = function(args)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[args.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
    local client_id = args.data.client_id
    local client = vim.lsp.get_client_by_id(client_id)
    if not client then
      vim.notify(client_id .. " not found", vim.log.levels.WARN)
      return
    end

    require("lsp/handlers").setup_lsp_keymaps(args.bufnr, client)
    require("lsp/handlers").lsp_highlight_document(client)

    if client.supports_method "textDocument/formatting" then
      -- Format the current buffer on save
      autocmd("BufWritePre", {
        buffer = args.bufnr,
        callback = function()
          require("lsp/handlers").format_buffer(args.bufnr, client)
        end,
      })

      vim.api.nvim_create_user_command("Format", function()
        local id = args.data.client_id
        local c = vim.lsp.get_client_by_id(id)
        if not c then
          vim.notify(id .. " not found", vim.log.levels.WARN)
          return
        end

        require("lsp/handlers").format_buffer(args.bufnr, c)
      end, {})
    end
  end,
})

return M
