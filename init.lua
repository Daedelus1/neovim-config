vim.loader.enable()
-- [[ Globals ]]
-- Custom Global Variables for running code
vim.g.run_code_command = "lua require('fidget').notify 'No run configuration set!'"
vim.g.test_code_command = "lua require('fidget').notify 'No test configuration set!'"
vim.g.build_code_command = "lua require('fidget').notify 'No build configuration set!'"
vim.g.clean_code_command = "lua require('fidget').notify 'No clean configuration set!'"
vim.g.codelldb_path = vim.fn.system(
    "echo /nix/store/$(ls /nix/store/ | grep -P \"vscode-extension-vadimcn-vscode-lldb-[0-9\\.]*(/|\\z)\")/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb")
vim.g.vim_window_id = vim.fn.system("xdotool getactivewindow")
vim.g.vimtex_word_count_status_line_cache = ''

-- [[Options]]
vim.g.mapleader = ' '       -- Set <space> as the leader key
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true -- Allows dependencies to use a nerd font
vim.o.relativenumber = true -- Relative Line Numbers
vim.o.number = true
vim.o.mouse = ''            -- Enable mouse mode, can be useful for resizing splits for example!
vim.o.showmode = false      -- Don't show the mode, since it's already in the status line
vim.schedule(function()     -- Sync clipboard between OS and Neovim.
    vim.o.clipboard = 'unnamedplus'
end)
vim.o.breakindent = true   -- Enable break indent
vim.o.undofile = true      -- Save undo history
vim.o.ignorecase = true    -- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.smartcase = true
vim.o.signcolumn = 'yes'   -- Keep signcolumn on by default
vim.o.updatetime = 250     -- Decrease update time
vim.o.timeoutlen = 300     -- Decrease mapped sequence wait time
vim.o.splitright = true    -- Configure how new splits should be opened
vim.o.splitbelow = true
vim.o.wrap = false         -- Disable soft wrapping
vim.o.list = true          -- Sets how neovim will display certain whitespace characters in the editor.
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.o.inccommand = 'split' -- Preview substitutions live, as you type!
vim.o.cursorline = true    -- Show which line your cursor is on
vim.o.scrolloff = 10       -- Minimal number of screen lines to keep above and below the cursor.
-- If performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
vim.o.confirm = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
    callback = function()
        vim.hl.on_yank()
    end,
})

vim.api.nvim_create_autocmd({ 'BufEnter' }, {
    callback = function(args)
        local ft = vim.bo[args.buf].filetype
        --require('fidget').notify('Filetype is ' .. ft)
        if ft == 'rust' then
            vim.g.run_code_command = 'RustLsp runnables'
            vim.g.test_code_command = 'RustLsp testables'
            vim.g.build_code_command = "lua require('fidget').notify 'No build configuration set!'"
            vim.g.clean_code_command = "lua require('fidget').notify 'No clean configuration set!'"
        elseif ft == 'c' or 'ft' == 'cpp' then
            vim.g.run_code_command = 'CMakeQuickRun'
            vim.g.test_code_command = 'CMakeTest'
            vim.g.build_code_command = 'CMakeQuickBuild'
            vim.g.clean_code_command = 'CMakeClean'
        elseif ft == 'tex' then
            vim.diagnostic.config({
                update_in_insert = false, -- don't update while typing
                virtual_text = true,
            })
        else
            vim.g.run_code_command = "lua require('fidget').notify 'No run configuration set!'"
            vim.g.test_code_command = "lua require('fidget').notify 'No test configuration set!'"
            vim.g.build_code_command = "lua require('fidget').notify 'No build configuration set!'"
            vim.g.clean_code_command = "lua require('fidget').notify 'No clean configuration set!'"
        end
        if ft ~= 'tex' then
            vim.g.vimtex_word_count_status_line_cache = ''
        end
    end,
})


-- setup for battery.nvim
local nvimbattery = {
    function()
        return require('battery').get_status_line()
    end,
}

local function telescope_pick(opts)
    local co = coroutine.running()
    local defaults = {
        attach_mappings = function(prompt_bufnr, map)
            local actions = require("telescope.actions")
            local state   = require("telescope.actions.state")
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                coroutine.resume(co, (state.get_selected_entry() or {})[1])
            end)
            map("i", "<C-c>", function()
                actions.close(prompt_bufnr)
                coroutine.resume(co, nil)
            end)
            return true
        end,
    }
    require("telescope.builtin").find_files(vim.tbl_extend("force", defaults, opts or {}))
    return coroutine.yield()
end

-- Evaluates whether or not suggestions should be enabled or not, and sets it accordingly
function RefreshCmpState()
    local disabled = false
    disabled = disabled or (vim.api.nvim_get_option_value('buftype', { buf = 0 }) == 'prompt')
    disabled = disabled or (vim.fn.reg_recording() ~= '')
    disabled = disabled or (vim.fn.reg_executing() ~= '')
    local success, node = pcall(vim.treesitter.get_node)
    if success and node and vim.tbl_contains({ 'comment', 'line_comment', 'block_comment' }, node:type()) then
        disabled = false
    end
    disabled = disabled or not vim.b.cmp_enabled
    vim.b.completion = not disabled
    require('blink-cmp').setup { cmdline = { enabled = vim.b.completion } }
end

function GitsignsKeymap(bufnr)
    local gitsigns = require 'gitsigns'

    local function map(mode, l, r, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']c', function()
        if vim.wo.diff then
            vim.cmd.normal { ']c', bang = true }
        else
            gitsigns.nav_hunk 'next'
        end
    end, { desc = 'Jump to next git [c]hange' })

    map('n', '[c', function()
        if vim.wo.diff then
            vim.cmd.normal { '[c', bang = true }
        else
            gitsigns.nav_hunk 'prev'
        end
    end, { desc = 'Jump to previous git [c]hange' })

    -- Actions
    -- visual mode
    map('v', '<leader>hs', function()
        gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
    end, { desc = 'Git [S]tage Hunk' })
    map('v', '<leader>hr', function()
        gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
    end, { desc = 'Git [R]eset Hunk' })
    -- normal mode
    map('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'Git [s]tage Hunk' })
    map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'Git [r]eset Hunk' })
    map('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'Git [S]tage Buffer' })
    map('n', '<leader>hu', gitsigns.stage_hunk, { desc = 'Git [u]ndo stage Hunk' })
    map('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'Git [R]eset Buffer' })
    map('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'Git [p]review Hunk' })
    map('n', '<leader>hb', gitsigns.blame_line, { desc = 'Git [b]lame Line' })
    map('n', '<leader>hd', gitsigns.diffthis, { desc = 'Git [d]iff Against Index' })
    map('n', '<leader>hD', function()
        gitsigns.diffthis '@'
    end, { desc = 'Git [D]iff against last commit' })
    -- Toggles
    map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = '[T]oggle git show [b]lame line' })
    map('n', '<leader>tD', gitsigns.preview_hunk_inline, { desc = '[T]oggle git show [D]eleted' })
end

-- [[Config]]



-- gitsigns.nvim
-- Eager Load
require('gitsigns').setup({
    signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
    },
})


-- which-key
-- Eager Load


