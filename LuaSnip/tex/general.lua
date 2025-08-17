local tex_utils = {}
tex_utils.in_mathzone = function() -- math context detection
  return vim.fn['vimtex#syntax#in_mathzone']() == 1
end
tex_utils.in_text = function()
  return not tex_utils.in_mathzone()
end
tex_utils.in_comment = function() -- comment detection
  return vim.fn['vimtex#syntax#in_comment']() == 1
end
tex_utils.in_env = function(name) -- generic environment detection
  local is_inside = vim.fn['vimtex#env#is_inside'](name)
  return (is_inside[1] > 0 and is_inside[2] > 0)
end
-- A few concrete environments
-- adapt as needed
tex_utils.in_equation = function() -- equation environment detection
  return tex_utils.in_env 'equation'
end
tex_utils.in_itemize = function() -- itemize environment detection
  return tex_utils.in_env 'itemize'
end
tex_utils.in_tikz = function() -- TikZ picture environment detection
  return tex_utils.in_env 'tikzpicture'
end

local line_begin = require('luasnip.extras.expand_conditions').line_begin
return {
  -- text fractions
  s({ trig = '(.*),12', regTrig = true, snippetType = 'autosnippet' }, { f(function(_, snip)
    return snip.captures[1]
  end), t '½' }),
  s({ trig = '(.*),13', regTrig = true, snippetType = 'autosnippet' }, { f(function(_, snip)
    return snip.captures[1]
  end), t '⅓' }),
  s({ trig = '(.*),23', regTrig = true, snippetType = 'autosnippet' }, { f(function(_, snip)
    return snip.captures[1]
  end), t '⅔' }),
  s({ trig = '(.*),14', regTrig = true, snippetType = 'autosnippet' }, { f(function(_, snip)
    return snip.captures[1]
  end), t '¼' }),
  s({ trig = '(.*),34', regTrig = true, snippetType = 'autosnippet' }, { f(function(_, snip)
    return snip.captures[1]
  end), t '¾' }),
  s({ trig = '(.*),15', regTrig = true, snippetType = 'autosnippet' }, { f(function(_, snip)
    return snip.captures[1]
  end), t '⅕' }),
  s({ trig = '(.*),25', regTrig = true, snippetType = 'autosnippet' }, { f(function(_, snip)
    return snip.captures[1]
  end), t '⅖' }),
  s({ trig = '(.*),35', regTrig = true, snippetType = 'autosnippet' }, { f(function(_, snip)
    return snip.captures[1]
  end), t '⅗' }),
  s({ trig = '(.*),45', regTrig = true, snippetType = 'autosnippet' }, { f(function(_, snip)
    return snip.captures[1]
  end), t '⅘' }),
  s({ trig = '(.*),16', regTrig = true, snippetType = 'autosnippet' }, { f(function(_, snip)
    return snip.captures[1]
  end), t '⅙' }),
  s({ trig = '(.*),56', regTrig = true, snippetType = 'autosnippet' }, { f(function(_, snip)
    return snip.captures[1]
  end), t '⅚' }),
  s({ trig = '(.*),18', regTrig = true, snippetType = 'autosnippet' }, { f(function(_, snip)
    return snip.captures[1]
  end), t '⅛' }),
  s({ trig = '(.*),38', regTrig = true, snippetType = 'autosnippet' }, { f(function(_, snip)
    return snip.captures[1]
  end), t '⅜' }),
  s({ trig = '(.*),58', regTrig = true, snippetType = 'autosnippet' }, { f(function(_, snip)
    return snip.captures[1]
  end), t '⅝' }),
  s({ trig = '(.*),78', regTrig = true, snippetType = 'autosnippet' }, { f(function(_, snip)
    return snip.captures[1]
  end), t '⅞' }),

  -- Degrees Fahrenheit
  s({ trig = '([^%s]*)(%s*),df', regTrig = true, snippetType = 'autosnippet' }, { f(function(_, snip)
    return snip.captures[1]
  end), t '°F' }),
  -- Degrees Celsius
  s({ trig = '([^%s]*)(%s*),dc', regTrig = true, snippetType = 'autosnippet' }, { f(function(_, snip)
    return snip.captures[1]
  end), t '°C' }),
  -- Teaspoon
  s({ trig = ',ts', snippetType = 'autosnippet' }, { t 'Teaspoon' }),
  -- Tablespoon
  s({ trig = ',tb', snippetType = 'autosnippet' }, { t 'Tablespoon' }),
  -- Cup
  s({ trig = ',cu', snippetType = 'autosnippet' }, { t 'Cup' }),
  -- Ounce
  s({ trig = ',oz', snippetType = 'autosnippet' }, { t 'Ounce' }),

  -- Recipe Step
  s(
    { trig = ',rstep', snippetType = 'autosnippet', desc = 'Adds a step to the recipe' },
    fmta('\\begin{step}\n<>\n\\method\n<>\n\\end{step}\n<>', { i(2), i(1), i(0) })
  ),
}
