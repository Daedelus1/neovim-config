return {
  "lervag/vimtex",
  lazy = false,
  config = function()
    vim.g.vimtex_view_method = "general"
    vim.g.vimtex_general_viewer = "okular"
    vim.g.vimtex_compiler_latexmk = {
      options = {
        "-synctex=1",
      },
      aux_dir = "./.latexmk/aux",
      out_dir = "./.latexmk/out",
    }
  end,
  keys = {
    { "<localLeader>l", "", desc = "+vimtex" },
  },
}