require('which-key').setup({
    -- delay between pressing a key and opening which-key (milliseconds)
    -- this setting is independent of vim.o.timeoutlen
    delay = 0,
    icons = {
        -- set icon mappings to true if you have a Nerd Font
        mappings = vim.g.have_nerd_font,
        -- If you are using a Nerd Font: set icons.keys to an empty table which will use the
        -- default which-key.nvim defined Nerd Font icons, otherwise define a string table
        keys = vim.g.have_nerd_font and {} or {
            Up = '<Up> ',
            Down = '<Down> ',
            Left = '<Left> ',
            Right = '<Right> ',
            C = '<C-…> ',
            M = '<M-…> ',
            D = '<D-…> ',
            S = '<S-…> ',
            CR = '<CR> ',
            Esc = '<Esc> ',
            ScrollWheelDown = '<ScrollWheelDown> ',
            ScrollWheelUp = '<ScrollWheelUp> ',
            NL = '<NL> ',
            BS = '<BS> ',
            Space = '<Space> ',
            Tab = '<Tab> ',
            F1 = '<F1>',
            F2 = '<F2>',
            F3 = '<F3>',
            F4 = '<F4>',
            F5 = '<F5>',
            F6 = '<F6>',
            F7 = '<F7>',
            F8 = '<F8>',
            F9 = '<F9>',
            F10 = '<F10>',
            F11 = '<F11>',
            F12 = '<F12>',
        },
    },

    -- Document existing key chains
    spec = {
        { '<leader>c', group = '[C]ode' },
        { '<leader>l', group = '[L]aTeX' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk',    mode = { 'n', 'v' } },
        { '<leader>w', group = '[W]indow' },
        { '<leader>n', group = '[N]otification' },
        { '<leader>d', group = '[D]ebug' },
    },
})

-- Telescope
-- Eager Load

-- Telescope is a fuzzy finder that comes with a lot of different things that
-- it can fuzzy find! It's more than just a "file finder", it can search
-- many different aspects of Neovim, your workspace, LSP, and more!
--
-- The easiest way to use Telescope, is to start by doing something like:
--  :Telescope help_tags
--
-- After running this command, a window will open up and you're able to
-- type in the prompt window. You'll see a list of `help_tags` options and
-- a corresponding preview of the help.
--
-- Two important keymaps to use while in Telescope are:
--  - Insert mode: <c-/>
--  - Normal mode: ?
--
-- This opens a window that shows you all of the keymaps for the current
-- Telescope picker. This is really useful to discover what Telescope can
-- do as well as how to actually do it!

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
    -- You can put your default mappings / updates / etc. in here
    --  All the info you're looking for is in `:help telescope.setup()`
    --
    -- defaults = {
    --   mappings = {
    --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
    --   },
    -- },
    -- pickers = {}
    extensions = {
        ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
        },
    },
}

-- Enable Telescope extensions if they are installed
pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'ui-select')

-- Lazydev
-- Load on Lua
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.lua" },
    once = true,
    callback = function()
        require('lazydev').setup({
            library = {
                -- Load luvit types when the `vim.uv` word is found
                { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
            },
        })
    end,
})

-- Lsp-config

require("lspconfig").lua_ls.setup({
    ft = "lua"
})

require("lspconfig").clangd.setup({
    ft = "c"
})

require("lspconfig").nil_ls.setup({
    ft = "nix"
})


require("lspconfig").ltex.setup({
    ft = "tex",
    on_attach = function(client, bufnr)
        require("ltex_extra").setup({
            path = vim.fn.expand("~") .. "/.local/state/nvim/ltex"
        })
    end,
    settings = {
        ltex = {
            checkFrequency = "save"
        }
    }
})
require("lspconfig").texlab.setup({})

--  This function gets run when an LSP attaches to a particular buffer.
--    That is to say, every time a new file is opened that is associated with
--    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
--    function will be executed to configure the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
    callback = function(event)
        -- NOTE: Remember that Lua is a real programming language, and as such it is possible
        -- to define small helper and utility functions so you don't have to repeat yourself.
        --
        -- In this case, we create a function that lets us more easily define mappings specific
        -- for LSP related items. It sets the mode, buffer and description for us each time.
        local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        -- Rename the variable under your cursor.
        --  Most Language Servers support renaming across files, etc.
        map('<leader>cn', vim.lsp.buf.rename, '[R]e[n]ame')

        -- Execute a code action, usually your cursor needs to be on top of an error
        -- or a suggestion from your LSP for this to activate.
        map('<leader>ca', vim.lsp.buf.code_action, 'Goto Code [A]ction', { 'n', 'x' })

        -- Find references for the word under your cursor.
        map('<leader>cR', require('telescope.builtin').lsp_references, 'Goto [R]eferences')

        -- Jump to the implementation of the word under your cursor.
        --  Useful when your language has ways of declaring types without an actual implementation.
        map('<leader>ci', require('telescope.builtin').lsp_implementations, 'Goto [I]mplementation')

        -- Jump to the definition of the word under your cursor.
        --  This is where a variable was first declared, or where a function is defined, etc.
        --  To jump back, press <C-t>.
        map('<leader>cd', require('telescope.builtin').lsp_definitions, 'Goto [D]efinition')

        -- This is not Goto Definition, this is Goto Declaration.
        --  For example, in C this would take you to the header.
        map('<leader>cD', vim.lsp.buf.declaration, 'Goto [D]eclaration')

        -- Fuzzy find all the symbols in your current document.
        --  Symbols are things like variables, functions, types, etc.
        map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')

        -- Fuzzy find all the symbols in your current workspace.
        --  Similar to document symbols, except searches over your entire project.
        map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')

        -- Jump to the type of the word under your cursor.
        --  Useful when you're not sure what type a variable is and you want to see
        --  the definition of its *type*, not where it was *defined*.
        map('<leader>cT', require('telescope.builtin').lsp_type_definitions, 'Goto [T]ype Definition')

        -- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
        ---@param client vim.lsp.Client
        ---@param method vim.lsp.protocol.Method
        ---@param bufnr? integer some lsp support methods only in specific files
        ---@return boolean
        local function client_supports_method(client, method, bufnr)
            if vim.fn.has 'nvim-0.11' == 1 then
                return client:supports_method(method, bufnr)
            else
                return client.supports_method(method, { bufnr = bufnr })
            end
        end

        -- The following two autocommands are used to highlight references of the
        -- word under your cursor when your cursor rests there for a little while.
        --    See `:help CursorHold` for information about when this is executed
        --
        -- When you move your cursor, the highlights will be cleared (the second autocommand).
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                buffer = event.buf,
                group = highlight_augroup,
                callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                buffer = event.buf,
                group = highlight_augroup,
                callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
                group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
                callback = function(event2)
                    vim.lsp.buf.clear_references()
                    vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
                end,
            })
        end

        -- The following code creates a keymap to toggle inlay hints in your
        -- code, if the language server you are using supports them
        --
        -- This may be unwanted, since they displace some of your code
        if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map('<leader>th', function()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
        end
    end,
})

