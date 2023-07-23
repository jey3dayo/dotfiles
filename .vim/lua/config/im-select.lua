if os.getenv "WSLENV" then
  return
end

require("im_select").setup {
  default_im_select = "ms.inputmethod.atok33.Roman",
}
