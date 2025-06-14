local ls = require("luasnip")
local f = ls.function_node
local d = ls.dynamic_node
local r = ls.restore_node

local generate_matrix = function(args, snip)
  local rows = tonumber(snip.captures[2])
  local cols = tonumber(snip.captures[3])
  local nodes = {}
  local ins_indx = 1
  for j = 1, rows do
    table.insert(nodes, r(ins_indx, tostring(j) .. "x1", i(1)))
    ins_indx = ins_indx + 1
    for k = 2, cols do
      table.insert(nodes, t(" & "))
      table.insert(nodes, r(ins_indx, tostring(j) .. "x" .. tostring(k), i(1)))
      ins_indx = ins_indx + 1
    end
    table.insert(nodes, t({ " \\\\", "" }))
  end
  nodes[#nodes] = t(" \\\\")
  return sn(nil, nodes)
end

local generate_hom_matrix = function(args, snip)
  local rows = tonumber(snip.captures[2])
  local cols = tonumber(snip.captures[3])
  local nodes = {}
  local ins_indx = 1
  for j = 1, rows do
    if j == 1 then
      table.insert(nodes, r(ins_indx, i(1)))
      table.insert(nodes, t("_{11}"))
    else
      table.insert(nodes, rep(1))
      table.insert(nodes, t("_{" .. tostring(j) .. "1}"))
    end
    ins_indx = ins_indx + 1
    for k = 2, cols do
      table.insert(nodes, t(" & "))
      table.insert(nodes, rep(1))
      table.insert(nodes, t("_{" .. tostring(j) .. tostring(k) .. "}"))
      ins_indx = ins_indx + 1
    end
    table.insert(nodes, t({ " \\\\", "" }))
  end
  nodes[#nodes] = t(" \\\\")
  return sn(nil, nodes)
end

return {

  -- Common Operations
  s(
    { trig = ".ff", snippetType = "autosnippet", desc = "Fraction", condition = InMathzone },
    fmta("\\frac{<>}{<>}", { i(1), i(2) })
  ),
  s(
    { trig = ".lim", snippetType = "autosnippet", desc = "Limit", condition = InMathzone },
    fmta("\\lim_{<> \\to <>}", { i(1), i(2) })
  ),
  s(
    { trig = ".din", snippetType = "autosnippet", desc = "Definite Integral", condition = InMathzone },
    fmta("\\int_{<>}^{<>}", { i(1), i(2) })
  ),
  s(
    { trig = ".ind", snippetType = "autosnippet", desc = "Indefinite Integral", condition = InMathzone },
    fmta("\\int ", {})
  ),

  -- Matrix-like environments

  s({ trig = ".([bBpvV])(%d+)x(%d+)%s", name = "New matrix", snippetType = "autosnippet", regTrig = true }, {
    t("\\begin{"),
    f(function(_, snip)
      return snip.captures[1] .. "matrix"
    end),
    t("}"),
    t({ "", "" }),
    d(1, generate_matrix),
    t({ "", "" }),
    t("\\end{"),
    f(function(_, snip)
      return snip.captures[1] .. "matrix"
    end),
    t("}"),
  }, { condition = InMathzone }),

  s(
    { trig = ".([bBpvV])(%d+)h(%d+)%s", name = "New homogeneous matrix", snippetType = "autosnippet", regTrig = true },
    {
      t("\\begin{"),
      f(function(_, snip)
        return snip.captures[1] .. "matrix"
      end),
      t("}"),
      t({ "", "" }),
      d(1, generate_hom_matrix),
      t({ "", "" }),
      t("\\end{"),
      f(function(_, snip)
        return snip.captures[1] .. "matrix"
      end),
      t("}"),
    },
    { condition = InMathzone }
  ),
}