-- Diagnostic Config
-- See :help vim.diagnostic.Opts
vim.diagnostic.config {
    severity_sort = true,
    float = { border = 'rounded', source = 'if_many' },
    underline = { severity = vim.diagnostic.severity.ERROR },
    signs = vim.g.have_nerd_font and {
        text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
        },
    } or {},
    virtual_text = {
        source = 'if_many',
        spacing = 2,
        format = function(diagnostic)
            local diagnostic_message = {
                [vim.diagnostic.severity.ERROR] = diagnostic.message,
                [vim.diagnostic.severity.WARN] = diagnostic.message,
                [vim.diagnostic.severity.INFO] = diagnostic.message,
                [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
        end,
    },
}

-- LSP servers and clients are able to communicate to each other what features they support.
--  By default, Neovim doesn't support everything that is in the LSP specification.
--  When you add blink.cmp, luasnip, etc. Neovim now has *more* capabilities.
--  So, we create new capabilities with blink.cmp, and then broadcast that to the servers.
local capabilities = require('blink.cmp').get_lsp_capabilities()

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. Available keys are:
--  - cmd (table): Override the default command used to start the server
--  - filetypes (table): Override the default list of associated filetypes for the server
--  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
--  - settings (table): Override the default settings passed when initializing the server.
--        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
local servers = {
    -- gopls = {},
    -- pyright = {},
    -- rust_analyzer = {},
    -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
    --
    -- Some languages (like typescript) have entire language plugins that can be useful:
    --    https://github.com/pmizio/typescript-tools.nvim
    --
    -- But for many setups, the LSP (`ts_ls`) will work just fine
    -- ts_ls = {},
    --
    texlab = {},
    clangd = {},
    nil_ls = {},


    lua_ls = {
        cmd = { "lua-language-server" },
        filetypes = { ... },
        capabilities = capabilities,
        settings = {
            Lua = {
                runtime = {
                    version = "LuaJIT",
                    pathStrict = false, -- This is where magic happens
                },
                completion = {
                    callSnippet = 'Replace',
                },
                -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
                -- diagnostics = { disable = { 'missing-fields' } },
            },
        },
    },
}



-- conform

require('conform').setup({
    notify_on_error = false,
    format_on_save = function(bufnr)
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.
        -- Set the language to 'true' to disable it
        local disable_filetypes = { c = false, cpp = false }
        if disable_filetypes[vim.bo[bufnr].filetype] then
            return nil
        else
            return {
                timeout_ms = 500,
                lsp_format = 'fallback',
            }
        end
    end,
    formatters_by_ft = {
        lua = { 'stylua' },
        cpp = { 'clang-format' },
        c = { 'clang-format' },
        nix = { 'alejandra' }
        -- Conform can also run multiple formatters sequentially
        -- python = { "isort", "black" },
        --
        -- You can use 'stop_after_first' to run the first available formatter from the list
        -- javascript = { "prettierd", "prettier", stop_after_first = true },
    },
})

-- LuaSnip

-- Somewhere in your Neovim startup, e.g. init.lua
require('luasnip').config.set_config { -- Setting LuaSnip config
    -- Enable autotriggered snippets
    enable_autosnippets = true,
    wordTrig = false,

    -- Use Tab (or some other key if you prefer) to trigger visual selection
    store_selection_keys = '<Tab>',
}

-- Blink.cmp

require('blink.cmp').setup({
    keymap = {
        -- 'default' (recommended) for mappings similar to built-in completions
        --   <c-y> to accept ([y]es) the completion.
        --    This will auto-import if your LSP supports it.
        --    This will expand snippets if the LSP sent a snippet.
        -- 'super-tab' for tab to accept
        -- 'enter' for enter to accept
        -- 'none' for no mappings
        --
        -- For an understanding of why the 'default' preset is recommended,
        -- you will need to read `:help ins-completion`
        --
        -- No, but seriously. Please read `:help ins-completion`, it is really good!
        --
        -- All presets have the following mappings:
        -- <tab>/<s-tab>: move to right/left of your snippet expansion
        -- <c-space>: Open menu or open docs if already open
        -- <c-n>/<c-p> or <up>/<down>: Select next/previous item
        -- <c-e>: Hide menu
        -- <c-k>: Toggle signature help
        --
        -- See :h blink-cmp-config-keymap for defining your own keymap
        preset = 'default',
        -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
        --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
    },

    appearance = {
        -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono',
    },

    completion = {
        -- By default, you may press `<c-space>` to show the documentation.
        -- Optionally, set `auto_show = true` to show the documentation after a delay.
        documentation = { auto_show = true, auto_show_delay_ms = 500 },
        list = {
            selection = {
                preselect = false,
                auto_insert = false,
            },
        },
    },

    sources = {
        default = { 'lsp', 'path', 'snippets', 'lazydev' },
        providers = {
            lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
        },
    },

    snippets = { preset = 'luasnip' },

    -- Blink.cmp includes an optional, recommended rust fuzzy matcher,
    -- which automatically downloads a prebuilt binary when enabled.
    --
    -- By default, we use the Lua implementation instead, but you may enable
    -- the rust implementation via `'prefer_rust_with_warning'`
    --
    -- See :h blink-cmp-config-fuzzy for more information
    fuzzy = { implementation = 'prefer_rust_with_warning' },

    -- Shows a signature help window while you type arguments for a function
    signature = { enabled = true },

})

-- Todo comments

require('todo-comments').setup({ signs = false })

-- Mini

-- Better Around/Inside textobjects
--
-- Examples:
--  - va)  - [V]isually select [A]round [)]paren
--  - yinq - [Y]ank [I]nside [N]ext [Q]uote
--  - ci'  - [C]hange [I]nside [']quote
require('mini.ai').setup { n_lines = 500 }

-- Add/delete/replace surroundings (brackets, quotes, etc.)
--
-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
-- - sd'   - [S]urround [D]elete [']quotes
-- - sr)'  - [S]urround [R]eplace [)] [']
require('mini.surround').setup()


require('mini.pairs').setup()
--  Check out: https://github.com/echasnovski/mini.nvim
-- require('mini.misc').setup_termbg_sync()

-- Treesitter

require('nvim-treesitter').setup({
    ignore_install = { 'latex' },
    -- Autoinstall languages that are not installed
    auto_install = true,
    highlight = {
        enable = true,
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = { 'ruby', 'c' },
    },
    indent = { enable = true, disable = { 'ruby' } },
})

-- Noice

require('noice').setup({
    notify = { enabled = true },
    -- add any options here
    lsp = {
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
            ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
            ['vim.lsp.util.stylize_markdown'] = true,
        },
    },
    -- you can enable a preset for easier configuration
    presets = {
        bottom_search = true,         -- use a classic bottom cmdline for search
        command_palette = true,       -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false,           -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = true,        -- add a border to hover docs and signature help
    },
})
local real_notify = require('notify')
setmetatable(require('notify'), {
    __call = function(_, msg, level, opts)
        level = level or vim.log.levels.INFO
        if level == vim.log.levels.ERROR then
            real_notify.notify(msg, level, opts)
        else
            require('fidget').notify(msg, level, opts)
        end
    end
})
-- Alpha


