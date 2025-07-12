local utils = require "core.utils"

local function get_pre_hook()
  local ts_context = utils.safe_require "ts_context_commentstring.integrations.comment_nvim"
  if ts_context then return ts_context.create_pre_hook() end
  return nil
end

return {
  pre_hook = get_pre_hook(),
}
