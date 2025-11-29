-- Optimized blink.cmp configuration for performance and snippet management
require("blink.cmp").setup {
  keymap = {
    preset = "default",
    ["<C-k>"] = { "accept", "snippet_forward", "fallback" },
    ["<Tab>"] = { "accept", "snippet_forward", "fallback" },
    ["<S-Tab>"] = { "snippet_backward", "fallback" },
    ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
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