require('alpha').setup(require('alpha.themes.startify').config)
local alpha = require 'alpha'
local dashboard = require 'alpha.themes.dashboard'
dashboard.section.header.val = {
    '    ▄▄█▀▀▀▀█▄▄                                                                ▄▄█▀▀▀▀█▄▄',
    '  ▄█▀        ▀█▄                                                            ▄█▀        ▀█▄',
    '  ▀▀          ▀▀                                                            ▀▀          ▀▀',
    '        ██                                                                        ██',
    '       ████                                                                      ████',
    '      ▄█  █▄                                                                    ▄█  █▄',
    '     ▄██  ██▄                                                                  ▄██  ██▄',
    '     ██    ██        ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗        ██    ██',
    '    ███    ███       ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║       ███    ███',
    '   ██ █▄  ▄█ ▀█      ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║      ██ █▄  ▄█ ▀█',
    '  ▄█  ▀█  █▀  █▄     ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║     ▄█  ▀█  █▀  █▄',
    ' ▄█    ████    █▄    ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║    ▄█    ████    █▄',
    ' █▀    ▄██▄    ▀█    ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝    █▀    ▄██▄    ▀█',
    '▀█████▀▀██▀▀█████▀                                                        ▀█████▀▀██▀▀█████▀',
    '  ▀█▄   ██   ▄█▀                                                            ▀█▄   ██   ▄█▀',
    '    ▀█▄ ██ ▄█▀                                                                ▀█▄ ██ ▄█▀',
    '▀█▄   ▀████▀   ▄█▀                                                        ▀█▄   ▀████▀   ▄█▀',
    '  ▀█▄   ▀▀   ▄█▀                                                            ▀█▄   ▀▀   ▄█▀',
    '    ▀▀      ▀▀                                                                ▀▀      ▀▀',
}
dashboard.section.buttons.val = {
    dashboard.button('n', '  New file', ':ene <BAR> startinsert <CR>'),
    dashboard.button('f', '󰈞  Find file', ':Telescope find_files <CR>'),
    dashboard.button('t', '  Find text', ':Telescope live_grep <CR>'),
    dashboard.button('m', '󰃀  Bookmarks', ':Telescope marks <CR>'),
    dashboard.button('r', '󱑂  Recently used files', ':Telescope oldfiles <CR>'),
    dashboard.button('c', '  Configuration', ':e ~/AppData/Local/nvim/init.lua<CR>'),
    dashboard.button('q', '󰩈  Quit Neovim', ':qa<CR>'),
}
require('alpha').setup(dashboard.opts)


-- VimTeX


vim.g.vimtex_view_method = 'zathura_simple'
vim.g.vimtex_compiler_latexmk = {
    options = {
        '-pdf',
        '-shell-escape',
        '-interaction=nonstopmode',
        '-synctex=1',
    },
    aux_dir = './.latexmk/aux',
    out_dir = './.latexmk/out',
}
vim.g.vimtex_syntax_conceal = {
    accents = 1,
    ligatures = 1,
    fancy = 1,
    spacing = 1,
    greek = 1,
    math_bounds = 1,
    math_delimiters = 1,
    math_fracs = 1,
    math_super_sub = 1,
    math_symbols = 1,
    sections = 0,
    styles = 1,
}
vim.g.vimtex_quickfix_open_on_warning = 0

vim.opt.conceallevel = 2
vim.opt.concealcursor = 'nv'

vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufEnter' }, {
    pattern = '*.tex',
    callback = function()
        local ok, result = pcall(vim.fn['vimtex#misc#wordcount'])
        vim.g.vimtex_word_count_status_line_cache = ok and (result .. " words") or ''
    end,
})

local function vimtex_wordcount()
    local mode = vim.fn.mode()
    if mode == 'v' or mode == 'V' or mode == '\22' then
        local vwc = vim.fn.wordcount().visual_words
        return vwc and (vwc .. ' of ' .. vim.g.vimtex_word_count_status_line_cache) or ''
    end
    return vim.g.vimtex_word_count_status_line_cache
end


-- Smear Cursor

require('smear_cursor').setup({
    -- Default Range
    stiffness = 0.5,           -- 0.6 [0, 1]
    trailing_stiffness = 0.49, -- 0.3 [0, 1]
    time_interval = 7,         --ms
    -- distance_stop_animating = 0.5, -- 0.1 > 0
    smear_insert_mode = false,
})

-- Lualine


require('lualine').setup({
    sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = { 'filename', {
            vimtex_wordcount,
            -- cond = function()
            --   return vim.bo.filetype == "tex"
            -- end
        } },
        lualine_x = { 'encoding', 'filetype', nvimbattery },
        lualine_y = { 'progress', 'location' },
        lualine_z = {
            function()
                return ' ' .. os.date '%R'
            end,
        },
    },
})

-- Gitsigns

require('gitsigns').setup({
    on_attach = function(bufnr)
        GitsignsKeymap(bufnr)
    end,
})


-- CMake Tools
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "CMakeLists.txt", "*.cmake", "*.c", "*.h", "*.cpp" },
    once = true,
    callback = function()
        require('cmake-tools').setup {
            cmake_command = 'cmake',
            cmake_build_directory = 'build',
            cmake_notifications = {
                runner   = { enabled = false },
                executor = { enabled = false },
            },
        }
    end,
})


-- Colorscheme

-- Load the colorscheme here.
-- Like many other themes, this one has different styles, and you could load
-- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
vim.cmd.colorscheme 'everforest'

-- nvim-dap

local dap = require 'dap'
local dapui = require 'dapui'



-- Dap UI setup
-- For more information, see |:help nvim-dap-ui|
dapui.setup {
    -- Set icons to characters that are more likely to work in every terminal.
    --    Feel free to remove or use ones that you like more! :)
    --    Don't feel like these are good choices.
    icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
    controls = {
        icons = {
            pause = '',
            play = '',
            step_into = '',
            step_over = '',
            step_out = '',
            step_back = '',
            run_last = '',
            terminate = '',
            disconnect = '',
        },
    },
}

-- Change breakpoint icons
vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
local breakpoint_icons = vim.g.have_nerd_font
    and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
    or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
for type, icon in pairs(breakpoint_icons) do
    local tp = 'Dap' .. type
    local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
    vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
end

dap.listeners.after.event_initialized['dapui_config'] = dapui.open
dap.listeners.before.event_terminated['dapui_config'] = dapui.close
dap.listeners.before.event_exited['dapui_config'] = dapui.close

local dap = require("dap")

-- Find the lldb-dap binary (NixOS puts it in the store)
local lldb_dap = vim.fn.exepath("lldb-dap")

-- Adapter definition
dap.adapters.lldb = {
    type = "executable",
    command = lldb_dap,
    name = "lldb",
    enrich_config = function(config, on_config)
        config.stopOnEntry = false
        if pending_args then
            config.args = pending_args
            pending_args = nil
        end
        on_config(config)
    end,
}

-- C / C++ / Rust configurations
local lldb_config = {
    {
        name = "Launch binary",
        type = "lldb",
        request = "launch",
        program = function()
            pending_stdin = nil
            return telescope_pick({ prompt_title = "Binary (Ctrl-c to cancel)", find_command = { "find", vim.fn.getcwd(), "-type", "f", "-perm", "/111" } })
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        args = {},
    },
    {
        name = "Launch binary with input",
        type = "lldb",
        request = "launch",
        program = function()
            local binary = telescope_pick({ prompt_title = "Binary", find_command = { "find", vim.fn.getcwd(), "-type", "f", "-perm", "/111" } })
            local stdin  = telescope_pick({ prompt_title = "Stdin", find_command = { "find", vim.fn.getcwd(), "-type", "f", "-name", "*.txt" } })
            pending_args = { "-c", "exec " .. binary .. " < " .. stdin }
            return "/bin/sh"
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        args = {},
    },
    {
        name = "Attach to process",
        type = "lldb",
        request = "attach",
        pid = require("dap.utils").pick_process,
        args = {},
    },
}

