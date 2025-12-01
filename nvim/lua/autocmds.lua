local utils = require "core.utils"

-- Initialize ftplugin loader (replaces individual ftplugin files)
require("core.ftplugin_loader").setup()

local base_group = utils.augroup("BaseAutocmds", { clear = true })

local function define_autocmd(event, opts)
  opts.group = opts.group or base_group
  utils.autocmd(event, opts)
end

local function define_autocmds(definitions)
  for _, definition in ipairs(definitions) do
    define_autocmd(definition.event, definition.opts)
  end
end

define_autocmds {
  {
    event = "BufWritePre",
    opts = {
      pattern = "*",
      command = 'let v:swapchoice = "o"',
      desc = "Prefer original swapfile on conflict",
    },
  },
  {
    event = "BufWritePre",
    opts = {
      pattern = "*",
      command = ":%s/\\s\\+$//e",
      desc = "Trim trailing whitespace",
    },
  },
  {
    event = "BufEnter",
    opts = {
      pattern = "*",
      command = "set fo-=c fo-=r fo-=o",
      desc = "Disable comment continuation",
    },
  },
  {
    event = "BufReadPost",
    opts = {
      pattern = "*",
      callback = function()
        vim.cmd 'silent! normal! g`"zv'
      end,
      desc = "Restore cursor position",
    },
  },
  {
    event = "FileType",
    opts = {
      pattern = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
      callback = function()
        local config_files = require("lsp.config").formatters.eslint.config_files
        if not utils.has_config_files(config_files) then return end

        -- Wait a bit for LSP to initialize, then check if ESLint is running
        vim.defer_fn(function()
          local eslint_clients = vim.tbl_filter(function(client)
            return client.name == "eslint"
          end, vim.lsp.get_clients { bufnr = 0 })

          if #eslint_clients == 0 then vim.cmd "LspStart eslint" end
        end, 100)
      end,
      desc = "Ensure ESLint attaches when config is present",
    },
  },
  {
    event = "TextYankPost",
    opts = {
      pattern = "*",
      callback = function()
        local on_yank = (vim.hl or vim.highlight).on_yank
        on_yank { timeout = 300 }
      end,
      desc = "Highlight on yank",
    },
  },
  {
    event = "ModeChanged",
    opts = {
      pattern = "*:[vV\x16]*",
      callback = function()
        vim.opt.relativenumber = true
      end,
      desc = "Use relative numbers in visual mode",
    },
  },
  {
    event = "ModeChanged",
    opts = {
      pattern = "[vV\x16]*:*",
      callback = function()
        vim.opt.relativenumber = vim.o.number
      end,
      desc = "Restore relative numbers after visual mode",
    },
  },
  {
    event = "ColorScheme",
    opts = {
      pattern = "*",
      callback = function()
        local hl_groups = {
          "Normal",
          "SignColumn",
          "NormalNC",
          "NvimTreeNormal",
          "EndOfBuffer",
          "MsgArea",
        }
        for _, name in ipairs(hl_groups) do
          vim.cmd(string.format("highlight %s ctermbg=none guibg=none", name))
        end
      end,
      desc = "Keep background transparent",
    },
  },
  {
    event = "BufReadPre",
    opts = {
      pattern = "*",
      callback = function(args)
        local bufname = vim.api.nvim_buf_get_name(args.buf)
        if bufname:match "^%a+://" then vim.b[args.buf].lsp_disable = true end
      end,
      desc = "Disable LSP for non-file buffers",
    },
  },
}

-- 競合するLSPがある場合、client.stop()をかける
-- TypeScript Toolsとbiomeが競合するので、TypeScript側を止める等
local lsp_augroup = utils.augroup("LspFormatting", { clear = true })

define_autocmd("LspAttach", {
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

    -- Lazy load LSP modules when LSP actually attaches
    require("lsp.keymaps").setup(client, bufnr)
    require("lsp.formatter").setup(bufnr, client, args)
    require("lsp.highlight").setup(client)
  end,
  desc = "Configure LSP buffer behavior",
})
