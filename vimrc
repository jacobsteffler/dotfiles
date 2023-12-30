set number                                      " Show line numbers
set numberwidth=1                               " Thin line numbers
set relativenumber                              " Relative line numbers
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
set shiftwidth=4                                " Four-character tabs
set expandtab                                   " Insert spaces for tabs
set softtabstop=-1                              " Copy softtabstop from shiftwidth
set splitbelow splitright                       " Split directions
set wrap                                        " Soft wrap lines
set linebreak                                   " Try to split lines at certain characters
set sidescroll=1                                " Scroll horizontally one character at a time
set title                                       " Control terminal title when supported
set titleold=                                   " If can't restore the old title, just make it empty
set guicursor=                                  " Disable cursor shapes
let &showbreak='+++ '                           " Line break indicator

set laststatus=2                                " Always show status bar
set statusline=%t\                              " Filename
set statusline+=%m                              " Modified flag
set statusline+=[%{strlen(&fenc)?&fenc:'none'}, " File encoding
set statusline+=%{&ff}]                         " File format
set statusline+=%r                              " Read only flag
set statusline+=%y                              " Filetype
set statusline+=%=                              " Left/right separator
set statusline+=%c%V,                           " Cursor column
set statusline+=%l/%L                           " Cursor line/total lines
set statusline+=\ %P                            " Percent through file

" Backspace clears search highlight
nnoremap <silent> <BS> :nohlsearch<CR><BS>

" Syntax highlighting
if has("syntax")
    syntax on
endif

" Indentation rules and plugins
if has("autocmd")
    filetype plugin indent on
endif

" Source machine.vim from the same directory as this vimrc
" If vimrc is a symlink, we won't follow it when looking for machine.vim
let machine_specific=expand('<sfile>:p:h').'/machine.vim'
try
    execute 'source '.fnameescape(machine_specific)
catch
endtry
