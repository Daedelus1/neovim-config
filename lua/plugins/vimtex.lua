return {
  "lervag/vimtex",
  lazy = false,
  config = function()
    vim.g.vimtex_view_method = "general"
    vim.g.vimtex_general_viewer = "okular"
    vim.g.vimtex_compiler_progname = "nvr"
    vim.g.vimtex_quickfix_method = "latexlog"
    vim.g.vimtex_compiler_latexmk = {
      options = {
        "-pdf",
        "-shell-escape",
        "-interaction=nonstopmode",
        "-synctex=1",
      },
      aux_dir = "./.latexmk/aux",
      out_dir = "./.latexmk/out",
    }
  end,
  keys = {
    { "<localLeader>l", "", desc = "+vimtex" },
  },
  ft = { "tex", "latex", "rnw" },
}
