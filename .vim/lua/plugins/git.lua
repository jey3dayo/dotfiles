local deps = require("core.dependencies")

return {
  {
    "tpope/vim-fugitive",
    cmd = { "Gdiffsplit", "Ggrep", "Gstatus", "Gwrite", "Gcommit" },
    config = function()
      require("config/vim-fugitive")
    end,
  },
  {
    "sindrets/diffview.nvim",
    dependencies = deps.plenary,
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
    },
    opts = require("config/diffview"),
  },
  { "tpope/vim-rhubarb", cmd = { "GBrowse" }, dependencies = { "tpope/vim-fugitive" } },
  { "ruifm/gitlinker.nvim", keys = { "<leader>gy" }, dependencies = deps.plenary, config = true },
}
