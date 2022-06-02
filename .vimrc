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
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'ryanoasis/vim-devicons'

" Comments
Plug 'tpope/vim-commentary' 

" Theme
Plug 'morhetz/gruvbox'

" Telescope
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'

" lsp, treesitter, autocomplete
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-cmp' " Autocompletion plugin
Plug 'hrsh7th/cmp-nvim-lsp' " LSP source for nvim-cmp
Plug 'saadparwaiz1/cmp_luasnip' " Snippets source for nvim-cmp
Plug 'L3MON4D3/LuaSnip' " Snippets plugin
Plug 'jose-elias-alvarez/null-ls.nvim' " linting, formatting

" Git lines on side
Plug 'lewis6991/gitsigns.nvim'

" Airlines
" Plug 'vim-airline/vim-airline'
" Plug 'vim-airline/vim-airline-themes'

call plug#end()
" : PlugInstall to install theme


" KEYMAP 
let mapleader=" "

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
tnoremap <Esc> <C-\><C-n>
nnoremap <C-p> <cmd>tabe<cr><cmd>Telescope find_files theme=dropdown<cr>
nnoremap <leader>p <cmd>Telescope find_files theme=dropdown<cr>
nnoremap <leader>f <cmd>lua vim.lsp.buf.formatting()<CR>
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

require'lspconfig'.pyright.setup{}
local opts = { noremap=true, silent=true }

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  vim.api.nvim_set_keymap('n', 'gh', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  -- Mappings.
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  if client.name == 'tsserver' then
    client.resolved_capabilities.document_formatting = false
  end
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)
local servers = { 'pyright','tsserver' }
for _, lsp in pairs(servers) do
  require('lspconfig')[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
    flags = {
      debounce_text_changes = 150,
    }
  }
end

-- luasnip setup
local luasnip = require 'luasnip'

-- nvim-cmp setup
local cmp = require 'cmp'
cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}

-- null-ls
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
require("null-ls").setup({
    sources = {
        require("null-ls").builtins.diagnostics.eslint,
        require("null-ls").builtins.code_actions.eslint,
        require("null-ls").builtins.formatting.eslint,
        require("null-ls").builtins.formatting.prettier
    },
})

-- gitsigns setup
require('gitsigns').setup()
EOF

" Snippets
autocmd filetype java ab <buffer> sys System.out.println();<Left><Left>
autocmd filetype java ab <buffer> out. out.println();<Left><Left>
autocmd filetype java ab <buffer> cl Console.log();<Left><Left>
autocmd filetype java ab <buffer> itn int
