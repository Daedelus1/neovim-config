-- disables autocomplete in comments
require("cmp").setup({
  enabled = function()
    local disabled = false
    disabled = disabled or (vim.api.nvim_get_option_value("buftype", { buf = 0 }) == "prompt")
    disabled = disabled or (vim.fn.reg_recording() ~= "")
    disabled = disabled or (vim.fn.reg_executing() ~= "")
    disabled = disabled or require("cmp.config.context").in_treesitter_capture("comment")
    return not disabled
  end,
})

vim.g.automatic_suggestion_management_enabled = true

function RefreshCmpState()
  require("cmp").setup({
    enabled = function()
      local disabled = false
      disabled = disabled or (vim.api.nvim_get_option_value("buftype", { buf = 0 }) == "prompt")
      disabled = disabled or (vim.fn.reg_recording() ~= "")
      disabled = disabled or (vim.fn.reg_executing() ~= "")
      disabled = disabled or require("cmp.config.context").in_treesitter_capture("comment")
      disabled = disabled or not vim.b.cmp_enabled
      return not disabled
    end,
  })
end

return {}
