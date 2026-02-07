-- Optimized blink.cmp configuration for performance and snippet management
require("blink.cmp").setup {
  keymap = {
    preset = "default",
    ["<Tab>"] = {}, -- Disabled: override below with Supermaven priority
    ["<C-k>"] = { "accept", "snippet_forward", "fallback" },
  },

  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
    providers = {
      snippets = {
        score_offset = 100, -- High priority for snippets
        opts = {
          friendly_snippets = true,
          search_paths = { vim.fn.stdpath "config" .. "/snippets" },
        },
      },
    },
  },

  completion = {
    accept = {
      auto_brackets = { enabled = true },
    },
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 200,
    },
  },

  fuzzy = {
    implementation = "prefer_rust_with_warning",
    frecency = { enabled = true },
    use_proximity = true,
  },
}

-- Downgrade the noisy checkhealth warning about dynamic providers to info
local ok, health = pcall(require, "blink.cmp.health")
if ok and health.report_sources then
  local report_sources = health.report_sources
  function health.report_sources(...)
    local warn = vim.health.warn
    vim.health.warn = function(msg)
      if msg:find [[Some providers may show up as "disabled"]] then return vim.health.info(msg) end
      return warn(msg)
    end
    local result = report_sources(...)
    vim.health.warn = warn
    return result
  end
end

-- Tab key: Supermaven (AI) > blink.cmp (LSP) > default tab
vim.keymap.set("i", "<Tab>", function()
  local ok, supermaven = pcall(require, "supermaven-nvim.completion_preview")
  if ok and supermaven.has_suggestion() then
    supermaven.on_accept_suggestion()
    return
  end

  local blink = require "blink.cmp"
  if blink.is_visible() then
    blink.accept()
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
  end
end, { desc = "Accept Supermaven or blink.cmp" })
