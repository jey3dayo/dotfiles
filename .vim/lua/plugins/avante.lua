local deps = require "core.dependencies"

return {
  {
    "yetone/avante.nvim",
    cmd = { "AvanteAsk", "AvanteEdit", "AvanteRefresh" },
    keys = {
      { "<A-l>", desc = "Avante Ask" },
      { "<A-i>", desc = "Avante Edit" },
      { "<A-k>", desc = "Avante Focus" },
    },
    enabled = true,
    version = false,
    opts = {
      provider = "openai",
      providers = {
        openai = {
          endpoint = "https://api.openai.com/v1",
          model = "gpt-4o",
          timeout = 30000,
          disable_tools = true,
          extra_request_body = {
            temperature = 0,
            max_completion_tokens = 8192,
          },
        },
      },
      behaviour = {
        auto_suggestions = true,
        auto_set_highlight_group = true,
        auto_set_keymaps = true,
      },
      windows = {
        position = "right",
        width = 40,
        ask = {
          floating = true,
          start_insert = true,
          border = "rounded",
        },
      },
      mappings = {
        ask = "<A-l>",
        edit = "<A-i>",
        focus = "<A-k>",
        submit = {
          insert = "<S-Enter>",
        },
      },
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = vim.list_extend(
      vim.list_extend(vim.list_extend(deps.treesitter, deps.dressing), vim.list_extend(deps.plenary, deps.nui)),
      vim.list_extend(
        vim.list_extend(deps.telescope, deps.cmp),
        vim.list_extend(deps.web_devicons, {
          {
            -- support for image pasting
            "HakonHarnes/img-clip.nvim",
            event = "VeryLazy",
            opts = {
              -- recommended settings
              default = {
                embed_image_as_base64 = false,
                prompt_for_file_name = false,
                drag_and_drop = {
                  insert_mode = true,
                },
                -- required for Windows users
                use_absolute_path = true,
              },
            },
          },
          {
            "MeanderingProgrammer/render-markdown.nvim",
            opts = {
              file_types = { "Avante" },
              latex = {
                enabled = true,
              },
              html = {
                enabled = true,
              },
              render_modes = { "n", "c", "t" },
              preset = "obsidian",
            },
            ft = { "Avante" },
          },
        })
      )
    ),
  },
}
