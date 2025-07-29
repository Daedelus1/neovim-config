-- Autocmds are automatically loaded on the VeryLazy event
--
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local get_inner_tex_env = function()
  return vim.fn["vimtex#env#get_inner"]().name
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text" },
  callback = function()
    vim.opt_local.spell = false
  end,
})

-- Automatic Suggestion Management evaluated
local last_state = true
-- Fires on cursor movement and buffer changes in `.tex` files
vim.api.nvim_create_autocmd({ "CursorMovedI", "CursorMoved", "TextChanged", "TextChangedI" }, {
  pattern = "*.tex",
  callback = function()
    -- Allows manual disabling of system without deleting the autocmd
    if not vim.g.automatic_suggestion_management_enabled then
      return
    end

    -- Only passes this latch when the environment changes from a suggestion-disabled environment
    -- to a suggestion-enabled environment or vice-versa
    local current_env = get_inner_tex_env()
    local current_state = current_env == "step"
    if current_state == last_state then
      return
    end
    last_state = current_state

    if current_state then
      vim.b.cmp_enabled = false
      vim.print("Suggestions Disabled - Automatic")
    else
      vim.b.cmp_enabled = true
      vim.print("Suggestions Enabled - Automatic")
    end
    RefreshCmpState()
  end,
})
