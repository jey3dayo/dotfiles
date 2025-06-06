local function get_pre_hook()
  local ok, ts_context = pcall(require, "ts_context_commentstring.integrations.comment_nvim")
  if ok then
    return ts_context.create_pre_hook()
  end
  return nil
end

return {
  pre_hook = get_pre_hook(),
}
