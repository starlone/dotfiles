"
" Starlone VIM Setup
"

if has('vim_starting')
    set nocompatible               " Be iMproved
endif


"***********************************************************************
" Download Vim Plug
"***********************************************************************
let vimplug_exists=expand('~/.vim/autoload/plug.vim')
if !filereadable(vimplug_exists)
    if !executable("curl")
        echoerr "You have to install curl or first install vim-plug yourself!"
        execute "q!"
    endif
    echo "Installing Vim-Plug..."
    echo ""
    silent !\curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    let g:not_finish_vimplug = "yes"

    autocmd VimEnter * PlugInstall
endif



"***********************************************************************
" Plugins
"***********************************************************************
call plug#begin('~/.vim/plugged')

Plug 'tomasr/molokai'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'Valloric/YouCompleteMe'
Plug 'scrooloose/nerdtree'
Plug 'editorconfig/editorconfig-vim'
Plug 'airblade/vim-gitgutter'
Plug 'bronson/vim-trailing-whitespace'
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-commentary'
Plug 'vim-scripts/grep.vim'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --bin' }
Plug 'junegunn/fzf.vim'

" HTML
Plug 'mattn/emmet-vim'
Plug 'Valloric/MatchTagAlways'

"" Postgresql/Mysql
Plug 'ivalkeen/vim-simpledb'

"" Snippets
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'

call plug#end()


"***********************************************************************
""  Basic Setup
"***********************************************************************
"" Map leader to ,
let mapleader=','

"" Encoding
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=ucs-bom,utf8,latin1

"" Fix backspace indent
set backspace=indent,eol,start

"" Tabs. May be overridden by autocmd rules
set tabstop=4
set softtabstop=0
set shiftwidth=4
set expandtab

"" Searching
set hlsearch
set incsearch
set ignorecase
set smartcase

"" Enable hidden buffers
set hidden

set nobackup noswapfile

"" Copy/Paste/Cut
if has('unnamedplus')
    set clipboard=unnamed,unnamedplus
endif

set autoread

set nowrap


"***********************************************************************
""  Language Setup
"***********************************************************************
" HTML
autocmd Filetype html setlocal ts=2 sw=2 expandtab

" XML
autocmd Filetype xml setlocal ts=2 sw=2 expandtab


" javascript
let g:javascript_enable_domhtmlcss = 1

" vim-javascript
augroup vimrc-javascript
    autocmd!
    autocmd FileType javascript set tabstop=2|set shiftwidth=2|set expandtab softtabstop=2 smartindent
augroup END


" python
" vim-python
augroup vimrc-python
    autocmd!
    autocmd FileType python setlocal expandtab shiftwidth=4 tabstop=8 colorcolumn=79
                \ formatoptions+=croq softtabstop=4 smartindent
                \ cinwords=if,elif,else,for,while,try,except,finally,def,class,with
augroup END


"*****************************************************************************
"" Visual Settings
"*****************************************************************************
syntax on
set ruler
set number

"" Status bar
set laststatus=2

"" Disable the blinking cursor.
set gcr=a:blinkon0

set scrolloff=5

colorscheme molokai

set mousemodel=popup
set t_Co=256
set cursorline
set gfn=Monospace\ 11


"*****************************************************************************
"" Abbreviations
"*****************************************************************************
cnoreabbrev W! w!
cnoreabbrev Q! q!
cnoreabbrev Qall! qall!
cnoreabbrev Wq wq
cnoreabbrev Wa wa
cnoreabbrev wQ wq
cnoreabbrev WQ wq
cnoreabbrev W w
cnoreabbrev Q q
cnoreabbrev Qall qall


"*****************************************************************************
"" Mappings
"*****************************************************************************
if has("gui_running")
    "" Save"
    nnoremap <C-s> :w<cr>
    inoremap <C-s> <esc>:w<cr>a

    " Next buffer
    nnoremap <C-Tab> :bn<CR>
    nnoremap <C-PageUp> :bn<CR>

    " Previews buffer
    nnoremap <C-S-Tab> :bp<CR>
    nnoremap <C-PageDown> :bp<CR>
endif

"" Save"
nnoremap <leader>s :w<cr>
inoremap <leader>s <esc>:w<cr>a


"" Buffer nav
noremap <leader>q :bp<CR>
noremap <leader>w :bn<CR>

"" Close buffer
noremap <leader>c :bd<CR>

"" Clean search (highlight)
nnoremap <silent> <leader><space> :noh<cr>

"" Opens an edit command with the path of the currently edited file filled in
noremap <Leader>e :e <C-R>=expand("%:p:h") . "/" <CR>

"" Opens a tab edit command with the path of the currently edited file filled
noremap <Leader>te :tabe <C-R>=expand("%:p:h") . "/" <CR>

