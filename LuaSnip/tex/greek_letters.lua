InMathzone = function() -- math context detection
  return vim.fn["vimtex#syntax#in_mathzone"]() == 1
end

return {
  -- Greek Letters
  s({ trig = ";al", snippetType = "autosnippet", condition = InMathzone }, { t("\\alpha") }),
  s({ trig = ";be", snippetType = "autosnippet", condition = InMathzone }, { t("\\beta") }),
  s({ trig = ";ga", snippetType = "autosnippet", condition = InMathzone }, { t("\\gamma") }),
  s({ trig = ";de", snippetType = "autosnippet", condition = InMathzone }, { t("\\delta") }),
  s({ trig = ";ep", snippetType = "autosnippet", condition = InMathzone }, { t("\\varepsilon") }),
  s({ trig = ";ze", snippetType = "autosnippet", condition = InMathzone }, { t("\\zeta") }),
  s({ trig = ";et", snippetType = "autosnippet", condition = InMathzone }, { t("\\eta") }),
  s({ trig = ";th", snippetType = "autosnippet", condition = InMathzone }, { t("\\theta") }),
  s({ trig = ";io", snippetType = "autosnippet", condition = InMathzone }, { t("\\iota") }),
  s({ trig = ";ka", snippetType = "autosnippet", condition = InMathzone }, { t("\\kappa") }),
  s({ trig = ";la", snippetType = "autosnippet", condition = InMathzone }, { t("\\lambda") }),
  s({ trig = ";mu", snippetType = "autosnippet", condition = InMathzone }, { t("\\mu") }),
  s({ trig = ";nu", snippetType = "autosnippet", condition = InMathzone }, { t("\\nu") }),
  s({ trig = ";xi", snippetType = "autosnippet", condition = InMathzone }, { t("\\xi") }),
  s({ trig = ";pi", snippetType = "autosnippet", condition = InMathzone }, { t("\\pi") }),
  s({ trig = ";rh", snippetType = "autosnippet", condition = InMathzone }, { t("\\rho") }),
  s({ trig = ";si", snippetType = "autosnippet", condition = InMathzone }, { t("\\sigma") }),
  s({ trig = ";ta", snippetType = "autosnippet", condition = InMathzone }, { t("\\tau") }),
  s({ trig = ";up", snippetType = "autosnippet", condition = InMathzone }, { t("\\upsilon") }),
  s({ trig = ";ph", snippetType = "autosnippet", condition = InMathzone }, { t("\\phi") }),
  s({ trig = ";ch", snippetType = "autosnippet", condition = InMathzone }, { t("\\chi") }),
  s({ trig = ";ps", snippetType = "autosnippet", condition = InMathzone }, { t("\\psi") }),
  s({ trig = ";om", snippetType = "autosnippet", condition = InMathzone }, { t("\\omega") }),
  -- Greek Letters
  s({ trig = ";Ga", snippetType = "autosnippet", condition = InMathzone }, { t("\\Gamma") }),
  s({ trig = ";De", snippetType = "autosnippet", condition = InMathzone }, { t("\\Delta") }),
  s({ trig = ";Th", snippetType = "autosnippet", condition = InMathzone }, { t("\\Theta") }),
  s({ trig = ";La", snippetType = "autosnippet", condition = InMathzone }, { t("\\Lambda") }),
  s({ trig = ";Xi", snippetType = "autosnippet", condition = InMathzone }, { t("\\Xi") }),
  s({ trig = ";Pi", snippetType = "autosnippet", condition = InMathzone }, { t("\\Pi") }),
  s({ trig = ";Si", snippetType = "autosnippet", condition = InMathzone }, { t("\\Sigma") }),
  s({ trig = ";Up", snippetType = "autosnippet", condition = InMathzone }, { t("\\Upsilon") }),
  s({ trig = ";Ph", snippetType = "autosnippet", condition = InMathzone }, { t("\\Phi") }),
  s({ trig = ";Ps", snippetType = "autosnippet", condition = InMathzone }, { t("\\Psi") }),
  s({ trig = ";Om", snippetType = "autosnippet", condition = InMathzone }, { t("\\Omega") }),
}
