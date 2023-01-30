local status, mason = pcall(require, "mason")
if not status then
  return
end

local status2, lspconfig = pcall(require, "mason-lspconfig")
if not status2 then
  return
end

local status3, nvim_lsp = pcall(require, "lspconfig")
if not status3 then
  return
end

local status4 = pcall(require, "lspsaga")
if not status4 then
  return
end

local status5, null_ls = pcall(require, "null-ls")
if not status5 then
  return
end

local status6, mason_null_ls = pcall(require, "mason-null-ls")
if not status6 then
  return
end

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

mason_null_ls.setup {
  ensure_installed = nil,
  automatic_installation = true,
  automatic_setup = false,
}

local set_opts = { silent = true }
Set_keymap("[lsp]", "<Nop>", set_opts)
Set_keymap("<C-e>", "[lsp]", set_opts)

lspconfig.setup {
  ensure_installed = { "sumneko_lua", "tailwindcss", "tsserver" },
}

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.resolveSupport = {
  properties = {
    "documentation",
    "detail",
    "additionalTextEdits",
  },
}

local configs = {
  cssls = {
    settings = {
      css = {
        lint = {
          unknownAtRules = "ignore",
        },
      },
    },
  },
  tailwindcss = {
    init_options = {
      userLanguages = {
        eruby = "erb",
        eelixir = "html-eex",
        ["javascript.jsx"] = "javascriptreact",
        ["typescript.tsx"] = "typescriptreact",
      },
    },
  },
  jsonls = {
    filetypes = { "json", "jsonc" },
    commands = {
      Format = {
        function()
          vim.lsp.buf.formatexpr({}, { 0, 0 }, { vim.fn.line "$", 0 })
        end,
      },
    },
    settings = {
      json = {
        -- Schemas https://www.schemastore.org
        schemas = {
          {
            fileMatch = { "package.json" },
            url = "https://json.schemastore.org/package.json",
          },
          {
            fileMatch = { "tsconfig*.json" },
            url = "https://json.schemastore.org/tsconfig.json",
          },
          {
            fileMatch = {
              ".prettierrc",
              ".prettierrc.json",
              "prettier.config.json",
            },
            url = "https://json.schemastore.org/prettierrc.json",
          },
          {
            fileMatch = { ".eslintrc", ".eslintrc.json" },
            url = "https://json.schemastore.org/eslintrc.json",
          },
          {
            fileMatch = { ".babelrc", ".babelrc.json", "babel.config.json" },
            url = "https://json.schemastore.org/babelrc.json",
          },
          {
            fileMatch = { "lerna.json" },
            url = "https://json.schemastore.org/lerna.json",
          },
          {
            fileMatch = { "now.json", "vercel.json" },
            url = "https://json.schemastore.org/now.json",
          },
          {
            fileMatch = { "now.json", "vercel.json" },
            url = "https://json.schemastore.org/now.json",
          },
          {
            fileMatch = {
              ".stylelintrc",
              ".stylelintrc.json",
              "stylelint.config.json",
            },
            url = "http://json.schemastore.org/stylelintrc.json",
          },
        },
      },
    },
  },
  yamlls = {
    settings = {
      yaml = {
        -- Schemas https://www.schemastore.org
        schemas = {
          ["http://json.schemastore.org/gitlab-ci.json"] = {
            ".gitlab-ci.yml",
          },
          ["https://json.schemastore.org/bamboo-spec.json"] = {
            "bamboo-specs/*.{yml,yaml}",
          },
          ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = {
            "docker-compose*.{yml,yaml}",
          },
          ["http://json.schemastore.org/github-workflow.json"] = ".github/workflows/*.{yml,yaml}",
          ["http://json.schemastore.org/github-action.json"] = ".github/action.{yml,yaml}",
          ["http://json.schemastore.org/prettierrc.json"] = ".prettierrc.{yml,yaml}",
          ["http://json.schemastore.org/stylelintrc.json"] = ".stylelintrc.{yml,yaml}",
          ["http://json.schemastore.org/circleciconfig"] = ".circleci/**/*.{yml,yaml}",
        },
      },
    },
  },
}

lspconfig.setup_handlers {
  function(server_name)
    local config = {}

    if configs[server_name] ~= nil then
      config = configs[server_name]
    end

    local on_attach = function(_, bufnr)
      local bufopts = { noremap = true, silent = true, buffer = bufnr }
      Keymap("<C-]>", vim.lsp.buf.definition, bufopts)
      Keymap("[lsp]f", vim.lsp.buf.format, bufopts)
      Keymap("[lsp]d", vim.lsp.buf.declaration, bufopts)
      Keymap("[lsp]t", vim.lsp.buf.type_definition, bufopts)
      Keymap("[lsp]i", vim.lsp.buf.implementation, bufopts)

      -- lspsaga
      Keymap("<C-j>", "<cmd>Lspsaga diagnostic_jump_next<CR>", bufopts)
      Keymap("<C-k>", "<cmd>Lspsaga diagnostic_jump_prev<CR>", bufopts)
      Keymap("K", "<cmd>Lspsaga hover_doc<CR>", bufopts)
      Keymap("<C-[>", "<Cmd>Lspsaga lsp_finder<CR>", bufopts)
      Keymap("[lsp]r", "<cmd>Lspsaga rename<CR>", bufopts)
      Keymap("[lsp]a", "<cmd>Lspsaga code_action<CR>", bufopts)
    end

    local server_disabled = (config.disabled ~= nil and config.disabled) or false
    if not server_disabled then
      nvim_lsp[server_name].setup(
        vim.tbl_deep_extend("force", { on_attach = on_attach, capabilities = capabilities }, config)
      )
    end
  end,
}
