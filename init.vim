"##########"
" vim-plug "
"##########"

call plug#begin()
Plug 'frazrepo/vim-rainbow'
Plug 'junegunn/fzf', { 'do': './install --all' } | Plug 'junegunn/fzf.vim'
Plug 'junegunn/fzf.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'vim-airline/vim-airline' | Plug 'vim-airline/vim-airline-themes'
Plug 'vim-scripts/tcomment'
call plug#end()

"###########"
" Shortcuts "
"###########"

" Assign a leader:
let g:mapleader = ","

" Fast saving:
nmap <leader>s :w<CR>

" Close buffer:
nmap <leader>bd :bd<CR>

" Map arrows to switch between open buffers:
map <right> :bn<CR>
map <left> :bp<CR>

" End of line:
map ` $

" Unmap F1:
nmap <F1> :echo<CR>

"############"
" Appearance "
"############"

set number
set linebreak

" Sets colours
set background=light

"###########"
" Behaviour "
"###########"

" Use system clipboard
set clipboard=unnamedplus

" Indentation
set shiftwidth=2

" Replace tabs with spaces:
set expandtab

" Vertical splits default to right hand side:
set spr

" Disable 'no write since last change':
set hidden

" Disable swapfile:
set noswapfile

" Search:
set ignorecase    " case insensitive
set smartcase     " match uppercase letters
set hlsearch      " Highlight search terms
set incsearch     " Show search matches typed

" Open file at last edited postition:
autocmd BufReadPost * if @% !~# '\.git[\/\\]COMMIT_EDITMSG$' && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif 

" Emacs bindings for the command line:
cnoremap <C-A>        <Home>
cnoremap <C-E>        <End>
cnoremap <C-K>        <C-U>

" Disable automatic insertion of comments (includes workaround setting for bug #4684):
filetype plugin indent on
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" TODO: Autoinsert close brace. Should handle JS and Rust cases. Python
" different

"#########"
" Plugins "
"#########"

" vim-rainbow:
let g:rainbow_active = 1

" FZF:
map <leader>t :FZF <CR>
map <leader>f :Rg 

" CoC:
" Use tab for trigger completion with characters ahead and navigate
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

nnoremap <silent> K :call ShowDocumentation()<CR>

nmap <leader>rn <Plug>(coc-rename)

" NERDTree:
map \ :NERDTreeToggle<CR>
let NERDTreeQuitOnOpen = 1
let NERDTreeIgnore=['\.pyc$']

" vim-airline
let g:airline_powerline_fonts = 1

" TComment:
map <leader>cc :TComment<CR>

