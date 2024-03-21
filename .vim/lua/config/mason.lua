local mason = safe_require "mason"
local mason_lspconfig = safe_require "mason-lspconfig"
local lspconfig = safe_require "lspconfig"
local lspsaga = safe_require "lspsaga"

if not (mason and mason_lspconfig and lspconfig and lspsaga) then
  return
end

local function safe_setup(server, _opts, autostart)
  local opts = vim.tbl_deep_extend("force", _opts, { autostart = autostart or _opts.autostart })
  lspconfig[server].setup(opts)
end

local term_opts = { silent = true }
Set_keymap("[lsp]", "<Nop>", term_opts)
Set_keymap("<C-e>", "[lsp]", term_opts)

mason.setup {
  ui = {
    icons = {
      server_installed = "✓",
      server_pending = "➜",
      server_uninstalled = "✗",
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗",
    },
  },
}

mason_lspconfig.setup {
  ensure_installed = require("lsp.config").installed_servers,
  automatic_installation = true,
}

mason_lspconfig.setup_handlers {
  function(server)
    local opts = {
      on_attach = require("lsp.handlers").on_attach,
      capabilities = require("lsp.handlers").capabilities,
    }
    local server_custom_opts = safe_require("lsp.settings." .. server)
    if server_custom_opts then
      opts = vim.tbl_deep_extend("force", opts, server_custom_opts)
    end

    -- config_filesと一致するサーバーの場合、対応する設定ファイルがあれば起動する
    local server_config_files = require("lsp.config").config_files[server]
    if server_config_files then
      for _, file in ipairs(server_config_files) do
        if vim.fn.filereadable(file) == 1 then
          return safe_setup(server, opts, true)
        end
      end
      return safe_setup(server, opts, false)
    else
      return safe_setup(server, opts, true)
    end
  end,
}
