local M = {}

-- Echo buffer for colored output
local echo_buffer = {}

local function echo(text, hlgroup)
  table.insert(echo_buffer, { text, hlgroup or "Normal" })
end

local function echo_newline()
  table.insert(echo_buffer, { "\n", "Normal" })
end

local function flush_echo()
  vim.api.nvim_echo(echo_buffer, false, {})
  echo_buffer = {}
end

-- Styled echo helpers
local function echo_header(text)
  echo(string.format("=== %s ===", text), "Title")
  echo_newline()
end

local function echo_bullet(text, hlgroup)
  echo("• ", "Normal")
  echo(text, hlgroup or "Normal")
  echo_newline()
end

local function echo_sub_bullet(text, hlgroup)
  echo("    ", "Normal")
  echo(text, hlgroup or "Normal")
  echo_newline()
end

function M.check_lsp_status()
  vim.cmd "echo ''"
  echo_buffer = {}

  -- Buffer information
  echo_header "Buffer Information"
  local bufnr = vim.api.nvim_get_current_buf()
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  echo("• File: ", "Normal")
  echo(bufname ~= "" and bufname or "[No Name]", "DiagnosticInfo")
  echo_newline()
  echo("• Filetype: ", "Normal")
  echo(vim.bo.filetype, "DiagnosticInfo")
  echo_newline()
  echo("• Buffer: ", "Normal")
  echo(tostring(bufnr), "DiagnosticInfo")
  echo_newline()

  -- Active LSP clients
  local clients = vim.lsp.get_clients { bufnr = bufnr }
  echo_newline()
  echo_header "Active LSP Clients"
  if #clients == 0 then
    echo("  No LSP clients attached to this buffer", "DiagnosticError")
    echo_newline()
  else
    for _, client in ipairs(clients) do
      local status_icon = client.initialized and "✓" or "○"
      local status_hl = client.initialized and "DiagnosticOk" or "DiagnosticWarn"
      echo(status_icon .. " ", status_hl)
      echo(client.name, "DiagnosticInfo")
      echo(string.format(" (id: %d)", client.id), "Normal")
      echo_newline()

      -- Show capabilities
      if client.server_capabilities then
        local caps = {}
        if client.server_capabilities.textDocumentSync then table.insert(caps, "sync") end
        if client.server_capabilities.completionProvider then table.insert(caps, "completion") end
        if client.server_capabilities.hoverProvider then table.insert(caps, "hover") end
        if client.server_capabilities.signatureHelpProvider then table.insert(caps, "signature") end
        if client.server_capabilities.definitionProvider then table.insert(caps, "definition") end
        if client.server_capabilities.referencesProvider then table.insert(caps, "references") end
        if client.server_capabilities.documentFormattingProvider then table.insert(caps, "format") end
        if client.server_capabilities.codeActionProvider then table.insert(caps, "codeAction") end
        if #caps > 0 then
          echo("    Capabilities: ", "Normal")
          echo(table.concat(caps, ", "), "Normal")
          echo_newline()
        end
      end
    end
  end

  -- Diagnostics summary
  echo_newline()
  echo_header "Diagnostics Summary"
  local diag_count = {
    [vim.diagnostic.severity.ERROR] = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.ERROR }),
    [vim.diagnostic.severity.WARN] = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.WARN }),
    [vim.diagnostic.severity.INFO] = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.INFO }),
    [vim.diagnostic.severity.HINT] = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.HINT }),
  }

  local has_diagnostics = false
  if diag_count[vim.diagnostic.severity.ERROR] > 0 then
    echo("  ✗ Errors: ", "DiagnosticError")
    echo(tostring(diag_count[vim.diagnostic.severity.ERROR]), "DiagnosticError")
    echo_newline()
    has_diagnostics = true
  end
  if diag_count[vim.diagnostic.severity.WARN] > 0 then
    echo("  ⚠ Warnings: ", "DiagnosticWarn")
    echo(tostring(diag_count[vim.diagnostic.severity.WARN]), "DiagnosticWarn")
    echo_newline()
    has_diagnostics = true
  end
  if diag_count[vim.diagnostic.severity.INFO] > 0 then
    echo("  ℹ Info: ", "DiagnosticInfo")
    echo(tostring(diag_count[vim.diagnostic.severity.INFO]), "DiagnosticInfo")
    echo_newline()
    has_diagnostics = true
  end
  if diag_count[vim.diagnostic.severity.HINT] > 0 then
    echo("  💡 Hints: ", "Normal")
    echo(tostring(diag_count[vim.diagnostic.severity.HINT]), "Normal")
    echo_newline()
    has_diagnostics = true
  end

  if not has_diagnostics then
    echo("  ✓ No diagnostics found", "DiagnosticOk")
    echo_newline()
  end

  -- All available LSP clients
  local all_clients = vim.lsp.get_clients()
  echo_newline()
  echo_header "All LSP Clients in Session"
  for _, client in ipairs(all_clients) do
    local attached_buffers = vim.tbl_filter(function(b)
      return vim.lsp.buf_is_attached(b, client.id)
    end, vim.api.nvim_list_bufs())
    echo("• ", "Normal")
    echo(client.name, "DiagnosticInfo")
    echo(string.format(" (buffers: %d)", #attached_buffers), "Normal")
    echo_newline()
  end

  -- Check autostart conditions
  local utils = require "core.utils"
  local config = require "lsp.config"

  echo_newline()
  echo_header "Autostart Conditions"

  -- Check eslint
  local eslint_config = require "lsp.settings.eslint"
  local eslint_files = config.formatters.eslint.config_files
  local eslint_has_files = utils.has_config_files(eslint_files)
  local eslint_autostart = type(eslint_config.autostart) == "function" and eslint_config.autostart() or true

  echo("• eslint: ", "Normal")
  echo(eslint_has_files and "enabled" or "disabled", eslint_has_files and "DiagnosticOk" or "DiagnosticError")
  echo(" (config: ", "Normal")
  echo(eslint_has_files and "found" or "not found", eslint_has_files and "DiagnosticOk" or "DiagnosticError")
  echo(", autostart: ", "Normal")
  echo(eslint_autostart and "true" or "false", eslint_autostart and "DiagnosticOk" or "DiagnosticError")
  echo(")", "Normal")
  echo_newline()

  -- Check ts_ls
  local ts_ls_files = config.formatters.ts_ls.config_files
  local ts_ls_has_files = utils.has_config_files(ts_ls_files)
  echo("• ts_ls: ", "Normal")
  echo("enabled", "DiagnosticOk")
  echo(" (tsconfig.json: ", "Normal")
  echo(ts_ls_has_files and "found" or "not found", ts_ls_has_files and "DiagnosticOk" or "DiagnosticError")
  echo(")", "Normal")
  echo_newline()

  -- Check biome
  local biome_files = config.formatters.biome.config_files
  local biome_has_files = utils.has_config_files(biome_files)
  echo("• biome: ", "Normal")
  if biome_has_files then
    echo("found (may override other formatters)", "DiagnosticWarn")
  else
    echo("not found", "Normal")
  end
  echo_newline()

  -- Mason installation status
  echo_newline()
  echo_header "Mason Installation Status"
  local mason_registry = require "mason-registry"
  local eslint_pkg = mason_registry.get_package "eslint-lsp"
  local ts_ls_pkg = mason_registry.get_package "typescript-language-server"

  echo("• eslint-lsp: ", "Normal")
  echo(
    eslint_pkg:is_installed() and "✓ installed" or "✗ not installed",
    eslint_pkg:is_installed() and "DiagnosticOk" or "DiagnosticError"
  )
  echo_newline()

  echo("• typescript-language-server: ", "Normal")
  echo(
    ts_ls_pkg:is_installed() and "✓ installed" or "✗ not installed",
    ts_ls_pkg:is_installed() and "DiagnosticOk" or "DiagnosticError"
  )
  echo_newline()

  -- Formatter status
  echo_newline()
  echo_header "Formatter Status"
  local format_config = require("lsp.config").format
  local global_format_disabled = vim.g[format_config.state.global] == 1
  local buffer_format_disabled = vim.b[format_config.state.buffer] == 1

  echo("• Global formatting: ", "Normal")
  echo(global_format_disabled and "✗ OFF" or "✓ ON", global_format_disabled and "DiagnosticError" or "DiagnosticOk")
  echo_newline()

  echo("• Buffer formatting: ", "Normal")
  echo(buffer_format_disabled and "✗ OFF" or "✓ ON", buffer_format_disabled and "DiagnosticError" or "DiagnosticOk")
  echo_newline()

  -- Show which formatters would be used
  local format_clients = require("lsp.client_utils").get_format_clients(bufnr)
  if #format_clients > 0 then
    echo("• Available formatters:", "Normal")
    echo_newline()
    for _, client in ipairs(format_clients) do
      local is_active = not (global_format_disabled or buffer_format_disabled)
      local status_icon = is_active and "✓" or "○"
      local status_hl = is_active and "DiagnosticOk" or "DiagnosticWarn"
      echo("    " .. status_icon .. " ", status_hl)
      echo(client.name, "DiagnosticInfo")
      echo_newline()
    end
  else
    echo("  No formatters available for this buffer", "DiagnosticWarn")
    echo_newline()
  end

  -- Show formatter priority if multiple formatters
  if #format_clients > 1 then
    local formatters = require("lsp.config").formatters
    echo_newline()
    echo("• Formatter priorities:", "Normal")
    echo_newline()
    for _, client in ipairs(format_clients) do
      local formatter_config = formatters[client.name]
      if formatter_config and formatter_config.formatter_priority then
        echo("    ", "Normal")
        echo(client.name, "DiagnosticInfo")
        echo(string.format(": priority %d", formatter_config.formatter_priority.priority), "Normal")
        echo_newline()
      end
    end
  end

  -- Format on save status
  local format_on_save = vim.api.nvim_buf_get_option(bufnr, "formatexpr") ~= ""
  echo_newline()
  echo("• Format on save: ", "Normal")
  echo(format_on_save and "configured" or "not configured", format_on_save and "DiagnosticWarn" or "Normal")
  echo_newline()

  -- Key bindings reminder
  echo_newline()
  echo_header "Useful Commands"
  local commands = {
    { ":LspInfo", "Show detailed LSP information" },
    { ":LspRestart", "Restart LSP servers" },
    { ":LspLog", "View LSP log file" },
    { ":Mason", "Manage LSP installations" },
    { ":LspStartManual <server>", "Manually start a server" },
    { "[d / ]d", "Navigate diagnostics" },
    { "K", "Show hover information" },
    { "gd", "Go to definition" },
    { "gr", "Find references" },
    { "<leader>tf", "Toggle formatting (buffer)" },
    { "<leader>tF", "Toggle formatting (global)" },
  }

  for _, cmd in ipairs(commands) do
    echo("• ", "Normal")
    echo(cmd[1], "DiagnosticInfo")
    echo(" - " .. cmd[2], "Normal")
    echo_newline()
  end

  -- Flush the buffer
  flush_echo()
end

-- Manual LSP start function
function M.start_lsp_manually(server_name)
  local lspconfig = require "lspconfig"
  local utils = require "core.utils"

  -- Enable debug logging
  vim.lsp.set_log_level "debug"

  if server_name == "eslint" then
    local extends = utils.safe_require "lsp.settings.eslint"
    local handlers = require "lsp.handlers"
    local config = vim.tbl_deep_extend("force", {
      on_attach = function(client, bufnr)
        print(string.format("ESLint attached to buffer %d", bufnr))
        handlers.on_attach(client, bufnr)
        -- Enable diagnostics
        if client.server_capabilities.diagnosticProvider then vim.diagnostic.enable(true, { bufnr = bufnr }) end
      end,
      capabilities = require("lsp.capabilities").setup(),
      handlers = handlers.handlers,
    }, extends or {})
    lspconfig.eslint.setup(config)
    vim.cmd "LspStart eslint"
    print "Manually started eslint"
  elseif server_name == "ts_ls" then
    local extends = utils.safe_require "lsp.settings.ts_ls"
    local handlers = require "lsp.handlers"
    local config = vim.tbl_deep_extend("force", {
      on_attach = function(client, bufnr)
        print(string.format("ts_ls attached to buffer %d", bufnr))
        handlers.on_attach(client, bufnr)
        -- Enable diagnostics
        if client.server_capabilities.diagnosticProvider then vim.diagnostic.enable(true, { bufnr = bufnr }) end
      end,
      capabilities = require("lsp.capabilities").setup(),
      handlers = handlers.handlers,
    }, extends or {})
    lspconfig.ts_ls.setup(config)
    vim.cmd "LspStart ts_ls"
    print "Manually started ts_ls"
  else
    print("Unknown server: " .. server_name)
  end
end

-- Function to check diagnostic configuration
function M.check_diagnostics()
  vim.cmd "echo ''"
  echo_buffer = {}

  echo_header "Diagnostic Configuration"

  -- Check if diagnostics are enabled
  local diag_config = vim.diagnostic.config()
  echo("• Diagnostics enabled: ", "Normal")
  echo(diag_config.virtual_text and "Yes" or "No", diag_config.virtual_text and "DiagnosticOk" or "DiagnosticError")
  echo_newline()

  -- Check diagnostic handlers
  echo("• Virtual text: ", "Normal")
  echo(tostring(diag_config.virtual_text ~= false), "DiagnosticInfo")
  echo_newline()

  echo("• Signs: ", "Normal")
  echo(tostring(diag_config.signs ~= false), "DiagnosticInfo")
  echo_newline()

  echo("• Underline: ", "Normal")
  echo(tostring(diag_config.underline ~= false), "DiagnosticInfo")
  echo_newline()

  -- Check LSP client diagnostic capabilities
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients { bufnr = bufnr }

  echo_newline()
  echo_header "LSP Client Diagnostic Support"
  for _, client in ipairs(clients) do
    echo("• ", "Normal")
    echo(client.name, "DiagnosticInfo")
    echo(": ", "Normal")

    local supports_diag = client.server_capabilities and client.server_capabilities.diagnosticProvider
    if supports_diag then
      echo("supports diagnostics", "DiagnosticOk")
    else
      echo("no diagnostic support", "DiagnosticWarn")
    end
    echo_newline()
  end

  -- Force refresh diagnostics
  echo_newline()
  echo("Running vim.diagnostic.reset()...", "DiagnosticInfo")
  echo_newline()
  vim.diagnostic.reset()

  echo("Running vim.lsp.buf.document_diagnostics()...", "DiagnosticInfo")
  echo_newline()
  for _, client in ipairs(clients) do
    if client.server_capabilities.diagnosticProvider then vim.lsp.diagnostic.refresh(nil, { client_id = client.id }) end
  end

  flush_echo()
end

-- Function to test formatter
function M.test_formatter()
  vim.cmd "echo ''"
  echo_buffer = {}

  local bufnr = vim.api.nvim_get_current_buf()
  local format_clients = require("lsp.client_utils").get_format_clients(bufnr)

  echo_header "Formatter Test"
  if #format_clients == 0 then
    echo("No formatters available for this buffer", "DiagnosticError")
    echo_newline()
  else
    echo("Available formatters:", "Normal")
    echo_newline()
    for i, client in ipairs(format_clients) do
      echo(string.format("%d. ", i), "Normal")
      echo(client.name, "DiagnosticInfo")
      echo_newline()
    end

    echo_newline()
    echo("Formatting would use: ", "Normal")
    echo(format_clients[1].name, "DiagnosticOk")
    echo_newline()
    echo_newline()
    echo("Run :lua vim.lsp.buf.format() to format the buffer", "Normal")
    echo_newline()
  end

  flush_echo()
end

-- Create user commands
vim.api.nvim_create_user_command("LspDebug", M.check_lsp_status, {})
vim.api.nvim_create_user_command("LspStartManual", function(opts)
  M.start_lsp_manually(opts.args)
end, {
  nargs = 1,
  complete = function()
    return { "eslint", "ts_ls" }
  end,
})
vim.api.nvim_create_user_command("LspTestFormatter", M.test_formatter, {})
vim.api.nvim_create_user_command("LspCheckDiagnostics", M.check_diagnostics, {})

return M
