set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set ignorecase
set mouse=a
set nowrap
set scrolloff=8
set number                     " Show current line number
" set relativenumber             
set background=dark
set clipboard=unnamedplus     " Install vim-gtk3 to enable copy-paste
set timeoutlen=1000 
set ttimeoutlen=10
set ssop-=options    " do not store global and local values in a session
set ssop-=folds      " do not store folds
set cursorline
set foldmethod=indent   
set foldnestmax=2
set nofoldenable
set foldlevel=2
set formatoptions-=cro  " prevent comment in next line
set splitbelow
set splitright


" PLUGINS
" vim plug - vim plugin manager
" Plugins will be downloaded under the specified directory.
call plug#begin('~/.vim/plugged')

" Nerdtree
Plug 'preservim/nerdtree' 
Plug 'ryanoasis/vim-devicons'

" Comments
Plug 'tpope/vim-commentary' 

" Theme
Plug 'morhetz/gruvbox'

" lsp, treesitter, autocomplete
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Airlines
" Plug 'vim-airline/vim-airline'
" Plug 'vim-airline/vim-airline-themes'

call plug#end()
" : PlugInstall to install theme


" KEYMAP 
let mapleader=" "

nnoremap <C-b> :call ToggleTree()<CR>
map <C-_> :Commentary<CR>
nnoremap <Tab> gt 
nnoremap <S-Tab> gT 
nnoremap <leader>h <C-w>h
nnoremap <leader>j <C-w>j
nnoremap <leader>k <C-w>k
nnoremap <leader>l <C-w>l
nnoremap <leader>r <C-w>r
nnoremap <M-l> 2<c-w>>
nnoremap <M-h> 2<c-w><
nnoremap <M-j> 2<c-w>-
nnoremap <M-k> 2<c-w>+
vnoremap p "_dP
tnoremap <Esc> <C-\><C-n>
command Tq :tabonly 

" Other options
let g:gruvbox_invert_selection=0
colorscheme gruvbox
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_buffers = 0
let g:airline#extensions#tabline#show_splits = 0
let g:airline#extensions#tabline#show_tabs = 1
let g:airline#extensions#tabline#show_tab_nr = 0
let g:airline#extensions#tabline#show_tab_type = 0
let g:airline#extensions#tabline#close_symbol = '×'
let g:airline#extensions#tabline#show_close_button = 0
let g:NERDTreeGitStatusUseNerdFonts = 1
highlight Comment cterm=italic

lua <<EOF
-- TreeSitter
require'nvim-treesitter.configs'.setup {
  -- One of "all", "maintained" (parsers with maintainers), or a list of languages
  ensure_installed = {"java", "typescript", "javascript", "html", "css", "go", "python"},
  -- Install languages synchronously (only applied to `ensure_installed`)
  sync_install = false,
  highlight = {
    -- `false` will disable the whole extension
    enable = true,
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}

EOF

" Snippets
autocmd filetype java ab <buffer> sys System.out.println();<Left><Left>
autocmd filetype java ab <buffer> out. out.println();<Left><Left>
autocmd filetype java ab <buffer> cl Console.log();<Left><Left>
autocmd filetype java ab <buffer> itn int

" Check if NERDTree is open or active
function! IsNERDTreeOpen()
  return exists("t:NERDTreeBufName") && (bufwinnr(t:NERDTreeBufName) != -1)
endfunction

function! CheckIfCurrentBufferIsFile()
  return strlen(expand('%')) > 0
endfunction

" Call NERDTreeFind iff NERDTree is active, current window contains a modifiable
" file, and we're not in vimdiff
function! SyncTree()
  if &modifiable && IsNERDTreeOpen() && CheckIfCurrentBufferIsFile() && !&diff
    NERDTreeFind
    wincmd p
  endif
endfunction

" Highlight currently open buffer in NERDTree
autocmd BufRead * call SyncTree()

function! ToggleTree()
  if CheckIfCurrentBufferIsFile()
    if IsNERDTreeOpen()
      NERDTreeClose
    else
      NERDTreeFind
    endif
  else
    NERDTree
  endif
endfunction

