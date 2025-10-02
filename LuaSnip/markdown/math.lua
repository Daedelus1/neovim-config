return {
  -- Common Operations
  s({ trig = '.ff', snippetType = 'autosnippet', desc = 'Fraction', condition = InMathzone }, fmta('\\frac{<>}{<>}', { i(1), i(2) })),
  s({ trig = '.lim', snippetType = 'autosnippet', desc = 'Limit', condition = InMathzone }, fmta('\\lim_{<> \\to <>}', { i(1), i(2) })),
  s({ trig = '.din', snippetType = 'autosnippet', desc = 'Definite Integral', condition = InMathzone }, fmta('\\int_{<>}^{<>}', { i(1), i(2) })),
  s({ trig = '.ind', snippetType = 'autosnippet', desc = 'Indefinite Integral', condition = InMathzone }, fmta('\\int ', {})),
}
