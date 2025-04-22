" filetype plugin guard
if exists('b:user_ftplugin')
    finish
endif
let b:user_ftplugin = 1

" setting it to 101 instead of 100
setlocal colorcolumn=+2
