local comment = safe_require "Comment"

if not comment then
  return
end

comment.setup {
  pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
}
