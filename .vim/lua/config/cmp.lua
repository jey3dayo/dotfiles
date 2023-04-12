local status1, cmp = pcall(require, "cmp")
if not status1 then
  return
end

local status2, lspkind = pcall(require, "lspkind")
if not status2 then
  return
end

cmp.setup {
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ["<C-d>"] = cmp.mapping.scroll_docs( -4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-e>"] = cmp.mapping.close(),
    ["<C-k>"] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ["<CR>"] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = false,
    },
  },
  sources = cmp.config.sources {
    { name = "copilot" },
    { name = "vsnip",    group_index = 2,   keyword_length = 2 },
    { name = "nvim_lsp", group_index = 2,   keyword_length = 2 },
    { name = "path",     group_index = 2,   keyword_length = 3 },
    { name = "buffer",   keyword_length = 3 },
    { name = "cmdline" },
  },
  formatters = {
    insert_text = require("copilot_cmp.format").remove_existing,
  },
  formatting = {
    format = lspkind.cmp_format {
      mode = "symbol",
      max_width = 50,
      symbol_map = { Copilot = "" },
    },
  },
}

cmp.setup.cmdline(":", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = "path" },
    { name = "cmdline" },
  },
})

vim.cmd [[
  set completeopt=menuone,noinsert,noselect
  highlight! default link CmpItemKind CmpItemMenuDefault
]]
