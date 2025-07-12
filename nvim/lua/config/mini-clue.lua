-- Mini clue configuration for enhanced key mapping hints
return {
  -- Clue triggers for different key prefixes
  triggers = {
    -- Leader key triggers
    { mode = "n", keys = "<Leader>" },
    { mode = "x", keys = "<Leader>" },

    -- Built-in completion
    { mode = "i", keys = "<C-x>" },

    -- `g` key triggers
    { mode = "n", keys = "g" },
    { mode = "x", keys = "g" },

    -- Marks
    { mode = "n", keys = "'" },
    { mode = "n", keys = "`" },
    { mode = "x", keys = "'" },
    { mode = "x", keys = "`" },

    -- Registers
    { mode = "n", keys = '"' },
    { mode = "x", keys = '"' },
    { mode = "i", keys = "<C-r>" },

    -- Window commands
    { mode = "n", keys = "<C-w>" },

    -- `z` key
    { mode = "n", keys = "z" },
    { mode = "x", keys = "z" },

    -- Tab operations
    { mode = "n", keys = "<C-t>" },

    -- Format operations
    { mode = "n", keys = "<C-e>" },

    -- Git operations (neogit-focused)
    { mode = "n", keys = "<C-g>" },

    -- Surround operations (mini.surround)
    { mode = "n", keys = "s" },
    { mode = "x", keys = "s" },

    -- Yank operations
    { mode = "n", keys = "Y" },
  },

  -- Custom clue groups for better organization
  clues = {
    -- Git operations help
    { mode = "n", keys = "<C-g><C-g>", desc = "Neogit Status" },
    { mode = "n", keys = "<C-g>s", desc = "Git Status" },
    { mode = "n", keys = "<C-g>c", desc = "Git Commit" },
    { mode = "n", keys = "<C-g>a", desc = "Stage All (use s in Neogit)" },
    { mode = "n", keys = "<C-g>b", desc = "Git Branches (use b in Neogit)" },
    { mode = "n", keys = "<C-g>l", desc = "Git Log (use l in Neogit)" },
    { mode = "n", keys = "<C-g>d", desc = "Diff View" },
    { mode = "n", keys = "<C-g>D", desc = "Close Diff" },
    { mode = "n", keys = "<C-g>z", desc = "Git Stash (use Z in Neogit)" },

    -- Tab operations
    { mode = "n", keys = "<C-t>c", desc = "New Tab" },
    { mode = "n", keys = "<C-t>d", desc = "Close Tab" },
    { mode = "n", keys = "<C-t>o", desc = "Split Tab" },
    { mode = "n", keys = "<C-t>n", desc = "Next Tab" },
    { mode = "n", keys = "<C-t>p", desc = "Previous Tab" },

    -- Format operations
    { mode = "n", keys = "<C-e>f", desc = "Auto Format" },
    { mode = "n", keys = "<C-e>b", desc = "Format w/ Biome" },
    { mode = "n", keys = "<C-e>p", desc = "Format w/ Prettier" },
    { mode = "n", keys = "<C-e>e", desc = "Format w/ ESLint" },
    { mode = "n", keys = "<C-e>s", desc = "Format w/ TypeScript" },

    -- Yank operations
    { mode = "n", keys = "Yf", desc = "Copy File Path" },
    { mode = "n", keys = "Yl", desc = "Copy Path:Line" },
    { mode = "n", keys = "YF", desc = "Copy Full Path" },
    { mode = "n", keys = "Yd", desc = "Copy Directory" },
    { mode = "n", keys = "YD", desc = "Copy Rel Directory" },
    { mode = "n", keys = "YY", desc = "Copy Buffer+Path" },

    -- Enhance Mini.nvim helpers
    require("mini.clue").gen_clues.builtin_completion(),
    require("mini.clue").gen_clues.g(),
    require("mini.clue").gen_clues.marks(),
    require("mini.clue").gen_clues.registers(),
    require("mini.clue").gen_clues.windows(),
    require("mini.clue").gen_clues.z(),
  },

  -- Window configuration
  window = {
    delay = 300, -- Show after 300ms
    config = {
      border = "rounded",
      width = "auto",
    },
  },
}
