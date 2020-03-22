" pathogen config
execute pathogen#infect()

" syntax highlighting and numbers
syntax on
set number

" retain the visual selection after having pressed > or <
vnoremap > >gv
vnoremap < <gv

" paste selection multiple times
xnoremap p pgvy

" buffers
nnoremap <C-n> :bnext<CR>
nnoremap <C-p> :bpreviou<CR>

" tab config
filetype plugin indent on
set tabstop=4
set shiftwidth=4
set expandtab
nnoremap <Tab> >>_
nnoremap <S-Tab> <<_
inoremap <S-Tab> <C-D>
vnoremap <Tab> >gv
vnoremap <S-Tab> <gv

" NerdTree config
" map <C-n> :NERDTreeToggle<CR>

" Ctrl-Space for completions. Heck Yeah!
inoremap <expr> <C-Space> pumvisible() \|\| &omnifunc == '' ?
            \ "\<lt>C-n>" :
            \ "\<lt>C-x>\<lt>C-o><c-r>"
imap <C-@> <C-Space>

" colors config
set background=dark
colorscheme solarized

" markdonw config
let g:vim_markdown_folding_disabled=1
let g:markdown_enable_conceal = 1

" system clipboard
set clipboard=unnamedplus

