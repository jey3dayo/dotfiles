-- Dial.nvim configuration (replacement for increment-activator)
-- Based on previous increment-activator configuration

local augend = require "dial.augend"

-- Define base configurations
local common_candidates = {
  augend.constant.new {
    elements = { "info", "warning", "notice", "error", "success" },
    word = true,
    cyclic = true,
  },
  augend.constant.new {
    elements = { "mini", "small", "medium", "large", "xlarge", "xxlarge" },
    word = true,
    cyclic = true,
  },
  augend.constant.new {
    elements = { "static", "absolute", "relative", "fixed", "sticky" },
    word = true,
    cyclic = true,
  },
  augend.constant.new {
    elements = { "height", "width" },
    word = true,
    cyclic = true,
  },
  augend.constant.new {
    elements = { "left", "right", "top", "bottom" },
    word = true,
    cyclic = true,
  },
  augend.constant.new {
    elements = { "true", "false" },
    word = true,
    cyclic = true,
  },
  augend.constant.new {
    elements = { "enable", "disable" },
    word = true,
    cyclic = true,
  },
  augend.constant.new {
    elements = { "enabled", "disabled" },
    word = true,
    cyclic = true,
  },
  augend.constant.new {
    elements = { "should", "should_not" },
    word = true,
    cyclic = true,
  },
  augend.constant.new {
    elements = { "be_file", "be_directory" },
    word = true,
    cyclic = true,
  },
  augend.constant.new {
    elements = { "div", "span", "Box" },
    word = true,
    cyclic = true,
  },
  augend.constant.new {
    elements = { "column", "row" },
    word = true,
    cyclic = true,
  },
  augend.constant.new {
    elements = { "start", "end" },
    word = true,
    cyclic = true,
  },
  augend.constant.new {
    elements = { "before", "after" },
    word = true,
    cyclic = true,
  },
  augend.constant.new {
    elements = { "head", "tail" },
    word = true,
    cyclic = true,
  },
  augend.constant.new {
    elements = { "get", "post" },
    word = true,
    cyclic = true,
  },
  augend.constant.new {
    elements = { "margin", "padding" },
    word = true,
    cyclic = true,
  },
  augend.constant.new {
    elements = { "primary", "secondary", "tertiary" },
    word = true,
    cyclic = true,
  },
  augend.constant.new {
    elements = { "development", "staging", "production" },
    word = true,
    cyclic = true,
  },
  augend.constant.new {
    elements = { "const", "let" },
    word = true,
    cyclic = true,
  },
  augend.constant.new {
    elements = { "dark", "medium", "light" },
    word = true,
    cyclic = true,
  },
  augend.constant.new {
    elements = { "sm", "md", "lg", "xl", "xxl" },
    word = true,
    cyclic = true,
  },
  augend.constant.new {
    elements = { "50", "100", "200", "300", "400", "500", "600", "700", "800", "900", "950" },
    word = true,
    cyclic = true,
  },
  augend.constant.new {
    elements = { "slate", "gray", "zinc", "neutral", "stone" },
    word = true,
    cyclic = true,
  },
  augend.constant.new {
    elements = {
      "red",
      "orange",
      "amber",
      "yellow",
      "lime",
      "green",
      "emerald",
      "teal",
      "cyan",
      "sky",
      "blue",
      "indigo",
      "violet",
      "purple",
      "fuchsia",
      "pink",
      "rose",
    },
    word = true,
    cyclic = true,
  },
}

-- Default configuration (includes numbers, dates, etc.)
local default_config = {
  augend.integer.alias.decimal,
  augend.integer.alias.hex,
  augend.date.alias["%Y/%m/%d"],
  augend.date.alias["%Y-%m-%d"],
  augend.date.alias["%m/%d/%Y"],
  augend.date.alias["%d/%m/%Y"],
  augend.date.alias["%H:%M:%S"],
  augend.date.alias["%H:%M"],
  augend.constant.alias.bool,
  augend.constant.alias.alpha,
  augend.constant.alias.Alpha,
  augend.semver.alias.semver,
}

-- Merge common candidates with default
for _, candidate in ipairs(common_candidates) do
  table.insert(default_config, candidate)
end

-- Filetype-specific configurations
local ruby_config = vim.deepcopy(default_config)
vim.list_extend(ruby_config, {
  augend.constant.new {
    elements = { "if", "unless" },
    word = true,
    cyclic = true,
  },
  augend.constant.new {
    elements = { "nil", "empty", "blank" },
    word = true,
    cyclic = true,
  },
  augend.constant.new {
    elements = { "string", "text", "integer", "float", "datetime", "timestamp" },
    word = true,
    cyclic = true,
  },
})

