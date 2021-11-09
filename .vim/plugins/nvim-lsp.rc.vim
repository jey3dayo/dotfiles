nnoremap [lsp] <Nop>
nmap <C-e> [lsp]

nnoremap <C-[> :lua vim.lsp.buf.references()<CR>
nnoremap <C-]> :lua vim.lsp.buf.definition()<CR>
nnoremap [lsp]gd :lua vim.lsp.buf.definition()<CR>
nnoremap [lsp]D :lua vim.lsp.buf.declaration()<CR>
nnoremap [lsp]t :lua vim.lsp.buf.type_definition()<CR>
nnoremap [lsp]i :lua vim.lsp.buf.implementation()<CR>
nnoremap [lsp]r :lua vim.lsp.buf.rename()<CR>
nnoremap [lsp]f :lua vim.lsp.buf.formatting()<CR>
nnoremap [lsp]a :lua vim.lsp.buf.code_action()<CR>
nnoremap <silent>K :lua vim.lsp.buf.hover()<CR>
nnoremap <silent>L :lua vim.lsp.buf.signature_help()<CR>
nnoremap <C-k> :lua vim.lsp.diagnostic.goto_prev()<CR>
nnoremap <C-j> :lua vim.lsp.diagnostic.goto_next()<CR>

lua << EOF
-- for debugging
-- :lua require('vim.lsp.log').set_level("debug")
-- :lua print(vim.inspect(vim.lsp.buf_get_clients()))
-- :lua print(vim.lsp.get_log_path())
-- :lua print(vim.inspect(vim.tbl_keys(vim.lsp.callbacks)))
local has_lsp, nvim_lsp = pcall(require, 'lspconfig')
local on_attach = function(client, bufnr)
  require "lsp_signature".on_attach()
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end
end

local servers = {
  cssls = {},
  bashls = {},
  vimls = {},
  pylsp = {},
  dockerls = {},
  eslint = {},
  -- tailwindcss = {
  --   init_options = {
  --     userLanguages = {
  --       eruby = 'erb',
  --       eelixir = 'html-eex',
  --       ['javascript.jsx'] = 'javascriptreact',
  --       ['typescript.tsx'] = 'typescriptreact',
  --     },
  --   },
  --   handlers = {
  --     ['tailwindcss/getConfiguration'] = function(_, _, context)
  --       -- tailwindcss lang server waits for this repsonse before providing hover
  --       vim.lsp.buf_notify(
  --         context.bufnr,
  --         'tailwindcss/getConfigurationResponse',
  --         { _id = context.params._id }
  --       )
  --     end,
  --   },
  -- },
  rust_analyzer = {},
  tsserver = {
    root_dir = function(fname)
      return nvim_lsp.util.root_pattern 'tsconfig.json'(fname)
        or nvim_lsp.util.root_pattern(
          'package.json',
          'jsconfig.json',
          '.git'
        )(fname)
        or nvim_lsp.util.path.dirname(fname)
    end,
  },
  -- rnix = {},
  jsonls = {
    filetypes = { 'json', 'jsonc' },
    settings = {
      json = {
        -- Schemas https://www.schemastore.org
        schemas = {
          {
            fileMatch = { 'package.json' },
            url = 'https://json.schemastore.org/package.json',
          },
          {
            fileMatch = { 'tsconfig*.json' },
            url = 'https://json.schemastore.org/tsconfig.json',
          },
          {
            fileMatch = {
              '.prettierrc',
              '.prettierrc.json',
              'prettier.config.json',
            },
            url = 'https://json.schemastore.org/prettierrc.json',
          },
          {
            fileMatch = { '.eslintrc', '.eslintrc.json' },
            url = 'https://json.schemastore.org/eslintrc.json',
          },
          {
            fileMatch = { '.babelrc', '.babelrc.json', 'babel.config.json' },
            url = 'https://json.schemastore.org/babelrc.json',
          },
          {
            fileMatch = { 'lerna.json' },
            url = 'https://json.schemastore.org/lerna.json',
          },
          {
            fileMatch = { 'now.json', 'vercel.json' },
            url = 'https://json.schemastore.org/now.json',
          },
          {
            fileMatch = { 'now.json', 'vercel.json' },
            url = 'https://json.schemastore.org/now.json',
          },
          {
            fileMatch = {
              '.stylelintrc',
              '.stylelintrc.json',
              'stylelint.config.json',
            },
            url = 'http://json.schemastore.org/stylelintrc.json',
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
          ['http://json.schemastore.org/gitlab-ci.json'] = {
            '.gitlab-ci.yml',
          },
          ['https://json.schemastore.org/bamboo-spec.json'] = {
            'bamboo-specs/*.{yml,yaml}',
          },
          ['https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json'] = {
            'docker-compose*.{yml,yaml}',
          },
          ['http://json.schemastore.org/github-workflow.json'] = '.github/workflows/*.{yml,yaml}',
          ['http://json.schemastore.org/github-action.json'] = '.github/action.{yml,yaml}',
          ['http://json.schemastore.org/prettierrc.json'] = '.prettierrc.{yml,yaml}',
          ['http://json.schemastore.org/stylelintrc.json'] = '.stylelintrc.{yml,yaml}',
          ['http://json.schemastore.org/circleciconfig'] = '.circleci/**/*.{yml,yaml}',
        },
      },
    },
  },
}

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.resolveSupport = {
  properties = {
    'documentation',
    'detail',
    'additionalTextEdits',
  },
}

for server, config in pairs(servers) do
  local server_disabled = (config.disabled ~= nil and config.disabled) or false

  if not server_disabled then
    nvim_lsp[server].setup(
      vim.tbl_deep_extend(
        'force',
        { on_attach = on_attach, capabilities = capabilities },
        config
      )
    )
  end
end
EOF
