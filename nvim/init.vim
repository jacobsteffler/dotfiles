set number
set relativenumber

set wildignorecase
set ignorecase
set smartcase

set splitbelow splitright

set title

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

inoremap ;; <Esc>
nnoremap <silent> <BS> :nohlsearch<CR><BS>
