" filetype plugin guard
if exists('b:user_ftplugin')
    finish
endif
let b:user_ftplugin = 1

" for pretty formatting
setlocal conceallevel=3
