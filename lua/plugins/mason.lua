return {
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "lua_ls",
        "rust_analyzer",
        "harper_ls",
        "pyright",
        "clangd",
      },
    },
  },
}
