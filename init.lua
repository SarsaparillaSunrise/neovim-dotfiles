--[[
  MODERNIZED SINGLE-FILE NEOVIM CONFIG
  Language: Lua
  Manager:  Lazy.nvim
--]]

-- ========================================================================== --
-- ==                           BOOTSTRAP LAZY                             == --
-- ========================================================================== --
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
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
vim.opt.termguicolors = true

-- Behavior
vim.opt.clipboard = "unnamedplus" -- System clipboard
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.splitright = true -- 'set spr'
vim.opt.swapfile = false
vim.opt.hidden = true     -- Buffer switching without saving
vim.opt.undofile = true   -- Persistent undo across sessions
vim.opt.signcolumn = "yes" -- Gutter always visible; no sideways jump when signs appear
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.updatetime = 300 -- Faster CursorHold (document highlight, etc.)

-- Diagnostics
vim.diagnostic.config({
  virtual_text = { prefix = "●", spacing = 2 },
  severity_sort = true,
  float = { border = "rounded", source = true },
})

-- Diagnostics show as passive virtual text; open the full float on demand
-- with <leader>e rather than auto-popping it on every CursorHold (which
-- covered the code you were trying to read).

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
-- Single-key save, e.g. to poke filewatchers / dev servers
keymap("n", "<C-Space>", ":w<CR>", opts)

