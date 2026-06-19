local function read_file(path)
  local handle = assert(io.open(path, "r"))
  local content = handle:read "*a"
  handle:close()
  return content
end

describe("zsh performance-sensitive loading", function()
  it("keeps history UI integration off the synchronous tool loader path", function()
    local content = read_file "zsh/config/loaders/tools.zsh"
    local critical_tools = assert(content:match "critical_tools=%(([^%)]*)%)")

    assert.matches("%f[%w]fzf%f[%W]", critical_tools)
    assert.matches("%f[%w]mise%f[%W]", critical_tools)
    assert.matches("%f[%w]starship%f[%W]", critical_tools)
    assert.is_nil(critical_tools:match "%f[%w]atuin%f[%W]")
    assert.matches('atuin%)%s+zsh%-defer %-t "?%$DEFER_ATUIN_SECONDS"?', content)
  end)
end)
