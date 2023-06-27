vim.g.increment_activator_filetype_candidates = {
  _ = {
    { "info", "warning", "notice", "error", "success" },
    { "mini", "small", "medium", "large", "xlarge", "xxlarge" },
    { "static", "absolute", "relative", "fixed", "sticky" },
    { "height", "width" },
    { "left", "right", "top", "bottom" },
    { "enable", "disable" },
    { "enabled", "disabled" },
    { "should", "should_not" },
    { "be_file", "be_directory" },
    { "div", "span", "Box" },
    { "column", "row" },
    { "start", "end" },
    { "head", "tail" },
    { "get", "post" },
    { "margin", "padding" },
    { "primary", "secondary", "tertiary" },
    { "development", "staging", "production" },
    { "const", "let" },
    { "dark", "medium", "light" },
  },
  ruby = {
    { "if", "unless" },
    { "nil", "empty", "blank" },
    { "string", "text", "integer", "float", "datetime", "timestamp", "timestamp" },
  },
  javascript = {
    { "props", "state" },
  },
  typescript = {
    { "string", "number", "boolean", "null", "undefined", "unknown" },
    { "void", "never" },
  },
  ["git-rebase-todo"] = {
    { "pick", "reword", "edit", "squash", "fixup", "exec" },
  },
}