"" NerdTree
nnoremap <silent> <F2> :NERDTreeFind<CR>
noremap <F3> :NERDTreeToggle<CR>

"" MatchTagAlways JumpToOtherTag
nnoremap <leader>% :MtaJumpToOtherTag<cr>

"" Set working directory
nnoremap <leader>. :lcd %:p:h<CR>

"" Vmap for maintain Visual Mode after shifting > and <
vmap < <gv
vmap > >gv

"" Move visual block
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" Copy to 'clipboard registry'
vmap <C-c> "*y

" Select all text
nmap <C-a> ggVG

" Indentation
nnoremap <leader>i gg=G''

"" plugins "

" grep.vim
nnoremap <silent> <leader>f :Rgrep<CR>

" fzf.vim
cnoremap <C-P> <C-R>=expand("%:p:h") . "/" <CR>
nnoremap <silent> <leader>b :Buffers<CR>
nnoremap <silent> <leader>e :FZF -m<CR>

" YouCompleteMe
nnoremap <leader>yi :YcmCompleter Format<CR>
nnoremap <leader>yo :YcmCompleter OrganizeImports<CR>
nnoremap <leader>yu :YcmCompleter FixIt<CR>


"*****************************************************************************
" Plugins Setup
"*****************************************************************************
" YCM YouCompleteME
let g:ycm_key_list_select_completion = ['<TAB>', '<Down>', '<Enter>']

"" NERDTree configuration
let g:NERDTreeChDirMode=2
let g:NERDTreeIgnore=['\.rbc$', '\~$', '\.pyc$', '\.db$', '\.sqlite$', '__pycache__']
let g:NERDTreeSortOrder=['^__\.py$', '\/$', '*', '\.swp$', '\.bak$', '\~$']
let g:NERDTreeShowBookmarks=1
let g:nerdtree_tabs_focus_on_files=1
let g:NERDTreeMapOpenInTabSilent = '<RightMouse>'
let g:NERDTreeWinSize = 50
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.pyc,*.db,*.sqlite

" grep.vim
let Grep_Default_Options = '-IR'
let Grep_Skip_Files = '*.log *.db'
let Grep_Skip_Dirs = '.git node_modules'

"" fzf.vim
set wildmode=list:longest,list:full
set wildignore+=*.o,*.obj,.git,*.rbc,*.pyc,__pycache__
let $FZF_DEFAULT_COMMAND =  "find * -path '*/\.*' -prune -o -path 'node_modules/**' -prune -o -path 'target/**' -prune -o -path 'dist/**' -prune -o  -type f -print -o -type l -print 2> /dev/null"

" The Silver Searcher
if executable('ag')
    let $FZF_DEFAULT_COMMAND = 'ag --hidden --ignore .git -g ""'
    set grepprg=ag\ --nogroup\ --nocolor
endif

" ripgrep
if executable('rg')
    let $FZF_DEFAULT_COMMAND = 'rg --files --hidden --follow --glob "!.git/*"'
    set grepprg=rg\ --vimgrep
    command! -bang -nargs=* Find call fzf#vim#grep('rg --column --line-number --no-heading --fixed-strings --ignore-case --hidden --follow --glob "!.git/*" --color "always" '.shellescape(<q-args>).'| tr -d "\017"', 1, <bang>0)
endif

" Airline
let g:airline_theme = 'luna'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#branch#enabled=1
let g:airline#extensions#tagbar#enabled = 1

if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif

if !exists('g:airline_powerline_fonts')
    let g:airline#extensions#tabline#left_sep = ' '
    let g:airline#extensions#tabline#left_alt_sep = '|'
    let g:airline_left_sep          = '▶'
    let g:airline_left_alt_sep      = '»'
    let g:airline_right_sep         = '◀'
    let g:airline_right_alt_sep     = '«'
    let g:airline#extensions#branch#prefix     = '⤴' "➔, ➥, ⎇
    let g:airline#extensions#readonly#symbol   = '⊘'
    let g:airline#extensions#linecolumn#prefix = '¶'
    let g:airline#extensions#paste#symbol      = 'ρ'
    let g:airline_symbols.linenr    = '␊'
    let g:airline_symbols.branch    = '⎇'
    let g:airline_symbols.paste     = 'ρ'
    let g:airline_symbols.paste     = 'Þ'
    let g:airline_symbols.paste     = '∥'
    let g:airline_symbols.whitespace = 'Ξ'
else
    let g:airline#extensions#tabline#left_sep = ''
    let g:airline#extensions#tabline#left_alt_sep = ''

    " powerline symbols
    let g:airline_left_sep = ''
    let g:airline_left_alt_sep = ''
    let g:airline_right_sep = ''
    let g:airline_right_alt_sep = ''
    let g:airline_symbols.branch = ''
    let g:airline_symbols.readonly = ''
    let g:airline_symbols.linenr = ''
endif

