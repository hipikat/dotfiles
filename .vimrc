""
" .vimrc - Adam Wright <adam@hipikat.org>
" 
" TODO: Finish exploring suggested bundles from:
" http://sontek.net/blog/detail/turning-vim-into-a-modern-python-ide
""""""""""""""""""""""""""""""""""""""""""


""""
" Mapleader sets a namespace for custom bindings, defined below
let mapleader=","


""" Vundle configuration
""" https://github.com/gmarik/vundle
"""""""""""""""""""""""""""""""""""""""""""""
set nocompatible        " Be iMproved
filetype off            " Required for vundle setup
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.

Plugin 'ekalinin/Dockerfile.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'majutsushi/tagbar'
Plugin 'vim-scripts/vim-flake8'
Plugin 'saltstack/salt-vim'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line


""" Display
""""""""""""""""""""""""""""""""""""""""
set t_Co=256
colorscheme peachpuff



"""""" unclean .....



syntax on






" let Vundle manage Vundle
" required! 
"Bundle 'gmarik/vundle'

" :BundleList          - list configured bundles
" :BundleInstall(!)    - install(update) bundles
" :BundleSearch(!) foo - search(or refresh cache first) for foo
" :BundleClean(!)      - confirm(or auto-approve) removal of unused bundles
"
" see :h vundle for more details or wiki for FAQ
" NOTE: comments after Bundle command are not allowed.

" Pathogen
"call pathogen#runtime_append_all_bundles()
"call pathogen#infect()
"call pathogen#helptags()

syntax on                     " Syntax highlighting 
"filetype indent off

""""

" Don't let Pyflakes use the Quickfix window
let g:pyflakes_use_quickfix = 1 


" Remap , (repeat f, t, F or T in opposite direction) to default leader
noremap \ ,
" Remap <C-a> (add [count] to number after cursor), which GNU Screen steals.
noremap <leader>a <C-A> 50

" Fix syntax
map <leader>F :syntax sync fromstart<CR>

" Check for pep8 compliance
"let g:pep8_map='<leader>8'
map <leader>8 :call Flake8()<CR>

" Run PyLint
"map <leader>p :PyLint<CR>

" SuperTab completion
au FileType python set omnifunc=pythoncomplete#Complete
let g:SuperTabDefaultCompletionType = "context"

set completeopt=menuone,longest,preview

if version >= 700 
  "let g:SuperTabDefaultCompletionType = "<C-X><C-O>"
  "highlight   clear
  highlight   Pmenu         ctermfg=0 ctermbg=2
  highlight   PmenuSel      ctermfg=0 ctermbg=7
  highlight   PmenuSbar     ctermfg=7 ctermbg=0
  highlight   PmenuThumb    ctermfg=0 ctermbg=7
endif

" NerdTree
map <leader>n :NERDTreeToggle<CR>


" taglist
set updatetime=4000
map <leader>t :TagbarToggle<CR>

" Disable pylint checking every save
let g:pymode_lint_write = 0

" Switch pylint, pyflakes, pep8, mccabe code-checkers
let g:pymode_lint_checker = "pep8"

""
" Behaviour
set ic                  " Ignore case in searches
set noai                " No automatic indentation
set history=50          " Lines in the history buffer
set viminfo='20,\"50    " Remembers information between sessions
set mouse=              " Disable the use of the mouse
set nf=hex              " Incremement and decrement do hex but not octal
set bs=2                " Allow backspacing over anything


" Searching
set incsearch           " Show the first match while typing a pattern
set nohls               " Set search highlighting on by default
set nowrap              " Don't linewrap
map ,, :set hls!<CR>
map! ,, <ESC>:set hls!<CR>a
highlight Search ctermfg=Black ctermbg=DarkBlue cterm=bold guifg=Black guibg=LightBlue gui=bold

" For file name completion, ignore files with the listed suffixes first
set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc

" Tab behaviour
set tabstop=2           " Number of spaces a <Tab> counts for
set shiftwidth=2        " Spaces for each step of (auto)indent
set expandtab           " Use spaces for tabs; Use CTRL-V<Tab> for tabs

"""
" Display
set laststatus=2        " Last window always has a status line
set ruler               " Labels line and column position 
set number              " Show line numbers
map <leader># :set nu!<CR>
set scrolloff=3         " Keep context around the cursor
set showcmd             " Show command being typed in normal mode
" Toggle display of tabs and line endings
set listchars=tab:>-,trail:·,eol:$
nmap <silent> <leader>w :set nolist!<CR>
" Toggle spell-check
nmap <silent> <leader>s :set spell!<CR>
" Split sizing
map <leader>+ 99<C-w>+
" Toggle word wrap
map <leader>r :set wrap!<CR>:set linebreak!<CR>


" Code folding
set foldmethod=indent
set foldlevel=99

