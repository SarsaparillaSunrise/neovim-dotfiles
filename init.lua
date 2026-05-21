--[[
  MODERNIZED SINGLE-FILE NEOVIM CONFIG
  Language: Lua
  Manager:  Lazy.nvim
--]]

-- ========================================================================== --
-- ==                           BOOTSTRAP LAZY                             == --
-- ========================================================================== --
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ========================================================================== --
-- ==                             OPTIONS                                  == --
-- ========================================================================== --
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- Appearance
vim.opt.number = true
vim.opt.linebreak = true
vim.opt.cursorline = true
vim.opt.termguicolors = true -- FIXED: Corrected spelling from termguicolours to termguicolors

-- Behavior
vim.opt.clipboard = "unnamedplus" -- System clipboard
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.splitright = true -- 'set spr'
vim.opt.swapfile = false
vim.opt.hidden = true     -- Buffer switching without saving
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- Restore cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- ========================================================================== --
-- ==                             KEYMAPS                                  == --
-- ========================================================================== --
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Fast saving
keymap("n", "<leader>s", ":w<CR>", opts)
keymap("n", "<CR>", ":w<CR>", opts)

-- NEW: Save WITHOUT formatting (Capital S)
keymap("n", "<leader>S", ":noa w<CR>", opts)

-- Buffer management
keymap("n", "<leader>bd", ":bd<CR>", opts)
keymap("n", "<Right>", ":bn<CR>", opts)
keymap("n", "<Left>", ":bp<CR>", opts)

-- End of line
keymap("n", "`", "$", opts)

-- Emacs bindings for command line
keymap("c", "<C-A>", "<Home>", { noremap = true })
keymap("c", "<C-E>", "<End>", { noremap = true })
keymap("c", "<C-K>", "<C-U>", { noremap = true }) -- Clear line

-- Disable F1
keymap("n", "<F1>", ":echo<CR>", opts)

-- ========================================================================== --
-- ==                             PLUGINS                                  == --
-- ========================================================================== --
require("lazy").setup({

  -- 1. THEME: Solarized 8 (Safest Configuration)
  {
    "lifepillar/vim-solarized8",
    lazy = false,
    priority = 1000,
    config = function()
      -- Now that termguicolors is fixed and background is set by the theme,
      -- we only need the colorscheme command.
      vim.cmd("colorscheme solarized8")
    end
  },

  -- 2. FILE EXPLORER (Neo-tree)
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "\\", ":Neotree toggle<CR>", desc = "Toggle Explorer" },
    },
    opts = {
      filesystem = {
        filtered_items = { hide_dotfiles = false, hide_gitignored = false },
      },
    }
  },

  -- 3. TELESCOPE (File Finding)
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "Find Files" })
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = "Live Grep" })
      vim.keymap.set('n', '<leader>fr', builtin.oldfiles, { desc = "Recent Files" })
      vim.keymap.set('n', '<leader>t', builtin.find_files, { desc = "Find Files (Alt)" })
    end
  },

  -- 4. TREESITTER (Syntax Highlighting & Parsers)
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local ts = require("nvim-treesitter")

      -- 1. Tell Treesitter to install your languages
      ts.install({
        "python", "go", "tsx", "typescript", "javascript",
        "lua", "vim", "vimdoc", "rust", "elixir", "yaml", "html", "css"
      })

      -- 2. Turn on native Neovim highlighting and indents globally
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          pcall(vim.treesitter.start)
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end
  },

  -- 5. GIT SIGNS
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require('gitsigns').setup {
        current_line_blame = true,
        current_line_blame_opts = { delay = 500 },
      }
    end
  },

  -- 6. STATUS LINE
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = { theme = "solarized_dark" }
  },

  -- 7. AUTO-PAIRS
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {}
  },

  -- 8. FORMATTING
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
      formatters_by_ft = {
        python = { "ruff_organize_imports", "ruff_format" },
        go = { "gofmt" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
        yaml = { "prettier" },
        json = { "prettier" },
        rust = { "rustfmt" },
        elixir = { "mix" },
      },
      format_on_save = { timeout_ms = 500, lsp_fallback = true },
    },
  },

  -- 9. LSP & AUTOCOMPLETION
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/nvim-cmp",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      local cmp = require('cmp')
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "pyright", "ruff", "gopls", "ts_ls", "elixirls", "html", "yamlls", "rust_analyzer", "cssls", "lua_ls" },
        handlers = {
          function(server_name)
            require("lspconfig")[server_name].setup {
              capabilities = capabilities
            }
          end,
          ["ruff"] = function()
            require("lspconfig").ruff.setup {
              on_attach = function(client, _)
                client.server_capabilities.hoverProvider = false
              end
            }
          end
        }
      })

      -- Autocompletion Setup
      cmp.setup({
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping.select_next_item(),
          ['<S-Tab>'] = cmp.mapping.select_prev_item(),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        }, {
          { name = 'buffer' },
        })
      })

      -- Keymaps for LSP
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
          local opts = { buffer = ev.buf }
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
          vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
        end,
      })
    end
  },

  -- 10. TODO COMMENTS
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    keys = {
      { "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "Find TODOs" },
    }
  },

  -- 11. COMMENTING
  {
    "numToStr/Comment.nvim",
    -- TODO: The `<leader>cc` keymap is currently disabled due to a persistent API/loading conflict.
    -- Use the built-in 'gcc' for now. To re-enable the custom keymap later, uncomment the 'keys' block below,
    -- and use the 'lazy = false' and 'config = function() ... end' structure we attempted previously.
    keys = {
      -- { "<leader>cc", mode = { "n", "v" }, desc = "Toggle Comment (FIX ME)" },
    },
    opts = {},
  },

  -- 12. AUTO-CLOSING TAGS (for HTML/TSX/JSX)
  {
    "windwp/nvim-ts-autotag",
    ft = { "html", "javascript", "typescript", "javascriptreact", "typescriptreact" },
    opts = {},
  },

  -- 13. TELESCOPE FZF NATIVE (Performance Boost)
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    cond = function()
      return vim.fn.executable("make") == 1
    end,
  },
})
