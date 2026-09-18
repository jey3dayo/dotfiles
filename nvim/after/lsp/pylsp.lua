-- Python linting and formatting belong to ruff (LSP) and conform; pylsp is kept
-- for jedi completion/definition/hover. Enabled, these report findings twice.
return {
  settings = {
    pylsp = {
      plugins = {
        autopep8 = { enabled = false },
        black = { enabled = false },
        flake8 = { enabled = false },
        mccabe = { enabled = false },
        pycodestyle = { enabled = false },
        pydocstyle = { enabled = false },
        pyflakes = { enabled = false },
        pylint = { enabled = false },
        yapf = { enabled = false },
      },
    },
  },
}
