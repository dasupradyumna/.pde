" filetype plugin guard
if exists('b:user_ftplugin')
    finish
endif
let b:user_ftplugin = 1

" cosmetic : one-column width between window separator and file contents
setlocal signcolumn=yes:1

" use <Enter> to follow tags
nnoremap <buffer> <C-S> <C-]>
nnoremap <buffer> <C-V> <C-W>v<C-]>
nnoremap <buffer> <C-X> <C-W>s<C-]>
