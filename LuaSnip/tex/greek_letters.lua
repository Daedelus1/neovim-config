InMathzone = function() -- math context detection
  return vim.fn['vimtex#syntax#in_mathzone']() == 1
end

return {
  -- Greek Letters
  s({ trig = ',al', snippetType = 'autosnippet' }, { t '\\alpha' }),
  s({ trig = ',be', snippetType = 'autosnippet' }, { t '\\beta' }),
  s({ trig = ',ga', snippetType = 'autosnippet' }, { t '\\gamma' }),
  s({ trig = ',de', snippetType = 'autosnippet' }, { t '\\delta' }),
  s({ trig = ',ep', snippetType = 'autosnippet' }, { t '\\varepsilon' }),
  s({ trig = ',ze', snippetType = 'autosnippet' }, { t '\\zeta' }),
  s({ trig = ',et', snippetType = 'autosnippet' }, { t '\\eta' }),
  s({ trig = ',th', snippetType = 'autosnippet' }, { t '\\theta' }),
  s({ trig = ',io', snippetType = 'autosnippet' }, { t '\\iota' }),
  s({ trig = ',ka', snippetType = 'autosnippet' }, { t '\\kappa' }),
  s({ trig = ',la', snippetType = 'autosnippet' }, { t '\\lambda' }),
  s({ trig = ',mu', snippetType = 'autosnippet' }, { t '\\mu' }),
  s({ trig = ',nu', snippetType = 'autosnippet' }, { t '\\nu' }),
  s({ trig = ',xi', snippetType = 'autosnippet' }, { t '\\xi' }),
  s({ trig = ',pi', snippetType = 'autosnippet' }, { t '\\pi' }),
  s({ trig = ',rh', snippetType = 'autosnippet' }, { t '\\rho' }),
  s({ trig = ',si', snippetType = 'autosnippet' }, { t '\\sigma' }),
  s({ trig = ',ta', snippetType = 'autosnippet' }, { t '\\tau' }),
  s({ trig = ',up', snippetType = 'autosnippet' }, { t '\\upsilon' }),
  s({ trig = ',ph', snippetType = 'autosnippet' }, { t '\\phi' }),
  s({ trig = ',ch', snippetType = 'autosnippet' }, { t '\\chi' }),
  s({ trig = ',ps', snippetType = 'autosnippet' }, { t '\\psi' }),
  s({ trig = ',om', snippetType = 'autosnippet' }, { t '\\omega' }),
  -- Greek Letters
  s({ trig = ',Ga', snippetType = 'autosnippet' }, { t '\\Gamma' }),
  s({ trig = ',De', snippetType = 'autosnippet' }, { t '\\Delta' }),
  s({ trig = ',Th', snippetType = 'autosnippet' }, { t '\\Theta' }),
  s({ trig = ',La', snippetType = 'autosnippet' }, { t '\\Lambda' }),
  s({ trig = ',Xi', snippetType = 'autosnippet' }, { t '\\Xi' }),
  s({ trig = ',Pi', snippetType = 'autosnippet' }, { t '\\Pi' }),
  s({ trig = ',Si', snippetType = 'autosnippet' }, { t '\\Sigma' }),
  s({ trig = ',Up', snippetType = 'autosnippet' }, { t '\\Upsilon' }),
  s({ trig = ',Ph', snippetType = 'autosnippet' }, { t '\\Phi' }),
  s({ trig = ',Ps', snippetType = 'autosnippet' }, { t '\\Psi' }),
  s({ trig = ',Om', snippetType = 'autosnippet' }, { t '\\Omega' }),
}
