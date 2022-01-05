""""""""""""""""""""""""""""""""""""""""""""""""""
" General
""""""""""""""""""""""""""""""""""""""""""""""""""

" Get out of vi's compatible mode
set nocompatible

" How many lines of history
set history=500

" Set to auto read when a file is changed from the outside
"set autoread

" Show commands as they are typed
set showcmd

set nomodeline

""""""""""""""""""""""""""""""""""""""""""""""""""
" Encoding
""""""""""""""""""""""""""""""""""""""""""""""""""

" Use UTF-8
set encoding=utf-8

" Save file as UTF-8
set fileencoding=utf-8

" List of charsets to recognize
set fileencodings=utf-8,cp950,latin1,gbk,euc-jp,utf-16le,ucs-bom,gb2312,korea,gb18030

" Terminal encoding
set termencoding=utf-8

""""""""""""""""""""""""""""""""""""""""""""""""""
" Colors and Fonts
""""""""""""""""""""""""""""""""""""""""""""""""""

" xterm 256 colors
set t_Co=256

" Set color scheme
colorscheme desert
set background=dark

" Enable syntax highlighting
syntax on

" Highlight cursor line
set cursorline
highlight CursorLine cterm=none ctermbg=17
highlight CursorColumn cterm=none ctermbg=17

let g:cursorLineAndColumnState = 1
:function ChangeCursorLineAndColumn()
:    let g:cursorLineAndColumnState = (g:cursorLineAndColumnState + 1) % 4
:    if g:cursorLineAndColumnState == 0
:        set nocursorline
:        set nocursorcolumn
:    elseif g:cursorLineAndColumnState == 1
:        set cursorline
:        set nocursorcolumn
:    elseif g:cursorLineAndColumnState == 2
:        set nocursorline
:        set cursorcolumn
:    elseif g:cursorLineAndColumnState == 3
:        set cursorline
:        set cursorcolumn
:    endif
:endfunction

map <F3> :call ChangeCursorLineAndColumn()<CR>

" Hightlight search term
"highlight Search term=reverse ctermbg=green ctermfg=grey

" Highlight constant and comment
hi Constant ctermfg=DarkRed
hi Comment ctermfg=DarkGrey

" ins-completion popup menu
hi Pmenu ctermbg=DarkBlue ctermfg=Grey
hi PmenuSel ctermbg=DarkGreen ctermfg=white
"set pumheight=16

" Line number
set nu
highlight LineNr term=bold cterm=NONE ctermfg=darkgrey ctermbg=none gui=NONE guifg=DarkGrey guibg=NONE 
map <F4> :set number!<CR><Bar>:echo "Line Number: " . strpart("OffOn", 3 * &number, 3)<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""
" File formats
""""""""""""""""""""""""""""""""""""""""""""""""""

set fileformat=unix
set fileformats=unix

""""""""""""""""""""""""""""""""""""""""""""""""""
" Filetypes
""""""""""""""""""""""""""""""""""""""""""""""""""

filetype on
"filetype plugin on

augroup filetypedetect
  au! BufRead,BufNewFile *.spt setfiletype snippet
augroup END 

autocmd Filetype cpp,c,java,cs set omnifunc=cppcomplete#Complete 

" For txl syntax highlighting
au BufNewFile,BufRead *.Txl,*.txl,*.Grammar,*.grammar,*.Rules,*.rules,*.Module,*.module,*.Mod,*.mod,*.Grm,*.grm,*.Rul,*.rul set ft=txl

" Python related
au BufRead,BufNewFile *.py set ai et nu sw=4 ts=4 tw=79 expandtab
autocmd BufRead,BufNewFile *.py map <F5> :% w !python<CR>
autocmd BufRead,BufNewFile *.py vmap <F5> :w !python<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""
" Interface
""""""""""""""""""""""""""""""""""""""""""""""""""

" Turn on wild menu
set wildmenu

" Show current position
set ruler

" Don't redraw while running macros (faster)
set lazyredraw

" Set backspace
set backspace=indent,eol,start

" Set '\p' as paste toggle
set pastetoggle=<leader>p

" Show matching brackets
set showmatch

" Ruler
set colorcolumn=80
highlight ColorColumn ctermbg=darkGrey
"highlight OverLength ctermbg=red ctermfg=white guibg=#592929
"match OverLength /\%81v.\+/

" Status line
set laststatus=2

" Mouse
"set mouse=a

