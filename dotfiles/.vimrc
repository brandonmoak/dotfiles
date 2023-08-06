set nocompatible              " be iMproved, required
filetype off                  " required

" Load vim-plug - install if not present
" vim
if empty(glob("~/.vim/autoload/plug.vim"))
  execute '!curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
endif
" neovim
if empty(glob("~/.local/share/nvim/site/autoload/plug.vim"))
    execute '!curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
endif

" Specify a directory for plugins (for Neovim: ~/.local/share/nvim/plugged)
call plug#begin('~/.vim/plugged')

" Fuzzy search folder tree
Plug 'ctrlpvim/ctrlp.vim'
" Autoclose parentheses, brackets, quotes, etc.
Plug 'Townk/vim-autoclose'
" Plugin for golang, allows for fun stuff like :GoDef
Plug 'fatih/vim-go'
" Allows you to prefix movements with ',' to move through
" CamelCased/snake_cased word movements (e.g. ,w ,b ,e)
Plug 'vim-scripts/camelcasemotion'
" Nicely formats JSON
Plug 'leshill/vim-json'
" Press ctrl+n to browse directory tree
Plug 'scrooloose/nerdtree'
" Shows changes to git repo files in nerdtree
Plug 'Xuyuanp/nerdtree-git-plugin'
" Status bar
Plug 'vim-airline/vim-airline'
" JS Linter (via JSHint)
Plug 'Shutnik/jshint2.vim'
" Color scheme
Plug 'joshdick/onedark.vim'
" Improved syntax highlighting
Plug 'sheerun/vim-polyglot'
" Seamlessly navigate vim splits and tmux panes
" https://robots.thoughtbot.com/seamlessly-navigate-vim-and-tmux-splits
" Plug 'christoomey/vim-tmux-navigator'
  " Show git diff on left side
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
" Show class definitions
Plug 'majutsushi/tagbar'
"
" Easy motions using \\w
Plug 'easymotion/vim-easymotion'
" Easy motion shortcuts:
" \w make every word a target
map <Leader>w <Leader><Leader>w
" \W make every space separated word a target
map <Leader>W <Leader><Leader>W
" \b make every word a target (backwards)
map <Leader>b <Leader><Leader>b
" \b make every space separated word a target (backwards)
map <Leader>B <Leader><Leader>B
" \fx make every character x in the line a target
map <Leader>f <Leader><Leader>f

" Neovim-specific plugins
if (has("nvim"))
  Plug 'Shougo/deoplete.nvim'
  "let g:deoplete#enable_at_startup = 1
endif

" All of your Plugins must be added before the following line
call plug#end()              " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Plugged package manager commands
" :PlugList       - lists configured plugins
" :PlugInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PlugSearch foo - searches for foo; append `!` to refresh local cache
" :PlugClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line
"

nmap <C-a> :TagbarToggle<CR>

" NERDTree shit
" Toggle NERDTree with Ctrl+n
map <C-n> :NERDTreeToggle<CR>
" Ignore certain files in NERDTree
let NERDTreeIgnore = ['\.pyc$','\.class$']
" Show relative line numbers in NERDTree
" enable line numbers
let NERDTreeShowLineNumbers=1
" make sure relative line numbers are used
autocmd FileType nerdtree setlocal relativenumber

" ctrlp shit
" Force files searched for to be open in a new buffer,
" even if they're already open in another split
let g:ctrlp_switch_buffer = 0
let g:ctrlp_custom_ignore = 'node_modules\|DS_Store'

" Enable filetype plugin
filetype on
filetype plugin on
filetype indent on

" Turn on syntax highlighting
syntax on

" autoindent stuff as you are coding
set autoindent

" set the tab to 2 space per google coding guidelines
set tabstop=2
set shiftwidth=2

" Google code guidelines for python are 4 spaces a tab
autocmd FileType python setlocal expandtab shiftwidth=4 softtabstop=4
set expandtab

" json highlighting
au! BufRead,BufNewFile *.json set filetype=json "foldmethod=syntax

" faster viewport scrolling
nnoremap <C-e> 3<C-e>
nnoremap <C-y> 3<C-y>

" HACK: nvim doesn't support <Ctrl-h> natively, it remaps to <BS> (backspace)
" for some reason. This breaks split navigation soo...
" https://github.com/neovim/neovim/issues/2048#issuecomment-78534227
if has('nvim')
     nmap <BS> <C-W>h
 endif
" Same hack as above, but to make it work with tmux-vim-navigator
" https://github.com/neovim/neovim/issues/2048#issuecomment-92776095

" Change active split with tab
nmap <tab> <C-w>w

" Change buffers with ctrl-x and ctrl-c
"nmap <C-x> :prev<CR>
"nmap <C-c> :next<CR>

" strip trailing whitespace
map <LocalLeader>ks :%s/\s\+$//g<CR>

"  convert tabs to spaces
map <LocalLeader>kt :%s/\t/  /g<CR>

" set history to be longer
set history=1000

" begin substitution
map <C-h> :%s/

" shut the F*** up
set visualbell

" Change highlight color for pyflakes-vim
highlight SpellBad term=reverse ctermbg=2

"  Highlight text that goes beyond 90 char column limit
"highlight OverLength ctermbg=red ctermfg=white guibg=#592929
"match OverLength /\%91v.\+/

" Automatically show line numbers
set nu
set relativenumber " Shows relative numbers when in selection mode

"LaTeX Setup
" REQUIRED. This makes vim invoke Latex-Suite when you open a tex file.
filetype plugin on

" IMPORTANT: win32 users will need to have 'shellslash' set so that latex
" can be called correctly.
set shellslash

" IMPORTANT: grep will sometimes skip displaying the file name if you
" search in a single file. This will confuse Latex-Suite. Set your grep
" program to always generate a file-name.
set grepprg=grep\ -nH\ $*

