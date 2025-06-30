local colors = require "config.lualine.colors"
local conditions = require "config.lualine.conditions"

local M = {}

-- Component factory functions
function M.create_mode_component(icon, padding_config)
  return {
    function()
      return icon or ""
    end,
    color = function()
      return { fg = colors.mode_color[vim.fn.mode()] }
    end,
    padding = padding_config or { right = 1 },
  }
end

function M.create_lsp_component(get_clients_fn, label, color_config)
  return {
    function()
      local bufnr = vim.api.nvim_get_current_buf()
      local clients = get_clients_fn(bufnr)
      return #clients > 0 and table.concat(clients, ",") or "N/A"
    end,
    icon = label,
    color = color_config,
  }
end

function M.create_separator(icon, color_config, padding_config)
  return {
    function()
      return icon
    end,
    color = color_config,
    padding = padding_config,
  }
end

-- Component definitions
M.left_components = {
  -- Mode indicator
  M.create_separator("▊", function()
    return { fg = colors.mode_color[vim.fn.mode()] }
  end, { left = 0, right = 1 }),
  M.create_mode_component "",

  -- File info
  {
    "filesize",
    cond = conditions.buffer_not_empty,
  },
  {
    "filename",
    path = 1, -- 0: filename only, 1: relative path, 2: absolute path
    cond = conditions.buffer_not_empty,
    color = { fg = colors.colors.primary, gui = "bold" },
  },

  -- Position
  { "location" },
  { "progress", color = { fg = colors.colors.fg, gui = "bold" } },

  -- Diagnostics
  {
    "diagnostics",
    sources = { "nvim_diagnostic" },
    symbols = { error = " ", warn = " ", info = " " },
    diagnostics_color = {
      color_error = { fg = colors.colors.red },
      color_warn = { fg = colors.colors.yellow },
      color_info = { fg = colors.colors.cyan },
    },
  },

  -- Center separator
  {
    function()
      return "%="
    end,
  },

  -- LSP info
  M.create_lsp_component(function(bufnr)
    return require("lsp.client_manager").get_all_lsp_client_names(bufnr)
  end, " LSP:", { fg = colors.colors.fg, gui = "bold" }),
  M.create_lsp_component(function(bufnr)
    return require("lsp.client_manager").get_lsp_client_names(bufnr)
  end, " Fmt:", { fg = colors.colors.orange, gui = "bold" }),
}

M.right_components = {
  -- Encoding
  {
    "o:encoding",
    fmt = string.upper,
    cond = conditions.hide_in_width,
    color = { fg = colors.colors.green, gui = "bold" },
  },

  -- File format
  {
    "fileformat",
    fmt = string.upper,
    icons_enabled = false,
    color = { fg = colors.colors.green, gui = "bold" },
  },

  -- Git info
  { "branch", icon = "", color = { fg = colors.colors.violet, gui = "bold" } },
  {
    "diff",
    symbols = { added = " ", modified = "󰝤 ", removed = " " },
    diff_color = {
      added = { fg = colors.colors.green },
      modified = { fg = colors.colors.orange },
      removed = { fg = colors.colors.red },
    },
    cond = conditions.hide_in_width,
  },

  -- End separator
  M.create_separator("▊", { fg = colors.colors.primary }, { left = 1 }),
}

return M
