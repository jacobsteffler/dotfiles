if has("win32")
    call plug#begin('$HOME\vimfiles\plugged')   " Start loading plugins
else
    call plug#begin('$HOME/.vim/plugged')
endif

Plug 'tpope/vim-commentary'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'flazz/vim-colorschemes'

call plug#end()                                 " End of plugins

set nocompatible                                " IMproved
set number                                      " Show line numbers
set numberwidth=1                               " Thin line numbers
set relativenumber                              " Relative line numbers
set ruler                                       " Show ruler
set showcmd                                     " Show partial command in status line
set mouse=a                                     " Enable mouse usage
set wildmenu                                    " Tab-completion menu
set wildignorecase                              " Ignore case in wildmenu
set showmatch                                   " Show matching brackets
set hidden                                      " Hide buffers when they are abandoned
set autowrite                                   " Automatically write on :next, :make
set backspace=indent,eol,start                  " Backspace duties
set autochdir                                   " Change working directory to match file
set incsearch                                   " Incremental search
set hlsearch                                    " Highlight searches
set ignorecase                                  " Ignore case in search...
set smartcase                                   "  ...except when search contains a capital
set switchbuf=useopen                           " Switch windows if file is already open
set tabstop=4 shiftwidth=4                      " Smaller tab stops
set expandtab softtabstop=4                     " Spaces for tabs
set splitbelow splitright                       " Split directions
set laststatus=2                                " Always show status bar

" Backspace clears search highlight
nnoremap <silent> <BS> :nohlsearch<CR><BS>

" Jump to the last position when reopening a file
if has("autocmd")
    au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" Syntax highlighting
if has("syntax")
    syntax on
endif

" Indentation rules and plugins
if has("autocmd")
    filetype plugin indent on
endif

" Assume LaTeX for .tex files
let g:tex_flavor = "latex"
