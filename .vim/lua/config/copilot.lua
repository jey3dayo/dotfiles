local utils = require "core.utils"
local copilot = utils.safe_require "copilot"
local copilot_cmp = utils.safe_require "copilot_cmp"
local copilot_chat = utils.safe_require "CopilotChat"
local select = utils.safe_require "CopilotChat.select"

if not (copilot and copilot_cmp and copilot_chat) then return end

-- Disable Copilot as an LSP to prevent "no configuration" warnings
vim.g.copilot_filetypes = {
  ["*"] = false,
  javascript = true,
  typescript = true,
  lua = true,
  python = true,
  go = true,
  rust = true,
}

copilot.setup {
  suggestion = { enabled = false },  -- Disable to use Supermaven instead
  panel = { enabled = false },
  copilot_node_command = utils.find_command {
    os.getenv "HOME" .. "/.mise/shims/node",
    "/usr/local/bin/node",
  },
}

copilot_cmp.setup {
  formatters = {
    label = require("copilot_cmp.format").format_label_text,
    insert_text = require("copilot_cmp.format").remove_existing,
    preview = require("copilot_cmp.format").deindent,
  },
}

copilot_chat.setup {
  debug = false, -- Enable debugging  -- プロンプトの設定

  -- 日本語でオーバーライド
  prompts = {
    Explain = {
      prompt = "/COPILOT_EXPLAIN カーソル上のコードの説明を段落をつけて書いてください。",
    },
    Tests = {
      prompt = "/COPILOT_TESTS カーソル上のコードの詳細な単体テスト関数を書いてください。",
    },
    Fix = {
      prompt = "/COPILOT_FIX このコードには問題があります。バグを修正したコードに書き換えてください。",
    },
    Optimize = {
      prompt = "/COPILOT_REFACTOR 選択したコードを最適化し、パフォーマンスと可読性を向上させてください。",
    },
    Review = {
      prompt = "/COPILOT_REFACTOR 選択したコードのレビューをお願いします。",
    },
    Docs = {
      prompt = "/COPILOT_REFACTOR 選択したコードのドキュメントを書いてください。ドキュメントをコメントとして追加した元のコードを含むコードブロックで回答してください。使用するプログラミング言語に最も適したドキュメントスタイルを使用してください（例：JavaScriptのJSDoc、Pythonのdocstringsなど）",
    },
    FixDiagnostic = {
      prompt = "ファイル内の次のような診断上の問題を解決してください：",
      selection = select and select.diagnostics or nil,
    },
  },
}

-- Copilot Chat
-- バッファの内容全体を使ってCopilotとチャット
local function CopilotChatBuffer()
  local input = vim.fn.input "Quick Chat: "
  if input ~= "" then
    require("CopilotChat").ask(input, {
      selection = select and select.buffer or nil,
    })
  end
end

-- vim.ui.selectを使ってアクションプロンプトを表示（mini.pick統合）
local function ShowChatPrompt()
  local actions = require "CopilotChat.actions"
  local prompt_actions = actions.prompt_actions()
  
  -- mini.pickのvim.ui.select統合を利用
  local items = {}
  for name, action in pairs(prompt_actions) do
    table.insert(items, { name = name, action = action })
  end
  
  vim.ui.select(items, {
    prompt = "Select CopilotChat action:",
    format_item = function(item)
      return item.name
    end,
  }, function(choice)
    if choice then
      choice.action()
    end
  end)
end

-- Copilot Chat keymaps
vim.keymap.set("n", "<A-k>", CopilotChatBuffer, { desc = "Copilot Chat Buffer" })
vim.keymap.set("v", "<A-k>", CopilotChatBuffer, { desc = "Copilot Chat Buffer" })
vim.keymap.set("n", "<A-l>", ShowChatPrompt, { desc = "Show Copilot Chat Prompt" })
vim.keymap.set("v", "<A-l>", ShowChatPrompt, { desc = "Show Copilot Chat Prompt" })
