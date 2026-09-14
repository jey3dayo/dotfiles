local function read_file(path)
  local handle = assert(io.open(path, "r"))
  local content = handle:read "*a"
  handle:close()
  return content
end

describe("zsh performance-sensitive loading", function()
  it("keeps Sheldon plugins out of the synchronous startup path", function()
    local content = read_file "zsh/lib/abbr.zsh"

    -- 重い plugin は precmd で遅延ロードし、起動時に sheldon cache を source しない。
    assert.matches("add%-zsh%-hook precmd _zsh_load_abbr_once", content)
    assert.is_nil(content:match 'source%s+%"%$sheldon_cache%"')
  end)

  it("restores Sheldon plugins lazily via the noop template", function()
    local content = read_file "zsh/sheldon/plugins.toml"

    assert.matches('%[templates%].-noop%s=%s%""', content)
    for _, plugin in ipairs { "zsh%-abbr", "fzf%-tab", "zsh%-autosuggestions", "fast%-syntax%-highlighting" } do
      assert.matches("%[plugins%." .. plugin .. "%]", content)
    end
    -- 削除済み plugin が復活していないこと。
    assert.is_nil(content:match "pnpm%-shell%-completion")
    assert.is_nil(content:match "ohmyzsh")
  end)
end)
