local status, mason = pcall(require, "mason")
if not status then
  return
end

local status2, mason_lspconfig = pcall(require, "mason-lspconfig")
if not status2 then
  return
end

local status3, lspconfig = pcall(require, "lspconfig")
if not status3 then
  return
end

local status4 = pcall(require, "lspsaga")
if not status4 then
  return
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
    local has_custom_opts, server_custom_opts = pcall(require, "lsp.settings." .. server)
    if has_custom_opts then
      opts = vim.tbl_deep_extend("force", opts, server_custom_opts)
    end

    -- config_filesと一致するサーバーの場合、対応する設定ファイルがあれば起動する
    local server_config_files = require("lsp.config").config_files[server]
    if server_config_files then
      for _, file in ipairs(server_config_files) do
        if vim.fn.filereadable(file) == 1 then
          lspconfig[server].setup(opts)
          break
        end
      end
    else
      lspconfig[server].setup(opts)
    end
  end,
}