dap.configurations.c = lldb_config
dap.configurations.cpp = lldb_config
dap.configurations.rust = lldb_config
-- Linting

local lint = require 'lint'
lint.linters_by_ft = {
    rust = { 'clippy' },
    markdown = { 'markdownlint' },
}

-- To allow other plugins to add linters to require('lint').linters_by_ft,
-- instead set linters_by_ft like this:
-- lint.linters_by_ft = lint.linters_by_ft or {}
-- lint.linters_by_ft['markdown'] = { 'markdownlint' }
--
-- However, note that this will enable a set of default linters,
-- which will cause errors unless these tools are available:
-- {
--   clojure = { "clj-kondo" },
--   dockerfile = { "hadolint" },
--   inko = { "inko" },
--   janet = { "janet" },
--   json = { "jsonlint" },
--   markdown = { "vale" },
--   rst = { "vale" },
--   ruby = { "ruby" },
--   terraform = { "tflint" },
--   text = { "vale" }
-- }
--
-- You can disable the default linters by setting their filetypes to nil:
-- lint.linters_by_ft['clojure'] = nil
-- lint.linters_by_ft['dockerfile'] = nil
-- lint.linters_by_ft['inko'] = nil
-- lint.linters_by_ft['janet'] = nil
-- lint.linters_by_ft['json'] = nil
-- lint.linters_by_ft['markdown'] = nil
-- lint.linters_by_ft['rst'] = nil
-- lint.linters_by_ft['ruby'] = nil
-- lint.linters_by_ft['terraform'] = nil
-- lint.linters_by_ft['text'] = nil

-- Create autocommand which carries out the actual linting
-- on the specified events.
local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
    group = lint_augroup,
    callback = function()
        -- Only run the linter in buffers that you can modify in order to
        -- avoid superfluous noise, notably within the handy LSP pop-ups that
        -- describe the hovered symbol using Markdown.
        if vim.bo.modifiable then
            lint.try_lint()
        end
    end,
})

-- Fidget

require("fidget").setup({
    progress = {
        display = {
            overrides = {
                ltex = { ignore = true }
            }
        }
    }
})
--
-- After fidget is set up, wrap its $/progress handler
local original_handler = vim.lsp.handlers["$/progress"]
vim.lsp.handlers["$/progress"] = function(err, result, ctx, config)
    local client = vim.lsp.get_client_by_id(ctx.client_id)
    if client and client.name == "ltex" then
        return -- drop it before fidget ever sees it
    end
    original_handler(err, result, ctx, config)
end

-- [[Keymap]]



local toggle_mouse = function()
    if vim.o.mouse == 'a' then
        vim.o.mouse = ''
        require('fidget').notify 'Mouse: Disabled'
    else
        vim.o.mouse = 'a'
        require('fidget').notify 'Mouse: Enabled'
    end
end

local cycle_tabwidth = function()
    if vim.o.tabstop == 4 then
        vim.o.tabstop = 2
        vim.o.shiftwidth = 2
    elseif vim.o.tabstop == 2 then
        vim.o.tabstop = 4
        vim.o.shiftwidth = 4
    end
    require('fidget').notify(string.format('Tabwith set to %d', vim.o.tabstop))
end

local toggle_neotree = function()
    local reveal_file = vim.fn.expand '%:p'
    if reveal_file == '' then
        reveal_file = vim.fn.getcwd()
    else
        local f = io.open(reveal_file, 'r')
        if f then
            f.close(f)
        else
            reveal_file = vim.fn.getcwd()
        end
    end
    require('neo-tree.command').execute {
        action = 'focus',          -- OPTIONAL, this is the default value
        source = 'filesystem',     -- OPTIONAL, this is the default value
        position = 'left',         -- OPTIONAL, this is the default value
        reveal_file = reveal_file, -- path to file or folder to reveal
        reveal_force_cwd = true,   -- change cwd without asking if needed
        toggle = true,
    }
end


vim.g.run_code = function()
    vim.cmd(vim.g.run_code_command)
end
vim.g.test_code = function()
    vim.cmd(vim.g.test_code_command)
end
vim.g.build_code = function()
    vim.cmd(vim.g.build_code_command)
end
vim.g.clean_code = function()
    vim.cmd(vim.g.clean_code_command)
end

local open_file_explorer = function()
    local output = vim.fn.system 'explorer .'
end

if vim.fn.has 'win32' == 0 then
    vim.keymap.set('n', '<leader>cs', function() vim.cmd("so ~/Documents/Configuration/nvim/init.lua") end,
        { desc = "[S]ource Dev Neovim Config" })