" Jump to the last position when reopening a file
au BufReadPost * if line("'\"") >= 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

""""""""""""""""""""""""""""""""""""""""""""""""""
" Search
""""""""""""""""""""""""""""""""""""""""""""""""""

" Ignore case
set ignorecase

" Smart case
set smartcase

" Show first match
set incsearch

" Highlight search results
set hlsearch

""""""""""""""""""""""""""""""""""""""""""""""""""
" Tabs
""""""""""""""""""""""""""""""""""""""""""""""""""

" Tabs
nmap <C-T>c :tabnew<CR>
nmap <C-T>k :tabclose<CR>
nmap <C-T>o :tabnew
nmap <C-H> :tabprev<CR>
nmap <C-L> :tabnext<CR>
nmap <C-left> :tabprev<CR>
nmap <C-right> :tabnext<CR>
imap <ESC><C-Left> :tabprev<CR>
imap <ESC><C-Right> :tabnext<CR>
nmap [D :tabprev<CR>
nmap [C :tabnext<CR>
imap [D <ESC>:tabprev<CR>
imap [C <ESC>:tabnext<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""
" Folding
""""""""""""""""""""""""""""""""""""""""""""""""""
set foldenable
"set foldcolumn=5
set foldmethod=indent
set foldlevelstart=999
highlight Folded ctermbg=none ctermfg=grey
highlight FoldColumn ctermbg=none ctermfg=white
"nnoremap <SPACE> @=((foldclosed(line('.')) < 0) ? 'zc' : 'zo')<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""
" Text
""""""""""""""""""""""""""""""""""""""""""""""""""

set autoindent
set cindent

set showmode

set tabstop=4
set shiftwidth=4

"set nowrap

""""""""""""""""""""""""""""""""""""""""""""""""""
" Spell check
""""""""""""""""""""""""""""""""""""""""""""""""""

" Set spelling check
set spelllang=en
map <F2> :set spell!<CR><Bar>:echo "Spell check: " . strpart("OffOn", 3 * &spell, 3)<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""
" List mode
""""""""""""""""""""""""""""""""""""""""""""""""""

set listchars=eol:$,tab:>-,space:.,trail:~,extends:>,precedes:<
map <F7> :set list!<CR><Bar>:echo "Unprintable characters display: " . strpart("OffOn", 3 * &list, 3)<CR>

highlight DiffAdd cterm=none ctermfg=black ctermbg=Green gui=none guifg=black guibg=Green
highlight DiffDelete cterm=none ctermfg=black ctermbg=Red gui=none guifg=black guibg=Red
highlight DiffChange cterm=none ctermfg=black ctermbg=Yellow gui=none guifg=black guibg=Yellow
highlight DiffText cterm=none ctermfg=black ctermbg=Magenta gui=none guifg=black guibg=Magenta

""""""""""""""""""""""""""""""""""""""""""""""""""
" Convert tabs to spaces
""""""""""""""""""""""""""""""""""""""""""""""""""

map <F8> :set expandtab<CR><Bar>:retab<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""
" Remove symbol '^M' (Ctrl+V, Ctrl+M)
""""""""""""""""""""""""""""""""""""""""""""""""""

map <F9> :%s/\r//g<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""
" Run script
""""""""""""""""""""""""""""""""""""""""""""""""""

autocmd BufRead,BufNewFile *.cvc3	map <F5> :% w !clear; cvc3<CR>
autocmd BufRead,BufNewFile *.cvcl	map <F5> :% w !clear; cvcl<CR>
autocmd BufRead,BufNewFile *.pl		map <F5> :% w !clear; perl<CR>
autocmd BufRead,BufNewFile *.py		map <F5> :% w !clear; python<CR>
autocmd BufRead,BufNewFile *.rb		map <F5> :% w !clear; ruby<CR>
autocmd BufRead,BufNewFile *.sh		map <F5> :% w !clear; sh<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""
" Edit Binary
""""""""""""""""""""""""""""""""""""""""""""""""""

" vim -b : edit binary using xxd-format!
augroup Binary
  au!
  au BufReadPre  *.bin let &bin=1
  au BufReadPost *.bin if &bin | %!xxd
  au BufReadPost *.bin set ft=xxd | endif
  au BufWritePre *.bin if &bin | %!xxd -r
  au BufWritePre *.bin endif
  au BufWritePost *.bin if &bin | %!xxd
  au BufWritePost *.bin set nomod | endif
augroup END
