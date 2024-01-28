" filetype plugin guard
if exists('b:user_ftplugin')
    finish
endif
let b:user_ftplugin = 1

" disable color column
setlocal colorcolumn=

" use <Enter> to follow tags
nnoremap <buffer> <CR> <C-]>

" cosmetic : one-column width between window separator and file contents
setlocal signcolumn=yes:1
