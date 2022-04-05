if &compatible  " if-statement probably because nocompatible might overwrite defaults
  set nocompatible               " Be iMproved
endif


" Add my custom snippets:
set runtimepath+=/home/jan/repositories/github.com/jheidbrink/custom-snippets


" General {{{
set history=10000
filetype on
" Set to auto read when a file is changed from the outside
set autoread
" }}}


" VIM user interface {{{
" Set 7 lines to the cursor - when moving vertically using j/k
set scrolloff=7
" Turn on the WiLd menu
set wildmenu
set wildmode=list:longest,full
" Ignore compiled files
set wildignore=*.o,*~,*.pyc
" Always show current position
set ruler
" Always show line numbers
set number
" Height of the command bar
set cmdheight=1
" A buffer becomes hidden when it is abandoned
set hidden
" Ignore case when searching
set ignorecase
" When searching try to be smart about cases
set smartcase
" Highlight search results
set hlsearch
" Makes search act like search in modern browsers
set incsearch
" Don't redraw while executing macros (good performance config)
set lazyredraw
" For regular expressions turn magic on
set magic
" Show matching brackets when text indicator is over them
set showmatch
" How many tenths of a second to blink when matching brackets
set matchtime=2
" No annoying sound on errors
set noerrorbells
set novisualbell
set t_vb=
set timeoutlen=500

" allow backspace over start of insert, end of lines  and for indents:
set backspace=start,indent,eol

set nowrap " don't wrap text when displaying long lines

" show whitespace:
set list
" configure whitespace display, also shows a > when there is text right of the
" terminal window (when nowrap is set), and < when there is text left of the
" terminal window:
set list listchars=eol:¬,tab:→→,extends:>,precedes:<
" When using extends, and with sidescroll=1 which is the VIM default, with
" some combination of line length and editor window width, when moving the
" cursor to the last character of the line with `$`, the rightmost character I
" see is the "extends" character, and I do not see the last character of the
" line. Also see the issue I opened for this: https://github.com/neovim/neovim/issues/16793
" I got hinted to sidescrolloff, and the help for help for sidescrolloff also
" mentions to combine it with "listchars=extends:>"
" Note that this is only an issue sidescroll=1 which is an nvim default.
set sidescrolloff=1
" }}}


" Colors and Fonts settings {{{
syntax on
" }}}


" Text, Tabs and Indenting {{{
set shiftwidth=4
set tabstop=4
set expandtab
set softtabstop=4
" }}}
"

" autocommands {{{
if has("autocmd")
  " from "https://stackoverflow.com/questions/923737/detect-file-change-offer-to-reload-file":
  " autocmd FileChangedShell * echo "Warning: File changed on disk"
  " (deactivated because the following is better:)
  " when moving cursor and then waiting for some delay (default 4 seconds),
  " call checktime which checks if any buffer was modified from outside vim
  autocmd CursorHold * checktime
  autocmd BufRead,BufNewFile *.pde set filetype=arduino
  autocmd BufRead,BufNewFile *.ino set filetype=arduino
  autocmd FileType text setlocal textwidth=0 tabstop=2 softtabstop=2 shiftwidth=2 expandtab
  autocmd FileType python setlocal foldmethod=indent
  autocmd FileType cpp setlocal foldmethod=syntax
  autocmd FileType cpp setlocal number
  autocmd BufRead,BufNewFile *.strace set filetype=strace
  autocmd FileType json setlocal foldmethod=syntax
  autocmd FileType yaml setlocal foldmethod=syntax tabstop=2 softtabstop=2 shiftwidth=2
  " from mgold on stackoverflow:
  " autocmd BufNewFile,BufRead *.tex set makeprg=pdflatex\ %\ &&\ open\ %:r.pdf
  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif
endif " has("autocmd")
" }}}
"

" Mappings {{{
" enter command-mode with space:
noremap <Space> :
" Smart way to move between windows
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l
" smart way to move between tabs
nmap <Left> :bprev<cr>
nmap <Right> :bnext<cr>

" local leader:
let maplocalleader = ','

" Fast saving
nmap <leader>w :write!<cr>
map <C-p> :cprevious<cr>
map <C-n> :cnext<cr>
nnoremap <leader>a :cclose<CR>
" Mappings }}}

" junegunn/fzf-vim {{{
nnoremap <silent> <leader>f :Files<CR>
nnoremap <silent> <leader>b :Buffers<CR>
nnoremap <silent> <leader>c :Commands<CR>
nnoremap <silent> <leader>g :Commits<CR>
nnoremap          <leader>/ :Rg<Space>
nnoremap          <leader>z :Rg<CR>
" junegunn/fzf-vim }}}


" mbbill/undotree {{{
nnoremap <F5> :UndotreeToggle<CR>
" mbbill/undotree }}}


" SirVer/ultisnips {{{
let g:UltiSnipsExpandTrigger = '<C-l>'
let g:UltiSnipsJumpForwardTrigger = '<C-j>'
let g:UltiSnipsJumpBackwardTrigger = '<C-k>'
" SirVer/ultisnips }}}


" w0rp/ale {{{
let g:ale_linters = { 'python': ['pylint'], 'haskell': ['hlint', 'stack-build']}
let g:ale_python_pylint_options = "--disable=missing-docstring --disable=miscellaneous --disable=invalid-name --disable=too-few-public-methods --max-args=7 --disable=line-too-long"
" w0rp/ale }}}

" davidhalter/jedi-vim {{{
" jedi-vim should not complete because deoplete + deoplete-jedi does that:
let g:jedi#completions_enabled = 0
" davidhalter/jedi-vim }}}

" majutsushi/tagbar {{{
nmap <leader>t :TagbarToggle<CR>
" majutsushi/tagbar {{{


" vim: set foldmethod=marker tabstop=2 :