-- Save without running formatters (:noa skips conform's BufWritePre hook)
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

-- Toggle diagnostics on/off (silences the pyright float/virtual-text nags
-- while reading code). Watch for the red "DIAG OFF" flag in the statusline.
keymap("n", "<leader>td", function()
  local on = vim.diagnostic.is_enabled()
  vim.diagnostic.enable(not on)
  vim.notify("Diagnostics " .. (on and "OFF" or "ON"))
end, opts)

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
      event_handlers = {
        {
          event = "file_opened",
          handler = function()
            vim.cmd("Neotree close")
          end,
        },
      },
    }
  },

  -- 3. TELESCOPE (File Finding)
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },
    },
    config = function()
      local telescope = require('telescope')
      telescope.setup({})
      pcall(telescope.load_extension, 'fzf')

      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>f', builtin.live_grep, { desc = "Live Grep" })
      vim.keymap.set('n', '<leader>t', builtin.find_files, { desc = "Find Files" })
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
        "lua", "vim", "vimdoc", "rust", "elixir", "yaml", "html", "css", "sql", "julia", "http", "json"
      })

      -- 2. Turn on native Neovim highlighting and indents globally
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          -- Only wire up TS indenting for filetypes that actually have a parser.
          if pcall(vim.treesitter.start) then
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
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
    opts = {
      options = { theme = "solarized_dark" },
      sections = {
        lualine_x = {
          {
            function() return "⊘ DIAG OFF" end,
            cond = function() return not vim.diagnostic.is_enabled() end,
            color = { fg = "#fdf6e3", bg = "#dc322f", gui = "bold" },
          },
          "encoding", "fileformat", "filetype",
        },
      },
    },
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
        -- Disabled for legacy codebase; re-enable for normal projects.
        -- python = { "ruff_organize_imports", "ruff_format" },
        python = { "ruff_format" },
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

  -- 9. LSP
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "basedpyright", "ruff", "ts_ls", "elixirls", "html", "yamlls", "rust_analyzer", "cssls", "lua_ls", "julials" },
        automatic_enable = true,
      })

      vim.lsp.config("*", { capabilities = capabilities })

      vim.lsp.config("basedpyright", {
        before_init = function(_, config)
          local venv = vim.fn.getcwd() .. "/.venv/bin/python"
          if vim.fn.filereadable(venv) == 1 then
            config.settings = config.settings or {}
            config.settings.python = config.settings.python or {}
            config.settings.python.pythonPath = venv
          end
        end,
        settings = {
          basedpyright = {
            analysis = {
              -- basedpyright defaults to "recommended", which warns on every
              -- unannotated parameter. "standard" = actual type errors only.
              typeCheckingMode = "standard",
            },
          },
          python = {
            analysis = {
              autoImportCompletions = true,
              indexing = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "workspace",
            },
          },
        },
      })

      vim.lsp.config("ruff", {
        on_attach = function(client, _)
          client.server_capabilities.hoverProvider = false
        end,
      })

      -- Keymaps for LSP
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
          local opts = { buffer = ev.buf }
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
          vim.keymap.set('n', 'gd', require('telescope.builtin').lsp_definitions, opts)
          vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references, opts)
          vim.keymap.set('n', 'gi', require('telescope.builtin').lsp_implementations, opts)
          vim.keymap.set('n', '<leader>ds', require('telescope.builtin').lsp_document_symbols, opts)
          vim.keymap.set('n', '<leader>ws', require('telescope.builtin').lsp_workspace_symbols, opts)
          vim.keymap.set('n', '<leader>k', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
          vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
          vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
          vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count = -1 }) end, opts)
          vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count = 1 }) end, opts)

          local client = vim.lsp.get_client_by_id(ev.data.client_id)

          -- Inlay hints: inferred types + parameter names at call sites.
          if client and client:supports_method('textDocument/inlayHint') then
            vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
            vim.keymap.set('n', '<leader>ih', function()
              local on = vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf })
              vim.lsp.inlay_hint.enable(not on, { bufnr = ev.buf })
            end, opts)
          end

          -- Highlight other uses of the symbol under the cursor (PyCharm-style).
          if client and client:supports_method('textDocument/documentHighlight') then
            local grp = vim.api.nvim_create_augroup('UserDocHighlight' .. ev.buf, { clear = true })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              group = grp, buffer = ev.buf, callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI', 'InsertEnter' }, {
              group = grp, buffer = ev.buf, callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })
    end
  },

  -- 9b. AUTOCOMPLETION (blink.cmp)
  {
    "saghen/blink.cmp",
    version = "1.*", -- release tag ships a prebuilt fuzzy binary (no cargo needed)
    opts = {
      -- Mirror the old nvim-cmp bindings: Tab/S-Tab cycle, <CR> confirms.
      keymap = {
        preset = "none",
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide" },
        ["<CR>"] = { "accept", "fallback" },
        ["<Tab>"] = { "select_next", "fallback" },
        ["<S-Tab>"] = { "select_prev", "fallback" },
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        providers = {
          -- Don't block the menu on pyright (slow with autoImportCompletions);
          -- show buffer/path/snippet matches immediately, stream LSP items in.
          lsp = { async = true },
        },
      },
      completion = {
        documentation = { auto_show = true },
        -- preselect=false keeps <CR> safe in prose: it only confirms an item
        -- you actually Tabbed onto, otherwise it's a plain newline.
        -- auto_insert=true means Tab inserts the item as you cycle, so you can
        -- just keep typing — no <CR> needed to commit plain-text matches.
        -- (<CR>/accept still applies auto-imports and expands snippets.)
        list = { selection = { preselect = false, auto_insert = true } },
      },
      signature = { enabled = true },
      -- No command-line completion (matches the previous setup).
      cmdline = { enabled = false },
    },
  },

  -- 10. TODO COMMENTS
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },

  -- 11. COMMENTING
  {
    "numToStr/Comment.nvim",
    keys = {
      { "<leader>cc", "gcc", mode = "n", remap = true, desc = "Toggle Comment" },
      { "<leader>cc", "gc",  mode = "v", remap = true, desc = "Toggle Comment" },
    },
    opts = {},
  },

  -- 12. AUTO-CLOSING TAGS (for HTML/TSX/JSX)
  {
    "windwp/nvim-ts-autotag",
    ft = { "html", "javascript", "typescript", "javascriptreact", "typescriptreact" },
    opts = {},
  },

  -- 14b. DIFFVIEW (Merge Conflict Resolution & Diffs)
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
    keys = {
      { "<leader>gm", "<cmd>DiffviewOpen<CR>",        desc = "Diffview: open (merge/diff)" },
      { "<leader>gc", "<cmd>DiffviewClose<CR>",       desc = "Diffview: close" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", desc = "Diffview: file history" },
    },
    opts = {
      -- Put a proper 3-way merge layout front and center:
      -- top row = OURS | BASE | THEIRS, bottom = the file you're writing.
      view = {
        merge_tool = {
          -- Small screen: a single full-width window with inline conflict
          -- markers. ,co/,ct/,cb/,ca still work off the markers, so we lose
          -- nothing but the (cramped) side-by-side context panes.
          layout = "diff1_plain",
          disable_diagnostics = true,
        },
      },
    },
  },

  -- 15. SYMBOLS OUTLINE (Aerial)
  {
    "stevearc/aerial.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<leader>o", "<cmd>AerialToggle<CR>", desc = "Toggle Symbols Outline" },
    },
    opts = {
      backends = { "lsp", "treesitter", "markdown", "man" },
      layout = {
        default_direction = "right",
        placement = "edge",
        width = 35,
      },
      attach_mode = "global",
      show_guides = true,
    },
  },

  -- 16. HTTP CLIENT (Kulala) — run .http requests in-editor
  {
    "mistweaverco/kulala.nvim",
    ft = { "http", "rest" },
    init = function()
      vim.filetype.add({ extension = { http = "http" } })
    end,
    keys = {
      { "<leader>Rs", function() require("kulala").run() end,        ft = "http", desc = "HTTP: send request" },
      { "<leader>Ra", function() require("kulala").run_all() end,    ft = "http", desc = "HTTP: send all in file" },
      { "<leader>Rr", function() require("kulala").replay() end,     ft = "http", desc = "HTTP: replay last" },
      { "<leader>Rt", function() require("kulala").toggle_view() end, ft = "http", desc = "HTTP: toggle body/headers" },
    },
    opts = {},
  },

  -- 17. DEBUGGER (nvim-dap + Python)
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "mfussenegger/nvim-dap-python",
    },
    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "DAP: breakpoint" },
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end, desc = "DAP: conditional breakpoint" },
      { "<leader>dc", function() require("dap").continue() end, desc = "DAP: continue / start" },
      { "<leader>dn", function() require("dap").step_over() end, desc = "DAP: step over" },
      { "<leader>di", function() require("dap").step_into() end, desc = "DAP: step into" },
      { "<leader>do", function() require("dap").step_out() end, desc = "DAP: step out" },
      { "<leader>dq", function() require("dap").terminate() end, desc = "DAP: terminate" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "DAP: toggle UI" },
    },
    config = function()
      local dap, dapui = require("dap"), require("dapui")
      dapui.setup()

      -- Use the project venv's python if it has debugpy, else fall back.
      local venv = vim.fn.getcwd() .. "/.venv/bin/python"
      require("dap-python").setup(vim.fn.filereadable(venv) == 1 and venv or "python")

      -- FastAPI: launch uvicorn under the debugger. --reload is deliberately
      -- omitted; its subprocess reloader detaches from debugpy so breakpoints
      -- wouldn't hit.
      table.insert(dap.configurations.python, {
        type = "python",
        request = "launch",
        name = "FastAPI (uvicorn)",
        module = "uvicorn",
        args = function()
          return { vim.fn.input("App target: ", "app.main:app") }
        end,
        justMyCode = false,
        console = "integratedTerminal",
      })

      -- Auto-open/close the UI with the session.
      dap.listeners.before.attach.dapui_config = function() dapui.open() end
      dap.listeners.before.launch.dapui_config = function() dapui.open() end
      dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
      dap.listeners.before.event_exited.dapui_config = function() dapui.close() end
    end,
  },

  -- 18. FIND & REPLACE (grug-far) — project-wide, with live preview
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    keys = {
      { "<leader>sr", function() require("grug-far").open() end, mode = { "n", "v" }, desc = "Search & replace (project)" },
    },
    opts = {},
  },

  -- 19. HARPOON — pin a handful of files and jump between them
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>a", function() require("harpoon"):list():add() end, desc = "Harpoon: pin file" },
      { "<leader>h", function() local h = require("harpoon"); h.ui:toggle_quick_menu(h:list()) end, desc = "Harpoon: menu" },
      { "<leader>1", function() require("harpoon"):list():select(1) end, desc = "Harpoon: file 1" },
      { "<leader>2", function() require("harpoon"):list():select(2) end, desc = "Harpoon: file 2" },
      { "<leader>3", function() require("harpoon"):list():select(3) end, desc = "Harpoon: file 3" },
      { "<leader>4", function() require("harpoon"):list():select(4) end, desc = "Harpoon: file 4" },
    },
    config = function()
      require("harpoon"):setup()
    end,
  },

  -- 19b. INLAY HINT FILLER — turn the ghost "x=" hints into real kwargs
  {
    "Davidyz/inlayhint-filler.nvim",
    keys = {
      {
        "<leader>I",
        function() require("inlayhint-filler").fill() end,
        mode = { "n", "v" },
        desc = "Insert inlay hint(s) into buffer (kwargs-ify call)",
      },
    },
  },

  -- 20. BREADCRUMBS (dropbar) — path + code context in the winbar
  {
    "Bekaboo/dropbar.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },

  -- 21. REFACTORING — extract function / variable / inline
  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "lewis6991/async.nvim",
    },
    keys = {
      { "<leader>rr", function() require("refactoring").select_refactor() end, mode = { "n", "x" }, desc = "Refactor: menu" },
    },
    opts = {},
  },
})
