" -- Spacing and Indentation
set tabstop=4        " Set the width of a tab
set shiftwidth=4     " Set the width of an indentation
set expandtab        " Use spaces instead of tabs
set autoindent        " Copy indent from current line when starting a new line

" -- Numbers
set number
set relativenumber

" -- Searching
set hlsearch         " Highlight search results
set incsearch        " Incremental search


" -- Other
set mouse=a          " Enable mouse support
set hidden           " Enable background buffers
set wildmenu         " Enable menu for tab-completion


" -- Essential Keymaps
let mapleader = " "
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
vnoremap <C-c> "+y
nnoremap <C-v> "+p
