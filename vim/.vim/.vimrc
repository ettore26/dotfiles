""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Basic Config
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" multi lines edit keys
""""""""""""""""""""""""
" end of lines edit
""""""""""""""""""""""""
" Visual Block + lines append + finish
" Ctrl+V       + $A           + ESC
" Visual Block + lines append + one normal mode cmd + finish
" Ctrl+V       + $A           + Ctrl+o              + ESC   
""""""""""""""""""""""""

" pathogen config
execute pathogen#infect()

" clearjumps
autocmd VimEnter * :clearjumps

" syntax highlighting, numbers and case
syntax on
set number
set ignorecase
set smartcase

" retain the visual selection after having pressed > or <
vnoremap > >gv
vnoremap < <gv

" paste selection multiple times
xnoremap p pgvy

" buffers
" nnoremap <C-n> :bnext<CR>
" nnoremap <C-p> :bpreviou<CR>

" tab config
filetype plugin indent on
set tabstop=4
set shiftwidth=4
set expandtab
inoremap <S-Tab> <C-D>
vnoremap <Tab> >gv
vnoremap <S-Tab> <gv

" colors config
"set background=dark
colorscheme gruvbox
let g:gruvbox_contrast_light='hard'

" markdonw config
" let g:vim_markdown_folding_disabled=1
" let g:markdown_enable_conceal = 1

" system clipboard
set clipboard+=unnamedplus

"filetype plugin indent on
filetype on
filetype plugin on
filetype indent on

map <C-_> gc

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin Config
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

