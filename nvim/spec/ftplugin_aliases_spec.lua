require "nvim.spec.spec_helper"

describe("ftplugin aliases for LSP-only filetypes", function()
  local nvim_dir = (os.getenv "PWD" or io.popen("pwd"):read "*l"):match "/nvim$"
      and (os.getenv "PWD" or io.popen("pwd"):read "*l")
    or (os.getenv "PWD" or io.popen("pwd"):read "*l") .. "/nvim"

  local expected = {
    "aspnetcorerazor",
    "astro-markdown",
    "blade",
    "django-html",
    "edge",
    "eelixir",
    "ejs",
    "erb",
    "gohtml",
    "gohtmltmpl",
    "gotmpl",
    "gowork",
    "hbs",
    "html-eex",
    "jade",
    "leaf",
    "markdown.mdx",
    "mdx",
    "mustache",
    "njk",
    "nunjucks",
    "postcss",
    "razor",
    "reason",
    "slim",
    "sugarss",
    "templ",
    "terraform-vars",
  }

  it("ships runtime alias files for health-check filetypes", function()
    for _, filetype in ipairs(expected) do
      local path = string.format("%s/ftplugin/%s.lua", nvim_dir, filetype)
      local fh = io.open(path, "r")
      assert.is_not_nil(fh, "missing alias file: " .. path)
      if fh then fh:close() end
    end
  end)
end)
