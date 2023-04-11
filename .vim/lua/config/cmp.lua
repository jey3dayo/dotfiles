local status1, cmp = pcall(require, "cmp")
if not status1 then
  return
end

local status2, lspkind = pcall(require, "lspkind")
if not status2 then
  return
end

-- local luasnip = require "luasnip"

local status3, copilot_cmp = pcall(require, "copilot_cmp")
if not status3 then
  return
end

copilot_cmp.setup()

cmp.setup {
  snippet = {
    expand = function(args)
      -- luasnip.lsp_expand(args.body)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-e>"] = cmp.mapping.close(),
    ["<C-k>"] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ["<CR>"] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
  },
  sources = cmp.config.sources {
    -- { name = "copilot",  group_index = 2 },
    { name = "copilot" },
    { name = "nvim_lsp", group_index = 2,   keyword_length = 2 },
    { name = "path",     group_index = 2,   keyword_length = 3 },
    { name = "vsnip",    group_index = 2,   keyword_length = 2 },
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

vim.cmd [[
  set completeopt=menuone,noinsert,noselect
  highlight! default link CmpItemKind CmpItemMenuDefault
]]
