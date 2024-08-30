<h1 align="center">Neovim Dotfiles</h1>
<br>

# Installation

Install dependencies and run:

    mkdir -p ~/.config/nvim
    git clone https://github.com/SarsaparillaSunrise/neovim-dotfiles.git ~/.config/nvim
    sh -c 'curl -fLo $HOME/.local/share/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    nvim +PlugInstall


Dependencies:
-------------
  - fzf
  - ripgrep
  - [vim-plug](https://github.com/junegunn/vim-plug)
  - elixir-ls
  - Ruff


Plugins:
--------
  - https://github.com/fannheyward/coc-pyright
  - https://github.com/josa42/coc-sh
  - https://github.com/neoclide/coc-prettier
  - https://github.com/neoclide/coc-tsserver


