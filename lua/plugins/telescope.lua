return {
  "nvim-telescope/telescope.nvim",
  keys = {
    { "<leader>fF", false },
    -- change a keymap
    { "<leader> ", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files (cwd)" },
  },
}
