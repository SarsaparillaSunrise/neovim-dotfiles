-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- Leader key
vim.g.mapleader = ' ' -- Space as the leader key

-- Saving
vim.api.nvim_set_keymap('n', '<Leader>s', ':w<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Enter>', ':w<CR>', { noremap = true, silent = true })

-- Buffers
vim.api.nvim_set_keymap('n', '<Right>', ':bn<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Left>', ':bp<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>bd', ':bd<CR>', { noremap = true, silent = true })

-- TODO: Emacs bindings for command line:

-- Behavioural settings:
vim.o.tabstop = 4 -- Number of spaces a tab represents
vim.o.shiftwidth = 2 -- Number of spaces for each indentation
vim.o.expandtab = true -- Convert tabs to spaces
vim.o.smartindent = true -- Automatically indent new lines
vim.o.spr = true -- Ensure vertical splits are on the right hand side
vim.o.swapfile = false -- Disable swap file
vim.o.clipboard = "unnamedplus"  -- Use system clipboard
-- Prevent automatic comment insertion on new line
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove({ 'r', 'o' })
  end,
})

-- Search settings:
vim.o.ignorecase = true -- case insensitive
vim.o.smartcase = true -- match uppercase letters
vim.o.hlsearch = true -- highlight matches
vim.o.ignorecase = true -- show search matches typed

-- Presentation settings:
vim.o.number = true -- Enable line numbers
vim.o.cursorline = true -- Highlight the current line
vim.o.termguicolors = true -- Enable 24-bit RGB colors
vim.o.linebreak = true -- Enable line breaks

-- Syntax highlighting and filetype plugins
vim.cmd('syntax enable')
vim.cmd('filetype plugin indent on')

-- Setup lazy.nvim
require("lazy").setup({
    {
        'maxmx03/solarized.nvim',
        lazy = false,
        priority = 1000,
        ---@type solarized.config
        opts = {},
        config = function(_, opts)
            vim.o.termguicolors = true
            vim.o.background = 'dark'
            require('solarized').setup(opts)
            vim.cmd.colorscheme 'solarized'
        end,
    },


    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "L3MON4D3/LuaSnip",
            "rafamadriz/friendly-snippets",
            "onsails/lspkind.nvim"
        },
        event = "InsertEnter",
        config = function()
            local cmp = require("cmp")
            cmp.setup({
                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)  -- For `luasnip` users.
                    end,
                },
                mapping = {
                    ["<C-n>"] = cmp.mapping.select_next_item(),
                    ["<C-p>"] = cmp.mapping.select_prev_item(),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        else
                            fallback()  -- The fallback function sends a tab character
                        end
                    end, { "i", "s" }),
                },
                sources = {
                    { name = "nvim_lsp" },
                    { name = "buffer" },
                    { name = "path" },
                },
            })
        end,
    },

    {
        'williamboman/mason.nvim',
        build = ':MasonUpdate',  -- Optional: Update Mason on install
        config = function()
            require("mason").setup()
        end,
    },

    {
        'williamboman/mason-lspconfig.nvim',
        dependencies = { 'williamboman/mason.nvim' },
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "ts_ls",         -- TypeScript server
                    "eslint",        -- JavaScript server
                    "pyright",       -- Python server
                    "elixirls",      -- Elixir server
                    "intelephense",  -- PHP server
                    "bashls",        -- Bash server
                    "tailwindcss",   -- Tailwind CSS server
                },
                automatic_installation = true,  -- Automatically install configured servers
            })
        end,
    },

    {
        'neovim/nvim-lspconfig',
        dependencies = { 'williamboman/mason-lspconfig.nvim' },
        config = function()
            local servers = { "ts_ls", "eslint", "pyright", "elixirls", "intelephense", "bashls", "tailwindcss" }
            for _, server in ipairs(servers) do
                require('lspconfig')[server].setup({})
            end
        end,
    },

    {
        'WhoIsSethDaniel/mason-tool-installer.nvim',
        dependencies = { 'williamboman/mason.nvim' },
        config = function()
            require("mason-tool-installer").setup({
                ensure_installed = {
                    "prettier",  -- Code formatter for various languages
                    "ruff",      -- Python linter
                    "shellcheck" -- Shell script linter
                },
            })
        end,
    },

    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        opts = {
            ensure_installed = { "bash", "html", "javascript", "json", "lua", "python", "elixir", "php" },
            highlight = { enable = true },
        }
    },

    {
      -- TODO: Keybindings: <Leader>t, <Leader>f
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        cmd = { "Telescope" },
        opts = {
            defaults = {
                prompt_prefix = "> ",
                sorting_strategy = "ascending",
                layout_strategy = "flex",
            },
        }
    },


    {
        -- TODO: Bind :Neotree toggle to \ - make it exit on open
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
          "nvim-lua/plenary.nvim",
          "nvim-tree/nvim-web-devicons",
          "MunifTanjim/nui.nvim",
          "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
        }
    },


    {
        'stevearc/conform.nvim',
        opts = {},
    },


    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup({})
        end,
    },

})

