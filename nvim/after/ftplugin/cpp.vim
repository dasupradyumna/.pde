" filetype plugin guard
if exists('b:user_ftplugin')
    finish
endif
let b:user_ftplugin = 1

" allows jumping between = and ; in assignments
setlocal matchpairs+==:;
