local tex_utils = {}
tex_utils.in_mathzone = function() -- math context detection
  return vim.fn["vimtex#syntax#in_mathzone"]() == 1
end
tex_utils.in_text = function()
  return not tex_utils.in_mathzone()
end
tex_utils.in_comment = function() -- comment detection
  return vim.fn["vimtex#syntax#in_comment"]() == 1
end
tex_utils.in_env = function(name) -- generic environment detection
  local is_inside = vim.fn["vimtex#env#is_inside"](name)
  return (is_inside[1] > 0 and is_inside[2] > 0)
end
-- A few concrete environments---adapt as needed
tex_utils.in_equation = function() -- equation environment detection
  return tex_utils.in_env("equation")
end
tex_utils.in_itemize = function() -- itemize environment detection
  return tex_utils.in_env("itemize")
end
tex_utils.in_tikz = function() -- TikZ picture environment detection
  return tex_utils.in_env("tikzpicture")
end

local line_begin = require("luasnip.extras.expand_conditions").line_begin

return {
  -- text fractions
  s({ trig = ",12", snippetType = "autosnippet" }, { t("½") }),
  s({ trig = ",13", snippetType = "autosnippet" }, { t("⅓") }),
  s({ trig = ",23", snippetType = "autosnippet" }, { t("⅔") }),
  s({ trig = ",14", snippetType = "autosnippet" }, { t("¼") }),
  s({ trig = ",34", snippetType = "autosnippet" }, { t("¾") }),
  s({ trig = ",15", snippetType = "autosnippet" }, { t("⅕") }),
  s({ trig = ",25", snippetType = "autosnippet" }, { t("⅖") }),
  s({ trig = ",35", snippetType = "autosnippet" }, { t("⅗") }),
  s({ trig = ",45", snippetType = "autosnippet" }, { t("⅘") }),
  s({ trig = ",16", snippetType = "autosnippet" }, { t("⅙") }),
  s({ trig = ",56", snippetType = "autosnippet" }, { t("⅚") }),
  s({ trig = ",18", snippetType = "autosnippet" }, { t("⅛") }),
  s({ trig = ",38", snippetType = "autosnippet" }, { t("⅜") }),
  s({ trig = ",58", snippetType = "autosnippet" }, { t("⅝") }),
  s({ trig = ",78", snippetType = "autosnippet" }, { t("⅞") }),
  s(
    { trig = ",rstep", snippetType = "autosnippet", desc = "Adds a step to the recipe" },
    fmta("\\begin{step}\n<>\n\\method\n<>\n\\end{step}\n<>", { i(2), i(1), i(0) })
  ),
}
