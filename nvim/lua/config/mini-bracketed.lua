local M = {}

local function remove_yank_autocmds()
  for _, autocmd in
    ipairs(vim.api.nvim_get_autocmds {
      group = "MiniBracketed",
      event = "TextYankPost",
    })
  do
    vim.api.nvim_del_autocmd(autocmd.id)
  end
end

function M.setup()
  require("mini.bracketed").setup {
    file = { suffix = "" },
    window = { suffix = "" },
    quickfix = { suffix = "q" },
    yank = { suffix = "" },
    treesitter = { suffix = "t" },
  }

  remove_yank_autocmds()
end

return M
