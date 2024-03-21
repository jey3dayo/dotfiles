local cmp = safe_require "cmp"
local lspkind = safe_require "lspkind"

if not (cmp and lspkind) then
  return
end

local function has_words_before()
  if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
    return false
  end

  local cursor_position = vim.api.nvim_win_get_cursor(0)
  local line = cursor_position[1]
  local col = cursor_position[2]

  if col == 0 then
    return false
  end

  local line_text = vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]

  return line_text:match "^%s*$" == nil
end

cmp.setup {
  snippet = {
    expand = function(args)
      require("snippy").expand_snippet(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    -- ["<Tab>"] = cmp.mapping.complete(),
    ["<Tab>"] = vim.schedule_wrap(function(fallback)
      if cmp.visible() and has_words_before() then
        cmp.select_next_item { behavior = cmp.SelectBehavior.Select }
      else
        fallback()
      end
    end),
    ["<C-l>"] = cmp.mapping.complete(),
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
    { name = "treesitter" },
    { name = "nvim_lsp", group_index = 2, keyword_length = 2 },
    { name = "nvim_lsp_signature_help", group_index = 2, keyword_length = 2 },
    { name = "path", group_index = 2, keyword_length = 3 },
    { name = "buffer", keyword_length = 3 },
    { name = "cmdline" },
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
