-- Load colorscheme with lazy loading
local function load_colorscheme()
  pcall(function()
    -- Ensure 0x96f plugin is loaded
    require("lazy").load { plugins = { "0x96f.nvim" } }
    require("0x96f").setup()
    vim.cmd.colorscheme "0x96f"

    -- Apply custom highlights
    local highlights = {
      "Normal ctermbg=NONE guibg=NONE",
      "NonText ctermbg=NONE guibg=NONE",
      "SpecialKey ctermbg=NONE guibg=NONE",
      "EndOfBuffer ctermbg=NONE guibg=NONE",
      "SignColumn ctermbg=NONE guibg=NONE",
      "NormalNC ctermbg=NONE guibg=NONE",
      "NvimTreeNormal ctermbg=NONE guibg=NONE",
      "MsgArea ctermbg=NONE guibg=NONE",
    }

    for _, hl in ipairs(highlights) do
      vim.cmd("highlight " .. hl)
    end
  end)
end

-- Try to load 0x96f, fallback to default if not available
local ok = pcall(load_colorscheme)
if not ok then
  vim.cmd "colorscheme default"
  vim.cmd "set background=dark"
end
