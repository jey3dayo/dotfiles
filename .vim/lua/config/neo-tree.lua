local neo_tree = safe_require "neo-tree"
if not neo_tree then
  return
end

neo_tree.setup {
  filesystem = {
    window = {
      mappings = {
        -- disable fuzzy finder
        ["/"] = "noop",
        ["T"] = { "toggle_preview", config = { use_float = true } },
      },
    },
    filtered_items = {
      visible = true,
      hide_dotfiles = false,
    },
  },
}

Keymap("<Leader>e", ":<C-u>Neotree toggle<CR>")
