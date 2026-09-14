local M = {}

-- Aliases a native filetype to a base ftplugin: registers treesitter_lang for the
-- current filetype first, then force-sources ftplugin/<base>.vim|.lua. The
-- treesitter registration still happens when base_filetype is empty.
function M.setup(base_filetype, treesitter_lang)
  if treesitter_lang and vim.treesitter and vim.treesitter.language then
    pcall(vim.treesitter.language.register, treesitter_lang, vim.bo.filetype)
  end

  if not base_filetype or base_filetype == "" then return end

  vim.cmd.runtime { ("ftplugin/%s.vim"):format(base_filetype), bang = true }
  vim.cmd.runtime { ("ftplugin/%s.lua"):format(base_filetype), bang = true }
end

return M
