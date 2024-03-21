" filetype plugin guard
if exists('b:user_ftplugin')
    finish
endif
let b:user_ftplugin = 1

" remove statusline override
execute b:undo_ftplugin

" convenient exit
nnoremap <buffer> q <Cmd>cclose<CR>
