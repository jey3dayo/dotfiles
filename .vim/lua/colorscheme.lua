-- Load colorscheme with lazy loading
local function load_colorscheme()
  pcall(function()
    -- Ensure kanagawa plugin is loaded
    require("lazy").load({ plugins = { "kanagawa.nvim" } })
    vim.cmd("colorscheme kanagawa")

    -- Apply custom highlights
    local highlights = {
      "Normal ctermbg=NONE guibg=NONE",
      "NonText ctermbg=NONE guibg=NONE",
      "SpecialKey ctermbg=NONE guibg=NONE",
      "EndOfBuffer ctermbg=NONE guibg=NONE",
      "SignColumn ctermbg=NONE guibg=NONE",
      "NormalNC ctermbg=NONE guibg=NONE",
      "TelescopeBorder ctermbg=NONE guibg=NONE",
      "NvimTreeNormal ctermbg=NONE guibg=NONE",
      "MsgArea ctermbg=NONE guibg=NONE",
    }

    for _, hl in ipairs(highlights) do
      vim.cmd("highlight " .. hl)
    end
  end)
end

-- Try to load kanagawa, fallback to default if not available
local ok = pcall(load_colorscheme)
if not ok then
  vim.cmd("colorscheme default")
  vim.cmd("set background=dark")
end
