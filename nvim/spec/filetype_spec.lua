require "nvim.spec.spec_helper"

describe("filetype overrides", function()
  local captured

  before_each(function()
    captured = nil

    package.loaded["filetype"] = nil

    vim.filetype = {
      add = function(definitions)
        captured = definitions
      end,
    }
  end)

  it("registers specialized yaml filetypes required by lspconfig", function()
    require "filetype"

    assert.is_table(captured)
    assert.is_table(captured.filename)
    assert.equals("yaml.docker-compose", captured.filename["docker-compose.yaml"])
    assert.equals("yaml.docker-compose", captured.filename["compose.yml"])
    assert.equals("yaml.gitlab", captured.filename[".gitlab-ci.yml"])
    assert.equals("yaml.helm-values", captured.filename["values.yaml"])
  end)

  it("registers explicit extensions for nonstandard lsp filetypes", function()
    require "filetype"

    assert.is_table(captured)
    assert.is_table(captured.extension)
    assert.equals("gotmpl", captured.extension.gotmpl)
  end)
end)