end

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.keymap.set('n', '<leader>cq', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
-- Window Leader Remap from <C-w> to <leader>w
vim.keymap.set('n', '<leader>wd', '<C-w>d', { desc = 'Show diagnostics under the cursor' })
vim.keymap.set('n', '<leader>wh', '<C-w>h', { desc = 'Go to the left window' })
vim.keymap.set('n', '<leader>wH', '<C-w>H', { desc = 'Move window to far left' })
vim.keymap.set('n', '<leader>wj', '<C-w>j', { desc = 'Go to the down window' })
vim.keymap.set('n', '<leader>wJ', '<C-w>J', { desc = 'Move window to far bottom' })
vim.keymap.set('n', '<leader>wk', '<C-w>k', { desc = 'Go to the up window' })
vim.keymap.set('n', '<leader>wK', '<C-w>K', { desc = 'Move window to far top' })
vim.keymap.set('n', '<leader>wl', '<C-w>l', { desc = 'Go to the right window' })
vim.keymap.set('n', '<leader>wL', '<C-w>L', { desc = 'Move window to far right' })
vim.keymap.set('n', '<leader>wo', '<C-w>o', { desc = 'Close all other windows' })
vim.keymap.set('n', '<leader>wp', '<C-w>p', { desc = 'Quit a window' })
vim.keymap.set('n', '<leader>ws', '<C-w>s', { desc = 'Split window' })
vim.keymap.set('n', '<leader>wT', '<C-w>T', { desc = 'Break out into a new tab' })
vim.keymap.set('n', '<leader>wv', '<C-w>v', { desc = 'Split window vertically' })
vim.keymap.set('n', '<leader>ww', '<C-w>w', { desc = 'Switch windows' })
vim.keymap.set('n', '<leader>wx', '<C-w>x', { desc = 'Swap current with next' })
vim.keymap.set('n', '<leader>w+', '<C-w>+', { desc = 'Increase height' })
vim.keymap.set('n', '<leader>w-', '<C-w>-', { desc = 'Decrease height' })
vim.keymap.set('n', '<leader>w<', '<C-w><', { desc = 'Decrease width' })
vim.keymap.set('n', '<leader>w=', '<C-w>=', { desc = 'Equally high and wide' })
vim.keymap.set('n', '<leader>w>', '<C-w>>', { desc = 'Increase width' })
vim.keymap.set('n', '<leader>w_', '<C-w>_', { desc = 'Max out the height' })
vim.keymap.set('n', '<leader>w|', '<C-w>|', { desc = 'Max out the width' })
vim.keymap.set('n', '<leader>wD', '<C-w>D', { desc = 'Show diagnostics under the cursor' })

vim.keymap.set('n', '<leader>tm', toggle_mouse, { desc = 'Toggle [M]ouse' })
vim.keymap.set('n', '<leader>tt', cycle_tabwidth, { desc = 'Toggle [T]abwidth' })

vim.keymap.set('n', '<leader>cr', vim.g.run_code, { desc = '[R]un Code' })
vim.keymap.set('n', '<leader>cb', vim.g.build_code, { desc = '[B]uild Code' })
vim.keymap.set('n', '<leader>cc', vim.g.clean_code, { desc = '[C]lean Code' })
vim.keymap.set('n', '<leader>ct', vim.g.test_code, { desc = '[T]est Code' })

vim.diagnostic.config {
    virtual_text = {
        filter = function(diagnostic)
            return not string.match(diagnostic.message, 'code is inactive due to')
        end,
    },
}
vim.keymap.set('n', '<leader>sn', function()
    vim.cmd 'Noice telescope'
end, { desc = '[S]earch [N]otifications' })
vim.keymap.set('n', '<leader>nl', function()
    vim.cmd 'Noice last'
end, { desc = 'Show [L]ast Notification' })
vim.keymap.set('n', '<leader>nh', function()
    vim.cmd 'Noice history'
end, { desc = 'Show Notification [H]istory' })

vim.keymap.set({ 'i' }, '<Tab>', function()
    require('luasnip').expand {}
end, { silent = true })
vim.keymap.set({ 'i', 's' }, '<Tab>', function()
    require('luasnip').jump(1)
end, { silent = true })
vim.keymap.set({ 'i', 's' }, '<S-Tab>', function()
    require('luasnip').jump(-1)
end, { silent = true })

vim.keymap.set({ 'n' }, '<leader>ds', function()
    require('dap').continue()
end, { desc = 'Debug: [S]tart/Continue' })
vim.keymap.set({ 'n' }, '<leader>di', function()
    require('dap').step_into()
end, { desc = 'Debug: Step [I]nto' })
vim.keymap.set({ 'n' }, '<leader>do', function()
    require('dap').step_over()
end, { desc = 'Debug: Step [O]ver' })
vim.keymap.set({ 'n' }, '<leader>du', function()
    require('dap').step_out()
end, { desc = 'Debug: Step O[u]t' })
vim.keymap.set({ 'n' }, '<leader>db', function()
    require('dap').toggle_breakpoint()
end, { desc = 'Debug: Toggle [B]reakpoint' })
vim.keymap.set({ 'n' }, '<leader>dc', function()
    require('dap').run_to_cursor()
end, { desc = 'Debug: Run to [c]ursor' })
vim.keymap.set({ 'n' }, '<leader>dp', function()
    require('dap').pause()
end, { desc = 'Debug: [P]ause' })
vim.keymap.set({ 'n' }, '<leader>dC', function()
    require('dap').close()
end, { desc = 'Debug: [C]lose' })


vim.keymap.set({ 'n' }, '<leader>dd', function()
    require('dapui').toggle()
end, { desc = 'Debug: Toggle UI.' })

vim.keymap.set({ 'n', 'x', 'o' }, '<leader>st', toggle_neotree, { desc = 'Toggle Neo[t]ree' })

vim.keymap.set({ 'n', 'x', 'o' }, '<leader>se', open_file_explorer, { desc = 'Open File Explorer' })

-- Telescope

-- See `:help telescope.builtin`
local telescope_builtin = require 'telescope.builtin'
vim.keymap.set('n', '<leader>sh', telescope_builtin.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', telescope_builtin.keymaps, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>sf', telescope_builtin.find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>ss', telescope_builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set('n', '<leader>sw', telescope_builtin.grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', telescope_builtin.live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', telescope_builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
--vim.keymap.set('n', '<leader>sr', telescope_builtin.resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>sr', telescope_builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set('n', '<leader>sb', telescope_builtin.buffers, { desc = '[ ] [S]earch existing [b]uffers' })

-- Slightly advanced example of overriding default behavior and theme
vim.keymap.set('n', '<leader>/', function()
    -- You can pass additional configuration to Telescope to change the theme, layout, etc.
    telescope_builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
    })
end, { desc = '[/] Fuzzily search in current buffer' })

-- It's also possible to pass additional configuration options.
--  See `:help telescope.builtin.live_grep()` for information about particular keys
vim.keymap.set('n', '<leader>s/', function()
    telescope_builtin.live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
    }
end, { desc = '[S]earch [/] in Open Files' })

-- Shortcut for searching your Neovim configuration files
vim.keymap.set('n', '<leader>sc', function()
    telescope_builtin.find_files { cwd = vim.fn.stdpath 'config' }
end, { desc = '[S]earch Neovim [C]onfig' })

vim.keymap.set('n', '<leader>sF', function()
    telescope_builtin.find_files { hidden = true, no_ignore = true }
end, { desc = '[S]earch All [F]iles' })

-- [[ Snippets ]]
local luasnip = require 'luasnip'
local s = luasnip.snippet
local sn = luasnip.snippet_node
local t = luasnip.text_node
local i = luasnip.insert_node
local f = luasnip.function_node
local d = luasnip.dynamic_node
local r = luasnip.restore_node
local fmt = require('luasnip.extras.fmt').fmt
local fmta = require('luasnip.extras.fmt').fmta
local rep = require('luasnip.extras').rep

local return_capture = function(_, snip, captureIndex)
    return snip.captures[captureIndex]
end

local return_first_capture = function(_, snip)
    return return_capture(_, snip, 1)
end

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

local function v(pos, default_text)
    return d(pos, function(args, parent)
        return get_visual(args, parent, default_text)
    end)
end

local in_mathzone = function()
    return vim.fn['vimtex#syntax#in_mathzone']() == 1
end

-- Matrices and cases
-- taken from github.com/evesdropper

