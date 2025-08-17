-- Summary: When `LS_SELECT_RAW` is populated with a visual selection, the function
-- returns an insert node whose initial text is set to the visual selection.
-- When `LS_SELECT_RAW` is empty, the function simply returns an empty insert node.
local get_visual = function(args, parent)
  if #parent.snippet.env.LS_SELECT_RAW > 0 then
    return sn(nil, i(1, parent.snippet.env.LS_SELECT_RAW))
  else -- If LS_SELECT_RAW is empty, return a blank insert node
    return sn(nil, i(1))
  end
end
-- Example: expanding a snippet on a new line only.
-- In a snippet file, first require the line_begin condition...
local line_begin = require('luasnip.extras.expand_conditions').line_begin

return {
  -- Toggle Autocomplete
  s(
    { trig = ';aut', snippetType = 'autosnippet', desc = 'Toggle Autocomplete' },
    f(function()
      if vim.b.cmp_enabled then
        vim.b.cmp_enabled = false
        vim.print 'Suggestions Disabled'
      else
        vim.b.cmp_enabled = true
        vim.print 'Suggestions Enabled'
      end
      RefreshCmpState()
    end)
  ),
}
