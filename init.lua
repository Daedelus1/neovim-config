-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Load snippets from ~/.config/nvim/LuaSnip/
require("luasnip.loaders.from_lua").load({ paths = "~/AppData/Local/nvim/LuaSnip/" })

vim.cmd("colorscheme everforest")

-- Somewhere in your Neovim startup, e.g. init.lua
require("luasnip").config.set_config({ -- Setting LuaSnip config

  -- Enable autotriggered snippets
  enable_autosnippets = true,

  -- Use Tab (or some other key if you prefer) to trigger visual selection
  store_selection_keys = "<Tab>",
})

require("nvim-dap-projects").search_project_config()