local javascript_config = vim.deepcopy(default_config)
vim.list_extend(javascript_config, {
  augend.constant.new {
    elements = { "props", "state" },
    word = true,
    cyclic = true,
  },
})

local typescript_config = vim.deepcopy(default_config)
vim.list_extend(typescript_config, {
  augend.constant.new {
    elements = { "string", "number", "boolean", "null", "undefined", "unknown", "Error" },
    word = true,
    cyclic = true,
  },
  augend.constant.new {
    elements = { "void", "never" },
    word = true,
    cyclic = true,
  },
  augend.constant.new {
    elements = { "andThen", "asyncAndThen" },
    word = true,
    cyclic = true,
  },
  augend.constant.new {
    elements = { "err", "errAsync" },
    word = true,
    cyclic = true,
  },
  augend.constant.new {
    elements = { "ok", "okAsync" },
    word = true,
    cyclic = true,
  },
})

local git_rebase_config = vim.deepcopy(default_config)
vim.list_extend(git_rebase_config, {
  augend.constant.new {
    elements = { "pick", "reword", "edit", "squash", "fixup", "exec" },
    word = true,
    cyclic = true,
  },
})

-- Setup dial with configurations
require("dial.config").augends:register_group {
  default = default_config,
  ruby = ruby_config,
  javascript = javascript_config,
  typescript = typescript_config,
  ["git-rebase-todo"] = git_rebase_config,
}

-- Cache dial.map to avoid repeated require calls
local dial_map = nil
local function get_dial_map()
  if not dial_map then
    dial_map = require("dial.map")
  end
  return dial_map
end

-- Set up keymaps
vim.keymap.set("n", "<C-a>", function()
  get_dial_map().manipulate("increment", "normal")
end, { desc = "Increment" })

vim.keymap.set("n", "<C-x>", function()
  get_dial_map().manipulate("decrement", "normal")
end, { desc = "Decrement" })

vim.keymap.set("n", "g<C-a>", function()
  get_dial_map().manipulate("increment", "gnormal")
end, { desc = "Increment (global)" })

vim.keymap.set("n", "g<C-x>", function()
  get_dial_map().manipulate("decrement", "gnormal")
end, { desc = "Decrement (global)" })

vim.keymap.set("v", "<C-a>", function()
  get_dial_map().manipulate("increment", "visual")
end, { desc = "Increment (visual)" })

vim.keymap.set("v", "<C-x>", function()
  get_dial_map().manipulate("decrement", "visual")
end, { desc = "Decrement (visual)" })

vim.keymap.set("v", "g<C-a>", function()
  get_dial_map().manipulate("increment", "gvisual")
end, { desc = "Increment (global visual)" })

vim.keymap.set("v", "g<C-x>", function()
  get_dial_map().manipulate("decrement", "gvisual")
end, { desc = "Decrement (global visual)" })

-- Filetype-specific configurations
local augroup = vim.api.nvim_create_augroup("DialConfig", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = { "ruby" },
  callback = function()
    vim.keymap.set("n", "<C-a>", function()
      get_dial_map().manipulate("increment", "normal", "ruby")
    end, { buffer = true, desc = "Increment (Ruby)" })

    vim.keymap.set("n", "<C-x>", function()
      get_dial_map().manipulate("decrement", "normal", "ruby")
    end, { buffer = true, desc = "Decrement (Ruby)" })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = { "javascript", "javascriptreact" },
  callback = function()
    vim.keymap.set("n", "<C-a>", function()
      get_dial_map().manipulate("increment", "normal", "javascript")
    end, { buffer = true, desc = "Increment (JavaScript)" })

    vim.keymap.set("n", "<C-x>", function()
      get_dial_map().manipulate("decrement", "normal", "javascript")
    end, { buffer = true, desc = "Decrement (JavaScript)" })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = { "typescript", "typescriptreact" },
  callback = function()
    vim.keymap.set("n", "<C-a>", function()
      get_dial_map().manipulate("increment", "normal", "typescript")
    end, { buffer = true, desc = "Increment (TypeScript)" })

    vim.keymap.set("n", "<C-x>", function()
      get_dial_map().manipulate("decrement", "normal", "typescript")
    end, { buffer = true, desc = "Decrement (TypeScript)" })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = { "git-rebase-todo" },
  callback = function()
    vim.keymap.set("n", "<C-a>", function()
      get_dial_map().manipulate("increment", "normal", "git-rebase-todo")
    end, { buffer = true, desc = "Increment (Git rebase)" })

    vim.keymap.set("n", "<C-x>", function()
      get_dial_map().manipulate("decrement", "normal", "git-rebase-todo")
    end, { buffer = true, desc = "Decrement (Git rebase)" })
  end,
})
