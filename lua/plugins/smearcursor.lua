if vim.g.neovide then
  return {}
end

return {
  "sphamba/smear-cursor.nvim",
  opts = { -- Default Range
    stiffness = 0.5, -- 0.6 [0, 1]
    trailing_stiffness = 0.49, -- 0.3 [0, 1]
    -- distance_stop_animating = 0.5, -- 0.1 > 0
  },
}
