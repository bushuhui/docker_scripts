""""""""""""""""""""""""""""""""""""""""""""""""
" my .vimrc
" 
" Author: Shuhui Bu
""""""""""""""""""""""""""""""""""""""""""""""""

"notes:
" auto indent long lines
" % vim:tw=78:ts=4:nosmartindent:noautoindent:

""""""""""""""""""""""""""""""""""""""""""""""""
" Display
""""""""""""""""""""""""""""""""""""""""""""""""
" show the cursor position all the time
set ruler

" turn syntax high light on
syntax on

" use visual bell do not bell
"set visualbell

"active wildmenu
set wildmenu


"no wrap
set nowrap


"high-light current line
set cursorline

" show line number
set number
" set number width to 1
if v:version >= 700|set nuw=1|endif

" set right margin
set tw=80
set fo-=t


""""""""""""""""""""""""""""""""""""""""""""""""
" Color scheme
""""""""""""""""""""""""""""""""""""""""""""""""
colorscheme desert

""""""""""""""""""""""""""""""""""""""""""""""""
" set highlight current line or column
""""""""""""""""""""""""""""""""""""""""""""""""
"highlight CursorLine ctermbg=Gray
"highlight CursorLine ctermfg=Blue

"set cursorcolumn
"highlight CursorColumn ctermbg=Blue
"highlight CursorColumn ctermfg=Green


""""""""""""""""""""""""""""""""""""""""""""""""
" Edit
""""""""""""""""""""""""""""""""""""""""""""""""
" default tab to 4
set tabstop=4
" indent shift width
set shiftwidth=4
set softtabstop=4
" insert space instead of tab
set expandtab
" show line number
"set number
" set number width to 1
"set nuw=1
" automatic indent
set autoindent
" smart indent
set smartindent
" c-language indent
"set cindent 
" show match barcket 
set showmatch
" set warp options (left or right key move cursor 
"   to line above or down
set ww=b,s,<,>,[,]
" set back space to "indent, eol, start"
set bs=2

" remember last visited position
set viminfo='10,\"100,:20,%,n~/.viminfo
au BufReadPost * if line("'\"") > 0|if line("'\"") <= line("$")|exe("norm '\"")|else|exe "norm $"|endif|endif


""""""""""""""""""""""""""""""""""""""""""""""""
" Search
""""""""""""""""""""""""""""""""""""""""""""""""
set magic
set incsearch
set ignorecase
set smartcase
set hlsearch

""""""""""""""""""""""""""""""""""""""""""""""""
" Language support
""""""""""""""""""""""""""""""""""""""""""""""""
autocmd FileType python setlocal expandtab shiftwidth=4 tabstop=4 softtabstop=4


""""""""""""""""""""""""""""""""""""""""""""""""
" Steup key-map
""""""""""""""""""""""""""""""""""""""""""""""""

" ctrl-j,k,h,l to move cursor under insert mode
imap        <C-J>       <Down>
imap        <C-K>       <Up>
imap        <C-H>       <LEFT>
imap        <C-L>       <RIGHT>

" c-d delect one char
imap        <C-D>       <Del>

" c-u, c-d in insert mode to pageup or pagedown
imap        <C-U>       <PageUp>
imap        <C-Y>       <PageDown>

imap        <C-F>       <C-RIGHT>
imap        <C-B>       <C-LEFT>

imap        <C-a>       <Home>
imap        <C-e>       <End>

" F4 to toggle the taglist
nnoremap    <F4>        :TlistToggle<cr>
nnoremap    <F5>        :TlistUpdate<cr>

" Ctrl-Q to list buffer (change to buffer)
nnoremap    <C-Q>       :ls<cr>:b 
nnoremap    <C-X>       :FirstExplorerWindow<cr>
nnoremap    <C-F4>      :bd<cr>
nnoremap    <F11>       :MRU<cr>
nnoremap    <F10>       :FufLine<cr>
"nnoremap <unique> <A-1> :w<cr><c-6>



" use global clipboard
"set clipboard=unnamed
" howto use x11 clipboard
"   "+y     yank a region
"   "+p     put
"   "+yy    yank a line

noremap <c-p> "+p
vmap    <c-c> "+y

" when paste source code and others, please turn on "paste" option
" after finished, turn off "paste"
" :set paste
" :set nopaste


" [CTRL-A is Select all]
nnoremap    <c-a>   ggVG


" [CTRL-S for saving, also in Insert mode]
inoremap    <c-s>   <c-o>:update<cr>
nnoremap    <c-s>   :update<cr>


""""""""""""""""""""""""""""""""""""""""""""""""
" file encoding
""""""""""""""""""""""""""""""""""""""""""""""""
let &termencoding=&encoding
set fileencodings=utf-8,gbk,ucs-bom,cp936,euc-jp,iso-2022-jp,cp932


