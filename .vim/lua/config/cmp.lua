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
    expand = function(args)
      require("snippy").expand_snippet(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ["<Tab>"] = cmp.mapping.complete(),
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
    { name = "snippy" },
    { name = "copilot" },
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

cmp.setup.cmdline({ "/", "?" }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = "buffer" },
  },
})

cmp.setup.filetype("gitcommit", {
  sources = cmp.config.sources({
    { name = "cmp_git" },
  }, {
    { name = "buffer" },
  }),
})

vim.cmd [[
  set completeopt=menuone,noinsert,noselect
  highlight! default link CmpItemKind CmpItemMenuDefault
]]
