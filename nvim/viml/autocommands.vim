"--------------------------------------- CUSTOM USER AUTOCOMMANDS ---------------------------------"

" TODO: exclude all filetypes that have a formatter / LSP
function! s:trim_trailing_whitespace()
    let l:view = winsaveview()
    %s:\s\+$::e
    call winrestview(l:view)
endfunction

function! s:enable_cursorline(enable)
    if a:enable | setlocal cursorline | else | setlocal nocursorline | endif
endfunction

function! s:set_statuscolumn_fold_if_supported()
    " reset statuscolumn to default (if an existing parser is uninstalled)
    setlocal statuscolumn<

    let l:supported = luaeval("require('nvim-treesitter.info').installed_parsers()")
    " BUG: check using mapping from parser name to filetype (typically the same)
    if index(l:supported, &filetype) == -1 | return | endif

    let &l:statuscolumn = '%s%=%l%{ui#statuscolumn_fold()} '
endfunction

augroup __user__
    autocmd!

    " trim all trailing whitespace before writing buffer
    autocmd BufWritePre * call <SID>trim_trailing_whitespace()

    " enable cursorline only in focused window
    autocmd VimEnter,WinEnter * call <SID>enable_cursorline(1)
    autocmd WinLeave * call <SID>enable_cursorline(0)

    " disable colorcolumn in buffers not associated with files
    autocmd BufEnter * if &buftype != '' | setlocal colorcolumn= | endif

    " display treesitter folds in statuscolumn if supported
    autocmd BufEnter * call <SID>set_statuscolumn_fold_if_supported()

augroup END