"""
" Movement
"""
" Switching between split windows
map <c-j> <c-w>j
map <c-k> <c-w>k
map <c-l> <c-w>l
map <c-h> <c-w>h
" Move view up and down a chunk at a time
map <S-F11> 6<c-e>
map <S-F10> 6<c-y>

" Tab (the other kind) shortcuts
map <F1> :tabn 1<CR>
map <F2> :tabn 2<CR>
map <F3> :tabn 3<CR>
map <F4> :tabn 4<CR>
map <F5> :tabn 5<CR>
map <F6> :tabn 6<CR>
map <F7> :tabn 7<CR>
map <F8> :tabn 8<CR>
map <F9> :tabn 9<CR>
map <F10> :tabn 10<CR>
map! <F1> <ESC>:tabn 1<CR>
map! <F2> <ESC>:tabn 2<CR>
map! <F3> <ESC>:tabn 3<CR>
map! <F4> <ESC>:tabn 4<CR>
map! <F5> <ESC>:tabn 5<CR>
map! <F6> <ESC>:tabn 6<CR>
map! <F7> <ESC>:tabn 7<CR>
map! <F8> <ESC>:tabn 8<CR>
map! <F9> <ESC>:tabn 9<CR>
map! <F10> <ESC>:tabn 10<CR>


" My Bundles here:
"
" original repos on github
"Bundle 'tpope/vim-fugitive'
"Bundle 'Lokaltog/vim-easymotion'
"Bundle 'rstacruz/sparkup', {'rtp': 'vim/'}
"Bundle 'tpope/vim-rails.git'
" vim-scripts repos
"Bundle 'L9'
"Bundle 'FuzzyFinder'
" non github repos
"Bundle 'git://git.wincent.com/command-t.git'
" ...


"
" Brief help
" :BundleList          - list configured bundles
" :BundleInstall(!)    - install(update) bundles
" :BundleSearch(!) foo - search(or refresh cache first) for foo
" :BundleClean(!)      - confirm(or auto-approve) removal of unused bundles
"
" see :h vundle for more details or wiki for FAQ
" NOTE: comments after Bundle command are not allowed.



"filetype plugin on

"let g:miniBufExplMapWindowNavVim = 1
"let g:miniBufExplMapWindowNavArrows = 1
"let g:miniBufExplMapCTabSwitchBufs = 1
"let g:miniBufExplModSelTarget = 1

"autocmd FileType python set omnifunc=pythoncomplete#Complete



" Restructured Text
" #########################
   " Ctrl-u 1:    underline Parts w/ #'s
   noremap  <leader>1 yyPVr#yyjp
   " Ctrl-u 2:    underline Chapters w/ *'s
   noremap  <leader>2 yyPVr*yyjp
   " Ctrl-u 3:    underline Section Level 1 w/ ='s
   noremap  <leader>3 yypVr=
   " Ctrl-u 4:    underline Section Level 2 w/ -'s
   noremap  <leader>4 yypVr-
   " Ctrl-u 5:    underline Section Level 3 w/ ^'s
   noremap  <leader>5 yypVr^



""" Rope project navigation
"map <leader>j :RopeGotoDefinition<CR>
"map <leader>r :RopeRename<CR>
"
"set statusline=%{fugitive#statusline()}
set statusline+=%t       "tail of the filename
"set statusline+=[%{strlen(&fenc)?&fenc:'none'}, "file encoding
"set statusline+=%{&ff}] "file format
set statusline+=%h      "help file flag
set statusline+=%m      "modified flag
set statusline+=%r      "read only flag
"set statusline+=%y      "filetype
set statusline+=%=      "left/right separator
set statusline+=%c,     "cursor column
set statusline+=%l/%L   "cursor line/total lines
set statusline+=\ %P    "percent through file

""" VIM virtualenv awareness
" Add the virtualenv's site-packages to vim path
"py << EOF
"import os.path
"import sys
"import vim
"if 'VIRTUAL_ENV' in os.environ:
"    project_base_dir = os.environ['VIRTUAL_ENV']
"    sys.path.insert(0, project_base_dir)
"    activate_this = os.path.join(project_base_dir, 'bin/activate_this.py')
"    execfile(activate_this, dict(__file__=activate_this))
"EOF


au BufNewFile,BufRead *.less set filetype=less
au BufNewFile,BufRead *.yaml,*.yml,*.sls set filetype=yaml
au BufNewFile,BufRead *.yaml,*.yml,*.sls so ~/.vim/yaml.vim
au BufNewFile,BufRead *.mako,*.mak set filetype=mako
au BufNewFile,BufRead *.mako,*.mak so ~/.vim/mako.vim

autocmd FileType yaml setlocal tabstop=2
autocmd FileType yaml setlocal shiftwidth=2
autocmd FileType yaml setlocal expandtab
"au BufNewFile,BufRead *.sls set filetype=yaml

autocmd FileType sass setlocal tabstop=2

