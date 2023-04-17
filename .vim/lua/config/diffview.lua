local status, diffview = pcall(require, "diffview")
if not status then
  return
end

diffview.setup {
  view = {
    default = {},
  },
}
