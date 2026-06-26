local function read_file(path)
  local handle = assert(io.open(path, "r"))
  local content = handle:read "*a"
  handle:close()
  return content
end

describe("zsh performance-sensitive loading", function()
  it("keeps Sheldon plugins out of the synchronous startup path", function()
    local content = read_file "zsh/lib/plugins.zsh"

    assert.matches("dotfiles_load_sheldon_plugins%(%)", content)
    assert.matches("ZSH_LOAD_PLUGINS", content)
    assert.matches("add%-zle%-hook%-widget zle%-line%-init dotfiles_zle_line_init", content)
    assert.is_nil(content:match 'source%s+%"%$_dotfiles_sheldon_cache%"')
  end)

  it("keeps restored Sheldon plugins out of the generated source cache", function()
    local content = read_file "zsh/sheldon/plugins.toml"

    assert.matches("%[plugins%.zsh%-abbr%]", content)
    assert.matches('%[templates%].-noop%s=%s%""', content)
    assert.is_not_nil(content:find('[plugins.fzf-tab]\ngithub = "Aloxaf/fzf-tab"\napply = ["noop"]', 1, true))
    assert.is_not_nil(
      content:find('[plugins.zsh-autosuggestions]\ngithub = "zsh-users/zsh-autosuggestions"\napply = ["noop"]', 1, true)
    )
    assert.is_not_nil(
      content:find(
        '[plugins.fast-syntax-highlighting]\ngithub = "zdharma-continuum/fast-syntax-highlighting"\napply = ["noop"]',
        1,
        true
      )
    )
    assert.is_nil(content:match "pnpm%-shell%-completion")
    assert.is_nil(content:match "ohmyzsh")
  end)
end)
