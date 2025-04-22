" filetype plugin guard
if exists('b:user_ftplugin')
    finish
endif
let b:user_ftplugin = 1

" disable spell checking in SSH config file
setlocal nospell
