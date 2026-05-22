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

local function echo_header(text)
  echo(string.format("=== %s ===", text), "Title")
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
        local capability_names = {
          { "textDocumentSync", "sync" },
          { "completionProvider", "completion" },
          { "hoverProvider", "hover" },
          { "signatureHelpProvider", "signature" },
          { "definitionProvider", "definition" },
          { "referencesProvider", "references" },
          { "documentFormattingProvider", "format" },
          { "codeActionProvider", "codeAction" },
        }
        for _, capability_spec in ipairs(capability_names) do
          local capability, label = capability_spec[1], capability_spec[2]
          if client.server_capabilities[capability] then table.insert(caps, label) end
        end
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
  local diagnostic_specs = {
    { vim.diagnostic.severity.ERROR, "  ✗ Errors: ", "DiagnosticError" },
    { vim.diagnostic.severity.WARN, "  ⚠ Warnings: ", "DiagnosticWarn" },
    { vim.diagnostic.severity.INFO, "  ℹ Info: ", "DiagnosticInfo" },
    { vim.diagnostic.severity.HINT, "  💡 Hints: ", "Normal" },
  }

  local has_diagnostics = false
  for _, spec in ipairs(diagnostic_specs) do
    local severity, label, hlgroup = spec[1], spec[2], spec[3]
    local count = #vim.diagnostic.get(bufnr, { severity = severity })
    if count > 0 then
      echo(label, hlgroup)
      echo(tostring(count), hlgroup)
      echo_newline()
      has_diagnostics = true
    end
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

  -- Check TypeScript tools
  local ts_tools_config = config.formatters["typescript-tools"]
  local ts_tools_files = ts_tools_config and ts_tools_config.config_files or {}
  local ts_tools_has_files = utils.has_config_files(ts_tools_files)
  echo("• typescript-tools: ", "Normal")
  echo("enabled", "DiagnosticOk")
  echo(" (ts/js config: ", "Normal")
  echo(ts_tools_has_files and "found" or "not found", ts_tools_has_files and "DiagnosticOk" or "DiagnosticError")
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

  -- Tooling status
  echo_newline()
  echo_header "Tooling Status"
  local mason_registry = require "mason-registry"
  local eslint_pkg = mason_registry.get_package "eslint-lsp"

  echo("• eslint-lsp: ", "Normal")
  echo(
    eslint_pkg:is_installed() and "✓ installed" or "✗ not installed",
    eslint_pkg:is_installed() and "DiagnosticOk" or "DiagnosticError"
  )
  echo_newline()

  local tsserver_path =
    require("lsp.utils").get_mason_package_path("typescript-language-server", "node_modules/typescript/lib/tsserver.js")
  echo("• typescript-tools.nvim: ", "Normal")
  if tsserver_path then
    echo("using Mason TypeScript (tsserver): ", "DiagnosticOk")
    echo(tsserver_path, "DiagnosticInfo")
  else
    echo("TypeScript not found (install via Mason or workspace node_modules)", "DiagnosticWarn")
  end
  echo_newline()

  -- Formatter status
  echo_newline()
  echo_header "Formatter Status"
  local autoformat = require "lsp.autoformat"
  local format_state = autoformat.state(bufnr)
  local global_format_disabled = format_state.global_disabled
  local buffer_format_disabled = format_state.buffer_disabled

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
  local format_on_save = not (global_format_disabled or buffer_format_disabled)
  echo_newline()
  echo("• Format on save: ", "Normal")
  echo(format_on_save and "enabled" or "disabled", format_on_save and "DiagnosticOk" or "DiagnosticWarn")
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
  elseif server_name == "typescript-tools" then
    local ok = pcall(require, "typescript-tools")
    if not ok then
      print "typescript-tools.nvim not available"
      return
    end

    vim.cmd "LspStart typescript-tools"
    print "Manually started typescript-tools"
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
  for _, handler in ipairs {
    { "Virtual text", "virtual_text" },
    { "Signs", "signs" },
    { "Underline", "underline" },
  } do
    echo("• " .. handler[1] .. ": ", "Normal")
    echo(tostring(diag_config[handler[2]] ~= false), "DiagnosticInfo")
    echo_newline()
  end

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
    return { "eslint", "typescript-tools" }
  end,
})
vim.api.nvim_create_user_command("LspTestFormatter", M.test_formatter, {})
vim.api.nvim_create_user_command("LspCheckDiagnostics", M.check_diagnostics, {})

return M