" OPTIONAL: This enables automatic indentation as you type.
filetype indent on

" OPTIONAL: Starting with Vim 7, the filetype of empty .tex files defaults to
" 'plaintex' instead of 'tex', which results in vim-latex not being loaded.
" The following changes the default filetype back to 'tex':
let g:tex_flavor='latex'

set backspace=indent,eol,start

" Enable folding
set foldmethod=indent
set foldlevelstart=99

" Jump to the next or previous line that has the same level or a lower
" level of indentation than the current line.
"
" exclusive (bool): true: Motion is exclusive
" false: Motion is inclusive
" fwd (bool): true: Go to next line
" false: Go to previous line
" lowerlevel (bool): true: Go to line with lower indentation level
" false: Go to line with the same indentation level
" skipblanks (bool): true: Skip blank lines
" false: Don't skip blank lines
function! NextIndent(exclusive, fwd, lowerlevel, skipblanks)
  let line = line('.')
  let column = col('.')
  let lastline = line('$')
  let indent = indent(line)
  let stepvalue = a:fwd ? 1 : -1
  while (line > 0 && line <= lastline)
    let line = line + stepvalue
    if ( ! a:lowerlevel && indent(line) == indent ||
          \ a:lowerlevel && indent(line) < indent)
      if (! a:skipblanks || strlen(getline(line)) > 0)
        if (a:exclusive)
          let line = line - stepvalue
        endif
        exe line
        exe "normal " column . "|"
        return
      endif
    endif
  endwhile
endfunction

" Moving back and forth between lines of same or lower indentation.
nnoremap <silent> [l :call NextIndent(0, 0, 0, 1)<CR>
nnoremap <silent> ]l :call NextIndent(0, 1, 0, 1)<CR>
nnoremap <silent> [L :call NextIndent(0, 0, 1, 1)<CR>
nnoremap <silent> ]L :call NextIndent(0, 1, 1, 1)<CR>
vnoremap <silent> [l <Esc>:call NextIndent(0, 0, 0, 1)<CR>m'gv''
vnoremap <silent> ]l <Esc>:call NextIndent(0, 1, 0, 1)<CR>m'gv''
vnoremap <silent> [L <Esc>:call NextIndent(0, 0, 1, 1)<CR>m'gv''
vnoremap <silent> ]L <Esc>:call NextIndent(0, 1, 1, 1)<CR>m'gv''
onoremap <silent> [l :call NextIndent(0, 0, 0, 1)<CR>
onoremap <silent> ]l :call NextIndent(0, 1, 0, 1)<CR>
onoremap <silent> [L :call NextIndent(1, 0, 1, 1)<CR>
onoremap <silent> ]L :call NextIndent(1, 1, 1, 1)<CR>

" Disable Ex mode
map Q <Nop>

" Enable window swapping
function! MarkWindowSwap()
    let g:markedWinNum = winnr()
endfunction

function! DoWindowSwap()
    "Mark destination
    let curNum = winnr()
    let curBuf = bufnr( "%" )
    exe g:markedWinNum . "wincmd w"
    "Switch to source and shuffle dest->source
    let markedBuf = bufnr( "%" )
    "Hide and open so that we aren't prompted and keep history
    exe 'hide buf' curBuf
    "Switch to dest and shuffle source->dest
    exe curNum . "wincmd w"
    "Hide and open so that we aren't prompted and keep history
    exe 'hide buf' markedBuf
endfunction

nmap <silent> <leader>mw :call MarkWindowSwap()<CR>
nmap <silent> <leader>pw :call DoWindowSwap()<CR>

" To use:
" 1. Move to the window to mark for the swap via ctrl-w movement
" 2. Type \mw
" 3. Move to the window you want to swap
" 4. Type \pw

" Always display the statusline:
:set laststatus=2

" Incremental searching - start search as soon as first char entered after /
set incsearch

" Highlight search matchces
set hlsearch

" disable the guicursor
set guicursor=

" Clear search highlight after hitting enter in normal mode
nnoremap <CR> :noh<CR><CR>

" Neovim!
if (has("nvim"))
  if (empty($TMUX))
    "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
  endif
  " Change cursor shape between insert and normal mode in iTerm2.app
  if $TERM_PROGRAM =~ "iTerm"
    let &t_SI = "\<Esc>]50;CursorShape=1\x7" " Vertical bar in insert mode
    let &t_EI = "\<Esc>]50;CursorShape=0\x7" " Block in normal mode
  endif
  let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1
endif

"Color scheme
"Use 24-bit (true-color) mode in Vim/Neovim when outside tmux.
"If you're using tmux version 2.2 or later, you can remove the outermost $TMUX check and use tmux's 24-bit color support
"(see < http://sunaku.github.io/tmux-24bit-color.html#usage > for more information.)
"if (empty($TMUX))
"  if (has("nvim"))
"    "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
"    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
"  endif
"  "For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
"  "Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
"  " < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
"  if (has("termguicolors"))
"    set termguicolors
"  endif
"endif
colorscheme onedark

" Don't suggest filenames with these extensions when vs or sp or edit etc.
set wildignore+=*.pdf,*.d,*.o,*.pyc,*.jpg,*.jpeg,*.png,*.class

inoremap jk <Esc>
inoremap jj <Esc>
inoremap <Esc> <nop>

let g:go_version_warning = 0

" J always messes with me
" noremap J <nop>

" Spellcheck
" set spell
" :set nospell to disable

" Command to format json
com! JSON %!python -m json.tool

"Remove all trailing whitespace by pressing F5
nnoremap <F5> :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar><CR>

"Remove trailing whitespace
autocmd BufWritePre * :%s/\s\+$//e
