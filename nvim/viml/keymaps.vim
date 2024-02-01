"--------------------------------------- CUSTOM USER KEYMAPS --------------------------------------"

let g:mapleader = ' '
let g:maplocalleader = ' '

"----------------------------------- GENERAL ----------------------------------"

map <Space> <NOP>
map <BS> <NOP>
map! <C-C> <Esc>
noremap ; :
noremap : ;

"----------------------------------- EDITING ----------------------------------"

nnoremap <Leader>o o<Esc>
nnoremap <Leader>O O<Esc>
nnoremap K i<CR><Esc>
nnoremap U <C-R>

" system clipboard
nnoremap <Leader>cc "+y
nnoremap <Leader>cx "+d
nnoremap <Leader>cp "+p
nnoremap <Leader>cP "+P
xnoremap <Leader>cc "+y
xnoremap <Leader>cx "+d
xnoremap <Leader>cp "+p
xnoremap <Leader>cP "+P

"--------------------------------- NAVIGATION ---------------------------------"

nnoremap <C-U> <C-U>zz
nnoremap <C-D> <C-D>zz
nnoremap H zk
nnoremap L zj

" search
nnoremap n nzz
nnoremap N Nzz
nnoremap <Leader>, <Cmd>nohlsearch<CR>

"----------------------------------- WINDOWS ----------------------------------"

nnoremap <C-P> <C-W>p
nnoremap <C-H> <C-W>h
nnoremap <C-J> <C-W>j
nnoremap <C-K> <C-W>k
nnoremap <C-L> <C-W>l

" vertical and horizontal resizing
nnoremap <C-Up> <C-W>+
nnoremap <C-Down> <C-W>-
nnoremap <C-Left> <C-W><
nnoremap <C-Right> <C-W>>

"------------------------------------------------------------------------------"
