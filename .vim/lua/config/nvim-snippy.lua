local snippy = require "snippy"

snippy.setup {
  mappings = {
    is = {
      ["<C-k>"] = "expand_or_advance",
      ["<Tab>"] = "expand_or_advance",
      ["<S-Tab>"] = "previous",
    },
  },
}

-- Insert mode snippy completion mapping - '<Control-s>'
vim.keymap.set("i", "<C-s>", function()
  snippy.complete()
end, { silent = true })
