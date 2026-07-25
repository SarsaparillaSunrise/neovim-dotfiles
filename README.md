<h1 align="center">Neovim Dotfiles</h1>
<br>

A single-file (`init.lua`) Neovim config built on [lazy.nvim](https://github.com/folke/lazy.nvim),
native LSP (`vim.lsp` + Mason), Treesitter, and nvim-cmp.

Requires **Neovim 0.11+** (developed on 0.12).

# Installation

```sh
git clone https://github.com/SarsaparillaSunrise/neovim-dotfiles.git ~/.config/nvim
nvim
```

lazy.nvim bootstraps itself on first launch and installs every plugin. Mason then
auto-installs the language servers listed in `init.lua` (`:Mason` to inspect).

# Dependencies

System tools:

  - `git` — lazy.nvim bootstrap
  - `ripgrep` — Telescope live grep
  - `make` + a C compiler — builds `telescope-fzf-native` and Treesitter parsers
  - `node` — Prettier and several language servers

Formatters (via [conform.nvim](https://github.com/stevearc/conform.nvim)):

  - `ruff` (Python), `prettier` (JS/TS/CSS/HTML/YAML/JSON)
  - `gofmt` (Go), `rustfmt` (Rust), `mix` (Elixir)

Language servers are installed automatically by Mason: basedpyright, ruff, ts_ls,
elixirls, html, yamlls, rust_analyzer, cssls, lua_ls, julials.

# Notable keymaps

Leader is `,`.

  - `<C-Space>` / `<leader>s` — save
  - `<leader>S` — save without running formatters
  - `\` — toggle file explorer (Neo-tree)
  - `<leader>t` / `<leader>f` — find files / live grep (Telescope)
  - `<leader>o` — symbols outline (Aerial)
  - `gd` / `gr` / `<leader>ca` / `<leader>rn` — LSP definitions / references / code action / rename
  - `<leader>gm` — open Diffview (merge/diff)
