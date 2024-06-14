local mason_lspconfig = safe_require "mason-lspconfig"
local lspconfig = safe_require "lspconfig"

if not (mason_lspconfig and lspconfig) then
  return
end

local function safe_setup(server, opts, autostart)
  -- opts.autostartが定義されてないならautostartを代入
  if not opts.autostart then
    opts.autostart = autostart
  end

  lspconfig[server].setup(opts)
end

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
