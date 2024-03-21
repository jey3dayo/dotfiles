local diffview = safe_require "diffview"

if not diffview then
  return
end

diffview.setup {
  view = {
    default = {},
  },
}
