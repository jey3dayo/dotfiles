-- Linting and formatting for Python belong to ruff (LSP) and conform; pylsp is
-- kept only for jedi-backed completion, definition and hover. Leaving these
-- plugins enabled reports the same finding twice.
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