local generate_matrix = function(args, snip)
    local rows = tonumber(snip.captures[2])
    local cols = tonumber(snip.captures[3])
    local nodes = {}
    local ins_indx = 1
    for j = 1, rows do
        table.insert(nodes, r(ins_indx, tostring(j) .. 'x1', i(1)))
        ins_indx = ins_indx + 1
        for k = 2, cols do
            table.insert(nodes, t ' & ')
            table.insert(nodes, r(ins_indx, tostring(j) .. 'x' .. tostring(k), i(1)))
            ins_indx = ins_indx + 1
        end
        table.insert(nodes, t { ' \\\\', '' })
    end
    nodes[#nodes] = t ' \\\\'
    return sn(nil, nodes)
end

local generate_hom_matrix = function(args, snip)
    local rows = tonumber(snip.captures[2])
    local cols = tonumber(snip.captures[3])
    local nodes = {}
    local ins_indx = 1
    for j = 1, rows do
        if j == 1 then
            table.insert(nodes, r(ins_indx, i(1)))
            table.insert(nodes, t '_{11}')
        else
            table.insert(nodes, rep(1))
            table.insert(nodes, t('_{' .. tostring(j) .. '1}'))
        end
        ins_indx = ins_indx + 1
        for k = 2, cols do
            table.insert(nodes, t ' & ')
            table.insert(nodes, rep(1))
            table.insert(nodes, t('_{' .. tostring(j) .. tostring(k) .. '}'))
            ins_indx = ins_indx + 1
        end
        table.insert(nodes, t { ' \\\\', '' })
    end
    nodes[#nodes] = t ' \\\\'
    return sn(nil, nodes)
end

-- Greek Letters
local greek_letter_snippets = {
    s({ trig = ',al', wordTrig = true, snippetType = 'autosnippet' }, { t '\\alpha' }),
    s({ trig = ',be', wordTrig = true, snippetType = 'autosnippet' }, { t '\\beta' }),
    s({ trig = ',ga', wordTrig = true, snippetType = 'autosnippet' }, { t '\\gamma' }),
    s({ trig = ',de', wordTrig = true, snippetType = 'autosnippet' }, { t '\\delta' }),
    s({ trig = ',ep', wordTrig = true, snippetType = 'autosnippet' }, { t '\\varepsilon' }),
    s({ trig = ',ze', wordTrig = true, snippetType = 'autosnippet' }, { t '\\zeta' }),
    s({ trig = ',et', wordTrig = true, snippetType = 'autosnippet' }, { t '\\eta' }),
    s({ trig = ',th', wordTrig = true, snippetType = 'autosnippet' }, { t '\\theta' }),
    s({ trig = ',io', wordTrig = true, snippetType = 'autosnippet' }, { t '\\iota' }),
    s({ trig = ',ka', wordTrig = true, snippetType = 'autosnippet' }, { t '\\kappa' }),
    s({ trig = ',la', wordTrig = true, snippetType = 'autosnippet' }, { t '\\lambda' }),
    s({ trig = ',mu', wordTrig = true, snippetType = 'autosnippet' }, { t '\\mu' }),
    s({ trig = ',nu', wordTrig = true, snippetType = 'autosnippet' }, { t '\\nu' }),
    s({ trig = ',xi', wordTrig = true, snippetType = 'autosnippet' }, { t '\\xi' }),
    s({ trig = ',pi', wordTrig = true, snippetType = 'autosnippet' }, { t '\\pi' }),
    s({ trig = ',rh', wordTrig = true, snippetType = 'autosnippet' }, { t '\\rho' }),
    s({ trig = ',si', wordTrig = true, snippetType = 'autosnippet' }, { t '\\sigma' }),
    s({ trig = ',ta', wordTrig = true, snippetType = 'autosnippet' }, { t '\\tau' }),
    s({ trig = ',up', wordTrig = true, snippetType = 'autosnippet' }, { t '\\upsilon' }),
    s({ trig = ',ph', wordTrig = true, snippetType = 'autosnippet' }, { t '\\phi' }),
    s({ trig = ',ch', wordTrig = true, snippetType = 'autosnippet' }, { t '\\chi' }),
    s({ trig = ',ps', wordTrig = true, snippetType = 'autosnippet' }, { t '\\psi' }),
    s({ trig = ',om', wordTrig = true, snippetType = 'autosnippet' }, { t '\\omega' }),
    s({ trig = ',Ga', wordTrig = true, snippetType = 'autosnippet' }, { t '\\Gamma' }),
    s({ trig = ',De', wordTrig = true, snippetType = 'autosnippet' }, { t '\\Delta' }),
    s({ trig = ',Th', wordTrig = true, snippetType = 'autosnippet' }, { t '\\Theta' }),
    s({ trig = ',La', wordTrig = true, snippetType = 'autosnippet' }, { t '\\Lambda' }),
    s({ trig = ',Xi', wordTrig = true, snippetType = 'autosnippet' }, { t '\\Xi' }),
    s({ trig = ',Pi', wordTrig = true, snippetType = 'autosnippet' }, { t '\\Pi' }),
    s({ trig = ',Si', wordTrig = true, snippetType = 'autosnippet' }, { t '\\Sigma' }),
    s({ trig = ',Up', wordTrig = true, snippetType = 'autosnippet' }, { t '\\Upsilon' }),
    s({ trig = ',Ph', wordTrig = true, snippetType = 'autosnippet' }, { t '\\Phi' }),
    s({ trig = ',Ps', wordTrig = true, snippetType = 'autosnippet' }, { t '\\Psi' }),
    s({ trig = ',Om', wordTrig = true, snippetType = 'autosnippet' }, { t '\\Omega' }),
}

local text_fraction_snippets = {
    s({ trig = ',12', snippetType = 'autosnippet' }, { t '½' }),
    s({ trig = ',13', snippetType = 'autosnippet' }, { t '⅓' }),
    s({ trig = ',23', snippetType = 'autosnippet' }, { t '⅔' }),
    s({ trig = ',14', snippetType = 'autosnippet' }, { t '¼' }),
    s({ trig = ',34', snippetType = 'autosnippet' }, { t '¾' }),
    s({ trig = ',15', snippetType = 'autosnippet' }, { t '⅕' }),
    s({ trig = ',25', snippetType = 'autosnippet' }, { t '⅖' }),
    s({ trig = ',35', snippetType = 'autosnippet' }, { t '⅗' }),
    s({ trig = ',45', snippetType = 'autosnippet' }, { t '⅘' }),
    s({ trig = ',16', snippetType = 'autosnippet' }, { t '⅙' }),
    s({ trig = ',56', snippetType = 'autosnippet' }, { t '⅚' }),
    s({ trig = ',18', snippetType = 'autosnippet' }, { t '⅛' }),
    s({ trig = ',38', snippetType = 'autosnippet' }, { t '⅜' }),
    s({ trig = ',58', snippetType = 'autosnippet' }, { t '⅝' }),
    s({ trig = ',78', snippetType = 'autosnippet' }, { t '⅞' }),
}

local math_snippets = {
    s({ trig = ',ff', snippetType = 'autosnippet', desc = 'Fraction' }, fmta('\\frac{<>}{<>}', { i(1), i(2) }),
        { condition = in_mathzone }),
    s({ trig = ',lim', snippetType = 'autosnippet', desc = 'Limit' }, fmta('\\lim_{<> \\to <>}', { i(1), i(2) }),
        { condition = in_mathzone }),
    s({ trig = ',din', snippetType = 'autosnippet', desc = 'Definite Integral' }, fmta('\\int_{<>}^{<>}', { i(1), i(2) }),
        { condition = in_mathzone }),
    s({ trig = ',ind', snippetType = 'autosnippet', desc = 'Indefinite Integral' }, fmta('\\int ', {}),
        { condition = in_mathzone }),
    s({ trig = ',()', snippetType = 'autosnippet' }, { t '\\left(\\', i(1), t 'right)' }, { condition = in_mathzone }),
    s({ trig = ',[]', snippetType = 'autosnippet' }, { t '\\left[\\', i(1), t 'right}' }, { condition = in_mathzone }),
    s({ trig = ',{}', snippetType = 'autosnippet' }, { t '\\left{\\', i(1), t 'right}' }, { condition = in_mathzone }),
    s({ trig = ',_', snippetType = 'autosnippet' }, { t '_{', d(1, get_visual), t '}' }, { condition = in_mathzone }),
    s({ trig = ',^', snippetType = 'autosnippet' }, { t '^{', d(1, get_visual), t '}' }, { condition = in_mathzone }),
    -- Matrices
    -- stylua: ignore start
    s(
        { trig = ",m([bBpvV])(%d+)x(%d+)", desc = "New matrix", snippetType = "autosnippet", wordTrig = true, regTrig = true },
        {
            t("\\begin{"), f(function(_, snip) return snip.captures[1] .. "matrix" end), t("}"),
            t({ "", "" }), d(1, generate_matrix),
            t({ "", "" }), t("\\end{"), f(function(_, snip) return snip.captures[1] .. "matrix" end), t("}")
        },
        { condition = in_mathzone }
    ),

    s(
        { trig = ",m([bBpvV])(%d+)h(%d+)", desc = "New homogeneous matrix", snippetType = "autosnippet", wordTrig = true, regTrig = true },
        {
            t("\\begin{"), f(function(_, snip) return snip.captures[1] .. "matrix" end), t("}"),
            t({ "", "" }), d(1, generate_hom_matrix),
            t({ "", "" }), t("\\end{"), f(function(_, snip) return snip.captures[1] .. "matrix" end), t("}")
        },
        { condition = in_mathzone }
    ),

    s(
        { trig = ",m([bBpvV])gn", desc = "New generic matrix", snippetType = "autosnippet", wordTrig = true, regTrig = true },
        {
            t("\\begin{"), f(function(_, snip) return snip.captures[1] .. "matrix" end), t("}"),
            t({ "", "" }), t("    "), i(1), t("_{11} & "), rep(1), t("_{12} & \\cdots & "), rep(1), t("_{1"), i(2), t(
            "}"), t(
            " \\\\"),
            t({ "", "" }), t("    "), rep(1), t("_{21} & "), rep(1), t("_{22} & \\cdots & "), rep(1), t("_{2"), rep(2), t(
            "}"),
            t(" \\\\"),
            t({ "", "" }), t("    "), t("\\vdots & \\vdots & \\ddots & \\vdots \\\\"),
            t({ "", "" }), t("    "), rep(1), t("_{"), i(3), t("1} & "), rep(1), t("_{"), rep(3), t("2} & \\cdots & "),
            rep(1),
            t("_{"), rep(3), rep(2), t("} \\\\"),
            t({ "", "" }), t("\\end{"), f(function(_, snip) return snip.captures[1] .. "matrix" end), t("}")
        },
        { condition = in_mathzone }
    ),
    -- stylua: ignore end
}

local markdown_snippets = {
    s({ trig = ';im', snippetType = 'autosnippet', desc = 'Inline Math' }, fmta('$<>$', { i(0) })),
    s({ trig = ';mm', snippetType = 'autosnippet', desc = 'Display Math' }, fmta('$$<>$$', { i(0) })),
}

local tex_snippets = {
    s({ trig = ',df', snippetType = 'autosnippet' }, { t '°F' }),
    s({ trig = ',dc', snippetType = 'autosnippet' }, { t '°C' }),
    s({ trig = ',ts', wordTrig = true, snippetType = 'autosnippet' }, { t 'Teaspoon' }),
    s({ trig = ',tb', wordTrig = true, snippetType = 'autosnippet' }, { t 'Tablespoon' }),
    s({ trig = ',cu', wordTrig = true, snippetType = 'autosnippet' }, { t 'Cup' }),
    s({ trig = ',oz', wordTrig = true, snippetType = 'autosnippet' }, { t 'Ounce' }),
    s(
        { trig = ';rstep', snippetType = 'autosnippet', desc = 'Adds a step to the recipe' },
        fmta('\\begin{step}\n<>\n\\method\n<>\n\\end{step}\n<>', { i(2), i(1), i(0) })
    ),
    s({ trig = ',it', snippetType = 'autosnippet', desc = 'Italicize' }, { t '\\textit{', d(1, get_visual), t '}' }),
    s({ trig = ',bf', snippetType = 'autosnippet', desc = 'Bold' }, { t '\\textbf{', d(1, get_visual), t '}' }),
    s({ trig = ',ts', snippetType = 'autosnippet', desc = 'TinySize' }, { t '\\tiny{', d(1, get_visual), t '}' }),
    s({ trig = ',cs', snippetType = 'autosnippet', desc = 'ScriptSize' }, { t '\\scriptsize{', d(1, get_visual), t '}' }),
    s({ trig = ',fs', snippetType = 'autosnippet', desc = 'FootnoteSize' },
        { t '\\footnotsize{', d(1, get_visual), t '}' }),
    s({ trig = ',ss', snippetType = 'autosnippet', desc = 'SmallSize' }, { t '\\small{', d(1, get_visual), t '}' }),
    s({ trig = ',ns', snippetType = 'autosnippet', desc = 'NormalSize' }, { t '\\normalsize{', d(1, get_visual), t '}' }),
    s({ trig = ',mm', snippetType = 'autosnippet', desc = 'Inline Math' }, { t '$', d(1, get_visual), t '$' }),
    s({ trig = ',dm', snippetType = 'autosnippet', desc = 'Display Math' }, { t '\\[', d(1, get_visual), t '\\]' }),
    s({ trig = ';beq', snippetType = 'autosnippet', desc = 'Equation Environment' },
        { t '\\begin{equation}\n', d(1, get_visual), t '\\end{equation}' }),
    s({ trig = ';bseq', snippetType = 'autosnippet', desc = 'Equation* Environment' },
        { t '\\begin{equation*}\n', d(1, get_visual), t '\\end{equation*}' }),
    s({ trig = ';bal', snippetType = 'autosnippet', desc = 'Align Environment' },
        { t '\\begin{align}\n', d(1, get_visual), t '\\end{align}' }),
    s({ trig = ';bsal', snippetType = 'autosnippet', desc = 'Align* Environment' },
        { t '\\begin{align*}\n', d(1, get_visual), t '\\end{align*}' }),
    s(
        { trig = ';bfig', snippetType = 'autosnippet', desc = 'Figure' },
        fmta('\\begin{figure}[<>]\n\t\\centering\n\t\\caption{<>}\\label{<>}\n\\end{figure}<>',
            { i(2), i(3), i(1), i(0) })
    ),
    s({ trig = ',ci', snippetType = 'autosnippet' }, fmta('\\autocite[<>]{<>}<>', { i(2), i(1), i(0) })),
}
-- \\begin{figure}[${1:htbp}]\n\t\\centering\n\t${0:${TM_SELECTED_TEXT}}\n\t\\caption{${2:<caption>}}\\label{${3:<label>}}\n\\end{figure}

local global_snippets = {
    s(
        { trig = ';aut', snippetType = 'autosnippet', desc = 'Toggle Autocomplete' },
        f(function()
            if vim.b.cmp_enabled then
                vim.b.cmp_enabled = false
                require('fidget').notify 'Suggestions Disabled'
            else
                vim.b.cmp_enabled = true
                require('fidget').notify 'Suggestions Enabled'
            end
            RefreshCmpState()
        end)
    ),
}

luasnip.add_snippets('all', global_snippets)
luasnip.add_snippets('markdown', greek_letter_snippets)
luasnip.add_snippets('markdown', text_fraction_snippets)
luasnip.add_snippets('markdown', math_snippets)
luasnip.add_snippets('markdown', markdown_snippets)
luasnip.add_snippets('tex', text_fraction_snippets)
luasnip.add_snippets('tex', greek_letter_snippets)
luasnip.add_snippets('tex', math_snippets)
luasnip.add_snippets('tex', tex_snippets)

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
--
