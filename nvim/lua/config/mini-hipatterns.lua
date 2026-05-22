local M = {}

local css_colors = {
  red = "#ff0000",
  green = "#008000",
  blue = "#0000ff",
  yellow = "#ffff00",
  orange = "#ffa500",
  purple = "#800080",
  pink = "#ffc0cb",
  brown = "#a52a2a",
  gray = "#808080",
  grey = "#808080",
  black = "#000000",
  white = "#ffffff",
  cyan = "#00ffff",
  magenta = "#ff00ff",
  lime = "#00ff00",
  navy = "#000080",
  teal = "#008080",
  olive = "#808000",
  silver = "#c0c0c0",
  maroon = "#800000",
  fuchsia = "#ff00ff",
  aqua = "#00ffff",
  darkred = "#8b0000",
  darkgreen = "#006400",
  darkblue = "#00008b",
  lightred = "#ffcccb",
  lightgreen = "#90ee90",
  lightblue = "#add8e6",
  darkgray = "#a9a9a9",
  darkgrey = "#a9a9a9",
  lightgray = "#d3d3d3",
  lightgrey = "#d3d3d3",
}

local css_color_names = {
  "red",
  "green",
  "blue",
  "yellow",
  "orange",
  "purple",
  "pink",
  "brown",
  "gray",
  "grey",
  "black",
  "white",
  "cyan",
  "magenta",
  "lime",
  "navy",
  "teal",
  "olive",
  "silver",
  "maroon",
  "fuchsia",
  "aqua",
  "darkred",
  "darkgreen",
  "darkblue",
  "lightred",
  "lightgreen",
  "lightblue",
  "darkgray",
  "darkgrey",
  "lightgray",
  "lightgrey",
}

local css_color_pattern = "()%f[%a](" .. table.concat(css_color_names, "|") .. ")%f[%A]()"

local function css_name_highlighter(hipatterns)
  local hex = hipatterns.gen_highlighter.hex_color()

  return {
    pattern = css_color_pattern,
    group = function(_, match)
      local color = css_colors[match.full_match:lower()]
      if color then return hex(_, { full_match = color }) end
      return nil
    end,
  }
end

function M.setup()
  local hipatterns = require "mini.hipatterns"
  local hi_words = require("mini.extra").gen_highlighter.words

  hipatterns.setup {
    highlighters = {
      fixme = hi_words({ "FIXME", "Fixme", "fixme" }, "MiniHipatternsFixme"),
      hack = hi_words({ "HACK", "Hack", "hack" }, "MiniHipatternsHack"),
      todo = hi_words({ "TODO", "Todo", "todo" }, "MiniHipatternsTodo"),
      note = hi_words({ "NOTE", "Note", "note" }, "MiniHipatternsNote"),
      hex_color = hipatterns.gen_highlighter.hex_color(),
      css_names = css_name_highlighter(hipatterns),
    },
    delay = {
      text_change = 200,
      scroll = 50,
    },
  }
end

return M
